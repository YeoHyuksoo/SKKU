#include <stdio.h>
#include <stdlib.h>

int first_eliminated_mole(int* m, int m_num){
	if(m_num<=2){
		return m[0];
	}
	int* arr;
	arr = (int*)calloc(m_num+1, sizeof(int));
	for(int i=0;i<m_num;i++){
		arr[m[i]]++;
	}
	int target=0;
	if(arr[m[0]]==1){
		return m[0];
	}
	int cnt=0;
	while(1){
		arr[m[target]]--;
		int jump=m[target]+1;
		m[target]=0;
		target+=jump;
		if((target+jump)>=m_num){//�Ѿ
			int zero=0, shrink=0;
			for(int i=0;i<m_num;i++){
				if(m[i]==0){
					zero++;
				}
				else {
					m[shrink++]=m[i];//resize
				}
			}
			target-=zero;
			if(target>=shrink){
				target=target%shrink;
			}
			m_num=shrink;
		}
		if(arr[m[target]]==1){
			break;
		}
	}
	return m[target];
}

int main(){
	int* m;
	int m_num;
	scanf("%d", &m_num);
	
	m = (int*)malloc(sizeof(int)*m_num);
	for(int i=0;i<m_num;i++){
		scanf("%d", &m[i]);
	}
	
	printf("%d\n", first_eliminated_mole(m, m_num));
	free(m);
	return 0;
}
