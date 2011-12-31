<?php

function block($str, $type){
  $lon= strlen($str)+2;
  $chk= $type;
  for($i= 0; $i<$lon; $i++)
    $chk^= ord($str[$i]);
  return pack('v', $lon) . chr($type) . $str . chr($chk);
}
function data($str){
  return block($str, 255);
}
function head($name, $len){
  return  block("\0" . substr(str_pad($name,10),0,10) . pack('vvv', $len, 0, $len), 0);
}
function write($file, $input, $filename= '', $func= ''){
  exec("sjasmplus $file.asm");
  $in= file_get_contents("$file.bin");
  unlink("$file.bin");
  $sna= file_get_contents("sna/$file.sna");
  if($func)
    $func($sna);
  if(is_string($input))
    $input= array($input);
  if(file_exists("sna/${file}_screen.sna"))
    $parche= file_get_contents("sna/${file}_screen.sna");
  $res= head($filename?$filename:$file, strlen($in)).
        data($in).
        data(substr($parche ? $parche : $sna, 0x4000-0x3fe5, 0x1b00));
  foreach($input as $value)
    $res.= data(substr($sna, hexdec(substr($value,0,4))-0x3fe5, hexdec(substr($value,5))));
  file_put_contents("tap/$file.tap", $res);
}
function write_noscreen($file, $input, $filename= '', $func= ''){
  exec("sjasmplus $file.asm");
  $in= file_get_contents("$file.bin");
  unlink("$file.bin");
  $sna= file_get_contents("sna/$file.sna");
  if($func)
    $func($sna);
  $res= head($filename?$filename:$file, strlen($in)).
        data($in);
  if(is_string($input))
    $input= array($input);
  foreach($input as $value)
    $res.= data(substr($sna, hexdec(substr($value,0,4))-0x3fe5, hexdec(substr($value,5))));
  file_put_contents("tap/$file.tap", $res);
}
function write_compressed($file, $input, $filename= ''){
  exec("sjasmplus ${file}_compressed.asm");
  $in= file_get_contents("$file.bin");
  $sna= file_get_contents("sna/$file.sna");
  if(file_exists("sna/${file}_screen.sna"))
    $parche= file_get_contents("sna/${file}_screen.sna");
  file_put_contents("$file.tmp", substr($parche ? $parche : $sna, 0x4000-0x3fe5, 0x1b00));
  exec("exomizer raw $file.tmp -c -o $file.bin");
  exec("exoopt $file.bin $file.scr");
  file_put_contents("$file.tmp", substr($sna, hexdec(substr($input,0,4))-0x3fe5, hexdec(substr($input,5))));
  exec("exomizer raw $file.tmp -c -o $file.bin");
  exec("exoopt $file.bin $file.out");
  unlink("$file.tmp");
  unlink("$file.bin");
  $blo= file_get_contents("$file.out");
  unlink("$file.out");
  $scr= substr($in,0,21).chr(strlen($blo)&255).chr(strlen($blo)>>8).substr($in,23).file_get_contents("$file.scr");
  unlink("$file.scr");
  $res= head($file, strlen($scr)).
        data($scr).
        data($blo);
  file_put_contents("tap/${file}_compressed.tap", $res);
}
function write128($file, $filename, $ofs, $ne, $pagemask, $func= ''){
  exec("sjasmplus $file.asm");
  $in= file_get_contents("$file.bin");
  unlink("$file.bin");
  $sna= file_get_contents("sna/$file.sna");
  $page[5]= substr($sna, 27, 16384);
  $page[2]= substr($sna, 27+16384, 16384);
  $last= ord(substr($sna, 27+2+16384*3, 1))&7;
  $page[$last]= substr($sna, 27+16384*2, 16384);
  for($i= 0; $i<8; $i++)
    if(($last!=$i)&&($i!=2)&&($i!=5))
      $page[$i]= substr($sna, 27+4+$next++*16384+49152, 16384);
  $port= ($last-1)&7;
  if($func)
    $func($page);
  for($i= 0; $i<$ne; $i++){
    $pos[$i]= ord($in[$ofs+$i*4])+256*ord($in[$ofs+1+$i*4]);
    $len[$i]= ord($in[$ofs+2+$i*4])+256*ord($in[$ofs+3+$i*4]);
  }
  $res= head($filename, strlen($in)).
        data($in);
  for($i= 0; $i<$ne; $i++){
    do{
      $port= (($port&7)+1)&7;
      $pagemask= ($pagemask<<1)+1;
    }while(!($pagemask&256));
    if($pos[$i]<0x8000){
      if($pos[$i]+$len[$i]<0x8000)
        $res.= data(substr($page[5],$pos[$i]-0x4000,$len[$i]));
      elseif($pos[$i]+$len[$i]<0xC000)
        $res.= data(substr($page[5],$pos[$i]-0x4000,0x8000-$pos[$i]).
                     substr($page[2],0,$pos[$i]+$len[$i]-0x8000));
      else
        $res.= data(substr($page[5],$pos[$i]-0x4000,0x8000-$pos[$i]).
                     substr($page[2],0,0x4000).
                     substr($page[$port],0,$pos[$i]+$len[$i]-0xC000));
    }
    elseif($pos[$i]<0xC000){
      if($pos[$i]+$len[$i]<0xC000)
        $res.= data(substr($page[2],$pos[$i]-0x8000,$len[$i]));
      else
        $res.= data(substr($page[2],$pos[$i]-0x8000,0xC000-$pos[$i]).
                     substr($page[$port],0,$pos[$i]+$len[$i]-0xC000));
    }
    else
      $res.= data(substr($page[$port],$pos[$i]-0xC000,$len[$i]));
  }
  file_put_contents("tap/$file.tap", $res);
}

function generate_basic($file, $filename= '', $run= 0){
  exec("sjasmplus $file.asm", $res);
  echo implode("\n", $res);
  $in= file_get_contents("$file.bin");
  unlink("$file.bin");
  file_put_contents("$file.tap", head($filename?$filename:$file, strlen($in)).data($in));
  if( $run )
    exec("$file.tap");
}

function generate_code($file, $start, $filename= '', $run= 0){
  exec("sjasmplus $file.asm", $res);
  echo implode("\n", $res);
  $in= file_get_contents("$file.bin");
  unlink("$file.bin");
  file_put_contents("$file.tap", block("\3". substr(str_pad($filename?$filename:$file,10), 0, 10).
      pack('vvv', strlen($in), $start, 0x8000), 0) . data($in));
  if( $run )
    exec("$file.tap");
}

?>