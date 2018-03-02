resource "openstack_compute_floatingip_v2" "illume-bastion" {
  pool       = "${var.floating-ip-pool}"
}

resource "openstack_compute_instance_v2" "illume-bastion" {
    name = "illume-bastion"

    # boot from volume (created from image)
    block_device {
        uuid                  = "${openstack_images_image_v2.illume-ubuntu.id}"
        source_type           = "image"
        volume_size           = "${var.volume-size-bastion}"
        boot_index            = 0
        destination_type      = "volume"
        delete_on_termination = true
    }

    # first ephemeral drive (45GB)
    block_device {
       boot_index            = -1
       delete_on_termination = true
       destination_type      = "local"
       source_type           = "blank"
       volume_size           = 45
     }

    # mount ephemeral storage #0 to /var/lib/docker
    user_data       = "#cloud-config\nmounts:\n  - [ ephemeral0, /var/lib/docker ]"

    #image_name      = "${openstack_images_image_v2.illume-ubuntu.name}"

    flavor_name     = "${var.flavor-bastion}"
    key_pair        = "${openstack_compute_keypair_v2.illume.name}"
    security_groups = [
      "${openstack_compute_secgroup_v2.illume-bastion.name}",
      "${openstack_compute_secgroup_v2.illume-internal.name}"
    ]

    network {
       name = "${var.network}"
    }

}

resource "openstack_compute_floatingip_associate_v2" "illume-bastion" {
  floating_ip = "${openstack_compute_floatingip_v2.illume-bastion.address}"
  instance_id = "${openstack_compute_instance_v2.illume-bastion.id}"

  connection {
    host = "${openstack_compute_floatingip_v2.illume-bastion.address}"
    user     = "${var.ssh_user_name}"
    private_key = "${file(var.ssh_key_file)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python",
      "sudo shutdown -r now",
      "sleep 2",
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

  provisioner "file" {
    content     = <<EOF
Host 192.168.19.*
  User ubuntu
  Port 2222
  IdentityFile /home/${var.ssh_user_name}/.ssh/illume_key
EOF
    destination = "/home/${var.ssh_user_name}/.ssh/config"
  }

}
