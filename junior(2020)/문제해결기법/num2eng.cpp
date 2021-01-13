#include <stdio.h>
#include <string.h>
//1234987?134?20?
long long num2eng(char* input){
	int len = strlen(input);
	long long res, bef1=1, bef2=1;
	int n;
	if(input[0]=='0'){
		return 0;
	}
	if(len==1){
		return 1;
	}
	for(int i=1;i<len;i++){
		res=0;
		n = input[i]-'0';
		if(n!=0){
			res+=bef1;
		}
		if(input[i-1]=='0'){
			bef2=bef1;
			bef1=res;
			continue;
		}
		n=(input[i-1]-'0')*10+(input[i]-'0');
		if(n<=26){
			res+=bef2;
		}
		bef2=bef1;
		bef1=res;
	}
	return res;
}

int main(void){
	char input[2000];
	scanf("%s", input);
	long long answer;
	//for(int i=0;i<300000;i++){
		answer = num2eng(input);
	//}
	printf("%lld", answer);
	return 0;
}
