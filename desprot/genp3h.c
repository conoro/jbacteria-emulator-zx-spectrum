#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x20000);
  unsigned char checksum;
  FILE *fi, *fo;
  int i, length;
  unsigned short param;
  if( argc==1 )
    printf("\n"
    "genp3h v0.01, generates the PLUS3DOS header by Antonio Villena 2012-12-27\n\n"
    "  genp3h <target_file>  [ basic <startline> | hdata <address> ]\n\n"
    "  <target_file>  Origin and target file\n"
    "  <startline>    In decimal, first BASIC line to execute\n"
    "  <address>      In hexadecimal, address of the binary block\n\n"),
    exit(0);
  fi= fopen(argv[1], "rb+");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  length= fread(mem+128, 1, 0x20000-128, fi);
  fseek(fi, 0, SEEK_SET);
  strncpy(mem, "PLUS3DOS", 8);
  *(short*)(mem+8)= 0x011a;
  *(char*)(mem+10)= 0;
  *(int*)(mem+11)= length+128;
  *(short*)(mem+16)= length;
  while ( (argc-= 2) > 1 )
    if( !stricmp(argv++[2], "basic"))
      *(char*)(mem+15)= 0,
      *(short*)(mem+18)= strtol(argv++[2], NULL, 10),
      *(short*)(mem+20)= length;
    else if( !stricmp(argv[1], "hdata"))
      *(char*)(mem+15)= 3,
      *(short*)(mem+18)= strtol(argv++[2], NULL, 16),
      *(short*)(mem+20)= 0x8000;
    else
      printf("\nInvalid argument name: %s\n", argv[1]),
      exit(-1);
  for ( checksum= 0, i= 0; i<128; ++i )
    checksum+= mem[i];
  *(char*)(mem+127)= checksum;
  fwrite(mem, 1, length+128, fi);
  fclose(fi);
  printf("\nFile generated successfully\n");
}