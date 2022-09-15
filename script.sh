#!/bin/bash
user=$(whoami)
id=$(id -u)
if [ $id -ne 0 ]; then
	echo "El usuario debe ser root para correr este script"
            echo "Ejecutar el comando “sudo su” para cambiar a root"
	exit 1
fi
apt-get update
apt-get install -y git
apt-get update
git clone https://github.com/roxsross/challenge-linux-bash
apt install -y nodejs npm
apt-get update
apt-get install -y curl
curl -sL https://deb.nodesource.com/setup_14.x -o node_setup.sh
bash node_setup.sh
apt remove nodejs -y
apt autoremove -y 
apt-get update
apt install -y nodejs
#Crear usuario llamado nodejs con la contraseña nodejs
useradd -m -p nodejs nodejs
#Crear archivo de configuración
cat  > /lib/systemd/system/devops@.service <<EOF
[Unit]
Description=Balanceo para desafio Final
Documentation=https://github.com/roxsross/challenge-linux-bash
After=network.target

[Service]
Enviroment=PORT=%i
Type=simple
User=$user
WorkingDirectory=/home/ubuntu/challenge-linux-bash
ExecStart=/usr/bin/node /home/ubuntu/challenge-linux-bash/server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF

# iniciar el servicio automáticamente

for port in $(seq 3000 3003); do sudo systemctl enable devops@$port; done

for port in $(seq 3000 3003); do sudo systemctl start devops@$port; done

#Crear script para detener el servicio
cat  > stop.sh <<EOF
for port in $(seq 3000 3003); do sudo systemctl stop devops@$port; done
EOF

echo “______________________________________________________________”
echo “___________________________FINISHED___________________________”
echo “______________________________________________________________”
