#!/bin/bash

# DB, Wordpress 초기비번 정의 => 설치 후 변경필수!
INIT_ID="CloudZ"
INIT_PASSWORD="Secret@77"

# 필요 패키지 설치
yum update -y
yum install -y httpd php mariadb-server php-mysqlnd expect

chown -R apache:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;

systemctl start httpd
systemctl enable httpd
systemctl start mariadb
systemctl enable mariadb

# DB 비번 초기화 ============================
/usr/bin/mysqladmin -u root password "$INIT_PASSWORD"
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$INIT_PASSWORD\r\"
expect \"Change the root password?\"
send \"y\r\"
expect \"New password\"
send \"$INIT_PASSWORD\r\"
expect \"Re-enter new password\"
send \"$INIT_PASSWORD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"

# Mysql 설정 : wordpress DB 생성, User/PW 생성
mysql -u root -p$INIT_PASSWORD mysql -e "\
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON *.* TO '$INIT_ID'@'localhost' IDENTIFIED BY '$INIT_PASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '$INIT_ID'@'%'  IDENTIFIED BY '$INIT_PASSWORD' WITH GRANT OPTION;
FLUSH PRIVILEGES;\
"

# Wordpress 설치
mkdir -p /var/www/
pushd /var/www/
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
rm -f latest.tar.gz
chown -R apache:apache wordpress
mv html{,_old}
mv wordpress html
popd

MYIP=$(curl -s whatismyip.akamai.com)
curl -s --data "dbname=wordpress&uname=$INIT_ID&pwd=$INIT_PASSWORD&dbhost=localhost&prefix=wp_&submit=Submit" \
http://$MYIP/wp-admin/setup-config.php?step=2
curl -s --data "weblog_title=CloudZ+Wordpress+QuickStart&user_name=$INIT_ID&admin_password=$INIT_PASSWORD& \
admin_password2=$INIT_PASSWORD&admin_email=admin%40example.com&blog_public=1&Submit=Install+WordPress" \
http://$MYIP/wp-admin/install.php?step=2

#끝 : 아래 IP로 접속해서 확인 요망
echo $MYIP
