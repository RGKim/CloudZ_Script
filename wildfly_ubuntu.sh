mkdir /ReadMe

sthvar=$(pwgen 8 1)


echo "The Admin ID is admin and the Password is \""$sthvar"\"" &> /ReadMe/ReadMe

./opt/wildfly/bin/add-user.sh admin $sthvar




