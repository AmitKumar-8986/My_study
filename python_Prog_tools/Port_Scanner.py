#!/usr/bin/python3
import socket, sys, re

def do_scan(port):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((sys.argv[1], port))
        global data
        data = s.recv(1024).decode()
        s.close()
        return True
    except:
        return False

def port_pass(port):
    if do_scan(port):
        print("Port {} is open".format(port), "DATA : {}".format(str(data)))
    else:
        print("Port {} is close".format(port))

port1 = (sys.argv[2])

if re.findall(",", port1):
    x=port1.split(",")
    for i in x:
        port_pass(int(i))
elif re.findall("-", port1):
    x=port1.split("-")
    port_min = int(x[0])
    port_max = int(x[1])
    for i in range(port_min,port_max+1):
        port_pass(i)
else:
    port = int(port1)
    port_pass(port)
