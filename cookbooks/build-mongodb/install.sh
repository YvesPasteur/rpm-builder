#!/bin/bash
d=`date`
echo "$d - Construction de MongoDB"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}

echo "Compilation de MongoDB"

logs_destination="/vagrant/logs"
mkdir -p $logs_destination

cd /tmp
cp /vagrant/cookbooks/build-mongodb/mongo-php.tar.bz2 /tmp/
bunzip2 mongo-php.tar.bz2 
tar -xf mongo-php.tar
error_handler $? "Erreur à l'extraction des sources de mongodb-php"

rm mongo-php.tar

cd /tmp/mongo-php-driver-master
error_handler $? "Erreur en entrant dans mongodb-php-driver-master"

PATH=$PATH:/usr/local/bin
phpize >> $logs_destination/mongodb.log 2>&1
error_handler $? "Erreur à l'exécution de phpize"
echo "phpize OK"

./configure >> $logs_destination/mongodb.log 2>&1
error_handler $? "Erreur lors du configure de mongodb"
echo "configure OK"

make all >> $logs_destination/mongodb.log 2>&1
error_handler $? "Erreur lors du make de mongodb"
echo "make OK"


make install
error_handler $? "Erreur lors du make install de mongodb"

cp modules/mongo.so /vagrant/rpm

d=`date`
echo "$d - Fin de Construction de MongoDB"
