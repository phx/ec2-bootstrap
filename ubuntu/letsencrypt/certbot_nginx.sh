#!/bin/sh

SSL_DOMAIN='ENTER_SSL_DOMAIN_HERE'
EMAIL='email@example.com'

snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
apt update && apt install -y nginx-extras
mkdir -p /var/www/letsencrypt
mkdir -p /etc/nginx/global
echo '		location ^~ /.well-known/acme-challenge/ {
			default_type "text/plain";
			root /var/www/letsencrypt;
		}' > /etc/nginx/global/letsencrypt.conf
loc_line="$(grep -n 'location /' /etc/nginx/sites-enabled/default | head -1 | cut -d':' -f1)"
conf_line="$((loc_line-1))"
sed -i "${conf_line} i include global/letsencrypt.conf;" /etc/nginx/sites-enabled/default
nginx -t && systemctl enable nginx && systemctl start nginx
echo '00 2 * * * root /usr/bin/certbot renew 2> /dev/null' > /etc/cron.d/certbot_renew
echo '15 2 * * * root nginx -s reload 2> /dev/null' > /etc/cron.d/nginx_reload
certbot certonly --agree-tos -n --webroot -w /home/www/letsencrypt -d "$SSL_DOMAIN" -m "$EMAIL"
