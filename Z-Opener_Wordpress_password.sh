#!/bin/bash

cat << EOF > /root/cloudz.sh
#!/bin/sh

CONFIG_FILE="/root/provisioningConfiguration.cfg"
if [ -f "\$CONFIG_FILE" ] ; then
  source \$CONFIG_FILE

  INIT_ID="CloudZ"
  OLD_PASSWORD=\$(cat /root/INIT_PASSWORD)
  NEW_PASSWORD=\$OS_PASSWORD
  MYIP=\$(/usr/bin/hostname -i)

  # 비번을  OS 초기비번으로 변경
  systemctl start mariadb
  
  /usr/bin/mysql -u root -p\$OLD_PASSWORD mysql -e "\
  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('\$NEW_PASSWORD');\
  SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('\$NEW_PASSWORD');\
  SET PASSWORD FOR 'root'@'::1' = PASSWORD('\$NEW_PASSWORD');\
  SET PASSWORD FOR '\$INIT_ID'@'localhost' = PASSWORD('\$NEW_PASSWORD');\
  FLUSH PRIVILEGES;"
  
  /usr/bin/mysql -u root -p\$NEW_PASSWORD wordpress -e "\
  UPDATE wp_users SET user_pass=MD5('\$NEW_PASSWORD') WHERE wp_users.user_login='\$INIT_ID';\
  FLUSH PRIVILEGES;"

  /usr/bin/mysql -u root -p\$NEW_PASSWORD wordpress -e "\
  update wp_options set option_value = 'http://\$MYIP' where option_name = 'siteurl' or option_name = 'home'; \
  FLUSH PRIVILEGES;"

  sed -i "s/'\$OLD_PASSWORD'/'\$NEW_PASSWORD'/g" /var/www/html/wp-config.php

  systemctl restart httpd

  systemctl disable cloudz
  rm -f /etc/systemd/system/cloudz.service
  rm -f /root/cloudz.sh
  rm -f /root/INIT_PASSWORD
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

rm -f /root/post*
cat /dev/null > /root/.bash_history && history -c
