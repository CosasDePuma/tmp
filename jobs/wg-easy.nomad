variable "domain" {
  type        = string
  description = "Domain to serve HTTP webui"
}

variable "dns" {
  type        = string
  description = "Default DNS server"
}

job "wg-easy" {
  datacenters = ["lab"]
  region      = "global"
  type        = "service"

  group "wg-easy" {
    network {
      mode = "bridge"

      port "wg-easy" {}
      port "wireguard" {}
    }

    service {
      name = "wg-easy"
      port = "wg-easy"

      connect {
        sidecar_service {}
      }

      #check {
      #  name     = "wg-easy"
      #  type     = "tcp"  # TODO: Check http
      #  interval = "10s"
      #  timeout  = "2s"
      #}

      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.wg-easy.rule=Host(`vpn.${var.domain}`)",
        "traefik.http.routers.wg-easy.entrypoints=https",
      ]
    }

    task "wg-easy" {
      driver = "docker"
      
      config {
        image       = "ghcr.io/wg-easy/wg-easy:latest"
        cap_add     = ["NET_ADMIN", "SYS_MODULE"]
        sysctl      = {
          "net.ipv4.conf.all.src_valid_mark" = "1",
          "net.ipv4.ip_forward" = "1",
        }
        volumes     = [
          "/lib/modules:/lib/modules:ro",
          "/mnt/nfs/lab/wg-easy:/etc/wireguard:rw"
        ]
      }

      template {
        destination = "secrets/.env"
        env         = true
        data        = <<-ENV
          PORT={{ env "NOMAD_PORT_wg-easy" }}
          WG_HOST=vpn.${var.domain}
          WG_DEFAULT_ADDRESS=10.10.0.x
          WG_DEFAULT_DNS=${var.dns}
          WG_ALLOWED_IPS=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
          WG_LANG=en
          WG_MTU=1360
          UI_CHART_TYPE=2
          UI_TRAFFIC_STATS=true
          UI_ENABLE_SORT_CLIENTS=true
          WG_DEVICE=eth1
        ENV
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}