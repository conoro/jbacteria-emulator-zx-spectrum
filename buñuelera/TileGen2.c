#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
unsigned char *image, *pixel, *output;
unsigned error, width, height, i, j, k, l, fondo, tinta, outpos= 0;
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
  output= (unsigned char *) malloc (0x10000);
  error= lodepng_decode32_file(&image, &width, &height, "tiles.png");
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
  fo= fopen("tiles.bin", "wb+");
  fwrite(output, 1, outpos, fo);
  fclose(fo);
  free(image);
  return 0;
}
