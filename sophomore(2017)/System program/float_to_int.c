#include <stdio.h>
#include <string.h>

float fn;
int float_to_int(float src);

int main(){
	int intn;
	printf("Input some float number: ");
	scanf("%f",&fn);
	intn=float_to_int(fn);
	printf("%f\n",fn);
	printf("%d",intn);
}

int float_to_int(float src){
	unsigned int src2,src3;
	unsigned int s,exp,frac;
	unsigned int e,bias=127;
	int dest;
	memcpy(&src2,&src,sizeof(unsigned int));
	s=src2&0x80000000;
	exp=src2&0x7F800000;
	exp=exp>>23;
	frac=src2&0x007FFFFF;
	if(exp==0){
		return 0;
	}
	e=exp-bias;
	src3=(1<<e)+(frac>>(23-e));	
	memcpy(&dest,&src3,sizeof(int));
	if(fn<0){
		return -dest;		
	}
	return dest;
}
