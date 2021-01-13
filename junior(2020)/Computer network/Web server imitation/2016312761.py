from socket import *
import threading
import time

def httpprocess(connectionSocket):
    global permit
    global num
    global curtime
    global identifier
    msg = connectionSocket.recv(1024).decode()
    print(msg)
    if 'cookieID=' in msg:
        permit=2
    elif permit==2 and 'cookieID=' not in msg:
        permit=0
        curtime=0
    newmsg = msg.split('/')
    filename = newmsg[1].split(' ')[0]
    images = ['.jpg', '.jpeg', '.png', '.bmp']
    header=''
    try:
        if len(filename)==0: #go to index.html (login page)
            header = 'HTTP/1.1 200 OK\r\n'
            header+='Keep-Alive: timeout=5\r\nConnection: Keep-Alive\r\n\r\n'
            src=open('index.html', 'rt', encoding='utf-8')
            content=src.read(10240)
            permit=1
            connectionSocket.send((header+content).encode('utf-8'))
            src.close()

        else:
            if permit==0: #cannot go any page
                header = 'HTTP/1.1 403 Forbidden\r\n\r\n'
                print("403 Forbidden")
                connectionSocket.send(header.encode('utf-8'))
            elif permit==1:
                if 'secret.html' == filename and len(msg.split('&')[0].split('id=')[1])>=1 and len(msg.split('&')[1])>=4:
                    identifier = msg.split('&')[0].split('id=')[1]
                    header = 'HTTP/1.0 200 OK\r\n'
                    header+= 'Content-Type: text/html\r\n'
                    header+= 'Set-Cookie: cookieID='
                    header+= str(num)
                    header+= '; Max-Age=30\r\n'
                    header+='Keep-Alive: timeout=5\r\nConnection: Keep-Alive\r\n\r\n'
                    if curtime==0:
                        curtime=time.time()
                    src = open(filename, 'rt', encoding='utf-8')
                    content = src.read(10240)
                    connectionSocket.send((header+content).encode('utf-8'))
                    src.close()
                    num=num+1
                    permit=2
                else:
                    header = 'HTTP/1.1 403 Forbidden\r\n\r\n'
                    print("403 Forbidden")
                    connectionSocket.send(header.encode('utf-8'))

            elif permit==2:
                if '.html' in filename:
                    if 'cookie.html' == filename: #cookie.html
                        header = 'HTTP/1.1 200 OK\r\n'
                        header+='Keep-Alive: timeout=5\r\nConnection: Keep-Alive\r\n\r\n'
                        src=open(filename, 'rt', encoding='utf-8')
                        content=src.read(10240)
                        content2 = content.split('</title>')
                        newcontent=''
                        newcontent+=content2[0]
                        newcontent+=identifier
                        newcontent+='</title>'
                        newcontent+=content2[1].split('Hello')[0]
                        newcontent+='Hello '
                        newcontent+=identifier
                        newcontent+=content2[1].split('Hello')[1].split('seconds')[0]
                        newcontent+=str(int(30-(time.time()-curtime)))
                        newcontent+=' seconds'
                        newcontent+=content2[1].split('Hello')[1].split('seconds')[1]

                        connectionSocket.send((header+newcontent).encode('utf-8'))
                        src.close()
                    else:
                        header = 'HTTP/1.1 200 OK\r\n'
                        header+='Keep-Alive: timeout=5\r\nConnection: Keep-Alive\r\n\r\n'
                        src=open(filename, 'rt', encoding='utf-8')
                        content=src.read(10240)
                        connectionSocket.send((header+content).encode('utf-8'))
                        src.close()
                else:
                    for img in images:
                        if img in filename: #image file
                            src=open(filename, 'rb')
                            connectionSocket.send('HTTP/1.0 200 OK\r\n'.encode())
                            connectionSocket.send("Content-Type: image/png\r\n".encode())
                            connectionSocket.send("Accept-Ranges: bytes\r\n\r\n".encode())
                            connectionSocket.send(src.read())
                            src.close()
                            break

    except Exception as e:
        header = 'HTTP/1.1 404 Not Found\r\n\r\n'
        connectionSocket.send(header.encode('utf-8'))
        print(e)

    connectionSocket.close()


serverPort = 10080
serverSocket = socket(AF_INET, SOCK_STREAM)
serverSocket.bind( ('', serverPort) )
serverSocket.listen( 5 )

print( 'The TCP server is ready to receive.' )

global permit
permit=0
global num
num=1
global curtime
curtime=0

while True:
    connectionSocket, addr = serverSocket.accept()
    t = threading.Thread(target=httpprocess, args=(connectionSocket,))
    t.start()
