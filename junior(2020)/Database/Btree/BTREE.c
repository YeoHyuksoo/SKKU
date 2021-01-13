#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#include "BTREE.h"

void BTreeInit(int _t)
{
	root = NULL;  t = _t - 1;
}


void traverse()
{
	if (root != NULL) _traverse(root);
}


BTreeNode* search(int k)
{
	return (root == NULL) ? NULL : _search(root, k);
}


BTreeNode* _createNode(bool _leaf)
{
	BTreeNode* newNode = (BTreeNode*)malloc(sizeof(BTreeNode));
	int i;

	// Copy the given leaf property
	newNode->leaf = _leaf;

	// Allocate memory for maximum number of possible keys
	// and child pointers
	newNode->keys = (int*)malloc(sizeof(int) * (t + 1));
	newNode->C = (BTreeNode**)malloc(sizeof(BTreeNode*)*(t + 2));

	// Initialize child
	for (i = 0; i < t + 2; i++)
		newNode->C[i] = NULL;

	// Initialize the number of keys as 0
	newNode->n = 0;

	// Initialize parent
	newNode->P = NULL;

	return newNode;
}




void _traverse(BTreeNode* present)
{
	// There are n keys and n+1 children, travers through n keys and first n children
	int i;
	for (i = 0; i < present->n; i++)
	{
		// If this is not leaf, then before printing key[i],
		// traverse the subtree rooted with child C[i].
		if (present->leaf == false)
			_traverse(present->C[i]);

		printf(" ");
		printf("%d", present->keys[i]);
	}

	// Print the subtree rooted with last child
	if (present->leaf == false)
		_traverse(present->C[i]);
}


BTreeNode* _search(BTreeNode* present, int k)
{
	// Find the first key greater than or equal to k
	int i = 0;
	while (i < present->n && k > present->keys[i])
		i++;

	// If the found key is equal to k, return this node
	if (present->keys[i] == k)
		return present;

	// If key is not found here and this is a leaf node
	if (present->leaf == true)
		return NULL;

	// Go to the appropriate child
	return _search(present->C[i], k);
}

int flag;
void insertElement(int k)
{
	// Find key in this tree, and If there is a key, it prints error message.
	if (search(k) != NULL)
	{
		printf("The tree already has %d \n", k);
		return;
	}

	// If tree is empty
	if (root == NULL)
	{
		// Allocate memory for root
		root = _createNode(true);
		root->P = NULL; // Init parent
		root->keys[0] = k;  // Insert key
		root->n = 1;  // Update number of keys in root
	}
	else{ // If tree is not empty
		flag=0;
		_insert(root, k);
	}
}

