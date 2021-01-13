from threading import Thread
import time

def work(id, start, end):
    global start_time
    src=open(start, 'rb')
    buf=src.read(10240)
    dest=open(end, 'wb')
    while buf:
        dest.write(buf)
        buf=src.read(10240)

    src.close()
    dest.close()
    logfile.write("%.2f {0} is copied completely\n".format(end) % (time.time()-start_time))
    return

if __name__ == "__main__":
    start_time = time.time()
    logfile=open("log.txt", 'w')
    while True:
        START=input("Input the file name: ")
        if START=="exit":
            break
        END=input("Input the new name: ")
        if END=="exit":
            break
        th = Thread(target=work, args=(1, START, END))
        logfile.write("%.2f Start copying {0} to {1}\n".format(START, END) % (time.time()-start_time))
        th.start()
    logfile.close()
