resource "openstack_compute_instance_v2" "illume-control" {
  depends_on = [
    openstack_compute_floatingip_associate_v2.illume-bastion,
    openstack_compute_instance_v2.illume-worker-1080ti,
  ]

  count = 3
  name  = format("illume-control-%02d", count.index + 1)

  flavor_name = "p4-32gb-1socket"
  key_pair    = openstack_compute_keypair_v2.illume.name
  security_groups = [
    openstack_compute_secgroup_v2.illume-internal.name,
  ]

  block_device {
    uuid                  = openstack_images_image_v2.illume-ubuntu.id
    source_type           = "image"
    volume_size           = "120"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

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
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python",
      "sudo sed -i 's/^[# ]*Port .*/Port 2222/' /etc/ssh/sshd_config",
      "sudo shutdown -r now",
    ]
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

