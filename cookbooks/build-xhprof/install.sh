#!/bin/bash
d=`date`
echo "$d - Construction de Xhprof"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}

echo "Compilation de Xhprof"

logs_destination="/vagrant/logs"
mkdir -p $logs_destination



wget --quiet http://pecl.php.net/get/xhprof-0.9.4.tgz
error_handler $? "Erreur à la récupération des sources de xhprof"

echo "Sources récupérées"

tar -xzf xhprof-0.9.4.tgz
error_handler $? "Erreur à l'extraction des sources de xhprof"

cd xhprof-0.9.4/extension

PATH=$PATH:/usr/local/bin
phpize >> $logs_destination/xhprof.log 2>&1
error_handler $? "Erreur à l'exécution de phpize"
echo "phpize OK"

./configure --with-php-config=/usr/local/bin/php-config >> $logs_destination/xhprof.log 2>&1
error_handler $? "Erreur lors du configure de xhprof"
echo "configure OK"

make >> $logs_destination/xhprof.log 2>&1
make install >> $logs_destination/xhprof.log 2>&1
error_handler $? "Erreur lors du make de xhprof"
echo "make OK"

cp /usr/local/lib/php/extensions/no-debug-zts-20121212/xhprof.so /vagrant/rpm

d=`date`
echo "$d - Fin de Construction de Xhprof"
