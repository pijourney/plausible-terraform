variable "api_key" {
  type = string
  description = "Vultr API key"
}
variable "ssh_key" {
  type = string
  description = "SSH key"
}
variable "domain_name" {
  type = string
  description = "Domain name"
}
## can be found https://www.vultr.com/api/#operation/list-regions
variable "vultr_region" {
  type = string
  description = "Vultr region"

}
## Can be found https://www.vultr.com/api/#tag/plans
variable "vultr_plan" {
  type = string
  description = "Vultr plan"
}
