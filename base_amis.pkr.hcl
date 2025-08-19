data "amazon-ami" "debian_trixie_arm64" {
  filters = {
    architecture        = "arm64"
    name                = "debian-13-arm64-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["136693071363"]
  region      = var.build_region
}

data "amazon-ami" "debian_trixie_x86_64" {
  filters = {
    architecture        = "x86_64"
    name                = "debian-13-amd64-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["136693071363"]
  region      = var.build_region
}
