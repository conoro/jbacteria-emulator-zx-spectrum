#include <termios.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>

int main(int argc, char* argv[]){
  FILE *fi;
  int i, fd;
  unsigned char j, eot= 0x04, buf[132];
  struct termios attr;
  buf[0]++;
  buf[2]--;
  if( argc != 2 )
    printf( "sendx v1.00 by Antonio Villena, 21 Dec 2014\n\n"
            "  sendx <input_file>\n\n"
            "  <input_file>   Bare Metal input binary file\n\n"),
    exit(0);
  fi= fopen(argv[1], "r");
  if( !fi )
    printf("Couldn't open file %s\n", argv[1]),
    exit(1);
  fd= open("/dev/ttyUSB0", O_RDWR | O_NOCTTY | O_NDELAY);
  if( fd == -1 )
    printf("Couldn't open serial device /dev/ttyUSB0\n"),
    exit(1);
  tcgetattr(fd, &attr);
  attr.c_cflag= B2000000 | CS8;
  attr.c_oflag= attr.c_iflag= attr.c_lflag= 0;
  tcsetattr(fd, TCSANOW, &attr);
  i= TIOCM_DTR;
  ioctl(fd, TIOCMSET, &i);
  usleep( 100*1000 );
  i= 0;
  ioctl(fd, TIOCMSET, &i);
  fcntl(fd, F_SETFL, 0);
  usleep( 50*1000 );
  tcflush(fd, TCIOFLUSH);
  read(fd, &j, 1);
  printf("Initializing file transfer...\n");
  while ( fread(buf+3, 1, 128, fi)>0 ){
    buf[1]++;
    buf[2]--;
    for ( buf[131]= 0, i= 3; i < 131; i++ )
      buf[131]+= buf[i];
    if( write(fd, buf, 132) != 132 )
      printf("Error writing to serial port\n"),
      exit(-1);
    read(fd, &j, 1);
    if( j == 6 )  // ACK
      printf("."),
      fflush(stdout);
    else
      printf("Received %d, expected ACK\n", j),
      exit(-1);
  }
  write(fd, &eot, 1);
  read(fd, &j, 1);
  if( j != 6 )  // ACK
    printf("No ACK for EOT message\n"),
    exit(-1);
  printf("\nFile transfer successfully.\n");
  fclose(fi);
  close(fd);
}
