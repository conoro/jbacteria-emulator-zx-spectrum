<?
require 'tablas.php';
$cont= file_get_contents($_SERVER['argv'][1]);
$skip= $_SERVER['argv'][5]=='skip' ? 0 : 1;
$long= strlen($cont);
$lastbl= $pos= 0;
while($pos<$long){
  $len= ord($cont[$pos])|ord($cont[$pos+1])<<8;
  pilot( $lastbl ? 1000 : 200 );
  loadconf( $velo                           // velocidad
          | $mlow<<3                        // frecuencia muestreo
          | 0x1f<<4                         // 5 bits a 1
          | 1<<9                            // bit snapshot
          | ( $len==6914 ? $skip : 1) << 10 // eludo checksum solo en bloques de pantalla
          | ord($cont[$pos+2])<<11          // byte flag
          | ord($cont[$pos+$len+1])<<19);   // checksum
  for($i= 2; $i<$len; $i++){
    $val= ord($cont[$pos+1+$i]) >> 6;
    outbits($tabla1[$velo][$val]);
    outbits($tabla2[$velo][$val]);
    $val= ord($cont[$pos+1+$i]) >> 4 & 3;
    outbits($tabla1[$velo][$val]);
    outbits($tabla2[$velo][$val]);
    $val= ord($cont[$pos+1+$i]) >> 2 & 3;
    outbits($tabla1[$velo][$val]);
    outbits($tabla2[$velo][$val]);
    $val= ord($cont[$pos+1+$i]) & 3;
    outbits($tabla1[$velo][$val]);
    outbits($tabla2[$velo][$val]);
  }
  outbits($termin[$mlow][$velo]>>1);
  outbits($termin[$mlow][$velo]-($termin[$mlow][$velo]>>1));
  outbits_double(1 << $mhigh);
  $lastbl= ord($cont[$pos+2]);
  $pos+= $len+2;
}
pilot(4);
echo 'Hecho.';
$longi= strlen($bytes);
file_put_contents(substr($_SERVER['argv'][1],0,-4).'.tzx',
                  $tzx.chr($longi&255).chr($longi>>8&255).chr($longi>>16&255).$bytes);