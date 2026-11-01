variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "instance_name" {
  description = "Name for the compute instance and associated resources"
  type        = string
  default     = "vllm-server"
}

variable "machine_type" {
  description = "GCP machine type"
  type        = string
}

variable "gpu_type" {
  description = "GPU accelerator type"
  type        = string
}

variable "gpu_count" {
  description = "Number of GPUs to attach"
  type        = number
  default     = 1
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
}

variable "ssh_user" {
  description = "Linux user for SSH access"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file on your local machine"
  type        = string
}

variable "ssh_trusted_cidr" {
  description = "CIDR block allowed to reach port 22"
  type        = string
}

variable "running" {
  description = "Set to false to stop the instance without destroying it. Stops GPU billing immediately. Disk and static IP still accrue"
  type        = bool
  default     = true
}

variable "wireguard_port" {
  description = "UDP port WireGuard listens on"
  type        = number
  default     = 51820
}
