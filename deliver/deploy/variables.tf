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
  type        = string
  default     = "nbg1"
  description = "Hetzner location nbg1 as default, sin for Singapore"
}

variable "networkzone" {
  type        = string
  default     = "eu-central" # must be compatible with the location (eu-central for nbg1 )
  description = "Hetzner networkzone eu-central as default, ap-southeast for Singapore"
}

variable "dind-rootless" {
  description = "Use rootless dind image for webshell"
  type        = bool
  default     = true
}

variable "dind-enabled" {
  description = "Enable dind for webshell, set to false for plain kubernetes trainings"
  type        = bool
  default     = true
}

variable "dind-persistence-enabled" {
  description = "Enable dind persistence for webshell, set to false for rootless dind trainings"
  type        = bool
  default     = true
}

variable "controlplane_type" {
  type        = string
  default     = "cx33" #cx33 4cpu/8gbRAM use cpx32 in singapore
  description = "machine type to use for the controlplanes"
}

variable "worker_type" {
  type        = string
  default     = "cx43" #cx43 4cpu/16gbRAM use cpx42 in singapore
  description = "machine type to use for the worker"
}

variable "user_vm_node_type" {
  type        = string
  default     = "cx23" #cx23 2cpu/4 GB use cpx12 in singapore
  description = "machine type to use for the vm"
}
