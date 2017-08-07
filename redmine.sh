#!/bin/sh

cat << EOF > /root/redminepw.sh
#!/bin/sh
  NEW_PASSWORD="\$(cat /root/passwd)"
  eval "RAILS_ENV=production /var/www/redmine/bin/rails runner 'puts user = User.find(1); user.password, user.password_confirmation = \"\$NEW_PASSWORD\"; user.save! '"

EOF

./redminepw.sh

rm -rf redminepw.sh
rm -rf redmine.sh
