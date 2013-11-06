/*
 * (c) Copyright 2013 by Antonio Villena. All rights reserved.
 * The compressor is based on ZX7 from Einar Saukas
 *   http://www.worldofspectrum.org/infoseekid.cgi?id=0027996
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * The name of its author may not be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_OFFSET  142   /* range 1..142 */
#define MAX_LEN    65536  /* range 2..65536 */
#define BITS_SYMBOL   4

unsigned char* output_data;
size_t output_index;
int bit_mask;

typedef struct match_t {
    size_t index;
    struct match_t *next;
} Match;

typedef struct optimal_t {
    size_t bits;
    int offset;
    int len;
} Optimal;

void shellSort ( int *a, int *b, int n ){
  int h, i, j, k, l;
  for ( h= n; h>>= 1; )
    for ( i= h; i < n; i++ ){
      k= a[i];
      l= b[i];
      for ( j= i; j >= h && a[j - h] < k; j-= h )
        a[j]= a[j - h],
        b[j]= b[j - h];
      a[j]= k;
      b[j]= l;
    }
}

int elias_gamma_bits(int value) {
    int bits;

    bits = 1;
    while (value > 1) {
        bits += 2;
        value >>= 1;
    }
    return bits;
}

int count_bits(int offset, int len) {
  if ( offset == 1 )
    return 3 + elias_gamma_bits(len-1);
  else if( offset == 15 )
    return 4 + elias_gamma_bits(len-1);
  else if( offset < 14 )
    return 6 + elias_gamma_bits(len-1);
  else
    return 10 + elias_gamma_bits(len-1);
}

Optimal* optimize(unsigned char *input_data, size_t input_size) {
    size_t *min;
    size_t *max;
    Match *matches;
    Match *match_slots;
    Optimal *optimal;
    Match *match;
    int match_index;
    int offset;
    size_t len;
    size_t best_len;
    size_t bits;
    size_t i;

    /* allocate all data structures at once */
    min = (size_t *)calloc(MAX_OFFSET+1, sizeof(size_t));
    max = (size_t *)calloc(MAX_OFFSET+1, sizeof(size_t));
    matches = (Match *)calloc(256*256, sizeof(Match));
    match_slots = (Match *)calloc(input_size, sizeof(Match));
    optimal = (Optimal *)calloc(input_size, sizeof(Optimal));

    if (!min || !max || !matches || !match_slots || !optimal) {
         fprintf(stderr, "Error: Insufficient memory\n");
         exit(1);
    }

    /* first byte is always literal */
    optimal[0].bits = BITS_SYMBOL;

    /* process remaining bytes */
    for (i = 1; i < input_size; i++) {

        optimal[i].bits = optimal[i-1].bits + 1 + BITS_SYMBOL;
        match_index = input_data[i-1] << 8 | input_data[i];
        best_len = 1;
        for (match = &matches[match_index]; match->next != NULL && best_len < MAX_LEN; match = match->next) {
            offset = i - match->next->index;
            if (offset > MAX_OFFSET) {
                match->next = NULL;
                break;
            }

            for (len = 2; len <= MAX_LEN; len++) {
                if (len > best_len) {
                    best_len = len;
                    bits = optimal[i-len].bits + count_bits(offset, len);
                    if (optimal[i].bits > bits) {
                        optimal[i].bits = bits;
                        optimal[i].offset = offset;
                        optimal[i].len = len;
                    }
                } else if (i+1 == max[offset]+len && max[offset] != 0) {
                    len = i-min[offset];
                    if (len > best_len) {
                        len = best_len;
                    }
                }
                if (i < offset+len || input_data[i-len] != input_data[i-len-offset]) {
                    break;
                }
            }
            min[offset] = i+1-len;
            max[offset] = i;
        }
        match_slots[i].index = i;
        match_slots[i].next = matches[match_index].next;
        matches[match_index].next = &match_slots[i];
    }

    /* save time by releasing the largest block only, the O.S. will clean everything else later */
    free(match_slots);

    return optimal;
}

void write_bit(int value) {
  if( bit_mask == 0 )
    bit_mask= 128,
    output_data[output_index++]= 0;
  if (value > 0)
    output_data[output_index-1] |= bit_mask;
  bit_mask>>= 1;
}

void write_elias_gamma(int value) {
  int bits= 0, rvalue= 0;
  while ( value>1 )
    ++bits,
    rvalue<<= 1,
    rvalue|= value&1,
    value>>= 1;
  while ( bits-- )
    write_bit(0),
    write_bit(rvalue & 1),
    rvalue>>= 1;
  write_bit(1);
}

