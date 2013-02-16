#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef __DMC__
  #define strcasecmp stricmp
#endif
unsigned char *mem, *precalc;
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
  ind= 0;
 // abcd
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
    obgen( 2168*2 );
  }
  else
    fwrite(buff, 1, length, fo);
}

int main(int argc, char* argv[]){
  mem= (unsigned char *) malloc (0x20000);
  if( argc==1 )
    printf("\nGenTape v0.20, a Tape File Generator by Antonio Villena, 16 Feb 2013\n\n"),
    printf("  GenTape [<frequency>] [<channel_type>] <output_file>\n"),
    printf("          [ basic <name> <startline> <input_file>\n"),
    printf("          | hdata <name> <address>   <input_file>\n"),
    printf("          |  data                    <input_file>\n"),
    printf("          | pilot <pilot_ts> <pilot_ms>\n"),
    printf("          | pulse <M> <pulse1_ts> <pulse2_ts> .. <pulseM_ts>\n"),
    printf("          | pause <pause_ms>\n"),
    printf("          | pdata <flag> <checksum> <zero_ts> <one_ts> <pause_ms> <input_file>\n"),
    printf("          | tdata <flag> <checksum> <pilot_ts> <syn1_ts> <syn2_ts>\n"),
    printf("                         <zero_ts> <one_ts> <pilot_ms> <pause_ms> <input_file>\n"),
    printf("          | plug-xxx-N <param1> <param2> .. <paramN> ]\n\n"),
    printf("  <output_file>  Target file, between TAP, TZX or WAV file\n"),
    printf("  <name>         Up to 10 chars name between single quotes or in hexadecimal\n"),
    printf("  <startline>    In decimal, first BASIC line to execute\n"),
    printf("  <address>      In hexadecimal, address of the binary block\n"),
    printf("  <input_file>   Hexadecimal string or filename as data origin of that block\n"),
    printf("  <zero_ts> <one_ts> <syn1_ts> <syn2_ts> <pilot_ts>\n"),
    printf("                 Length of zero/one/syncs/pilot pulses at 3.528MHz clock\n"),
    printf("  <pilot_ms> <pause_ms>\n"),
    printf("                 Duration of pilot/pause after block in milliseconds\n"),
    printf("  <M>            Number of pulses in the sequence of pulses\n"),
    printf("  <pulseX_ts>    Length of X-th pulse in the sequence at 3.528MHz clock\n"),
    printf("  <plug-xxx-N>   External generator, must exists xxx.exe and accept N params\n\n"),
    printf("  WAV options:\n"),
    printf("      <frequency>    Sample frequency, 44100 or 48000. Default is 44100\n"),
    printf("      <channel_type> Possible values are: mono (default), stereo or stereoinv\n\n"),
    exit(0);
  while( argv[1][0]!='+' || (++argv[1], plus--) )
    if( !strcasecmp(argv[1], "mono") || !strcasecmp(argv[1], "44100") )
      ++argv, --argc;
    else if( !strcasecmp(argv[1], "stereo") )
      channel_type= 2, ++argv, --argc;
    else if( !strcasecmp(argv[1], "stereoinv") )
      channel_type= 6, ++argv, --argc;
    else if( !strcasecmp(argv[1], "48000") )
      frequency= 48000, ++argv, --argc;
    else
      break;
  mod= 7056000/frequency;
  if( !strchr(argv[1], '.') )
    printf("\nInvalid argument name: %s\n", argv[1]),
    exit(-1);
  fo= fopen(argv[1], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[1]),
    exit(-1);
  if( !strcasecmp((char *)strchr(argv[1], '.'), ".tzx" ) )
    fprintf( fo, "ZXTape!" ),
    *(int*)mem= 0xa011a,
    fwrite(mem, ++tzx, 3, fo),
    mem[0]= 0x10;
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
  while ( argc-- > 2 ){
    lpause= ftell(fo);
    wav && nextsilence && wavsilence( silence );
    if( !strcasecmp(argv++[2], "basic")){
      *(short*)(mem+1)= 1000;
      tzx && fwrite(mem, 1, 3, fo);
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
      tapewrite(mem+3, 21);
      wav && wavsilence( 1000 );
      lpause= ftell(fo);
      *(short*)(mem+1)= 2000;
      tzx && fwrite(mem, 1, 3, fo);
      tapewrite(mem+24, length+2);
      silence= nextsilence= 2000;
      fclose(fi);
      argc-= 3;
      argv+= 3;
    }
    else if( !strcasecmp(argv[1], "hdata")){
      *(short*)(mem+1)= 1000;
      tzx && fwrite(mem, 1, 3, fo);
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
      for ( checksum= 0, i= 26; i<26+length-1; ++i )
        checksum^= mem[i];
      mem[length+25]= checksum;
      tapewrite(mem+3, 21);
      wav && wavsilence( 1000 );
      lpause= ftell(fo);
      *(short*)(mem+1)= 2000;
      tzx && fwrite(mem, 1, 3, fo);
      tapewrite(mem+24, length+2);
      silence= nextsilence= 2000;
      fclose(fi);
      argc-= 3;
      argv+= 3;
    }
    else if( !strcasecmp(argv[1], "data")){
      *(short*)(mem+1)= 1000;
      tzx && fwrite(mem, 1, 3, fo);
      fi= fopen(argv[2], "rb");
      if( fi )
        length= 2+fread(mem+6, 1, 0x20000-6, fi);
      else
        length= parseHex(argv[2], 6);
//      *(short*)(mem+1)= 1000;
      *(short*)(mem+3)= length;
      mem[5]= 255;
      for ( checksum= 0, i= 5; i<5+length-1; ++i )
        checksum^= mem[i];
      mem[length+4]= checksum;
      tapewrite(mem+3, length+2);
      silence= nextsilence= 2000;
      fclose(fi);
      --argc;
      ++argv;
    }
    else if( !strcasecmp(argv[1], "pause")){
      nextsilence= silence= atof(argv[2]);
      if( tzx )
        mem[1]= 0x20,
        *(short*)(mem+2)= nextsilence,
        fwrite(mem+1, 1, 3, fo);
      else if( !wav )
        printf("\nError: pause command not allowed in TAP files\n"),
        exit(-1);
      --argc;
      ++argv;
    }
    else if( !strcasecmp(argv[1], "pilot")){
      k= strtol(argv[2], NULL, 10);
      if( tzx )
        mem[1]= 0x12,
        k>>= 1-plus,
        *(short*)(mem+2)= k,
        *(unsigned short*)(mem+4)= atof(argv[3])*3500/k+0.5,
        fwrite(mem+1, 1, 5, fo);
      else if( wav ){
        j= atof(argv[3])*3528/k+0.5;
        k<<= plus;
        while( j-- )
          obgen( k );
      }
      else
        printf("\nError: pilot command not allowed in TAP files\n"),
        exit(-1);
      nextsilence= 0;
      argc-= 2;
      argv+= 2;
    }
    else if( (turbo= !strcasecmp(argv[1], "pdata")) || !strcasecmp(argv[1], "tdata") ){
/*    if( tzx ){
      }
      else if( wav ){
        memset(precalc2, 128, 0x200000);
        if( turbo==1 )
          pilot1= strtol(argv[4], NULL, 10)*frequency/175e4+0.5,
          pilot2= pilot1>>1,
          pilot1-= pilot2,
          sync1=  strtol(argv[5], NULL, 10)*frequency/35e5+0.5,
          sync2=  strtol(argv[6], NULL, 10)*frequency/35e5+0.5,
          zero1=  strtol(argv[7], NULL, 10)*frequency/175e4+0.5,
          one1=   strtol(argv[8], NULL, 10)*frequency/175e4+0.5,
          k=      strtol(argv[9], NULL, 10),
          nextsilence= strtol(argv[10], NULL, 10);
        else
          zero1= strtol(argv[4], NULL, 10)*frequency/175e4+0.5,
          one1=  strtol(argv[5], NULL, 10)*frequency/175e4+0.5,
          nextsilence= strtol(argv[6], NULL, 10);
        zero2= zero1>>1;
        zero1-= zero2;
        one2= one1>>1;
        one1-= one2;
        for( j= ind= 0; j<0x100; j++ ){
          pos2[j]= ind;
          for( k= 0; k<8; k++ )
            outbits( j<<k & 0x80 ? one1 : zero1 ),
            outbits( j<<k & 0x80 ? one2 : zero2 );
          len2[j]= ind-pos2[j];
        }
        if( turbo==1 ){
          j= 2048;
          pos2[0x100]= pos2[0x101]= ind;
          while( j-- )
            outbits( pilot1 ),
            outbits( pilot2 );
          outbits( sync1 );
          outbits( sync2 );
          len2[0x100]= len2[0x101]= ind-pos2[0x100];
        }
        pos2[0x102]= ind;
        mem[0]= strtol(argv[2], NULL, 16);
        fi= fopen(argv[15-turbo*4], "rb");
        if( fi )
          length= 2+fread(mem+1, 1, 0x20000-1, fi);
        else
          length= parseHex(argv[15-turbo*4], 1);
        for ( checksum= i= 0; i<length-1; ++i )
          checksum^= mem[i];
        if( argv[3][0]!='-' )
          checksum= strtol(argv[3], NULL, 16);
        mem[length-1]= checksum;
        tapewrite(mem, length+2);
        fclose(fi);

 //strtol(argv[2], NULL, 16);

        
//    printf("          | pdata <zero_ts> <one_ts> <pause_ms> <input_file>\n"),
//    printf("          | tdata <pilot_ts> <syn1_ts> <syn2_ts> <zero_ts> <one_ts>\n"),
//    printf("                                 <pilot_ms> <pause_ms> <input_file>\n"),
        argc-= 14-turbo*4;
        argv+= 14-turbo*4;
      }
      else
        printf("\nError: pdata or tdata command not allowed in TAP files\n"),
        exit(-1);*/
    }
    else
      printf("\nInvalid argument name: %s\n", argv[1]),
      exit(-1);
  }
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