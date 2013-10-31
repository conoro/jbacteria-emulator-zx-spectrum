#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
unsigned char *image, *pixel;
unsigned error, width, height, i, j, k, l, fondo, tinta;

int check(int value){
  return value==0 || value==192 || value==255;
}
int tospec(int r, int g, int b){
  return ((r|g|b)==255 ? 8 : 0) | g>>7<<2 | r>>7<<1 | b>>7;
}
void celdagen(void){
  pixel= &image[(((j|i<<8)<<4)+(k<<8)+l)<<2];
// pixel= &image[(((j|i<<8)<<4) | k<<8 | l)<<2];
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
  printf("hola: %d %d %d - %d\n" , pixel[0], pixel[1], pixel[2], tospec(pixel[0], pixel[1], pixel[2]));
}

int main(int argc, char *argv[]){
  error= lodepng_decode32_file(&image, &width, &height, "tiles.png");
  if( error )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  if( width!= 256 )
    printf("Error. The width of tiles.png must be 256");
  for ( i= 0; i < height>>4; i++ )
    for ( j= 0; j < 16; j++ ){
      pixel= &image[((j|i<<8)<<4)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 0; k < 8; k++ )
        for ( l= 0; l < 8; l++ )
          celdagen();
      pixel= &image[(((j|i<<8)<<4)+8)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 0; k < 8; k++ )
        for ( l= 8; l < 16; l++ )
          celdagen();
      pixel= &image[(((j|i<<8)<<4)+2048)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 8; k < 16; k++ )
        for ( l= 0; l < 8; l++ )
          celdagen();
      pixel= &image[(((j|i<<8)<<4)+2056)<<2];
      fondo= tinta= tospec(pixel[0], pixel[1], pixel[2]);
      for ( k= 8; k < 16; k++ )
        for ( l= 8; l < 16; l++ )
          celdagen();
    }
  pixel[0]= 0;
  pixel[1]= 192;
  pixel[2]= 255;
  printf("error: %d \n", (char)pixel[0]*-1 | (char)pixel[1]*-1 | (char)pixel[2]*-1);
  free(image);
  return 0;
}
