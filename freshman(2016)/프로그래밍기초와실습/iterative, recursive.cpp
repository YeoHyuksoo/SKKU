#include <stdio.h>
#include <stdlib.h>

int factorial_iter(int n);
int factorial_recur(int m);
int b=1;
int main(void){
	int n,m,a,b;
	scanf("%d",&n);
	scanf("%d",&m);
	a=factorial_iter(n);
	b=factorial_recur(m);
	if(n>=0)printf("Iter : %d! is %d",n,a);
	else printf("Iter : Wrong input!");
	if(m>=0)printf("Recur : %d! is %d",m,b);
	else printf("Recur : Wrong input!");

}

int factorial_iter(int n){
	int a=1;
	for(;n>0;n--){
		a=a*n;
	}
	return a;
}

int factorial_recur(int m){
	b=b*m;
	if(m==1) return b;
	return factorial_recur(m-1);
}
