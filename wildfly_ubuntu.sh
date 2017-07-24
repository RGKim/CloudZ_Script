cd /opt/wildfly/bin

sthvar=$(pwgen 8 1)

mkdir /ReadMe
echo "The Admin Password is \""$sthvar"\"" > /ReadMe/ReadMe

./add-user admin $sthvar

