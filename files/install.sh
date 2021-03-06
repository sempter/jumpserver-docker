#!/usr/bin/env bash

DEPENDS="nodejs python-django ssh python-paramiko python-ldap python-ecdsa python-django-shortuuidfield python-psutil slapd ldapscripts python-pycryptopp python-pip python-mysqldb"
APP_DIR="/opt/jumpserver"

echo 'slapd	slapd/domain	string	jumpserver.org' | debconf-set-selections
echo 'slapd	shared/organization	string	jumpserver' | debconf-set-selections
cat > /etc/apt/sources.list <<EOF
deb http://ap-southeast-1.ec2.archive.ubuntu.com/ubuntu/ trusty main
deb http://ap-southeast-1.ec2.archive.ubuntu.com/ubuntu/ trusty-updates main
deb http://ap-southeast-1.ec2.archive.ubuntu.com/ubuntu/ trusty universe
deb http://ap-southeast-1.ec2.archive.ubuntu.com/ubuntu/ trusty-updates universe
EOF

apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install $DEPENDS
pip install django-uuidfield

cd $APP_DIR
chmod +x *.py *.sh
cp docs/zzjumpserver.sh /etc/profile.d/

rm -f /var/lib/ldap/{__db.*,alock,dn2id.bdb,id2entry.bdb,log.0000000001,objectClass.bdb}
/etc/init.d/slapd start

cp /opt/install/docker-entrypoint.sh /
cd /opt/install/slapd/
ldapmodify -Y EXTERNAL -H ldapi:/// < rootpw.ldif
ldapadd -x -w secret234 -D "cn=admin,dc=jumpserver,dc=org" -f base.ldif
ldapadd -x -w secret234 -D "cn=admin,dc=jumpserver,dc=org" -f group.ldif
#ldapadd -x -w secret234 -D "cn=admin,dc=jumpserver,dc=org" -f passwd.ldif
#ldapadd -x -w secret234 -D "cn=admin,dc=jumpserver,dc=org" -f sudo.ldif

#ldapdelete -x -D "cn=admin,dc=jumpserver,dc=org" -w secret234 "uid=testuser,ou=People,dc=jumpserver,dc=org"
#ldapdelete -x -D "cn=admin,dc=jumpserver,dc=org" -w secret234 "cn=testuser,ou=Sudoers,dc=jumpserver,dc=org"
#echo no | python manage.py syncdb

