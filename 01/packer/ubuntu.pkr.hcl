packer {
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}
source "virtualbox-iso" "ubuntu2204-vb" {
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  boot_wait               = "10s"
  communicator            = "ssh"
  cpus                    = "${var.vm_cpus}"
  memory                  = "${var.vm_memory}"
  disk_size               = "32768"
  guest_os_type           = "Ubuntu_64"
  guest_additions_mode    = "disable"
  iso_checksum            = "${var.iso_checksum}"
  iso_url                 = "${var.iso_url}"
  shutdown_command        = "sudo -S shutdown now"
  ssh_username            = "vagrant"
  ssh_password            = "${var.ssh_pass}"
  ssh_port                = "22"
  ssh_timeout             = "60m"
  ssh_pty                 = true
  vm_name                 = "${var.image_name}"
  cd_label                = "cidata"
  output_directory        = "builds"
  http_directory          = "http"
  export_opts = [
      "--manifest",
      "--vsys", "0",
      "--description", "${var.vm_description}",
      "--version", "${var.vm_version}"
  ]
  vboxmanage = [
   ["modifyvm", "{{.Name}}", "--memory", "${var.vm_memory}"],
   ["modifyvm", "{{.Name}}", "--cpus", "${var.vm_cpus}"],
   ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"]
  ]
}
build {
  sources = ["sources.virtualbox-iso.ubuntu2204-vb"]
  provisioner "shell" {
    expect_disconnect = true
    scripts = [
      "scripts/stage-1-kernel-update.sh",
      "scripts/stage-2-clean.sh"
      ]
    pause_before = "20s"
    start_retry_timeout = "1m"
  }
   post-processors {
    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "virtualbox"
    }
  }
}