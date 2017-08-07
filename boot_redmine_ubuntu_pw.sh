#!/bin/bash

cat << EOF > /root/cloudz.sh
#!/bin/sh

CONFIG_FILE="/root/provisioningConfiguration.cfg"
if [ -f "\$CONFIG_FILE" ] ; then
  source \$CONFIG_FILE

  OLD_PASSWORD="admin"
  NEW_PASSWORD=\$OS_PASSWORD
  
  service mariadb start
  service nginx start
  
  /usr/bin/mysql -u root -p\$OLD_PASSWORD mysql -e "\
  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('\$NEW_PASSWORD');\
  SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('\$NEW_PASSWORD');\
  SET PASSWORD FOR 'root'@'::1' = PASSWORD('\$NEW_PASSWORD');\
  SET PASSWORD FOR 'debian-sys-maint'@'localhost' = PASSWORD('\$NEW_PASSWORD');\
  SET PASSWORD FOR 'redmine'@'localhost' = PASSWORD('\$NEW_PASSWORD');\
  FLUSH PRIVILEGES;"
  
  cd /var/www/redmine
  
  sed -i "s/\$OLD_PASSWORD/\$NEW_PASSWORD/g" /var/www/redmine/config/database.yml
  
  mkdir -p tmp tmp/pdf public/plugin_assets
  sudo chown -R www-data:www-data files log tmp public/plugin_assets
  sudo chmod -R 775 files log tmp public/plugin_assets
  
  gem install bundler
  bundle install --without development test
  
  bundle exec rake generate_secret_token
  RAILS_ENV=production bundle exec rake db:migrate
  RAILS_ENV=production bundle exec rake redmine:load_default_data
  
  eval "RAILS_ENV=production bin/rails runner 'puts user = User.find(1); user.password, user.password_confirmation = \"\$NEW_PASSWORD\"; user.save! '"

  service nginx restart
  
  service cloudz disable
  
  rm -f /etc/systemd/system/cloudz.service
  rm -f /root/cloudz.sh
else
  echo "provisioningConfiguration file not exist"
fi
EOF

chmod 755 /root/cloudz.sh

touch /etc/init.d/cloudz

cat << EOF > /etc/init.d/cloudz
#!/bin/bash

### BEGIN INIT INFO
# Provides:        TestServer
# Required-Start:  $network
# Required-Stop:   $network
# Default-Start:   2 3 4 5
# Default-Stop:    0 1 6
# Short-Description: Start/Stop TestServer
### END INIT INFO

start() {
 sh /root/cloudz.sh
}

case $1 in
  start|stop) $1;;
  restart) stop; start;;
  *) echo "Run as $0 "; exit 1;;
esac

EOF

chmod 755 /etc/init.d/cloudz

update-rc.d cloudz defaults

service enable cloudz
cat /dev/null > /root/.bash_history && history -c  
