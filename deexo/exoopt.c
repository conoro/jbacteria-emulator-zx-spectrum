#include <stdio.h>

FILE *fi, *fo, *fa;
unsigned char *input, *output, *mem;
char *output_name;
unsigned short base[52];
unsigned char bits[52];
unsigned char sizes[]= {148, 150, 166, 203};
char  tmpstr1[100], tmpstr2[100], tmpstr3[100];
unsigned short  index, indoff, length, offset, inbyte, outbyte, inpos,
                outnex, mempos, b1, b2, mapbase, speed, fil, back,
                mapb= 0, litf= 0;
int outpos;

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
  if( outbyte>0xff )
    output[outpos]= outbyte&0xff,
    outpos= outnex++,
    outbyte= 2 | bit;
  else
    outbyte<<= 1,
    outbyte|= bit;
}

unsigned short putbits(int bits, char nbits){
  bits<<= 18-nbits;
  while ( nbits-- > 0)
    putbit( bits&0x20000 ? 1 : 0 ),
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
  if( bits[offs2]>7 && speed>2 )
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
    printf("\nexoopt v1.05, Metalbrain/Antonio Villena, 28 Jan 2013\n\n"),
    printf("  exoopt <type> <table_address> <file1> <file2> .. <fileN>\n\n"),
    printf("  <type>           Target decruncher\n"),
    printf("  <table_address>  Hexadecimal address for the temporal 156 bytes table\n"),
    printf("  <file1..N>       Origin files\n\n"),
    printf("All params are mandatory\n"),
    printf("Valid <type> values are: f0, f1, f2, f3, b0, b1, b2 and b3\n"),
    printf("Every input file will be compressed in a .opt output file\n"),
    printf("It will generate the decruncher into the file d.asm\n\n"),
    printf("Valid input files must be generated with one of next exomizer params:\n"),
    printf("  exomizer raw <ifile> -o <ofile>\n"),
    printf("  exomizer raw <ifile> -c -o <ofile>\n"),
    printf("  exomizer raw <ifile> -b -r -o <ofile>\n"),
    printf("  exomizer raw <ifile> -b -r -c -o <ofile>\n"),
    exit(0);
  back= (~argv[1][0] & 4)>>2;
  speed= argv[1][1] - '0';
  if( argc<4 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  mapbase= strtol(argv[2], NULL, 16);
  if( (mapbase&0xff)>0x87 && (mapbase&0xff)<0xf0 )
    mapb++;
  input= (unsigned char *) malloc (0x10000);
  for( fil= 3; fil<argc; fil++ ){
    fi= fopen(argv[fil], "rb");
    if( !fi )
      printf("\nInput file not found: %s\n", argv[fil]),
      exit(-1);
    fread(input, 1, 0x10000, fi);
    fclose(fi);
    inpos= outpos= 0;
    inbyte= input[inpos++];
    for( index= 0; index<52; ++index )
      index & 15 || (b2= 1),
      base[index]= b2,
      bits[index]= b1= getbits(4),
      b2+= 1 << b1;
    while( 1 )
      if( getbit() )
        ++outpos,
        ++inpos;
      else{
        for ( index= 0; !getbit(); index++ );
        if ( index==17 || outpos>0x10000 )
          goto exit;
        else if( index==16 )
          break;
        else{
          outpos+= length= base[index] + getbits(bits[index]);
          if( length==1 )
            getbits(bits[0x30+getbits(2)]);
          else if( length==2 )
            getbits(bits[0x20+getbits(4)]);
          else
            getbits(bits[0x10+getbits(4)]);
        }
      }
  }
exit:
  if( outpos>0x10000 )
    printf("\nInvalid input file: %s\n", argv[fil]),
    exit(-1);
  index==17 && (litf= 1);
  fa= fopen("d.asm", "wb+");
  if( !fa )
    printf("\nCannot create d.asm file"),
    exit(-1);
  fprintf(fa, "; %c%d [%s] %s= %d bytes\n", back ? 'b' : 'f'
                                          , speed
                                          , mapb ? "88..ef" : "f0..87"
                                          , litf ? "liter" : "nolit"
                                          , sizes[speed]-back*2+mapb*(2+litf)+10*litf);
  fprintf(fa, "        ld      iy, %d\n", mapb
                                            ? mapbase+0x100 & 0xff00
                                            : mapbase+0x10  & 0xff00 | 0x70);
  fprintf(fa, "        ld      a, 128\n");
  fprintf(fa, "        ld      b, 52\n");
  fprintf(fa, "        push    de\n");
  fprintf(fa, "        cp      a\n");
  fprintf(fa, "exinit: ld      c, 16\n");
  fprintf(fa, "        jr      nz, exget4\n");
  fprintf(fa, "        ld      de, 1\n");
  fprintf(fa, "        ld      ixl, c\n");
  if( speed==0 )
    fprintf(fa, "exget4: call    exgetb\n");
  else if ( speed==1 )
    fprintf(fa, "exget4: add     a, a\n"),
    fprintf(fa, "        call    z, exgetb\n");
  else
    fprintf(fa, "        defb    218\n"),
    fprintf(fa, "exgb4:  ld      a, (hl)\n"),
    fprintf(fa, "        %sc     hl\n", back ? "de" : "in"),
    fprintf(fa, "exget4: adc     a, a\n"),
    fprintf(fa, "        jr      z, exgb4\n");
  fprintf(fa, "        rl      c\n");
  fprintf(fa, "        jr      nc, exget4\n");
  if( mapb )
    sprintf(tmpstr1, "-%d", 0x100-(mapbase&0xff));
  else
    sprintf(tmpstr1, "%c%d", mapbase-(mapbase+0x10 & 0xff00)>0x6f ? '+' : '-'
                           , abs(mapbase-(mapbase+0x10 & 0xff00)-0x70));
  if( speed<2 )
    fprintf(fa, "        ld      (iy%s), c\n", tmpstr1),
    fprintf(fa, "        push    hl\n"),
    fprintf(fa, "        ld      hl, 1\n"),
    fprintf(fa, "        defb    210\n");
  else if ( speed==2 )
    fprintf(fa, "        inc     c\n"),
    fprintf(fa, "        ld      (iy%s), c\n", tmpstr1),
    fprintf(fa, "        push    hl\n"),
    fprintf(fa, "        ld      hl, 1\n"),
    fprintf(fa, "        defb    48\n");
  else
    fprintf(fa, "        ex      af, af'\n"),
    fprintf(fa, "        ld      a, c\n"),
    fprintf(fa, "        cp      8\n"),
    fprintf(fa, "        jr      c, exget5\n"),
    fprintf(fa, "        xor     136\n"),
    fprintf(fa, "exget5: inc     a\n"),
    fprintf(fa, "        ld      (iy%s), a\n", tmpstr1),
    fprintf(fa, "        push    hl\n"),
    fprintf(fa, "        ld      hl, 1\n"),
    fprintf(fa, "        ex      af, af'\n"),
    fprintf(fa, "        defb    210\n");
  fprintf(fa, "exsetb: add     hl, hl\n");
  fprintf(fa, "        dec     c\n");
  fprintf(fa, "        jr      nz, exsetb\n");
  if( mapb )
    sprintf(tmpstr2, "%c%d", (mapbase&0xff)>0xcb ? '+' : '-'
                           , abs((mapbase&0xff)-0xcc)),
    sprintf(tmpstr3, "%c%d", (mapbase&0xff)>0x97 ? '+' : '-'
                           , abs((mapbase&0xff)-0x98));
  else
    sprintf(tmpstr2, "%c%d", mapbase-(mapbase+0x10 & 0xff00)>0x3b ? '+' : '-'
                           , abs(mapbase-(mapbase+0x10 & 0xff00)-0x3c)),
    sprintf(tmpstr3, "%c%d", mapbase-(mapbase+0x10 & 0xff00)>0x07 ? '+' : '-'
                           , abs(mapbase-(mapbase+0x10 & 0xff00)-0x08));
  fprintf(fa, "        ld      (iy%s), e\n", tmpstr2);
  fprintf(fa, "        ld      (iy%s), d\n", tmpstr3);
  fprintf(fa, "        add     hl, de\n");
  fprintf(fa, "        ex      de, hl\n");
  fprintf(fa, "        inc     iyl\n");
  fprintf(fa, "        pop     hl\n");
  fprintf(fa, "        dec     ixl\n");
  fprintf(fa, "        djnz    exinit\n");
  fprintf(fa, "        pop     de\n");
  if( litf )
    fprintf(fa, "exlit:  inc    c\n"),
    fprintf(fa, "exseq:  ld%cr\n", back ? 'd' : 'i');
  else
    fprintf(fa, "exlit:  ld%c\n", back ? 'd' : 'i');
  if( speed==0 )
    fprintf(fa, "exloop: call    exgetb\n"),
    fprintf(fa, "        jr      c, exlit\n"),
    fprintf(fa, "        ld      c, %d\n", mapb ? 0xff : 0x6f),
    fprintf(fa, "exgeti: call    exgetb\n");
  else if ( speed==1 )
    fprintf(fa, "exloop: add     a, a\n"),
    fprintf(fa, "        call    z, exgetb\n"),
    fprintf(fa, "        jr      c, exlit\n"),
    fprintf(fa, "        ld      c, %d\n", mapb ? 0xff : 0x6f),
    fprintf(fa, "exgeti: add     a, a\n"),
    fprintf(fa, "        call    z, exgetb\n");
  else
    fprintf(fa, "exloop: add     a, a\n"),
    fprintf(fa, "        jr      z, exgbm\n"),
    fprintf(fa, "        jr      c, exlit\n"),
    fprintf(fa, "exgbmc: ld      c, %d\n", mapb ? 0xff : 0x6f),
    fprintf(fa, "exgeti: add     a, a\n"),
    fprintf(fa, "        jr      z, exgbi\n");
  fprintf(fa, "exgbic: inc     c\n");
  fprintf(fa, "        jr      c, exgeti\n");
  if( mapb ){
    fprintf(fa, "        bit     4, c\n");
    if( litf )
      fprintf(fa, "        jr      nz, excat\n");
    else
      fprintf(fa, "        ret     nz\n");
  }
  else{
    if( litf )
      fprintf(fa, "        jp      m, excat\n");
    else
      fprintf(fa, "        ret     m\n");
  }
  fprintf(fa, "        push    de\n");
  fprintf(fa, "        ld      iyl, c\n");
  if( speed>1 )
    fprintf(fa, "        ld      de, 0\n");
  if( speed==3 )
    fprintf(fa, "        ld      b, (iy%s)\n", tmpstr1),
    fprintf(fa, "        dec     b\n"),
    fprintf(fa, "        call    nz, exgbts\n"),
    fprintf(fa, "        ex      de, hl\n"),
    fprintf(fa, "        ld      c, (iy%s)\n", tmpstr2),
    fprintf(fa, "        ld      b, (iy%s)\n", tmpstr3),
    fprintf(fa, "        add     hl, bc\n"),
    fprintf(fa, "        ex      de, hl\n");
  else
    fprintf(fa, "        call    expair\n");
  fprintf(fa, "        push    de\n");
  if( mapb )
    fprintf(fa, "        ld      bc, 560\n"),
    fprintf(fa, "        dec     e\n"),
    fprintf(fa, "        jr      z, exgoit\n"),
    fprintf(fa, "        dec     e\n"),
    fprintf(fa, "        ld      bc, 1056\n"),
    fprintf(fa, "        jr      z, exgoit\n"),
    fprintf(fa, "        ld      c, 16\n");
  else
    fprintf(fa, "        ld      bc, 672\n"),
    fprintf(fa, "        dec     e\n"),
    fprintf(fa, "        jr      z, exgoit\n"),
    fprintf(fa, "        dec     e\n"),
    fprintf(fa, "        ld      bc, 1168\n"),
    fprintf(fa, "        jr      z, exgoit\n"),
    fprintf(fa, "        ld      c, 128\n");
  if( speed<2 )
    fprintf(fa, "exgoit: call    exgbts\n");
  else if ( speed==2 )
    fprintf(fa, "        ld      e, 0\n"),
    fprintf(fa, "exgoit: ld      d, e\n"),
    fprintf(fa, "        call    exgbts\n");
  else
    fprintf(fa, "        ld      e, 0\n"),
    fprintf(fa, "exgoit: ld      d, e\n"),
    fprintf(fa, "        call    exlee8\n");
  fprintf(fa, "        ld      iyl, c\n");
  fprintf(fa, "        add     iy, de\n");
  if( speed>1 )
    fprintf(fa, "        ld      e, d\n");
  if( speed==3 )
    fprintf(fa, "        ld      b, (iy%s)\n", tmpstr1),
    fprintf(fa, "        dec     b\n"),
    fprintf(fa, "        call    nz, exgbts\n"),
    fprintf(fa, "        ex      de, hl\n"),
    fprintf(fa, "        ld      c, (iy%s)\n", tmpstr2),
    fprintf(fa, "        ld      b, (iy%s)\n", tmpstr3),
    fprintf(fa, "        add     hl, bc\n"),
    fprintf(fa, "        ex      de, hl\n");
  else
    fprintf(fa, "        call    expair\n");
  fprintf(fa, "        pop     bc\n");
  fprintf(fa, "        ex      (sp), hl\n");
  if( back )
    fprintf(fa, "        ex      de, hl\n"),
    fprintf(fa, "        add     hl, de\n"),
    fprintf(fa, "        lddr\n");
  else
    fprintf(fa, "        push    hl\n"),
    fprintf(fa, "        sbc     hl, de\n"),
    fprintf(fa, "        pop     de\n"),
    fprintf(fa, "        ldir\n");
  fprintf(fa, "        pop     hl\n");
  fprintf(fa, "        jr      exloop\n");
  if( litf ){
    if( mapb )
      fprintf(fa, "excat:  rl      c\n"),
      fprintf(fa, "        ret     pe\n");
    else
      fprintf(fa, "excat:  ret     po\n");
    fprintf(fa, "        ld      b, (hl)\n");
    fprintf(fa, "        %sc     hl\n", back ? "de" : "in");
    fprintf(fa, "        ld      c, (hl)\n");
    fprintf(fa, "        %sc     hl\n", back ? "de" : "in");
    fprintf(fa, "        jr      exseq\n");
  }
  if( speed>1 )
    fprintf(fa, "exgbm:  ld      a, (hl)\n"),
    fprintf(fa, "        %sc     hl\n", back ? "de" : "in"),
    fprintf(fa, "        adc     a, a\n"),
    fprintf(fa, "        jr      nc, exgbmc\n"),
    fprintf(fa, "        jp      exlit\n"),
    fprintf(fa, "exgbi:  ld      a, (hl)\n"),
    fprintf(fa, "        %sc     hl\n", back ? "de" : "in"),
    fprintf(fa, "        adc     a, a\n"),
    fprintf(fa, "        jp      exgbic\n");
  if( speed==3 )
    fprintf(fa, "exgbts: jp      p, exlee8\n"),
    fprintf(fa, "        ld      e, (hl)\n"),
    fprintf(fa, "        %sc     hl\n", back ? "de" : "in"),
    fprintf(fa, "        rl      b\n"),
    fprintf(fa, "        ret     z\n"),
    fprintf(fa, "        srl     b\n"),
    fprintf(fa, "        defb    250\n"),
    fprintf(fa, "exxopy: ld      a, (hl)\n"),
    fprintf(fa, "        %sc     hl\n", back ? "de" : "in"),
    fprintf(fa, "exl16:  adc     a, a\n"),
    fprintf(fa, "        jr      z, exxopy\n"),
    fprintf(fa, "        rl      d\n"),
    fprintf(fa, "        djnz    exl16\n"),
    fprintf(fa, "        ret\n"),
    fprintf(fa, "excopy: ld      a, (hl)\n"),
    fprintf(fa, "        %sc     hl\n", back ? "de" : "in"),
    fprintf(fa, "exlee8: adc     a, a\n"),
    fprintf(fa, "        jr      z, excopy\n"),
    fprintf(fa, "        rl      e\n"),
    fprintf(fa, "        djnz    exlee8\n"),
    fprintf(fa, "        ret\n");
  else{
    fprintf(fa, "expair: ld      b, (iy%s)\n", tmpstr1);
    if( speed==2 )
      fprintf(fa, "        dec     b\n"),
      fprintf(fa, "        call    nz, exgbts\n");
    else
      fprintf(fa, "        call    exgbts\n");
    fprintf(fa, "        ex      de, hl\n");
    fprintf(fa, "        ld      c, (iy%s)\n", tmpstr2);
    fprintf(fa, "        ld      b, (iy%s)\n", tmpstr3);
    fprintf(fa, "        add     hl, bc\n");
    fprintf(fa, "        ex      de, hl\n");
    fprintf(fa, "        ret\n");
  }
  if( speed<2 ){
    fprintf(fa, "exgbts: ld      de, 0\n");
    fprintf(fa, "excont: dec     b\n");
    fprintf(fa, "        ret     m\n");
    if( speed==0 )
      fprintf(fa, "        call    exgetb\n");
    else
      fprintf(fa, "        add     a, a\n"),
      fprintf(fa, "        call    z, exgetb\n");
    fprintf(fa, "        rl      e\n");
    fprintf(fa, "        rl      d\n");
    fprintf(fa, "        jr      excont\n");
    if( speed==0 )
      fprintf(fa, "exgetb: add     a, a\n"),
      fprintf(fa, "        ret     nz\n"),
      fprintf(fa, "        ld      a, (hl)\n"),
      fprintf(fa, "        %sc     hl\n", back ? "de" : "in"),
      fprintf(fa, "        adc     a, a\n"),
      fprintf(fa, "        ret\n");
    else
      fprintf(fa, "exgetb: ld      a, (hl)\n"),
      fprintf(fa, "        %sc     hl\n", back ? "de" : "in"),
      fprintf(fa, "        adc     a, a\n"),
      fprintf(fa, "        ret\n");
  }
  if( speed==2 )
    fprintf(fa, "exgbg:  ld      a, (hl)\n"),
    fprintf(fa, "        %sc     hl\n", back ? "de" : "in"),
    fprintf(fa, "exgbts: adc     a, a\n"),
    fprintf(fa, "        jr      z, exgbg\n"),
    fprintf(fa, "        rl      e\n"),
    fprintf(fa, "        rl      d\n"),
    fprintf(fa, "        djnz    exgbts\n"),
    fprintf(fa, "        ret\n");
  output= (unsigned char *) malloc (0x10000);
  mem= (unsigned char *) malloc (0x10000);
  for( fil= 3; fil<argc; fil++ ){
    fi= fopen(argv[fil], "rb");
    if( !fi )
      printf("\nInput file not found: %s\n", argv[fil]),
      exit(-1);
    fread(input, 1, 0x10000, fi);
    fclose(fi);
    output_name= (char *)malloc(strlen(argv[fil])+5);
    strcpy(output_name, argv[fil]);
    strcat(output_name, ".opt");
    fo= fopen(output_name, "wb+");
    if( !fo )
      printf("\nCannot create output file: %s\n", output_name),
      exit(-1);
    inpos= outpos= mempos= 0;
    outbyte= outnex= 1;
    inbyte= input[inpos++];
    for( index= 0; index<52; ++index )
      index & 15 || (b2= 1),
      base[index]= b2,
      bits[index]= b1= getbits(4),
      putbits(b1, 4),
      b2+= 1 << b1;
    while( 1 )
      if( getbit() )
        mempos && putbit(1),
        mem[mempos++]= output[outnex++]= input[inpos++];
      else{
        for ( index= 0; !getbit(); index++ );
        if ( index==17 ){
          length= getbits(16);
          if( !mempos )
            --length,
            mem[mempos++]= output[outnex++]= input[inpos++];
          putbit(0);
          putbits( -2, 17 );
          output[outnex++]= length>>8;
          output[outnex++]= length&0xff;
          while ( length-- )
            mem[mempos++]= output[outnex++]= input[inpos++];
        }
        else{
          length= base[index] + getbits(bits[index]);
          if( length==1 )
            indoff= 0x30+getbits(2);
          else if( length==2 )
            indoff= 0x20+getbits(4);
          else
            indoff= 0x10+getbits(4);
          offset= base[indoff] + getbits(bits[indoff]);
          putbit(0);
          if( index==16 ){
            putbits( -2, 17 + litf );
            break;
          }
          if( (length&255)==1 )
            if( length == 1
             || offset < base[51]+(1<<bits[51]) )
              encode(length, 4, 0),
              encode(offset, 2, 0x30);
            else
              if( encodebits(length-3, 4, 0)
                + encodebits(3, 4, 0)
                - encodebits(length, 4, 0)
                + encodebits(offset, 4, 0x10) + 1
                < encodebits(length-1, 4, 0)
                - encodebits(length, 4, 0) + 9 )
                encode(length-3, 4, 0),
                encode(offset, 4, 0x10),
                putbit(0),
                encode(3, 4, 0),
                encode(offset, 4, 0x10);
              else
                encode(length-1, 4, 0),
                encode(offset, 4, 0x10),
                putbit(1),
                output[outnex++]= mem[mempos-offset+length-1];
          else if( (length&0xff)==2 )
            if( length == 2
             || offset < base[0x2f]+(1<<bits[0x2f]) )
              encode(length, 4, 0),
              encode(offset, 4, 0x20);
            else
              if( encodebits(length-3, 4, 0)
                + encodebits(3, 4, 0)
                - encodebits(length, 4, 0)
                + encodebits(offset, 4, 0x10) + 1
                < encodebits(length-2, 4, 0)
                - encodebits(length, 4, 0) + 18 )
                encode(length-3, 4, 0),
                encode(offset, 4, 0x10),
                putbit(0),
                encode(3, 4, 0),
                encode(offset, 4, 0x10);
              else
                encode(length-2, 4, 0),
                encode(offset, 4, 0x10),
                putbit(1),
                output[outnex++]= mem[mempos-offset+length-2],
                putbit(1),
                output[outnex++]= mem[mempos-offset+length-1];
          else
            encode(length, 4, 0),
            encode(offset, 4, 0x10);
          while ( length-- )
            mem[mempos++]= mem[mempos-offset];
        }
      }
    while( outbyte<0x100 )
      outbyte<<= 1;
    output[outpos]= outbyte;
    if( back )
      for ( b1= 0; b1<outnex>>1; b1++ )
        b2= output[b1],
        output[b1]= output[outnex-1-b1],
        output[outnex-1-b1]= b2;
    fwrite(output, 1, outnex, fo);
    printf("\n  %d bytes processed from %s", outnex, argv[fil]);
  }
  litf && printf("\n\nLiterals found, for a shorter decruncher avoid them with -c in exomizer");
  printf("\n");
}