# Avalon Nginx Reverse Proxy + Let's Encrypt (Docker)

This stack provides:
- An **Nginx reverse proxy** to route HTTPS traffic to services in multiple Docker stacks.
- **Automatic Let's Encrypt SSL certificates** via Certbot (HTTP-01 validation).
- Integration with a shared external Docker network for multi-stack communication.

---

## 📋 Prerequisites

1. **Domain name**  
   - You must own a domain (example: `slyverstorm.dev`).
   - Create an **A record** pointing to your WAN IP (check with `curl ifconfig.me`).

2. **Publicly accessible ports**  
   - Forward **TCP port 80** → Debian server's port 80
   - Forward **TCP port 443** → Debian server's port 443  
     *(Freebox users: enable "mode avancé" and adjust IPv6 firewall if needed.)*

3. **Docker & Docker Compose** installed on your Debian server  
   - Install:  
     ```bash
     sudo apt update
     sudo apt install docker.io docker-compose-plugin -y
     ```

4. **Shared external network** (for multi-stack service access)  
   - Create it **once** (before first `docker compose up`):  
     ```bash
     docker network create avalon-reverse-proxy-net
     ```

5. **Nginx configuration files**  
   - Place your virtual host configs inside `./nginx/conf.d/`.
   - Example config is shown below.

---

## ⚙️ Example Nginx Configuration

`nginx/conf.d/slyverstorm.conf`
```nginx
server {
    listen 80;
    server_name slyverstorm.dev www.slyverstorm.dev;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name slyverstorm.dev www.slyverstorm.dev;

    ssl_certificate /etc/letsencrypt/live/slyverstorm.dev/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/slyverstorm.dev/privkey.pem;

    # Example routes:
    location /grafana/ {
        proxy_pass http://grafana:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /portainer/ {
        proxy_pass https://portainer:9443/;
        proxy_ssl_verify off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🚀 First-Time Setup
1. Get the first SSL certificate
Before starting the proxy stack, run Certbot in standalone mode to get the initial cert:

```bash
docker run --rm \
  -v $(pwd)/certbot/www:/var/www/certbot \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  certbot/certbot certonly --webroot \
  --webroot-path=/var/www/certbot \
  --email your@email.com \
  --agree-tos \
  --no-eff-email \
  -d slyverstorm.dev -d www.slyverstorm.dev

```
If successful, your certs will be in: `certbot/conf/live/slyverstorm.dev/`

2. Start the stack
```bash
docker compose up -d
```

## ➕ Adding New Services from Other Stacks
1. In the service's own stack, connect it to the shared network:

```yaml
networks:
  avalon-reverse-proxy-net:
    external: true
```

```yaml
services:
  my-service:
    image: my-service-image
    expose:
      - "3000" # Important: so nginx can target this port
    networks:
      - avalon-reverse-proxy-net
      - internal-networtk  # optional internal network
```

2. Add a new location block in the Nginx config for that service.
3. Restart Nginx (targeting the `nginx` service inside the stack):
```bash
docker compose restart nginx
```

## 🔄 Certificate Renewal
- Renewal is handled automatically by the certbot container (runs every 12 hours).

- To manually test renewal:
```bash
docker compose exec certbot certbot renew --dry-run
```

## 🛠 Troubleshooting
- Certbot fails HTTP-01 challenge:
Ensure port 80 is open and forwarded to your server, and the domain resolves to your WAN IP.

- Service not reachable via proxy:
Ensure the service container is attached to avalon-reverse-proxy-net and expose or listen on the expected port.


## 📌 Notes
- External network is mandatory for multi-stack communication. Create it once with:

```bash
docker network create avalon-reverse-proxy-net
```

- All stacks using this network must declare it as:

```yaml
networks:
  avalon-reverse-proxy-net:
    external: true
```
