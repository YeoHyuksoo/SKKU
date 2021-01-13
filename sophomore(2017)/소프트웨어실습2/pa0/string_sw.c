//-----------------------------------------------------------
// 
// SWE2007: Software Experiment II (Fall 2017)
//
// Skeleton code for PA #0
// September 6, 2017
//
// Ha-yun Lee, Jong-won Park
// Embedded Software Laboratory
// Sungkyunkwan University
//
//-----------------------------------------------------------
//2016312761 yeo hyuksoo
#include "string_sw.h"
#include <stdlib.h>

#define isspace(ch) ((ch) == ' ' || (ch) == '\t' || (ch) == '\n' || \
					 (ch) == '\v' || (ch) == '\f' || (ch) == '\r')

/* Conversions string to numeric formats */

int atoi2 (const char *str)
{
	int i;
	int sign=1;
	int total=0;
	for(i=0;isspace(str[i]);i++);
	if(str[i]=='-'){
		sign=-1;
	}
	if(str[i]=='+' || str[i]=='-'){
		i++;
	}
	for(total=0;str[i]>='0' && str[i]<='9';i++){
		total=10*total+(str[i]-'0');
	}
	return total*sign;
}
long atol2 (const char *str)
{
		int i;
     long  sign=1;
      long  total=0;
       for(i=0;isspace(str[i]);i++);
	     if(str[i]=='-'){
		         sign=-1;
		       }
	      if(str[i]=='+' || str[i]=='-'){
		          i++;
			     }
	     for(total=0;str[i]>='0' && str[i]<='9';i++){
			        total=10*total+(str[i]-'0');
			      }
		  return total*sign;

}

char *int2str (char *dest, int num)
{
	int i=0;
	int j=0;
	char temp;
	int isNeg=0;
	if(dest== NULL){
		dest= (char *) malloc(13*(sizeof(char)));
		if(dest == NULL) return NULL;
	}
	char * copy=dest;
	if (num==0){
		*dest='0';
		*(dest+1)='\0';
		return dest;
	}
	if (num<0){
		isNeg=1;
		num=-num;
	}
	while(num!=0){
		 *dest=num%10+'0';
		 dest++;
		 num=num/10;
		 i++;
	}
	if (isNeg==1){//if negative number
		*dest='-';
		dest++;
		i++;
	}
	dest=copy;
	for(j=0;j<i/2;j++){
		temp=dest[j];
		dest[j]=dest[i-j-1];
		dest[i-j-1]=temp;
	}
	return dest;
}

char *strcpy (char *dst, const char *src)
{
	char *p=dst;
	while(*p++=*src++);
	return dst;
}

char *strncpy (char *dst, const char *src, size_t count)
{
	char *p=dst;
	int i;
	for(i=0;i<count;i++){
		if((*dst++=*src++)==0){
			while(++i < count){
				*dst++=0;
			}
			dst=p;
			return dst;
		}
	}
	dst=p;
	return dst;
}

char *strcat (char *dst, const char *src)
{
	char *p=dst;
	while(*p!='\0'){
		p++;
	}
	while(*src!='\0'){
		*p=*src;
		src++;
		p++;
	}
	return dst;
}
char *strncat (char *dst, const char *src, size_t count)
{
	char *p = dst;
	while(*dst++);
	dst--;
	while(count--){
		if(!(*dst++ = *src++)){
			return p;
		}
	}
	*dst='\0';
	return p;
}
char *strdup (const char *str)
{
	char *temp=str;
	int len=0;
	while(*str++){
		len++;
	}
	char *p;
	p=(char*) malloc(len*sizeof(char));
	if(p==NULL){
		return NULL;
	}
	p=temp;
	return p;
}

size_t strlen (const char *str)
{
	int len=0;
	while(*str++){
		len++;
	}
	return len;
}
int strcmp (const char *lhs, const char *rhs)
{
	int tf;
	while(!(tf = *(unsigned char *)lhs - *(unsigned char *)rhs)&& *rhs){
		++lhs;
		++rhs;
	}
	if (tf<0){
		tf=-1;
	}
	else if(tf>0){
		tf=1;
	}
	return tf;
}
int strncmp (const char *lhs, const char *rhs, size_t count)
{
	if(!count){
		return 0;
	}
	while(--count && *lhs && *lhs==*rhs){
		lhs++;
		rhs++;
	}
	return *(unsigned char *)lhs - *(unsigned char *)rhs;
}
char *strchr (const char *str, int ch)
{
	while(*str && (*str!=(char)ch)){
		str++;
	}
	if(*str==(char)ch){
		return (char *)str;
	}
	return NULL;
}
char *strrchr (const char *str, int ch)
{
	char *temp;
	while(*str){
		if(*str==(char)ch){
			temp=str;
		}
		str++;
	}
	return temp;
}
char *strpbrk (const char *str, const char *accept)
{
	char ch=*str;
	char *temp=accept;
	while(*str){
		while(*accept!='\0'){
			if(*accept==ch){
				return str;
			}
			accept++;
		}
		str++;
		ch=*str;
		accept=temp;
	}
	return NULL;
	
}
char *strstr (const char *str, const char *substr)
{
	int i;
	int len=0;
	const char *p=substr;
	while(*p++){
		len++;
	}
	if(*substr=='\0'){
		return (char *)str;
	}
	else{
		for(;*str;str++){
			if(*str==*substr){
				for(i=1;*(str+i)==*(substr+i);i++);
				if(i==len){
					return (char *)str;
				}
			}
		}
		return NULL;
	}
}
char *strtok (char *str, const char *delim)
{

	static char* ps;
	const char * pd=delim;
	if(str==NULL){
		ps=NULL;
	}
	else{
		ps=str;
	}
	while(*str){
		pd=delim;
		while(*pd){
			if(*ps==*pd){
				*ps=NULL;
				ps++;
				return str;
			}
			pd++;
		}
		ps++;
	}
	return str;
}
char *strtok_r (char *str, const char *delim, char **saveptr)
{
}

void *memcpy (void *dest, const void *str, size_t n)
{
	char *p1=(char *)dest;
	const char *p2=(char *)str;
	while(n--){
		*p1++=*p2++;
	}
	return dest;
}

void *memset (void *dest, int ch, size_t count)
{
	char *st=(char *)dest;
	char *last=st+count;
	while(st!=last){
		*st++=ch;
	}
	return dest;
}
