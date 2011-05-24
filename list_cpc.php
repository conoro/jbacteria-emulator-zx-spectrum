<!DOCTYPE HTML><?//4069 juegos
?><html><head><title>Roland, probably the worst Amstrad CPC emulator</title><?
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
?>a.c:link{<?
?>color:#084<?
?>}<?
?>a.c:visited{<?
?>color:#042<?
?>}<?
?></style><?
?><body><ol style="margin-bottom:10px"><?
?><li><a id="l" href="noframes" style="display:block;text-align:center;font-size:10px;margin-top:0" target="_top">NO FRAMES</a></li><?
?><li><a id="av" href="main" target="main" onclick="l(this)">Home</a></li><?
?><li><a title="Amstrad CPC 464" href="464<?=$vesionra?>" target="main" onclick="l(this)">464 Rom</a></li><?
?><li><a title="Amstrad CPC 664" href="664<?=$vesionra?>" target="main" onclick="l(this)">664 Rom</a></li><?
?><li><a title="Amstrad CPC 6128" href="6128<?=$vesionra?>" target="main" onclick="l(this)">6128 Rom</a></li><?
?></ol><ul><?
$mi= explode("\n", file_get_contents('cpc.txt'));
array_pop($mi);
$arti= array('a'=>'464', 'b'=>'664', 'c'=>'6128');
foreach ($mi as $mifi){
  $tipo= $mifi[0];
  $num= +substr($mifi, 1, 5);
  $nombre= trim(substr($mifi, 7, 46));
  $pub= trim(substr($mifi, 58, 35));
  $year= trim(substr($mifi, 53, 4));
  $snombre= $tipo=='a' ? trim(substr($mifi, 93, 8)).'.tap' : trim(substr($mifi, 93, 8)).'.dsk/'.urlencode(trim(substr($mifi, 102, 13)));
  $pref= $arti[$tipo].$vesionra;
?><li><a title="<?=$nombre?>" href="<?=$pref?>?<?=$snombre?>"<?=$tipo=='a'?' class="c"':''?> target="main" onclick="l(this)"><?=$nombre?></a><?
if($num > 0){?>
<a href="http://www.cpc-power.com/index.php?page=detail&num=<?=$num?>" target="_blank"> <img src="cpcpow.png" width="48" height="7"/></a>
<?}?>
</li><li><?=$year?> <?=$pub?></li><?
}
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
?>document.getElementById('l').href='/',<?
?>document.getElementById('l').innerHTML= 'I ♡ FRAMES';<?
?>//]]><?
?></script><?
?></html>