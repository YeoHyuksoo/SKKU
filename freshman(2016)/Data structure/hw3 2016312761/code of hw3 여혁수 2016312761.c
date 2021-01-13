#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct node *treePointer;
typedef struct node{
   int value;
   treePointer leftchild;
   treePointer rightchild;
}node;

int e1[2000],e2[2000],v1[1000],v2[1000],one,two;
int i,j,r1,r2,nv1,nv2,na1,nd1,na2,nd2,ne12,ne21;
int e12[2000],e21[2000];
node* Root1;
node* Root2;
node* CopyRoot2;

void preorder1(node* ROOT){
    if(ROOT!=NULL){
        insert12(Root2, ROOT->value); 
        preorder1(ROOT->leftchild);
        preorder1(ROOT->rightchild);
    }
}

void preorder2(node* ROOT){
    if(ROOT!=NULL){
        insert21(Root1, ROOT->value);
        preorder2(ROOT->leftchild);
        preorder2(ROOT->rightchild);
    }
}

void insert12(node* tree, int VAL){
	node* temp;
	if(tree->value<VAL){
		if(tree->rightchild!=NULL){
			insert12(tree->rightchild, VAL);
		}
		else {
			temp=(node *)malloc(sizeof(node));
			tree->rightchild=temp;
			tree->rightchild->value=VAL;
			tree->rightchild->leftchild=NULL;
			tree->rightchild->rightchild=NULL;
			e12[i]=tree->value;
			i++;
			e12[i]=VAL;
			i++;
		}
	}
	else {
		if(tree->leftchild!=NULL){
			insert12(tree->leftchild, VAL);
		}
		else {
			temp=(node *)malloc(sizeof(node));
			tree->leftchild=temp;
			tree->leftchild->value=VAL;
			tree->leftchild->leftchild=NULL;
			tree->leftchild->rightchild=NULL;
			e12[i]=tree->value;
			i++;
			e12[i]=VAL;
			i++;
		}
	}
}

void insert21(node* tre, int VA){
	node* tem;
	if(tre->value<VA){
		if(tre->rightchild!=NULL){
			insert21(tre->rightchild, VA);
		}
		else{
			tem=(node *)malloc(sizeof(node));
			tre->rightchild=tem;
			tre->rightchild->value=VA;
			tre->rightchild->leftchild=NULL;
			tre->rightchild->rightchild=NULL;
			e21[i]=tre->value;
			i++;
			e21[i]=VA;
			i++;
		}
	}
	else {
		if(tre->leftchild!=NULL){
			insert21(tre->leftchild, VA);
		}
		else {
			tem=(node *)malloc(sizeof(node));
			tre->leftchild=tem;
			tre->leftchild->value=VA;
			tre->leftchild->leftchild=NULL;
			tre->leftchild->rightchild=NULL;
			e21[i]=tre->value;
			i++;
			e21[i]=VA;
			i++;
		}
	}
}

