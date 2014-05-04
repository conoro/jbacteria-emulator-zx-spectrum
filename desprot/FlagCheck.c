#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char mem[0x10000], flag= 0xff, checksum= 0;
  FILE *fi, *fo;
  char *output_name;
  int i, size;
  if( argc==1 )
    printf("\n"
    "FlagCheck v0.99, inserts flag and checksum into a data block, 04 May 2014\n\n"
    "  FlagCheck <input_file> [<flag>]\n\n"
    "  <input_file>   Origin binary file\n"
    "  [<flag>]       In hexadecimal, flag byte to insert, optional parameter\n\n"
    "A output file with .fck added extension will be generated. If no flag byte is"
    "specified, default value is FF\n"),
    exit(0);
  if( argc==3 )
    flag= strtol(argv[2], NULL, 16);
  else if( argc!=2 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[1], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  output_name= (char *)malloc(strlen(argv[1])+5);
  strcpy(output_name, argv[1]);
  strcat(output_name, ".fck");
  fo= fopen(output_name, "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", output_name),
    exit(-1);
  i= size= fread(mem+1, 1, 0x10000, fi)+1;
  fclose(fi);
  mem[0]= flag;
  while ( i-- )
    checksum^= mem[i];
  mem[size]= checksum;
  fwrite(mem, 1, size+1, fo);
  fclose(fo);
  printf("\nFile %s generated successfully\n", output_name);
}