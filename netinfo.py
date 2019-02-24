#!/usr/bin/python3
import sys
import socket
import psutil

def get_ip_addresses(family):
    for interface, snics in psutil.net_if_addrs().items():
        for snic in snics:
            if snic.family == family:
                yield (interface, snic.address)


def interface():
    ipv4s = list(get_ip_addresses(socket.AF_INET))
    nic =  ipv4s[1]

    returnStr = nic[0]
    print(returnStr)
    return

def address():
    ipv4s = list(get_ip_addresses(socket.AF_INET))
    nic =  ipv4s[1]

    returnStr = nic[1]
    print(returnStr)
    return



if len(sys.argv) != 2:
    print("Please specify interface or address")
else:
    if str(sys.argv[1]) == "address":
        address()
    elif str(sys.argv[1]) == "interface":
        interface()
    else:
        print("Invalid Parameter, only address and interface are accepted")
