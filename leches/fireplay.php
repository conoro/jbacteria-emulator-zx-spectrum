<?
function outbits($val){
  global $inibit;
  for($i= 0; $i<$val; $i++)
    outbit($inibit);
  $inibit^= 1;
}
function outbit($val){
  global $bytes;
  $bytes.= $val ? '@' : '�';
//  $bytes.= $val ? ' �' : '� ';
}
function pilot($val){
  while( $val-- )
    outbits( 12 );
}
$tabla= array( 1, 2, 3, 4 );
$termin= array( 21, 13 );
$argc==1 && die(
  "\nFireplay WAV generator v0.1 05-03-2012 Antonio Villena, GPLv3 license\n\n".
  "  fireplay file.tap [Sample Rate] [Polarity]\n\n".
  "-Sample Rate: 44 or 48. For 44100 and 48000Hz\n".
  "-Polarity:    0 or 1. If 1 the WAV signal is inverted. Same results if the signal is balanced\n\n".
  "Only file is mandatory. Default values for Sample Rate and Polarity are 44 and 0\n");
file_exists($argv[1]) || die ("\n  Error: File not exists\n");
$mlow= $argv[2]==48 ? 1 : 0;
$srate= array(44100,48000);
$inibit= $argv[3]==1 ? 1 : 0;
$st= array();
$noprint || print("\nGenerating WAV...");
$bytes= '';
for($i= 0; $i<256; $i++){
  $val= $i >> 6;
  outbits(1);
  outbits($tabla[$val]);
  $val= $i >> 4 & 3;
  outbits(1);
  outbits($tabla[$val]);
  $val= $i  >> 2 & 3;
  outbits(1);
  outbits($tabla[$val]);
  $val= $i  & 3;
  outbits(1);
  outbits($tabla[$val]);
  $st[$i]= $bytes;
  $bytes= '';
}
$sna= file_get_contents($argv[1]);
$long= strlen($sna);
$lastbl= $pos= 0;
while($pos<$long){
  $len= ord($sna[$pos])|ord($sna[$pos+1])<<8;
  pilot( $lastbl ? 5000 : 400 );
  $b16= ord($sna[$pos+2])               // byte flag
      | ord($sna[$pos+$len+1])<<8;      // checksum
  outbits( 12 );
  outbits( 28 );
  pilot( 6 );
  outbits(2);
  outbits(11-9*$mlow);
  $c16= 16;
  while( $c16-- ){
    outbits( $b16&0x8000 ? 4 : 8 );
    outbits( ($b16&0x8000 ? 4 : 8) + ($c16==15 ? 1 : 0) );
    $b16<<= 1;
  }
  outbits(2);
  outbits(2);
  for($i= 2; $i<$len; $i++)
    $bytes.= $st[ord($sna[$pos+1+$i])];
  outbits(1);
  outbits($termin[$mlow]-1);
  $lastbl= ord($sna[$pos+2]);
  $pos+= $len+2;
}
pilot( 1000 );
$longi= strlen($bytes);
$noprint || print("Done\n");
$chan= 1;
$output=  'RIFF'.pack('L', $longi+36).'WAVEfmt '.pack('L', 16).pack('v', 1).pack('v', $chan).
          pack('L', $srate[$mlow]).pack('L', $srate[$mlow]*$chan).
          pack('v', $chan).pack('v', 8).'data'.pack('L', $longi).$bytes;
$noprint || file_put_contents(substr($argv[1],0,-4).'.wav', $output);