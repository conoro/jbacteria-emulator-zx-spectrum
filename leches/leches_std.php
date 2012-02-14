<?
function outbits($val){
  global $inibit, $bytes;
  for($i= 0; $i<$val; $i++)
    $bytes.= $inibit ? '@' : '�';
//    $bytes.= $inibit ? ' �' : '� ';
  $inibit^= 1;
  for($i= 0; $i<$val; $i++)
    $bytes.= $inibit ? '@' : '�';
//    $bytes.= $inibit ? ' �' : '� ';
  $inibit^= 1;
}
function pilot($val){
  global $mhigh;
  while( $val-- )
    outbits( 14 << $mhigh );
}
function block($str, $type){
  $chk= $type;
  for($i= 0; $i<strlen($str); $i++)
    $chk^= ord($str[$i]);
  return chr($type) . $str . chr($chk);
}
$argc==1 && die(
  "\nCargandoLeches Standard WAV generator v0.1 14-02-2012 Antonio Villena, GPLv3 license\n\n".
  "  leches_std file.tap [Sample Rate] [Polarity]\n".
  "  leches_std file.sna [Sample Rate] [Polarity] [Address Patch]\n\n".
  "-Sample Rate: In Khz and rounded (22, 24, 44 or 48). For 22050, 24000, 44100 and 48000Hz\n".
  "-Polarity:    0 or 1. If 1 the WAV signal is inverted. Same results if the signal is balanced\n".
  "-Address Patch: Address used in SNA for storing the register. Must be unused in the game\n\n".
  "Only file is mandatory. Default values are 44 (Sample Rate), 0 (Polarity) and 5780 (Address Patch)\n");
