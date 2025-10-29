#################
# CONTEXTE GCE
#################

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "cv-wordpress" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
  tags = ["http-server"]

  scheduling {
    preemptible = true
    automatic_restart = false
    provisioning_model = SPOT
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      type = pd-SSD
    }
  }


#################
# RESEAU
#################

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}


##################
# INITIALISATION VM
##################

# Copie le script d'installation et les fichiers Docker sur la VM
provisioner "file" {
  source      = "scripts/setup.sh"
  destination = "/tmp/setup_vm.sh"
}

provisioner "file" {
  source      = "../../" # Chemin vers ton dépôt local (docker-compose.yml, Dockerfiles, etc.)
  destination = "/home/cv-wordpress"
}

# Exécute le script d'installation
provisioner "remote-exec" {
  inline = [
    "chmod +x /tmp/setup_vm.sh",
    "/tmp/setup_vm.sh"
  ]
}