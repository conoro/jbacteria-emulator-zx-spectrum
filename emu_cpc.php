<!DOCTYPE HTML><?
?><html><?
?><head><title><?=$title?></title></head><?
?><body/><?
?><script type="text/javascript">ie=0</script><?
?><!--[if IE]><?
?><script type="text/javascript">ie=1;onhelp=function(){return false}</script><?
?><script type="text/vbscript" src="ie.vbscript"></script><?
?><![endif]--><?
?><script type="text/javascript"><?
?>game=t=u=0;<?
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
      ?>cb(ie?bin2arr(xhr.responseBody):xhr.responseText,f);<?
  ?>};<?
  ?>xhr.open('GET',f,true);<?
  ?>if(!ie)<?
    ?>xhr.overrideMimeType('text/plain;charset=x-user-defined');<?
  ?>xhr.send(null);<?
?>}<?
?>function bin2arr(a){<?
?>return arr(a).replace(/[\s\S]/g,function(t){<?
  ?>v=t.charCodeAt(0);<?
  ?>return String.fromCharCode(v&0xff,v>>8)<?
?>})+arrl(a);<?
?>}<?
?>k=location.href.indexOf('?')+1;<?
?>ifra=location.href.slice(-1)=='#';<?
?>if(k)<?
  ?>t++,<?
  ?>ajax(location.href.slice(k,-ifra));<?
?>ajax('_<?=$x?>');<?
?></script><?
?></html>