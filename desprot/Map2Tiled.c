#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x10000);
  unsigned char tmp;
  int width, height;
  char oname[100];
  FILE *fi, *fo;
  long size, size_hi, size_lo;
  if( argc==1 )
    printf("\nMap2Tiled v0.99, a Mappy to Tiled conversor by Antonio Villena, 23 Oct 2013\n\n"),
    printf("  Map2Tiled <mapwidth> <mapheight> <input_file.map>\n\n"),
    exit(0);
  if( argc!=4 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  if ( stricmp(strchr(argv[3], '.'), ".map") )
    printf("\nInvalid input extension: %s\n", strchr(argv[3], '.')),
    exit(-1);
  fi= fopen(argv[3], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[3]),
    exit(-1);
  width= strtol(argv[1], NULL, 16);
  height= strtol(argv[2], NULL, 16);
  if( width*height<1 || width*height>99 )
    printf("\nInvalid range, mapwidth*mapheight must be between 1 and 99 and it is %d\n", width*height),
    exit(-1);
  size= fread(mem+128, 1, 0x10000, fi);
  if( size % (width*height) )
    printf("\nInput file size is incorrect\n"),
    exit(-1);

  for ( int i= 0; i<height; i++ )
    for ( int j= 0; j<width; j++ ){
      sprintf(oname, "%s%d.tmx", argv[3], 1+i*width+j);
      fo= fopen(oname, "wb+");
      if( !fo )
        printf("\nCannot create output file: %s\n", oname),
        exit(-1);
      fclose(fo);
//      output_name= (char *)malloc(filenl+7);
//      memcpy(output_name, argv[3], filenl);
//      strcat(output_name, i_to_a(i*width+j));
//      strcat(output_name, sprintf("%d.tmx", i*width+j));
//      printf("%s\n", output_name);
//      printf("%d, ", i*width+j);
  }


  printf("\n0x%X bytes reversed\n", size);
}