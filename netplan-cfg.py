#!/usr/bin/python3

import yaml
import psutil

# function to validate it an IP address is real, or NA to skip (used for NS2)
def validate_ip(s):
    if s.upper() == "NA":
        return True
    a = s.split('.')
    if len(a) != 4:
        return False
    for x in a:
        if not x.isdigit():
            return False
        i = int(x)
        if i < 0 or i > 255:
            return False
    return True

# function to validate if a network mask is between 8 and 30 bits
def validate_mask(a):
    if len(a) > 2:
        return False
    for x in a:
        if not x.isdigit():
            return False
    if not 8 <= int(a) <= 30:
        return False
    return True

# function to format dhcp yaml for given nic
def set_nic_dhcp(n):
    yamldhcp = {'network': {'version': 2, 'renderer': 'networkd', 'ethernets': {'tempnic': {'dhcp4': True}}}}
    yamldhcp["network"]["ethernets"][n] = yamldhcp["network"]["ethernets"].pop("tempnic")
    staticfilename = "50-" + n + ".yaml"
    write_yaml(yamldhcp, staticfilename)

# function to format static yaml for given nic after getting info
def set_nic_static(n):
    # a basic static YAML config 
    yamlstatic = {'network': {'ethernets': {'tempnic': {'addresses': ['192.168.254.45/24'], 'gateway4': '192.168.254.41', 'nameservers': {'addresses': ['1.1.1.1', '1.0.0.1'], 'search': ['jpaul.me']}, 'optional': True}}, 'version': 2}}

    s_ip = " "
    s_mask = " "
    s_gateway = " "
    s_ns1 = " "
    s_ns2 = " "

    # swap out the tempnic with the nic that the user selected
    yamlstatic["network"]["ethernets"][n] = yamlstatic["network"]["ethernets"].pop("tempnic")

    # get static IP information from the user
    while not validate_ip(s_ip):
        s_ip = input("Please enter the IP address (ex. 192.168.1.50): ")
    while not validate_mask(s_mask):
        s_mask = input("Please enter the subnet bits (ex. 255.255.255.0 = 24): ")
    while not validate_ip(s_gateway):
        s_gateway = input("Please enter the default gateway (ex. 192.168.1.1): ")
    while not validate_ip(s_ns1):
        s_ns1 = input("Please enter DNS nameserver 1 (ex. 192.168.1.2): ")
    while not validate_ip(s_ns2):
        s_ns2 = input("Please enter DNS nameserver 2 (enter NA to skip): ")
    s_searchdomain = input("Please enter the search domain (ex. corp.local): ")

    # start setting yaml data to the input info
    address = s_ip + '/' + s_mask
    yamlstatic['network']['ethernets'][n]['addresses'][0] = address
    yamlstatic['network']['ethernets'][n]['gateway4'] = s_gateway
    yamlstatic['network']['ethernets'][n]['nameservers']['search'][0] = s_searchdomain


    # set name servers
    if (not s_ns2) or (s_ns2.upper() == "NA"):
        yamlstatic['network']['ethernets'][n]['nameservers']['addresses'].pop()
        yamlstatic['network']['ethernets'][n]['nameservers']['addresses'][0] = s_ns1
    else:
        yamlstatic['network']['ethernets'][n]['nameservers']['addresses'][0] = s_ns1
        yamlstatic['network']['ethernets'][n]['nameservers']['addresses'][1] = s_ns2

    # call write yaml function to put yaml data into a config file
    staticfilename = "50-" + n + ".yaml"
    write_yaml(yamlstatic, staticfilename)

# function to write yaml file to netplan config directory
def write_yaml(yamldata, filename):
    filename = "/etc/netplan/" + filename
    print("Trying to write {}".format(filename))
    try:
        with open(filename, 'w') as outfile:
            yaml.dump(yamldata, outfile, default_flow_style=False)
        print("File was written successfully")
    except:
        print("Something went wrong, unable to write file. Did you run the script as sudo or root?")


# main function to control
def main():
    selection = None
    addrs = psutil.net_if_addrs()
    nics = list(addrs.keys())

    print("Please select the network interface to configure")
    i = 0
    while  i < len(nics):
        if not nics[i] == "lo":
            print("{} - {}".format(i, nics[i]))
        i = i + 1

    selection = input("Enter the nic number: ")
    nic = nics[int(selection)]
    print("Configuring {}".format(nic)) 

    static = False

    tmp = input("Do you want to set a Static IP address? (Y/N): ")
    if tmp.upper() == "Y":
        set_nic_static(nic)
    else:
        set_nic_dhcp(nic)


if __name__ == "__main__":
    main()
