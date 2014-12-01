#/bin/bash

###
# Variables
###

if [ -z ${ROUNDCUBE_MYSQL_USER+x} ] || [ -z ${ROUNDCUBE_MYSQL_PASSWORD+x} ]
then
  >&2 echo ">> no user or password for database specified!"
  exit 1
fi

if [ -z ${ROUNDCUBE_MAIL_HOST+x} ]
then
  ROUNDCUBE_MAIL_HOST=mail
fi

if [ -z ${ROUNDCUBE_MYSQL_HOST+x} ]
then
  ROUNDCUBE_MYSQL_HOST=mysql
fi

if [ -z ${ROUNDCUBE_MYSQL_PORT+x} ]
then
  ROUNDCUBE_MYSQL_PORT=3306
fi

if [ -z ${ROUNDCUBE_MYSQL_DBNAME+x} ]
then
  ROUNDCUBE_MYSQL_DBNAME=roundcube
fi

if [ -z ${ROUNDCUBE_PHP_DATE_TIMEZONE+x} ]
then
  ROUNDCUBE_PHP_DATE_TIMEZONE=Europe/Berlin
fi

if [ -z ${ROUNDCUBE_RELATIVE_URL_ROOT+x} ]
then
  ROUNDCUBE_RELATIVE_URL_ROOT="/"
fi

ROUNDCUBE_RANDOM=`perl -e 'my @chars = ("A".."Z", "a".."z"); my $string; $string .= $chars[rand @chars] for 1..24; print $string;'` # returns exactly 24 random chars

###
# Configuration
###

sed -i "s/MYSQL_USER/$ROUNDCUBE_MYSQL_USER/g" /roundcube/config/config.inc.php
sed -i "s/MYSQL_PASSWORD/$ROUNDCUBE_MYSQL_PASSWORD/g" /roundcube/config/config.inc.php
sed -i "s/MYSQL_DB/$ROUNDCUBE_MYSQL_DBNAME/g" /roundcube/config/config.inc.php
sed -i "s/MYSQL_HOST/$ROUNDCUBE_MYSQL_HOST/g" /roundcube/config/config.inc.php
sed -i "s/MYSQL_PORT/$ROUNDCUBE_MYSQL_PORT/g" /roundcube/config/config.inc.php
sed -i "s/MAIL_HOST/$ROUNDCUBE_MAIL_HOST/g" /roundcube/config/config.inc.php
sed -i "s/ROUNDCUBE_RANDOM/$ROUNDCUBE_RANDOM/g" /roundcube/config/config.inc.php

echo ">> set Timezone -> $ROUNDCUBE_PHP_DATE_TIMEZONE"
sed -i "s!;date.timezone =.*!date.timezone = $ROUNDCUBE_PHP_DATE_TIMEZONE!g" /etc/php5/fpm/php.ini

###
# Install
###

echo ">> making roundcube available beneath: $ROUNDCUBE_RELATIVE_URL_ROOT"
mkdir -p "/usr/share/nginx/html$ROUNDCUBE_RELATIVE_URL_ROOT" 
# adding softlink for nginx connection
echo ">> adding softlink from /roundcube to $ROUNDCUBE_RELATIVE_URL_ROOT"
mkdir -p "/usr/share/nginx/html$ROUNDCUBE_RELATIVE_URL_ROOT"
rm -rf "/usr/share/nginx/html$ROUNDCUBE_RELATIVE_URL_ROOT"
ln -s /roundcube $(echo "/usr/share/nginx/html$ROUNDCUBE_RELATIVE_URL_ROOT" | sed 's/\/$//')

###
# Post Install
###

if [ ! -z ${ROUNDCUBE_DO_NOT_INITIALIZE+x} ]
then
  echo ">> ROUNDCUBE_DO_NOT_INITIALIZE set - skipping initialization"
  exit 0
fi

# skip if DB exists and not empty!!!
if [ $(mysql -h $ROUNDCUBE_MYSQL_HOST -P $ROUNDCUBE_MYSQL_PORT -u $ROUNDCUBE_MYSQL_USER -p$ROUNDCUBE_MYSQL_PASSWORD $ROUNDCUBE_MYSQL_DBNAME -e "show tables;" | wc -l) -gt 4 ]
then
  echo ">> DB is already configured - skipping initialization"
  exit 0
fi

###
# Headless initialization
###
echo ">> initialization"
echo ">> starting nginx to configure roundcube"
sleep 1
nginx > /dev/null 2> /dev/null &
sleep 1

## Create Roundcube Installation
echo ">> init roundcube installation"
echo ">> init database"

# enable installer
sed -i 's/\?>/\$config["enable_installer"] = true;\n\?>/g' /roundcube/config/config.inc.php
sleep 1

wget -O /dev/null --no-check-certificate --no-proxy --post-data 'initdb=Initialize+database' https://localhost$ROUNDCUBE_RELATIVE_URL_ROOT\installer/index.php?_step=3

# disable installer
echo ">> removing installer folder"
sed -i 's/\$config\["enable_installer"\] = true;/\$config\["enable_installer"\] = false;/g' /roundcube/config/config.inc.php
rm -rf /roundcube/installer
chown www-data:www-data -R /roundcube

echo ">> killing nginx - done with configuration"
sleep 1
killall nginx
echo ">> finished initialization"
