#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x100000);
  FILE *fi, *fo;
  long size;
  int i, j, k;
  if( argc==1 )
    printf("\nbramgen v0.99, BRAM file generation from binary files /Antonio Villena, 4Jun2013\n\n"),
    printf("  bramgen <input_file> <output_file>\n\n"),
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
  rewind(fi);
  if( size>0xfffff )
    printf("\nFile length exceeded 1Mb.\n"),
    exit(-1);
  for ( i= 0; i < size>>11; i++ ){
    fprintf(fo, "\n-- block %02X\n", i);
    for ( j= 0; j<0x40; j++ ){
      fprintf(fo, "    , INIT_%02X   => X\"", j);
      for ( k= 0x20; k-->0; )
        fprintf(fo, "%02X", mem[i<<11 | j<<5 | k]);
      fprintf(fo, "\"\n");
    }
  }
  size&= 0x7ff;
  fprintf(fo, "\n-- block %02X\n", i);
  for ( j= 0; j < size>>5; j++ ){
    fprintf(fo, "    , INIT_%02X   => X\"", j);
    for ( k= 0x20; k-->0; )
      fprintf(fo, "%02X", mem[i<<11 | j<<5 | k]);
    fprintf(fo, "\"\n");
  }
  size&= 0x1f;
  fprintf(fo, "    , INIT_%02X   => X\"", j);
  for ( k= 0x20; k-->0; )
    fprintf(fo, "%02X", k>size ? 0 : mem[i<<11 | j<<5 | k]);
  fprintf(fo, "\"\n");
  fclose(fi);
  fclose(fo);
  printf("\nFile generated\n", size);
}