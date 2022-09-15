#!/bin/bash
user=$(whoami)
id=$(id -u)
if [ $id -ne 0 ]; then
	echo "El usuario debe ser root para correr este script"
            echo "Ejecutar el comando “sudo su” para cambiar a root"
	exit 1
fi
apt-get update
apt install nginx -y
systemctl status nginx
cd etc/nginx/sites-available/
truncate -s0 default
cat  > default <<EOF
server  {
	listen 80 default_server;
	listen [::]:80 default_server;
	
	server_name _;
	
	location / {
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header Host $host;
		proxy_http_version 1.1;
		proxy_pass http://backend;
	}
}

upstream backend {
	server 127.0.0.1:3000;
	server 127.0.0.1:3001;
	server 127.0.0.1:3002;
	server 127.0.0.1:3003;
}
EOF
nginx -t
systemctl restart nginx
curl 44.204.123.63:3000
sudo certbot --non-interactive --nginx -d 44.204.123.63.sslip.io -d www.44.204.123.63.sslip.io -m ce.djesus@gmail.com--agree-tos
certbot renew --dry-run

echo “______________________________________________________________”
echo “___________________________FINISHED___________________________”
echo “______________________________________________________________”
