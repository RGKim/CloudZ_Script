#!/bin/bash

cat << EOF > /root/cloudz.sh
#!/bin/sh

CONFIG_FILE="/root/provisioningConfiguration.cfg"
if [ -f "\$CONFIG_FILE" ] ; then
  source \$CONFIG_FILE

  OLD_PASSWORD="admin"
  NEW_PASSWORD=\$OS_PASSWORD
  NEW_PASSWORD_HASH=\$(echo -n \$(echo -n \$NEW_PASSWORD | sha1sum | awk '{print \$1}') | sha1sum | awk '{print \$1}')
  
  systemctl start mariadb
  systemctl start nginx
  
  /usr/bin/mysql -u root -p\$OLD_PASSWORD mysql -e "\
  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('\$NEW_PASSWORD');\
  SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('\$NEW_PASSWORD');\
  SET PASSWORD FOR 'root'@'::1' = PASSWORD('\$NEW_PASSWORD');\
  SET PASSWORD FOR 'redmine'@'localhost' = PASSWORD('\$NEW_PASSWORD');\
  FLUSH PRIVILEGES;"
  
  cd /var/www/redmine
  
  sed -i "s/\$OLD_PASSWORD/\$NEW_PASSWORD/g" /var/www/redmine/config/database.yml
  
  gem install bundler
  bundle install --without development test
  
  bundle exec rake generate_secret_token
  RAILS_ENV=production bundle exec rake db:migrate
  
  /usr/bin/mysql -u redmine -p\$NEW_PASSWORD redmine -e "\
  UPDATE users SET hashed_password='\$NEW_PASSWORD_HASH' WHERE login='admin';\
  UPDATE users SET salt='' WHERE login='admin';"
  
  systemctl restart nginx
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
