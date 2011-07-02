<!DOCTYPE HTML><?
?><html><?
?><body/><?
?><script type="text/javascript">ie=0</script><?
?><!--[if IE]><?
?><script type="text/javascript">ie=1;onhelp=function(){return false}</script><?
?><script type="text/vbscript" src="ie.vbscript"></script><?
?><![endif]--><?
?><script type="text/javascript"><?
?>game=t=u=0;<?
?>function cb(b){<?
  ?>emul=b;<?
  ?>this.eval(emul.substr(<?=0x18018+0x4000?>));<?
?>}<?
?>function bin2arr(a) {<?
?>v=[];<?
?>for(i=0;i<256;i++)<?
  ?>for(j=0;j<256;j++)<?
    ?>v[String.fromCharCode(i|j<<8)]=String.fromCharCode(i,j);<?
?>return arr(a).replace(/[\s\S]/g,function(t){return v[t]})+arrl(a);<?
?>}<?
?>xhr=new XMLHttpRequest();<?
?>xhr.onreadystatechange=function(){<?
  ?>if(xhr&&xhr.readyState==4)<?
    ?>cb(ie?bin2arr(xhr.responseBody):xhr.responseText);<?
?>};<?
?>xhr.open('GET','_<?=$x?>',true);<?
?>if(!ie)<?
  ?>xhr.overrideMimeType('text/plain;charset=x-user-defined');<?
?>xhr.send(null);<?
?></script><?
?></html>