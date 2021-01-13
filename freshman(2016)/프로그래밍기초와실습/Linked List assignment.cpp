#include <stdio.h>
#include <stdlib.h>

typedef struct node{
	unsigned int val;
	struct node *next;
}node;

void create(int num);
void sort(void);

int num;
int count;
node *new_node=NULL;
node *first=NULL;
node *p=NULL;

int main(void){
	printf("> ");
	p=(node *)malloc(sizeof(node));
	for(count=0;count<5;count++){
		scanf("%d",&num);
		create(num);
		getchar();
	}
	p->next=NULL;
	printf("--------------------\n");
	printf("Before sorting, list = [");
	p=(node *)malloc(sizeof(node));
	count=0;
	for(p=first;count<5;p=p->next){
		printf("%d ",p->val);
		count++;
	}
	printf("]\n");
	printf("After sorting, list = [");
	count=0;
	sort();
	count=0;
	for(p=first;count<5;p=p->next){
		printf("%d ",p->val);
		count++;
	}
	printf("]\n");
	printf("--------------------\n");
	//return 0;
	free(first);
	free(new_node);
	free(p);
	return 0;
}

void create(int num){
	if(count==0){
		new_node=(node *)malloc(sizeof(node));
		first=(node *)malloc(sizeof(node));
		new_node->val=num;
		first=new_node;
		p=first;
	}
	else{
		new_node=(node *)malloc(sizeof(node));
		p->next=new_node;
		new_node->val=num;
		new_node->next=NULL;
		p=p->next;
	}
}

void sort(void){
	int min,swap;
	node *temp=NULL;
	node *cpyp=NULL;
	cpyp=(node *)malloc(sizeof(node));
	p=first;
	while(p->next!=NULL){
		count++; 
		swap=0;
		min=p->val;
		for(cpyp=p->next;cpyp!=NULL;cpyp=cpyp->next){
			if(cpyp->val<min){
				min=cpyp->val;
				temp=cpyp;
				swap=1;//최솟값 min에 넣기, temp 최솟값 방을 가리키고 있다. p는 바뀌지 않는다. 
			}
		}
		if(swap==1){
			//최솟값이 첫 값은 아닐 떄 
			if(temp->next==NULL){
				//최솟값 찾은게 마지막 번째 숫자라면
				temp->next=p;
				if(count==1)first=temp;
				else if(count==2)first->next=temp;
				else if(count==3)first->next->next=temp;
				else if(count==4)first->next->next->next=temp;
				first->next->next->next->next->next=NULL;
			}
			else {
				for(cpyp=p;cpyp!=NULL;cpyp=cpyp->next){
					if(cpyp->next->val==min){
						cpyp->next=temp->next;
						break; 
					}
				}//최솟값 위치 찾기 
				temp->next=p;
				if(count==1)first=temp;
				else if(count==2)first->next=temp;
				else if(count==3)first->next->next=temp;
			}	
		}//p가 다음 값으로 자동으로 옮겨진다. 
		else p=p->next;//최솟값이 첫 값일 때이므로 p를 다음 값으로 옮겨준다.
	}
	free(cpyp);
}
