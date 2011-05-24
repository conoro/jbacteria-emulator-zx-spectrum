<!DOCTYPE HTML><?
?><html><?
?><body/><?
?><script type="text/javascript"><?
?>game=t=u=0;<?
?>function cb(a,f){<?
  ?>if(f[0]=='_')<?
    ?>emul=a;<?
  ?>else <?
    ?>game=a;<?
  ?>if(!t--)<?
    ?>this.eval(emul.substr(<?=0x18018+$y?>));<?
?>}<?
?>function ajax(f){<?
  ?>var xhr=new XMLHttpRequest();<?
  ?>xhr.onreadystatechange=function(){<?
    ?>if(xhr&&xhr.readyState==4)<?
      ?>cb(xhr.responseText,f);<?
  ?>};<?
  ?>xhr.open('GET',f,true);<?
  ?>xhr.overrideMimeType('text/plain;charset=x-user-defined');<?
  ?>xhr.send(null);<?
?>}<?
?>k=location.href.indexOf('?')+1;<?
?>if(k)<?
  ?>t++,<?
  ?>ajax(location.href.substr(k));<?
?>ajax('_<?=$x?>');<?
?></script><?
?></html>