#include <stdio.h>
int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x4000);
  unsigned char *patch= (unsigned char *) malloc (0x4000);
//  unsigned char tmp;
  unsigned short size, len, addr, i;
  FILE *fi, *fp, *fo;
  if( argc==1 )
    printf("\npokemon v0.99, a ZX Rom patch for the poke utility by Antonio Villena, 26 Feb 2013\n\n"),
    printf("  pokemon <input_rom_file> <input_patch_file> <output_file>\n\n"),
    printf("  <input_rom_file>    Origin rom to patch\n"),
    printf("  <input_patch_file>  Patch file\n"),
    printf("  <output_file>       Genetated patched file\n\n"),
    printf("All params are mandatory.\n"),
    exit(0);
  if( argc!=4 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[1], "rb");
  if( !fi )
    printf("\nROM file not found: %s\n", argv[1]),
    exit(-1);
  fp= fopen(argv[2], "rb");
  if( !fp )
    printf("\nPatch file not found: %s\n", argv[2]),
    exit(-1);
  fo= fopen(argv[3], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[3]),
    exit(-1);
  fseek(fi, 0, SEEK_END);
  size= ftell(fi);
  rewind(fi);
  if( size!=0x4000 )
    printf("\nInvalid ROM file size, must be 16384, but is %d\n", size),
    exit(-1);
  fread(mem, 1, 0x4000, fi);
  fclose(fi);
  fread(patch, 1, 0x4000, fp);
  size= ftell(fp);
  rewind(fp);
  while ( ftell(fp)<size ){
    fread(&addr, 2, 1, fp);
    fread(&len, 2, 1, fp);
    if( addr>0x386d && addr<0x3d00 ){
      for ( i= 0; i<len && mem[addr]==0xff; i++ );
      if( i!=len )
        printf("\nCollision detected at %X\n", i+addr),
        exit(-1);
    }
    fread(mem+addr, 1, len, fp);
  }
  fclose(fp);
  fwrite(mem, 1, 0x4000, fo);
  fclose(fo);
  printf("\nFile sucessfully patched\n");
}