variable "count-students" {
  type    = number
  default = 0
}

variable "student-passwords" {
  type = list(any)
}

variable "studentname-prefix" {
  type    = string
  default = "student"
}

variable "location" {
  type        = string
  default     = "nbg1"
  description = "hetzner location"
}

variable "cluster_name" {
  type        = string
  description = "name of the cluster"
}

variable "node_type" {
  type        = string
  default     = "cx23" #cx23 2cpu/4 GB
  description = "machine type to use for the vm"
}

variable "enable_password_login" {
  type        = bool
  default     = false
  description = "Enable password login for VMs"
}