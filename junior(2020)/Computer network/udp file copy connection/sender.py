import sys
import socket
import time
import threading
from struct import *

"Use this method to write Packet log"
def writePkt(logFile, procTime, pktNum, event):
    logFile.write('{:1.3f} pkt: {} | {}'.format(procTime, pktNum, event))

"Use this method to write ACK log"
def writeAck(logFile, procTime, ackNum, event):
    logFile.write('{:1.3f} ACK: {} | {}'.format(procTime, ackNum, event))

"Use this method to write final throughput log"
def writeEnd(logFile, throughput, avgRTT):
    logFile.write('File transfer is finished.\n')
    logFile.write('Throughput : {:.2f} pkts / sec\n'.format(throughput))
    logFile.write('Average RTT : {:.1f} ms\n'.format(avgRTT))

def receiveACK(sock, sending_log, start_time):
    global window
    global retransmitACK
    global rtt_dict
    print("thread start")
    dupAck = -1
    dup = 0
    while True:
        msg, receiverAddr = sock.recvfrom(1400)
        cur_time = time.time()
        writeAck(sending_log, cur_time-start_time, msg.decode(), "received\n")
        rtt_dict[int(msg)] = cur_time-rtt_dict[int(msg)]
        if dupAck==int(msg):
            dup=dup+1
            if dup==3:
                retransmitACK = dupAck+1
                
        else:
            dupAck = int(msg)
            dup=0
        window = window-1


def fileSender():
    print ('sender program starts...')
    receiverIP = recvAddr
    receiverPort = 10080

    sendlog_file = dstFilename+"_sending_log.txt"
    sending_log = open(sendlog_file, 'w')
    senderSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    start_time = time.time()
    senderSocket.sendto(dstFilename.encode(), (receiverIP, receiverPort))
    
    sending_log.write(str('%.3f' % (time.time()-start_time))+" pkt: 0 | sent\n")
    msg, receiverAddr = senderSocket.recvfrom(1400)
    sending_log.write(str('%.3f' % (time.time()-start_time))+" ACK: 0 | received\n")

    src = open(srcFilename, 'rb')
    buf = src.read(1390)
    global window
    global retransmitACK
    window = 0
    retransmitACK = -1
    th = threading.Thread(target=receiveACK, args=(senderSocket, sending_log, start_time,))
    th.start()
    pn = 1
    global rtt_dict
    rtt_dict = {}
    while buf:
        while True:
            if window<windowSize:
                break
        window = window+1
        if retransmitACK != -1:
            print("retransmit of ack ", retransmitACK)
            b = 1390*retransmitACK
            #print(b)
            #src.seek(1390*retransmitACK)
            #buf = src.read(1390)
            pn = retransmitACK
            retransmitACK=-1
        
        form = 'i '+str(len(buf))+'s'
        rtt_dict[pn] = time.time()
        #send(senderSocket, form, pn, buf, receiverIP)
        senderSocket.sendto(pack(form, pn, buf), (receiverIP, receiverPort))
        writePkt(sending_log, time.time()-start_time, pn, "sent\n")
        pn = pn+1
        buf = src.read(1390)
        time.sleep(0.01)

    total_time = time.time()-start_time
    throughput = pn/total_time

    total=0.0
    num=0
    for v in rtt_dict.values():
        if v<2.0:
            total+=v
            num+=1
    
    src.close()
    senderSocket.close()
    th.join()
    writeEnd(sending_log, throughput, total/num*1000)

if __name__=='__main__':
    recvAddr = sys.argv[1]  #receiver IP address
    windowSize = int(sys.argv[2])   #window size
    srcFilename = sys.argv[3]   #source file name
    dstFilename = sys.argv[4]   #result file name
    print("receiver IP address:",recvAddr)
    print("windowSize: ", windowSize)
    print("src filename: ", srcFilename)
    print("dst filename: ", dstFilename)
    fileSender()
