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