void quickSort(int *data, int first, int last){
    
    if(first < last){
        
        int splitPoint;
        
        splitPoint = split(data, first, last);
        
        quickSort(data,first,splitPoint-1);
        quickSort(data,splitPoint+1,last);
        
    }
}

int split(int *data, int first, int last){
    
    int left;
    int right;
    int splitPoint;
    int splitVal;
    int temp;
    
    left = first + 1;
    right = last;
    splitVal = data[first];
    
    while(left <= right){
        while(data[left]<=splitVal || left<=right){
                left++;
        }
        while(data[right]>splitVal || left<=right){
                right--;
        }
        if(left < right){
            temp=data[left];
            data[left]=data[right];
            data[right]=temp;
            left++;
            right--;//data swap
        }
    }
    temp=data[right];
    data[right]=data[first];
    data[first]=temp;
    splitPoint=right;
    
	return splitPoint;
}
