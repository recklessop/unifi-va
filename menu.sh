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
  iptype=$(cat /etc/network/interfaces | grep -vi "lo" | grep -i "inet" | awk '{print $NF}')
  ipinfo=$(ifconfig $interface | awk '/inet addr/' | sed "s/^[ \t]*//")
  ipgw=$(ip route | grep -i "default" | awk '{ print $3 }')
  manadd=$(/sbin/ifconfig $interface | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
  ver=$(cat /var/lib/unifi/db/version)
  # start menu output
  clear
  echo "=================================================="
  echo "=      Recklessop's Unifi Virtual Appliance      ="
  echo "=        Info and Config menu v1.0.3             ="
  echo "=================================================="
  echo "Current Network Config:"
  echo "   Interface Name: $interface"
  echo "   Static \ DHCP: $iptype"
  echo "   Details: $ipinfo"
  echo "   Default Gateway: $ipgw"
  echo "   Management Address: https://$manadd:8443"
  echo "   Unifi Controller Version: $ver
  echo "=================================================="
  echo -e "Select an action from the menu below\n"
  echo "1.) Update Unifi Application    2.) Configure Network Settings"
  echo "3.) Update Unifi-va Scripts     4.) Bash Shell"
  echo "5.) Change unifi user password  6.) Exit"
  echo "7.) Restart Unifi Service       8.) Reboot Unifi Appliance"
  read choice
  case "$choice" in
          1) # Update Unifi Scripts from Github
              clear
              echo "Updating Unifi from Ubuntu APT repo"
              (sudo apt update && sudo apt upgrade -y)
              ;;
          2) # Config Network Settings
              clear
              echo "====================="
              echo "Network Config Wizard"
              echo -e "=====================\n"
              echo "Configure appliance with DHCP or STATIC IP? (S=Static, D=DHCP)"
              read network
                case "$network" in
                    "S" | "s") # update /etc/network/interface with static config
                                echo "Enter IP address (xxx.xxx.xxx.xxx):"
                                read nicip
                                echo "Enter Subnet Mask (xxx.xxx.xxx.xxx):"
                                read nicmask
                                echo "Enter Default Gateway (xxx.xxx.xxx.xxx):"
                                read nicgw
                                echo "Enter DNS Servers (Seperate by space):"
                                read nicdns
                                echo "Does everything look correct? (Y/N)"
                                read confirm
                                case "$confirm" in
                                   "Y" | "y")
                                        awk -f /home/unifi/unifi-va/changeInterface.awk /etc/network/interfaces device="$interface" mode=static address="$nicip" netmask="$nicmask" dns="$nicdns" gateway="$nicgw" | sudo tee /etc/network/interfaces
                	                echo "Press any key to reboot"
					read reboot
					sudo reboot
                                        ;;
                                   *)
                                        break
                                        ;;
                                esac
                                ;;
                    "D" | "d") # update /etc/network/interface with dhcp config
                                awk -f /home/unifi/unifi-va/changeInterface.awk /etc/network/interfaces device="$interface" mode=dhcp | sudo tee /etc/network/interfaces
                                echo "Press any key to reboot"
				read reboot
				sudo reboot
                                ;;
                    *) echo "invalid option try again";;
                esac
              ;;
          3) # Update Unifi Scripts from Github
              clear
              echo "Updating Unifi from GitHub"
              (cd /home/unifi/unifi-va/ && git reset --hard HEAD && git pull http://www.github.com/recklessop/unifi-va/)
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
          7) # Restart Unifi Service
              clear
              echo "Restarting Unifi Controller Services"
              (sudo service unifi restart)
              ;;
          8) # Reboot Unifi Server Appliance
              clear
              echo "Rebooting Unifi Server Appliance, you will need to reconnect"
              (sudo reboot)
              ;;
          99) # Update Unifi Scripts from StevenDeZalia Github
              clear
              echo "Updating Unifi from StevenDeZalia GitHub"
              (cd /home/unifi/unifi-va/ && git reset --hard HEAD && git pull http://www.github.com/StevenDeZalia/unifi-va/)
              ;;
          *) echo "invalid option try again";;
      esac
      echo "Press any key to Continue..."
      read input
done
done

