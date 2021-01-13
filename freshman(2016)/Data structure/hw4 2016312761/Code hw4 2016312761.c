#include <stdio.h>
#include <time.h>

int ne=0,nv=0,cnt=0,nve=0,total=0,nvv=0;
int e[2200],w[2200],v[2200],fo[2200],ew[3300],ve[2200],vv[2200],secmin[2200]={0};
int min,sec;
int i=0,j=0,k=0,flag,fl,temp,t;
int tx,ty,sx,sy,nox,noy,endx,endy;

void sortingweight(void);
void sortingedge(void);
int kruscal(int tone, int ttwo);
void secondkruscal(void);

int main(void){
	clock_t start,end;
	start=clock();
	FILE *fp,*fpp;
	fp=fopen("hw4_input1.txt","r");
	fscanf(fp,"%d",&ne);
	printf("number of edges : %d\n",ne);
	for(i=0;i<ne*3;i++){
		if(i%3==2){
			fscanf(fp,"%d",&w[j]);
			ew[i]=w[j];
			j++;
		}
		else{
			fscanf(fp,"%d",&e[k]);
			ew[i]=e[k];
			k++;
		}
	}
	fclose(fp);
	for(i=0;i<k;i++){
		flag=0;
		for(j=0;j<nv;j++){
			if(v[j]==e[i]){
				flag=1;
				break;
			}
		}
		if(flag==0){
			v[j]=e[i];
			nv++;
		}
	}
	printf("number of vertexes : %d\n",nv);
	sortingweight();
	sortingedge();
	for(i=0;i<nv;i++){
		fo[i]=i+1;
	}
	for(i=0;i<nv;i++){
		if(v[i]==e[0]){
			sx=i;
		}
	}
	for(i=0;i<nv;i++){
		if(v[i]==e[1]){
			sy=i;
		}
	}
	for(i=0;i<nv;i++){
		if(v[i]==e[ne*2-2]){
			endx=v[i];
		}
	}
	for(i=0;i<nv;i++){
		if(v[i]==e[ne*2-1]){
			endy=v[i];
		}
	}
	fpp=fopen("hw4_output.txt","w");
	min=kruscal(sx,sy);
	if(fl==1){
		printf("NULL");
		fprintf(fpp,"NULL");
		return 0;
	}
	printf("Weight of minimum spanning tree : %d\n",min);
	secondkruscal();
	flag=0;
	for(i=0;i<(nve/2);i++){
		if(secmin[i]!=0){
			flag=1;
			sec=secmin[i];
			break;
		}
	}
	if(flag==0){
		printf("NULL");
		fprintf(fpp,"NULL");
		fclose(fpp);
		return 0;
	}
	for(j=i;j<(nve/2);j++){
		if(secmin[j]<sec && secmin[j]!=0){
			sec=secmin[j];
		}
	}
	printf("Weight of second minimum spanning tree : %d\n",sec);
	fprintf(fpp,"%d",sec);
	fclose(fpp);
	end=clock();
	printf("%.3lfÃÊ\n",(end-start)/(double)(1000));
	return 0;
}

void sortingweight(void){
	for(i=0;i<ne-1;i++){
		temp=w[i+1];
		for(j=i;j>-1;j--){
			if(w[j]>temp){
				w[j+1]=w[j];
			}
			else break;
		}
		w[j+1]=temp;
	}	
}

void sortingedge(void){
	for(i=0;i<ne;i++){
		for(j=0;j<ne;j++){
			if(ew[3*j+2]==w[i]){
				e[2*i]=ew[3*j];
				e[2*i+1]=ew[3*j+1];
			}
		}
	}
}

int kruscal(int tone, int ttwo){
	while(1){
		if(fo[tone]==fo[ttwo]){//cycle or same edge
			cnt++;
			if(v[tone]==endx && v[ttwo]==endy){
				break;
			}
			for(i=0;i<nv;i++){
				if(v[i]==e[2*cnt]){
					tx=i;
				}
			}
			for(i=0;i<nv;i++){
				if(v[i]==e[2*cnt+1]){
					ty=i;
				}
			}
			kruscal(tx,ty);
		}
		else {
			if(flag==2 && v[tone]==nox && v[ttwo]==noy){//if second kruscal, and excluded edge
				if(v[tone]==endx && v[ttwo]==endy){
					break;
				}
				cnt++;
				for(i=0;i<nv;i++){
					if(v[i]==e[2*cnt]){
						tx=i;
					}
				}
				for(i=0;i<nv;i++){
					if(v[i]==e[2*cnt+1]){
						ty=i;
					}
				}
				kruscal(tx,ty);
			}
			else if(fo[tone]>fo[ttwo]){//success
				temp=fo[tone];
				total+=w[cnt];
				for(i=0;i<nv;i++){
					if(fo[i]==temp){
						fo[i]=fo[ttwo];
					}
				}//priorty to smaller forest number
				if(flag!=2){//not second kruscal
					ve[nve++]=v[tone];
					ve[nve++]=v[ttwo];
				}
				if(v[tone]==endx && v[ttwo]==endy){
					break;
				}
				cnt++;
				for(i=0;i<nv;i++){
					if(v[i]==e[2*cnt]){
						tx=i;
					}
				}
				for(i=0;i<nv;i++){
					if(v[i]==e[2*cnt+1]){
						ty=i;
					}
				}
				fl=0;
				for(i=0;i<nv;i++){
					if(fo[0]!=fo[i]){
						fl=1;
					}
				}
				if(fl==0){//finish kruscal
					break;
				}
				kruscal(tx,ty);
			}
			else if(fo[tone]<fo[ttwo]){//success
				temp=fo[ttwo];
				total+=w[cnt];
				for(i=0;i<nv;i++){
					if(fo[i]==temp){
						fo[i]=fo[tone];
					}
				}
				if(flag!=2){
					ve[nve++]=v[tone];
					ve[nve++]=v[ttwo];
				}
				if(v[tone]==endx && v[ttwo]==endy){
					break;
				}
				cnt++;
				for(i=0;i<nv;i++){
					if(v[i]==e[2*cnt]){
						tx=i;
					}
				}
				for(i=0;i<nv;i++){
					if(v[i]==e[2*cnt+1]){
						ty=i;
					}
				}
				fl=0;
				for(i=0;i<nv;i++){
					if(fo[0]!=fo[i]){
						fl=1;
					}
				}
				if(fl==0){
					break;
				}
				kruscal(tx,ty);
			}
		}
		break;//Finish kruscal
	}
	fl=0;//rechecking
	for(i=0;i<nv;i++){
		if(fo[0]!=fo[i]){
			fl=1;
		}
	}
	if(fl==0){
		return total;
	}
}

void secondkruscal(void){
	int a,m,n;
	a=nve;
	for(m=0;m<(a/2);m++){
		flag=2;
		cnt=0;
		total=0;
		for(n=0;n<nv;n++){
			fo[n]=(n+1);
		}//reset options
		nox=ve[2*m];
		noy=ve[2*m+1];//exclude one edge belonged to minimum spanning tree
		secmin[m]=kruscal(sx,sy);
		if(fl==1){//cannot make spanning tree
			secmin[m]=0;
		}
	}
}
