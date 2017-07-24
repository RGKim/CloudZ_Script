cd /opt/wildfly/bin

sthvar=$(pwgen 8 1)

mkdir /ReadMe
echo "The Admin ID is admin and the Password is \""$sthvar"\"" > Password.txt


./add-user.sh admin $sthvar

