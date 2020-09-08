resource "openstack_networking_floatingip_v2" "illume-bastion" {
  pool = var.floating-ip-pool
}

resource "openstack_compute_instance_v2" "illume-bastion" {
  name = "illume-bastion"

  flavor_name = "p2-8gb"
  key_pair    = openstack_compute_keypair_v2.illume.name
  security_groups = [
    openstack_compute_secgroup_v2.illume-bastion.name,
    openstack_compute_secgroup_v2.illume-internal.name,
  ]

  # boot from volume (created from image)
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
}

resource "openstack_compute_floatingip_associate_v2" "illume-bastion" {
  floating_ip = openstack_networking_floatingip_v2.illume-bastion.address
  instance_id = openstack_compute_instance_v2.illume-bastion.id

  connection {
    host        = openstack_networking_floatingip_v2.illume-bastion.address
    user        = var.ssh_user_name
    private_key = file(var.ssh_key_file)
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
    inline = ["#wait"]
  }

  provisioner "file" {
    source      = var.ssh_key_file
    destination = "/home/${var.ssh_user_name}/.ssh/illume-new"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod og-rwx /home/${var.ssh_user_name}/.ssh/illume-new",
    ]
  }

  provisioner "file" {
    content = <<EOF
Host 192.168.254.*
  User ubuntu
  Port 2222
  IdentityFile /home/${var.ssh_user_name}/.ssh/illume-new
EOF


    destination = "/home/${var.ssh_user_name}/.ssh/config"
  }
}

