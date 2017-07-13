#!/bin/sh

cd /var/www/redmine

sthvar=$(pwgen 8 1)

mkdir /ReadMe
echo "The Admin Password for Redmine is \""$sthvar"\"" > /ReadMe/ReadMe


eval "RAILS_ENV=production bin/rails runner 'puts user = User.find(1); user.password, user.password_confirmation = \"$sthvar\"; user.save! '"

