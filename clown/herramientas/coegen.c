#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x100000);
  FILE *fi, *fo;
  long size, i;
  if( argc==1 )
    printf("\ncoegen v0.99, COE file generation from binary files /Antonio Villena, 29May2013\n\n"),
    printf("  coegen <input_file> <output_file>\n\n"),
    printf("  <input_file>   Origin binary file\n"),
    printf("  <output_file>  Genetated .COE file\n\n"),
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
  size--;
  fprintf(fo, "memory_initialization_radix=16;\n");
  fprintf(fo, "memory_initialization_vector=\n");
  for ( i= 0; i<size; i++ )
    fprintf(fo, "%02X,\n", mem[i]);
  fprintf(fo, "%02X;\n", mem[i]);
  fclose(fi);
  fclose(fo);
  printf("\nFile generated\n", size);
}