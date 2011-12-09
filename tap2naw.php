<?
function outbit($val){
  global $bytes;
  $byte= $byte*2+$val;
  if($byte>255){
    $bytes.= chr($byte & 255);
    $byte= 1;
  }
}
$cont= file_get_contents($_SERVER['argv'][1]);
$velo= $_SERVER['argv'][1];
$long= strlen($cont);
$tzx= "ZXTape!\032\1\024\25\117\0\0\0";
$byte= 1;
$lastbl= $pos= 0;
while($pos<$long){
  $len= ord($cont[$pos])|ord($cont[$pos+1])<<8;
  pilot( $lastbl ? 1000 : 100 );
  $lastbl= ord($cont[$pos+2]);
}

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