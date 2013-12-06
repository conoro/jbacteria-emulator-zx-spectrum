#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]){
  unsigned short table[0x80];
  FILE *fo= fopen("table.bin", "wb+");
  for ( int i= 0; i<0x40; i++ )
    table[i]= 0x4000 | i<<9&0x700 | i<<3&0xe0 | i<<6&0x1800;
  fwrite(table, 1, 0x80, fo);
}
