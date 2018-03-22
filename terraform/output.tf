output "bastion-address" {
  value = "${openstack_compute_instance_v2.illume-bastion.0.network.0.fixed_ip_v4}"
}

output "bastion-address-public" {
  value = "${openstack_compute_floatingip_v2.illume-bastion.address}"
}

output "illume-proxy-addresses" {
  value = "${openstack_compute_instance_v2.illume-proxy.*.network.0.fixed_ip_v4}"
}

output "illume-control-addresses" {
  value = "${openstack_compute_instance_v2.illume-control.*.network.0.fixed_ip_v4}"
}

output "illume-worker-1080ti-addresses" {
  value = "${openstack_compute_instance_v2.illume-worker-1080ti.*.network.0.fixed_ip_v4}"
}

output "illume-worker-titanx-addresses" {
  value = "${openstack_compute_instance_v2.illume-worker-titanx.*.network.0.fixed_ip_v4}"
}

output "illume-worker-titanxp-addresses" {
  value = "${openstack_compute_instance_v2.illume-worker-titanxp.*.network.0.fixed_ip_v4}"
}

output "illume-worker-nogpu-10core-addresses" {
  value = "${openstack_compute_instance_v2.illume-worker-nogpu-10core.*.network.0.fixed_ip_v4}"
}

output "illume-worker-nogpu-8core-addresses" {
  value = "${openstack_compute_instance_v2.illume-worker-nogpu-8core.*.network.0.fixed_ip_v4}"
}

output "illume-worker-nogpu-4core-addresses" {
  value = "${openstack_compute_instance_v2.illume-worker-nogpu-4core.*.network.0.fixed_ip_v4}"
}

output "illume-ingress-addresses" {
  value = "${openstack_compute_instance_v2.illume-ingress.*.network.0.fixed_ip_v4}"
}

output "illume-ingress-addresses-public" {
  value = "${openstack_compute_floatingip_v2.illume-ingress.*.address}"
}

output "subnet" {
  value = "${var.local_subnet}"
}

output "ssh-key-file" {
  value = "${var.ssh_key_file}"
}

output "ssh-username" {
  value = "${var.ssh_user_name}"
}
