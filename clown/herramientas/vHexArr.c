#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x100000);
  char counter[16];
  FILE *fi, *fo;
  long size, shsize;
  int i, j, k;
  if( argc==1 )
    printf("\nvHexArr, VHDL Hex Array generator from binary files /Antonio Villena, 13Jun2013\n\n"),
    printf("  vHexArr <input_file> <output_file>\n\n"),
    printf("  <input_file>   Origin binary file\n"),
    printf("  <output_file>  Genetated .VHD file\n\n"),
    printf("All params are mandatory.\n"),
    exit(0);
  if( argc!=3 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[1], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  fo= fopen(argv[2], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[2]),
    exit(-1);
  fread(mem, 1, 0x100000, fi);
  size= ftell(fi);
  for ( shsize= size, k= 0; shsize; shsize>>= 4, k++ );
  sprintf( counter, "--%%0%dX\n", k );
  rewind(fi);
  if( size>0xfffff )
    printf("\nFile length exceeded 1Mb.\n"),
    exit(-1);
  for ( i= 0; i < size>>3; i++ ){
    fprintf(fo, "  ");
    for ( j= 0; j<8; j++ )
      fprintf(fo, "X\"%02X\", ", mem[i<<3 | j]);
    fprintf(fo, counter, i<<3);
  }
  size&= 0x7;
  if( size ){
    fprintf(fo, "  ");
    for ( j= 0; j<8; j++ )
      if( j<size )
        fprintf(fo, "X\"%02X\", ", mem[i<<3 | j]);
      else
        fprintf(fo, "       ");
    fprintf(fo, counter, i<<3);
  }
  fclose(fi);
  fclose(fo);
  printf("\nFile generated\n", size);
}