<!DOCTYPE HTML><?
?><html><?
?><body/><?
?><script type="text/javascript"><?
?>game=t=u=0;<?
?>function cb(b){<?
  ?>emul=b;<?
  ?>this.eval(emul.substr(<?=0x18018+0x4000?>));<?
?>}<?
?>xhr=new XMLHttpRequest();<?
?>xhr.onreadystatechange=function(){<?
  ?>if(xhr&&xhr.readyState==4)<?
    ?>cb(xhr.responseText);<?
?>};<?
?>xhr.open('GET','_<?=$x?>',true);<?
?>xhr.overrideMimeType('text/plain;charset=x-user-defined');<?
?>xhr.send(null);<?
?></script><?
?></html>