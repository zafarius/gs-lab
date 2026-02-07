resource "gridscale_ipv4" "nginx_ip" {
  name = "nginx-public-ip"
}

resource "gridscale_firewall" "nginx_firewall" {
  name = "nginx-firewall"

  # Block all inbound traffic on lower ports (0-1023)
  rules_v4_in {
    order    = 0
    protocol = "tcp"
    action   = "drop"
    dst_port = "1:1023"
    comment  = "block all lower ports inbound"
  }
}

resource "gridscale_storage" "nginx_storage" {
  name     = "nginx-storage"
  capacity = 10
  template {
    template_uuid = data.gridscale_template.ubuntu.id
  }
}

resource "gridscale_server" "nginx" {
  name   = "nginx"
  cores  = 1
  memory = 2

  storage {
    object_uuid = gridscale_storage.nginx_storage.id
  }

  # Private network
  network {
    object_uuid = gridscale_network.private_net.id
  }

  # Public network (for outbound only - no inbound access)
  network {
    firewall_template_uuid = gridscale_firewall.nginx_firewall.id
    object_uuid            = var.public_network_uuid
  }

  power = true

  ipv4 = gridscale_ipv4.nginx_ip.id


  # SSH key-only access
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
              - ${var.nginx_private_ip}
runcmd:
  - netplan apply
  - systemctl enable --now ssh || systemctl enable --now sshd
  - systemctl restart ssh || systemctl restart sshd
EOF
  )
}
