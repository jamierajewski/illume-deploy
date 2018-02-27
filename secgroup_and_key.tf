resource "openstack_compute_keypair_v2" "illume" {
  name       = "illume"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_compute_secgroup_v2" "illume-ingress" {
  name        = "illume"
  description = "Security group for illume ingress instances"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2222
    to_port     = 2222
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "illume-bastion" {
  name        = "illume-bastion"
  description = "Security group for illume-bastion instances"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2222
    to_port     = 2222
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }

  # bastion should be able to run rancher (which needs port 443)
  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "illume-internal" {
  name = "illume-internal"
  description = "Allow internal traffic between all nodes"
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "tcp"
    cidr = "${var.local_subnet}"
  }
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "udp"
    cidr = "${var.local_subnet}"
  }
  rule {
    from_port = -1
    to_port = -1
    ip_protocol = "icmp"
    cidr = "${var.local_subnet}"
  }
}
