echo "This script updates your apt sources with the official unifi apt repo and then upgrades all packages on the unifi appliance
echo "deb http://www.ui.com/downloads/unifi/debian stable ubiquiti" | sudo tee /etc/apt/sources.list.d/100-ubnt.list
sudo apt-key adv --recv-keys 06E85760C0A52C50
sudo apt update
sudo apt upgrade -y
