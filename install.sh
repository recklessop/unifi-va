#!/bin/bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
sudo apt update
sudo apt install curl net-tools apt-transport-https openjdk-8-jre-headless -y
sudo apt install mongodb-org-server mongodb-org-shell mongodb-org-tools -y
sudo apt install binutils ca-certificates-java java-common -y
sudo apt install jsvc libcommons-daemon-java -y

if [ -f unifi_sysvinit_all.deb ]
then
  rm unifi_sysvinit_all.deb
fi
wget https://dl.ui.com/unifi/5.10.17/unifi_sysvinit_all.deb || abort
sudo dpkg -i unifi_sysvinit_all.deb || abort
rm unifi_sysvinit_all.deb || abort
sudo service unifi start || abort
