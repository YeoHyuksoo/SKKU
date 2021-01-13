#include <stdio.h>
#include <stdlib.h>

typedef struct node node;
struct node{
	int val;
	node *next;
};
node *head=NULL;
node *new_node=NULL;

int a[5][5]={{0,0,0,0,20},{10,0,0,15,0},{0,10,10,0,0},{0,0,20,0,0},{0,30,0,10,0}};
int pop(void);
void push(int x);
void show(void);
void print(void);
int count=0;
int tempvertex=0;

int main(void){
	int found=0,cnt=0,weight,path[5];
	int startvertex,endvertex,i,k=0,pw=0;
	show();
	printf("My top is left side of my stack!!!\n");
	
	printf("Put your startvertex. ");
	scanf("%d",&startvertex);
	getchar();
	printf("Put your endvertex. ");
	scanf("%d",&endvertex);
	push(startvertex);
	while(count!=0 && found==0){
		print();
		tempvertex=pop();
		printf("tempvertex is %d. ",tempvertex);
		if(tempvertex==endvertex){
			print();
			path[k]=endvertex;
			path[k+1]=0;
			k++;
			found=1;
		}
		else if(a[tempvertex-1][tempvertex-1]==0){
			cnt=0;
			for(i=0;i<5;i++){
				if(a[tempvertex-1][i]!=0){
					cnt++;
					push(i+1);
					path[k]=tempvertex;
				}
			}
			if(cnt==0)k--;
			k++;
			a[tempvertex-1][tempvertex-1]=1;
		}
	}
	if(found==1){
		printf("\nPath ");
		for(i=0;i<k;i++){
			printf("->%d ",path[i]);
			pw+=a[path[i]-1][path[i+1]-1];
		}
		printf("Path has been printed. ");
		printf("Path weight is %d",pw);
	}
	else printf("Path does not exist.");
	return 0;
}

void show(void){
	printf("//(1,1)->(5,20)\n");
	printf("//(2,2)->(1,10)->(4,15)\n");
	printf("//(3,2)->(3,10)->(2,10)\n");
	printf("//(4,1)->(3,20)\n");
	printf("//(5,2)->(4,10)->(2,30)\n");
}

void push(int x){
				new_node=(node *)malloc(sizeof(node));
                new_node->val=x;
                new_node->next=head;
                head=new_node;
                count++;
                printf("%d is pushed. ",x);
                
}

int pop(void){
		int temp;
		if(head==NULL){
			printf("Warning: Nothing to be popped from the stack\n");
		}
		else {
			temp=head->val;
			head=head->next;
			printf("%d is popped. ",temp);
		}
		count--;
		return temp;
}

void print(void){
	printf("t(");
	node *rd=NULL;
    rd=(node *)malloc(sizeof(node));
    for(rd=head;rd!=NULL;rd=rd->next){
        printf("%d ",rd->val);
    }
    printf(")->");
}
