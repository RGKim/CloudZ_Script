sudo apt install pwgen


sthvar=$(pwgen 8 1)

mkdir /ReadMe

echo "The Admin Password for GitLab is \""$sthvar"\"" > /ReadMe/ReadMe


eval "gitlab-rails runner 'puts user = User.find(1); user.password, user.password_confirmation = \"$sthvar\"; user.save! '"
