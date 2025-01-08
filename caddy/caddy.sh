if [ ! -e /data/caddy ];then
mkdir -p /data/caddy
fi

cat << EOF > /data/caddy/docker-compose.yaml
services:
  caddy:
    image: caddy
    restart: always
    container_name: caddy
    cap_add:
      - NET_ADMIN
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./caddy:/etc/caddy
      - ./srv:/srv
      - ./data:/data
      - ./config:/config
EOF

cd /data/caddy && docker compose up -d
cat << EOF > /data/caddy/caddy/Caddyfile
ui.apen.ltd {
	reverse_proxy localhost:50000 {
		header_up Host {host}
		header_up Origin {scheme}://{host}
		header_up X-Forwarded-For {remote_addr}
		header_up X-Forwarded-Proto {scheme}
		header_up X-Forwarded-Ssl on
		header_up X-Forwarded-Port {server_port}
		header_up X-Forwarded-Host {host}
	}
}
hub.apen.ltd {
	reverse_proxy localhost:51000 {
		header_up Host {host}
		header_up X-Real-IP {remote_addr}
		header_up X-Forwarded-For {remote_addr}
		header_up X-Nginx-Proxy true
	}
}
gcr.apen.ltd {
	reverse_proxy localhost:53000 {
		header_up Host {host}
		header_up X-Real-IP {remote_addr}
		header_up X-Forwarded-For {remote_addr}
		header_up X-Nginx-Proxy true
	}
}
k8s.apen.ltd {
	reverse_proxy localhost:55000 {
		header_up Host {host}
		header_up X-Real-IP {remote_addr}
		header_up X-Forwarded-For {remote_addr}
		header_up X-Nginx-Proxy true
	}
}
quay.apen.ltd {
	reverse_proxy localhost:56000 {
		header_up Host {host}
		header_up X-Real-IP {remote_addr}
		header_up X-Forwarded-For {remote_addr}
		header_up X-Nginx-Proxy true
	}
}
www.apen.ltd {
	reverse_proxy 198.19.19.119:8090 {
		header_up Host {host}
		header_up X-Real-IP {remote_addr}
		header_up X-Forwarded-For {remote_addr}
		header_up X-Nginx-Proxy true
	}
}
EOF
cd /data/caddy && docker compose restart