#include <iostream>
#include <fstream>

using namespace std;

int find_set(int x, int* parent){
	while(parent[x]!=x){
		x=parent[x];
	}
	return x;
}

void union_set(int x, int y, int* parent){
	int _x = find_set(x, parent);
	int _y = find_set(y, parent);
	if(parent[_x]!=parent[_y]){
		parent[_x]=parent[_y];
	}
}

int main(int argc, char* argv[]){
	ifstream ifs;
	ifs.open(argv[1]);
	ofstream ofs;
	ofs.open(argv[2]);
	int n, m;
	ifs >> n;
	int* parent;
	parent = new int[n];
	for(int i=0;i<n;i++){
		parent[i]=i;
	}
	ifs >> m;
	int cmd, a, b;
	for(int i=0;i<m;i++){
		ifs >> cmd;
		ifs >> a;
		ifs >> b;
		if(cmd==0){
			union_set(a, b, parent);
		}
		else{
			int pa=find_set(a, parent);
			int pb=find_set(b, parent);
			if(pa==pb){
				ofs << "Y\n";
			}
			else{
				ofs << "N\n";
			}
		}
	}
	ifs.close();
	ofs.close();
}
