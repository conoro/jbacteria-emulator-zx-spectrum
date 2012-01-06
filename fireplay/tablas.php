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
  global $mhigh;
  while( $val-- )
    outbits_double( 6 << $mhigh );
}
function loadconf($b26){
  global $mhigh;
  outbits_double(1 << $mhigh);
  $c26= 26;
  while( $c26-- ){
    if (($c26==25 || $c26==9) && $mhigh){
      outbits( $b26&0x2000000 ? 4 : 8 );
      outbits( $b26&0x2000000 ? 5 : 9 );
    }
    else
      outbits_double( ($b26&0x2000000 ? 2 : 4) << $mhigh );
    $b26<<= 1;
  }
  outbits(1 << $mhigh);
  outbits((1 << $mhigh)+1);
//  outbits_double(1 << $mhigh);
}
$tabla1= array( array(1,2,2,3), // 0
                array(2,2,3,3), // 1
                array(2,3,3,4), // 2
                array(3,3,4,4), // 3
                array(1,2,3,4), // 4
                array(2,3,4,5), // 5
                array(2,3,4,5), // 6
                array(3,4,5,6), // 7
                array(1,1,2,2));// 8
$tabla2= array( array(1,1,2,2), // 0
                array(1,2,2,3), // 1
                array(2,2,3,3), // 2
                array(2,3,3,4), // 3
                array(1,2,3,4), // 4
                array(1,2,3,4), // 5
                array(2,3,4,5), // 6
                array(2,3,4,5), // 7
                array(1,2,2,3));// 8
$termin= array( array( 21, 22, 23, 24, 23, 24, 25, 26, 13),  // 0 1 2 3 4 5 6 7
                array( 13, 14, 15, 16, 15, 16, 17, 18, 9)); // 0 1 2 3 4 5 6 7
$byvel=  array( array( 0xed, 0xde, 0xd2, 0xc3, 0x00, 0x71, 0x62, 0x53, 0x62),  // 0 1 2 3 4 5 6 7
                array( 0xf1, 0xe5, 0xd6, 0xc7, 0x04, 0x78, 0x69, 0x5d, 0x62)); // 0 1 2 3 4 5 6 7
$velo= isset($_SERVER['argv'][2]) ? $_SERVER['argv'][2] : 3;
$mlow= $_SERVER['argv'][3]==24 || $_SERVER['argv'][3]==48 ? 1 : 0;
$mhigh= $_SERVER['argv'][3]==22 || $_SERVER['argv'][3]==24 ? 0 : 1;
if(!$mhigh)
  $velo= 8;
$states= array(array(159,146),array(79,73)); // 22 24 44 48
$inibit= $_SERVER['argv'][4]==1 ? 1 : 0;
$tzx= "ZXTape!\32\1\24\25".chr($states[$mhigh][$mlow])."\0\0\0\10";
$byte= 1;
?>