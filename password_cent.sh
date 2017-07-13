#!/bin/sh

systemctl start nginx

cd /var/www/redmine

sthvar=$(pwgen 13 1)

eval "RAILS_ENV=production bin/rails runner 'puts user = User.find(1); user.password, user.password_confirmation = \"$sthvar\"; user.save! '"

mkdir /ReadMe
echo "The Admin Password for Redmine is \""$sthvar"\"" > /ReadMe/ReadMe

