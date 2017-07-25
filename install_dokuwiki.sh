#!/bin/sh

set -e

[ -z "${DOKUWIKI_PASSWD}" ] && \
  DOKUWIKI_PASSWD=dokuwiki

centos_install_dokuwiki()
{
  # BUG: https://bugzilla.redhat.com/show_bug.cgi?id=1372948
  R=https://bugzilla.redhat.com
  P="${R}/attachment.cgi?id=1251789&action=diff&context=patch&collapsed=&headers=1&format=raw"

  F=https://dl.fedoraproject.org/pub/fedora
  D=${F}/linux/releases/25/Everything/source/tree/Packages/d
  wget -q ${D}/dokuwiki-0-0.27.20150810a.fc24.src.rpm

  sudo yum-builddep -y dokuwiki-0-0.27.20150810a.fc24.src.rpm
  rpm -i dokuwiki-0-0.27.20150810a.fc24.src.rpm
  rm -f dokuwiki-0-0.27.20150810a.fc24.src.rpm

  cd ~/rpmbuild/SPECS
  wget -q "${P}" -O - | patch -p0
  cd ..
  rpmbuild -ba SPECS/dokuwiki.spec
  cd ..

  pkgs=$(find ~/rpmbuild/RPMS -type f)
  sudo yum install -y epel-release
  # shellcheck disable=SC2086
  sudo yum localinstall -y ${pkgs}
  rm -rf ~/rpmbuild

  # Add ACL and admin user.
  passwd=$(printf "%s" "${DOKUWIKI_PASSWD}" | md5sum -b | cut -d' ' -f1)
  echo "admin:${passwd}:::admin,user" | \
    sudo tee /etc/dokuwiki/users.auth.php
  cat <<EOF | sudo tee /etc/dokuwiki/local.php
<?php
\$conf['useacl'] = 1;
\$conf['superuser'] = '@admin';
EOF
}

centos_install_apache()
{
  sudo yum install -y mod_ssl

  sudo mv /etc/httpd/conf.d/dokuwiki.conf \
       /etc/httpd/conf.d/dokuwiki.conf.orig

  cat <<EOF | sudo tee /etc/httpd/conf.d/dokuwiki.conf
<VirtualHost _default_:443>
  SSLEngine on
  SSLCertificateFile /etc/pki/tls/certs/localhost.crt
  SSLCertificateKeyFile /etc/pki/tls/private/localhost.key

  Alias /dokuwiki /usr/share/dokuwiki

  <Directory /usr/share/dokuwiki>
    Require all granted
  </Directory>

  <Directory /usr/share/dokuwiki/inc>
    Require all denied
  </Directory>

  <Directory /usr/share/dokuwiki/inc/lang>
    Require all denied
  </Directory>

  <Directory /usr/share/dokuwiki/lib/_fla>
    Require all denied
  </Directory>

  <Directory /etc/dokuwiki>
    Require all denied
  </Directory>
</VirtualHost>
EOF

  sudo systemctl enable httpd
  sudo systemctl restart httpd
  sudo firewall-cmd --add-service=https --permanent
  sudo firewall-cmd --reload
}

centos_main()
{
  centos_install_dokuwiki
  centos_install_apache
}

centos_main
