#!/usr/bin/python3

#Creating a TCP Server

import socket
#creating of socket object
serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#host 192.168.20.10
host = socket.gethostname()#host will be replaced/subtitued with IP, if changed and not running on host
port = 444
#Binding to socket
serversocket.bind(('192.168.20.10',port))
#number of system listen 3
#starting TCP listener
serversocket.listen(3)

while True:
    #Starting the connection 
    clientsocket, address = serversocket.accept()

    print("Recived connection from %s" %str(address))

    message = 'hello! thank you for connecting to the server' + "\r\n"
    clientsocket.send(message.encode('ascii'))

    clientsocket.close()

