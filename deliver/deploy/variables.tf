variable "hcloud_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_zone_id" {
  type = string
}

variable "user-vms-enabled" {
  type    = bool
  default = false
}

variable "user-vms-unattached-enabled" {
  description = "Deploy free floating VMs next to the cluster"
  type        = bool
  default     = false
}

variable "user-vms-unattached-count" {
  description = "Deploy free floating VMs next to the cluster"
  type        = number
  default     = 0
}

variable "count-students" {
  description = "Number of students for the training cluster sizing"
  type        = number
  default     = 3
}

variable "worker_count" {
  description = "Number of worker nodes in the training cluster, a minimum of 3 is required"
  type        = number
  default     = 3
}

variable "location" {
  type    = string
  default = "nbg1"
  description = "Hetzner location nbg1 as default, sin for Singapore"
}

variable "networkzone" {
  type    = string
  default = "eu-central" # must be compatible with the location (eu-central for nbg1 )
  description = "Hetzner networkzone eu-central as default, ap-southeast for Singapore"
}