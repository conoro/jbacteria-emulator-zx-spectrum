#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x10000);
  char tmpstr[100];
  FILE *fi, *fo;
  int size, scrw, scrh, mapw, maph, lock;
  if( argc==1 )
    printf("\nMap2Tmx v1.00, MAP file (Mappy) to TMX (Tiled) by Antonio Villena, 26 Oct 2013\n\n"),
    printf("  Map2Tmx       <map_width> <map_height> <screen_width> <screen_height>\n"),
    printf("                <lock> <output_tmx> [<input_map>] [<input_ene>]\n\n"),
    printf("  <map_width>       Map width\n"),
    printf("  <map_height>      Map height\n"),
    printf("  <screen_width>    Screen width\n"),
    printf("  <screen_height>   Screen height\n"),
    printf("  <lock>            Tile number of the lock, normally 15\n"),
    printf("  <output_tmx>      Generated output file\n"),
    printf("  <input_map>       Origin .map file\n"),
    printf("  <input_ene>       Origin .ene file\n\n"),
    printf("Last 2 params are optionally. If not specified will create a black .tmx.\n"),
    printf("If only the map is specified, the .tmx will have a blank object layer.\n\n"),
    printf("Example: Map2Tmx 5 4 15 10 15 mapa.tmx trabajobasura.map enems.ene\n"),
    exit(0);
  if( argc!=8 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fo= fopen(argv[6], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[6]),
    exit(-1);
  fi= fopen(argv[7], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[7]),
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
  fprintf(fo, " <tileset firstgid=\"101\" name=\"sprites\" tilewidth=\"16\" tileheight=\"16\">\n");
  fprintf(fo, "  <image source=\"../gfx/sprites.png\"/></tileset>\n");
  fprintf(fo, " <layer name=\"map\" %s>\n", tmpstr);
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
  fprintf(fo, "</data></layer>");
  fprintf(fo, " <objectgroup name=\"enems\" %s>\n", tmpstr);
  fprintf(fo, "</objectgroup></map>\n");
  fclose(fo);
  printf("\nFile generated successfully\n");
}