int main(void){
	clock_t start, end;
	start=clock();
   	FILE *fp;
  	FILE *fpp;
   	fp=fopen("hw3_input.txt","r");
   	int num,a;
   	fscanf(fp,"%d",&nv1);//read the text
   	for(i=0;i<(2*nv1-2);i++){
      	fscanf(fp,"%d",&e1[i]);
   	}
   	fscanf(fp,"%d",&nv2);
   	for(i=0;i<(2*nv2-2);i++){
      	fscanf(fp,"%d",&e2[i]);
   	}
   	fclose(fp);
   	for(i=0;i<nv1-1;i++){
      	a=0;
      	for(j=0;j<nv1-1;j++){
         	if(e1[2*i]==e1[2*j+1]){
            a++;
         	}
      	}
    	if(a==0){
        	r1=e1[2*i];
        	break;
    	}
   	}
   	for(i=0;i<nv2-1;i++){
      	a=0;
      	for(j=0;j<nv2-1;j++){
         	if(e2[2*i]==e2[2*j+1]){
            	a++;
         	}
      	}
    	if(a==0){
         	r2=e2[2*i];
         	break;
      	}
   	}//find root node
   	for(i=0;i<(2*nv1-2);i++){
       	int find=0;
       	for(j=0;j<one;j++)
            if(e1[i]==v1[j])
                find=1;
        if(find==0){
            v1[one]=e1[i];
            one++;
        }
   	}
   	for(i=0;i<(2*nv2-2);i++){
       	int find=0;
       	for(j=0;j<two;j++)
            if(e2[i]==v2[j])
            	find=1;
        if(find==0){
            v2[two]=e2[i];
            two++;
        }
   	}//make two trees and the same thing of second tree.
	node** treeone=(node**)malloc(sizeof(node*)*1000);
    node** treetwo=(node**)malloc(sizeof(node*)*1000);
    node** copytreetwo=(node**)malloc(sizeof(node*)*1000);
   	for(i=0;i<1000;i++){
       	treeone[i]=(node*)malloc(sizeof(node));
       	treetwo[i]=(node*)malloc(sizeof(node));
       	copytreetwo[i]=(node*)malloc(sizeof(node));
   	}
   	for(i=0;i<one;i++){
       	treeone[i]->value=v1[i];
       	treeone[i]->leftchild=NULL;
       	treeone[i]->rightchild=NULL;
       	if(v1[i]==r1)
        	Root1=treeone[i];
   	}
   	for(i=0;i<nv1-1;i++){
       	int parent,child;
       	for(j=0;j<one;j++){
           	if(e1[i*2]==v1[j])
                parent=j;
            if(e1[i*2+1]==v1[j])
                child=j;
       	}
       	if(v1[parent]<v1[child])
        	treeone[parent]->rightchild=treeone[child];
        else
            treeone[parent]->leftchild=treeone[child];
   	}
   	for(i=0;i<two;i++){
       	treetwo[i]->value=v2[i];
       	treetwo[i]->leftchild=NULL;
       	treetwo[i]->rightchild=NULL;
       	copytreetwo[i]->value=v2[i];
       	copytreetwo[i]->leftchild=NULL;
       	copytreetwo[i]->rightchild=NULL;
       	if(v2[i]==r2){
        	Root2=treetwo[i];
        	CopyRoot2=copytreetwo[i];
    	}
   	}
   	for(i=0;i<nv2-1;i++){
       	int parent,child;
       	for(j=0;j<two;j++){
           	if(e2[i*2]==v2[j])
            	parent=j;
            if(e2[i*2+1]==v2[j])
                child=j;
       	}
       	if(v2[parent]<v2[child]){
        	treetwo[parent]->rightchild=treetwo[child];
        	copytreetwo[parent]->rightchild=copytreetwo[child];
    	}
        else{
            treetwo[parent]->leftchild=treetwo[child];
            copytreetwo[parent]->leftchild=copytreetwo[child];
        }
   	}
	i=0;
	preorder1(Root1);//new edges of 1->2 in e12[].
	ne12=i;//the number of new edges
	i=0;
	preorder2(CopyRoot2);//new edges of 2->1 in e21[].
	ne21=i;//the number of new edges
	na1=ne12/2;//get na1+nd1
	for(i=0;i<ne12/2;i++){
		for(j=0;j<nv1-1;j++){
			if(e12[2*i]==e1[2*j] && e12[2*i+1]==e1[2*j+1]){
				na1--;
			}
		}
	}
	for(i=0;i<ne12/2;i++){
		for(j=0;j<nv2-1;j++){
			if(e12[2*i]==e2[2*j] && e12[2*i+1]==e2[2*j+1]){
				na1--;
			}
		}
	}
	nd1=nv1-1;
	for(i=0;i<nv1-1;i++){
		for(j=0;j<ne12/2;j++){
			if(e1[2*i]==e12[2*j] && e1[2*i+1]==e12[2*j+1]){
				nd1--;
			}
		}
	}
	na2=ne21/2;//get na2+nd2
	for(i=0;i<ne21/2;i++){
		for(j=0;j<nv1-1;j++){
			if(e21[2*i]==e1[2*j] && e21[2*i+1]==e1[2*j+1]){
				na2--;
			}
		}
	}
	for(i=0;i<ne21/2;i++){
		for(j=0;j<nv2-1;j++){
			if(e21[2*i]==e2[2*j] && e21[2*i+1]==e2[2*j+1]){
				na2--;
			}
		}
	}
	nd2=nv2-1;
	for(i=0;i<nv2-1;i++){
		for(j=0;j<ne21/2;j++){
			if(e2[2*i]==e21[2*j] && e2[2*i+1]==e21[2*j+1]){
				nd2--;
			}
		}
	}
	fpp=fopen("hw3_output.txt","w");
	if(na1+nd1<na2+nd2){//1->2 is better case
		fprintf(fpp,"%d\n",r2);
		for(i=0;i<ne12/2;i++){
			fprintf(fpp,"%d %d\n",e12[2*i],e12[2*i+1]);
		}
		for(i=0;i<nv2-1;i++){
			fprintf(fpp,"%d %d\n",e2[2*i],e2[2*i+1]);
		}
		fprintf(fpp,"%d\n",na1);
		fprintf(fpp,"%d\n",nd1);
	}
	else {//2->1 is better case
		fprintf(fpp,"%d\n",r1);
		for(i=0;i<ne21/2;i++){
			fprintf(fpp,"%d %d\n",e21[2*i],e21[2*i+1]);
		}
		for(i=0;i<nv1-1;i++){
			fprintf(fpp,"%d %d\n",e1[2*i],e1[2*i+1]);
		}
		fprintf(fpp,"%d\n",na2);
		fprintf(fpp,"%d\n",nd2);
	}//print the root, edges of new tree, na, nd.
	fclose(fpp);
	end=clock();
	printf("%.4lfÃÊ",(end-start)/(double)1000); 
	return 0;
}
