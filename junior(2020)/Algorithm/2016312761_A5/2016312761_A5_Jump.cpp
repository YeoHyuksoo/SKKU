#include <stdio.h>
#include <algorithm>
#include <fstream>
#include <vector>
#include <cmath>
#include <queue>

#define DMAX 1e12

using namespace std;

int main(int argc, char* argv[]){
	ifstream ifs;
	ifs.open(argv[1]);
	ofstream ofs;
	ofs.open(argv[2]);
	int n, g;
	ifs >> n >> g;
	
	int a, b;
	vector <pair<int, int>> stone;
	stone.push_back({0, 0});
	for(int i=0;i<n;i++){
		ifs >> a >> b;
		stone.push_back({a, b});
	}
	vector <pair<int, int>> edge;
	for(int i=0;i<stone.size();i++){
		for(int j=i+1;j<stone.size();j++){
			if(abs(stone[i].first-stone[j].first)<=2 && abs(stone[i].second-stone[j].second)<=2){
				//valid edge
				edge.push_back({i, j});
				edge.push_back({j, i});
			}
		}
	}
	double* dist;
	dist = new double[stone.size()];
	for(int i=0;i<stone.size();i++){
		dist[i]=(double)DMAX;
	}
	dist[0]=(double)0;
	
	priority_queue<pair<double, int> > pq;
	pq.push({0, 0});
	while(!pq.empty()){
		double weight = pq.top().first;
		int curr = pq.top().second;
		pq.pop();
        int next;
		double cost;
        for(int i=0;i<edge.size();i++){
        	if(edge[i].first==curr || edge[i].second==curr){
        		if(edge[i].first==curr){
        			next = edge[i].second;
        			cost = sqrt(pow(stone[edge[i].second].first-stone[curr].first, 2) + pow(stone[edge[i].second].second-stone[curr].second, 2));
					
				}
				else{
					next = edge[i].first;
					cost = sqrt(pow(stone[edge[i].first].first-stone[curr].first, 2) + pow(stone[edge[i].first].second-stone[curr].second, 2));
					
				}
				if(dist[next]>dist[curr]+cost){
                	dist[next]=dist[curr]+cost;
                	pq.push({dist[next], next});
            	}
			}
        }
	}
	double res=(double)DMAX;
	for(int i=0;i<n;i++){
		if(stone[i].second==g){
			if(dist[i]<res){
				res=dist[i];
			}
		}
	}
	ofs << round(res);
	delete [] dist;
	ifs.close();
	ofs.close();
}
