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
$tabla1= array( array(1,2,2,3), // 0
                array(2,2,3,3), // 1
                array(2,3,3,4), // 2
                array(3,3,4,4), // 3
                array(1,2,3,4), // 4
                array(2,3,4,5), // 5
                array(2,3,4,5), // 6
                array(3,4,5,6));// 7
$tabla2= array( array(1,1,2,2), // 0
                array(1,2,2,3), // 1
                array(2,2,3,3), // 2
                array(2,3,3,4), // 3
                array(1,2,3,4), // 4
                array(1,2,3,4), // 5
                array(2,3,4,5), // 6
                array(2,3,4,5));// 7
$termin= array( array( 21, 22, 23, 24, 23, 24, 25, 26),  // 0 1 2 3 4 5 6 7
                array( 13, 14, 15, 16, 15, 16, 17, 18)); // 0 1 2 3 4 5 6 7
$byvel=  array( array( 0xed, 0xde, 0xd2, 0xc3, 0x00, 0x71, 0x62, 0x53),  // 0 1 2 3 4 5 6 7
                array( 0xf1, 0xe5, 0xd6, 0xc7, 0x04, 0x78, 0x69, 0x5d)); // 0 1 2 3 4 5 6 7
?>