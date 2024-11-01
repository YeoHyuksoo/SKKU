#include <cstdio>
#include <chrono>
#include <cmath>
#include <cstring>
#include <vector>

/////////////////////////////////////////////////
//////////////// YOUR PLAYGROUND ////////////////
/////////////////////////////////////////////////

void quickSort(int s, int f, int* arr);
void countingSort(int n, int* arr);
void bucketSort(int f, std::vector<int> &v, int max);
void radixSort(int n, std::vector<int> &v);

void MyVeryFastSort(int n, int *d)
{
	int min=d[0], max=d[0];
	int i;
	for(i=1;i<n;i++){
		if(d[i]<min){
			min=d[i];
		}
		else if(d[i]>max){
			max=d[i];
		}
	}
	int range = (max-min)/2;
	if(n<=13000){
		quickSort(0, n-1, d);
	}
	else if(n>=20200000){
		countingSort(n, d);
	}
	else if(n<=170000){
		if(range<n*3.3){
			countingSort(n, d);
		}
		else if(range<n*69){
			int j;
			std::vector<int> neg;
			std::vector<int> pos;
			for(i=0;i<n;i++){
        		if(d[i]<0){
        			neg.push_back(d[i]*-1);
        		}
				else{
					pos.push_back(d[i]);
        		}
    		}
			if(neg.size()!=0)
    			radixSort(neg.size(), neg);
			if(pos.size()!=0)
    			radixSort(pos.size(), pos);
    		j=neg.size()-1;
    		for(i=0;i<=j;i++){
        		d[i]=neg[j-i]*-1;
    		}
    		j++;
    		for(;i<n;i++){
        		d[i]=pos[i-j];
			}
		}
		else{
			quickSort(0, n-1, d);
		}
	}
	else if(n<=260000){
		if(range<n*3.5){
			countingSort(n, d);
		}
		else if(range<n*70){
			int j;
			std::vector<int> neg;
			std::vector<int> pos;
			for(i=0;i<n;i++){
        		if(d[i]<0){
        			neg.push_back(d[i]*-1);
        		}
				else{
					pos.push_back(d[i]);
        		}
    		}
			if(neg.size()!=0)
    			radixSort(neg.size(), neg);
			if(pos.size()!=0)
    			radixSort(pos.size(), pos);
    		j=neg.size()-1;
    		for(i=0;i<=j;i++){
        		d[i]=neg[j-i]*-1;
    		}
    		j++;
    		for(;i<n;i++){
        		d[i]=pos[i-j];
			}
		}
		else if(range<165*n){
			std::vector<int> a1;
			std::vector<int> a2;
			for(i=0;i<n;i++){
				if(d[i]<0){
					a1.push_back(d[i]*-1);
				}
				else{
					a2.push_back(d[i]);
				}
			}
			int s1=a1.size(), s2=a2.size();
			if(s1!=0)
				bucketSort(s1, a1, min);
			if(s2!=0)
				bucketSort(s2, a2, max);
			for(i=0;i<s1;i++){
				d[i]=a1[i]*-1;
			}
			for(i=0;i<s2;i++){
				d[s1+i] = a2[i];
			}
		}
		else{
			quickSort(0, n-1, d);
		}
	}
	else if(n<=660000){
		if(range<n*4.1){
			countingSort(n, d);
		}
		else if(range<n*60){
			int j;
			std::vector<int> neg;
			std::vector<int> pos;
			for(i=0;i<n;i++){
        		if(d[i]<0){
        			neg.push_back(d[i]*-1);
        		}
				else{
					pos.push_back(d[i]);
        		}
    		}
			if(neg.size()!=0)
    			radixSort(neg.size(), neg);
			if(pos.size()!=0)
    			radixSort(pos.size(), pos);
    		j=neg.size()-1;
    		for(i=0;i<=j;i++){
        		d[i]=neg[j-i]*-1;
    		}
    		j++;
    		for(;i<n;i++){
        		d[i]=pos[i-j];
			}
		}
		else{
			std::vector<int> a1;
			std::vector<int> a2;
			for(i=0;i<n;i++){
				if(d[i]<0){
					a1.push_back(d[i]*-1);
				}
				else{
					a2.push_back(d[i]);
				}
			}
			int s1=a1.size(), s2=a2.size();
			if(s1!=0)
				bucketSort(s1, a1, min);
			if(s2!=0)
				bucketSort(s2, a2, max);
			for(i=0;i<s1;i++){
				d[i]=a1[i]*-1;
			}
			for(i=0;i<s2;i++){
				d[s1+i] = a2[i];
			}
		}
	}
	else if(n<=1250000){
		if(range<n*4.4){
			countingSort(n, d);
		}
		else if(range<n*74){
			int j;
			std::vector<int> neg;
			std::vector<int> pos;
			for(i=0;i<n;i++){
        		if(d[i]<0){
        			neg.push_back(d[i]*-1);
        		}
				else{
					pos.push_back(d[i]);
        		}
   			}
			if(neg.size()!=0)
    			radixSort(neg.size(), neg);
			if(pos.size()!=0)
    			radixSort(pos.size(), pos);
    		j=neg.size()-1;
   			for(i=0;i<=j;i++){
        		d[i]=neg[j-i]*-1;
    		}
    		j++;
    		for(;i<n;i++){
        		d[i]=pos[i-j];
			}
		}
		else{
			std::vector<int> a1;
			std::vector<int> a2;
			for(i=0;i<n;i++){
				if(d[i]<0){
					a1.push_back(d[i]*-1);
				}
				else{
					a2.push_back(d[i]);
				}
			}
			int s1=a1.size(), s2=a2.size();
			if(s1!=0)
				bucketSort(s1, a1, min);
			if(s2!=0)
				bucketSort(s2, a2, max);
			for(i=0;i<s1;i++){
				d[i]=a1[i]*-1;
			}
			for(i=0;i<s2;i++){
				d[s1+i] = a2[i];
			}
		}
	}
	else if(n<=4250000 || (n>15250000 && n<20200000)){
		if(range<n*4.5){
			countingSort(n, d);
		}
		else{
			int j;
			std::vector<int> neg;
			std::vector<int> pos;
			for(i=0;i<n;i++){
        		if(d[i]<0){
        			neg.push_back(d[i]*-1);
        		}
				else{
					pos.push_back(d[i]);
        		}
   			}
			if(neg.size()!=0)
    			radixSort(neg.size(), neg);
			if(pos.size()!=0)
    			radixSort(pos.size(), pos);
   			j=neg.size()-1;
    		for(i=0;i<=j;i++){
        		d[i]=neg[j-i]*-1;
    		}
    		j++;
    		for(;i<n;i++){
        		d[i]=pos[i-j];
			}
		}
	}
	else{
		if(range<n*5){
			countingSort(n, d);
		}
		else{
			int j;
			std::vector<int> neg;
			std::vector<int> pos;
			for(i=0;i<n;i++){
        		if(d[i]<0){
        			neg.push_back(d[i]*-1);
        		}
				else{
					pos.push_back(d[i]);
       			}
    		}
			if(neg.size()!=0)
    			radixSort(neg.size(), neg);
			if(pos.size()!=0)
    			radixSort(pos.size(), pos);
    		j=neg.size()-1;
    		for(i=0;i<=j;i++){
        		d[i]=neg[j-i]*-1;
    		}
    		j++;
    		for(;i<n;i++){
        		d[i]=pos[i-j];
			}
		}
	}
}

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

