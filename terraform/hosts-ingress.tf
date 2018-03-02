resource "openstack_compute_instance_v2" "illume-ingress" {
    depends_on = ["openstack_compute_floatingip_associate_v2.illume-bastion"]

    count = 1
    name = "${format("illume-ingress-%02d", count.index+1)}"

    image_id      = "${openstack_images_image_v2.illume-ubuntu.id}"
    flavor_name     = "${var.flavor-ingress}"
    key_pair        = "${openstack_compute_keypair_v2.illume.name}"
    security_groups = [
      "${openstack_compute_secgroup_v2.illume-ingress.name}",
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

    # first ephemeral drive (45GB)
    block_device {
       boot_index            = -1
       delete_on_termination = true
       destination_type      = "local"
       source_type           = "blank"
       volume_size           = 45
    }

    # second ephemeral drive (45GB)
    block_device {
       boot_index            = -1
       delete_on_termination = true
       destination_type      = "local"
       source_type           = "blank"
       volume_size           = 45
    }

    # mount ephemeral storage #0 to /var/lib/docker
    # mount ephemeral storage #1 to /var/lib/kubelet
    user_data       = "#cloud-config\nmounts:\n  - [ ephemeral0, /var/lib/docker ]\n  - [ ephemeral1, /var/lib/kubelet ]"

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

# attach a floating IP to this one
resource "openstack_compute_floatingip_v2" "illume-ingress" {
  pool       = "${var.floating-ip-pool}"
}

resource "openstack_compute_floatingip_associate_v2" "illume-ingress" {
  floating_ip = "${openstack_compute_floatingip_v2.illume-ingress.address}"
  instance_id = "${openstack_compute_instance_v2.illume-ingress.id}"
}
