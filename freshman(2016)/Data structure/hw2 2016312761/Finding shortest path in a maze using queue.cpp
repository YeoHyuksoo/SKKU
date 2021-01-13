#include <stdio.h>
#include <stdlib.h>
//The range of maze[n][m] is 2<=n,m<=200.
//Range of the number of warp zones is 2<=k<=10.
//n is 가로, m is 세로.
int main(void){
	char maze[200][200];
	char r;
	int i,j,k=0,n=0,m=0,s,t=0,c=0,tf;
	int rtx[40000],rty[40000],a[40000];
	int ex,ey;
	int warpx=-1,warpy;//means the first warp zone that we accessed.
	int num=0;
	int tracex[40000],tracey[40000];
	int len=0;
	int cnt=0,count=0;
	FILE *fp1,*fp2;
	fp1=fopen("hw2_input.txt","r");
	while(1){
		r=fgetc(fp1);
		if(r!=EOF){
			if(r!=' '){
				if(r=='\n'){
					n++;
					m=0;
				}
				else{
					maze[n][m]=r;
					m++;
				}	
			}
		}
		else break;
	}
	n++;
	fclose(fp1);
	for(i=0;i<n;i++){
		for(j=0;j<m;j++){
			if(maze[i][j]=='e'){
				ex=i;
				ey=j;
			}
			if(maze[i][j]=='s'){
				rtx[0]=i;
				rty[0]=j;
				maze[i][j]=-1;
				cnt++;
			}
		}
	}
	a[0]=1;
	//I used count,cnt,num,k,s,t variables to represent the number of points that you can find the near routes one more time.
	//len is the number of length of route.
	//array a[] represents the number of points that have len1,2,3, and so on.
	while(maze[ex][ey]=='e'){
		s=k;
		len++;
		num=cnt;
		cnt=0;
		for(k=s;k<s+num;k++){
			if((maze[rtx[k]+1][rty[k]]=='s' || maze[rtx[k]+1][rty[k]]=='e' || maze[rtx[k]+1][rty[k]]=='w' || maze[rtx[k]+1][rty[k]]=='0') && rtx[k]+1<=n){
				if(maze[rtx[k]+1][rty[k]]=='w'){
					if(warpx==-1){
					warpx=rtx[k]+1;
					warpy=rty[k];
				}
				for(i=0;i<n;i++){
					for(j=0;j<m;j++){
						if(maze[i][j]=='w'){
							count++;
							maze[i][j]=len;
							rtx[count]=i;
							rty[count]=j;
							cnt++;
						}
					}
				}
			}
			else {
				maze[rtx[k]+1][rty[k]]=len;
				count++;
				rtx[count]=rtx[k]+1;
				rty[count]=rty[k];
				cnt++;
			}
			}
			if((maze[rtx[k]][rty[k]+1]=='s' || maze[rtx[k]][rty[k]+1]=='e' || maze[rtx[k]][rty[k]+1]=='w' || maze[rtx[k]][rty[k]+1]=='0') && rty[k]+1<=m){
				if(maze[rtx[k]][rty[k]+1]=='w'){
					if(warpx==-1){
					warpx=rtx[k];
					warpy=rty[k]+1;
				}
				for(i=0;i<n;i++){
					for(j=0;j<m;j++){
						if(maze[i][j]=='w'){
							count++;
							maze[i][j]=len;
							rtx[count]=i;
							rty[count]=j;
							cnt++;
						}
					}
				}
				}
				else {
					maze[rtx[k]][rty[k]+1]=len;
					count++;
					rtx[count]=rtx[k];
					rty[count]=rty[k]+1;
					cnt++;
				}
			}
			if((maze[rtx[k]-1][rty[k]]=='s' || maze[rtx[k]-1][rty[k]]=='e' || maze[rtx[k]-1][rty[k]]=='w' || maze[rtx[k]-1][rty[k]]=='0') && rtx[k]-1>=0){
				if(maze[rtx[k]-1][rty[k]]=='w'){
					if(warpx==-1){
					warpx=rtx[k]-1;
					warpy=rty[k];
				}
				for(i=0;i<n;i++){
					for(j=0;j<m;j++){
						if(maze[i][j]=='w'){
							count++;
							maze[i][j]=len;
							rtx[count]=i;
							rty[count]=j;
							cnt++;
						}
					}
				}
				}
				else {
					maze[rtx[k]-1][rty[k]]=len;
					count++;
					rtx[count]=rtx[k]-1;
					rty[count]=rty[k];
					cnt++;
				}			
			}
			if((maze[rtx[k]][rty[k]-1]=='s' || maze[rtx[k]][rty[k]-1]=='e' || maze[rtx[k]][rty[k]-1]=='w' || maze[rtx[k]][rty[k]-1]=='0') && rty[k]-1>=0){
				if(maze[rtx[k]][rty[k]-1]=='w'){
					if(warpx==-1){
					warpx=rtx[k];
					warpy=rty[k]-1;
				}
				for(i=0;i<n;i++){
					for(j=0;j<m;j++){
						if(maze[i][j]=='w'){
							count++;
							maze[i][j]=len;
							rtx[count]=i;
							rty[count]=j;
							cnt++;
						}
					}
				}
				}
				else {
					maze[rtx[k]][rty[k]-1]=len;
					count++;
					rtx[count]=rtx[k];
					rty[count]=rty[k]-1;
					cnt++;
				}
			}
		}
		t++;
		a[t]=cnt;
		if(m*n<=t){
			fp2=fopen("hw2_output.txt","w");
			fprintf(fp2,"NULL");
			fclose(fp2);
			return 0;
		}
	}
	tracex[0]=ex;//traceback start
	tracey[0]=ey;
	t--;//마지막 경로는 무조건 end point 이다. 
	for(i=t;i>=0;i--){
		tf=0;
		count=-1; 
		for(k=0;k<=i;k++)count=count+a[k];
		for(j=a[i];j>0;j--){
			if((rtx[count]==tracex[c]+1 && rty[count]==tracey[c]) || (rtx[count]==tracex[c]-1 && rty[count]==tracey[c]) || (rtx[count]==tracex[c] && rty[count]==tracey[c]+1) || (rtx[count]==tracex[c] && rty[count]==tracey[c]-1)){
				//주변에 다음 경로가 있다면
				c++;
				tracex[c]=rtx[count];
				tracey[c]=rty[count];
				tf=1;
				break;
			}
			count--;
		}
		if(maze[tracex[c]][tracey[c]]==-1)break;
		if(tf==0){
			//주변에 다음 len이 없다면, 그곳은 warp zone이다. 그러므로 다음 trace는 처음으로 액세스한 warp zone이 된다. 
			c++;
			tracex[c]=warpx;
			tracey[c]=warpy;
			i++;
			if(maze[tracex[c]][tracey[c]]==-1)break;
		}
		if(i==0){//다 보고 시작점 밖에 큐에 남지 않았을때, 시작점을 저장하면서 for문을 마친다. 
			c++;
			tracex[c]=rtx[0];
			tracey[c]=rty[0];
			if(maze[tracex[c]][tracey[c]]==-1)break;
		}
	}
	fp2=fopen("hw2_output.txt","w");
	fprintf(fp2,"%d\n",len);
	for(i=c;i>=0;i--){
		fprintf(fp2,"(%d, %d) ",tracex[i]+1,tracey[i]+1);
	}
	fclose(fp2);
	return 0;
}
