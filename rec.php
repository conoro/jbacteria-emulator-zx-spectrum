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
if( $_POST['enviar'] ){
  require 'connect.php';
  list($name_year, $publisher)= $db->query('SELECT CONCAT(name," ",year), publisher FROM spectrum_games WHERE shortname="'.$_POST['sname'].'"')->fetch_row();
  $db->query('INSERT spectrum_record VALUES("'.$_POST['id'].'","'.
             $_POST['url'].'",'.
             $_POST['frames'].',"'.
             $name_year.'","'.
             $publisher.'",'.
             $_POST['f3'].','.
             $_POST['f4'].',"'.
             $_POST['name'].'","'.
             $_POST['comment'].'")');
  die('Your recorded playgame has been registered in our database');
}
$str= file_get_contents('php://input');
$index= 0;
$snap= $keys= $frames= $param= '';
while ( strlen($snap)<87 )
  $snap.= chr(getval($index, $str));
$len= 87+16387*(ord($snap[34]) ? 8 : 3);
while ( strlen($snap)<$len )
  $snap.= chr(getval($index, $str));
$f3= (getval($index, $str));
$f4= (getval($index, $str));
while( $str[$index]!=chr(0xc3) )
  $param.= $str[$index++];
list($url,)= explode('?', $_SERVER['HTTP_REFERER']);
$urls= substr(strstr($url, 'ndia.net/'), 9);
list($sname,)= explode('.', $param);
$index+= 2;
$num_frames= 0;
while ( $index<strlen($str) )
  if( ~ord($str[$index]) & 0x80 ){
    $keys.= chr(0);
    $val= getval($index, $str);
    $frames.= chr($val);
    $num_frames+= $val;
  }
  elseif( ord($str[$index]) & 0x20 ){
    $val= getval($index, $str);
    $keys.= chr($val>>8);
    $frames.= chr($val&255);
    $num_frames+= $val&255;
  }
  else{
    $frames.= chr(($val= getval($index, $str))&255);
    if( $val!=255 )
      $keys.= chr($val>>8);
    $num_frames+= $val&255;
  }
$num= time();
$num2= 0;
while( file_exists($file= 'recorded/'.
                          ($b64=  substr(
                                    strtr(
                                      base64_encode(
                                        chr($num>>24&255).chr($num>>16&255).chr($num>>8&255).chr($num&255).chr(($num2&15)<<4)
                                      ), '+/', '-_'
                                    ), 0, 6
                                  )
                          ).'.rec.deflate') )
  if( ++$num2&15 == 0 )
    $num++;
$url.= '?'.$b64.'.rec';
file_put_contents($file, gzdeflate($param."\0".strrev($frames.$keys)));
file_put_contents('snaps/'.$b64.'.z80.deflate', gzdeflate($snap));
?><pre style="text-align:center;font-size:20px">The recorded gameplay is located at:
<a href="<?=$url?>"><?=$url?></a>


Also you can <a href="<?=$urls.'?'.$b64.'.z80'?>">play</a> or <a href="snaps/<?=$b64.'.z80'?>">download</a> the final snapshot.

<form method="post" action="rec.php">
Your name or nickname:
<input name="name" maxlength="20" style="font-size:20px;width:300px"/>

Write a comment:
<textarea name="comment" style="width:300px;height:100px;font-size:20px"></textarea>

<input name="enviar" type="submit" style="font-size:20px"/>
<input name="id" type="hidden" value="<?=$b64?>"/>
<input name="sname" type="hidden" value="<?=$sname?>"/>
<input name="frames" type="hidden" value="<?=$num_frames?>"/>
<input name="url" type="hidden" value="<?=$urls?>"/>
<input name="f3" type="hidden" value="<?=$f3?>"/>
<input name="f4" type="hidden" value="<?=$f4?>"/>
</form>
</pre>
<script type="text/javascript">
  document.forms[0].name.focus();
</script>