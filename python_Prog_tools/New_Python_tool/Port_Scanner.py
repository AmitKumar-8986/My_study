#!/usr/bin/python3
import socket

skt = socket.socket(socket.AF_INET,socket.SOCK_STREAM)

host = input("Please enter the IP address: ")
#port = 1-1024

for port in range(1,1024,1):
    #portScanner(port)
    if skt.connect_ex((host,port)):
        continue#print("Port is closed!!")
    else:
        print("The port {} is open!!".format(port))