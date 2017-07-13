sudo apt install pwgen

cd /var/www/redmine

sthvar=$(pwgen 8 1)

echo "The Admin Password is \""$sthvar"\"" > ~/readme.txt


eval "RAILS_ENV=production bin/rails runner 'puts user = User.find(1); user.password, user.password_confirmation = \"$sthvar\"; user.save! '"

