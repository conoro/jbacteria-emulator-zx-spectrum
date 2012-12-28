#include <stdio.h>

FILE *fi, *fo;
unsigned char *input, *output, *mem;
unsigned short base[52];
unsigned char bits[52];
unsigned short
    index
  , indoff
  , length
  , offset
  , inbyte= 1
  , inpos= 0
  , outbyte= 1
  , outpos= 0
  , outnex= 1
  , mempos= 0
  , b1
  , b2
  , s34= 0
  , back= 0
  ;

char getbit(){
  if( inbyte==1 )
    inbyte= 0x100 | input[inpos++];
  char tmp= inbyte&1;
  inbyte>>= 1;
  return tmp;
}

unsigned short getbits(char nbits){
  unsigned short bits= 0;
  while ( nbits-- > 0)
    bits<<= 1,
    bits|=  getbit();
  return bits;
}

putbit(char bit){
  if( outbyte>255 )
    output[outpos]= outbyte&255,
    outpos= outnex++,
    outbyte= 2 | bit;
  else
    outbyte<<= 1,
    outbyte|= bit;
}

unsigned short putbits(int bits, char nbits){
  bits<<= 17-nbits;
  while ( nbits-- > 0)
    putbit( bits&0x10000 ? 1 : 0 ),
    bits<<= 1;
}

encode(unsigned short value, char nbits, char offs){
  char offs2= offs;
  while( value >= base[offs2+1]
      && offs2 <  (1<<nbits)+offs-1)
    offs2++;
  if( offs )
    putbits( offs2-offs, nbits );
  else
    putbits( -2, offs2-offs+1 );
  if( bits[offs2]>7 && s34 )
    output[outnex++]= value-base[offs2],
    putbits( value-base[offs2]>>8, bits[offs2]-8 );
  else
    putbits( value-base[offs2], bits[offs2] );
}

unsigned short encodebits(unsigned short value, char nbits, char offs){
  char offs2= offs;
  while( value >= base[offs2+1]
      && offs2 <  (1<<nbits)+offs-1)
    offs2++;
  if( offs )
    return nbits+bits[offs2];
  else
    return offs2-offs+1+bits[offs2];
}

int main(int argc, char* argv[]){
  if( argc==1 )
    printf("\nexoopt v1.00, Metalbrain/Antonio Villena, 17 Dec 2012\n\n"),
    printf("  exoopt <input_file> <output_file> [-r]\n\n"),
    printf("  <input_file>   Origin file\n"),
    printf("  <output_file>  Genetated output file\n"),
    printf("  <type>         Target decruncher\n\n"),
    printf("<input_file> and <output_file> params are mandatory, <type> param is optional.\n"),
    printf("<type> values are: f0, f1, f2, f3, b0, b1, b2 and b3. Default is f0.\n"),
    exit(0);
  if( argc<3 || argc>4 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  if( argc==4 )
    back= ~argv[3][0] & 4,
    s34= ++argv[3][1] & 4;
  fi= fopen(argv[1], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  fo= fopen(argv[2], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[2]),
    exit(-1);
  input= (unsigned char *) malloc (0x10000);
  output= (unsigned char *) malloc (0x10000);
  mem= (unsigned char *) malloc (0x10000);
  fread(input, 1, 0x10000, fi);
  inbyte= input[inpos++];
  for( int i= 0; i<52; ++i )
    i & 15 || (b2= 1),
    base[i]= b2,
    bits[i]= b1= getbits(4),
    putbits(b1, 4),
    b2+= 1 << b1;
  getbit();
  mem[mempos++]= output[outnex++]= input[inpos++];
  while( 1 )
    if( getbit() )
      putbit(1),
      mem[mempos++]= output[outnex++]= input[inpos++];
    else{
      for ( index= 0; !getbit(); index++ );
      length= base[index] + getbits(bits[index]);
      if( length==1 )
        indoff= 48+getbits(2);
      else if( length==2 )
        indoff= 32+getbits(4);
      else
        indoff= 16+getbits(4);
      offset= base[indoff] + getbits(bits[indoff]);
      putbit(0);
      if( index==16 ){
        putbits( -2, 17 );
        break;
      }
      else if ( index==17 )
        printf("Error. Literals not allowed, compress with -c"),
        exit(-1);
      if( (length&255)==1 )
        if( length == 1
         || offset < base[51]+(1<<bits[51]) )
          encode(length, 4, 0),
          encode(offset, 2, 48);
        else
          if( encodebits(length-3, 4, 0)
            + encodebits(3, 4, 0)
            - encodebits(length, 4, 0)
            + encodebits(offset, 4, 16) + 1
            < encodebits(length-1, 4, 0)
            - encodebits(length, 4, 0) + 9 )
            encode(length-3, 4, 0),
            encode(offset, 4, 16),
            putbit(0),
            encode(3, 4, 0),
            encode(offset, 4, 16);
          else
            encode(length-1, 4, 0),
            encode(offset, 4, 16),
            putbit(1),
            output[outnex++]= mem[mempos-offset+length-1];
      else if( (length&255)==2 )
        if( length == 2
         || offset < base[47]+(1<<bits[47]) )
          encode(length, 4, 0),
          encode(offset, 4, 32);
        else
          if( encodebits(length-3, 4, 0)
            + encodebits(3, 4, 0)
            - encodebits(length, 4, 0)
            + encodebits(offset, 4, 16) + 1
            < encodebits(length-2, 4, 0)
            - encodebits(length, 4, 0) + 18 )
            encode(length-3, 4, 0),
            encode(offset, 4, 16),
            putbit(0),
            encode(3, 4, 0),
            encode(offset, 4, 16);
          else
            encode(length-2, 4, 0),
            encode(offset, 4, 16),
            putbit(1),
            output[outnex++]= mem[mempos-offset+length-2],
            putbit(1),
            output[outnex++]= mem[mempos-offset+length-1];
      else
        encode(length, 4, 0),
        encode(offset, 4, 16);
      while ( length-- )
        mem[mempos++]= mem[mempos-offset];
    }
  while( outbyte<256 )
    outbyte<<= 1;
  output[outpos]= outbyte;
  if( back )
    for ( int b1= 0; b1<outnex>>1; b1++ )
      b2= output[b1],
      output[b1]= output[outnex-1-b1],
      output[outnex-1-b1]= b2;
  fwrite(output, 1, outnex, fo);
//    FILE *fm= fopen("memp.bin", "wb+");
//    fwrite(mem, 1, mempos, fm);
  printf("\n%d bytes processed from %s\n", outnex, argv[1]);
}