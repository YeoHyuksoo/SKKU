#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(void){
	int mat[100][100]={0};
	int i,j,n,x,y;
	scanf("%d",&n);
	while(1){
		printf("숫자를 입력하세요");
		scanf("%d",&x);
		scanf("%d",&y);
		mat[y-1][x-1]=1;
		if(y<0 || x<0 || y>n || x>n){
			break;
			}for(i=0;i<n;i++){
		for(j=0;j<n;j++){
			printf("%d",mat[i][j]);
		}
	printf("\n");
	}
	}
return 0;
}
