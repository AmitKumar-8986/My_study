#!/usr/bin/python3
import socket

def banner(ip,port):
    skt = socket.socket()
    skt.connect((ip, int(port)))
    print(str(skt.recv(1024)).strip('b'))

def main():
    ip = input("Please enter the IP address: ")
    port = str(input("Please enter the port: "))
    banner(ip,port)

main()