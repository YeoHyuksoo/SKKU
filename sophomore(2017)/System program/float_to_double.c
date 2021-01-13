#include <stdio.h>
#include <string.h>

double float_to_double(float src);
float fn;

int main(){
	double dn;
	printf("Input some float number: ");
	scanf("%f",&fn);
	dn=float_to_double(fn);
	printf("%lf",dn);
	return 0;
}

double float_to_double(float src){
	unsigned long long src2;
	unsigned long long src3;
	unsigned long long exp,expd,biasf=127,biasd=1023,frac;
	unsigned int e;
	double dest;
	memcpy(&src2,&src,sizeof(unsigned long long));
	exp=src2&0x000000007F800000;
	frac=src2&0x00000000007FFFFF;
	if(exp!=0){
		exp=exp>>23;
		e=exp-biasf;
		expd=e+biasd;
		if(exp==0x7F8){//exp=111..11
			src3=(expd>>52)+0x0070000000000000+(frac<<29);
			memcpy(&dest,&src3,sizeof(double));
			if(fn<0){
				return -dest;
			}
			return dest;
		}
		else{
			src3=(expd<<52)+(frac<<29);
			memcpy(&dest,&src3,sizeof(double));
			if(fn<0){
				return -dest;
			}
			return dest;
		}
	}
	else{
		//exp = 00000...0
		e=-biasf+1;
		exp=e+biasd;
		src3=(exp<<52)+(frac<<29);
		memcpy(&dest,&src3,sizeof(double));
		if(fn<0){
			return -dest;
		}
		return dest;
	}
}
