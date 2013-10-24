#include <stdio.h>
int main(int argc, char* argv[]){
  char tmpstr[100];
  FILE *fi, *fo;
  int size, scrw, scrh, mapw, maph, lock;
  if( argc==1 )
    printf("\nTmxGen v0.99, TMX (Tiled) blank file generator by Antonio Villena, 24 Oct 2013\n\n"),
    printf("  TmxGen <map_w> <map_h> <screen_w> <screen_h> <lock> <output_f>\n\n"),
    printf("  <map_w>     Map width\n"),
    printf("  <map_h>     Map height\n"),
    printf("  <screen_w>  Screen width\n"),
    printf("  <screen_h>  Screen height\n"),
    printf("  <lock>      Tile number of the lock, normally 15\n"),
    printf("  <output_f>  Generated output file\n\n"),
    printf("Example: TmxGen 5 4 15 10 15 map.tmx\n"),
    exit(0);
  if( argc!=7 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fo= fopen(argv[6], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[6]),
    exit(-1);
  mapw= atoi(argv[1]);
  maph= atoi(argv[2]);
  scrw= atoi(argv[3]);
  scrh= atoi(argv[4]);
  lock= atoi(argv[5]);
  size= mapw*maph*scrw*scrh;
  sprintf(tmpstr, "width=\"%d\" height=\"%d\"", scrw*mapw+mapw-1, scrh*maph+maph-1);
  fprintf(fo, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
  fprintf(fo, "<map version=\"1.0\" orientation=\"orthogonal\" %s ", tmpstr);
  fprintf(fo, "tilewidth=\"16\" tileheight=\"16\">\n");
  fprintf(fo, " <properties><property name=\"lock\" value=\"%d\"/></properties>\n", lock);
  fprintf(fo, " <tileset firstgid=\"1\" name=\"work\" tilewidth=\"16\" tileheight=\"16\">\n");
  fprintf(fo, "  <image source=\"../gfx/work.png\"/></tileset>\n");
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
      fprintf(fo, "01\n");
    else if( (i+1)%(scrw*mapw) )
      fprintf(fo, "01,");
    else
      fprintf(fo, "01,\n");
  }
  fprintf(fo, "</data></layer></map>\n");
  fclose(fo);
  printf("\nFile generated successfully\n");
}