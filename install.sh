#!/bin/bash
me=$(whoami)
dirpath=$(pwd)

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list

echo "unifi ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/apt/sources.list.d/mongodb-org-3.4.list

cat > /home/$me/override.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noissue --autologin $me \%I \$TERM
Type=idle
EOF
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
sudo mv /home/$me/override.conf /etc/systemd/system/getty@tty1.service.d/
sudo chown -R root:root /etc/systemd/system/getty@tty1.service.d
sudo apt update
sudo apt upgrade -y
sudo apt install python3-pip git -y
git clone http://github.com/recklessop/unifi-va.git /home/$me/unifi-va
sudo pip3 install -r /home/$me/unifi-va/requirements.txt
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

cd /etc/profile.d/
ln -s /home/$me/unifi-va/menu.sh
cd ~
