<!DOCTYPE HTML><?
?><html xmlns="http://www.w3.org/1999/xhtml"><?
?><head><title><?=$title?></title></head><?
?><body/><?
?><script type="text/javascript"><?
?>/*<![CDATA[*/<?
?>param=game=t=u=0;<?
?>function cb(b,f){<?
  ?>if(f[0]=='_')<?
    ?>emul=b;<?
  ?>else <?
    ?>game=b;<?
  ?>if(!t--)<?
    ?>this.eval(emul.substr(<?=0x18015+$y?>));<?
?>}<?
?>function ajax(f,a){<?
  ?>var xhr=new XMLHttpRequest();<?
  ?>xhr.onreadystatechange=function(){<?
    ?>if(xhr&&xhr.readyState==4)<?
      ?>a(xhr.responseText,f);<?
  ?>};<?
  ?>xhr.open('GET',f,true);<?
  ?>xhr.overrideMimeType('text/plain;charset=x-user-defined');<?
  ?>xhr.send(null);<?
?>}<?
?>k=location.href.indexOf('?')+1;<?
?>if(k)<?
  ?>l=location.href.substr(k).indexOf('/'),<?
  ?>param= decodeURI(location.href.substr(k+l+1)),<?
  ?>t++,<?
  ?>ajax(location.href.substr(k,l),cb);<?
?>ajax('_<?=$x?>',cb);<?
?>//]]><?
?></script><?
?></html>