variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

variable "ssh_public_key_file" {
  type = string
}

resource "digitalocean_ssh_key" "terraria" {
  name       = "id_terraria"
  public_key = file(var.ssh_public_key_file)
}

resource "digitalocean_droplet" "terraria" {
  image      = "ubuntu-18-04-x64"
  name       = "terraria"
  region     = "sgp1"
  size       = "s-2vcpu-2gb"
  monitoring = true
  ssh_keys   = [digitalocean_ssh_key.terraria.fingerprint]
  user_data  = file("cloud-init.yaml")
}

resource "digitalocean_firewall" "terraria" {
  name = "terraria"

  droplet_ids = [digitalocean_droplet.terraria.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "7777"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

output "ip" {
  value = digitalocean_droplet.terraria.ipv4_address
}
