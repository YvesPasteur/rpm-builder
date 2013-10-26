#!/bin/bash
d=`date`
echo "$d - Construction de Xdebug"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}

echo "Compilation de Xdebug"

logs_destination="/vagrant/logs"
mkdir -p $logs_destination



wget --quiet http://xdebug.org/files/xdebug-2.2.3.tgz
error_handler $? "Erreur à la récupération des sources de xdebug"

echo "Sources récupérées"

tar -xzf xdebug-2.2.3.tgz
error_handler $? "Erreur à l'extraction des sources de xdebug"

cd xdebug-2.2.3

PATH=$PATH:/usr/local/bin
phpize >> $logs_destination/xdebug.log 2>&1
error_handler $? "Erreur à l'exécution de phpize"
echo "phpize OK"

./configure >> $logs_destination/xdebug.log 2>&1
error_handler $? "Erreur lors du configure de xdebug"
echo "configure OK"

make >> $logs_destination/xdebug.log 2>&1
error_handler $? "Erreur lors du make de xdebug"
echo "make OK"

cp modules/xdebug.so /vagrant/rpm

d=`date`
echo "$d - Fin de Construction de Xdebug"
