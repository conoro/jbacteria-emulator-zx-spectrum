<?
function outbits($val){
  global $inibit;
  for($i= 0; $i<$val; $i++)
    outbit($inibit);
  $inibit^= 1;
}
function outbits_double($val){
  outbits($val);
  outbits($val);
}
function outbit($val){
  global $bytes, $byte;
  $byte= $byte*2+$val;
  if($byte>255){
    $bytes.= chr($byte & 255);
    $byte= 1;
  }
}
function pilot($val){
  global $muest;
  while( $val-- )
    outbits_double($muest);
}
$tabla1= array( array(1,2,2,3),
                array(1,2,3,4),
                array(2,2,3,3),
                array(2,3,4,5),
                array(2,3,3,4),
                array(2,3,4,5),
                array(3,3,4,4),
                array(3,4,5,6));
$tabla2= array( array(1,1,2,2),
                array(1,2,3,4),
                array(1,2,2,3),
                array(1,2,3,4),
                array(2,2,3,3),
                array(2,3,4,5),
                array(2,3,3,4),
                array(2,3,4,5));
$cont= file_get_contents($_SERVER['argv'][1]);
$velo= $_SERVER['argv'][2] ? $_SERVER['argv'][2] : 3;
$muest= $_SERVER['argv'][3]==48 ? 11 : 12;
$inibit= $_SERVER['argv'][4]==1 ? 1 : 0;
$skip= $_SERVER['argv'][5]=='skip' ? 1 : 0;
$long= strlen($cont);
$tzx= "ZXTape!\32\1\24\25".chr($muest&1?73:79)."\0\0\0\10";
$byte= 1;
$lastbl= $pos= 0;
while($pos<$long){
  $len= ord($cont[$pos])|ord($cont[$pos+1])<<8;
echo $len."\n";
  pilot( $lastbl ? 1000 : 200 );
  outbits_double(3);
  $c21= 21;
  $b21= ( $len==6914 ? $skip : 0 )      // eludo checksum solo en bloques de pantalla
      | $velo<<1                        // velocidad
      | $muest<<4&16                    // muestreo 44 ó 48khz
      | ord($cont[$pos+2])<<5           // byte flag
      | ord($cont[$pos+$len+1])<<13;    // checksum
  while( $c21-- ){
    outbits_double( $b21&0x100000 ? 3 : 5 );
    $b21<<= 1;
  }
  $ini= 2;
  for($i= 2; $i<$len; $i++){
    $val= ord($cont[$pos+1+$i]) >> 6;
    outbits($ini+$tabla1[$velo][$val^3]);
    outbits($tabla2[$velo][$val^3]);
    $val= ord($cont[$pos+1+$i]) >> 4 & 3;
    outbits($tabla1[$velo][$val]);
    outbits($tabla2[$velo][$val]);
    $val= ord($cont[$pos+1+$i]) >> 2 & 3;
    outbits($tabla1[$velo][$val^2]);
    outbits($tabla2[$velo][$val^2]);
    $val= ord($cont[$pos+1+$i]) & 3;
    outbits($tabla1[$velo][$val^1]);
    outbits($tabla2[$velo][$val^1]);
    $ini= 0;
  }
  outbits_double(9);
  $lastbl= ord($cont[$pos+2]);
  $pos+= $len+2;
}
pilot( 200 );
$longi= strlen($bytes);
file_put_contents(substr($_SERVER['argv'][1],0,-4).'.tzx',
                  $tzx.chr($longi&255).chr($longi>>8&255).chr($longi>>16&255).$bytes);
/*
slow 2.5  2 4 6 8
     3    3 5 7 9
     3.5  4 6 8 10
     4    5 7 9 11

raudo  1.75  2 3 4 5
       2.25  3 4 5 6
       2.50  2 4 6 8
       2.75  4 5 6 7

2345 12

21  r1.75
22 sr2.5
31  r2.25
32  s3
41  r2.75
42  s3.5
51   3.25
52  s4

fdff salto1
fdbf escribe
fe04 tabla
febf salto0
feff lee timings

38bf escribe
38ff salto1
3904 tabla
39bf salto0
39ff lee timings

3abf salto0
3aff escribe
3b04 tabla
3bbf lee timings
3bff salto1

1110 11xx registro B
0110 0010 ini
1000 1000 shi
0110 01xx xor
1001 xx00 shi
0111 XXyy xor
11XX yy00 shi
00Xx YYzz xor
XxYY zz00 shi
xXyY ZZww xor

 teclas problematicas
 6 7 9 0
 Z X V Shift
 A S F G

ZxTapTimingInfo   48K        128K
01 HP SAIMAZOOM   123        126
02 D  213         3494400    234124
03 HB saimazooms  123        234
04 D  6914        1234       2142
05 HB saimazoomc  123        321
06 D  34502       Block      Block

*/