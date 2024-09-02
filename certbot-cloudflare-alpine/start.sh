#!/bin/bash
set -ex
export CF_KEY=${CF_KEY}
export SHDIR=/root
export DOMAIN=${DOMAIN}
export EMAIL=${EMAIL}
#Cloudflare
if [ ! -d /root/.secrets ]
then
 mkdir /root/.secrets
fi
if [ ! -f /root/.secrets/cloudflare.ini ]
then
cat << EOF >  /root/.secrets/cloudflare.ini
# Cloudflare API token used by Certbot
dns_cloudflare_email =  ${EMAIL}
dns_cloudflare_api_key = ${CF_KEY}
EOF
chmod 600 /root/.secrets/cloudflare.ini
fi
#续期脚本及计划任务配置
cat << EOF > ${SHDIR}/renew.sh
#申请续期并重启nginx
certbot renew  --post-hook  "nginx -s reload"  -m ${EMAIL} --agree-tos
EOF
echo '1 1 */1 * * sh '"${SHDIR}"'/renew.sh' > /var/spool/cron/crontabs/root
#Nginx配置文件
cat << "EOF" > /etc/nginx/http.d/template.apen.ltd
server {
    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/apen.ltd/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/apen.ltd/privkey.pem;
    server_name f.apen.ltd;
    ssl_session_timeout 5m;
    ssl_dhparam /etc/nginx/dhparam.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-CAMELLIA256-SHA:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-SEED-SHA:DHE-RSA-CAMELLIA128-SHA:HIGH:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS';
    ssl_prefer_server_ciphers on;
    proxy_set_header X-Forwarded-For $remote_addr;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
    server_tokens off;
    location / {
        proxy_pass         http://127.0.0.1:80;
        proxy_set_header   Host $host:$server_port;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host $server_name;
        proxy_set_header   X-Forwarded-Proto https;
        proxy_read_timeout  1200s;
        client_max_body_size 0;
    }
}
EOF
#openssl req -x509 -nodes -newkey rsa:4096 -keyout nginx.key -out nginx.crt -days 365 -subj "/CN=$(hostname)"
if [ ! -f /etc/nginx/dhparam.pem ]
then
openssl dhparam -out /etc/nginx/dhparam.pem 2048
fi
nginx
if [ ! -d /etc/letsencrypt/archive ]
then
certbot certonly --dns-cloudflare \
        -d ${DOMAIN} -d *.${DOMAIN} \
        --dns-cloudflare --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \
        -m ${EMAIL} \
        --post-hook "nginx -s reload" \
        --agree-tos --non-interactive
fi
nginx -s reload
tail -f /dev/null