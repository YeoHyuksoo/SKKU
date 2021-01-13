void selectionSort(int *data, int length){
    
    int firstUnsorted;
    
    firstUnsorted = 0;
    while(firstUnsorted<length-1){
        
        int indexOfSmallest;
        int index;
        int temp;
        
        indexOfSmallest = firstUnsorted;
        index = firstUnsorted + 1;
        
        while(index<=length-1){
            if(data[index]<data[indexOfSmallest]){
                indexOfSmallest=index;
            }
            index++;
        }
        
        temp=data[firstUnsorted];
        data[firstUnsorted]=data[indexOfSmallest];
        data[indexOfSmallest]=temp;//choice the smallest and swap
        
        firstUnsorted++;
    }
    
}
