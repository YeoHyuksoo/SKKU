#include <cstdio>
#include <chrono>
#include <fstream>

using namespace std;

/////////////////////////////////////////////////
//////////////// YOUR PLAYGROUND ////////////////
/////////////////////////////////////////////////

// You are NOT ALLOWED to add any header file

void quickSort(int s, int f, int* arr){
	int pivot, left, right, temp;
	if(s>=f){
		return;
	}
	pivot = s;
	left = s+1;
	right = f;
	while(left<=right){
		while(arr[pivot]>=arr[left] && left<=f) left++;
		while(arr[pivot]<=arr[right] && right>s) right--;
	//catch swap elements
		if(left<=right){
			temp=arr[left];
			arr[left]=arr[right];
			arr[right]=temp;
		}
		else{
			temp=arr[pivot];
			arr[pivot]=arr[right];
			arr[right]=temp;
		}
	}
	quickSort(s, right-1, arr);
	quickSort(right+1, f, arr);
}

void heapify(int root, int k, int* data){
    if(root>=k/2){//not in max heap
		return;
	}
    int maxele=root, childs=2*root;
    
    if(data[childs+1]>data[root]){
    	maxele=childs+1;
	}
	if(childs+2<k){
		if(data[childs+2]>data[maxele]){
			maxele=childs+2;
		}
	}
    if(maxele==root){//not exists no change
    	return;
	}
    int temp = data[root];
    data[root] = data[maxele];
    data[maxele] = temp;
    heapify(maxele, k, data);
    
    return;
}

void buildHeap(int k, int* data){
	heapify(0, k, data);
	if(data[0]!=0){
		for(int i=1;i<=k/2-1;i++){
    		heapify(i, k, data);
		}
	}
    return;
} 

void Find_K_Smallest(int n, int *data, int k, int *result){
	// You should fill 'result' array with K smallest values of 'data'
    buildHeap(k, data);//set half maxheap

    for(int i=k;i<n;i++){
        if(data[0]>=data[i]){
        	data[0]=data[i];
            heapify(0, k, data);
		}
    }
    quickSort(0, k, data);
    for(int i=0;i<k;i++){
    	result[i] = data[i];
	}
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////


int main()
{
	/*if( argc != 3 )
	{
		fprintf( stderr , "USAGE:  EXECUTABLE   INPUT_FILE_NAME   OUTPUT_FILE_NAME\n");
		return 1;
	}*/

	// Get input from a binary file whose name is provided from the command line
	int N, K, *data, *result;
	ifstream ifs;
	ifs.open("input.txt");
	ifs >> N;
	ifs >> K;
	data = new int [ N ];
	for(int i=0;i<N;i++){
		ifs >> data[i];
	}
	/*FILE *input = fopen( "input.txt" , "r" );
	int e = fread( &N , sizeof(int) , 1 , input );
	printf("%d\n", N);
	e = fread( &K , sizeof(int) , 1 , input );
	data = new int [ N ];
	e = fread( data , sizeof(int) , N , input );
	fclose(input);*/
	ifs.close();

	result = new int [ K ];	

	std::chrono::time_point<std::chrono::system_clock> start = std::chrono::system_clock::now();

	// Call your function
	Find_K_Smallest( N , data , K , result );

	std::chrono::time_point<std::chrono::system_clock> end = std::chrono::system_clock::now();
	std::chrono::milliseconds elapsed_time = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
	double res_time = elapsed_time.count();

	// Write the results
	FILE *output = fopen( "output.txt" , "w" );
	fprintf( output , "%d\n" , K );
	for(int i=0;i<K;i++)
	{
		fprintf( output , "%d " , result[i] );
	}
	fprintf( output , "\n%d\n" , (int)res_time );
	fclose(output);

	delete [] data;
	delete [] result;

	return 1;
}
