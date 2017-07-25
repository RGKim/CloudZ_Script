cd /var/www/html/owncloud/config


url=$(wget -qO- http://ipecho.net/plain ; echo)

sed -i "s/serverip/$url/" config.php


cd /var/www/html/owncloud

sthvar=$(pwgen 8 1)
export OC_PASS=$sthvar

mkdir /ReadMe
echo "The Admin of OwnCloud's Username is \"admin\" Password is \""$sthvar"\"" > /ReadMe/ReadMe

su -s /bin/sh apache -c 'php ./occ user:resetpassword --password-from-env admin'
