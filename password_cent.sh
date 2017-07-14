#!/bin/sh

systemctl start nginx
systemctl start mysqld



cd /var/www/redmine

ln -s /usr/local/ruby/bin/ruby /usr/local/rvm/rubies/ruby-2.2.5/bin/ruby &> log.txt

sthvar=$(pwgen 13 1) 

eval "RAILS_ENV=production bin/rails runner 'puts user = User.find(1); user.password, user.password_confirmation = \"$sthvar\"; user.save! '" &>> log.txt

mkdir /ReadMe 
echo "The Admin Password for Redmine is \""$sthvar"\"" > /ReadMe/ReadMe

