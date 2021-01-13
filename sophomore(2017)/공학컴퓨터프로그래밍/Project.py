#다음은 KINGO Navigation 코드입니다.
import turtle
import math
import time
import sys

screen=turtle.Screen()
screen.setup(1000,1000)
screen.bgpic("map.jpg")

connect=[[0 for x in range (300)] for y in range (300)]
map=[]
path=[]
v=[int(0)]*300

def ask():
    print()
    print("1. 길 찾기")
    print("2. ATM 찾기")
    print("3. 교내 식당 찾기")
    print("4. 카페 찾기")
    print("5. 매점 찾기")
    print("6. 흡연장소 찾기")
    print()
    selection=int(input("실행할 서비스를 선택하세요.(1~6): "))
    while selection<1 or selection>6:
        selection=int(input("잘못 입력하셨습니다. 다시 입력해 주세요.(1~6): "))
    print()
    return selection

def information(temp):
    distance=float(0)
    for i in range(temp-1):
        distance=distance+math.sqrt(math.pow(map[path[i]][0]-map[path[i+1]][0],2)+math.pow(map[path[i]][1]-map[path[i+1]][1],2))# 거리 계산
    distance*=0.987
    walking_time=int(distance/60) # 시간
    print("거리는 약", int(distance),"m 입니다.")
    print("시간은 도보로 대략", walking_time,"~",walking_time+1,"분 걸립니다.")

def find_way(start,finish):# 1
    inf=float(10000000000)
    dist=[inf]*300
    check=[0]*300
    dist[start]=0
    v[start]=-1
    m=start# m은 시작지점
    temp=0
    for k in range (152): #Dijkstra Algorithm
        min=inf
        for i in range (1,153):
            if check[i]==0:
                if connect[m][i]==1:#만약 인접해 있다면
                    if dist[i]>dist[m]+math.sqrt(math.pow(map[i][0]-map[m][0],2)+math.pow(map[i][1]-map[m][1],2)):#x좌표 차이 제곱+y좌표 차이 제곱 에 제곱근 : 거리
                        dist[i]=dist[m]+math.sqrt(math.pow(map[i][0]-map[m][0],2)+math.pow(map[i][1]-map[m][1],2))# dist[i]값을 더 짧은 값으로 변경해준다.
                        v[i]=m # v 일차원 배열에 인접한 지점들이 인덱스가 되는 배열값에 m값을 넣어준다.

        for i in range (1,153):
            if check[i]==0:
                if min>dist[i]:
                    min=dist[i]
                    m=i
        check[m]=1# 거리가 짧은 것 부터 경로를 더 써나가기 시작한다.

    k=finish# 도착 지점이 k에 들어간다
    while k!=-1:
        path.append(k)# 경로에 추가
        k=v[k]# 전 경로를 추적한다.
        temp=temp+1
    print()
    information(temp)
    turtle.goto(map[start][0],map[start][1])
    turtle.pendown()
    turtle.pensize(5)
    turtle.pencolor('blue')
    
    for i in range(temp-1,-1,-1):
        turtle.goto(map[path[i]][0],map[path[i]][1])
        turtle.speed(3)
        time.sleep(0.25)
    print()
    print("10초 후 종료됩니다...")
    time.sleep(10)

def way(a):
    num=int(input('출발장소의 위치번호를 입력하세요 (1~152): '))
    while num<1 or num>152:
        print('잘못된 위치번호입니다.')
        num=int(input('위치번호를 다시 입력하세요 (1~152): '))
    close(num,a)

def ways():
    num=int(input('출발장소의 위치번호를 입력하세요 (1~152): '))
    while num<1 or num>152:
        print('잘못된 위치번호입니다.')
        num=int(input('위치번호를 다시 입력하세요 (1~152): '))
    nums=int(input('도착장소의 위치번호를 입력하세요 (1~152): '))
    while nums<1 or nums>152:
        print('잘못된 위치번호입니다.')
        nums=int(input('도착 위치번호를 다시 입력하세요 (1~152): '))
    find_way(num,nums)

def close(start,selection):# 2~6

    if selection==2:
        print()
        print("ATM 기기 찾기")
        end={'ATM':['2','6','32','44','67','83','76','87','105','117']}
        many=10
    elif selection==3:
        print()
        print("식당 찾기")
        end={'restaurant':['6','32','44','117','129','134','105']}
        many=7
    elif selection==4:
        print()
        print("카페 찾기")
        end={'cafe':['127','86','3','134']}
        many=4
    elif selection==5:
        print()
        print("매점 찾기")
        end={'PX':['6','35','105','106','136','117']}
        many=6
    elif selection==6:
        print()
        print("흡연장소 찾기")
        end={'smoke':['14','99','6','108','75','141','114']}
        many=7

    inf=float(10000000000)
    dist=[inf]*300
    check=[0]*300
    dist[start]=0
    v[start]=-1
    m=start
    
    for k in range (300):
        min=inf

        for i in range (1,300):
            if check[i]==0:
                if connect[m][i]==1:
                    if dist[i]>dist[m]+math.sqrt(math.pow(map[i][0]-map[m][0],2)+math.pow(map[i][1]-map[m][1],2)):
                        dist[i]=dist[m]+math.sqrt(math.pow(map[i][0]-map[m][0],2)+math.pow(map[i][1]-map[m][1],2))
                        v[i]=m

        for i in range (1,300):
            if check[i]==0:
                if min>dist[i]:
                    min=dist[i]
                    m=i

        check[m]=1

    finish=0
    M=float(10000000000)
    for i in end.values():
        for j in range(0,len(i),1):
            if dist[int(i[j])]<M:
                M=dist[int(i[j])]
                finish=int(i[j]) # 가장가까운 좌표찾기 M: 최단거리

    find_way(start,finish)


map.append([])
map[0].append(int(0))
map[0].append(int(0))

f1=open("position.txt",'r')
place=int(0)
for i in range(1,300):
    map.append([])
    line=f1.readline().split()
    temps=0
    for char in line:
        map[i].append(int(char))
        temps=temps+1
print(map)
print(temps)
#map은 이차원배열로써 안내가능한 지점들의 위치정보를 담고 있다.

arr=[0 for x in range(2)]
f2=open("connection.txt",'r')
for i in range(0,300):
    line=f2.readline().split()
    temps=0
    for char in line:
        arr[temps]=int(char)
        temps=temps+1
    connect[arr[0]][arr[1]]=1
    connect[arr[1]][arr[0]]=1
#connect라는 이차원배열에 행렬형식으로 두 지점이 인접해있으면 1로, 아니면 0으로 값을 설정한다.

turtle.penup()

info=[[0 for x in range (300)]for y in range (300)]
num=[0 for x in range (300)]

selection=ask()
#실행할 서비스의 번호

print("다음은 장소의 위치번호입니다.")
print("Loading... ( 지도상 정점 찍는중 )")
print("Starting [                    ]",'\b'*22,end='')
sys.stdout.flush()#print의 변화를 바로바로 exe화면에 출력하는 코드
for i in range (1,153):
    turtle.speed(0)
    turtle.goto(map[i][0],map[i][1])
    turtle.dot('5',"red")
    turtle.write(i)
    if i%8==0:
        print('.',end='')
        sys.stdout.flush()
print('] Done')

if selection==1:
    ways()
elif selection<=6:
    way(selection)
