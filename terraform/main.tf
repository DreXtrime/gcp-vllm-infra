terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_address" "vllm" {
  name   = "${var.instance_name}-ip"
  region = var.region
}

resource "google_compute_firewall" "wireguard" {
  name    = "${var.instance_name}-wireguard"
  network = "default"

  allow {
    protocol = "udp"
    ports    = [var.wireguard_port]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.instance_name]
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.instance_name}-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.ssh_trusted_cidr]
  target_tags   = [var.instance_name]
}

resource "google_compute_firewall" "deny_all_ingress" {
  name     = "${var.instance_name}-deny-ingress"
  network  = "default"
  priority = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.instance_name]
}

resource "google_compute_instance" "vllm" {
  name           = var.instance_name
  machine_type   = var.machine_type
  zone           = var.zone
  desired_status = var.running ? "RUNNING" : "TERMINATED"

  tags = [var.instance_name]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.boot_disk_size_gb
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.vllm.address
    }
  }

  scheduling {
    on_host_maintenance = var.gpu_count > 0 ? "TERMINATE" : "MIGRATE"
  }

  dynamic guest_accelerator {
    for_each = var.gpu_count > 0 ? [1] : []
    content {
      type = var.gpu_type
      count = var.gpu_count
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
