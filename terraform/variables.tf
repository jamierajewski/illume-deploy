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
