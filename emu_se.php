<!DOCTYPE HTML><?
?><html><?
?><body/><?
?><script type="text/javascript">ie=0</script><?
?><!--[if IE]><?
?><script type="text/javascript">ie=1</script><?
?><script type="text/vbscript" src="ie.vbscript"></script><?
?><![endif]--><?
?><script type="text/javascript"><?
?>game=t=u=0;<?
?>function cb(b){<?
  ?>emul=b;<?
  ?>this.eval(emul.substr(<?=0x18018+0x4000?>));<?
?>}<?
?>xhr=new XMLHttpRequest();<?
?>xhr.onreadystatechange=function(){<?
  ?>if(xhr&&xhr.readyState==4)<?
    ?>cb(ie<?
       ?>?String.fromCharCode.apply(0,bin2arr(xhr.responseBody).toArray())<?
       ?>:xhr.responseText);<?
?>};<?
?>xhr.open('GET','_<?=$x?>',true);<?
?>if(!ie)<?
  ?>xhr.overrideMimeType('text/plain;charset=x-user-defined');<?
?>xhr.send(null);<?
?></script><?
?></html>