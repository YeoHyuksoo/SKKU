import sys
import math
from queue import PriorityQueue
import timeit

def astar(parent, obstacle, fn, nextstate, depth):
    global goal, row, col, expand
    visit= [0 for i in range(row*col)]
    visit[nextstate]=1
    queue=PriorityQueue()
    fn[nextstate]=dist(nextstate, goal)
    while True:
        if nextstate-col>=0:
            if nextstate-col not in obstacle:
                if fn[nextstate-col]>depth+dist(nextstate-col, goal):
                    visit[nextstate-col]=1
                    fn[nextstate-col]=depth+dist(nextstate-col, goal)
                    parent[nextstate-col]=nextstate
                    queue.put((fn[nextstate-col], nextstate-col))
            
        if nextstate+col<row*col:
            if nextstate+col not in obstacle:
                if fn[nextstate+col]>depth+dist(nextstate+col, goal):
                    visit[nextstate+col]=1
                    fn[nextstate+col]=depth+dist(nextstate+col, goal)
                    parent[nextstate+col]=nextstate
                    queue.put((fn[nextstate+col], nextstate+col))
            
        if (nextstate-1)%col!=col-1:
            if nextstate-1 not in obstacle:
                if fn[nextstate-1]>depth+dist(nextstate-1, goal):
                    visit[nextstate-1]=1
                    fn[nextstate-1]=depth+dist(nextstate-1, goal)
                    parent[nextstate-1]=nextstate
                    queue.put((fn[nextstate-1], nextstate-1))
            
        if (nextstate+1)%col!=0:
            if nextstate+1 not in obstacle:
                if fn[nextstate+1]>depth+dist(nextstate+1, goal):
                    visit[nextstate+1]=1
                    fn[nextstate+1]=depth+dist(nextstate+1, goal)
                    parent[nextstate+1]=nextstate
                    queue.put((fn[nextstate+1], nextstate+1))

        nextstate=queue.get()[1]
        if nextstate==goal:
            expand=sum(visit)
            return
        else:
            depth+=1

def dist(a, b):
    global row, col
    x=abs(int(a/col)-int(b/col))
    y=abs(int(a%col)-int(b%col))
    return x+y

file_path=sys.argv[len(sys.argv)-1]

if len(sys.argv) != 2:
    file_path=input("please input file name.")

file=open(file_path, 'r')

file.readline()
size = file.readline()

global row, col
size = size.split(" ")
row=int(size[0])
col=int(size[1])

init=file.readline()
ix=int(init[1])
iy=int(init[3])

global goal
goal=file.readline()
gx=int(goal[1])
gy=int(goal[3])
goal=gx*col+gy

line=file.readline()
while line!="END_WORLD\n":
    line=file.readline()

while line!="BEGIN_OBSTACLES\n":
    line=file.readline()
    
obstacle=[]
line=file.readline()
while line!="END_OBSTACLES":
    obstacle.append(int(line[1])*col+int(line[3]))
    line=file.readline()
nobs=len(obstacle)

start = timeit.default_timer()
queue= []
queue.append(ix*col+iy)
visit= [0 for i in range(row*col)]
parent= [-1 for i in range(row*col)]
while True:
    node=queue.pop(0)
    if node==goal:
        break
    if visit[node]==1:
        continue
    visit[node]=1
    if node-col>=0:
        if node-col not in obstacle and visit[node-col]==0:
            queue.append(node-col)
            parent[node-col]=node
            
    if node+col<row*col:
        if node+col not in obstacle and visit[node+col]==0:
            queue.append(node+col)
            parent[node+col]=node
            
    if (node-1)%col!=col-1:
        if node-1 not in obstacle and visit[node-1]==0:
            queue.append(node-1)
            parent[node-1]=node
            
    if (node+1)%col!=0:
        if node+1 not in obstacle and visit[node+1]==0:
            queue.append(node+1)
            parent[node+1]=node

bfsvisit=sum(visit)
path=[]
node=goal
path.append(goal)
while parent[node]!=-1:
    path.append(parent[node])
    node=parent[node]
bfslen=len(path)
path.reverse()
bfstime=timeit.default_timer()-start
print(bfstime)
px=[]
py=[]
for node in path:
    px.append(int(node/col))
    py.append(node%col)

node=ix*col+iy
global expand
expand=1
start = timeit.default_timer()-start
fn=[200 for i in range(row*col)]
parent=[-1 for i in range(row*col)]
astar(parent, obstacle, fn, node, 1)
astarvisit=expand
path=[]
node=goal
path.append(goal)
while parent[node]!=-1:
    path.append(parent[node])
    node=parent[node]
astarlen=len(path)
path.reverse()
astartime=timeit.default_timer()-start

print("Robot World File: {0}".format(file_path))
print("Room Size: {0} x {1}".format(row, col))
print("Number of Obstacles: {0}".format(nobs))
print("Robot Initial Location: ({0},{1})".format(ix, iy))
print("Robot Goal Location: ({0},{1})".format(gx, gy))
print()

print("Search Method: Breadth First Search")
print("Nodes Explored: {0}".format(bfsvisit))
print("Solution Length: {0}".format(bfslen))
print("Solution Path:", end=' ')
for i in range(0, len(px), 1):
    print("({0}, {1})".format(px[i], py[i]), end=' ')
print()
print("Solution Time: %.4f" % (bfstime))
print()

print("Search Method: A Star Search")
print("Nodes Explored: {0}".format(astarvisit))
print("Solution Length: {0}".format(astarlen))
print("Solution Path:", end=' ')
px=[]
py=[]
for node in path:
    px.append(int(node/col))
    py.append(node%col)
for i in range(0, len(px), 1):
    print("({0}, {1})".format(px[i], py[i]), end=' ')
print()
print("Solution Time: %.4f" % (astartime))

file.close()
