<?
function getval(&$index, &$str){
  if( ~ord($str[$index]) & 0x80 )
    return ord($str[$index++]);
  elseif( ord($str[$index]) & 0x20 )
    return  ord($str[$index])  <<12 & 0xf000
          | ord($str[++$index])<<6  & 0x0f00
          | ord($str[$index++])<<6  & 0x00c0
          | ord($str[$index++])     & 0x003f;
  else
    return  ord($str[$index++])<<6  & 0x00c0
          | ord($str[$index++])     & 0x003f
          | ord($str[$index-2])<<6  & 0x0700;
}
$str= file_get_contents('php://input');
$keys= $frames= $param= '';
$index= 0;
$f3= (getval($index, $str));
$f4= (getval($index, $str));
while( $str[$index]!=chr(0xc3) )
  $param.= $str[$index++];
$url= strstr($param, '?', 1);
$param= strstr($param, '?');
$param= strrpos($param, '#') ? substr($param, 1, -1) : substr($param, 1);
while( $str[$index]==chr(0xc3) && $str[$index+1]==chr(0xbf) )
  $index+= 2;
while ( $index<strlen($str) )
  if( ~ord($str[$index]) & 0x80 ){
    $keys.= chr(0);
    $frames.= chr(getval($index, $str));
  }
  elseif( ord($str[$index]) & 0x20 ){
    $val= getval($index, $str);
    $keys.= chr($val>>8);
    $frames.= chr($val&255);
  }
  else{
    $frames.= chr(($val= getval($index, $str))&255);
    if( $val!=255 )
      $keys.= chr($val>>8);
  }
file_put_contents('caca.txt', $param.strrev($frames.$keys));
?><pre style="text-align:center;font-size:20px">The recorded gameplay is located at:
<a href="<?=$url?>"><?=$url?></a>

Your name or nickname:
<input name="name" maxlength="20" style="font-size:20px;width:300px"/>

Write a comment:
<textarea name="comment" style="width:300px;height:100px;font-size:20px"></textarea>

<input name="enviar" type="submit" style="font-size:20px"/>
</pre>