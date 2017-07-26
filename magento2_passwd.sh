#!/bin/bash

cat << EOF > /root/cloudz.sh
#!/bin/sh

CONFIG_FILE="/root/provisioningConfiguration.cfg"

if [ -f "\$CONFIG_FILE" ] ; then
source \$CONFIG_FILE

OLD_PASSWORD="Admin@123"
OLD_PASSWORD_M="Magento@123"
NEW_PASSWORD=\$OS_PASSWORD
INIT_ID="CloudZ"
	
systemctl start mysqld

/usr/bin/mysql -u root -p\$OLD_PASSWORD mysql -e "\
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('\$NEW_PASSWORD');\
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('\$NEW_PASSWORD');\
SET PASSWORD FOR 'root'@'::1' = PASSWORD('\$NEW_PASSWORD');\
SET PASSWORD FOR 'magentouser'@'localhost' = PASSWORD('\$NEW_PASSWORD');\
FLUSH PRIVILEGES;" &> log.txt



MYIP=\$(wget -qO- http://ipecho.net/plain ; echo)


php /var/www/html/bin/magento setup:install --base-url="http://\$MYIP/" --backend-frontname=admin\
 --db-host=localhost --db-name=magento --db-user=magentouser --db-password=\$OS_PASSWORD\
 --admin-firstname=CloudZ --admin-lastname=User --admin-email=magentoadmin@cloudz.com\
 --admin-user=CloudZ --admin-password=\$OS_PASSWORD --language=en_US\
 --currency=USD --timezone=America/Chicago --use-rewrites=1 &>> log.txt

chown -R :apache /var/www/html && find /var/www/html -type f -print0 | xargs -r0 chmod 640 && find /var/www/html -type d -print0 | xargs -r0 chmod 750 && chmod -R g+w /var/www/html/{pub,var} && chmod -R g+w /var/www/html/{app/etc,vendor}

systemctl restart httpd
systemctl disable cloudz

rm -f /etc/systemd/system/cloudz.service
rm -f /root/cloudz.sh

else
echo "provisioningConfiguration file not exist"
fi
EOF

chmod 755 /root/cloudz.sh

cat << EOF > /etc/systemd/system/cloudz.service
[Unit]
Description=CloudZ Install
After=network.target

[Service]
ExecStart=/root/cloudz.sh
Type=oneshot
TimeoutSec=0

[Install]
WantedBy=multi-user.target
EOF

systemctl enable cloudz
cat /dev/null > /root/.bash_history && history -c



