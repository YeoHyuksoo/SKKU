void insertionSort(int *data, int length){

	int current;

	current = 1;
	while(current<length ){

		int index;
		int placeFound=0;

		index = current;

		while(index>0 && placeFound==0){

			int temp;
			if(data[index]<data[index-1]){
				temp=data[index];
                data[index]=data[index-1];
                data[index-1]=temp;//swap
                index--;
            }
			
			else placeFound=1;
		}
		current++;
	}
}
