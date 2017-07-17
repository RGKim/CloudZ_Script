#reset password 
yum install epel-release -y
yum install pwgen -y

cd /var/www/html

sthvar=$(pwgen 8 1)

mkdir /ReadMe
echo "The Admin Password is \""$sthvar"\"" > /ReadMe/ReadMe



urla='http://'
urla=$urla$(wget -qO- http://ipecho.net/plain ; echo)
urla=$urla'/'


"echo "The Adress of Admin Page is \""&urla"admin\" >> /ReadMe/ReadMe

php /var/www/html/bin/magento setup:install --base-url="$urla" --backend-frontname=admin \
 --db-host=localhost --db-name=magento --db-user=magentouser --db-password=Magento@123 \
 --admin-firstname=Magento --admin-lastname=User --admin-email=admin@admin.com \
 --admin-user=admin --admin-password=$sthvar --language=en_US \
 --currency=USD --timezone=America/Chicago --use-rewrites=1

chmod -R g+w /var/www/html/{pub,var} && chmod -R g+w /var/www/html/{app/etc,vendor}






/usr/bin/php /var/www/html/bin/magento cron:run | grep -v "Ran jobs by schedule" >> /var/www/html/var/log/magento.cron.log
/usr/bin/php /var/www/html/update/cron.php >> /var/www/html/var/log/update.cron.log
/usr/bin/php /var/www/html/bin/magento setup:cron:run >> /var/www/html/var/log/setup.cron.log
