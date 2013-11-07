#include <stdio.h>
int nodes[512][3];

typedef struct node Node;

int freq[]= {5, 7, 10, 15, 20, 45};
int elems= 6;
int i, min1, min2, mind1, mind2;

int main(){

  for ( i= 1; i<elems+1; i++ )
    nodes[i][0]= freq[i-1],
    nodes[i][1]= 0,
    nodes[i][2]= 0;

  while ( ++elems<12 ){
    min1= min2= mind1= mind2= 1e8;
    for ( i= 1; i<elems; i++ )
      if( nodes[i][0] && nodes[i][0]<min2 ){
        if( nodes[i][0]<min1 )
          mind2= mind1,
          min2= min1,
          mind1= i,
          min1= nodes[i][0];
        else
          mind2= i,
          min2= nodes[i][0];
      }
    nodes[elems][0]= min1+min2;
    nodes[elems][1]= mind1;
    nodes[elems][2]= mind2;
    nodes[mind1][0]= nodes[mind2][0]= 0;
  }
  for ( i= 1; i<12; i++ )
    printf("[%d,%d,%d] ", nodes[i][0], nodes[i][1], nodes[i][2]);
/*  Node tree[6*2];
  for ( i= 0; i<6; i++ )
    tree[i]->value= freq[i],
    tree[i]->left= NULL,
    tree[i]->right= NULL;*/

}