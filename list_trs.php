<!DOCTYPE HTML><?
?><html><head><title>jTandy, another javascript TRS-80 emulator</title><?
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
?>height:16px;<?
?>overflow:hidden;<?
?>}<?
?>ul a{<?
?>font-size:16px;<?
?>line-height:14px;<?
?>white-space:nowrap;<?
?>font-weight:bold<?
?>}<?
?>a:link{<?
?>color:#00f<?
?>}<?
?>a:visited{<?
?>color:#008<?
?>}<?
?></style><?
?><body><ol style="margin-bottom:10px"><?
?><li style="text-align:center;width:100%"><a id="l" href="noframes" style="font-size:10px" target="_top">NO FRAMES</a></li><?
?><li style="clear:left"><a id="av" href="main" target="main" onclick="l(this)">Home</a></li><?
?><li><a title="TRS-80 Model III" href="3" target="main" onclick="l(this)">Model III</a></li><?
?></ol><ul><?
$mi= explode("\n", file_get_contents('trs.txt'));
array_pop($mi);
foreach ($mi as $mifi){
  $num= +substr($mifi, 0, 6);
  $year= trim(substr($mifi, 7, 4));
  $nombre= trim(substr($mifi, 12, 60));
  $pub= trim(substr($mifi, 72, 40));
  $snombre= trim(substr($mifi, 116, 8));
  if($snombre){
?><li><a title="<?=$nombre?>" href="3?<?=$snombre?>.cmd" target="main" onclick="l(this)"><?=$nombre?></a><?
?><a href="http://planetemu.net/?section=roms&action=showrom&id=<?=$num?>" target="_blank"> <img src="planet.png" width="16" height="16"/></a><?
?></li><li><?=$year?> <?=$pub?></li><?
}}
?></ul></body><?
?><script type="text/javascript"><?
?>function l(e){<?
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
?></script><?
?></html>