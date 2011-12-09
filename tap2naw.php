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
$tabla= array(array(2,3,4,5),
              array(2,4,6,8),
              array(3,4,5,6),
              array(3,5,7,9),
              array(4,5,6,7),
              array(4,6,8,10),
              array(5,6,7,8),
              array(5,7,9,11));
$cont= file_get_contents($_SERVER['argv'][1]);
$velo= $_SERVER['argv'][2] ? $_SERVER['argv'][2] : 3;
$muest= $_SERVER['argv'][3]==48 ? 11 : 12;
$inibit= $_SERVER['argv'][4]==1 ? 1 : 0;
$long= strlen($cont);
$tzx= "ZXTape!\32\1\24\25".chr($muest&1?79:73)."\0\0\0\10";
$byte= 1;
$lastbl= $pos= 0;
while($pos<$long){
  $len= ord($cont[$pos])|ord($cont[$pos+1])<<8;
echo $len."\n";
  pilot( $lastbl ? 1000 : 100 );
  outbits_double(3);
  $c20= 20;
  $b20= $velo | $muest<<3&8 | ord($cont[$pos+2])<<4 | ord($cont[$pos+$len+1])<<12;
  while( $c20-- ){
    outbits_double( $b20&0x80000 ? 3 : 5 );
    $b20<<= 1;
  }
  for($i= 2; $i<$len; $i++){
    $val= ord($cont[$pos+1+$i]) >> 6;
    outbits_double($tabla[$velo][$val]);
    $val= ord($cont[$pos+1+$i]) >> 4 & 3;
    outbits_double($tabla[$velo][$val]);
    $val= ord($cont[$pos+1+$i]) >> 6 & 3;
    outbits_double($tabla[$velo][$val]);
    $val= ord($cont[$pos+1+$i]) & 3;
    outbits_double($tabla[$velo][$val]);
  }
  $lastbl= ord($cont[$pos+2]);
  $pos+= $len+2;
}
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
*/