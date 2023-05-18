output "plausible_instance_ip" {
  value = vultr_instance.plausible_instance.main_ip
  description = "The IP address of the Plausible instance."
}