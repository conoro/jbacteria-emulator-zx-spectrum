<!DOCTYPE HTML><?//2150 apps
?><html><head><title>jBacteria, the smallest javascript spectrum emulator</title><?
?><style type="text/css"><?
?>*{<?
?>border:0;<?
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
?>a[name]{<?
?>font-size:30px;<?
?>line-height:30px;<?
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
?><li><a id="l" href="noframes_cat<?=$vra?'s':''?>" style="float:left;font-size:10px" target="_top">NO FRAMES</a><?
?><a id="m" href="noframes_cat<?=$vra?'':'s'?>?" style="float:right;font-size:10px"><?=$vra?'FAST RENDER':'SLOW RENDER'?></a></li><?
?><li style="clear:left"><a id="av" href="main" target="main" onclick="l(this)">Home</a></li><?
?><li><a title="Adventures" href="#Adventures" onclick="l(this)">Adventures</a></li><?
?><li><a title="Educational" href="#Educational" onclick="l(this)">Educational</a></li><?
?><li><a title="Utilities" href="#Utilities" onclick="l(this)">Utilities</a></li><?
?><li><a title="Demos" href="#Demos" onclick="l(this)">Demos</a></li><?
?><li><a title="Adult Games" href="#Adult Games" onclick="l(this)">Adult</a></li><?
?></ol><ul><?
?><li style="height:35px"><a name="Adventures">Adventures</a><a name="" href="#">⇧</a></li><?
$mi= explode("\n", file_get_contents('wos_cat.txt'));
$num= count($mi);
$y= $i= 0;
while($num--){
  $nn= trim(substr($mi[$i], 0, 5));
  $year= trim(substr($mi[$i], 6, 4));
  $plat= trim(substr($mi[$i], 11, 6));
  $genre= trim(substr($mi[$i], 18, 7));
  $nombre= trim(substr($mi[$i], 26, 50));
  $pub= trim(substr($mi[$i], 76, 36));
  $snombre= trim(substr($mi[$i], 113, 8));
  $file= trim(substr($mi[$i++], 122));
  $pref= $plat=='16' ? 16 :
                       ($plat=='48' ? 48 : 128);
  $z= array('Educational','Utilities','Demos','Adult Games');
  if($nn=='-----'){?>
    <li style="height:35px"><a name="<?=$z[$y]?>"><?=$z[$y++]?></a><a name="" href="#">⇧</a></li>
<?}
  elseif($snombre){
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
?>document.getElementById('l').href='rest',<?
?>document.getElementById('l').innerHTML= 'I ♡ FRAMES';<?
?>//]]><?
?></script><?
?></html>