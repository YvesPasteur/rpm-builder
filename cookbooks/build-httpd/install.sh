#!/bin/bash

d=`date`
echo "$d - Construction RPMs de Apache"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}


workspace="/root/rpmbuild"
rpm_location="$workspace/RPMS/x86_64"
rpm_destination="/vagrant/rpm"
logs_destination="/vagrant/logs"

mkdir -p $logs_destination

# construction de la structure de répertoires permettant de construire les RPMs
echo "initialisation structure rpmbuild"
yum install -q -y rpmdevtools

rpmdev-setuptree

if [ ! -d $workspace ]; then
    echo "Erreur d'initialisation de la structure du rpmbuild"
    exit 1
fi
echo "initialisation structure rpmbuild OK"
###
# installation de distcache
###
cd $workspace/SRPMS/

echo "Début distache"
yum -q -y update

yum install -q -y libtool openssl-devel
error_handler $? "Probleme d'installation de libtool"
echo "libtool OK"

wget -q http://dl.fedoraproject.org/pub/fedora/linux/releases/18/Fedora/source/SRPMS/d/distcache-1.4.5-23.src.rpm
error_handler $? "Probleme de recuperation des sources de distcache"

rpmbuild --quiet --rebuild distcache-1.4.5-23.src.rpm >> $logs_destination/distcache.log 2>&1
error_handler $? "Erreur pour construire le rpm de distcache, voir le fichier de log"
echo "rpmbuild distacache OK"

yum install -y -q $rpm_location/* >> $logs_destination/distcache.log 2>&1
error_handler $? "Erreur pour installer les rpm de distcache, voir le fichier de log"

echo "distcache OK"
###
# creation des rpm de apr et apr-util
###
cd $workspace/SOURCES/

wget -q http://mir2.ovh.net/ftp.apache.org/dist/apr/apr-1.5.1.tar.bz2
error_handler $? "Probleme de recuperation des sources de apr"
echo "recuperation sources de apr OK"

wget -q http://mir2.ovh.net/ftp.apache.org/dist/apr/apr-util-1.5.4.tar.bz2
error_handler $? "Probleme de recuperation des sources de apr-util"
echo "recuperation sources de apr-util OK"

yum install -y -q doxygen >> $logs_destination/apr.log 2>&1
echo "installation de doxygen OK"

if [ ! -f $rpm_location/apr-1.5.1-1.x86_64.rpm ]; then
  rpmbuild --quiet -ta apr-1.5.1.tar.bz2 >> $logs_destination/apr.log 2>&1
  error_handler $? "Erreur pour construire le rpm de apr, voir le fichier de log"
  echo "construction rpm de apr OK"
else
  echo "RPM de apr existe deja, pas de construction"
fi

yum install -y -q $rpm_location/* >> $logs_destination/apr.log 2>&1
error_handler $? "Erreur pour installer les rpm de apr, voir le fichier de log"
echo "installation apr OK"

yum install -y -q expat-devel libuuid-devel db4-devel postgresql-devel mysql-devel sqlite-devel unixODBC-devel openldap-devel nss-devel >> $logs_destination/apr.log 2>&1
error_handler $? "Erreur pour installer les packages necessaires pour apr, voir le fichier de log"
echo "installation packages necessaires pour apr OK"

# freetds-devel n'est plus dans les depots par defaut
wget -q http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
error_handler $? "Probleme de recuperation du rpm de epel"
echo "recuperation rpm de EPEL OK"

yum install -y -q epel-release-6-8.noarch.rpm >> $logs_destination/apr.log 2>&1
error_handler $? "Erreur pour installer EPEL, voir le fichier de log"
echo "installation EPEL OK"

yum install -y -q freetds-devel >> $logs_destination/apr.log 2>&1
error_handler $? "Erreur pour installer freetds-devel, voir le fichier de log"
echo "Installation freetds-devel OK"

rm epel-release-6-8.noarch.rpm

if [ ! -f $rpm_location/apr-util-1.5.4-1.x86_64.rpm ]; then
  rpmbuild --quiet -ta apr-util-1.5.4.tar.bz2 >> $logs_destination/apr.log 2>&1
  error_handler $? "Erreur pour construire les rpm d'apr-util, voir le fichier de log"
  echo "construction rpm apr-util OK"
else
  echo "RPM de apr-util existe deja, pas de construction"
fi

yum install -y -q $rpm_location/* >> $logs_destination/apr.log 2>&1
error_handler $? "Erreur pour installer apr-util, voir le fichier de log"
echo "installation rpm de apr OK"

###
# creation des rpm de httpd
###
cd $workspace/SOURCES/

wget -q http://mir2.ovh.net/ftp.apache.org/dist/httpd/httpd-2.4.10.tar.bz2
error_handler $? "Probleme de recuperation des sources de httpd"
echo "recuperation sources httpd OK"

tar -xvf httpd-2.4.10.tar.bz2
error_handler $? "Probleme pour decompresser les sources de httpd"
sed -i '/modules\/mod_watchdog.so/a %{_libdir}/httpd/modules/mod_proxy_wstunnel.so' httpd-2.4.10/httpd.spec
sed -i 's/\(--enable-case-filter --enable-case-filter-in \\\)/\1\n\t--enable-so \\/' httpd-2.4.10/httpd.spec
tar -cf httpd-2.4.10.tar.bz2 httpd-2.4.10
error_handler $? "Probleme pour archiver les sources de httpd"

yum install -y -q pcre-devel lua-devel libxml2-devel >> $logs_destination/httpd.log 2>&1
error_handler $? "Erreur pour installer les packages necessaires pour httpd, voir le fichier de log"
echo "installation packages necessaires pour httpd OK"

if [ ! -f $rpm_location/httpd-2.4.10-1.x86_64.rpm ]; then
  rpmbuild --quiet -ta httpd-2.4.10.tar.bz2 >> $logs_destination/httpd.log 2>&1
  error_handler $? "Erreur pour construire les rpm de httpd, voir le fichier de log"
  echo "construction rpm de httpd OK"
else
  echo "rpm de httpd existe déjà, pas de construction"
fi

yum install -y -q mailcap >> $logs_destination/httpd.log 2>&1
error_handler $? "Erreur pour installer mailcap, voir le fichier de log"
echo "installation de mailcap OK"

yum install -y -q $rpm_location/*>> $logs_destination/httpd.log 2>&1
error_handler $? "Erreur pour installer httpd, voir le fichier de log"
echo "installation de httpd OK"

###
# on copie les rpms en dehors de la VM pour les recuperer sur la machine hote
###
mkdir -p $rpm_destination

cp $rpm_location/* $rpm_destination
cp $workspace/SOURCES/* $rpm_destination


d=`date`
echo "$d - Fin de Construction RPMs de Apache"
