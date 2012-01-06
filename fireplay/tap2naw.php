<?
require 'tablas.php';
$cont= file_get_contents($_SERVER['argv'][1]);
$velo= isset($_SERVER['argv'][2]) ? $_SERVER['argv'][2] : 3;
$mlow= $_SERVER['argv'][3]==24 || $_SERVER['argv'][3]==48 ? 1 : 0;
$mhigh= $_SERVER['argv'][3]==22 || $_SERVER['argv'][3]==24 ? 0 : 1;
if(!$mhigh)
  $velo= 8;
$states= array(array(159,146),array(79,73)); // 22 24 44 48
$inibit= $_SERVER['argv'][4]==1 ? 1 : 0;
$skip= $_SERVER['argv'][5]=='skip' ? 0 : 1;
$long= strlen($cont);
$tzx= "ZXTape!\32\1\24\25".chr($states[$mhigh][$mlow])."\0\0\0\10";
$byte= 1;
$lastbl= $pos= 0;
while($pos<$long){
  $len= ord($cont[$pos])|ord($cont[$pos+1])<<8;
  pilot( $lastbl ? 1000 : 200 );
  outbits_double(1 << $mhigh);
  $c26= 26;
  $b26= $byvel[$mlow][$velo]            // byte velo
      | 1<<8                            // bit snapshot
      | ( $len==6914 ? $skip : 1) << 9  // eludo checksum solo en bloques de pantalla
      | ord($cont[$pos+2])<<10          // byte flag
      | ord($cont[$pos+$len+1])<<18;    // checksum
  while( $c26-- ){
    outbits_double( ($b26&0x2000000 ? 2 : 4) << $mhigh );
    $b26<<= 1;
  }
  outbits_double(1 << $mhigh);
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