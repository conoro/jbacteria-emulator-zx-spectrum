<?
require 'tablas.php';
$sna= file_get_contents($_SERVER['argv'][1]);
$parche= isset($_SERVER['argv'][5]) ? hexdec($_SERVER['argv'][5]) : 0x5b00;
$pos= 25;
$long= 49152+27;
$r= ord($sna[20]);
$r= (($r&127)-5)&127 | $r&128;
$sp= ord($sna[23]) | ord($sna[24])<<8;
$regs=  substr($sna, 0xbffe-0x3fe5, 4).         // stack padding
        substr($sna, 5, 2).                     // BC'
        substr($sna, 3, 2).                     // DE'
        substr($sna, 1, 2).                     // HL'
        substr($sna, 7, 2).                     // AF'
        substr($sna, 13, 2).                    // BC
        substr($sna, 11, 2).                    // DE
        $sna[0].chr($r).                        // IR
        substr($sna, 17, 2).                    // IX
        substr($sna, 15, 2).                    // IY
        chr(ord($sna[25])>>1                    // IM
          | ord($sna[19])<<7                    // IFF1
          | ord($sna[26])<<1).                  // Border
        substr($sna, 21, 2).                    // AF
        chr(0x21) . substr($sna, 9, 2).         // HL
        chr(0x31) . pack('v', $sp+2).           // SP
        chr(0xc3) . substr($sna, $sp-0x3fe5, 2);// PC
$sna=   substr($sna, 0, 0xbffe-0x3fe5).
        pack('vv', 0x3502, $parche).
        substr($sna, 0xc002-0x3fe5);
$sna=   substr($sna, 0, 25).
        pack('v', 0x3c42).                      // posiciones 3ffe-3fff de la ROM
        substr($sna, 27, $parche-0x4000).
        $regs.
        substr($sna, $parche+strlen($regs)-0x3fe5);
pilot( 200 );
loadconf( $byvel[$mlow][$velo]            // byte velo
        | 0<<8                            // bit snapshot activado
        | 1<<9                            // bit checksum desactivado
        | 0<<10                           // byte flag
        | 0x3f<<18);                      // start high byte
while($pos<$long){
  $val= ord($sna[$pos]) >> 6;
  outbits($tabla1[$velo][$val]);
  outbits($tabla2[$velo][$val]);
  $val= ord($sna[$pos]) >> 4 & 3;
  outbits($tabla1[$velo][$val]);
  outbits($tabla2[$velo][$val]);
  $val= ord($sna[$pos]) >> 2 & 3;
  outbits($tabla1[$velo][$val]);
  outbits($tabla2[$velo][$val]);
  $val= ord($sna[$pos++]) & 3;
  outbits($tabla1[$velo][$val]);
  outbits($tabla2[$velo][$val]);
}
outbits($termin[$mlow][$velo]>>1);
outbits($termin[$mlow][$velo]-($termin[$mlow][$velo]>>1));
outbits_double(1 << $mhigh);
pilot(8);
$longi= strlen($bytes);
echo 'Hecho.';
file_put_contents(substr($_SERVER['argv'][1],0,-4).'.tzx',
                  $tzx.chr($longi&255).chr($longi>>8&255).chr($longi>>16&255).$bytes);