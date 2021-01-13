import sys
from time import sleep
### library ###
import threading
import socket

serverPort = 10080
 
def display_timeout(server_socket):
    global list_lock, clients
    while True:
        timeout_clients = {}
        list_lock.acquire()
        for key in clients:
            clients[key][1] = clients[key][1] + 1
            if clients[key][1] >= 30:
                timeout_clients[key] = 1

        for key in timeout_clients:
            print(key, "is disappeared", str(clients[key][0][0])+':'+str(clients[key][0][1]))
            del clients[key]

        msg = "clients::" + str(clients)
        for key in clients:
            server_socket.sendto(msg.encode(), clients[key][0])
        list_lock.release()
        sleep(1)

def receive_data(server_socket):
    global list_lock, clients
    while True:
        data, addr = server_socket.recvfrom(1024)
        if data:
            data = data.decode()
            data = data.split(':')
            list_lock.acquire()
            if data[0] == "recvID":
                print(data[1].split(' ')[0], str(addr[0])+':'+str(addr[1]))
                clients[data[1].split(' ')[0]] = [addr, 0, data[1].split(' ')[1]]
                for key in clients:
                    if clients[key][0] == addr:
                        msg = "clients::" + str(clients)
                        server_socket.sendto(msg.encode(), clients[key][0])
            elif data[0] == "keep_alive":
                clients[data[1]][1] = 0
            elif data[0] == "deregister":
                for key in clients:
                    if key == data[1]:
                        print(data[1], "is deregistered", str(clients[key][0][0])+':'+str(clients[key][0][1]))
                        del clients[key]
                        break
                msg = "clients::" + str(clients)
                for key in clients:
                    server_socket.sendto(msg.encode(), clients[key][0])
            list_lock.release()


def server():
    global list_lock, clients, server_close
    list_lock = threading.Lock()
    clients = {}
    server_close = 0

    server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    server_socket.bind(('', serverPort))

    print("server starts")

    th_timeout = threading.Thread(target=display_timeout, args=(server_socket,))
    th_timeout.start()

    th_receive_data = threading.Thread(target=receive_data, args=(server_socket,))
    th_receive_data.start()

    while True:
        if server_close:
            break

    server_socket.close()

"""
Don't touch the code below
"""
if  __name__ == '__main__':
    server()


