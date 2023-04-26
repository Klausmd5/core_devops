packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "headless" {
  default = false
}

source "virtualbox-iso" "synopsis-host" {
  iso_url      = "https://releases.ubuntu.com/22.04.2/ubuntu-22.04.2-live-server-amd64.iso"
  iso_checksum = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"

  cpus   = 4
  memory = 4096

  headless = var.headless

  vm_name              = "Synopsis"
  guest_os_type        = "Ubuntu_64"
  guest_additions_mode = "disable"

  # fix network issue
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
  ]

  boot_wait    = "5s"
  boot_command = [
    "e<wait>",
    "<down><down><down>",
    "<end><bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  http_directory = "http"

  ssh_handshake_attempts = "10000"
  ssh_timeout            = "2h"
  ssh_username           = "synopsis"
  ssh_password           = "initial-setup"

  shutdown_command = "sudo shutdown -P now"

  format          = "ova"
  output_filename = "synopsis"
}

build {
  sources = ["source.virtualbox-iso.synopsis-host"]

  provisioner "shell" {
    script = "../scripts/install-docker.sh"
  }

  provisioner "shell" {
    inline = [
      "mkdir public-keys",
      "mkdir private-keys"
    ]
  }

  provisioner "file" {
    source = "../docker-compose.yml"
    destination = "~/docker-compose.yml"
  }

  provisioner "file" {
    source = "../mainframe-config.json"
    destination = "~/mainframe-config.json"
  }

  provisioner "file" {
    source = "../.env"
    destination = "~/.env"
  }

  provisioner "file" {
    source      = "../scripts/generate-keys.sh"
    destination = "~/generate-keys.sh"
  }

  provisioner "file" {
    source      = "../scripts/validate-download-links.sh"
    destination = "~/validate-download-links.sh"
  }

  provisioner "file" {
    source      = "../scripts/first-time-setup.sh"
    destination = "~/first-time-setup.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x generate-keys.sh",
      "chmod +x validate-download-links.sh",
      "chmod +x first-time-setup.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '~/first-time-setup.sh' >> .profile",
      "sudo touch /etc/cloud/cloud-init.disabled",
      "sudo rm -v /etc/ssh/ssh_host_*", # remove ssh keys, will be regenerated on first boot by line above
      "sudo passwd --delete synopsis" # remove "initial-setup" password
    ]
  }
}
