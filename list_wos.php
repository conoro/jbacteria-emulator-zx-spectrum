<!DOCTYPE HTML><?//4069 juegos
?><html><head><title>jBacteria, the smallest javascript spectrum emulator</title><?
?><style type="text/css"><?
?>*{<?
?>margin:0;<?
?>padding:0;<?
?>}<?
?>body{<?
?>margin:0 8px 8px 8px;<?
?>font-family:Tahoma,Arial<?
?>}<?
?>a{<?
?>text-decoration:none<?
?>}<?
?>a:hover{<?
?>text-decoration:underline<?
?>}<?
?>ol li{<?
?>list-style-type:none<?
?>}<?
?>ol a{<?
?>font-size:30px;<?
?>}<?
?>ul li{<?
?>list-style-type:none;<?
?>font-size:11px;<?
?>color:#888;<?
?>white-space:nowrap;<?
?>width:100%;<?
?>overflow:hidden;<?
?>}<?
?>ul a{<?
?>font-size:16px;<?
?>white-space:nowrap;<?
?>font-weight:bold<?
?>}<?
?></style><?
?><body><ol style="margin-bottom:10px"><?
?><li><a id="l" href="noframes<?=$vra?'s':''?>" style="float:left;font-size:10px" target="_top">NO FRAMES</a><?
?><a id="m" href="noframes<?=$vra?'':'s'?>?" style="float:right;font-size:10px"><?=$vra?'FAST RENDER':'SLOW RENDER'?></a></li><?
?><li style="clear:left"><a id="av" href="main" target="main" onclick="l(this)">Home</a></li><?
?><li><a title="Original 16K" href="16<?=$vra?'':'s'?>" target="main" onclick="l(this)">16K Sinclair</a></li><?
?><li><a title="Original 48K" href="48<?=$vra?'':'s'?>" target="main" onclick="l(this)">48K Sinclair</a></li><?
?><li><a title="Sinclair 128K" href="128<?=$vra?'':'s'?>" target="main" onclick="l(this)">128K Sinclair</a></li><?
?><li><a title="Investronica 128K" href="128i<?=$vra?'':'s'?>" target="main" onclick="l(this)">128K Inves</a></li><?
?><li><a title="Amstrad +2" href="+2<?=$vra?'':'s'?>" target="main" onclick="l(this)">+2 Amstrad</a></li><?
?><li><a title="Amstrad +2A" href="+2A<?=$vra?'':'s'?>" target="main" onclick="l(this)">+2A Amstrad</a></li><?
?><li><a title="Amstrad +3" href="+3<?=$vra?'':'s'?>" target="main" onclick="l(this)">+3 Amstrad</a></li><?
?><li><a title="Microdigital TK 90X" href="tk90<?=$vra?'':'s'?>" target="main" onclick="l(this)">TK 90X</a></li><?
?><li><a title="Modified by Andrew Owen" href="SE<?=$vra?'':'s'?>" target="main" onclick="l(this)">SE Basic</a></li><?
?></ol><ul><?
$mi= explode("\n", file_get_contents('wos.txt'));
$num= count($mi);
$i= 0;
while($num--){
  $nn= trim(substr($mi[$i], 0, 5));
  $year= trim(substr($mi[$i], 6, 4));
  $plat= trim(substr($mi[$i], 11, 6));
  $genre= trim(substr($mi[$i], 18, 7));
  $nombre= trim(substr($mi[$i], 26, 50));
  $pub= trim(substr($mi[$i], 76, 36));
  $snombre= trim(substr($mi[$i], 113, 8));
  $file= trim(substr($mi[$i++], 122));
  $pref=  $plat=='16'
          ? 16
          : ( $plat=='48' 
              ? 48
              : 128 );
  if($snombre){
?><li><a title="<?=$nombre?>" href="<?=$pref.($vra?'':'s').'?'.$snombre?>.tap" target="main" onclick="l(this)"><?=$nombre?></a><?
?><a href="http://www.worldofspectrum.org/infoseekid.cgi?id=00<?=$nn?>" target="_blank"> <img src="wos.png" width="30" height="9"/></a><?
?></li><li><?=$year=='0000'?'':$year?> <?=$pub?></li><?
}}
?></ul></body><?
?><script type="text/javascript"><?
?>/*<![CDATA[*/function l(e){<?
?>last.style.backgroundColor='#FFF';<?
?>e.style.backgroundColor='#0FF';<?
?>last=e;<?
?>}<?
?>last= document.getElementById('av');<?
?>last.style.backgroundColor= '#0FF';<?
?>if(location.href.indexOf('?')<0)<?
?>document.getElementById('m').href=document.getElementById('m').href.slice(0,-1),<?
?>document.getElementById('l').href='/',<?
?>document.getElementById('l').innerHTML= 'I ♡ FRAMES';<?
?>//]]><?
?></script><?
?></html>