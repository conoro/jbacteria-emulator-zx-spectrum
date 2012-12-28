#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x20000);
  unsigned char checksum;
  FILE *fi, *fo;
  int i;
  unsigned short length, param;
  if( argc==1 )
    printf("\ngentape v0.01, a Tape File Generator by Antonio Villena, 25 Dec 2012\n\n"),
    printf("  gentape <output_file> [ basic <name> <startline> <input_file>\n"),
    printf("                        | hdata <name> <address>   <input_file>\n"),
    printf("                        |  data                    <input_file> ]\n\n"),
    printf("  <output_file>  Target file, at the moment .TAP file (TZX/WAV in near future)\n"),
    printf("  <name>         Up to 10 chars name between single quotes or in hexadecimal\n"),
    printf("  <startline>    In decimal, first BASIC line to execute\n"),
    printf("  <address>      In hexadecimal, address of the binary block\n"),
    printf("  <input_file>   Hexadecimal string or filename as data origin of that block\n\n"),
    exit(0);
  fo= fopen(argv[1], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[1]),
    exit(-1);
  while ( argc-- > 2 )
    if( !stricmp(argv++[2], "basic")){
      param= strtol(argv[3], NULL, 10);
      fi= fopen(argv[4], "rb");
      length= fread(mem+24, 1, 0x20000-25, fi);
      *(int*)mem= 19;
      if( argv[2][0]=='\'' )
        for ( i= 1; i<11 && argv[2][i]!='\''; ++i )
          *(char*)(mem+i+3)= argv[2][i];
      while( ++i<12 )
        *(char*)(mem+i+2)= ' ';
      *(short*)(mem+14)= *(short*)(mem+18)= length;
      *(short*)(mem+16)= param;
      length+= 2;
      *(short*)(mem+21)= length;
      *(char*)(mem+23)= 255;
      for ( checksum= 0, i= 2; i<20; ++i )
        checksum^= mem[i];
      *(char*)(mem+20)= checksum;
      for ( checksum= 0, i= 23; i<23+length; ++i )
        checksum^= mem[i];
      *(char*)(mem+length+22)= checksum;
      fwrite(mem, 1, length+23, fo);
      fclose(fi);
      argc-= 3;
      argv+= 3;
    }
    else if( !stricmp(argv[1], "hdata")){
      param= strtol(argv[3], NULL, 16);
      fi= fopen(argv[4], "rb");
      length= fread(mem+24, 1, 0x20000-25, fi);
      *(short*)mem= 19;
      *(short*)(mem+2)= 0x300;
      if( argv[2][0]=='\'' )
        for ( i= 1; i<11 && argv[2][i]!='\''; ++i )
          *(char*)(mem+i+3)= argv[2][i];
      while( ++i<12 )
        *(char*)(mem+i+2)= ' ';
      *(short*)(mem+14)= length;
      *(short*)(mem+16)= param;
      *(short*)(mem+18)= 0x8000;
      length+= 2;
      *(short*)(mem+21)= length;
      *(char*)(mem+23)= 255;
      for ( checksum= 0, i= 2; i<20; ++i )
        checksum^= mem[i];
      *(char*)(mem+20)= checksum;
      for ( checksum= 0, i= 23; i<23+length; ++i )
        checksum^= mem[i];
      *(char*)(mem+length+22)= checksum;
      fwrite(mem, 1, length+23, fo);
      fclose(fi);
      argc-= 3;
      argv+= 3;
    }
    else if( !stricmp(argv[1], "data")){
      fi= fopen(argv[2], "rb");
      length= 2+fread(mem+3, 1, 0x20000-4, fi);
      *(short*)mem= length;
      *(char*)(mem+2)= 255;
      for ( checksum= 0, i= 2; i<2+length; ++i )
        checksum^= mem[i];
      *(char*)(mem+length+1)= checksum;
      fwrite(mem, 1, length+2, fo);
      fclose(fi);
      --argc;
      ++argv;
    }
    else
      printf("\nInvalid argument name: %s\n", argv[1]),
      exit(-1);
  fclose(fo);
  printf("\nFile generated successfully\n");
}