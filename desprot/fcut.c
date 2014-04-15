#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x10000);
  FILE *fi, *fo;
  long start, length, size, length_hi, length_lo;
  if( argc==1 )
    printf("\n"
    "fcut v0.99, a File Hexadecimal Cutter by Antonio Villena, 01 Dec 2012\n\n"
    "  fcut <input_file> <start> <length> <output_file>\n\n"
    "  <input_file>   Origin file to cut\n"
    "  <start>        In hexadecimal, is the start offset of the segment\n"
    "  <length>       In hexadecimal, is the length of the segment\n"
    "  <output_file>  Genetated output file\n\n"
    "All params are mandatory. If <start> is negative, it's assumed a negative offset\n"
    "from the end of the file. If <length> is negative, the result length will be the\n"
    "file size minus that parameter.\n"),
    exit(0);
  if( argc!=5 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[1], "rb");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  fo= fopen(argv[4], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[4]),
    exit(-1);
  fseek(fi, 0, SEEK_END);
  size= ftell(fi);
  rewind(fi);
  start= strtol(argv[2], NULL, 16);
  if( start<0 )
    start+= size;
  length= strtol(argv[3], NULL, 16);
  if( length<0 )
    length+= size;
  if( start+length>size
   || start>size )
    printf("\nOut of input file\n"),
    exit(-1);
  fseek(fi, start, SEEK_SET);
  length_hi= length>>16;
  length_lo= length&0xffff;
  for ( int i= 0; i<length_hi; i++ )
    fread(mem, 1, 0x10000, fi),
    fwrite(mem, 1, 0x10000, fo);
  fread(mem, 1, length_lo, fi);
  fwrite(mem, 1, length_lo, fo);
  fclose(fi);
  fclose(fo);
  printf("\n0x%X bytes written (%d) at offset 0x%X (%d)\n", length, length, start, start);
}