resource "gridscale_ipv4" "caddy_ip" {
  name = "caddy-public-ip"
}

resource "gridscale_firewall" "caddy_firewall" {
  name = "caddy-firewall"

  # Allow SSH from anywhere
  rules_v4_in {
    order    = 0
    protocol = "tcp"
    action   = "accept"
    dst_port = "22"
    comment  = "ssh from internet"
  }

  # Allow HTTP from anywhere
  rules_v4_in {
    order    = 1
    protocol = "tcp"
    action   = "accept"
    dst_port = "80"
    comment  = "http from internet"
  }

  # Allow Prometheus from anywhere
  rules_v4_in {
    order    = 2
    protocol = "tcp"
    action   = "accept"
    dst_port = "9090"
    comment  = "prometheus from internet"
  }

  rules_v4_in {
    order    = 3
    protocol = "tcp"
    action   = "drop"
    dst_port = "1:1023"
    comment  = "block all lower ports inbound"
  }
}

resource "gridscale_storage" "caddy_storage" {
  name     = "caddy-storage"
  capacity = 10
  template {
    template_uuid = data.gridscale_template.ubuntu.id
  }
}

resource "gridscale_server" "caddy" {
  name   = "caddy"
  cores  = 1
  memory = 2

  storage {
    object_uuid = gridscale_storage.caddy_storage.id
  }

  # Private network
  network {
    object_uuid = gridscale_network.private_net.id
  }

  # Public network (required for actual internet access)
  network {
    object_uuid            = var.public_network_uuid
    firewall_template_uuid = gridscale_firewall.caddy_firewall.id
  }

  power = true

  ipv4 = gridscale_ipv4.caddy_ip.id


  # SSH key-only access + static private IP
  user_data_base64 = base64encode(<<EOF
#cloud-config
ssh_pwauth: false
users:
  - name: root
    ssh-authorized-keys:
      - ${var.ssh_public_key}
    lock_passwd: true
write_files:
  - path: /etc/ssh/sshd_config.d/99-key-only.conf
    permissions: '0644'
    content: |
      PermitRootLogin yes
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      PubkeyAuthentication yes
  - path: /etc/netplan/99-private.yaml
    permissions: '0644'
    content: |
      network:
        version: 2
        ethernets:
          enp0s16:
            dhcp4: false
            addresses:
              - ${var.caddy_private_ip}
runcmd:
  - netplan apply
  - systemctl restart ssh || systemctl restart sshd
EOF
  )
}
