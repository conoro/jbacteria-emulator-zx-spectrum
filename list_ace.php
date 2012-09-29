<!DOCTYPE HTML><?
?><html><head><title>jupiler, the unique javascript Jupiter Ace emulator</title><?
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
?>white-space:nowrap;<?
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
?><li><a id="l" href="noframes<?=$vra?'s':''?>" style="float:left;font-size:10px" target="_top">NO FRAMES</a><?
?><a id="m" href="noframes<?=$vra?'':'s'?>?" style="float:right;font-size:10px"><?=$vra?'FAST RENDER':'SLOW RENDER'?></a></li><?
?><li style="clear:left"><a id="av" href="main" target="main" onclick="l(this)">Home</a></li><?
?><li><a title="Original Jupiter Ace machine RAM expanded (51K)" href="JA<?=$vra?'':'s'?>" target="main" onclick="l(this)">Jupiter Ace</a></li><?
?><li><a title="Jupiter Ace with 16K ROM (BasColAce) and 51K RAM" href="ace" target="main" onclick="l(this)">BasColAce</a></li><?
?><li><a title="Jupiter Ace games" href="#Games" onclick="l(this)">JA games</a></li><?
?><li><a title="Jupiter Ace magazines (listings)" href="#Magazines" onclick="l(this)">JA magazines</a></li><?
?><li><a title="ZX Spectrum Basic games for BasColAce" href="#Bascolace" onclick="l(this)">BasColAce games</a></li><?
?></ol><ul><?
?><li style="height:35px"><a name="" href="#">⇧</a><a name="Games">JA games</a></li><?
$mi= explode("\n", file_get_contents('\emu\jupace\ace_games.txt'));
$num= count($mi);
$fileout= '';
$i= 0;
while($num--){
  $url= trim(substr($mi[$i], 0, 32));
  $name= trim(substr($mi[$i], 32, 32));
  $pub= trim(substr($mi[$i], 64, 22));
  $year= trim(substr($mi[$i], 86, 10));
  $sname= trim(substr($mi[$i], 96, 18));
  $command= trim(substr($mi[$i++], 114));
 $fileout.= 'insert ace_games VALUES ("'.$sname.'","'.$name.'","'.$year.'","'.$pub.'");'."\n";
  if($sname){
?><li><a title="<?=$name?>" href="JA<?=($vra?'':'s').'?'.$sname?>.rec" target="main" onclick="l(this)"><?=$name?></a><?
?><a href="http://jupiter-ace.co.uk/<?=$url?>.html" target="_blank"> <img src="ace.png" width="30" height="9"/></a><?
?></li><li><?=$year?> <?=$pub?></li><?
}}
?><li style="height:35px"><a name="" href="#">⇧</a><a name="Magazines">JA magazines</a></li><?
$mi= explode("\n", file_get_contents('\emu\jupace\ace_magazines.txt'));
$num= count($mi);
$i= 0;
while($num--){
  $url= trim(substr($mi[$i], 0, 36));
  $name= trim(substr($mi[$i], 36, 26));
  $pub= trim(substr($mi[$i], 62, 26));
  $year= trim(substr($mi[$i], 88, 12));
  $sname= trim(substr($mi[$i], 100, 18));
  $command= trim(substr($mi[$i++], 118));
 $fileout.= 'insert ace_games VALUES ("'.$sname.'","'.$name.'","'.$year.'","'.$pub.'");'."\n";
  if($sname){
?><li><a title="<?=$name?>" href="JA<?=($vra?'':'s').'?'.$sname?>.tap" target="main" onclick="l(this)"><?=$name?></a><?
?><a href="http://jupiter-ace.co.uk/<?=$url?>.html" target="_blank"> <img src="ace.png" width="30" height="9"/></a><?
?></li><li><?=$year?> <?=$pub?></li><?
}}
?><li style="height:35px"><a name="" href="#">⇧</a><a name="Bascolace">BasColAce games</a></li><?
$mi= explode("\n", file_get_contents('\emu\jupace\ace_bascolace.txt'));
$num= count($mi);
$i= 0;
while($num--){
  $url= trim(substr($mi[$i], 0, 32));
  $name= trim(substr($mi[$i], 32, 32));
  $pub= trim(substr($mi[$i], 64, 22));
  $year= trim(substr($mi[$i], 86, 10));
  $sname= trim(substr($mi[$i], 96, 18));
  $command= trim(substr($mi[$i++], 114));
 $fileout.= 'insert ace_games VALUES ("'.$sname.'","'.$name.'","'.$year.'","'.$pub.'");'."\n";
  if($sname){
?><li><a title="<?=$name?>" href="ace?<?=$sname?>.tap" target="main" onclick="l(this)"><?=$name?></a><?
?><a href="http://jupiter-ace.co.uk/<?=$url?>.html" target="_blank"> <img src="ace.png" width="30" height="9"/></a><?
?></li><li><?=$year?> <?=$pub?></li><?
}}
file_put_contents('sql.txt', $fileout);
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