<!DOCTYPE HTML><?
?><html xmlns="http://www.w3.org/1999/xhtml"><?
?><body/><?
?><script type="text/javascript"><?
?>/*<![CDATA[*/<?
?>game=t=u=0;<?
?>function cb(b){<?
  ?>emul=b;<?
  ?>this.eval(emul.substr(<?=0x4000+0x30018?>));<?
?>}<?
?>xhr=new XMLHttpRequest();<?
?>xhr.onreadystatechange=function(){<?
  ?>if(xhr&&xhr.readyState==4)<?
    ?>cb(xhr.responseText);<?
?>};<?
?>xhr.open('GET','_SE',true);<?
?>xhr.overrideMimeType('text/plain;charset=x-user-defined');<?
?>xhr.send(null);<?
?>//]]><?
?></script><?
?></html>