variable "banner" {
  type        = string
  description = "Banner to display in DNS responses"
  default     = "HomeLab"
}
variable "domain" {
  type        = string
  description = "Domain to serve DNS for"
}
variable "ip" {
  type        = string
  description = "IP address to bind to"
  default     = "{{ env \"NOMAD_IP_dns\" }}"
}

job "bind9" {
  datacenters = ["lab"]
  region      = "global"
  type        = "service"

  group "bind9" {
    network {
      mode = "bridge"

      port "dns" {}
    }

    service {
      name = "bind9"
      port = "dns"

      check {
        name     = "dns-port"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }

      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.bind9.entrypoints=dns-tcp",
        "traefik.tcp.routers.bind9.rule=HostSNI(`*`)",
        "traefik.udp.routers.bind9.entrypoints=dns-udp",
      ]
    }

    task "bind9" {
      driver = "docker"

      constraint {
        attribute = "${meta.type}"
        value     = "dmz"
      }
      
      config {
        image   = "ubuntu/bind9:latest"
        volumes = [
          "local/named.conf:/etc/bind/named.conf:ro",
          "local/domain.zone:/etc/bind/zones/domain.zone:ro",
        ]
      }

      template {
        destination = "local/named.conf"
        data = <<-CONFIG
          acl internal {
            10.0.0.0/8;
            127.0.0.0/8;
            172.16.0.0/12;
            192.168.0.0/16;
          };

          options {
            directory "/var/cache/bind";
            dnssec-validation auto;
            auth-nxdomain no;  # conform to RFC1035
            listen-on port {{ env "NOMAD_PORT_dns" }} { any; };
            listen-on-v6 port {{ env "NOMAD_PORT_dns" }} { any; };
            recursion yes;
            allow-recursion { internal; };
            allow-query { internal; };
            allow-query-cache { internal; };
            allow-transfer { none; };
            empty-zones-enable no;
            querylog yes;
            version "${var.banner} (DNS)";
            forward only;
            forwarders {
              1.1.1.1;
              8.8.8.8;
            };
          };

          // External zones
          zone "."  {
            type hint;
            file "/usr/share/dns/root.hints";
          };
          zone "localhost" {
            type master;
            file "/etc/bind/db.local";
          };
          zone "127.in-addr.arpa" {
            type master;
            file "/etc/bind/db.127";
          };
          zone "0.in-addr.arpa" {
            type master;
            file "/etc/bind/db.0";
          };
          zone "255.in-addr.arpa" {
            type master;
            file "/etc/bind/db.255";
          };

          // Custom zones
          zone "${var.domain}" IN {
            type master;
            file "/etc/bind/zones/domain.zone";
            allow-update { none; };
          };
        CONFIG
      }

      template {
        destination = "local/domain.zone"
        data = <<-CONFIG
          $TTL 604800
          @ IN SOA ns.${var.domain}. root.${var.domain}. (
            1        ; Serial
            604800   ; Refresh
            86400    ; Retry
            2419200  ; Expire
            604800 ) ; Negative Cache TTL
          ;
          @  IN NS ns.${var.domain}.
          ns IN A  ${var.ip}
          @  IN A  ${var.ip}
          *  IN A  ${var.ip}
        CONFIG
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}