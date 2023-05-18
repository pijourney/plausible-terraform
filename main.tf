terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "vultr" {
  api_key = var.api_key
}
resource "vultr_ssh_key" "plausible_ssh_key" {
  name = "plausible-ssh-key"
  ssh_key = var.ssh_key
}
resource "random_password" "password" {
  length           = 64
  special          = true
  override_special = "_%@"
}
resource "vultr_instance" "plausible_instance" {
    plan              =       var.vultr_plan
    region            =       var.vultr_region
    image_id          =       "docker" // docker on ubuntu 22.04
    backups           =       "disabled" // disables backup costs 10$/month extra.
    label             =       "plausible"
    hostname          =       var.domain_name
    tags              =       ["plausible"]
    ddos_protection   =       false
    enable_ipv6       =       false
    ssh_key_ids       =       [vultr_ssh_key.plausible_ssh_key.id] 
    user_data = <<-EOF
    #!/bin/bash
    ## install docker compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    ## git clone
    git clone https://github.com/plausible/hosting plausible
    cd plausible
    ## edit plausible-conf.env
    sed -i 's/BASE_URL=replace-me/BASE_URL=https:\/\/${var.domain_name}/g' plausible-conf.env
    sed -i "s/SECRET_KEY_BASE=replace-me/SECRET_KEY_BASE=${random_password.password.result}/g" plausible-conf.env

    ## change docker-compose.yml
    sed -i 's/- 8000:8000/- 127.0.0.1:8000:8000/g' docker-compose.yml

    ## configure caddy-gen
    sed -i 's/example.com/${var.domain_name}/g' reverse-proxy/docker-compose.caddy-gen.yml

    ## start plausible docker compose
    docker-compose -f docker-compose.yml -f reverse-proxy/docker-compose.caddy-gen.yml up -d
  EOF
}