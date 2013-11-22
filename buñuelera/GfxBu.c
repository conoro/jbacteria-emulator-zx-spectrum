#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
unsigned char *image, *pixel, output[0x600];
unsigned error, width, height, i, j, k, l, fondo, tinta, outpos= 0;
long long atr, celdas[4];
FILE *fo;

int main(int argc, char *argv[]){
  if( argc==1 )
    printf("\nGfxBu v1.11. Bu Sprites generator by AntonioVillena, 20 Nov 2013\n\n"
           "  GfxBu <input_sprites> <output_sprites>\n\n"
           "  <input_sprites>   Normally sprites.png\n"
           "  <output_sprites>  Output binary file\n\n"
           "Example: GfxBu sprites.png sprites.bin\n"),
    exit(0);
  if( argc!=3 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  error= lodepng_decode32_file(&image, &width, &height, argv[1]);
  printf("Processing %s...", argv[1]);
  if( error )
    printf("\nError %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  fclose(fo);
  fo= fopen(argv[2], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[2]),
    exit(-1);
  for ( i= 0; i < 16; i++ )
    for ( j= 0; j < 16; j++ ){
      for ( k= 0; k < 8; k+= 2 ){
        tinta= fondo= 0;
        for ( l= 0; l < 16; l++ )
          tinta|= image[(i>>3<<12 | (i&7)<<5 | j<<8 | l)<<2] ? 0x800000>>l+k : 0,
          fondo|= image[(i>>3<<12 | (i&7)<<5 | j<<8 | 16 | l)<<2] ? 0x800000>>l+k : 0;
        fprintf(fo, "        defb %06x, %06x\n", tinta, fondo);
      }
      fprintf(fo, "\n");
    }
  fclose(fo);
  printf("Done\n"
         "Files generated successfully\n", argv[4], argv[5]);
  free(image);
}
