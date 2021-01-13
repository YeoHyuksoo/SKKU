#include <stdio.h>
#include <string.h>

double dn;
int double_to_int(double src);

int main(){
	int intn;
	printf("Input some double number: ");
	scanf("%lf",&dn);
	printf("%lf\n",dn);
	intn=double_to_int(dn);
	printf("%d",intn);
	return 0;
}

int double_to_int(double src){
	unsigned long long src2,src3;
	unsigned long long s,exp,frac;
	unsigned int bias=1023,e;
	int dest;
	memcpy(&src2,&src,sizeof(unsigned long long));
	s=src2&0x8000000000000000;
	s=s>>63;
	exp=src2&0x7FF0000000000000;
	exp=exp>>52;
	frac=src2&0xFFFFFFFFFFFFF;
	if(exp==0){
		return 0;
	}
	e=exp-bias;
	src3=(frac>>(52-e))+(1<<e);
	memcpy(&dest,&src3,sizeof(int));
	if(dn<0){
		return -dest;
	}
	return dest;
}
