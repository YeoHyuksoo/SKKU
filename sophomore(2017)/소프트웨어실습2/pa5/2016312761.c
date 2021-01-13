//-----------------------------------------------------------
// 
// SWE2007: Software Experiment II (Fall 2017)
//
// Skeleton code for PA #5
// December 6, 2017
// YeoHyukSoo 2016312761
// Hayun Lee
// Embedded Software Laboratory
// Sungkyunkwan University
//
//-----------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>

#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <strings.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>
#include <fcntl.h>

#include "http.h"
#include "string_sw.h"

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

pthread_mutex_t m=PTHREAD_MUTEX_INITIALIZER;
int reset=0, thread_num=0;
int connections=0;
long long int send_bytes=0;
int html=0, jpg=0, png=0, gif=0, js=0, css=0, error=0;

void * thread_main(void *arg){
	char buffer[4096];
	char address[1024]={0}, type[1024]={0};
	long long sent;
	int connfd=*((int *)arg);
	char *report;
	char *filecontent;
	int header_len, len, reportlen, filelen;
	char *http_header;
	int file=0;
	int i,t;
	int fd;
	pthread_detach(pthread_self());//make detach condition
	pthread_mutex_lock(&m);
	thread_num++;
	pthread_mutex_unlock(&m);
	sent=0;
	do {//putting contents in buffer
		sent += read(connfd, buffer + sent, 256);
		if (sent >= 4 && strncmp(buffer+sent-4, "\r\n\r\n", 4) == 0)
		break;
	} while (sent <= 1024);
	//cutting address
	if(buffer[5]==' '){// address is /
		strcpy(address, "index.html");
		strcpy(type, "html");
	}
	else {//cut
		i=4;
		while(buffer[i]!=' '){
			i++;
			continue;
		}
		t=i;
		buffer[t]='\0';
		strcpy(address, buffer+5);
		strcpy(type, address);
		for(i=0;i<strlen(type);i++){
			if(type[i]=='.'){
				type[i]='\0';
				i++;
				strcpy(type, address+i);
				break;
			}
		}
	}
	
	if(strcmp(type, "stat")==0){
		report=make_report(connections, send_bytes, html, jpg, png, gif, js, css, error);
		reportlen=strlen(report);
	}
	else if(strcmp(type, "reset")==0){
		reset=1;
		if(thread_num>1){
			while(thread_num>1){
				continue;
			}
		}
		pthread_mutex_lock(&m);
		send_bytes=0;
		pthread_mutex_unlock(&m);
		report=make_report(connections, send_bytes, html, jpg, png, gif, js, css, error);
		reportlen=strlen(report);
	}

	else{//file
		//check that file is valid
		len=strlen(address);
		file=0;
		for(i=0;i<len;i++){
			if(address[i]=='.'){
				file=1;
			}
		}
		if(file==0){//file invalid
			strcpy(type, "error");
		}
	}
	pthread_mutex_lock(&m);
	connections++;
	pthread_mutex_unlock(&m);
	if(strcmp(type, "reset")!=0 && strcmp(type, "stat")!=0){//is File
		fd=open(address, O_RDONLY, 0600);
		if(fd>=0){//valid file
			filelen=lseek(fd, 0, SEEK_END);
			lseek(fd, 0, SEEK_SET);
			filecontent=(char *)malloc(filelen*sizeof(char));
			read(fd, filecontent, filelen);
			pthread_mutex_lock(&m);
			send_bytes+=filelen;
			pthread_mutex_unlock(&m);
		}

		//make a <HTTP header>
		else{//file error
			pthread_mutex_lock(&m);
			error++;
			pthread_mutex_unlock(&m);
			if(errno==2){
				if(strcmp(type, "html")==0){
					http_header=make_http_header(E_NO_FILE, TYPE_HTML, 0);
				}
				else if(strcmp(type, "jpg")==0){
					http_header=make_http_header(E_NO_FILE, TYPE_JPG, 0);
				}
				else if(strcmp(type, "png")==0){
					http_header=make_http_header(E_NO_FILE, TYPE_PNG, 0);
				}
				else if(strcmp(type, "gif")==0){
					http_header=make_http_header(E_NO_FILE, TYPE_GIF, 0);
				}
				else if(strcmp(type, "js")==0){
					http_header=make_http_header(E_NO_FILE, TYPE_JS, 0);
				}
				else if(strcmp(type, "css")==0){
					http_header=make_http_header(E_NO_FILE, TYPE_CSS, 0);
				}
				else{
					http_header=make_http_header(E_NO_FILE, TYPE_ERROR, 0);
				}
			}
			else if(errno==13){
				if(strcmp(type, "html")==0){
					http_header=make_http_header(E_NOT_ALLOWED, TYPE_HTML, 0);
				}
				else if(strcmp(type, "jpg")==0){
					http_header=make_http_header(E_NOT_ALLOWED, TYPE_JPG, 0);
				}
				else if(strcmp(type, "png")==0){
					http_header=make_http_header(E_NOT_ALLOWED, TYPE_PNG, 0);
				}
				else if(strcmp(type, "gif")==0){
					http_header=make_http_header(E_NOT_ALLOWED, TYPE_GIF, 0);
				}
				else if(strcmp(type, "js")==0){
					http_header=make_http_header(E_NOT_ALLOWED, TYPE_JS, 0);
				}
				else if(strcmp(type, "css")==0){
					http_header=make_http_header(E_NOT_ALLOWED, TYPE_CSS, 0);
				}
				else{
					http_header=make_http_header(E_NOT_ALLOWED, TYPE_ERROR, 0);
				}
			}
		}
		if(fd>=0){
			if(strcmp(type, "html")==0){
				pthread_mutex_lock(&m);
				html++;
				pthread_mutex_unlock(&m);
				http_header=make_http_header(OK, TYPE_HTML, filelen);
			}
			else if(strcmp(type, "jpg")==0){
		      pthread_mutex_lock(&m);
	         jpg++;
	         pthread_mutex_unlock(&m);
	         http_header=make_http_header(OK, TYPE_JPG, filelen);
	      }
			else if(strcmp(type, "png")==0){
				pthread_mutex_lock(&m);
	         png++;
	         pthread_mutex_unlock(&m);
	         http_header=make_http_header(OK, TYPE_PNG, filelen);
	      }
			else if(strcmp(type, "gif")==0){
	         pthread_mutex_lock(&m);
	         gif++;
	         pthread_mutex_unlock(&m);
	         http_header=make_http_header(OK, TYPE_GIF, filelen);
	      }
			else if(strcmp(type, "js")==0){
				pthread_mutex_lock(&m);
	         js++;
	         pthread_mutex_unlock(&m);
	         http_header=make_http_header(OK, TYPE_JS, filelen);
	      }
			else if(strcmp(type, "css")==0){
				pthread_mutex_lock(&m);
				css++;
				pthread_mutex_unlock(&m);
				http_header=make_http_header(OK, TYPE_CSS, filelen);
			}
			else{
				pthread_mutex_lock(&m);
				error++;
				pthread_mutex_unlock(&m);
				http_header=make_http_header(OK, TYPE_ERROR, filelen);
			}
		}
	}
	else{//stat or reset
		pthread_mutex_lock(&m);
		html++;
		pthread_mutex_unlock(&m);
		http_header=make_http_header(OK, TYPE_HTML, strlen(report));
	}
	if (http_header == NULL)
	{
		write(2, "make_http_header returns NULL\n", 30);
		exit(5);
	}
	 
	// sending <HTTP header> and <NULL LINE>
	sent = 0;
	header_len = strlen(http_header);
	do {
		sent += write(connfd, http_header + sent, header_len - sent);
	} while (sent < header_len); // until write is done
	// sending <HTTP body>:
	sent = 0;
	if(strcmp(type, "reset")!=0 && strcmp(type, "stat")!=0){
		//send file content
		do {
			sent += write(connfd, filecontent + sent, filelen - sent);
		} while (sent < filelen);
	}
	else{
		//send report	
		do {
			sent += write(connfd, report + sent, reportlen - sent);
		} while (sent < reportlen);
	}
	
	if(fd>=0){//file
		free(filecontent);
		close(fd);
	}
	pthread_mutex_lock(&m);
	thread_num--;
	pthread_mutex_unlock(&m);
	free(http_header);
	close(connfd);
	return NULL;
}

int main(int argc, char *argv[])
{
    struct hostent;
    struct sockaddr_in saddr;
    int port = 1234;
    int listenfd, connfd;
	 
	 pthread_t tid;
    
	 if (argc == 2 && argv[1] != NULL)
    {
        port = atoi2(argv[1]);
    }
    if ((listenfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        perror("socket");
        exit(1);
    }
    bzero((char*)&saddr, sizeof(saddr));
    saddr.sin_family = AF_INET;
    saddr.sin_addr.s_addr = htonl(INADDR_ANY);
    saddr.sin_port = htons(port);
    if (bind(listenfd, (struct sockaddr*)&saddr, sizeof(saddr)) < 0)
    {
        perror("bind");
        exit(2);
    }
    if (listen(listenfd, 5) < 0)
    {
        perror("listen");
        exit(3);
    }
	 
	 while(1){
    	if ((connfd = accept(listenfd, NULL, NULL)) < 0)
 		{
			perror("accept");
        	exit(4);
    	}
	 	pthread_create(&tid, NULL, thread_main, &connfd);
	 	if(reset==1){//reset
			//waiting for finishing all threads
			while(thread_num>0){
		   	continue;
		 	}
		 	reset=0;
	 	}
	 }
    return 0;
}
