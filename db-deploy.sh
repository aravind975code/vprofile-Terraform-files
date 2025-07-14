#!/bin/bash

sudo apt update -y
sudo apt install -y git mysql-client
git clone -b local https://github.com/hkhcoder/vprofile-project.git 
cd vprofile-project
mysql -h ${rds_endpoint} -u ${dbuser} --password="${dbpass}" accounts --ssl-mode=DISABLED < src/main/resources/db_backup.sql

