import random

rank_code=['a',2,3,4,5,6,7,8,9,'t','j','q','k']
suit_code=['c','d','h','s']
score_board=[11,2,3,4,5,6,7,8,9,10,10,10,10] #ace가 11점일 때와 1점일 때를 예외로 두고 다른 카드는 숫자별로 점
name=[]
win=[]
draw=[]
lose=[]
win.append(0)
draw.append(0)
lose.append(0)
n=0
flag=0
sumOfCards = [0, 0] # [ dealer's sum, player's sum ]
count_ace = [0, 0]  # [ count of dealer's ace, count of player's ace ]
DEALER = 0          # dealer's number is 0
PLAYER = 1          # player's number is 1 
deck = list()
current_deck_number = 0

# 게임 방법 출력 함수
def print_man(): 
    print("Blackjack Instruction\n\nInitial condition: There are 52 cards in the deck, and a dealer and a player have 100 chips each. Face cards such as kings, queens and jacks re 10 points, and all other cards are counted as the numeric value shown. For exception, ace cards can be counted as 1 point or 11points based on the need.\n\n")
    print("Betting Rule: The player can bet either before the game starts or after taking the first two cards. If the player wins due to \"blackjack\", he or she takes as twice as his or her betting. The game continues until someone is out of betting points.\n\n")
    print("Basic Rules: The player can win against the dealer by getting 21 points on the player's first two cards which is blackjack, reaching a final score higher than the dealer without exceeding 21, letting the dealer draw additional cards until his or her score is over 21.\n\n")
    print("Game Rules: When the game starts the dealer takes one card and the player takes two cards. The player should choose hit, to continue to take a card or stay to stip taking a card. As soon as the player stays, dealer continues to take a card when the score is under 17, and otherwise stop taking a card.\n\n")


# 게임할 카드들(deck)를 중복되지 않게 뒤섞는 함수 
def shuffle_cards():


    global deck;
    global current_deck_number;
    
    for i in range(52):
        deck.append(i)
    random.shuffle(deck)
    current_deck_number = 0 

    print(deck) # 디버깅용: 나중에 지운다!!!!
    
    return
              

# deck 으로 부터 카드(card number)를 받는 함수   
def draw_card():
    global deck;
    global current_deck_number;
    global sumOfCards
    global sount_ace

    if (current_deck_number == 52): # 카드가 다 소모되면 다시 전체 카드를 뒤섞는다. 
        shuffle_cards()
        current_deck_number = 0
    
    cardnum = deck[current_deck_number]
    current_deck_number += 1
    #print(cardnum) #디버깅용 제거!!!
    
    return cardnum 
                        

# dealer, player 의 현재까지 점수를 구하는 함수 
def calculate_sum(turn, cardnum):

    global sumOfCards
    global sount_ace

    if cardnum%13==0: # ace 
        count_ace[turn] += 1
    sumOfCards[turn] += score_board[cardnum%13]

    if sumOfCards[turn] > 21 and count_ace[turn] >= 1:
        count_ace[turn] -= 1
        sumOfCards[turn] -= 10


# 카드 번호를 받아 출력하는 함수 --> 터틀 사용하면 변경해야!!! 
def print_card(cardnum):
    
    suit=int(cardnum/13)
    rank=int(cardnum%13)

    print("\t..........\n")
    print("\t|",rank_code[rank],"     |\n")

    if(suit==0):
        print("\t|   ♣   |\n")
        
    elif(suit==1):
        print("\t|   ♦    |\n")
   
    elif(suit==2):
        print("\t|   ♥   |\n")
    
    elif(suit==3):
        print("\t|   ♠   |\n")
    

    print("\t|     ",rank_code[rank],"|")
    print("\t''''''''''\n")
    

