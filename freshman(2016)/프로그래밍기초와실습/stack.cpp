#include <stdio.h>
#include <stdlib.h>

typedef struct node node;
struct node{
	int value;
	node *next;
};

node *head=NULL;
node *new_node=NULL;
int x;
int n;

void print(void);
void push(int x);
void pop(int n);

int main(void){
	char choice;
	while(1){
		print();
		scanf("%c",&choice);
		getchar();
		if(choice=='p'){
			scanf("%d",&x);
			getchar();
			push(x);
		}
		else if(choice=='o'){
			scanf("%d",&n);
			getchar();
			pop(n);
		}
		else printf("Your order is not in the program.\n");
	}
	
}

void push(int x){
				new_node=(node *)malloc(sizeof(node));
                new_node->value=x;
                new_node->next=head;
                head=new_node;
}

void pop(int n){
	int k;
	for(k=0;k<n;k++){
		if(head==NULL){
			printf("Warning: Nothing to be popped from the stack\n");
			break;
		}
		else {
			printf("%d has been popped from the stack\n",head->value);
			head=head->next;
		}
	}
}

void print(void){
        printf("--------------------\n");
        printf("Stack => ");
        node *rd=NULL;
        rd=(node *)malloc(sizeof(node));
        for(rd=head;rd!=NULL;rd=rd->next){
        	printf("%d ",rd->value);
        }
        printf("]\n");
        printf("--------------------\n");
        printf("(p:push / o:pop)\n");
        printf("> ");
}
