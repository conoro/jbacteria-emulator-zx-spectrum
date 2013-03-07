#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x10000);
  unsigned char tmp;
  FILE *fi, *fo;
  long size, size_hi, size_lo;
  if( argc==1 )
    printf("\nTapeSplit v0.99, a TAP/TZX file extractor by Antonio Villena, 6 Mar 2013\n\n"),
    printf("  TapeSplit [turbo] [hexheaders] <input_file> [<output_file>]\n\n"),
    printf("  turbo          generate turbo blocks instead basic, data and hdata\n"),
    printf("  hexheaders     generate hexadecimal headers instead file headers\n"),
    printf("  <input_file>   Origin file\n"),
    printf("  <output_file>  Genetated output, stdout if ommited\n"),
    exit(0);
  if( argc!=3 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[1], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  fo= fopen(argv[2], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[2]),
    exit(-1);
  fseek(fi, 0, SEEK_END);
  size= ftell(fi);
  size_hi= size>>16;
  size_lo= size&0xffff;
  for ( int i= 0; i<size_hi; i++ ){
    fseek(fi, (-i-1)*0x10000, SEEK_END);
    fread(mem, 1, 0x10000, fi);
    for ( int j= 0; j<0x8000; j++ )
      tmp= mem[j],
      mem[j]= mem[0xffff-j],
      mem[0xffff-j]= tmp;
    fwrite(mem, 1, 0x10000, fo);
  }
  rewind(fi);
  fread(mem, 1, size_lo, fi);
  for ( int j= 0; j<size_lo>>1; j++ )
    tmp= mem[j],
    mem[j]= mem[size_lo-1-j],
    mem[size_lo-1-j]= tmp;
  fwrite(mem, 1, size_lo, fo);
  fclose(fi);
  fclose(fo);
  printf("\n0x%X bytes reversed\n", size);
}