# 플레이어가 원하면(hit) 계속 카드를 받고, 중단하면(stay) 딜러가 진행하고 결과를
# 승부의 결과를 화면에 출력하는 함수 
def ask_decision(hidden_cardnum):
    global deck;
    global current_deck_number;
    global sumOfCards
    global sount_ace
    global flag

    # 플레이어가 블랙잭일때 
    if sumOfCards[PLAYER] == 21:
        if sumOfCards[DEALER] == 21:        # 딜러가 블랙잭이면 비김 
            print("Both blackjack!!! Tie!!!!\n")
            flag=1
        else:
            print_card(hidden_cardnum)  # print dealer's hidden card
            print("Blackjack!!! You won the game! Congratulation!\n")
            flag=0
        return
    else:
        if sumOfCards[DEALER] == 21:        # 딜러가 블랙잭이면 짐 
            print("Blackjack!!! You lost the game!\n")
            flag=2
            return
    
    # player's turn
    stop = False
    while (sumOfCards[PLAYER] < 21 and not stop):
        print("Dealer asks: Hit (h) or Stay (s)?\n\n")
        answer = input()
        while(answer !='s' and answer !='h'):
            print("Wrong input, Enter h to hit and s to stay\n")
            answer = input()
              
        if answer == 'h':
            cardnum = draw_card()
            calculate_sum(PLAYER, cardnum)
            print_card(cardnum)
        else:
            stop = True 
        print(sumOfCards) #디버깅용
        
    # dealer's turn
    print("\n[Dealer's card]\n")
    print_card(hidden_cardnum)  # print dealer's hidden card


    if sumOfCards[PLAYER]>21:
        print ("[Dealer: ",sumOfCards[DEALER]," vs You: ",sumOfCards[PLAYER],"]\nYou lost the game!\n")
        flag=2
        return
    
    while(sumOfCards[DEALER] < 17):
        cardnum = draw_card()
        calculate_sum(DEALER, cardnum)    
        print_card(cardnum)
        print(sumOfCards) #디버깅용
        
    if sumOfCards[DEALER]>21:
        print ("[Dealer: ",sumOfCards[DEALER]," vs You: ",sumOfCards[PLAYER],"]\nYou won the game! Congratulation!\n")
        flag=0
        return

    if sumOfCards[PLAYER] == sumOfCards[DEALER]:   
        print("[Dealer: ",sumOfCards[DEALER]," vs You: ",sumOfCards[PLAYER],"]\nTie\n")
        flag=1
    elif sumOfCards[PLAYER] > sumOfCards[DEALER]:
        print("[Dealer: ",sumOfCards[DEALER]," vs You: ",sumOfCards[PLAYER],"]\nYou won the game! Congratulation!\n")
        flag=0
    else:
        flag=2
        print ("[Dealer: ",sumOfCards[DEALER]," vs You: ",sumOfCards[PLAYER],"]\nYou lost the game!\n")
    return 

            
# 블랙잭 게임 한번 진행하는 함수 
def play_game():
    global deck;
    global current_deck_number;
    global sumOfCards
    global sount_ace
    global n
    global name
    global win
    global draw
    global lose
    #  사용자의 이름을 받는다
    if(n!=0):
        print("같은 이름으로 하실건까요? yes(y) or no(n)")
        y=input()
        if(y=='n'):
            n=n+1
            win.append(0)
            draw.append(0)
            lose.append(0)
            name.append(input("이름을 넣어주세요."))
    else :
        name.append(input("이름을 넣어주세요."))
    # 화면 좀 깨끗이 만들고 싶은뎅 system("clear");같은 함수 없나

    # 딜러가 두카드를 받는다 - 하나는 보여주고 나머지는 덮어둔다 
    cardnum = draw_card()
    calculate_sum(DEALER, cardnum)

    print("\n[Dealer's card]\n")       
    print_card(cardnum)
    
    hidden_cardnum = draw_card()
    calculate_sum(DEALER, hidden_cardnum)

    # 플레이어가 두카드를 받는다 - 모두 보여준다     
    print("\n[Your card]\n")
    cardnum = draw_card()
    calculate_sum(PLAYER, cardnum)
    print_card(cardnum)

    cardnum = draw_card()
    calculate_sum(PLAYER, cardnum)
    print_card(cardnum)
    
    print(sumOfCards) #디버깅용
    
    ask_decision(hidden_cardnum)
    #flag에 따라 결과를 출력한다
    if(flag==0):
        win[n]=win[n]+1
    elif(flag==1):
        draw[n]=draw[n]+1
    elif(flag==2):
        lose[n]=lose[n]+1
    print("User :",name[n])
    print("이긴 판수: ",win[n],"비긴 판수: ",draw[n],"진 판수: ",lose[n])
    print("승률: ",win[n]/(win[n]+draw[n]+lose[n]),"%")            


def main():
    global deck;
    global current_deck_number;
    global sumOfCards
    global sount_ace

    # 블랙잭 게임 방법을 출력한다
    print_man()
    
    # 게임할 카드를 중복되지 않게 뒤섞는다 
    shuffle_cards()

    # player 가 중단할 때까지 게임을 반복한다.        
    while(True):
        x=input("Enter c to continue, or s to stop \n")
        
        sumOfCards=[0, 0]
        count_ace = [0, 0]
        
        if(x=='c' or x=='C'):
            play_game()
        elif(x=='s' or x=='S'):
            break;  
        else:
            print('Wrong input \n')

main()

    
