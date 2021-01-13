#include <stdio.h>
#include <fstream>
#include <algorithm>

int findmin(int weight[],int n);
int findnode(int edge[],int node[],int index,int n);
int mstfunc(int checknode[][2],int edge1[],int edge2[],int weight[],int node[],int numofnode,int num_of_edge);

int realmst;

using namespace std;

int main(int argc, char* argv[]){
	ifstream ifs;
	ifs.open(argv[1]);
	ofstream ofs;
	ofs.open(argv[2]);
	
   int num_of_edge, vertex;
   ifs >> vertex >> num_of_edge;
   
   int *edge1,*edge2,*weight;
   edge1 = new int[num_of_edge];
   edge2 = new int[num_of_edge];
   weight = new int[num_of_edge];
   
   int numofnode=0, j,cnt1=0,cnt2=0;
   int node[50002];
   
   int i;
   for(i=0;i<num_of_edge;i++){
      ifs >> edge1[i] >> edge2[i] >> weight[i];
      for(j=0;j<numofnode;j++){
         if(node[j] == edge1[i])
            cnt1++;
         if(node[j] == edge2[i])
            cnt2++;
      }
      if(cnt1 == 0){
         node[numofnode] = edge1[i];
         numofnode++;
      }
      if(cnt2 == 0){
         node[numofnode] = edge2[i];
         numofnode++;
      }
      cnt1=0;
      cnt2=0;
   }
      
	int sweight[50002];
	for(i=0;i<num_of_edge;i++){
		sweight[i] = weight[i];
	}
	int checknode[50002][2];
	for(i=0;i<numofnode;i++){
		checknode[i][0] = node[i];
		checknode[i][1] = 0;
	}
	int forestnum = 1;
	int changenum = 0;
	int node1,node2,index;
	int save;
	int mst=0;
	int cnt=0;
	int scnt=0;
	int NULLcnt=0,mergecnt=1;
	int *mergededge;
	mergededge = new int[num_of_edge];
	
	while(1){
		index = findmin(weight,num_of_edge);
		node1 = findnode(edge1,node,index,numofnode);
		node2 = findnode(edge2,node,index,numofnode);
		if(checknode[node1][1] != checknode[node2][1]){
			if(checknode[node1][1] ==0){
				changenum = checknode[node2][1];
				checknode[node1][1] = changenum;
			}
			else if(checknode[node2][1] == 0){
				changenum = checknode[node1][1];
				checknode[node2][1] = changenum;
			}
			else{
				changenum =checknode[node1][1];	
				save = checknode[node2][1];			
				for(i=0;i<numofnode;i++){
					if(checknode[i][1] == save){
						checknode[i][1] = changenum;
					}
				}
			}
			mst += weight[index];
			weight[index] = 2100000000;	
			mergededge[index] = mergecnt;
			mergecnt++;
			scnt++;
		}
		else if(checknode[node1][1] == 0){
			checknode[node1][1] = forestnum;
			checknode[node2][1] = forestnum;	
			forestnum++;
			mst += weight[index];
			weight[index] = 2100000000;	
			mergededge[index] = mergecnt;
			mergecnt++;
			scnt++;
		}
		else{
	//		skip
			weight[index] = 2100000000;
		}
		
		for(i=0;i<numofnode;i++){
			if(checknode[i][1] == checknode[0][1]){
				cnt++;
			}
		}
		
		if(cnt == numofnode)
			break;
		
		cnt = 0;
		NULLcnt ++;
		if(NULLcnt >num_of_edge){
			ofs << "-1";
			return 0;
		}
	}
	realmst = mst;
	int* sedge1 = new int[num_of_edge-1];
	int* sedge2 = new int[num_of_edge-1];
	int* smstweight = new int[num_of_edge-1];
	
	for(i=0;i<numofnode;i++){
		checknode[i][0] = node[i];
		checknode[i][1] = 0;
	}
	int minmst=2100000000,nowmst;
	int k=0,checkcnt=0,a;
	for(i=1;i<scnt+1;i++){
		j=0;
		for(k=0;k<num_of_edge;k++){
			
			if(mergededge[k]!=i){
				sedge1[j] = edge1[k];
				sedge2[j] = edge2[k];
				smstweight[j] = sweight[k];
				
				j++;				
			}
		}
		for(a=0;a<numofnode;a++){
			checknode[a][1] = 0;
		}		
		nowmst=mstfunc(checknode,sedge1,sedge2,smstweight,node,numofnode,j);
		if(nowmst<minmst)
			minmst = nowmst;
	}
	if(minmst==2100000000){
		ofs << "-1";
	}
	else
		ofs << minmst;
}

int findmin(int weight[],int n){
	int i;
	int min = weight[0],k=0;
	for(i=0;i<n;i++){
		if(weight[i] < min){
			min = weight[i];
			k = i;
		}
	}
	return k;
}
int findnode(int edge[],int node[],int index,int n){
	int i;
	for(i=0;i<n;i++){
		if(edge[index] == node[i])
			break;
	}	
	return i;
}

int mstfunc(int checknode[][2],int edge1[],int edge2[],int weight[],int node[],int numofnode,int num_of_edge){
	int forestnum = 1;
	int changenum = 0;
	int node1,node2,index;
	int save;
	int mst=0;
	int cnt=0;
	int i=0,NULLcnt=0;
	while(1){
		index = findmin(weight,num_of_edge);
		node1 = findnode(edge1,node,index,numofnode);
		node2 = findnode(edge2,node,index,numofnode);
		if(checknode[node1][1] != checknode[node2][1]){
			if(checknode[node1][1] ==0){
				changenum = checknode[node2][1];
				checknode[node1][1] = changenum;
			}
			else if(checknode[node2][1] == 0){
				changenum = checknode[node1][1];
				checknode[node2][1] = changenum;
			}
			else{
				changenum =checknode[node1][1];	
				save = checknode[node2][1];			
				for(i=0;i<numofnode;i++){
					if(checknode[i][1] == save){
						checknode[i][1] = changenum;
					}
				}
			}	
			mst += weight[index];
			weight[index] = 2100000000;		
		}
		else if(checknode[node1][1] == 0){
			checknode[node1][1] = forestnum;
			checknode[node2][1] = forestnum;	
			forestnum++;
			mst += weight[index];
			weight[index] = 2100000000;	
		}
		else{
			weight[index] = 2100000000;
		}
		
		for(i=0;i<numofnode;i++){
			if(checknode[i][1] == checknode[0][1]){
				cnt++;
			}
		}
		
		if(cnt == numofnode)
			break;
		
		cnt = 0;
		NULLcnt ++;
		if(NULLcnt >num_of_edge){
			return 2100000000;
		}	
	}
	if(mst == realmst)
		mst = 2100000000;
	return mst;
}
