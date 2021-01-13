#include <iostream>
#include <fstream>
#include <algorithm>
#include <vector>
#include <queue>

using namespace std;

class Graph{
	public :
		int nV, nE;
		pair<double, double>* ver;
		vector< pair<int, double> >* edge;
		Graph() {}
		Graph(FILE* input, int v, int e){
			nV = v;
			nE = e;		
			ver = new pair<double, double> [nV+1];
			edge = new vector< pair<int, double> > [nV+1];
			for(int i=1;i<=nV;i++){
				double x, y;
				fscanf(input, "%lf %lf", &x, &y);
				ver[i] = make_pair(x, y);
			}
			for(int i=0;i<nE;i++){
				int s, f;
				double weight;
				fscanf(input, "%d %d", &s, &f);
				weight = (ver[f].first-ver[s].first)*(ver[f].first-ver[s].first);
				weight+= (ver[f].second-ver[s].second)*(ver[f].second-ver[s].second);
				weight = sqrt(weight);
				edge[s].push_back(make_pair(f, weight));
				edge[f].push_back(make_pair(s, weight));
			}
		}
};

double dijkstra(Graph& _g, int start, int finish, vector<int>& p){
	bool* visit = new bool[_g.nV+1];
	int* prev = new int [_g.nV+1];
	double* dist = new double [_g.nV+1];
	
	for(int i=0;i<=_g.nV;i++){
		visit[i] = false;
		prev[i] = -1;
		dist[i] = std::numeric_limits<double>::max()/(double)2;
	}
	dist[start] = (double)0;

	priority_queue< pair<double, int>, vector< pair<double, int> >, greater< pair<double, int> > > pq;
	pq.push(make_pair((double)0, start));
	for(;;){
		if(pq.empty()){
			break;
		}
		pair<double, int> cur = pq.top();
		pq.pop();
		if(visit[cur.second]) continue;
		visit[cur.second] = true;
		
		for(int i=0;i<_g.edge[cur.second].size();i++){
			int idx = _g.edge[cur.second][i].first;
			double w = _g.edge[cur.second][i].second;
			if(!visit[idx] && (dist[idx] > dist[cur.second]+w)){
				pq.push(make_pair(dist[cur.second]+w, idx));
				prev[idx] = cur.second;
				dist[idx] = dist[cur.second]+w;
			}
		}
	}
	int temp = finish;
	while(prev[temp]!=-1){
		p.push_back(temp);
		temp = prev[temp];
	}
	p.push_back(0);
	
	delete[] visit;
	delete[] prev;
	delete[] dist;
	return dist[finish];
}

int main(){
	FILE* input = fopen("input.txt", "r");
	int v, e, k;
	fscanf(input, "%d", &v);
	fscanf(input, "%d", &e);
	fscanf(input, "%d", &k);
	Graph g(input, v, e);

	vector<int> p;
	if(k==0){
		FILE* output = fopen("output.txt", "w");
		double path = dijkstra(g, 1, v, p);
		fprintf(output, "%d\n1 ", p.size());
		for(int i=p.size()-2;i>=0;i--){
			fprintf(output, "%d ", p[i]);
		}
		cout << path;
		fclose(input);
		return 0;
	}
	int* mid = new int [k];
	int i;
	for(i=0;i<k;i++){
		fscanf(input, "%d", &mid[i]);
	}
	fclose(input);
	
	mid[k] = v;
	int npath=0, res[501];
	double minpath = std::numeric_limits<double>::max()/(double)2;
	do{
		p.clear();
		double temp = (double)0;
		double path = dijkstra(g, 1, mid[0], p);
		if(path<minpath){
			temp+=path;
			for(i=0;i<k;i++){
				path = dijkstra(g, mid[i], mid[i+1], p);
				if(temp+path>=minpath){
					break;
				}
				temp+=path;
			}
			if(i==k && temp<minpath){
				minpath=temp;
				int t=0;
				for(int j=0;j<p.size();j++){
					if(p[j]==0){
						reverse(p.begin()+t, p.begin()+j+1);
						t=j+1;
					}
				}
				int cnt=0;
				for(int j=0;j<p.size();j++){
					if(p[j]==0) continue;
					res[cnt++] = p[j];
				}
				npath=cnt;
			}
		}
	} while(next_permutation(mid, mid+k));
	FILE* output = fopen("output.txt", "w");
	fprintf(output, "%d\n1 ", npath+1);
	for(int i=0;i<npath;i++){
		fprintf(output, "%d ", res[i]);
	}
	cout << minpath;
	
	delete[] mid;
	return 0;
}
