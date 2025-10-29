#!/bin/bash

# Installe Docker et Docker Compose
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

# Clone ou copie ton dépôt (déjà fait via le provisioner "file" dans main.tf)
cd /home/cv-wordpress

# Lance docker-compose
sudo docker-compose up -d