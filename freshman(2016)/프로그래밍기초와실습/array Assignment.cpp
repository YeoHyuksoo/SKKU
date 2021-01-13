#include <stdio.h>
#include <stdlib.h>

int size,count=0;
int *arr,*arrcpy;
int i,element,index;

void add(void);
void del(void);
void grow(void);
void shrink(void);
void print(void);
void insert(void);
void unique(void);

int main(void){
	char choice; 
	printf("Insert size of array : ");
	scanf("%d",&size);
	getchar();
	arr=(int*)malloc((size)*sizeof(int));
	while(1){
		print();
		printf("Prompt > ");
		scanf("%c",&choice);
		getchar();
		if(choice=='a'){
			scanf("%d",&element);
			getchar();
			add();
		}
		else if(choice=='d'){
			scanf("%d",&element);
			getchar();
			del();
		}
		else if(choice=='i'){
			scanf("%d",&index);
			getchar();
			scanf("%d",&element);
			getchar();
			insert();
		}
		else if(choice=='u')unique();
		else printf("Error! Your order is not in my program.");
	}
}

void add(void){ 
	if(count==size)grow();
	arr[count]=element;
	count++;
}


void del(void){
	if(count==0)printf("There is no numbers anymore.");
	else{
		for(i=0;i<count;i++){
			if(arr[i]==element)break;
		}
		if(i==count)printf("ERROR: %d is not found in the array",element);		
		else {
			for(;i<size-1;i++)arr[i]=arr[i+1];
			count--;
			if(count!=0){
				while(size*0.3>count && size>=10)shrink();
			}
		}
	}
}
void grow(void){
	free(arrcpy); 
	arrcpy=(int*)malloc((size)*sizeof(int));
	for(i=0;i<count;i++)arrcpy[i]=arr[i];
	free(arr);
	size=size*2;
	arr=(int*)malloc((size)*sizeof(int));
	for(i=0;i<count;i++)arr[i]=arrcpy[i];
}

void shrink(void){//내용물이 용량의 30프로 미만일때 호출
	if(size>5){
		free(arrcpy);
		arrcpy=(int*)malloc((size)*sizeof(int));
		for(i=0;i<count;i++)arrcpy[i]=arr[i];
		free(arr);
		size=size*0.5;
		arr=(int*)malloc((size)*sizeof(int));
		for(i=0;i<count;i++)arr[i]=arrcpy[i];
	}
}

void print(void){
	printf("--------------------\n");
	printf("Size of array = %d\n",size);
	printf("Elements of array = [");
	for(i=0;i<count;i++)printf("%d ",arr[i]);
	printf("]\n--------------------\n");
	printf("a:add / d:delete / i:insert / u: unique\n");
}

void insert(void){
	if(count==size)grow();
	for(i=(count-1);i>=index;i--)arr[i+1]=arr[i];
	arr[index]=element;
	count++;
}

void unique(void){
	int j,k,temp,rdd=0;
	for(i=1;i<count;i++){
		k=i;
		for(j=0;j<k;j++){
			if(arr[k]==arr[j]){
				for(;k<(count-1);k++)arr[k]=arr[k+1];
				rdd=1;
			}
			if(rdd==1){
				rdd=0;
				count--;
				j=k-1;
				i--;
				temp=i;
				i=temp;
			}
		}
	}
	while(size*0.3>count)shrink();
}
