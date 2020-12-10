#!/bin/bash

# Habilitamos el modo de shell para mostrar los comandos que se ejecutan
set -x

# Actualizamos la lista de paquetes
apt update

# Actualizamos los paquetes
apt upgrade -y

# Instalamos el servidor web apache
apt install apache2 -y


# Instalamos los paquetes de PHP
apt install php libapache2-mod-php php-mysql -y

#---------------------------------------------------------------------------------------------------------------------------------
# Herramientas adicionales
mkdir /var/www/html/adminer
cd /var/www/html/adminer
wget https://github.com/vrana/adminer/releases/download/v4.7.7/adminer-4.7.7-mysql.php
mv adminer-4.7.7-mysql.php index.php

# Definimos variables para el htpasswd
HTTPASSWD_USER=usuario
HTTPASSWD_PASSWD=usuario
HTTPASSWD_DIR=/home/ubuntu

# Instalación de GoAcces
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -
apt update
apt install goaccess -y

# Creacion de un directorio para cosultar las estadisticas
mkdir -p /var/www/html/stats
nohup goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html &
htpasswd -bc $HTTPASSWD_DIR/.htpasswd $HTTPASSWD_USER $HTTPASSWD_PASSWD

# Copiamos el archivo de configuración de Apache
cd /home/ubuntu
cp /home/ubuntu/000-default.conf /etc/apache2/sites-available/
systemctl restart apache2

# Instalacion de PHPMYADMIM
IP_PUBLICA_MYSQL=3.82.102.119

# Instalamos la utilidad unzip
apt install unzip -y

# Descargamos el codigo fuente de phpMyadmin
cd/home/ubuntu
rm -rf phpMyAdmin-5.0.4-all-languages.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.zip

# Descomprimimos el archivo
unzip phpMyAdmin-5.0.4-all-languages.zip

# Borramos el .zip
rm -rf phpMyAdmin-5.0.4-all-languages.zip

# Movemos el directorio de phpMyadmin
mv phpMyAdmin-5.0.4-all-languages/ /var/www/html/phpmyadmin

#Configuramos el archivo config.inc.php
cd /var/www/html/phpmyadmin
mv config.sample.inc.php config.inc.php
sed -i "s/localhost/$IP_PUBLICA_MYSQL/" /var/www/html/phpmyadmin/config.inc.php

# ------------------------------------------------------------------------------
# Instalación de la aplicación web propuesta
# ------------------------------------------------------------------------------

cd /var/www/html
rm -rf iaw-practica-lamp
git clone https://github.com/josejuansanchez/iaw-practica-lamp
mv /var/www/html/iaw-practica-lamp/src/* /var/www/html/
sed -i "s/localhost/$IP_PUBLICA_MYSQL/" /var/www/html/config.php

# Eliminamos contenido inutil
rm -rf /var/www/html/index.html
rm -rf /var/www/html/iaw-practica-lamp

# Cambiar permisos
chown www-data:www-data * -R
