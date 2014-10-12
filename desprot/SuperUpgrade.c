#include <stdio.h>
#include <stdlib.h>
#include <string.h>
unsigned char in[0x10200];
unsigned char checksum, roms= 0;
FILE *fi, *fo;
int i, j, k, length= 0;

int main(int argc, char* argv[]){
  if( argc==1 )
    printf("\n"
    "SuperUpgrade v0.01, Wilco flash utility upgrader, Antonio Villena 11 Oct 2014\n\n"
    "  SuperUpgrade <outputfile> <roms> <inputfile1> <inputfile2> .. <inputfilen> \n\n"
    "  <outputfile>  Output TAP file\n"
    "  <roms>        4 digit number, X to preserve. 0123 full 64K, XXX3 only ROM3\n"
    "  <inputfileX>  Input binary file/s\n\n"),
    exit(0);
  else if( argc<4 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fo= fopen(argv[1], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[1]),
    exit(-1);
  else if( strlen(argv[2]) != 4 )
    printf("\nInvalid length in <roms> parameter\n"),
    exit(-1);
  for ( i= 0; i<4; i++ )
    if( argv[2][i]=='0'+i )
      roms|= 1<<i;
    else if( (argv[2][i]&0xdf)!='X' )
      printf("\nInvalid digit %c in <roms> parameter\n", argv[2][i]),
      exit(-1);
  for ( i= 3; i<argc; i++ ){
    fi= fopen(argv[i], "rb");
    if( !fi )
      printf("\nInput file not found: %s\n", argv[i]),
      exit(-1);
    fseek(fi, 0, SEEK_END);
    length+= ftell(fi);
    fclose(fi);
  }
  for ( j= i= 0; i<4; i++ )
    j+= roms&1<<i ? 16384 : 0;
  if( length!= j )
    printf("\nInvalid length %d in input files, must be %d\n", length, j),
    exit(-1);
  length= 0;
  for ( i= 3; i<argc; i++ ){
    fi= fopen(argv[i], "rb");
    if( !fi )
      printf("\nInput file not found: %s\n", argv[i]),
      exit(-1);
    length+= fread(in+length, 1, 0x10000, fi);
    fclose(fi);
  }
  fi= fopen("SuperUpgrade.bin", "rb");
  length= fread(in+0x10018, 1, 0x10000, fi);
  in[0x10000]= 19;
  strcpy((char *) (in+0x10004), "SuperUpgra");
  *(short*)(in+0x1000e)= *(short*)(in+0x10012)= length;
  for ( checksum= 0, i= 0x10004; i<0x10014; i++ )
    checksum^= in[i];
  in[0x10014]= checksum;
  fwrite(in+0x10000, 1, 21, fo);
  in[0x10055]= roms;
  *(short*)(in+0x10015)= length+2;
  in[0x10017]= 255;
  for ( checksum= 255, i= 0x10018; i<0x10018+length; i++ )
    checksum^= in[i];
  in[0x10018+length]= checksum;
  fwrite(in+0x10015, 1, 4+length, fo);
  length= 0;
  k= 16384;
  *(short*)(in+0x10015)= k+2;
  for ( i= 1; i<0x10; i<<= 1 )
    if( roms&i ){
      fwrite(in+0x10015, 1, 3, fo);
      fwrite(in+length, 1, k, fo);
      for ( checksum= 0xff, j= 0; j<k; j++ )
        checksum^= in[j+length];
      length+= k;
      fwrite(&checksum, 1, 1, fo);
    }
  printf("\nFile %s generated successfully\n", argv[1]);
}