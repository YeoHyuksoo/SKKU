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
				swap=1;//�ּڰ� min�� �ֱ�, temp �ּڰ� ���� ����Ű�� �ִ�. p�� �ٲ��� �ʴ´�. 
			}
		}
		if(swap==1){
			//�ּڰ��� ù ���� �ƴ� �� 
			if(temp->next==NULL){
				//�ּڰ� ã���� ������ ��° ���ڶ��
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
				}//�ּڰ� ��ġ ã�� 
				temp->next=p;
				if(count==1)first=temp;
				else if(count==2)first->next=temp;
				else if(count==3)first->next->next=temp;
			}	
		}//p�� ���� ������ �ڵ����� �Ű�����. 
		else p=p->next;//�ּڰ��� ù ���� ���̹Ƿ� p�� ���� ������ �Ű��ش�.
	}
	free(cpyp);
}