void _insert(BTreeNode* present, int k)
{
	//-------------------------------------------------------------------------------------------------------
	//Write your code.
	int i, j;
	for(i=0;i<present->n;i++){
		if(present->keys[i]>k){
			if(present->C[i]!=NULL){
				_insert(present->C[i], k);
				break;
			}
			else{
				for(j=present->n;j>i;j--){
					present->keys[j]=present->keys[j-1];
				}
				present->keys[i]=k;
				present->n++;
				flag=1;
				break;
			}
		}
	}
	if(i==present->n && present->keys[i]!=k && flag==0){
		if(present->C[i]!=NULL){
			_insert(present->C[i], k);
		}
		else{
			present->keys[i]=k;
			present->n++;
			flag=1;
		}
	}
	if(present->n==t+1){//split
		if(present->P==NULL){//no parent
			BTreeNode* newRoot = _createNode(false);
			newRoot->C[0] = present;
			newRoot->C[1] = _createNode(true);
			if((t+1)%2==0){
				newRoot->keys[0]=present->keys[t/2];
				newRoot->n = 1;
				for(i=t/2+1;i<present->n;i++){
					newRoot->C[1]->keys[i-t/2-1] = present->keys[i];
				}
				present->P = newRoot;
				present->n = t/2;
				newRoot->C[1]->P = newRoot;
				newRoot->C[1]->n = t/2+1;
			}
			else{
				newRoot->keys[0]=present->keys[t/2];
				newRoot->n = 1;
				for(i=t/2+1;i<present->n;i++){
					newRoot->C[1]->keys[i-t/2-1] = present->keys[i];
				}
				present->P = newRoot;
				present->n = t/2;
				newRoot->C[1]->P = newRoot;
				newRoot->C[1]->n = t/2;
			}
			if(present->C[0]!=NULL){
				newRoot->C[1]->leaf = false;
				for(i=t/2+1;i<=t+1;i++){
					newRoot->C[1]->C[i-t/2-1] = present->C[i];
					newRoot->C[1]->C[i-t/2-1]->P = newRoot->C[1];
				}
			}
			root = newRoot;
		}
		else{//yes parent
			for(i=0;i<=t;i++){
				if(present->P->C[i] == present){
					break;
				}
			}
			if((t+1)%2==0){
				for(j=0;j<present->P->n;j++){
					if(present->P->keys[j]>present->keys[t/2]){
						break;
					}
				}
				for(k=present->P->n;k>j;k--){
					present->P->keys[k]=present->P->keys[k-1];
				}
				present->P->keys[j]=present->keys[t/2];
				present->P->n++;
				int c=i+1;
				while(1){
					if(present->P->C[c]!=NULL){
						c++;
					}
					else{
						break;
					}
				}
				for(j=c;j>i+1;j--){
					present->P->C[j]=present->P->C[j-1];
				}
				present->P->C[i+1] = _createNode(true);
				present->P->C[i+1]->P = present->P;
				for(j=t/2+1;j<present->n;j++){
					present->P->C[i+1]->keys[j-t/2-1]=present->keys[j];
				}
				present->n=t/2;
				if(present->C[0]!=NULL){
					int k=0;
					for(j=0;j<=t+1;j++){
						if(present->keys[t/2]<present->C[j]->keys[0]){
							present->P->C[i+1]->C[k] = present->C[j];
							present->C[j]->P = present->P->C[i+1];
							present->P->C[i+1]->leaf = false;
							k++;
						}
					}
				}
				present->P->C[i+1]->n=t/2+1;
			}
			else{
				for(j=0;j<present->P->n;j++){
					if(present->P->keys[j]>present->keys[t/2]){
						break;
					}
				}
				for(k=present->P->n;k>j;k--){
					present->P->keys[k]=present->P->keys[k-1];
				}
				present->P->keys[j]=present->keys[t/2];
				present->P->n++;
				int c=i+1;
				while(1){
					if(present->P->C[c]!=NULL){
						c++;
					}
					else{
						break;
					}
				}
				for(j=c;j>i+1;j--){
					present->P->C[j]=present->P->C[j-1];
				}
				present->P->C[i+1] = _createNode(true);
				present->P->C[i+1]->P = present->P;
				for(j=t/2+1;j<present->n;j++){
					present->P->C[i+1]->keys[j-t/2-1]=present->keys[j];
				}
				present->n=t/2;
				if(present->leaf==false){
					int k=0;
					for(j=0;j<=t+1;j++){
						if(present->keys[t/2]<present->C[j]->keys[0]){
							present->P->C[i+1]->C[k] = present->C[j];
							present->C[j]->P = present->P->C[i+1];
							present->P->C[i+1]->leaf = false;
							k++;
						}
					}
				}
				present->P->C[i+1]->n=t/2;
			}
		}
	}
	//-------------------------------------------------------------------------------------------------------
}


void _balancing(BTreeNode* present)
{
	BTreeNode* parent;

	if (present->n <= t)
	{
		return;
	}
	else if (present->P == NULL)
	{
		root = _splitChild(present);
		return;
	}
	else
	{
		parent = _splitChild(present);
		_balancing(parent);
	}
}


BTreeNode * _splitChild(BTreeNode* present)
{
	//-------------------------------------------------------------------------------------------------------
	//Write your code.
	
	
	//-------------------------------------------------------------------------------------------------------
}


void removeElement(int k)
{
	if (!root)
	{
		printf("The tree is empty\n");
		return;
	}

	// Call the remove function for root
	_remove(root, k);

	// If the root node has 0 keys, make its first child as the new root
	//  if it has a child, otherwise set root as NULL
	if (root->n == 0)
	{
		BTreeNode *tmp = root;
		if (root->leaf)
		{
			root = NULL;
		}
		else
		{
			root = root->C[0];
			root->P = NULL;
		}

		// Free the old root
		free(tmp);
	}
	return;
}

