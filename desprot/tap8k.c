#include <stdio.h>
#include <string.h>
int main(int argc, char* argv[]){
  unsigned char mem[0x10000], checksum= 0;
  FILE *fi, *fo;
  char *output_name, *ext;
  int i, size;
  if( argc==1 )
    printf("\n"
    "tap8k v0.99. Generates a ZX Spectrum TAP file from ORG $8000 binary 10 Sep 2017\n\n"
    "  tap8k <input_file> <name>\n\n"
    "  <input_file>   Origin binary file\n"
    "  <name>         Up 10 chars name to show during loading\n"
    "An output file with .TAP added extension will be generated\n"),
    exit(0);
  if( argc!=3 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  if( !(ext= strchr(argv[1], '.')) )
    printf("\nInvalid argument name: %s\n", argv[1]),
    exit(-1);
  fi= fopen(argv[1], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  output_name= (char *)malloc(strlen(argv[1])+1);
  ext[0]= 0;
  strcpy(output_name, argv[1]);
  strcat(output_name, ".TAP");
  fo= fopen(output_name, "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", output_name),
    exit(-1);
  size= fread(mem+28, 1, 0x10000, fi);
  *(int*)(mem)= 19;
  for ( i= 0; i<10 && argv[2][i]; i++ )
    mem[i+4]= argv[2][i];
  while( ++i<11 )
    mem[i+3]= ' ';
  *(short*)(mem+18)= *(short*)(mem+14)= *(short*)(mem+21)= size+25;
  size+= 29;
  for ( checksum= 0, i= 2; i<20; ++i )
    checksum^= mem[i];
  mem[20]= checksum;
  fwrite(mem, 1, 21, fo);
  *(short*)(mem)= size-2;
  *(int*)(mem+2)= 0x800031ff;
  *(int*)(mem+6)= 0x37c0def3;
  *(int*)(mem+10)= 0x96398f0e;
  *(int*)(mem+14)= 0x11dc7221;
  *(int*)(mem+18)= 0x7f06ff8e;
  *(int*)(mem+22)= 0xc3fbb8ed;
  *(short*)(mem+26)= 0x8000;
  for ( checksum= 0, i= 2; i<size; ++i )
    checksum^= mem[i];
  mem[size-1]= checksum;
  fwrite(mem, 1, size, fo);
  fclose(fo);
  printf("\nFile %s generated successfully\n", output_name);
}
