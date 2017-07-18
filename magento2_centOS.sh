cd /var/www/html

sthvar=$(pwgen 8 1)

mkdir /ReadMe
echo "The Admin Password is \""$sthvar"\"" > /ReadMe/ReadMe



urla='http://'
urla=$urla$(wget -qO- http://ipecho.net/plain ; echo)
urla=$urla'/'


echo "The Adress of Admin Page is \""$urla"admin\"" >> /ReadMe/ReadMe

php /var/www/html/bin/magento setup:install --base-url="$urla" --backend-frontname=admin\
 --db-host=localhost --db-name=magento --db-user=magentouser --db-password=Magento@123\
 --admin-firstname=Magento --admin-lastname=User --admin-email=admin@admin.com\
 --admin-user=admin --admin-password=$sthvar --language=en_US\
 --currency=USD --timezone=America/Chicago --use-rewrites=1 

chown -R :apache /var/www/html && find /var/www/html -type f -print0 | xargs -r0 chmod 640 && find /var/www/html -type d -print0 | xargs -r0 chmod 750 && chmod -R g+w /var/www/html/{pub,var} && chmod -R g+w /var/www/html/{app/etc,vendor}

systemctl restart httpd

