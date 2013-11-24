#!/bin/bash
d=`date`
echo "$d - Construction de mcrypt"

# error_handler $? "message d'erreur"
function error_handler() {
  if [ $1 -ne 0 ]; then
    echo $2
    exit 1
  fi
}

logs_destination="/vagrant/logs"
mkdir -p $logs_destination

yum install -y mcrypt.x86_64
error_handler $? "Erreur lors de l'install de mcrypt"

d=`date`
echo "$d - Fin de Construction de mcrypt"
