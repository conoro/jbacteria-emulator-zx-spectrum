<!DOCTYPE HTML><?
?><html><?
?><head><title><?=$title?></title></head><?
?><body/><?
?><script type="text/javascript">ie=0</script><?
?><!--[if IE]><?
?><script type="text/javascript">ie=1</script><?
?><script type="text/vbscript" src="ie.vbscript"></script><?
?><![endif]--><?
?><script type="text/javascript"><?
?>param=game=t=u=0;<?
?>function cb(a,f){<?
  ?>if(f[0]=='_')<?
    ?>emul=a;<?
  ?>else <?
    ?>game=a;<?
  ?>if(!t--)<?
    ?>this.eval(emul.substr(<?=0x18015+$y?>));<?
?>}<?
?>function ajax(f){<?
  ?>var xhr=new XMLHttpRequest();<?
  ?>xhr.onreadystatechange=function(){<?
    ?>if(xhr&&xhr.readyState==4)<?
      ?>cb(ie<?
         ?>?String.fromCharCode.apply(0,bin2arr(xhr.responseBody).toArray())<?
         ?>:xhr.responseText,f);<?
  ?>};<?
  ?>xhr.open('GET',f,true);<?
  ?>if(!ie)<?
    ?>xhr.overrideMimeType('text/plain;charset=x-user-defined');<?
  ?>xhr.send(null);<?
?>}<?
?>k=location.href.indexOf('?')+1;<?
?>if(k)<?
  ?>l=location.href.substr(k).indexOf('/'),<?
  ?>param= decodeURI(location.href.substr(k+l+1)),<?
  ?>t++,<?
  ?>ajax(location.href.substr(k,l));<?
?>ajax('_<?=$x?>');<?
?></script><?
?></html>