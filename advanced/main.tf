terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.10.0"
    }
  }
}

provider "google" {
  project = "your-gcp-project-id"
  region  = "asia-southeast2"
  zone    = "asia-southeast2-a"
}

variable "sshuser" {
  type = string
  default = "dojo"
}

variable "redhat_username" {
  type = string
  default = "your-redhat-login"
}

variable "redhat_password" {
  type = string
  default = "your-redhat-login"
}

resource "google_compute_instance" "dojo-vm" {
  name = "dojo-vm"
  machine_type = "e2-small"

  boot_disk {
    initialize_params {
        image = "rhel-7-v20220126"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // leave empty to enable ephemeral IP
    }
  }

  // https://stackoverflow.com/a/38647811
  // https://cloud.google.com/compute/docs/connect/add-ssh-keys?authuser=1#during-vm-creation
  metadata = {
    "ssh-keys" = format("%s:%s", var.sshuser, file("${path.module}/public_key"))  // "${var.sshuser}:${var.public_key}"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = self.network_interface.0.access_config.0.nat_ip // https://github.com/hashicorp/terraform-provider-google/issues/3089#issuecomment-465683040
      user = "${var.sshuser}"
      private_key = file(format("%s", "${path.module}/private_key")) // "${var.private_key}"
    }

    inline = [
        "sudo yum -y install subscription-manager* --noplugins",
        "sudo subscription-manager register --username=${var.redhat_username} --password=${var.redhat_password} --auto-attach"
    ]
  }

  provisioner "local-exec" {
    working_dir = "${path.module}"
    command = "chmod 400 private_key && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.sshuser} -i '${self.network_interface.0.access_config.0.nat_ip},' --private-key ${abspath("private_key")} -e 'pub_key=${file(abspath("public_key"))}' playbook.yml"
  }
}