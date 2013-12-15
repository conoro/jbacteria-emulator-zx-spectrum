#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]){
  unsigned short table[0xa0];
  FILE *fo= fopen("table.bin", "wb+");
  for ( int i= 0x20; i<0xc0; i++ )
    table[i-0x20]= 0x4000 | i<<8&0x700 | i<<2&0xe0 | i<<5&0x1800;
  fwrite(table, 1, 0x140, fo);
}