unsigned char *compress(Optimal *optimal, unsigned char *input_data, size_t input_size, size_t *output_size) {
    size_t input_index;
    size_t input_prev;
    int offset1;
    int mask;
    int i;

    /* calculate and allocate output buffer */
    input_index = input_size-1;
    *output_size = (optimal[input_index].bits+7)/8;
    output_data = (unsigned char *)malloc(*output_size);
    if (!output_data) {
         fprintf(stderr, "Error: Insufficient memory\n");
         exit(1);
    }

    /* un-reverse optimal sequence */
    optimal[input_index].bits = 0;
    while (input_index > 0) {
        input_prev = input_index - (optimal[input_index].len > 0 ? optimal[input_index].len : 1);
        optimal[input_prev].bits = input_index;
        input_index = input_prev;
    }

    output_index = 0;
    bit_mask = 0;

    /* first byte is always literal */
    for ( i= 1<<BITS_SYMBOL-1; i>0; i>>= 1 )
      write_bit(input_data[0]&i);

    /* process remaining bytes */
    while ((input_index = optimal[input_index].bits) > 0) {
        if (optimal[input_index].len == 0) {

            /* literal indicator */
            write_bit(0);

            /* literal value */
            for ( i= 1<<BITS_SYMBOL-1; i>0; i>>= 1 )
              write_bit(input_data[input_index]&i);

        } else {

            /* sequence indicator */
            write_bit(1);

            /* sequence length */
            write_elias_gamma(optimal[input_index].len-1);

            /* sequence offset */
            offset1 = optimal[input_index].offset-1;
            if( offset1 == 0)
              write_bit(0),
              write_bit(0);
            else if( offset1 == 13)
              write_bit(1),
              write_bit(1),
              write_bit(0),
              write_bit(0),
              write_bit(0),
              write_bit(0),
              write_bit(0),
              write_bit(0),
              write_bit(0);
            else if( offset1 == 14)
              write_bit(0),
              write_bit(1),
              write_bit(0);
            else if (offset1 < 13)
              offset1+= 11,
              write_bit(offset1&16),
              write_bit(offset1&8),
              write_bit(offset1&4),
              write_bit(offset1&2),
              write_bit(offset1&1);
            else
              offset1+= 114,
              write_bit(1),
              write_bit(1),
              write_bit(offset1&64),
              write_bit(offset1&32),
              write_bit(offset1&16),
              write_bit(offset1&8),
              write_bit(offset1&4),
              write_bit(offset1&2),
              write_bit(offset1&1);
        }
    }
    return output_data;
}

void calcfreq(Optimal *optimal, unsigned char *input_data, size_t input_size, int *freq) {
    size_t input_index, input_prev;
    int offset1, mask, i;

    /* calculate and allocate output buffer */
    input_index = input_size-1;

    /* un-reverse optimal sequence */
    optimal[input_index].bits = 0;
    while (input_index > 0) {
        input_prev = input_index - (optimal[input_index].len > 0 ? optimal[input_index].len : 1);
        optimal[input_prev].bits = input_index;
        input_index = input_prev;
    }

    while ((input_index = optimal[input_index].bits) > 0)
      if (optimal[input_index].len == 0)
        freq[input_data[input_index]]++;
}

