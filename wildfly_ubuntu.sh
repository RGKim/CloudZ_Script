sudo apt-get install pwgen -y

sthvar=$(pwgen 8 1)

mkdir /ReadMe
echo "The Admin Password is \""$sthvar"\"" > /ReadMe/ReadMe

cd /opt/wildfly/bin

./add-user admin $sthvar

