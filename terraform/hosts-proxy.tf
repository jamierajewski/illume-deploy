resource "openstack_compute_instance_v2" "illume-proxy" {
    depends_on = ["openstack_compute_floatingip_associate_v2.illume-bastion"]

    count = 2
    name = "${format("illume-proxy-%02d", count.index+1)}"

    image_id      = "${openstack_images_image_v2.illume-ubuntu.id}"
    # boot device (ephemeral)
    block_device {
       boot_index            = 0
       delete_on_termination = true
       destination_type      = "local"
       source_type           = "image"
       uuid                  = "${openstack_images_image_v2.illume-ubuntu.id}"
    }

    # first ephemeral drive (180GB)
    block_device {
       boot_index            = -1
       delete_on_termination = true
       destination_type      = "local"
       source_type           = "blank"
       volume_size           = 180
     }

    # mount ephemeral storage #0 to /var/spool/squid [do not use it here, use 100%
    # volume storage]
    user_data       = <<EOF
#cloud-config
mounts:
  - [ ephemeral0, /var/spool/squid ]
EOF

    flavor_name     = "c4-16GB-180"
    key_pair        = "${openstack_compute_keypair_v2.illume.name}"
    security_groups = [
      "${openstack_compute_secgroup_v2.illume-internal.name}"
    ]

    network {
      name = "${var.network}"
    }

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


    provisioner "remote-exec" {
      inline = [
        "sudo DEBIAN_FRONTEND=noninteractive apt-get -y update",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python",
        "sudo shutdown -r now",
      ]
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
