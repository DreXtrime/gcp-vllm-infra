output "instance_ip" {
  description = "Public IP of the vLLM server"
  value       = google_compute_address.vllm.address
}

output "instance_name" {
  description = "Compute instance name"
  value       = google_compute_instance.vllm.name
}
