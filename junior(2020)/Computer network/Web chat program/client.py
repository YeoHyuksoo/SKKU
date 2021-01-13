import sys
### library ###
import socket
import threading
from time import sleep
from ast import literal_eval

serverIP = '10.0.0.3'
serverPort = 10080
clientPort = 10081

def receive_data(client_socket):
    global flag, clients
    while True:
        if flag == 1:
            break
        data, addr = client_socket.recvfrom(1024)
        if data:
            data = data.decode()
            data = data.split("::")
            if data[0] == "clients":
                dictionary = literal_eval(data[1])
                clients = dictionary
            elif data[0] == "message":
                print("From", data[1], '[' + data[2] + ']')

def keep_alive(client_socket, serverIP, serverPort):
    global flag
    msg = "keep_alive:" + clientID
    while True:
        for i in range(0, 10, 1):
            if flag == 1:
                break
            sleep(1)
        if flag == 1:
            break
        client_socket.sendto(msg.encode(), (serverIP, serverPort))

def show_list():
    global clients
    for key in clients:
        print(key, str(clients[key][0][0]) + ':' + str(clients[key][0][1]))

def send_msg(client_socket, receiver, msg):
    global clients
    msg = "message::" + clientID + "::" + msg
    if clients[clientID][0][0] == clients[receiver][0][0]:
        client_socket.sendto(msg.encode(), (clients[receiver][2], clientPort))
    else:
        client_socket.sendto(msg.encode(), clients[receiver][0])

def send_deregister(client_socket, serverIP, serverPort):
    msg = "deregister:" + clientID
    client_socket.sendto(msg.encode(), (serverIP, serverPort))

def client(serverIP, serverPort, clientID):
    global clients, flag
    clients = {}
    flag = 0

    client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    client_socket.connect((serverIP, serverPort))
    private_addr = client_socket.getsockname()
    client_socket.close()

    client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    client_socket.bind(('', clientPort))

    print('#', clientID, "starts")

    th_receive_data = threading.Thread(target=receive_data, args=(client_socket,))
    th_receive_data.start()

    th_keep_alive = threading.Thread(target=keep_alive, args=(client_socket, serverIP, serverPort,))
    th_keep_alive.start()

    data = "recvID:" + clientID + ' ' + str(private_addr[0])
    client_socket.sendto(data.encode(), (serverIP, serverPort))

    while True:
        sentence = input("")
        
        if sentence == '@exit':
            send_deregister(client_socket, serverIP, serverPort)
            flag = 1
            print('#', clientID, "terminates")
            th_receive_data.join()
            th_keep_alive.join()
            break

        elif sentence == "@show_list":
            show_list()

        elif sentence.startswith("@chat"):
            receiver = sentence.split(' ')[1]
            msg = ' '.join(sentence.split(' ')[2:])
            send_msg(client_socket, receiver, msg)

    sys.exit(0)

"""
Don't touch the code below!
"""
if  __name__ == '__main__':
    clientID = input("")
    client(serverIP, serverPort, clientID)


