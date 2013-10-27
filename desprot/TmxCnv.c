#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x10000);
  char tmpstr[1000];
  char *fou;
  char *token;
  FILE *fi, *fo;
  int size= 0, scrw, scrh, mapw, maph, lock, numlock= 0, tmpi, elem, sum, tog= 0, i, j, k, l;
  if( argc==1 )
    printf("\nTmxCnv v0.99, TMX to H generator by Antonio Villena, 24 Oct 2013\n\n"),
    printf("  TmxCnv <input_file> <output_file>\n\n"),
    printf("  <input_file>   Origin .TMX file\n"),
    printf("  <output_file>  Generated .H output file\n\n"),
    printf("Example: TmxCnv map\\mapa.tmx dev\\mapa.h\n"),
    exit(0);
  if( argc!=3 )
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
  while( !feof(fi) && !strstr(tmpstr, "data e") ){
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
  while( token != NULL ){
    if( tmpi= atoi(token) )
      mem[size++]= tmpi-1;
    token= (char *) strtok(NULL, ",");
  }
  mapw= scrw-size+1;
  scrw= size/mapw;
  fgets(tmpstr, 1000, fi);
  while( !feof(fi) && !strstr(tmpstr, "map") ){
    token= (char *) strtok(tmpstr, ",");
    while( token != NULL ){
      if( tmpi= atoi(token) )
        mem[size++]= tmpi-1;
      token= (char *) strtok(NULL, ",");
    }
    fgets(tmpstr, 1000, fi);
  }
  fclose(fi);
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
  printf("\nFile generated successfully\n");
}