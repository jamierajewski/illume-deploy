# resource "openstack_compute_keypair_v2" "illume" {
#   name       = "illume"
#   public_key = file("${var.ssh_key_file}.pub")
# }

# Allow traffic outgoing to any port, and traffic between nodes on any port
# but the same subnet (egress rules are autogenerated)
resource "openstack_networking_secgroup_v2" "illume-internal-v2" {
  name        = "illume-internal-v2"
  description = "Allow internal traffic between all nodes"
}

resource "openstack_networking_secgroup_rule_v2" "internal-v2-rule1"{
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.illume-internal-v2.id
  remote_ip_prefix  = var.local_subnet
}
