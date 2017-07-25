mkdir /ReadMe

cd /opt/tomcat/conf

sthvar=$(pwgen 8 1)

echo "The Tomcat Admin Username is \"admin\" and Password is \""$sthvar"\"" > /ReadMe/ReadMe

sed -i "44s/adminpwd/$sthvar/g" tomcat-users.xml
