variable "username" { }

variable "password" { }

variable "image-url" {
  # default = "https://cloud-images.ubuntu.com/artful/current/artful-server-cloudimg-amd64.img"
  default = "https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img"
}

variable "image-name" {
  # default = "illume-ubuntu-aartful"
  default = "illume-ubuntu-xenial"
}

variable "volume-size-control" {
  default = "120"
}

variable "volume-size-bastion" {
  default = "30"
}

variable "flavor-bastion" {
  default = "c2-4GB-45"
}

variable "flavor-proxy" {
  default = "c4-16GB-180"
}

variable "flavor-control" {
  default = "c4-8GB-90"
}

variable "flavor-ingress" {
  default = "c4-8GB-90"
}

variable "flavor-worker-1080ti" {
  default = "c8-64gb-2048-4.1080ti"
}

variable "flavor-worker-nogpu" {
  default = "c8-64GB-720"
}

variable "ssh_key_file" {
  default = "~/.ssh/illume_key"
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "floating-ip-pool" {
  default = "ext-net"
}

variable "network" {
  default = "IceCube_network"
}

variable "local_subnet" {
  default = "192.168.19.0/24"
}
