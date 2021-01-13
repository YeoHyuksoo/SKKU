#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int block_length=0;
int wall_length=0;
char* block;
char* wall;
int answer_num=0;
int answer_height=0;

void calculator(){
	int i,j,tmp;
	char table[202][1001];
	/*char **table;
	table=(char **)calloc(202, sizeof(char *));
	for(i=0;i<202;i++){
		table[i]=(char *)calloc(wall_length+2, sizeof(char));
	}*/
	int floor=100, min=101, max=100;
	char *log;
	int lcnt=1;
	for(i=0;i<wall_length;i++){
		if(wall[i]==block[0] || wall[i]==block[block_length-1]){
			answer_num++;
		}
	}
	log=(char *)calloc(answer_num+2, sizeof(char));
	answer_num--;
	if(wall_length==1){
		answer_num++;
	}
	for(i=0;i<wall_length;i++){
		if(wall[i]==block[0]){
			if(log[lcnt-1]==block[block_length-1]){//finish->start
				//떨어져서 나오는 경우만 존재
				for(j=0;j<block_length;j++){
					if(block[j]==wall[i-1]){
						break;
					}
				}
				floor--;
				tmp=i-1-j;
				while(table[floor][tmp]!='\0'){
					floor--;
				}
				if(min>floor){
					min=floor;
				}
				memcpy(&table[floor][i-1-j], block, block_length);
				
				floor++;
				memcpy(&table[floor][i], block, block_length);
				log[lcnt++]=block[0];
			}
			else{//start->start or just start
				floor++;
				if(max<floor){
					max=floor;
				}
				memcpy(&table[floor][i], block, block_length);
				log[lcnt++]=block[0];
			}
		}
		else if(wall[i]==block[block_length-1]){
			if(log[lcnt-1]==block[0]){//start->finish
				log[lcnt++]=block[block_length-1];
			}
			else{
				floor--;
				tmp=i-block_length+1;
				while(table[floor][tmp]!='\0'){
					floor--;
				}
				if(min>floor){
					min=floor;
				}
				memcpy(&table[floor][i-block_length+1], block, block_length);
				log[lcnt++]=block[block_length-1];
			}
		}
		while(wall[i+1]!=block[0] && wall[i+1]!=block[block_length-1]){
			i++;
		}
	}
	answer_height=max-min+1;
	/*for(i=0;i<202;i++){
		free(table[i]);
	}
	free(table);*/
	free(log);
}

int main(){
	scanf("%d", &block_length);
	scanf("%d", &wall_length);
	block=(char *)malloc(sizeof(char)*block_length+1);
	wall=(char *)malloc(sizeof(char)*wall_length+1);
	scanf("%s", block);
	scanf("%s", wall);
	calculator();
	printf("num: %d\n", answer_num);
	printf("height: %d\n", answer_height);
	return 0;
}
