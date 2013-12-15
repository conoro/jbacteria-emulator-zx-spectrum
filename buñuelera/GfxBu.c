#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
unsigned char *image, *pixel, output[0x6000];
unsigned error, width, height, i, j, k, l, min, max, nmin, nmax, amin, amax, param,
          mask, pics, amask, apics, inipos, reppos, outpos= 256;
long long atr, celdas[4];
FILE *fo;

int main(int argc, char *argv[]){
  if( argc==1 )
    printf("\nGfxBu v1.11. Bu Sprites generator by AntonioVillena, 20 Nov 2013\n\n"
           "  GfxBu <input_sprites> <output_sprites> <table_address>\n\n"
           "  <input_sprites>   Normally sprites.png\n"
           "  <output_sprites>  Output binary file\n"
           "  <table_address>   In hexadecimal, address of the table\n\n"
           "Example: GfxBu sprites.png sprites.bin b000\n"),
    exit(0);
  if( argc!=4 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  error= lodepng_decode32_file(&image, &width, &height, argv[1]);
  printf("Processing %s...", argv[1]);
  if( error )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  fo= fopen(argv[2], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[2]),
    exit(-1);
  param= strtol(argv[3], NULL, 16);
  for ( i= 0; i < 16; i++ )
    for ( j= 0; j < 8; j++ ){
      output[j<<1|i<<4]= outpos+param;
      output[1|j<<1|i<<4]= outpos+param>>8;
      output[inipos= outpos]= 0;
      outpos+= 2;
      nmin= nmax= 4;
      for ( k= 0; k < 16; k++ ){
        pics= mask= 0;
        for ( l= 0; l < 16; l++ )
          pics|= image[(i>>3<<12 | (i&7)<<5 | k<<8 | l)<<2] ? 0x800000>>l+j : 0,
          mask|= image[(i>>3<<12 | (i&7)<<5 | k<<8 | 16 | l)<<2] ? 0 : 0x800000>>l+j;
        for ( min= 0; min < 3 && !(mask&0xff<<(2-min<<3)); min++ );
        for ( max= 3; max && !(mask&0xff<<(3-max<<3)); max-- );
        if( k&1 ){
          if( min>amin ) min= amin;
          if( max<amax ) max= amax;
          if( min<max ){
            if( (nmin!=min) || (nmax!=max) )
              output[reppos= outpos]= min+1-(nmin>2?0:nmin)&3 | max-min-1<<2,
              outpos+= 2,
              output[inipos]++,
              output[reppos+1]= 0;
            output[reppos+1]++;
            for ( l= min; l < max; l++ )
              output[outpos++]= apics>>(2-l<<3),
              output[outpos++]= amask>>(2-l<<3)^0xff;
            for ( l= max; l > min; l-- )
              output[outpos++]= pics>>(3-l<<3),
              output[outpos++]= mask>>(3-l<<3)^0xff;
          }
          else{
            if( nmin>2 )
              output[inipos+1]+= 2;
          }
          nmin= min;
          nmax= max;
        }
        else
          apics= pics,
          amask= mask;
          amin= min,
          amax= max;
      }
      if( (inipos+2)==outpos ){
        outpos-= 2;
        goto salir;
      }
    }
salir:
  fwrite(output, 1, outpos, fo);
  fclose(fo);
  printf("Done\n"
         "Files generated successfully\n", argv[4], argv[5]);
  free(image);
}
