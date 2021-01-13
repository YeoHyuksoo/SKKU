//in ppt

void mergeSort(int *data, int first, int last){
	int middle = 0;

	if(first < last){
		
		middle = (first + last) / 2;

		mergeSort(data, first, middle);
		mergeSort(data, middle+1, last);
		merge(data, first, middle, last);
	}
}

void merge(int *data, int first, int middle, int last){

	int n1,n2,i,j;
	n1=middle-first+1;
	n2=last-middle;
	int *L=(int*)malloc(sizeof(int)*(n1+1));
    int *R=(int*)malloc(sizeof(int)*(n2+1));
    for(i=0;i<n1;i++){
    	L[i]=data[first+i];
	}
	for(j=0;j<n2;j++){
		R[j]=data[middle+j+1];
	}
	L[n1]=210000000;
	R[n2]=210000000;
	i=0;
	j=0;
	for(k=first;k<=last;k++){
		if(L[i]<=R[j]){
			data[k]=L[i];
			i++;
		}
		else {
			data[k]=R[j];
			j++;
		}
	}
}

