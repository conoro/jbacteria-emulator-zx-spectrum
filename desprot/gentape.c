#include <stdio.h>
unsigned char *mem;
unsigned char checksum, tzx= 0;
FILE *fi, *fo;
int i, lpause;
unsigned short length, param;

char char2hex(char value){
  if( value<'0' || value>'f' || value<'A' && value>'9' || value<'a' && value>'F' )
    printf("\nInvalid character %c\n", value),
    exit(-1);
  return value>'9' ? 9+(value&7) : value-'0';
}

int parseHex(char * name, int index){
  int flen= strlen(name);
  if( name[0]=='\'' )
    for ( i= 1; i<11 && name[i]!='\''; ++i )
      mem[i+6]= name[i];
  else if( ~flen & 1 ){
    flen>>= 1;
    flen>10 && index==7 && (flen= 10);
    for ( i= 0; i < flen; i++ )
      mem[i+index]= char2hex(name[i<<1|1]) | char2hex(name[i<<1]) << 4;
    ++i;
  }
  while( ++i<12 )
    mem[i+5]= ' ';
  return flen;
}

int main(int argc, char* argv[]){
  mem= (unsigned char *) malloc (0x20000);
  if( argc==1 )
    printf("\ngentape v0.02, a Tape File Generator by Antonio Villena, 5 Jan 2012\n\n"),
    printf("  gentape <output_file> [ basic <name> <startline> <input_file>\n"),
    printf("                        | hdata <name> <address>   <input_file>\n"),
    printf("                        |  data                    <input_file> ]\n\n"),
    printf("  <output_file>  Target file, at the moment .TAP or TZX file (WAV in near future)\n"),
    printf("  <name>         Up to 10 chars name between single quotes or in hexadecimal\n"),
    printf("  <startline>    In decimal, first BASIC line to execute\n"),
    printf("  <address>      In hexadecimal, address of the binary block\n"),
    printf("  <input_file>   Hexadecimal string or filename as data origin of that block\n\n"),
    exit(0);
  fo= fopen(argv[1], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[1]),
    exit(-1);
  if( !stricmp((char *)strchr(argv[1], '.'), ".tzx" ) )
    fprintf( fo, "ZXTape!" ),
    *(int*)mem= 0xa011a,
    fwrite(mem, ++tzx, 3, fo),
    mem[0]= 0x10;
  while ( argc-- > 2 ){
    lpause= ftell(fo);
    *(short*)(mem+1)= 1000;
    tzx && fwrite(mem, 1, 3, fo);
    if( !stricmp(argv++[2], "basic")){
      param= strtol(argv[3], NULL, 10);
      fi= fopen(argv[4], "rb");
      if( fi )
        length= fread(mem+27, 1, 0x20000-27, fi);
      else
        length= parseHex(argv[4], 27);
      *(int*)(mem+3)= 19;
      parseHex(argv[2], 7);
      *(short*)(mem+17)= *(short*)(mem+21)= length;
      *(short*)(mem+19)= param;
      length+= 2;
      *(short*)(mem+24)= length;
      mem[26]= 255;
      for ( checksum= 0, i= 5; i<23; ++i )
        checksum^= mem[i];
      mem[23]= checksum;
      for ( checksum= 0, i= 26; i<26+length; ++i )
        checksum^= mem[i];
      mem[length+25]= checksum;
      fwrite(mem+3, 1, 21, fo);
      lpause= ftell(fo);
      *(short*)(mem+1)= 2000;
      tzx && fwrite(mem, 1, 3, fo);
      fwrite(mem+24, 1, length+2, fo);
      fclose(fi);
      argc-= 3;
      argv+= 3;
    }
    else if( !stricmp(argv[1], "hdata")){
      param= strtol(argv[3], NULL, 16);
      fi= fopen(argv[4], "rb");
      if( fi )
        length= fread(mem+27, 1, 0x20000-27, fi);
      else
        length= parseHex(argv[4], 27);
      *(short*)(mem+1)= 1000;
      *(short*)(mem+3)= 19;
      *(short*)(mem+5)= 0x300;
      parseHex(argv[2], 7);
      *(short*)(mem+17)= length;
      *(short*)(mem+19)= param;
      *(short*)(mem+21)= 0x8000;
      length+= 2;
      *(short*)(mem+24)= length;
      mem[26]= 255;
      for ( checksum= 0, i= 5; i<23; ++i )
        checksum^= mem[i];
      mem[23]= checksum;
      for ( checksum= 0, i= 26; i<26+length; ++i )
        checksum^= mem[i];
      mem[length+25]= checksum;
      fwrite(mem+3, 1, 21, fo);
      lpause= ftell(fo);
      *(short*)(mem+1)= 2000;
      tzx && fwrite(mem, 1, 3, fo);
      fwrite(mem+24, 1, length+2, fo);
      fclose(fi);
      argc-= 3;
      argv+= 3;
    }
    else if( !stricmp(argv[1], "data")){
      fi= fopen(argv[2], "rb");
      if( fi )
        length= 2+fread(mem+6, 1, 0x20000-6, fi);
      else
        length= parseHex(argv[2], 6);
      *(short*)(mem+1)= 1000;
      *(short*)(mem+3)= length;
      mem[5]= 255;
      for ( checksum= 0, i= 5; i<5+length; ++i )
        checksum^= mem[i];
      mem[length+4]= checksum;
      fwrite(mem+3, 1, length+2, fo);
      fclose(fi);
      --argc;
      ++argv;
    }
    else
      printf("\nInvalid argument name: %s\n", argv[1]),
      exit(-1);
  }
  if( tzx )
    fseek(fo, ++lpause, SEEK_SET),
    *(short*)mem= 0,
    fwrite(mem, 2, 1, fo);
  fclose(fo);
  printf("\nFile generated successfully\n");
}