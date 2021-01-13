#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(){
        char string[500];
        char findword[20];
        char getword[20];
        int i,count=0,k=0,length,words=0,len=0;
        printf("Input a string : ");
		gets(string);
        length=strlen(string);
        printf("Input a word : ");
        scanf("%s",findword);
        for(i=0;i<length;i++){
        	if(string[i]>'A' && string[i]<'Z'){
 				string[i]=(string[i]-'A'+'a');       	
			}
		}		
        for(i=0;i<length;i++){
        	if(i==length-1){
                    count=0;
					for(k=0;k<len;k++){
                            if(getword[k]==findword[k]){
								count++;
								}
						}
						if(count==len)words++;
								 
						k=0;
						len=0; 
 				}
 					
            if(string[i]==' '){
                count=0;
				for(k=0;k<len;k++){
                    if(getword[k]==findword[k]){
						count++;
						}
					}
				if(count==len)words++;
								 
				k=0;
				len=0; 
 				}
            else{ 
				getword[k]=string[i];
                k++;
                len++;
            }
        }
        printf("Result : %d",words);
        
		return 0;
	} 

