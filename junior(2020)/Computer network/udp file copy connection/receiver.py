import sys
import socket
import time
import select
from struct import *

"Use this method to write Packet log"
def writePkt(logFile, procTime, pktNum, event):
    logFile.write('{:1.3f} pkt: {} | {}'.format(procTime, pktNum, event))

"Use this method to write ACK log"
def writeAck(logFile, procTime, ackNum, event):
    logFile.write('{:1.3f} ACK: {} | {}'.format(procTime, ackNum, event))

"Use this method to write final throughput log"
def writeEnd(logFile, throughput):
    logFile.write('File transfer is finished.')
    logFile.write('Throughput : {:.2f} pkts/sec'.format(throughput))

def fileReceiver():
    print('receiver program starts...')
    receiverPort = 10080
    receiverSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    receiverSocket.bind(('', receiverPort))
    
    while True:
        ack=0
        start_time = time.time()
        msg, senderAddr = receiverSocket.recvfrom(1400)
        msg = msg.decode()
        dstFile = msg+"_receiving_log.txt"
        send_log = msg+"_sending_log.txt"
        receiving_log = open(dstFile, 'w')
        writePkt(receiving_log, time.time()-start_time, ack, "received\n")

        receiverSocket.sendto(str(ack).encode(), senderAddr)
        writeAck(receiving_log, time.time()-start_time, ack, "sent\n")
        ack=ack+1
        dst = open(msg, 'wb')
        temp = ""
        while True:
            ready = select.select([receiverSocket], [], [], 3)
            if ready[0]:
                msg, senderAddr = receiverSocket.recvfrom(1400)
                pn = msg[:4]
                pn, = unpack('i', pn)
                data = msg[4:]
                writePkt(receiving_log, time.time()-start_time, pn, "received\n")
                if pn != ack:
                    #print("dupAck ", ack)
                    sendAck = receiverSocket.sendto(str(ack).encode(), senderAddr)
                    writeAck(receiving_log, time.time()-start_time, ack, "sent\n")
                    temp = data
                else:
                    ack = ack+1
                    sendAck = receiverSocket.sendto(str(ack-1).encode(), senderAddr)
                    writeAck(receiving_log, time.time()-start_time, ack-1, "sent\n")
                    dst.write(data)
                 
            else:
                print("finish!")
                send_logfile = open(send_log, 'r')
                buf = send_logfile.readline()
                while buf:
                    if "Throughput" in buf:
                        print(buf)
                        receiving_log.write("File transfer is finished.\n")
                        receiving_log.write(buf)
                        break
                    buf = send_logfile.readline()

                dst.close()
                receiverSocket.close()
                return
                
    #receiverSocket.close()


if __name__=='__main__':
    fileReceiver()
