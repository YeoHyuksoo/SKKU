#include<stdio.h>
#include<time.h>
#include<stdlib.h>

int matrix[10000][10000];

int main(void)
{
    int n,i,j;
    float prob;
    srand((unsigned)time(NULL));
    scanf("%d",&n);
freopen("input.txt","w",stdout);
    for(i=0;i<n;i++)
    {
        for(j=0;j<n;j++)
        {
            prob=(float)rand()/(float)RAND_MAX;
            if(prob>0.1)
            matrix[i][j]=0;
            else
            matrix[i][j]=rand()%1000;
        }
    }

    for(i=0;i<n;i++)
    {
        for(j=0;j<n;j++)
        printf("%d ",matrix[i][j]);
        printf("\n");
    }
}