void _remove(BTreeNode* present, int k)
{	
	//-------------------------------------------------------------------------------------------------------
	//Write your code.
	int i, j, l;
	for(i=0;i<present->n;i++){
		if(present->keys[i]>k){
			_remove(present->C[i], k);
			break;
		}
		else if(present->keys[i]==k){
			//delete
			int minkey = t/2;
			if(present->C[0]==NULL){//if this node is leaf node
				if(present->n > minkey){
					for(j=i;j<present->n-1;j++){
						present->keys[j]=present->keys[j+1];
					}
					present->n--;
				}
				else{//should borrow
					j=0;
					while(1){
						if(present->P->C[j]==present){
							break;
						}
						j++;
					}
					if(j>=1 && present->P->C[j-1]->n > minkey){//left sibling
						for(l=i;l>0;l--){
							present->keys[l]=present->keys[l-1];
						}
						present->keys[0]=present->P->keys[j-1];
						present->P->keys[j-1]=present->P->C[j-1]->keys[present->P->C[j-1]->n-1];
						present->P->C[j-1]->n--;
					}
					else if(j<present->P->n && present->P->C[j+1]->n > minkey){//right sibling
						for(l=present->n-1;l>i;l--){
							present->keys[l+1]=present->keys[l];
						}
						present->keys[i]=present->P->keys[j];
						present->P->keys[j]=present->P->C[j+1]->keys[0];
						for(l=1;l<present->P->C[j+1]->n;l++){
							present->P->C[j+1]->keys[l-1] = present->P->C[j+1]->keys[l];
						}
						present->P->C[j+1]->n--;
					}
					else{//both side can't borrow -> merge
						if(j>=1){//merge with left sibling
							present->P->C[j-1]->keys[present->P->C[j-1]->n++] = present->P->keys[j-1];
							for(l=0;l<present->n;l++){
								if(i!=l)
									present->P->C[j-1]->keys[present->P->C[j-1]->n++] = present->keys[l];
							}
							for(l=j;l<present->P->n;l++){
								present->P->keys[l-1] = present->P->keys[l];
							}
							while(present->P->C[j+1]!=NULL){
								present->P->C[j]=present->P->C[j+1];
								j++;
							}
							present->P->n--;
							if(present->P->n<minkey){
								for(l=0;l<=present->P->P->n;l++){
									if(present->P->P->C[l]==present->P){
										break;
									}
								}
								if(l>=1 && present->P->P->C[l-1]->n > minkey){
									_borrowFromLeft(present->P, l-1);
								}
								else if(l<present->P->P->n && present->P->P->C[l+1]->n > minkey){
									_borrowFromRight(present->P, l);
								}
								else{
									_merge(present->P);
								}
							}
						}
						else{//with right sibling
							for(l=i;l<present->n-1;l++){
								present->keys[l]=present->keys[l+1];
							}
							present->n--;
							present->P->C[j]->keys[present->P->C[j]->n++] = present->P->keys[j];
							for(l=0;l<present->P->C[j+1]->n;l++){
								present->keys[present->n++] = present->P->C[j+1]->keys[l];
							}
							for(l=j+1;l<present->P->n;l++){
								present->P->keys[l-1] = present->P->keys[l];
							}
							while(present->P->C[j+2]!=NULL){
								present->P->C[j+1]=present->P->C[j+2];
								j++;
							}
							present->P->n--;
							if(present->P->n<minkey){
								for(l=0;l<=present->P->P->n;l++){
									if(present->P->P->C[l]==present->P){
										break;
									}
								}
								if(l>=1 && present->P->P->C[l-1]->n > minkey){
									_borrowFromLeft(present->P, l-1);
								}
								else if(l<present->P->P->n && present->P->P->C[l+1]->n > minkey){
									_borrowFromRight(present->P, l);
								}
								else{
									_merge(present->P);
								}
							}
						}
					}
				}
			}
			else{//internal node
				BTreeNode* newNode = present->C[i];//leftchild
				while(newNode->C[newNode->n]!=NULL){
					newNode = newNode->C[newNode->n];
				}
				if(newNode->n > minkey){//just change
					present->keys[i]=newNode->keys[--newNode->n];
				}
				else{
					newNode = present->C[i+1];//rightchild
					while(newNode->C[0]!=NULL){
						newNode = newNode->C[0];
					}
					if(newNode->n > minkey){//just change
						present->keys[i]=newNode->keys[--newNode->n];
					}
					else{//merge
						if(present == root){
							for(j=i;j<present->n;j++){
								present->keys[j]=present->keys[j+1];
							}
							for(j=0;j<present->C[i+1]->C[0]->n;j++){
								present->C[i]->C[present->C[i]->n]->keys[present->C[i]->C[present->C[i]->n]->n+j]=present->C[i+1]->C[0]->keys[j];
							}
							if(present->C[i+1]->C[0]->C[0]!=NULL){
								for(j=0;j<=present->C[i+1]->C[0]->n;j++){
									present->C[i]->C[present->C[i]->n]->n++;
									present->C[i]->C[present->C[i]->n]->C[present->C[i]->C[present->C[i]->n]->n]=present->C[i+1]->C[0]->C[j];
								}
							}
							else{
								present->C[i]->C[present->C[i]->n]->n+=present->C[i+1]->C[0]->n;
							}
							for(j=0;j<present->C[i+1]->n;j++){
								present->C[i]->keys[present->C[i]->n++]=present->C[i+1]->keys[j];
								present->C[i]->C[present->C[i]->n]=present->C[i+1]->C[j+1];
								present->C[i+1]->C[j]->P = present->C[i];
							}
							for(j=present->n;j>i+1;j--){
								present->C[j-1]=present->C[j];
							}
							present->n--;
						}
						else{
							for(j=i;j<present->n;j++){
								present->keys[j]=present->keys[j+1];
							}
							if(present->C[i+1]->C[0]!=NULL){
								for(j=0;j<present->C[i+1]->C[0]->n;j++){
									present->C[i]->C[present->C[i]->n]->keys[present->C[i]->C[present->C[i]->n]->n+j]=present->C[i+1]->C[0]->keys[j];
								}
								if(present->C[i+1]->C[0]->C[0]!=NULL){
									for(j=0;j<=present->C[i+1]->C[0]->n;j++){
										present->C[i]->C[present->C[i]->n]->n++;
										present->C[i]->C[present->C[i]->n]->C[present->C[i]->C[present->C[i]->n]->n]=present->C[i+1]->C[0]->C[j];
									}
								}
								else{
									present->C[i]->C[present->C[i]->n]->n+=present->C[i+1]->C[0]->n;
								}
							}
							for(j=0;j<present->C[i+1]->n;j++){
								present->C[i]->keys[present->C[i]->n++]=present->C[i+1]->keys[j];
								if(present->C[i+1]->C[0]!=NULL){
									present->C[i]->C[present->C[i]->n]=present->C[i+1]->C[j+1];
									present->C[i+1]->C[j]->P = present->C[i];
								}
							}
							for(j=present->n;j>i+1;j--){
								present->C[j-1]=present->C[j];
							}
							present->n--;
							if(present->n < minkey){
								for(l=0;l<=present->P->n;l++){
									if(present->P->C[l]==present){
										break;
									}
								}
								if(l>=1 && present->P->C[l-1]->n > minkey){
									_borrowFromLeft(present, l-1);
								}
								else if(l<present->P->n && present->P->C[l+1]->n > minkey){
									_borrowFromRight(present, l);
								}
								else{
									_merge(present);
								}
							}
						}
					}
				}
			}
			break;
		}
		else if(i==present->n-1){
			_remove(present->C[i+1], k);
			break;
		}
	}
	
	//-------------------------------------------------------------------------------------------------------
}

