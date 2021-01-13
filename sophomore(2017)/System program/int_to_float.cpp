#include <stdio.h>
#include <string.h>

int intn;
float int_to_float(int src);

int main(){
	float fn;
	printf("Input some int number: ");
	scanf("%d",&intn);
	printf("%d\n",intn);
	fn=int_to_float(intn);
	printf("%f",fn);
	return 0;
}

float int_to_float(int src){
	unsigned int src2,src3;
	unsigned int s,exp,frac;
	unsigned int e=0,bias=127,f=0;
	unsigned int temp;
	float dest;
	memcpy(&src2,&src,sizeof(unsigned int));
	if(intn<0){
		frac=~(src2&0xFFFFFFFF)+1;
	}
	else{
		frac=src2&0x7FFFFFFF;
	}
	temp=frac;
	while(temp>1){
		temp=temp>>1;
		f++;
	}
	frac=frac<<1;
	printf("E is %d\n",f);
	printf("%d\n",frac);
	while((frac>>31)==0){
		frac=frac<<1;
		e++;
	}
	printf("e is %d\n",e);
	printf("frac is %d\n",frac);
	if(e<7){
		//need rounding
		frac=frac<<1;
		e++;
		if((frac>>(7-e))&0x1==1){
			if(((frac<<(32-7+e))>>(32-7+e))==0){
				//짝수만들기0.5
				if((frac>>(8-e))&0x1==1){
					if((frac>>(7-e))&0xFFFFFFFF==(frac>>(7-e))){
						exp=f+bias+1;
						src3=exp<<23;
					}
					else{
						frac=frac>>(8-e);
						frac=frac+1;
						exp=f+bias;
						src3=((frac<<(8-e))>>9)+(exp<<23);
					}
				}
				else{
					//내리기 
					exp=f+bias;
					src3=(((frac>>(8-e))<<(8-e))>>9)+(exp<<23);
				}
			}
				else{
				//올리기
				if((frac>>(7-e))&0xFFFFFFFF==(frac>>(7-e))){
					exp=f+bias+1;
					src3=exp<<23;
				}
				else{
					frac=frac>>(8-e);
					frac=frac+1;
					exp=f+bias;
					src3=((frac<<(8-e))>>9)+(exp<<23);
				}
			}
		}
		else{
			//내리기
			exp=e+bias;
			src3=(((frac>>8)<<8)>>9)+(exp<<23);
		}
		memcpy(&dest,&src3,sizeof(float));
		if(intn<0){
			return -dest;
		}
		return dest;
	}
	else{
		//no rounding
		frac=frac<<1;
		e++;
		exp=f+bias;
		src3=(frac>>9)+(exp<<23);
		memcpy(&dest,&src3,sizeof(float));
		if(intn<0){
			return -dest;
		}
		return dest;
	}
}
