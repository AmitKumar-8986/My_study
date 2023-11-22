#!/usr/bin/python3
#Creating a TCP Client
import socket
#creating of socket object
clientsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
host = socket.gethostname()
port = 444
clientsocket.connect((host,port))
message = clientsocket.recv(1024)
clientsocket.close()
print(message.decode('ascii'))
