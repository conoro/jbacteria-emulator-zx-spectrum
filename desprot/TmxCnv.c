#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct enem{
  unsigned char xi, yi, xe, ye, speed;
  short type;
};
typedef struct{
  unsigned char xy, type;
  struct enem ene[3];
} screlm;
int sgn(int val) {
  return (0 < val) - (val < 0);
}

int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x10000);
  char tmpstr[1000];
  char *fou, *token;
  FILE *fi, *fo;
  int size= 0, scrw, scrh, mapw, maph, lock, numlock= 0, tmpi, elem, sum,
      tog= 0, i, j, k, l, type, gid, x, y, name, mapx, mapy, baddies= 0;
  if( argc==1 )
    printf("\nTmxCnv v0.99, TMX to H generator by Antonio Villena, 24 Oct 2013\n\n"),
    printf("  TmxCnv <input_file> <output_file>\n\n"),
    printf("  <input_file>   Origin .TMX file\n"),
    printf("  <output_file>  Generated .H output file\n\n"),
    printf("Example: TmxCnv map\\mapa.tmx dev\\mapa.h\n"),
    exit(0);
  if( argc<3 || argc>4 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[1], "r");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  fo= fopen(argv[2], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[2]),
    exit(-1);
  while ( !feof(fi) && !strstr(tmpstr, "data e") ){
    fgets(tmpstr, 1000, fi);
    if( fou= (char *) strstr(tmpstr, " width") )
      scrw= atoi(fou+8);
    if( fou= (char *) strstr(tmpstr, " height") )
      scrh= atoi(fou+9);
    if( fou= (char *) strstr(tmpstr, "lock") )
      lock= atoi(fou+13);
  }
  fgets(tmpstr, 1000, fi);
  token= (char *) strtok(tmpstr, ",");
  while ( token != NULL ){
    if( tmpi= atoi(token) )
      mem[size++]= tmpi-1;
    token= (char *) strtok(NULL, ",");
  }
  mapw= scrw-size+1;
  scrw= size/mapw;
  fgets(tmpstr, 1000, fi);
  while ( !strstr(tmpstr, "/layer") ){
    token= (char *) strtok(tmpstr, ",");
    while ( token != NULL ){
      if( tmpi= atoi(token) )
        mem[size++]= tmpi-1;
      token= (char *) strtok(NULL, ",");
    }
    fgets(tmpstr, 1000, fi);
  }
  maph= scrh-size/mapw/scrw+1;
  scrh= (scrh-maph+1)/maph;
  tmpi= 0;
  for ( i= 0; i<size; i++ )
    if( mem[i]>tmpi )
      tmpi= mem[i];
  fprintf(fo, "// %s\n", argv[2]);
  fprintf(fo, "// Generado por TmxCnv de la churrera\n");
  fprintf(fo, "// Copyleft 2013 The Mojon Twins/Antonio Villena\n\n");
  fprintf(fo, "unsigned char mapa [] = {");
  if( tmpi>15 )
    for ( i= 0; i<maph; i++ ){
      fprintf(fo, "\n");
      for ( j= 0; j<mapw; j++ ){
        fprintf(fo, "    ");
        for ( k= 0; k<scrh; k++ )
          for ( l= 0; l<scrw; l++ ){
            elem= mem[i*mapw*scrh*scrw+j*scrw+k*mapw*scrw+l];
            if( lock==elem )
              numlock++;
            fprintf(fo, "%d, ", elem);
          }
        fprintf(fo, "\n");
      }
    }
  else
    for ( i= 0; i<maph; i++ ){
      fprintf(fo, "\n");
      for ( j= 0; j<mapw; j++ ){
        fprintf(fo, "    ");
        for ( k= 0; k<scrh; k++ )
          for ( l= 0; l<scrw; l++ ){
            elem= mem[i*mapw*scrh*scrw+j*scrw+k*mapw*scrw+l];
            if( lock==elem )
              numlock++;
            if( tog^= 1 )
              sum= elem;
            else
              fprintf(fo, "%d, ", sum<<4 | elem);
          }
        fprintf(fo, "\n");
      }
    }
  fprintf(fo, "};\n\n#define MAX_CERROJOS %d\n\n", numlock);
  fprintf(fo, "typedef struct {\n");
  fprintf(fo, "    unsigned char np, x, y, st;\n");
  fprintf(fo, "} CERROJOS;\n\n");
  if( numlock ){
    fprintf(fo, "CERROJOS cerrojos [MAX_CERROJOS] = {");
    for ( i= 0; i<maph; i++ )
      for ( j= 0; j<mapw; j++ )
        for ( k= 0; k<scrh; k++ )
          for ( l= 0; l<scrw; l++ )
            if( lock==mem[i*mapw*scrh*scrw+j*scrw+k*mapw*scrw+l] ){
              fprintf(fo, "\n    {%d, %d, %d, 0}", i*mapw+j, l, k);
              if( --numlock )
                fprintf(fo, ",");
            }
    fprintf(fo, "\n};\n\n");
  }
  else
    fprintf(fo, "CERROJOS *cerrojos;\n\n");
  fclose(fo);
  if( argc==4 ){
    screlm *enems= (screlm *) calloc (maph*mapw, sizeof(screlm));
    fo= fopen(argv[3], "wb+");
    if( !fo )
      printf("\nCannot create output file: %s\n", argv[3]),
      exit(-1);
    while ( !feof(fi) && !strstr(tmpstr, "/map") ){
      name= 0;
      type= 0;
      fgets(tmpstr, 1000, fi);
      if( fou= (char *) strstr(tmpstr, "object ") ){
        token= (char *) strtok(fou+7, " ");
        while ( token != NULL ){
          if( strstr(token, "name") )
            name= atoi(token+6);
          else if ( strstr(token, "type") )
            type= atoi(token+6);
          else if ( strstr(token, "gid") )
            gid= atoi(token+5);
          else if ( strstr(token, "x") )
            x= atoi(token+3)>>4;
          else if ( strstr(token, "y") )
            y= (atoi(token+3)>>4)-1;
          token= (char *) strtok(NULL, " ");
        }
        mapy= mapx= 0;
        while ( x > scrw )
          mapx++,
          x-= scrw+1;
        while ( y > scrh )
          mapy++,
          y-= scrh+1;
        if( name>500 ){
          for ( k= 0
              ; k<3 && enems[mapy*mapw+mapx].ene[k].type && enems[mapy*mapw+mapx].ene[k].type!=name
              ; k++ );
          if( k==3 )
            printf("\nError: More than 3 enemies in screen (%d, %d).\n", mapx, mapy),
            exit(-1);
          if( enems[mapy*mapw+mapx].ene[k].type )
            enems[mapy*mapw+mapx].ene[k].type= (gid-313)>>2;
          else
            enems[mapy*mapw+mapx].ene[k].type= name;
          if( gid-313&2 )
            enems[mapy*mapw+mapx].ene[k].xe= x,
            enems[mapy*mapw+mapx].ene[k].ye= y+1;
          else{
            enems[mapy*mapw+mapx].ene[k].xi= x;
            enems[mapy*mapw+mapx].ene[k].yi= y+1;
            enems[mapy*mapw+mapx].ene[k].speed= type ? type : 2;
            if( ((gid-313)>>2)-4 )
              baddies++;
          }
        }
        else if( name )
          baddies++,
          enems[mapy*mapw+mapx].ene[k].xi= x,
          enems[mapy*mapw+mapx].ene[k].yi= y+1,
          enems[mapy*mapw+mapx].ene[k].xe= x,
          enems[mapy*mapw+mapx].ene[k].ye= y+1,
          enems[mapy*mapw+mapx].ene[k].speed= type ? type : 2,
          printf("hola%d \n", name);
        else if( type ){
          for ( k= 0 ; k<3 && enems[mapy*mapw+mapx].ene[k].type ; k++ );
          if( k==3 )
            printf("\nError: More than 3 enemies in screen (%d, %d).\n", mapx, mapy),
            exit(-1);
          if( enems[mapy*mapw+mapx].ene[k].yi+enems[mapy*mapw+mapx].ene[k].ye )
            enems[mapy*mapw+mapx].ene[k].type= (gid-313)>>2;
          if( gid-313&2 )
            enems[mapy*mapw+mapx].ene[k].xe= x,
            enems[mapy*mapw+mapx].ene[k].ye= y+1;
          else{
            enems[mapy*mapw+mapx].ene[k].xi= x;
            enems[mapy*mapw+mapx].ene[k].yi= y+1;
            enems[mapy*mapw+mapx].ene[k].speed= type ? type : 2;
            if( ((gid-313)>>2)-4 )
              baddies++;
          }
        }
        else
          enems[mapy*mapw+mapx].xy= y | x<<4,
          enems[mapy*mapw+mapx].type= gid-17;
      }
    }
    fprintf(fo, "#define BADDIES_COUNT %d\r\n\r\ntypedef struct {\r\n\tint x, y;\r\n\tunsigned char "
                "x1, y1, x2, y2;\r\n\tchar mx, my;\r\n\tchar t;\r\n#ifdef PLAYER_CAN_FIRE\r\n\tunsig"
                "ned char life;\r\n#endif\r\n} MALOTE;\r\n\r\nMALOTE malotes [] = {", baddies);
    for ( i= 0; i<maph; i++ )
      for ( j= 0; j<mapw; j++ )
        for ( k= 0; k<3; k++ )
          fprintf(fo, "\r\n\t{%d, %d, %d, %d, %d, %d, %d, %d, %d}%s",
                  enems[i*mapw+j].ene[k].xi<<4, enems[i*mapw+j].ene[k].yi-1<<4,
                  enems[i*mapw+j].ene[k].xi<<4, enems[i*mapw+j].ene[k].yi-1<<4,
                  enems[i*mapw+j].ene[k].xe<<4, enems[i*mapw+j].ene[k].ye-1<<4,
                  sgn(enems[i*mapw+j].ene[k].xe-enems[i*mapw+j].ene[k].xi)*enems[i*mapw+j].ene[k].speed,
                  sgn(enems[i*mapw+j].ene[k].ye-enems[i*mapw+j].ene[k].yi)*enems[i*mapw+j].ene[k].speed,
                  enems[i*mapw+j].ene[k].type,
                  i==maph-1 && j==mapw-1 && k==2 ? "" : ",");

    fprintf(fo, "\r\n};\r\n\r\ntypedef struct {\r\n\tunsigned char xy, tipo, act;\r\n} HOTSPOT;\r\n\r\n"
                "HOTSPOT hotspots [] = {");
    for ( i= 0; i<maph; i++ )
      for ( j= 0; j<mapw; j++ )
        fprintf(fo, "\r\n\t{%d, %d, 0}%s", 
                enems[i*mapw+j].xy,
                enems[i*mapw+j].type,
                i==maph-1 && j==mapw-1 ? "" : ",");
    fprintf(fo, "\r\n};\r\n\r\n");
    fclose(fo);
  }
  fclose(fi);
  printf("\nFile generated successfully\n");
}