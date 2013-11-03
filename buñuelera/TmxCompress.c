#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_OFFSET  142   /* range 1..144 */
#define MAX_LEN    65536  /* range 2..65536 */

typedef struct match_t {
    size_t index;
    struct match_t *next;
} Match;

typedef struct optimal_t {
    size_t bits;
    int offset;
    int len;
} Optimal;

Optimal *optimize(unsigned char *input_data, size_t input_size);

unsigned char *compress(Optimal *optimal, unsigned char *input_data, size_t input_size, size_t *output_size);

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
    optimal[0].bits = 4;

    /* process remaining bytes */
    for (i = 1; i < input_size; i++) {

        optimal[i].bits = optimal[i-1].bits + 5;
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

unsigned char* output_data;
size_t output_index;
size_t bit_index;
int bit_mask;

void write_byte(int value) {
    output_data[output_index++] = value;
}

void write_bit(int value) {
    if (bit_mask == 0) {
        bit_mask = 128;
        bit_index = output_index;
        write_byte(0);
    }
    if (value > 0) {
        output_data[bit_index] |= bit_mask;
    }
    bit_mask >>= 1;
}

void write_elias_gamma(int value) {
    int i;

    for (i = 2; i <= value; i <<= 1) {
        write_bit(0);
    }
    while ((i >>= 1) > 0) {
        write_bit(value & i);
    }
}

unsigned char *compress(Optimal *optimal, unsigned char *input_data, size_t input_size, size_t *output_size) {
    size_t input_index;
    size_t input_prev;
    int offset1;
    int mask;
    int i;

    /* calculate and allocate output buffer */
    input_index = input_size-1;
    *output_size = (optimal[input_index].bits+18+7)/8;
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
    write_byte(input_data[0]);

    /* process remaining bytes */
    while ((input_index = optimal[input_index].bits) > 0) {
        if (optimal[input_index].len == 0) {

            /* literal indicator */
            write_bit(0);

            /* literal value */
//            write_byte(input_data[input_index]);  // antes de churrera
//            freq[input_data[input_index]]++;
            write_bit(input_data[input_index]&8);
            write_bit(input_data[input_index]&4);
            write_bit(input_data[input_index]&2);
            write_bit(input_data[input_index]&1);

        } else {

            /* sequence indicator */
            write_bit(1);

            /* sequence length */
            write_elias_gamma(optimal[input_index].len-1);

            /* sequence offset */
            offset1 = optimal[input_index].offset-1;
//            if (offset1 < 128) { // antes de churrera
            if( offset1 == 0)
              write_bit(0),
              write_bit(0);
            else if( offset1 == 14)
              write_bit(0),
              write_bit(0),
              write_bit(0);
            else if (offset1 < 13) {
//              write_byte(offset1); // antes de churrera
              write_bit(offset1&16);
              write_bit(offset1&8);
              write_bit(offset1&4);
              write_bit(offset1&2);
              write_bit(offset1&1);
            } else {
//                offset1 -= 128; // antes de churrera
                offset1 -= 13;
                write_bit(offset1&256);
                write_bit(offset1&128);
                write_bit(offset1&64);
                write_bit(offset1&32);
                write_bit(offset1&16);
                write_bit(offset1&8);
                write_bit(offset1&4);
                write_bit(offset1&2);
                write_bit(offset1&1);
/*                write_byte((offset1 & 127) | 128);  // antes de churrera
                for (mask = 1024; mask > 127; mask >>= 1) {
                    write_bit(offset1 & mask);
                }*/
            }
        }
    }

    /* sequence indicator */
    write_bit(1);

    /* end marker > MAX_LEN */
    for (i = 0; i < 16; i++) {
        write_bit(0);
    }
    write_bit(1);

    return output_data;
}


calcfreq(Optimal *optimal, unsigned char *input_data, size_t input_size, int *freq) {
    size_t input_index;
    size_t input_prev;
    int offset1;
    int mask;
    int i;

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

/*int main(int argc, char *argv[]) {
    FILE *ifp;
    FILE *ofp;
    unsigned char *input_data;
    unsigned char *output_data;
    size_t input_size;
    size_t output_size;
    size_t partial_counter;
    size_t total_counter;
    char *output_name;

    if (argc == 2) {
        output_name = (char *)malloc(strlen(argv[1])+5);
        strcpy(output_name, argv[1]);
        strcat(output_name, ".zx7");
    } else if (argc == 3) {
        output_name = argv[2];
    } else {
         fprintf(stderr, "Usage: %s input [output.zx7]\n", argv[0]);
         exit(1);
    }

    ifp = fopen(argv[1], "rb");
    if (!ifp) {
         fprintf(stderr, "Error: Cannot access input file %s\n", argv[1]);
         exit(1);
    }

    fseek(ifp, 0L, SEEK_END);
    input_size = ftell(ifp);
    fseek(ifp, 0L, SEEK_SET);
    if (!input_size) {
         fprintf(stderr, "Error: Empty input file %s\n", argv[1]);
         exit(1);
    }

    input_data = (unsigned char *)malloc(input_size);
    if (!input_data) {
         fprintf(stderr, "Error: Insufficient memory\n");
         exit(1);
    }

    total_counter = 0;
    do {
        partial_counter = fread(input_data+total_counter, sizeof(char), input_size-total_counter, ifp);
        total_counter += partial_counter;
    } while (partial_counter > 0);

    if (total_counter != input_size) {
         fprintf(stderr, "Error: Cannot read input file %s\n", argv[1]);
         exit(1);
    }

    fclose(ifp);

    if (fopen(output_name, "rb") != NULL) {
         fprintf(stderr, "Error: Already existing output file %s\n", output_name);
         exit(1);
    }

    ofp = fopen(output_name, "wb");
    if (!ofp) {
         fprintf(stderr, "Error: Cannot create output file %s\n", output_name);
         exit(1);
    }

    output_data = compress(optimize(input_data, input_size), input_data, input_size, &output_size);

    if (fwrite(output_data, sizeof(char), output_size, ofp) != output_size) {
         fprintf(stderr, "Error: Cannot write output file %s\n", output_name);
         exit(1);
    }

    fclose(ofp);

    printf("Optimal LZ77/LZSS compression by Einar Saukas\nFile converted from %lu to %lu bytes!\n",
        (unsigned long)input_size, (unsigned long)output_size);

    return 0;
}*/


int main(int argc, char* argv[]){
  unsigned char *mem= (unsigned char *) malloc (0x10000);
  unsigned char *out= (unsigned char *) malloc (0x10000);
  unsigned char *input_data;
  size_t input_size;
  int freq[256];
  char tmpstr[1000];
  char *fou, *token;
  FILE *fi, *fo;
  int size= 0, scrw, scrh, mapw, maph, lock, tmpi, i, j, k, l;
  if( argc==1 )
    printf("\nTmxCompress v0.10, Map compressor by Antonio Villena, 3 Nov 2013\n\n"),
    printf("  TmxCompress <input_tmx> <input_tileset> <output_compressed> <output_tsbin>\n"
           "              [<output_tmx>] [<output_tileset>]\n\n"),
    printf("  <input_tmx>         Origin .TMX file\n"),
    printf("  <input_tileset>     Origin .PNG tileset\n"),
    printf("  <output_compressed> Generated binary compressed map\n"),
    printf("  <output_tsbin>      Generated binary tileset\n"),
    printf("  <output_tmx>        Modified .TMX file\n"),
    printf("  <output_tileset>    Modified .PNG tileset (reordered)\n\n"),
    exit(0);
/*  if( argc!=2 )
    printf("\nInvalid number of parameters\n"),
    exit(-1);*/
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
        mem[size++]= tmpi-1;
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
  for ( i= 0; i<maph*mapw; i++ ){
    input_data= out+i*scrh*scrw;
    input_size= scrh*scrw;
    calcfreq(optimize(input_data, input_size), input_data, input_size, freq);
  }
  fclose(fi);
  for ( i= 0; i<16; i++ )
    printf("%02d=%04d\n", i, freq[i]);
  printf("\nFile generated successfully\n");
}