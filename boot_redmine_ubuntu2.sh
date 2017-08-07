#!/bin/bash

cat << EOF > /root/cloudz.sh
#!/bin/sh

if [ -s "/root/provisioningConfiguration.cfg" ] ; then
  
  . /root/provisioningConfiguration.cfg

  OLD_PASSWORD="admin"
  NEW_PASSWORD=\${OS_PASSWORD}
  
  systemctl start nginx

  eval "RAILS_ENV=production bin/rails runner 'puts user = User.find(1); user.password, user.password_confirmation = \"\$NEW_PASSWORD\"; user.save! '"

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
