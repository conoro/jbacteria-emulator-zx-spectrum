#include <stdio.h>
#include <stdlib.h>
int main(int argc, char* argv[]){
  unsigned char mem[0x10000];
  FILE *fo;
  long length, size;
  if( argc==1 )
    printf("\n"
    "fpad v1.00, generate a file with padded values by Antonio Villena, 24 Apr 2016\n\n"
    "  fpad <length> <byte> <output_file>\n\n"
    "  <length>       In hexadecimal, is the length of the future file\n"
    "  <byte>         In hexadecimal, is the value of the padding\n"
    "  <output_file>  Genetated output file\n\n"),
    exit(0);
  if( argc!=4 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fo= fopen(argv[3], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[3]),
    exit(-1);
  memset(mem, strtol(argv[2], NULL, 16), 0x10000);
  length= strtol(argv[1], NULL, 16);
  for ( size= 0; size<length>>16; size++ )
    fwrite(mem, 1, 0x10000, fo);
  fwrite(mem, 1, length&0xffff, fo);
  fclose(fo);
  printf("\nDone\n");
}
