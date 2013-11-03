#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x10000);
  unsigned char *out= (unsigned char *) malloc (0x10000);
  int freq[256];
  char tmpstr[1000];
  char *fou, *token;
  FILE *fi, *fo;
  int size= 0, scrw, scrh, mapw, maph, lock, tmpi, i, j, k, l;
  if( argc==1 )
    printf("\nTmxCnv v1.02, TMX to H generator by Antonio Villena, 29 Oct 2013\n\n"),
    printf("  TmxCnv <input_tmx> <output_map_h> [<output_enems_h>]\n\n"),
    printf("  <input_tmx>       Origin .TMX file\n"),
    printf("  <output_map>      Generated .MAP output file\n"),
    printf("  <output_enems_h>  Generated .H enemies output file\n\n"),
    printf("Example: TmxCnv map\\mapa.tmx dev\\mapa.h dev\\enems.h\n"),
    exit(0);
  if( argc!=2 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[1], "r");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
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
  for ( i= 0; i<16; i++ )
    freq[i]= 0;
  while ( !strstr(tmpstr, "/layer") ){
    token= (char *) strtok(tmpstr, ",");
    while ( token != NULL ){
      if( tmpi= atoi(token) )
        freq[mem[size++]= tmpi-1]++;
      token= (char *) strtok(NULL, ",");
    }
    fgets(tmpstr, 1000, fi);
  }
  maph= scrh-size/mapw/scrw+1;
  scrh= (scrh-maph+1)/maph;
  tmpi= 0;
  for ( i= 0; i<maph; i++ )
    for ( j= 0; j<mapw; j++ )
      for ( k= 0; k<scrh; k++ )
        for ( l= 0; l<scrw; l++ )
          out[tmpi++]= mem[i*mapw*scrh*scrw+j*scrw+k*mapw*scrw+l];
  for ( i= 0; i<maph*mapw; i++ )
    sprintf(tmpstr, "mapa%d.bin", i),
    fo= fopen(tmpstr, "wb+"),
    fwrite(out+i*scrh*scrw, 1, scrh*scrw, fo),
    fclose(fo);
  fclose(fi);
  for ( i= 0; i<16; i++ )
    printf("%02d=%04d\n", i, freq[i]);
  printf("\nFile generated successfully\n");
}