resource "openstack_compute_instance_v2" "illume-worker-1080ti" {
    depends_on = ["openstack_compute_floatingip_associate_v2.illume-bastion"]

    count = 11
    name = "${format("illume-worker-1080ti-%02d", count.index+1)}"

    image_id        = "${openstack_images_image_v2.illume-ubuntu.id}"
    flavor_name     = "${var.flavor-worker-1080ti}"
    key_pair        = "${openstack_compute_keypair_v2.illume.name}"
    security_groups = [
      "${openstack_compute_secgroup_v2.illume-internal.name}"
    ]

    # boot device (ephemeral)
    block_device {
       boot_index            = 0
       delete_on_termination = true
       destination_type      = "local"
       source_type           = "image"
       uuid                  = "${openstack_images_image_v2.illume-ubuntu.id}"
    }

    # assign all ephemeral storage for this flavor (2048GB),
    # then split it up into partitions.
    # (OpenStack on cirrus did not seem to allow me to create more
    # than 2 ephemeral disks, so use partitions on a single disk instead.)
    block_device {
       boot_index            = -1
       delete_on_termination = true
       destination_type      = "local"
       source_type           = "blank"
       volume_size           = 2048
     }

    # split ephemeral storage into 3 parts:
    #  205GB - ephemeral0.1 (10%)
    #  205GB - ephemeral0.2 (10%)
    #   61GB - ephemeral0.3 ( 3%)
    # 1577GB - ephemeral0.4 (77%)
    # mount ephemeral storage #0.1 to /var/lib/docker
    # mount ephemeral storage #0.2 to /var/lib/kubelet
    # mount ephemeral storage #0.3 to /var/lib/cvmfs
    # mount ephemeral storage #0.4 to /cephstore
    user_data       = <<EOF
#cloud-config
disk_setup:
  ephemeral0:
    table_type: 'gpt'
    layout:
      - 10
      - 10
      - 3
      - 77
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
  - label: ephemeral0.4
    filesystem: 'ext4'
    device: 'ephemeral0.4'

mounts:
  - [ ephemeral0.1, /var/lib/docker ]
  - [ ephemeral0.2, /var/lib/kubelet ]
  - [ ephemeral0.3, /var/lib/cvmfs ]
  - [ ephemeral0.4, /cephstore ]
EOF

    network {
      name = "${var.network}"
    }

    provisioner "remote-exec" {
      connection {
        host     = "${self.network.0.fixed_ip_v4}"
        user     = "${var.ssh_user_name}"
        private_key = "${file(var.ssh_key_file)}"
        port     = 22

        bastion_host = "${openstack_compute_floatingip_v2.illume-bastion.address}"
        bastion_user = "${var.ssh_user_name}"
        bastion_private_key = "${file(var.ssh_key_file)}"
        bastion_port = 22
      }

      inline = [
        "sudo DEBIAN_FRONTEND=noninteractive apt-get -y update",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python",
        "sudo sed -i 's/^[# ]*Port .*/Port 2222/' /etc/ssh/sshd_config",
        "sudo shutdown -r now",
      ]
    }

    connection {
      host     = "${self.network.0.fixed_ip_v4}"
      user     = "${var.ssh_user_name}"
      private_key = "${file(var.ssh_key_file)}"
      port     = 2222

      bastion_host = "${openstack_compute_floatingip_v2.illume-bastion.address}"
      bastion_user = "${var.ssh_user_name}"
      bastion_private_key = "${file(var.ssh_key_file)}"
      bastion_port = 22
    }

    provisioner "remote-exec" {
      inline = [ "#wait" ]
    }

    provisioner "file" {
      source = "${var.ssh_key_file}"
      destination = "/home/${var.ssh_user_name}/.ssh/illume_key"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod og-rwx /home/${var.ssh_user_name}/.ssh/illume_key",
      ]
    }

}