int main(int argc, char* argv[]){
  unsigned char tmpchar, *mem, *out, *input_data, *image, *imagemod;
  size_t output_size;
  int freq[256], order[256], rorder[256], error, width, height, size= 0,
      scrw, scrh, mapw, maph, lock, tmpi, i, j, k, l;
  char *fou, *token, tmpstr[1000];
  FILE *fi, *fo;
  mem= (unsigned char *) malloc (0x10000);
  if( argc==1 )
    printf("\nTmxCompress v0.20, Map compressor by Antonio Villena, 5 Nov 2013\n\n"),
    printf("  TmxCompress <input_tmx> <input_tileset> \n"
           "              <output_tmx> <output_tileset> <output_compressed>\n\n"),
    printf("  <input_tmx>         Origin .TMX file\n"),
    printf("  <input_tileset>     Origin .PNG tileset\n"),
    printf("  <output_tmx>        Modified .TMX file\n"),
    printf("  <output_tileset>    Modified .PNG tileset (reordered)\n"),
    printf("  <output_compressed> Generated binary compressed map\n"),
    printf("compiled bitsymbol: %i\n\n", BITS_SYMBOL),
    exit(0);
  if( argc!=6 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);
  fi= fopen(argv[1], "r");
  if( !fi )
    printf("\nInput file not found: %s\n", argv[1]),
    exit(-1);
  fo= fopen(argv[3], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[3]),
    exit(-1);
  while ( !feof(fi) && !strstr(tmpstr, "data e") ){
    fgets(tmpstr, 1000, fi);
    fputs(tmpstr, fo);
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
  for ( i= 0; i<256; i++ )
    freq[i]= 0,
    order[i]= i;
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
  out= (unsigned char *) malloc (maph*mapw*scrh*scrw);
  for ( i= 0; i<maph; i++ )
    for ( j= 0; j<mapw; j++ )
      for ( k= 0; k<scrh; k++ )
        for ( l= 0; l<scrw; l++ )
          out[tmpi++]= mem[i*mapw*scrh*scrw+j*scrw+k*mapw*scrw+l];
  for ( i= 0; i<size>>1; i++ )
    tmpchar= out[i],
    out[i]= out[size-1-i],
    out[size-1-i]= tmpchar;
  for ( i= 0; i<maph*mapw; i++ )
    input_data= out+i*scrh*scrw,
    calcfreq(optimize(input_data, scrh*scrw), input_data, scrh*scrw, freq);
  for ( i= 255; !freq[--i]; );
  shellSort(freq, order, j= i+1);
  for ( i= 0; i<j; i++ ){
    for ( k= 0; i!=order[k]; k++ );
    rorder[i]= k;
  }
  for ( int i= 0; i<size; i++ ){
    if( !(i%scrw) && i%(mapw*scrw) )
      fprintf(fo, "0,");
    if( i && !(i%(mapw*scrw*scrh)) ){
      for ( int j= 0; j<mapw*scrw+mapw-1; j++ )
        fprintf(fo, "0,");
      fprintf(fo, "\n");
    }
    if( i==size-1 )
      fprintf(fo, "%d\n", rorder[mem[i]]+1);
    else if( (i+1)%(scrw*mapw) )
      fprintf(fo, "%d,", rorder[mem[i]]+1);
    else
      fprintf(fo, "%d,\n", rorder[mem[i]]+1);
  }
  free(mem);
  fprintf(fo, "</data></layer>\n");
  fgets(tmpstr, 1000, fi);
  while ( !feof(fi) )
    fputs(tmpstr, fo),
    fgets(tmpstr, 1000, fi);
  fclose(fi);
  if( error= lodepng_decode32_file(&image, &width, &height, argv[2]) )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  if( width!= 256 )
    printf("Error. The width of tiles.png must be 256");
  imagemod= (unsigned char *) malloc (width*height<<2);
  memcpy(imagemod, image, width*height<<2);
  for ( i= 0; i < j; i++ )
    for ( k= 0; k < 16; k++ )
      l= order[i],
      memcpy( imagemod+(((i&15|i>>4<<8)<<6) | k<<10),
              image+   (((l&15|l>>4<<8)<<6) | k<<10), 64);
  if( error= lodepng_encode32_file(argv[4], imagemod, width, height) )
    printf("Error %u: %s\n", error, lodepng_error_text(error)),
    exit(-1);
  free(image);
  free(imagemod);
  fo= fopen(argv[5], "wb+");
  if( !fo )
    printf("\nCannot create output file: %s\n", argv[3]),
    exit(-1);
  for ( i= maph*mapw-1; i>0; i-- )
    input_data= out+i*scrh*scrw,
    output_data= compress(optimize(input_data, scrh*scrw), input_data, scrh*scrw, &output_size),
    tmpchar= (output_size^0xff)+1,
    fwrite(&tmpchar, 1, 1, fo);
  for ( i= 0; i<maph*mapw; i++ ){
    input_data= out+i*scrh*scrw;
    output_data= compress(optimize(input_data, scrh*scrw), input_data, scrh*scrw, &output_size);
    for ( k= 0; k<output_size>>1; k++ )
      tmpchar= output_data[k],
      output_data[k]= output_data[output_size-1-k],
      output_data[output_size-1-k]= tmpchar;
    fwrite(output_data, 1, output_size, fo);
  }
  for ( i= 0; i<j; i++ )
    printf("%02d=%04d,  %02d   %02d\n", i, freq[i], order[i], rorder[i]);
  printf("\nFile generated successfully\n");
}
