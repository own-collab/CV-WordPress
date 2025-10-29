variable "project_id" {
  description = "#########"
  type        = string
}

variable "region" {
  description = "Région GCP : EUROPE-OUEST (depuis PARIS)"
  type        = string
  default     = "europe-west9"
}

variable "zone" {
  description = "Zone GCP : PARIS"
  type        = string
  default     = "europe-west9-b"
}

# https://cloud.google.com/products/calculator?hl=fr
# https://cloud.google.com/compute/docs/disks/local-ssd?hl=fr#machine-types
variable "machine_type" {
  description = "Type de VM"
  type        = string
  default     = "g1-small"
}

variable "vm_name" {
  description = "Nom de la VM"
  type        = string
  default     = "cv-wordpress"
}
