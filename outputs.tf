#################
# IP PUBLIQUE VM
#################

output "vm_public_ip" {
  description = "IP publique de la VM"
  value       = google_compute_instance.cv_wordpress.network_interface[0].access_config[0].nat_ip
}