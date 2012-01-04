<?
require 'tablas.php';
$sna= file_get_contents($_SERVER['argv'][1]);
$page[5]= substr($sna, 27, 0x4000);
$page[2]= substr($sna, 0x401b, 0x4000);
$last= ord($sna[0xc01d])&7;
$page[$last]= substr($sna, 0x801b, 0x4000);
for($i= 0; $i<8; $i++)
  if(($last!=$i)&&($i!=2)&&($i!=5))
    $page[$i]= substr($sna, 0xc01f+$next++*0x4000, 0x4000);
$velo= isset($_SERVER['argv'][2]) ? $_SERVER['argv'][2] : 3;
$muest= $_SERVER['argv'][3]==48 ? 13 : 12;
$inibit= $_SERVER['argv'][4]==1 ? 1 : 0;
$parche= isset($_SERVER['argv'][5]) ? hexdec($_SERVER['argv'][5]) : 0x5b00;
$tzx= "ZXTape!\32\1\24\25".chr($muest&1?73:79)."\0\0\0\10";
$byte= 1;
$r= ord($sna[20]);
$r= (($r&127)-5)&127 | $r&128;
$regs=  substr($page[2], 0x3ffe).                 // stack padding
        substr($page[7], 0, 2).                   // stack padding
        chr(ord($sna[0xc01d])|0x10).              // last byte 7FFD
        substr($sna, 5, 2).                       // BC'
        substr($sna, 3, 2).                       // DE'
        substr($sna, 1, 2).                       // HL'
        substr($sna, 7, 2).                       // AF'
        substr($sna, 13, 2).                      // BC
        substr($sna, 11, 2).                      // DE
        $sna[0].chr($r).                          // IR
        substr($sna, 17, 2).                      // IX
        substr($sna, 15, 2).                      // IY
        chr(ord($sna[25])>>1                      // IM
          | ord($sna[19])<<7                      // IFF1
          | ord($sna[26])<<1).                    // Border
        substr($sna, 21, 2).                      // AF
        chr(0x21) . substr($sna, 9, 2).           // HL
        chr(0x31) . substr($sna, 23, 2).          // SP
        ( ord($sna[0xc01d])&0x10
            ? ''
            : chr(0x01) . chr(0xfd) . chr(0x7f).  // LD BC,7FFD
              chr(0x3e) . $sna[0xc01d].           // LD A,last byte 7FFD
              chr(0xed) . chr(0x79).              // OUT (C),A
              chr(0x01) . substr($sna, 13, 2).    // restore BC
              chr(0x3e) . $sna[0xc01d]).          // restore A
        chr(0xc3) . substr($sna, 0xc01b, 2);      // PC
if($parche<0x8000)
  $page[5]= substr($page[5], 0, $parche-0x4000).
            $regs.
            substr($page[5], $parche+strlen($regs)-0x4000);
else
  $page[2]= substr($page[2], 0, $parche-0x8000).
            $regs.
            substr($page[2], $parche+strlen($regs)-0x8000);
$page[2]= substr($page[2], 0, 0x3ffe).
          pack('v', 0x04aa);
$page[7]= pack('v', $parche).
          substr($page[7], 2);
pilot( 200 );
outbits_double(3);
$c26= 26;
$b26= $byvel[$muest&1][$velo]         // byte velo
    | 0<<8                            // bit snapshot activado
    | 1<<9                            // bit checksum desactivado
    | 0<<10                           // byte flag
    | 0xbf<<18;                       // start high byte
while( $c26-- ){
  outbits_double( $b26&0x2000000 ? 3 : 6 );
  $b26<<= 1;
}
$page[0]= pack('v', 0x04aa).$page[0];
outbits_double(2);
for($j= 0; $j<0x4002; $j++){
  $val= ord($page[0][$j]) >> 6;
  outbits($tabla1[$velo][$val]);
  outbits($tabla2[$velo][$val]);
  $val= ord($page[0][$j]) >> 4 & 3;
  outbits($tabla1[$velo][$val]);
  outbits($tabla2[$velo][$val]);
  $val= ord($page[0][$j]) >> 2 & 3;
  outbits($tabla1[$velo][$val]);
  outbits($tabla2[$velo][$val]);
  $val= ord($page[0][$j]) & 3;
  outbits($tabla1[$velo][$val]);
  outbits($tabla2[$velo][$val]);
}
outbits($termin[$muest&1][$velo]>>1);
outbits($termin[$muest&1][$velo]-($termin[$muest&1][$velo]>>1));
outbits_double(2);
for($i= 1; $i<8; $i++){
  for($j= 0; $j<0x4000; $j++){
    $val= ord($page[$i][$j]) >> 6;
    outbits($tabla1[$velo][$val]);
    outbits($tabla2[$velo][$val]);
    $val= ord($page[$i][$j]) >> 4 & 3;
    outbits($tabla1[$velo][$val]);
    outbits($tabla2[$velo][$val]);
    $val= ord($page[$i][$j]) >> 2 & 3;
    outbits($tabla1[$velo][$val]);
    outbits($tabla2[$velo][$val]);
    $val= ord($page[$i][$j]) & 3;
    outbits($tabla1[$velo][$val]);
    outbits($tabla2[$velo][$val]);
    $ini= 0;
  }
  outbits($termin[$muest&1][$velo]>>1);
  outbits($termin[$muest&1][$velo]-($termin[$muest&1][$velo]>>1));
  outbits_double(2);
}
$longi= strlen($bytes);
echo 'Hecho.';
file_put_contents(substr($_SERVER['argv'][1],0,-4).'.tzx',
                  $tzx.chr($longi&255).chr($longi>>8&255).chr($longi>>16&255).$bytes);