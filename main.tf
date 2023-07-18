terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "ssh" {
  name = var.ssh_key_name
}

resource "digitalocean_vpc" "vpcprivate" {
  name        = "vpc-private-app"
  description = "Private network for Web App"
  region      =  var.regiondc
  ip_range    = var.vpc_private_net
}

resource "digitalocean_firewall" "firewall" {
  name = "web-only-lb-and-ssh"

  droplet_ids = [digitalocean_droplet.web-app1.id, digitalocean_droplet.web-app2.id]

  inbound_rule {
    protocol           = "tcp"
    port_range         = "22"
    source_addresses   = var.admin_net
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_droplet" "web-app1" {
  image  = "docker-20-04"
  name   = "web.app1"
  region = var.regiondc
  size   = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh.id]
  vpc_uuid = digitalocean_vpc.vpcprivate.id
}

resource "digitalocean_droplet" "web-app2" {
  image    = "docker-20-04"
  name     = "web.app2"
  region   = var.regiondc
  size     = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh.id]
  vpc_uuid = digitalocean_vpc.vpcprivate.id
}

resource "digitalocean_loadbalancer" "web-lb" {
  name   = "web-app-lb"
  region = "fra1"
  vpc_uuid = digitalocean_vpc.vpcprivate.id

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 5000
    target_protocol = "http"
  }

  healthcheck {
    port     = 5000
    protocol = "http"
    path     =  "/"
  }

  droplet_ids = [digitalocean_droplet.web-app1.id, digitalocean_droplet.web-app2.id ]
}