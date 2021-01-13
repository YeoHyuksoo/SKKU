#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <windows.h>
#define PROB 0.3	//0.3 probability
int main(void)
{
	char a[50][50];
	float tmp_rand;
	int i,j,m=0,x,y,k=0;
	int count=0;
	int mine=0;
	int squ,num;
	srand((unsigned)time(NULL));
	
	printf("가로 세로 몇?");
	scanf("%d",&num);
	
	for(i=0;i<num;i++)
	{
		for(j=0;j<num;j++)
		{
			tmp_rand = (float)rand()/(float)RAND_MAX;
			if(tmp_rand > PROB)
			{
				a[i][j]='*';
			}
			else
			{
				a[i][j]='X';
			}
		}
	}
		for(i=0;i<num;i++){
			for(j=0;j<num;j++){
				printf("%c",a[i][j]);
			}
			printf("\n");
		}
		for(i=0;i<num;i++){
			for(j=0;j<num;j++){
				if(a[i][j]=='X')mine++;
			}
		}
	squ=num*num;
	while(1){
		scanf("%d",&x);
		scanf("%d",&y);
		if(a[x-1][y-1]=='*'){
			a[x-1][y-1]='0';
				if(x-2>=0 && y-2>=0 && x-2<num && y-2<num){
					if(a[x-2][y-2]=='X')a[x-1][y-1]++;
				}
				if(x-2>=0 && y-1>=0 && x-2<num && y-1<num){
					if(a[x-2][y-1]=='X')a[x-1][y-1]++;
				}
				if(x-2>=0 && y>=0 && x-2<num && y<num){
					if(a[x-2][y]=='X')a[x-1][y-1]++;
				}
				if(x-1>=0 && y-2>=0 && x-1<num && y-2<num){
					if(a[x-1][y-2]=='X')a[x-1][y-1]++;
				}
				if(x-1>=0 && y>=0 && x-1<num && y<num){
					if(a[x-1][y]=='X')a[x-1][y-1]++;
				}
				if(x>=0 && y-2>=0 && x<num && y-2<num){
					if(a[x][y-2]=='X')a[x-1][y-1]++;
				}
				if(x>=0 && y-1>=0 && x<num && y-1<num){
					if(a[x][y-1]=='X')a[x-1][y-1]++;
				}
				if(x>=0 && y>=0 && x<num && y<num){
					if(a[x][y]=='X')a[x-1][y-1]++;
				}
				if(x-2>=0 && y-1>=0 && x-2<num && y-1<num && a[x-2][y-1]!='X'){
					x--;
					if(x-2>=0 && y-2>=0 && x-2<num && y-2<num){
						if(a[x-2][y-2]=='X')m++;
					}
					if(x-2>=0 && y-1>=0 && x-2<num && y-1<num){
						if(a[x-2][y-1]=='X')m++;
					}
					if(x-2>=0 && y>=0 && x-2<num && y<num){
						if(a[x-2][y]=='X')m++;
					}
					if(x-1>=0 && y-2>=0 && x-1<num && y-2<num){
						if(a[x-1][y-2]=='X')m++;
					}
					if(x-1>=0 && y>=0 && x-1<num && y<num){
						if(a[x-1][y]=='X')m++;
					}
					if(x>=0 && y-2>=0 && x<num && y-2<num){
						if(a[x][y-2]=='X')m++;
					}
					if(x>=0 && y-1>=0 && x<num && y-1<num){
						if(a[x][y-1]=='X')m++;
					}
					if(x>=0 && y>=0 && x<num && y<num){
						if(a[x][y]=='X')m++;
					}
					if(m==0)a[x-1][y-1]='0';
				m=0;
				x++;
				}
				if(x-1>=0 && y-2>=0 && x-1<num && y-2<num && a[x-1][y-2]!='X'){
					y--;
					if(x-2>=0 && y-2>=0 && x-2<num && y-2<num){
						if(a[x-2][y-2]=='X')m++;
					}
					if(x-2>=0 && y-1>=0 && x-2<num && y-1<num){
						if(a[x-2][y-1]=='X')m++;
					}
					if(x-2>=0 && y>=0 && x-2<num && y<num){
						if(a[x-2][y]=='X')m++;
					}
					if(x-1>=0 && y-2>=0 && x-1<num && y-2<num){	
						if(a[x-1][y-2]=='X')m++;
					}
					if(x-1>=0 && y>=0 && x-1<num && y<num){
						if(a[x-1][y]=='X')m++;
					}
					if(x>=0 && y-2>=0 && x<num && y-2<num){
						if(a[x][y-2]=='X')m++;
					}
					if(x>=0 && y-1>=0 && x<num && y-1<num){
						if(a[x][y-1]=='X')m++;
					}
					if(x>=0 && y>=0 && x<num && y<num){
						if(a[x][y]=='X')m++;
					}
					if(m==0)a[x-1][y-1]='0';
				m=0;
				y++;
				}
				if(x-1>=0 && y>=0 && x-1<num && y<num && a[x-1][y]!='X'){
					y++;
					if(x-2>=0 && y-2>=0 && x-2<num && y-2<num){
						if(a[x-2][y-2]=='X')m++;
					}
					if(x-2>=0 && y-1>=0 && x-2<num && y-1<num){		
						if(a[x-2][y-1]=='X')m++;
					}
					if(x-2>=0 && y>=0 && x-2<num && y<num){
						if(a[x-2][y]=='X')m++;
					}
					if(x-1>=0 && y-2>=0 && x-1<num && y-2<num){
						if(a[x-1][y-2]=='X')m++;
					}
					if(x-1>=0 && y>=0 && x-1<num && y<num){
						if(a[x-1][y]=='X')m++;
					}
					if(x>=0 && y-2>=0 && x<num && y-2<num){
						if(a[x][y-2]=='X')m++;
					}
					if(x>=0 && y-1>=0 && x<num && y-1<num){
						if(a[x][y-1]=='X')m++;
					}
					if(x>=0 && y>=0 && x<num && y<num){
						if(a[x][y]=='X')m++;
					}
					if(m==0)a[x-1][y-1]='0';
				m=0;
				y--;
				}
				if(x>=0 && y-1>=0 && x<num && y-1<num && a[x][y-1]!='X'){
					x++;
					if(x-2>=0 && y-2>=0 && x-2<num && y-2<num){
						if(a[x-2][y-2]=='X')m++;
					}
					if(x-2>=0 && y-1>=0 && x-2<num && y-1<num){		
						if(a[x-2][y-1]=='X')m++;
					}
					if(x-2>=0 && y>=0 && x-2<num && y<num){
						if(a[x-2][y]=='X')m++;
					}
					if(x-1>=0 && y-2>=0 && x-1<num && y-2<num){
						if(a[x-1][y-2]=='X')m++;
					}
					if(x-1>=0 && y>=0 && x-1<num && y<num){
						if(a[x-1][y]=='X')m++;
					}
					if(x>=0 && y-2>=0 && x<num && y-2<num){
						if(a[x][y-2]=='X')m++;
					}
					if(x>=0 && y-1>=0 && x<num && y-1<num){
						if(a[x][y-1]=='X')m++;
					}
					if(x>=0 && y>=0 && x<num && y<num){
						if(a[x][y]=='X')m++;
					}
					if(m==0)a[x-1][y-1]='0';		
				m=0;
				x--;
				}
			k=0;
			for(i=0;i<num;i++){
				for(j=0;j<num;j++){
					if(a[i][j]=='X'){
						printf("*");
					}
					else if (a[i][j]=='*')printf("%c",a[i][j]);
					else{
						printf("%c",a[i][j]);
						k++;
					}
				}
				printf("\n");
			}
			
			if(k==squ-mine){
				printf("모든 지뢰를 찾으셨네요~ 축하합니다!!\n");
				break;
			}
		}
		else{
			printf("지뢰를 밟으셨네요! 다시 도전해보세요!\n");
			break;
		}
	}
	Sleep(1500);
	system("cls");
		for(i=0;i<num;i++){
			for(j=0;j<num;j++){
				printf("%c",a[i][j]);
			}
			printf("\n");
		}
	return 0;
}
