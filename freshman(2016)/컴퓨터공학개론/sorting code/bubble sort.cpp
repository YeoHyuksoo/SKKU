void bubbleSort(int *data, int length){

	int firstUnsorted;
	int swapFlag;
	
	firstUnsorted = 0;
	swapFlag = 1;

	while(firstUnsorted<=(length-1) && swapFlag==1){
		
		int index;
		
		index = length -1;
		swapFlag = 0;

		while(1){

			int temp;

			if(data[index]<data[index-1]){
                temp=data[index];
                data[index]=data[index-1];
                data[index-1]=temp;
            }
            index--;//bubbling
            if(index==firstUnsorted)break;
		}
		swapFlag=1;
		firstUnsorted++;
	}
}