void _balancingAfterDel(BTreeNode* present) // repair After Delete
{
	int minKeys = (t + 2) / 2 - 1;
	BTreeNode* parent;
	BTreeNode* next;
	int parentIndex = 0;

	if (present->n < minKeys)
	{
		if (present->P == NULL)
		{
			if (present->n == 0)
			{
				root = present->C[0];
				if (root != NULL)
					root->P = NULL;
			}
		}
		else
		{//not root node
			parent = present->P;
			for (parentIndex = 0; parent->C[parentIndex] != present; parentIndex++);
			if (parentIndex > 0 && parent->C[parentIndex - 1]->n > minKeys)
			{
				_borrowFromLeft(present, parentIndex);

			}
			else if (parentIndex < parent->n && parent->C[parentIndex + 1]->n >minKeys)
			{
				_borrowFromRight(present, parentIndex);
			}
			else if (parentIndex == 0)
			{
				// Merge with right sibling
				next = _merge(present);
				_balancingAfterDel(next->P);
			}
			else
			{
				// Merge with left sibling
				next = _merge(parent->C[parentIndex - 1]);
				_balancingAfterDel(next->P);

			}

		}
	}
}


void _borrowFromRight(BTreeNode* present, int parentIdx)
{
	//-------------------------------------------------------------------------------------------------------
	//Write your code.
	int i;
	present->keys[present->n++] = present->P->keys[parentIdx];
	present->P->keys[parentIdx] = present->P->C[parentIdx+1]->keys[0];
	for(i=1;i<present->P->C[parentIdx+1]->n;i++){
		present->P->C[parentIdx+1]->keys[i-1]=present->P->C[parentIdx+1]->keys[i];
	}
	present->C[present->n]=present->P->C[parentIdx+1]->C[0];
	present->P->C[parentIdx+1]->C[0]->P = present;
	for(i=1;i<=present->P->C[parentIdx+1]->n;i++){
		present->P->C[parentIdx+1]->C[i-1]=present->P->C[parentIdx+1]->C[i];
	}
	present->P->C[parentIdx+1]->n--;
	
	//-------------------------------------------------------------------------------------------------------
}


