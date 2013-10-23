#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x10000);
  FILE *fi, *fo;
  int size, scrwidth, scrheight, mapwidth;
  if( argc==1 )
    printf("\nMap2Dec v0.99, binary file to CSV decimal ASCII converter by Antonio Villena, 23 Oct 2013\n\n"),
    printf("  Map2Dec <scrwidth> <scrheight> <mapwidth> <input_file> <output_file>\n\n"),
    printf("  <width>        Insert line feed every <width> bytes\n"),
    printf("  <input_file>   Origin binary file\n"),
    printf("  <output_file>  Genetated output file\n\n"),
    exit(0);
  if( argc!=6 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[4], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[4]),
    exit(-1);
  fo= fopen(argv[5], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[5]),
    exit(-1);
  size= fread(mem, 1, 0x10000, fi);
  scrwidth= atoi(argv[1]);
  scrheight= atoi(argv[2]);
  mapwidth= atoi(argv[3]);
//    fprintf(fa, "expair: ld      b, (iy%s)\n", tmpstr1);
  for ( int i= 0; i<size; i++ ){
    if( !(i%scrwidth) && i%(mapwidth*scrwidth) )
      fprintf(fo, "00,");
    if( i && !(i%(mapwidth*scrwidth*scrheight)) ){
      for ( int j= 0; j<mapwidth*scrwidth+mapwidth-1; j++ )
        fprintf(fo, "00,");
      fprintf(fo, "\n");
    }
    fprintf(fo, "%02d,", mem[i]+1);
    if( !((i+1)%(scrwidth*mapwidth)) )
      fprintf(fo, "\n");
  }
  fclose(fi);
  fclose(fo);
//  printf("\n0x%X bytes written (%d) at offset 0x%X (%d)\n", length, length, start, start);
}