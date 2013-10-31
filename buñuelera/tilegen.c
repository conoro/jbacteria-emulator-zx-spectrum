#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]){
  unsigned error;
  unsigned char* image;
  unsigned width, height;
  error= lodepng_decode32_file(&image, &width, &height, "tiles.png");
  printf("error: %d %d %d %d %d %d %d %d\n", image[8], image[9], image[10], image[11], image[4], image[5], image[6], image[7]);
  if(error) printf("error %u: %s\n", error, lodepng_error_text(error));
  free(image);
  return 0;
}