void _borrowFromLeft(BTreeNode* present, int parentIdx)
{
	//-------------------------------------------------------------------------------------------------------
	//Write your code.
	int i;
	for(i=present->n;i>0;i--){
		present->keys[i]=present->keys[i-1];
	}
	present->keys[0] = present->P->keys[parentIdx];
	present->n++;
	present->P->keys[parentIdx] = present->P->C[parentIdx]->keys[present->P->C[parentIdx]->n-1];
	for(i=present->n;i>0;i--){
		present->C[i]=present->C[i-1];
	}
	present->C[0]=present->P->C[parentIdx]->C[present->P->C[parentIdx]->n];
	present->P->C[parentIdx]->C[present->P->C[parentIdx]->n]->P = present;
	present->P->C[parentIdx]->n--;
	
	//-------------------------------------------------------------------------------------------------------
}


BTreeNode* _merge(BTreeNode* present)
{
	//-------------------------------------------------------------------------------------------------------
	//Write your code.
	int i, j;
	for(i=0;i<=present->P->n;i++){
		if(present->P->C[i] == present){
			break;
		}
	}
	if(i>=1){//left sibling merge
		for(j=0;j<=present->n;j++){
			present->P->C[i-1]->C[present->P->C[i-1]->n+j+1] = present->C[j];
			present->C[j]->P = present->P->C[i-1];
		}
		present->P->C[i-1]->keys[present->P->C[i-1]->n] = present->P->keys[i-1];
		for(j=0;j<present->n;j++){
			present->P->C[i-1]->keys[present->P->C[i-1]->n+j+1] = present->keys[j];
		}
		present->P->C[i-1]->n+=j+1;
		while(present->P->C[i+1]!=NULL){
			present->P->C[i]=present->P->C[i+1];
		}
		for(j=i;j<present->P->n;j++){
			present->P->keys[j-1]=present->P->keys[j];
		}
		present->P->n--;
	}
	else{//right sibling merge
		for(j=0;j<=present->P->C[1]->n;j++)
			present->C[present->n+j+1] = present->P->C[1]->C[j];
		present->keys[present->n] = present->P->keys[0];
		for(j=0;j<present->P->C[1]->n;j++){
			present->keys[present->n+j+1] = present->P->C[1]->keys[j];
		}
		present->n+=j+1;
		while(present->P->C[i+2]!=NULL){
			present->P->C[i+1]=present->P->C[i+2];
		}
		for(j=0;j<present->P->n-1;j++){
			present->P->keys[j]=present->P->keys[j+1];
		}
		present->P->n--;
	}
	if(present->P != root && present->P->n < (int)t/2){
		int l;
		for(l=0;l<=present->P->P->n;l++){
			if(present->P->P->C[l]==present->P){
				break;
			}
		}
		if(l>=1 && present->P->P->C[l-1]->n > (int)t/2){
			_borrowFromLeft(present->P, l-1);
		}
		else if(l<present->P->P->n && present->P->P->C[l+1]->n > (int)t/2){
			_borrowFromRight(present->P, l);
		}
		else{
			_merge(present->P);
		}
	}
	//-------------------------------------------------------------------------------------------------------
}


