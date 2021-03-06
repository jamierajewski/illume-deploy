resource "openstack_compute_instance_v2" "illume-worker-nogpu-4core" {
  depends_on = [
    openstack_compute_floatingip_associate_v2.illume-bastion,
    openstack_compute_instance_v2.illume-worker-1080ti,
  ]

  count = 0
  name  = format("illume-worker-nogpu-4core-%02d", count.index + 1)

  flavor_name = "c4-32GB-360"
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

  # assign all ephemeral storage for this flavor (360GB),
  # then split it up into partitions.
  # (OpenStack on cirrus did not seem to allow me to create more
  # than 2 ephemeral disks, so use partitions on a single disk instead.)
  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = 360
  }

  # split ephemeral storage into 3 parts:
  #  122GB - ephemeral0.1 (34%)
  #  209GB - ephemeral0.2 (58%)
  #   29GB - ephemeral0.3 ( 8%)
  # mount ephemeral storage #0.1 to /var/lib/docker
  # mount ephemeral storage #0.2 to /var/lib/kubelet
  # mount ephemeral storage #0.3 to /var/lib/cvmfs
  user_data = <<EOF
#cloud-config
disk_setup:
  ephemeral0:
    table_type: 'gpt'
    layout:
      - 34
      - 58
      - 8
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

      bastion_host        = openstack_compute_floatingip_v2.illume-bastion.address
      bastion_user        = var.ssh_user_name
      bastion_private_key = file(var.ssh_key_file)
      bastion_port        = 22
    }

    inline = [
      "sudo sed -i 's/^[# ]*Port .*/Port 2222/' /etc/ssh/sshd_config",
      "sudo shutdown -r now",
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.network[0].fixed_ip_v4
      user        = var.ssh_user_name
      private_key = file(var.ssh_key_file)
      port        = 22

      bastion_host        = openstack_compute_floatingip_v2.illume-bastion.address
      bastion_user        = var.ssh_user_name
      bastion_private_key = file(var.ssh_key_file)
      bastion_port        = 22
    }

    inline = [
      "sudo sed -i 's/^[# ]*Port .*/Port 2222/' /etc/ssh/sshd_config",
      "sudo shutdown -r +0",
    ]

    on_failure = continue
  }

  connection {
    type        = "ssh"
    host        = self.network[0].fixed_ip_v4
    user        = var.ssh_user_name
    private_key = file(var.ssh_key_file)
    port        = 2222

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

