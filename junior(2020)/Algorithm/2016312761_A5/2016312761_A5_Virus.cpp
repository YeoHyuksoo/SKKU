#include <stdio.h>
#include <algorithm>
#include <fstream>
#include <vector>
#include <cmath>
#include <queue>

using namespace std;

int main(int argc, char* argv[]){
	ifstream ifs;
	ifs.open(argv[1]);
	ofstream ofs;
	ofs.open(argv[2]);
	int v, e, root;
	ifs >> v >> e >> root;
	int* parent;
	parent = new int[v+1];
	for(int i=1;i<=v;i++){
		parent[i]=i;
	}
	int a, b, w;
	vector <pair<int, int>> info[v+1];
	for(int i=0;i<e;i++){
		ifs >> a >> b >> w;
		info[a].push_back({b, w});
		info[b].push_back({a, w});
	}
	int* dist;
	dist = new int[v+1];
	for(int i=1;i<=v;i++){
		dist[i]=2147483647;
	}
	dist[root]=0;
	
	priority_queue<pair<int, int> > pq;
	pq.push({0, root});
	while(!pq.empty()){
		int weight = pq.top().first;
		int curr = pq.top().second;
		pq.pop();
        int next, cost;
        for(int i=0;i<info[curr].size();i++){
            next=info[curr][i].first;
            cost=info[curr][i].second;
            if(dist[next]>dist[curr]+cost){
                dist[next]=dist[curr]+cost;
                pq.push({dist[next], next});
            }
        }
	}
	int count=0;
	int lastinfect = 0;
	for(int i=1;i<=v;i++){
		if(dist[i]!=2147483647){
			if(lastinfect<dist[i]){
				lastinfect=dist[i];
			}
			count++;
		}
    }
	delete [] parent;
	delete [] dist;
	ofs << count << " " << lastinfect;
	ifs.close();
	ofs.close();
}