void countingSort(int n, int* arr){
	int min=arr[0], max=arr[0];
	int i,j;
	for(i=1;i<n;i++){
		if(arr[i]<min){
			min=arr[i];
		}
		else if(arr[i]>max){
			max=arr[i];
		}
	} 
	int* narr = new int [ max-min+1 ]();
	for(i=0;i<n;i++){
		narr[arr[i]-min]++;
	}
	int cnt=0;
	for(i=0;i<=max-min;i++){
		for(j=0;j<narr[i];j++){
			arr[cnt++]=min+i;
		}
	}
	delete[] narr;
}

void radixSort(int n, std::vector<int> &v){
    int bucket[10];
	int i, digit, lsd=1;
    int max=v[0];
    for(i=1;i<n;i++){
        if(v[i]>max){
            max=v[i];
        }
    }
	int* copy = new int[n];
    while(max/lsd>0){
        memset(bucket, 0, sizeof(int)*10);
        for(i=0;i<n;i++){
            digit=(v[i]/lsd)%10;//가장 작은 자리수 
            bucket[digit]++;//버킷은 갯수만 보관
        }
        for(i=1;i<10;i++){
            bucket[i]=bucket[i]+bucket[i-1];//쌓는다
    	}
        for(i=n-1;i>=0;i--){
            digit=(v[i]/lsd)%10;
            copy[--bucket[digit]]=v[i];
        }
        for(i=0;i<n;i++){
        	v[i]=copy[i];
		}
        lsd*=10;
    }
	delete [] copy;
}

