# Configure the OpenStack Provider
provider "openstack" {
  version     = "~> 1.2" # might want to update this later to a more modern version
  user_name   = "${var.username}"
  tenant_name = "IceCube"
  tenant_id   = "0f4d05d808fb40fe9df8ddd33c576cb2"
  password    = "${var.password}"
  auth_url    = "https://cirrus.ualberta.ca:5000/v3"
  region      = "RegionOne"
  domain_name = "CCDB"
}
