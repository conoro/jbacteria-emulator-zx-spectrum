#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef __DMC__
  #define strcasecmp stricmp
#endif
unsigned char *mem, *precalc;
char *ext, *command;
unsigned char rem= 0, inibit= 0, tzx= 0, wav= 0, channel_type= 1, plus= 1,
              checksum, turbo, mod;
FILE *fi, *fo;
int i, j, k, l, ind= 0, lpause, nextsilence= 0;
float silence;
unsigned short length, param, frequency= 44100;

void outbits( short val ){
  for ( i= 0; i<val; i++ ){
    precalc[ind++]= inibit ? 0x40 : 0xc0;
    if( channel_type==2 )
      precalc[ind++]= inibit ? 0x40 : 0xc0;
    else if( channel_type==6 )
      precalc[ind++]= inibit ? 0xc0 : 0x40;
  }
  if( ind>0xff000 )
    fwrite( precalc, 1, ind, fo ),
    ind= 0;
  inibit^= 1;
}

void obgen( int nor ){
  outbits( (nor+rem)/mod );
  rem= (nor+rem)%mod;
}

char char2hex(char value, char * name){
  if( value<'0' || value>'f' || value<'A' && value>'9' || value<'a' && value>'F' )
    printf("\nInvalid character %c or '%s' not exists\n", value, name),
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
      mem[i+index]= char2hex(name[i<<1|1], name) | char2hex(name[i<<1], name) << 4;
    ++i;
  }
  while( ++i<12 )
    mem[i+5]= ' ';
  return flen;
}

int wavsilence( float msecs ){
  fwrite( precalc, 1, ind, fo );
  rem= ind= 0;
  fwrite( precalc+0x100000, 1, frequency*(channel_type&3)*msecs/1000, fo);
}

void tapewrite( unsigned char *buff, int length ){
  if( wav ){
    buff+= 2;
    length-= 2;
    j= *buff>>7&1 ? 3223 : 8063;
    while( j-- )
      obgen( 2168*2 );
    obgen( 667*2 );
    obgen( 735*2 );
    while ( length-- )
      for( k= 0, j= *buff++; k<8; k++, j<<= 1 )
        obgen( l= 1710 << ((j & 0x80)>>7) ),
        obgen( l );
    obgen( l );
  }
  else
    fwrite(buff, 1, length, fo);
}

int main(int argc, char* argv[]){
  mem= (unsigned char *) malloc (0x20000);
  if( argc==1 )
    printf("\nleches v0.01, an ultra load block generator by Antonio Villena, 18 Feb 2013\n\n"),
    printf("  leches <srate> <channel_type> <ofile> <flag> <pilot_ms> <pause_ms> <ifile>\n\n"),
    printf("  <srate>         Sample rate, 44100 or 48000. Default is 44100\n"),
    printf("  <channel_type>  Possible values are: mono (default), stereo or stereoinv\n"),
    printf("  <ofile>         Output file, between TZX or WAV file\n"),
    printf("  <flag>          Flag byte, 00 for header, ff or another for data blocks\n"),
    printf("  <pilot_ms>      Duration of pilot in milliseconds\n"),
    printf("  <pause_ms>      Duration of pause after block in milliseconds\n"),
    printf("  <ifile>         Hexadecimal string or filename as data origin of that block\n\n"),
    exit(0);
  if( argc!=8 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  frequency= strtol(argv[1], NULL, 10); //atoi
  if( frequency!=44100 || frequency!=48000 )
    printf("\nInvalid sample rate: %d\n", frequency),
    exit(-1);
  if( !strcasecmp(argv[2], "mono") )
    channel_type= 1;
  else if( !strcasecmp(argv[2], "stereo") )
    channel_type= 2;
  else if( !strcasecmp(argv[2], "stereoinv") )
    channel_type= 6;
  else
    printf("\nInvalid argument name: %s\n", argv[2]),
    exit(-1);
  mod= 7056000/frequency;
  fo= fopen(argv[3], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[3]),
    exit(-1);
  if( !strcasecmp((char *)strchr(argv[1], '.'), ".tzx" ) )
    fprintf( fo, "ZXTape!" ),
    *(int*)mem= 0xa011a,
    fwrite(mem, ++tzx, 3, fo),
    mem[0]= 0x12;
  else if( !strcasecmp((char *)strchr(argv[1], '.'), ".wav" ) ){
    precalc= (unsigned char *) malloc (0x200000);
    memset(mem, wav++, 44);
    memset(precalc, 128, 0x200000);
    *(int*)mem= 0x46464952;
    *(int*)(mem+8)= 0x45564157;
    *(int*)(mem+12)= 0x20746d66;
    *(char*)(mem+16)= 0x10;
    *(char*)(mem+20)= 0x01;
    *(char*)(mem+22)= *(char*)(mem+32)= channel_type&3;
    *(short*)(mem+24)= frequency;
    *(int*)(mem+28)= frequency*(channel_type&3);
    *(char*)(mem+34)= 8;
    *(int*)(mem+36)= 0x61746164;
    fwrite(mem, 1, 44, fo);
  }
  *(short*)(mem+1)= 500; //abcd
  *(short*)(mem+3)= atof(argv[5])*3500/k+0.5;
  mem[5]= strtol(argv[4], NULL, 16);
  tzx && fwrite(mem, 1, 3, fo);
  fi= fopen(argv[7], "rb");
  if( fi )
    length= 2+fread(mem+6, 1, 0x20000-6, fi);
  else
    length= parseHex(argv[2], 6);
  for ( checksum= 0, i= 5; i<5+length-1; ++i )
    checksum^= mem[i];
  mem[length+4]= checksum;
  tapewrite(mem+3, length+2);
 // pause
  fclose(fi);

  if( tzx )
    fseek(fo, ++lpause, SEEK_SET),
    *(short*)mem= 0,
    fwrite(mem, 2, 1, fo);
  else if( wav )
    wavsilence( 100 ),
    i= ftell(fo)-8,
    fseek(fo, 4, SEEK_SET),
    fwrite(&i, 4, 1, fo),
    i-= 36,
    fseek(fo, 40, SEEK_SET),
    fwrite(&i, 4, 1, fo);
  fclose(fo);
  printf("\nFile generated successfully\n");
}