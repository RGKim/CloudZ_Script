
sthvar=$(pwgen 8 1)


mkdir /ReadMe

echo "The Admin Password is \""$sthvar"\"" > /ReadMe/ReadMe

opt/wildfly/bin/add-user.sh admin $sthvar