$mlow= $argv[2]==24 || $argv[2]==48 ? 1 : 0;
$mhigh= $argv[2]==22 || $argv[2]==24 ? 0 : 1;
$srate= array(array(22050,24000),array(44100,48000));
$inibit= $argv[3]==1 ? 1 : 0;
$st= array();
for($i= 0; $i<256; $i++){
  for( $j= 0; $j<8; $j++ )
     outbits( ($i<<$j & 0x80 ? 10 : 5 ) << $mhigh );
  $st[$i]= $bytes;
  $bytes= '';
}
file_exists($argv[1]) || die ("\n  Error: File not exists\n");
$nombre= substr($argv[1],0,-4);
$sna= file_get_contents($argv[1]);
$noprint || print("\nGenerating WAV...");
if( strtolower(substr($argv[1],-3))=='tap' ){
  while( $pos<strlen($sna) ){
    $len= ord($sna[$pos++])|ord($sna[$pos++])<<8;
    pilot( 2000 );
    outbits( 4 << $mhigh );
    while( $len-- )
      $bytes.= $st[ord($sna[$pos++])];
  }
}
else{
  strtolower(substr($argv[1],-3))=='sna' || die ("\n  Invalid file: Must be TAP or SNA\n");
  $r= ord($sna[20]);
  $r= (($r&127)-13)&127 | $r&128;
  $parche= isset($argv[4]) ? hexdec($argv[4]) : 0x5780;
  if( strlen($sna)==49179 ){
    $sp= ord($sna[23]) | ord($sna[24])<<8;
    $regs=  chr(0x01).substr($sna, 5, 2).                 // BC'
            chr(0x11).substr($sna, 3, 2).                 // DE'
            chr(0x21).substr($sna, 1, 2).chr(0xd9).       // HL'
            chr(0x21).substr($sna, 7, 2).chr(0xe5).pack('v', 0x8f1). // AF'
            chr(0x3e).ord($sna[26]).chr(0xd3).chr(0xfe).  // Border
            chr(0xed).chr(ord($sna[25])==1?0x56:
                          (ord($sna[25])?0x5e:0x46)).     // IM
            chr(0x01).substr($sna, 13, 2).                // BC
            chr(0x11).substr($sna, 11, 2).                // DE
            pack('v', 0x21dd).substr($sna, 17, 2).        // IX
            pack('v', 0x21fd).substr($sna, 15, 2).        // IY
            chr(0x3e).$sna[0].pack('v', 0x47ed).          // I
            chr(0x3e).chr($r).pack('v', 0x4fed).          // R
            chr(0x21).substr($sna, 21, 2).pack('v', 0xf1e5). // AF
            chr(0x21).substr($sna, 0x8004-0x3fe5, 2).chr(0xe5). // restore stack in HL
            chr(0x21).substr($sna, 0x8002-0x3fe5, 2).chr(0xe5). // restore stack in HL
            chr(0x21).substr($sna, 0x8000-0x3fe5, 2).chr(0xe5). // restore stack in HL
            chr(0x21).substr($sna, 9, 2).                 // HL
            chr(0x31).pack('v', $sp+2).                   // SP
            chr(0xf3|ord($sna[19])<<3).                   // IFF1
            chr(0xc3).substr($sna, $sp-0x3fe5, 2);        // PC
    $sna=   substr($sna, 27, 0x4002).
            pack('vv', 0x05cd, $parche).
            substr($sna, 0x8006-0x3fe5);
    $sna=   block(substr($sna, 0, $parche-0x4000).
                  $regs.
                  substr($sna, $parche+strlen($regs)-0x4000), 255);
    $cab= block("\0".substr(str_pad($nombre,10),0,10).pack('vvv', 20, 0,  20), 0);
    pilot( 2000 );
    outbits( 4 << $mhigh );
    for( $i= 0; $i<19; $i++ )
      $bytes.= $st[ord($cab[$i])];
    $cab= block(chr(0x11).pack('vv', 0xc000, 0xde00).     // LD DE, $C000
                chr(0xc0).chr(0x37).chr(0x0e).chr(0x8f).chr(0x39).chr(0x96).
                chr(0x21).pack('v', 0x4000).              // LD HL, $4000
                chr(0x31).pack('v', 0x8008).              // LD SP, $8008
                chr(0xc3).pack('v', 0x07f4), 255);        // JP $07F4
    pilot( 2000 );
    outbits( 4 << $mhigh );
    for( $i= 0; $i<22; $i++ )
      $bytes.= $st[ord($cab[$i])];
    pilot( 2000 );
    outbits( 4 << $mhigh );
    for( $i= 0; $i<0xc002; $i++ )
      $bytes.= $st[ord($sna[$i])];
  }
  else{
    strlen($sna)==131103 || die ("\n  Invalid length for SNA file: Must be 49179 or 131103\n");
/*    $page[5]= substr($sna, 27, 0x4000);
    $page[2]= substr($sna, 0x401b, 0x4000);
    $last= ord($sna[0xc01d])&7;
    $page[$last]= substr($sna, 0x801b, 0x4000);
    for($i= 0; $i<8; $i++)
      if(($last!=$i)&&($i!=2)&&($i!=5))
        $page[$i]= substr($sna, 0xc01f+$next++*0x4000, 0x4000);
    $regs=  chr(0x21).substr($page[7], 0x3f54, 2).    // restore stack in HL
            chr(0x22).chr(0x54).chr(0xff).            // LD (FF54),HL
            chr(0x21).substr($page[7], 0x3f56, 2).    // restore stack in HL
            chr(0x22).chr(0x56).chr(0xff).            // LD (FF54),HL
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
              pack('v', 0x3ae6);
    $page[7]= pack('v', $parche).
              substr($page[7], 2);
    pilot( 200+700 );
    loadconf( $refconf
            | 0<<9                            // bit snapshot activado
            | 1<<10                           // bit checksum desactivado
            | 0<<11                           // byte flag
            | 0xbf<<19);                      // start high byte
    $page[0]= pack('v', 0x3ae6).$page[0];
    for($j= 0; $j<0x4002; $j++)
      $bytes.= $st[ord($page[0][$j])];
    outbits($termin[$mlow][$velo]>>1);
    outbits($termin[$mlow][$velo]-($termin[$mlow][$velo]>>1));
    outbits_double(1 << $mhigh);
    for($i= 1; $i<8; $i++){
      for($j= 0; $j<0x4000; $j++)
        $bytes.= $st[ord($page[$i][$j])];
      outbits($termin[$mlow][$velo]>>1);
      outbits($termin[$mlow][$velo]-($termin[$mlow][$velo]>>1));
      outbits_double(1 << $mhigh);
    }*/
  }
}
pilot( 300 );
$longi= strlen($bytes);
$noprint || print("Done\n");
$chan= 1;
$output=  'RIFF'.pack('L', $longi+36).'WAVEfmt '.pack('L', 16).pack('v', 1).pack('v', $chan).
          pack('L', $srate[$mhigh][$mlow]).pack('L', $srate[$mhigh][$mlow]*$chan).
          pack('v', $chan).pack('v', 8).'data'.pack('L', $longi).$bytes;
$noprint || file_put_contents($nombre.'.wav', $output);