struct bucket{
	int count;
	int* value;
};

void bucketSort(int f, std::vector<int> &v, int max){
	int i,j,k;
	int max2=max;
	if(max<0){
		max*=-1;
	}
	int nbuck = 833;
	bucket* buckets = new bucket[nbuck+1];
	int div = (max+1)/nbuck;
	if((max+1)%nbuck!=0){
		div++;
	}
	for(i=0;i<=nbuck;i++){
		buckets[i].count=0;
		buckets[i].value = new int[ f ];
	}
	for(i=0;i<f;i++){
		buckets[v[i]/div+1].value[++buckets[v[i]/div+1].count] = v[i];
	}
	k=0;
	if(max2<0){
		for(i=nbuck;i>=0;i--){
			if(buckets[i].count>=1){
				quickSort(1, buckets[i].count, buckets[i].value);
				for(j=buckets[i].count;j>0;j--){
					v[k++] = buckets[i].value[j];
				}
			}
			delete [] buckets[i].value;
		}
	}
	else{
		for(i=0;i<=nbuck;i++){
			if(buckets[i].count>=1){
				quickSort(1, buckets[i].count, buckets[i].value);
				for(j=0;j<buckets[i].count;j++){
					v[k+j] = buckets[i].value[j+1];
				}
				k+=buckets[i].count;
			}
			delete [] buckets[i].value;
		}
	}
}

/////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////

// Utilized to check the correctness
bool Validate(int n, int *d)
{
	for(int i=1;i<n;i++)
	{
		if( d[i-1] > d[i] )
		{
			return false;
		}
	}
	return true;
}

int main(int argc, char **argv)
{
	if( argc != 3 )
	{
		fprintf( stderr , "USAGE:  EXECUTABLE   INPUT_FILE_NAME   OUTPUT_FILE_NAME\n");
		return 1;
	}

	// Get input from a binary file whose name is provided from the command line
	int n, *d;
	FILE *input = fopen( argv[1] , "rb" );
	int e = fread( &n , sizeof(int) , 1 , input );
	d = new int [ n ];
	e = fread( d , sizeof(int) , n , input );
	fclose(input);

	std::chrono::time_point<std::chrono::system_clock> start = std::chrono::system_clock::now();

	// Call your sorting algorithm
	MyVeryFastSort( n , d );

	std::chrono::time_point<std::chrono::system_clock> end = std::chrono::system_clock::now();
	std::chrono::milliseconds elapsed_time = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
	double res_time = elapsed_time.count();

	bool res_validate = Validate( n , d );

	// Write the results (correctness and time)
	FILE *output = fopen( argv[2] , "w" );
	if( res_validate ) { fprintf( output , "OKAY\n" ); printf("OKAY\n"); }
	else { fprintf( output , "WRONG\n" ); printf("WRONG\n");  }
	fprintf( output , "%d\n" , (int)res_time );
	printf( "%d\n" , (int)res_time );
	fclose(output);

	delete [] d;

	return 1;
}
