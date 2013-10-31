#include <stdio.h>
#include <stdlib.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) calloc (0x10000, 1);
  char tmpstr[100];
  FILE *fi, *fo;
  int size, scrw, scrh, mapw, maph, lock, i, j, k, l;
  unsigned char type, xi, xe, yi, ye, speed;
  if( argc==1 )
    printf("\nMap2Tmx v1.01, MAP file (Mappy) to TMX (Tiled) by Antonio Villena, 28 Oct 2013\n\n"),
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
  if( argc<7 || argc>9 )
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
  if( argc>7 ){
    fi= fopen(argv[7], "rb");
    if( !fi )
      printf("\nInput file not found: %s\n", argv[7]),
      exit(-1);
    size= fread(mem, 1, 0x10000, fi);
    fclose(fi);
  }
  sprintf(tmpstr, "width=\"%d\" height=\"%d\"", scrw*mapw+mapw-1, scrh*maph+maph-1);
  fprintf(fo, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
  fprintf(fo, "<map version=\"1.0\" orientation=\"orthogonal\" %s ", tmpstr);
  fprintf(fo, "tilewidth=\"16\" tileheight=\"16\">\n");
  fprintf(fo, " <properties><property name=\"lock\" value=\"%d\"/></properties>\n", lock);
  fprintf(fo, " <tileset firstgid=\"1\" name=\"work\" tilewidth=\"16\" tileheight=\"16\">\n");
  fprintf(fo, "  <image source=\"tiles.png\"/></tileset>\n");
  fprintf(fo, " <tileset firstgid=\"301\" name=\"sprites\" tilewidth=\"16\" tileheight=\"16\">\n");
  fprintf(fo, "  <image source=\"sprites.png\"/></tileset>\n");
  fprintf(fo, " <layer name=\"map\" %s>\n", tmpstr);
  fprintf(fo, "  <data encoding=\"csv\">\n");
  for ( int i= 0; i<size; i++ ){
    if( !(i%scrw) && i%(mapw*scrw) )
      fprintf(fo, "0,");
    if( i && !(i%(mapw*scrw*scrh)) ){
      for ( int j= 0; j<mapw*scrw+mapw-1; j++ )
        fprintf(fo, "0,");
      fprintf(fo, "\n");
    }
    if( i==size-1 )
      fprintf(fo, "%d\n", mem[i]+1);
    else if( (i+1)%(scrw*mapw) )
      fprintf(fo, "%d,", mem[i]+1);
    else
      fprintf(fo, "%d,\n", mem[i]+1);
  }
  fprintf(fo, "</data></layer>\n <objectgroup name=\"enems\" %s>\n", tmpstr);
  if( argc>8 ){
    fi= fopen(argv[8], "rb");
    if( !fi )
      printf("\nInput file not found: %s\n", argv[8]),
      exit(-1);
    size= fread(mem, 1, 0x105, fi);
    l= 501;
    for ( i= 0; i<maph; i++ )
      for ( j= 0; j<mapw; j++ )
        for ( k= 0; k<3; k++ ){
          fread(&type, 1, 1, fi);
          fread(&xi, 1, 1, fi);
          fread(&yi, 1, 1, fi);
          fread(&xe, 1, 1, fi);
          fread(&ye, 1, 1, fi);
          fread(&speed, 1, 1, fi);
          fread(mem, 2, 1, fi);
          if( type>4 )
            fprintf(fo, "<object name=\"%d\" type=\"%d\" gid=\"325\" x=\"%d\" y=\"%d\"/>\n",
                    type, speed, (xi+j*(scrw+1))<<4, (1+yi+i*(scrh+1))<<4);
          else if( type )
            fprintf(fo, "<object name=\"%d\" type=\"%d\" gid=\"%d\" x=\"%d\" y=\"%d\"/>\n"
                        "<object name=\"%d\" type=\"%d\" gid=\"%d\" x=\"%d\" y=\"%d\"/>\n",
                    l++, speed, 307+2*type, (xi+j*(scrw+1))<<4, (1+yi+i*(scrh+1))<<4,
                    l,   speed, 308+2*type, (xe+j*(scrw+1))<<4, (1+ye+i*(scrh+1))<<4);
        }
    for ( i= 0; i<maph; i++ )
      for ( j= 0; j<mapw; j++ ){
        fread(&xi, 1, 1, fi);
        fread(&type, 1, 1, fi);
        yi= xi & 15;
        xi>>= 4;
        if( type )
          fprintf(fo, "<object gid=\"%d\" x=\"%d\" y=\"%d\"/>\n",
                  17+type, (xi+j*(scrw+1))<<4, (1+yi+i*(scrh+1))<<4);
      }
    
    fclose(fi);
  }
  fprintf(fo, "</objectgroup></map>\n");
  fclose(fo);
  printf("\nFile generated successfully\n");
}