#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
unsigned char *image, *pixel, output[0x10000];
unsigned error, width, height, i, j, k, l, min, max, nmin, nmax, amin, amax, param,
          mask, pics, amask, apics, inipos, reppos, smooth, outpos, fondo, tinta;
long long atr, celdas[4];
FILE *fo;

int check(int value){
  return value==0 || value==192 || value==255;
}

int tospec(int r, int g, int b){
  return ((r|g|b)==255 ? 8 : 0) | g>>7<<2 | r>>7<<1 | b>>7;
}

celdagen(){
  pixel= &image[(((j|i<<8)<<4) | k<<8 | l)<<2];
  if( !(check(pixel[0]) && check(pixel[1]) && check(pixel[2]))
    || ((char)pixel[0]*-1 | (char)pixel[1]*-1 | (char)pixel[2]*-1)==65 )
    printf("El pixel (%d, %d) tiene un color incorrecto\n" , j*16+l, i*16+k),
    exit(-1);
  if( tinta != tospec(pixel[0], pixel[1], pixel[2]) )
    if( fondo != tospec(pixel[0], pixel[1], pixel[2]) ){
      if( tinta != fondo )
        printf("El pixel (%d, %d) tiene un tercer color de celda\n", j*16+l, i*16+k),
        exit(-1);
      tinta= tospec(pixel[0], pixel[1], pixel[2]);
    }
  celdas[k>>3<<1 | l>>3]<<= 1;
  celdas[k>>3<<1 | l>>3]|= fondo != tospec(pixel[0], pixel[1], pixel[2]);
}

atrgen(){
  atr<<= 8;
  if( fondo==tinta ){
    if( tinta )
      celdas[k>>4<<1 | l>>4]= 0xffffffffffffffff,
      atr|= tinta&7 | tinta<<3&64;
    else
      celdas[k>>4<<1 | l>>4]= 0,
      atr|= 7;
  }
  else if( fondo<tinta )
    atr|= fondo<<3 | tinta&7 | tinta<<3&64;
  else
    celdas[k>>4<<1 | l>>4]^= 0xffffffffffffffff,
    atr|= tinta<<3 | fondo&7 | fondo<<3&64;
}

int main(int argc, char *argv[]){
  if( argc==1 )
    printf("\nGfxBu v1.11. Bu Sprites generator by AntonioVillena, 20 Nov 2013\n\n"
           "  GfxBu <input_tiles> <input_sprites> <output_tiles> <output_sprites> <table_address> [smooth]\n\n"
           "  <input_tiles>     Normally tiles.png\n"
           "  <input_sprites>   Normally sprites.png\n"
           "  <output_tiles>    Output binary tiles\n"
           "  <output_sprites>  Output binary sprites\n"
           "  <table_address>   In hexadecimal, address of the table\n\n"
           "Example: GfxBu tiles.png sprites.png tiles.bin sprites.bin b000\n"),
    exit(0);
  if( argc!=6 && argc!=7 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  smooth= argc&1;

// tiles

  error= lodepng_decode32_file(&image, &width, &height, argv[1]);
  printf("Processing %14s...", argv[1]);
  if( error )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  if( width!= 256 )
    printf("Error. The width of tiles.png must be 256");
  for ( i= 0; i < height>>4; i++ )
    for ( j= 0; j < 16; j++ ){
      celdas[0]= celdas[1]= celdas[2]= celdas[3]= atr= 0;
      pixel= &image[((j|i<<8)<<4)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 0; k < 8; k++ )
        for ( l= 0; l < 8; l++ )
          celdagen();
      atrgen();
      pixel= &image[(((j|i<<8)<<4)|8)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 0; k < 8; k++ )
        for ( l= 8; l < 16; l++ )
          celdagen();
      atrgen();
      pixel= &image[(((j|i<<8)<<4)|2048)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 8; k < 16; k++ )
        for ( l= 0; l < 8; l++ )
          celdagen();
      atrgen();
      pixel= &image[(((j|i<<8)<<4)|2056)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 8; k < 16; k++ )
        for ( l= 8; l < 16; l++ )
          celdagen();
      atrgen();
      for ( k= 0; k < 4; k++ )
        for ( l= 0; l < 8; l++ )
          output[outpos++]= celdas[k]>>(56-l*8);
      for ( l= 0; l < 4; l++ )
        output[outpos++]= atr>>(24-l*8);
    }
  pics= outpos/36;
  inipos= 0x3000;
  for ( reppos= i= 0; i < pics; i++ ){
    for ( j= 0; j < i; j++ ){
      for ( k= l= 0; k < 32; k++ )
        l+= output[i*36+k]-output[j*36+k];
      if( !l )
        break;
    }
    output[inipos++]= j<i ? output[0x3000|j] : reppos++;
  }
  inipos= 0x4000;
  for ( apics= i= 0; i < pics; i++ ){
    for ( j= 0; j < i; j++ ){
      for ( k= l= 0; k < 4; k++ )
        l+= output[i*36+32+k]-output[j*36+32+k];
      if( !l )
        break;
    }
    output[inipos++]= j<i ? output[0x4000|j] : apics++;
  }
  printf("\nno index     %d\n", pics*36);
  printf("index bitmap %d\n", reppos*32+pics*5);
  printf("index attr   %d\n", apics*4+pics*33);
  printf("full index   %d\n", reppos*32+apics*4+pics*2);
  for ( i= 0; i < pics; i++ ){
    printf("%2d %2d %2d, ", i, output[0x3000 | i], output[0x4000 | i]);
  }
  fo= fopen(argv[3], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[3]),
    exit(-1);
  fwrite(output, 1, outpos, fo);
  fclose(fo);
  free(image);
  printf("Done\n");

// sprites

  outpos= 128<<smooth;
  error= lodepng_decode32_file(&image, &width, &height, argv[2]);
  printf("Processing %14s...", argv[2]);
  if( error )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  fo= fopen(argv[4], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[4]),
    exit(-1);
  param= strtol(argv[5], NULL, 16);
  for ( i= 0; i < 16; i++ )
    for ( j= 0; j < 8; j+= 2-smooth ){
      output[(j|i<<3)<<smooth]= outpos+param;
      output[1|(j|i<<3)<<smooth]= outpos+param>>8;
      output[inipos= outpos]= 0;
      output[inipos+1]= smooth ? 0x28 : 0x50;
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
              output[reppos= outpos]= min+1-(nmin>2?0:nmin)&3 | (max-min==3?3:max-min-1)<<2,
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
          else if( nmin==4 )
            output[inipos+1]+= 2;
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
         "Generating      table.bin...Done\n"
         "Files generated successfully\n");
  free(image);

// table

  unsigned short table[0xb0];
  fo= fopen("table.bin", "wb+");
  if( smooth )
    for ( int i= 0x38; i<0xe8; i++ )
      table[i-0x38]= 0x3800 + (i<<8&0x700) + (i<<2&0xe0) + (i<<5&0x1800);
  else
    for ( int i= 0x1c; i<0x7c; i++ )
      table[i-0x1c]= 0x3800 + (i<<9&0x700) + (i<<3&0xe0) + (i<<6&0x1800);
  fwrite(table, 1, 0xb0<<smooth, fo);
  fclose(fo);
}
