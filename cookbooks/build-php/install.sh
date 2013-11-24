#!/bin/bash
d=`date`
echo "$d - Construction RPM de PHP"

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
yum install -q -y rpmdevtools >> $logs_destination/php.log 2>&1

rpmdev-setuptree

if [ ! -d $workspace ]; then
    echo "Erreur d'initialisation de la structure du rpmbuild"
    exit 1
fi
echo "initialisation structure rpmbuild OK"

# installation des packages requis 
yum install -q -y libxml2-devel curl-devel libpng-devel mcrypt.x86_64 libmcrypt-devel.x86_64 >> $logs_destination/php.log 2>&1
error_handler $? "Probleme de recuperation des packages necessaires pour compiler PHP"

# préparation des sources de PHP
cd $workspace/SOURCES/

cp /vagrant/cookbooks/build-php/php-5.5.3.tar.bz2 .
if [ ! -f php-5.5.3.tar ]; then
  bunzip2 php-5.5.3.tar.bz2
  error_handler $? "Probleme de decompression des sources"
fi
if [ ! -d php-5.5.3 ]; then
  tar xf php-5.5.3.tar
  error_handler $? "Probleme de desarchivage des sources"
fi

# compilation
if ! type -P php &>/dev/null; then
  echo "Début compilation"
  cd php-5.5.3
  ./configure --with-apxs2=/usr/bin/apxs --with-openssl --enable-zip --with-gd --with-curl --with-zlib --enable-mbstring --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-mcrypt=/usr/bin/mcrypt >> $logs_destination/php.log 2>&1
  error_handler $? "Probleme au configure"
  echo "configure OK"
  make >> $logs_destination/php.log 2>&1
  error_handler $? "Probleme au make"
  echo "make OK"
  make install >> $logs_destination/php.log 2>&1
  error_handler $? "Probleme au make install"
  echo "Install OK"
else
  echo "PHP deja installe"
fi

# pour créer les RPMs, j'utilise fpm, exemple pris ici : http://systembash.com/content/how-to-turn-php-into-an-rpm-the-easy-way-with-fpm/
if [ ! -f $rpm_location/$rpm_location/php-1_x86_64.rpm ]; then
  yum -q -y install ruby ruby-devel rubygems >> $logs_destination/fpm.log 2>&1
  error_handler $? "Probleme d'installation de ruby pour fpm"
  gem install fpm

  fpm -s dir -t rpm -n php -v 1 -C / -p $rpm_location/php-VERSION_ARCH.rpm -d libxml2 -d curl -d libpng -d bzip2 -d pcre /usr/local/etc/pear.conf /usr/local/php/ /usr/local/lib/php /usr/local/include/php /usr/local/bin/php-config /usr/local/bin/phar /usr/local/bin/php /usr/local/bin/php-cgi /usr/local/bin/phpize /usr/local/bin/phar.phar /usr/lib64/httpd/modules/libphp5.so >> $logs_destination/php.log 2>&1
else
  echo "rpm de PHP existe deja"
fi


mkdir -p $rpm_destination
cp $rpm_location/php-1_x86_64.rpm $rpm_destination

# mcrypt
cp /usr/lib64/libmcrypt.so $rpm_destination 

d=`date`
echo "$d - Fin de Construction RPM de PHP"


