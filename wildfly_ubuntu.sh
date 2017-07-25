#! /bin/bash

mkdir /ReadMe


cd /opt/wildfly

sthvar=$(pwgen 8 1)


echo "The Admin ID is admin and the Password is \""$sthvar"\"" &> /ReadMe/ReadMe

./bin/add-user.sh admin $sthvar