int _getLevel(BTreeNode* present)//leafnode level: 1
{
	int i;
	int maxLevel = 0;
	int temp;
	if (present == NULL) return maxLevel;
	if (present->leaf == true)
		return maxLevel + 1;

	for (i = 0; i < present->n + 1; i++)
	{
		temp = _getLevel(present->C[i]);

		if (temp > maxLevel)
			maxLevel = temp;
	}

	return maxLevel + 1;
}

void _getNumberOfNodes(BTreeNode* present, int* numNodes, int level)
{
	int i;
	if (present == NULL) return;

	if (present->leaf == false)
	{
		for (i = 0; i < present->n + 1; i++)
			_getNumberOfNodes(present->C[i], numNodes, level + 1);
	}
	numNodes[level] += 1;
}

void _mappingNodes(BTreeNode* present, BTreeNode ***nodePtr, int* numNodes, int level)
{
	int i;
	if (present == NULL) return;

	if (present->leaf == false)
	{
		for (i = 0; i < present->n + 1; i++)
			_mappingNodes(present->C[i], nodePtr, numNodes, level + 1);
	}

	nodePtr[level][numNodes[level]] = present;
	numNodes[level] += 1;
}


void printTree()
{
	int level;
	int *numNodes;
	int i, j, k;

	level = _getLevel(root);
	numNodes = (int *)malloc(sizeof(int) * (level));
	memset(numNodes, 0, level * sizeof(int));

	_getNumberOfNodes(root, numNodes, 0);

	BTreeNode ***nodePtr;
	nodePtr = (BTreeNode***)malloc(sizeof(BTreeNode**) * level);
	for (i = 0; i < level; i++) {
		nodePtr[i] = (BTreeNode**)malloc(sizeof(BTreeNode*) * numNodes[i]);
	}

	memset(numNodes, 0, level * sizeof(int));
	_mappingNodes(root, nodePtr, numNodes, 0);

	for (i = 0; i < level; i++) {
		for (j = 0; j < numNodes[i]; j++) {
			printf("[");

			for (k = 0; k < nodePtr[i][j]->n; k++)
				printf("%d ", nodePtr[i][j]->keys[k]);

			printf("] ");
		}
		printf("\n");
	}

	for (i = 0; i < level; i++) {
		free(nodePtr[i]);
	}
	free(nodePtr);
}
/*
int main(void) {
	BTreeInit(3); // Max degree 3
	insertElement(1); insertElement(3); insertElement(7); insertElement(10); insertElement(11); insertElement(13);	insertElement(14);
	insertElement(15); insertElement(18); insertElement(16); insertElement(19); insertElement(24); insertElement(25); insertElement(26);
	printTree();

	removeElement(13);
	printTree();


	

	BTreeInit(4); // Max degree 4
	insertElement(1); insertElement(3); insertElement(7); insertElement(10); insertElement(11); insertElement(13);	insertElement(14);
	insertElement(15); insertElement(18); insertElement(16); insertElement(19); insertElement(24); insertElement(25); insertElement(26);
	printTree();

	removeElement(13);
	printTree();


	BTreeInit(5); // Max degree 5
	insertElement(1); insertElement(2); insertElement(3); insertElement(4);
	printTree();
	printf("\n");

	printf("====== split ======\n");
	insertElement(5); // split
	printTree();
	printf("\n");

	printf("====== balanced tree ======\n");
	insertElement(6); insertElement(7); insertElement(8); insertElement(9);
	insertElement(10); insertElement(11); insertElement(12); insertElement(13);
	insertElement(14); insertElement(15); insertElement(16); insertElement(17);
	printTree();
	printf("\n");

	printf("====== merge ======\n");
	removeElement(12); // merge
	printTree();
	printf("\n");

	insertElement(12);
	printTree();
	printf("\n");

	printf("====== remove root ======\n");
	removeElement(9); // remove root
	printTree();
	printf("\n");

	
	printf("====== remove leaf node ======\n");
	removeElement(11); // remove leaf node
	printTree();
	printf("\n");




	return 0;
}*/
