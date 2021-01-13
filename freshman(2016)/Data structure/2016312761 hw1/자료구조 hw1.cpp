#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int arr[1010][1010];//allocate two-dimensional array.
int main(void){
	int a,b;
	char choice;
	time_t s=0,e=0;
	s=clock();
	int x[10000],y[10000],num[10000];//allocate one dimensional array that contain x,y,number.
	int m=0,i,j;	
	FILE *fp1;
	FILE *fp2;//declare two files.
	fp1 = fopen("hw1_input.txt","r");
	fscanf(fp1,"%c",&choice);
	fscanf(fp1,"%d",&a);
	fscanf(fp1,"%d",&b);
	for(i=0;i<a;i++){
		for(j=0;j<b;j++){
			fscanf(fp1,"%d",&arr[i][j]);
		}
	}//get information from input text.
	fclose(fp1);//close the file.
	if(choice=='r'){//read row first.
		for(i=0;i<a;i++){
			for(j=0;j<b;j++){
				if(arr[i][j]!=0){
					x[m]=i+1;
					y[m]=j+1;
					num[m]=arr[i][j];
					m++;		
				}
			}
		}//put x,y point and number into array, get the number of non-zero elements(m).
		fp2=fopen("hw1a_output.txt","w");
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",x[i]);
		}
		fprintf(fp2,"\n");
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",y[i]);
		}
		fprintf(fp2,"\n");
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",num[i]);
		}
		fprintf(fp2,"\n");//print x,y,num to output(a) file. 
		m=0;//initialization of m.
		for(i=0;i<b;i++){
			for(j=0;j<a;j++){
				if(arr[j][i]!=0){
					x[m]=j+1;
					y[m]=i+1;
					num[m]=arr[j][i];
					m++;		
				}
			}
		}//put x,y point and number into array, get the number of non-zero elements(m) again.
		fp2=fopen("hw1b_output.txt","w");//transpose the result of hw1a_output.
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",y[i]);
		}
		fprintf(fp2,"\n");
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",x[i]);
		}
		fprintf(fp2,"\n");
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",num[i]);
		}//print x,y,num to output(b) file.
		m=0;//initialization of m.
		fclose(fp2);//close the file.
	}
	else if(choice=='c'){//similar like above(r).
		for(i=0;i<b;i++){//read column first.
			for(j=0;j<a;j++){
				if(arr[j][i]!=0){
					x[m]=j+1;
					y[m]=i+1;
					num[m]=arr[j][i];
					m++;		
				}
			}
		}
		fp2=fopen("hw1a_output.txt","w");
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",x[i]);
		}
		fprintf(fp2,"\n");
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",y[i]);
		}
		fprintf(fp2,"\n");
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",num[i]);
		}
		m=0;
		for(i=0;i<a;i++){
			for(j=0;j<b;j++){
				if(arr[i][j]!=0){
					x[m]=i+1;
					y[m]=j+1;
					num[m]=arr[i][j];
					m++;		
				}
			}
		}
		fp2=fopen("hw1b_output.txt","w");//transpose the result of hw1b_output.
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",y[i]);
		}
		fprintf(fp2,"\n");
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",x[i]);
		}
		fprintf(fp2,"\n");
		for(i=0;i<m;i++){
			fprintf(fp2,"%d ",num[i]);
		}
		fprintf(fp2,"\n");
		fclose(fp2);
	}
	e=clock();
	printf("%f초 걸렸습니다.",(float)(e-s)/CLOCKS_PER_SEC);//represent running time.
	return 0;
}
