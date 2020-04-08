resource "openstack_compute_instance_v2" "illume-worker-1080ti" {
  depends_on = [openstack_compute_floatingip_associate_v2.illume-bastion]

  count = 11
  name  = format("illume-worker-1080ti-%02d", count.index + 1)

  flavor_name = "c16-116gb-3400-4.1080ti"
  image_id    = openstack_images_image_v2.illume-ubuntu.id
  key_pair    = openstack_compute_keypair_v2.illume.name
  security_groups = [
    openstack_compute_secgroup_v2.illume-internal.name,
  ]

  # boot device (ephemeral)
  block_device {
    boot_index            = 0
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "image"
    uuid                  = openstack_images_image_v2.illume-ubuntu.id
  }

  # assign all ephemeral storage for this flavor (3400GB),
  # then split it up into partitions.
  # (OpenStack on cirrus did not seem to allow me to create more
  # than 2 ephemeral disks, so use partitions on a single disk instead.)
  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 3400
  }

  # split ephemeral storage into 3 parts:
  #  204GB - ephemeral0.1 ( 6%)
  # 3128GB - ephemeral0.2 (92%)
  #   68GB - ephemeral0.3 ( 2%)
  # mount ephemeral storage #0.1 to /var/lib/docker
  # mount ephemeral storage #0.2 to /var/lib/kubelet
  # mount ephemeral storage #0.3 to /var/lib/cvmfs
  user_data = <<EOF
#cloud-config
disk_setup:
  ephemeral0:
    table_type: 'gpt'
    layout:
      - 6
      - 92
      - 2
    overwrite: true

fs_setup:
  - label: ephemeral0.1
    filesystem: 'ext4'
    device: 'ephemeral0.1'
  - label: ephemeral0.2
    filesystem: 'ext4'
    device: 'ephemeral0.2'
  - label: ephemeral0.3
    filesystem: 'ext4'
    device: 'ephemeral0.3'

mounts:
  - [ ephemeral0.1, /var/lib/docker ]
  - [ ephemeral0.2, /var/lib/kubelet ]
  - [ ephemeral0.3, /var/lib/cvmfs ]
EOF


  network {
    name = var.network
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.network[0].fixed_ip_v4
      user        = var.ssh_user_name
      private_key = file(var.ssh_key_file)
      port        = 22
      timeout     = "20m"

      bastion_host        = openstack_compute_floatingip_v2.illume-bastion.address
      bastion_user        = var.ssh_user_name
      bastion_private_key = file(var.ssh_key_file)
      bastion_port        = 22
    }

    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python",
      "sudo sed -i 's/^[# ]*Port .*/Port 2222/' /etc/ssh/sshd_config",
      "sudo shutdown -r +1",
    ]
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }

  connection {
    type        = "ssh"
    host        = self.network[0].fixed_ip_v4
    user        = var.ssh_user_name
    private_key = file(var.ssh_key_file)
    port        = 2222
    timeout     = "20m"

    bastion_host        = openstack_compute_floatingip_v2.illume-bastion.address
    bastion_user        = var.ssh_user_name
    bastion_private_key = file(var.ssh_key_file)
    bastion_port        = 22
  }

  provisioner "remote-exec" {
    inline = ["#wait"]
  }

  provisioner "file" {
    source      = var.ssh_key_file
    destination = "/home/${var.ssh_user_name}/.ssh/illume_key"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod og-rwx /home/${var.ssh_user_name}/.ssh/illume_key",
    ]
  }
}

