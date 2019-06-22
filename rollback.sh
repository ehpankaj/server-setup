#!/bin/bash
cd ~/
echo 1
rm -r ~/server-setup
echo 2
rm -r ~/.ssh
echo 3
rm -r /etc/netplan/netplan.yaml
echo 4
sudo apt-get purge nginx nginx-common
echo 5
sudo apt-get autoremove
echo 6
rm -r /var/www/test
echo 7
rm -r /etc/nginx/sites-available/test
echo 8
unlink -s /etc/nginx/sites-enabled/test
echo 9
sudo ufw reset
echo 10