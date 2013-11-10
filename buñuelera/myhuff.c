#include <stdio.h>
int nodes[512][3];

typedef struct node Node;

int freq[]= {85, 62, 61, 59, 55, 47, 23, 17, 17, 15, 11, 11, 10, 10, 04, 02};


//int freq[]= {5, 7, 10, 15, 20, 45};
int pila[16];
int lenw[16];
int doble, elems= 16;
//int doble, elems= 6;
int i, min1, min2, mind1, mind2, sp= 0;

int main(){

  for ( i= 0; i<16; i++ )
    lenw[i]= 0;

  for ( i= 1; i<elems+1; i++ )
    nodes[i][0]= freq[i-1],
    nodes[i][1]= 0,
    nodes[i][2]= 0;

  doble= elems<<1;
  while ( ++elems<doble ){
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
  pila[sp]= - --elems;
  elems= nodes[elems][1];
  while ( sp>=0 ){
  printf( "%d,%d \n", elems, pila[sp]);
    if( nodes[elems][1] )
      pila[++sp]= -elems,
      elems= nodes[elems][1];
    else{
      lenw[sp]++;
      if( pila[sp]>0 )
        while ( (elems= pila[--sp])>0 );
      elems= nodes[-pila[sp]][2];
      pila[sp]= -pila[sp];
    }
      
  }
  for ( i= 0; i<16; i++ )
    printf("%d,", lenw[i]);
}