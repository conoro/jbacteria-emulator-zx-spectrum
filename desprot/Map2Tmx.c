#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x10000);
  char tmpstr[100];
  FILE *fi, *fo;
  int size, scrw, scrh, mapw, maph;
  if( argc==1 )
    printf("\nMap2Tmx v0.99, MAP file (Mappy) to TMX (Tiled) by Antonio Villena, 23 Oct 2013\n\n"),
    printf("  Map2Tmx <screen_w> <screen_h> <map_w> <map_h> <input_file> <output_file>\n\n"),
    printf("  <screen_w>     Screen width\n"),
    printf("  <screen_h>     Screen height\n"),
    printf("  <map_w>        Map width\n"),
    printf("  <map_h>        Map height\n"),
    printf("  <input_file>   Origin file\n"),
    printf("  <output_file>  Genetated output file\n\n"),
    printf("Example: Map2Tmx 15 10 5 4 trabajobasura.map mapa.tmx\n"),
    exit(0);
  if( argc!=7 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[5], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[5]),
    exit(-1);
  fo= fopen(argv[6], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[6]),
    exit(-1);
  size= fread(mem, 1, 0x10000, fi);
  fclose(fi);
  scrw= atoi(argv[1]);
  scrh= atoi(argv[2]);
  mapw= atoi(argv[3]);
  maph= atoi(argv[4]);
  sprintf(tmpstr, "width=\"%d\" height=\"%d\"", scrw*mapw+mapw-1, scrh*maph+maph-1);
  fprintf(fo, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
  fprintf(fo, "<map version=\"1.0\" orientation=\"orthogonal\" %s ", tmpstr);
  fprintf(fo, "tilewidth=\"16\" tileheight=\"16\">\n");
  fprintf(fo, " <tileset firstgid=\"1\" name=\"work\" tilewidth=\"16\" tileheight=\"16\">\n");
  fprintf(fo, "  <image source=\"../gfx/work.png\" width=\"256\" height=\"48\"/></tileset>\n");
  fprintf(fo, " <layer name=\"work\" %s>\n", tmpstr);
  fprintf(fo, "  <data encoding=\"csv\">\n");
  for ( int i= 0; i<size; i++ ){
    if( !(i%scrw) && i%(mapw*scrw) )
      fprintf(fo, "00,");
    if( i && !(i%(mapw*scrw*scrh)) ){
      for ( int j= 0; j<mapw*scrw+mapw-1; j++ )
        fprintf(fo, "00,");
      fprintf(fo, "\n");
    }
    if( i==size-1 )
      fprintf(fo, "%02d\n", mem[i]+1);
    else if( (i+1)%(scrw*mapw) )
      fprintf(fo, "%02d,", mem[i]+1);
    else
      fprintf(fo, "%02d,\n", mem[i]+1);
  }
  fprintf(fo, "</data></layer></map>\n");
  fclose(fo);
  printf("\nFile generated successfully\n");
}