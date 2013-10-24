#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x10000);
  char tmpstr[100];
  FILE *fi, *fo;
  int size, scrw, scrh, mapw, maph, lock;
  if( argc==1 )
    printf("\nMap2Tmx v0.99, MAP file (Mappy) to TMX (Tiled) by Antonio Villena, 23 Oct 2013\n\n"),
    printf("  Map2Tmx <map_w> <map_h> <screen_w> <screen_h> <lock> <input_f> <output_f>\n\n"),
    printf("  <map_w>     Map width\n"),
    printf("  <map_h>     Map height\n"),
    printf("  <screen_w>  Screen width\n"),
    printf("  <screen_h>  Screen height\n"),
    printf("  <lock>      Tile number of the lock, normally 15\n"),
    printf("  <input_f>   Origin file\n"),
    printf("  <output_f>  Generated output file\n\n"),
    printf("Example: Map2Tmx 5 4 15 10 15 trabajobasura.map mapa.tmx\n"),
    exit(0);
  if( argc!=8 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[6], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[6]),
    exit(-1);
  fo= fopen(argv[7], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[7]),
    exit(-1);
  size= fread(mem, 1, 0x10000, fi);
  fclose(fi);
  mapw= atoi(argv[1]);
  maph= atoi(argv[2]);
  scrw= atoi(argv[3]);
  scrh= atoi(argv[4]);
  lock= atoi(argv[5]);
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