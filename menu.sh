#!/bin/bash
##########################################################
#
# Info and Config Menu for Unifi Appliance
#
# Disclaimer: Unifi is a trademark of Ubiquiti Networks
# I make no claim to their I.P. and provide this virtual
# appliance for simplicity for new users. I make no 
# guarentee that it works, or that it will be super awesome
# use at your own risk.
#
##########################################################
while true
do
  # get network information (get each time in case it changes)
  interface=$(cat /etc/network/interfaces | grep -i "iface" | grep -vi "lo" | awk '{print $2}')
  interface=$(python3 /home/unifi/unifi-va/netinfo.py interface)
  ipinfo=$(python3 /home/unifi/unifi-va/netinfo.py address)
  ipgw=$(ip route | grep -i "default" | awk '{ print $3 }')

  # start menu output
  clear
  echo "=================================================="
  echo "=      Recklessop's Unifi Virtual Appliance      ="
  echo "=        Info and Config menu v1.1.0             ="
  echo "=================================================="
  echo "Current Network Config:"
  echo "   Interface Name: $interface"
  echo "   Details: $ipinfo"
  echo "   Default Gateway: $ipgw"
  echo "=================================================="
  echo -e "Select an action from the menu below\n"
  echo "1.) Update Unifi Application    2.) Configure Network Settings"
  echo "3.) Update Unifi-va Scripts     4.) Bash Shell"
  echo "5.) Change unifi user password  6.) Exit"
  read choice
  case "$choice" in
          1) # Update Unifi Appliance
              clear
              echo "Updating Unifi from Ubuntu APT repo"
              (sudo apt update && sudo apt upgrade -y)
              ;;
          2) # Config Network Settings
              clear
              echo "====================="
              echo "Network Config Wizard"
              echo -e "=====================\n"
              (sudo python3 /home/unifi/unifi-va/netplan-cfg.py)
              echo "Running Netplan Generate & Netplan Apply"
              (sudo netplan generate)
              (sudo netplan apply)
              echo "Press any key to reboot"
              read reboot
              sudo reboot
              ;;
          3) # Update Unifi Scripts from Github
              clear
              echo "Updating Unifi from GitHub"
              (cd /home/unifi/unifi-va/ && git reset --hard HEAD && git pull http://www.github.com/recklessop/unifi-va/)`
	      sudo /home/unifi/unifi-va/update-apt.sh
              ;;
          4) # enter bash shell prompt
              clear
              /bin/bash
              ;;
          5) # enter bash shell prompt
              clear
	      echo "Enter a new password for user unifi:"
              /usr/bin/passwd
              ;;
          6) # exit the menu script
              exit
              ;;
          *) echo "invalid option try again";;
      esac
      echo "Press any key to Continue..."
      read input
done
done

