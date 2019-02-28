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
  # shows the webaddress by IPv4 to connect to to configure and manage the device
  manadd=$(/sbin/ifconfig $interface | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
  # displays version of Unifi installed
  ver=$(cat /var/lib/unifi/db/version)
  # system uptime
  uptime=$(uptime |awk -F, '{print $1,$2}' |
  		sed 's/:/h, /g;s/^.*up */Uptime: /;
		s/ *[0-9]* user.*//;s/[0-9]$/&m/;s/ day. */d, /g')
  # shows date of system
  date=$(date)
  # last boot
  last_boot=$(uptime -s)
  # swap componets
  swap_total=$(free -t -m | grep Swap | awk '{print $2" MB";}')
  swap_used=$(free -t -m | grep Swap | awk '{print $3" MB";}')
  swap_free=$(free -t -m | grep Swap | awk '{print $4" MB";}')
  swap_per=$(free -m | awk '/Swap/ { printf("%3.1f%%", $3/$2*100) }')
  # memory componets
  mem_total=$(free -t -m | grep Mem | awk '{print $2" MB";}')		# Total system ram
  mem_used=$(free -t -m | grep Mem | awk '{print $3" MB";}')		# used system ram
  mem_free=$(free -t -m | grep Mem | awk '{print $4" MB";}')		# Free/Available memory
  mem_per=$(free -m | awk '/Mem/ { printf("%3.1f%%", $3/$2*100) }')	# % of used memory
  # disk storage componets
  disk_name=$(df -h / | grep / | awk '{print $1;}')
  disk_size=$(df -h / | grep / | awk '{print $2;}')
  disk_used=$(df -h / | grep / | awk '{print $3;}')
  disk_free=$(df -h / | grep / | awk '{print $4;}')
  disk_per=$(df -h / | grep / | awk '{print $5;}')
  disk_mnt=$(df -h / | grep / | awk '{print $6;}')
  
  # start menu output
  clear
  echo "=================================================="
  echo "=      Recklessop's Unifi Virtual Appliance      ="
  echo "=        Info and Config menu v1.1.0             ="
  echo "=================================================="
  echo
  echo "Current Network Config:"
  echo "   Interface Name: $interface"
  echo "   Details: $ipinfo"
  echo "   Default Gateway: $ipgw"
  echo
  echo "Unifi Config:"
  echo "   Management Address: https://$manadd:8443"
  echo "   Unifi Controller Version: $ver"
  echo
  echo "System Info:"
  echo "   $uptime"
  echo "   Last Boot Time: $last_boot"
  echo "   Date:   $date"
  echo "   Memory: Total: $mem_total | Used: $mem_used | Free: $mem_free | Percent Used: $mem_per"
  echo "   Disk:"
  echo "     Disk:   Total: $disk_size | Used: $disk_used | Free: $disk_free | Percent Used: $disk_per | Mounted on: $disk_mnt | Name: $disk_name"
  echo "     Swap:   Total: $swap_total | Used: $swap_used | Free: $swap_free | Percent Used: $swap_per"

  
  
  echo "=================================================="
  echo -e "Select an action from the menu below\n"
  echo "1.) Update Unifi Application    2.) Configure Network Settings"
  echo "3.) Update Unifi-va Scripts     4.) Bash Shell"
  echo "5.) Change unifi user password  6.) Exit Session (Disconnect)"
  echo "7.) Restart Unifi Service       8.) Reboot Unifi Appliance"
  read choice
  case "$choice" in
          1) # Updating Unifi from Ubuntu APT repo
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
          100) # Force "unifi" Account to change password at next login
              clear
              echo "User: Unifi will be required to change their password on next login"
              (sudo chage -d 0 unifi)	      
              ;;
          *) echo "invalid option try again";;
      esac
      echo "Press any key to Continue..."
      read input
done
done

