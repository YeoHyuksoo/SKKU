#include <iostream>
#include <fstream>
#include <algorithm>
#include <vector>

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
	ifs >> m;
	vector< pair<int, pair<int, int> > > d;
	int a, b, weight, max=0;
	for(int i=0;i<m;i++){
		ifs >> a;
		ifs >> b;
		if(a<b){
			if(b>max){
				max=b;
			}
		}
		else{
			if(a>max){
				max=a;
			}
		}
		ifs >> weight;
		d.push_back(make_pair(weight, make_pair(a, b)));
	}
	sort(d.begin(), d.end());
	int* parent;
	parent = new int[max+1];
	for(int i=0;i<max+1;i++){
		parent[i]=i;
	}
	int cost=0;
	int x, y, w;
	for(int i=0;i<d.size();i++){
		x = d[i].second.first;
		y = d[i].second.second;
		w = d[i].first;
		if(find_set(x, parent)!=find_set(y, parent)){
			cost+=w;
			union_set(x, y, parent);
		}
	}
	ofs << cost;
	ifs.close();
	ofs.close();
}
