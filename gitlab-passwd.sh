
#!/bin/bash

cat << EOF > /root/cloudz.sh
#!/bin/sh

CONFIG_FILE="/root/provisioningConfiguration.cfg"
if [ -f "\$CONFIG_FILE" ] ; then
  source \$CONFIG_FILE

  NEW_PASSWORD=\$OS_PASSWORD


/usr/bin/mysqladmin -u root password "\$NEW_PASSWORD"
SECURE_MYSQL=\$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$INIT_PASSWORD\r\"
expect \"Change the root password?\"
send \"y\r\"
expect \"New password\"
send \"$INIT_PASSWORD\r\"
expect \"Re-enter new password\"
send \"$INIT_PASSWORD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

  systemctl start postfix
  gitlab-ctl reconfigure
  
  eval "gitlab-rails runner 'puts user = User.find(1); user.password, user.password_confirmation = \"\$NEW_PASSWORD\"; user.save! '"

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
