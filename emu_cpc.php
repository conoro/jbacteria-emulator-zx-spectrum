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
?>pb=[];<?
?>pbf=pbt=frc=game=t=u=0;<?
?>function cb(b,c){<?
  ?>if(c=='m')<?
    ?>emul=b;<?
  ?>else <?
    ?>game=b;<?
  ?>if(c==8)<?
    ?>document.write(game);<?
  ?>else if(!t--)<?
    ?>this.eval(emul.substr(<?=0x30045+$y?>));<?
  ?>else if(c=='c'){<?
    ?>u=b.indexOf('\0');<?
    ?>ci=b.length;<?
    ?>frc=bp=u+1;<?
    ?>while(bp<ci)<?
      ?>pbf+=(ap=b.charCodeAt(--ci)),<?
      ?>ap!=255&&bp++;<?
    ?>while(ci<b.length)<?
      ?>ap=b.charCodeAt(ci++),<?
      ?>pb[pbt++]=ap==255?ap:ap|b.charCodeAt(frc++)<<8;<?
    ?>frc=pb[0]&255;<?
    ?>ajax((b[u-1]=='a'?'snaps/':'games/')+(param=b.substr(0,u)));<?
  ?>}<?
?>}<?
?>function ajax(f,g){<?
  ?>var xhr=new XMLHttpRequest();<?
  ?>if(g<0)<?
    ?>xhr.onreadystatechange=function(){<?
      ?>if(xhr&&xhr.readyState==4)<?
        ?>rt(ie?bin2arr(xhr.responseBody):bin2str(xhr.responseText));<?
      ?>};<?
  ?>else <?
    ?>xhr.onreadystatechange=function(){<?
      ?>if(xhr&&xhr.readyState==4)<?
        ?>cb(ie?bin2arr(xhr.responseBody):bin2str(xhr.responseText),xhr.getResponseHeader('Content-Type').slice(-1));<?
      ?>};<?
  ?>xhr.open('POST',f,true);<?
  ?>if(!ie)<?
    ?>xhr.overrideMimeType('text/plain;charset=x-user-defined');<?
  ?>xhr.send(g);<?
?>}<?
?>function bin2str(a){<?
  ?>return a.replace(/[\s\S]/g,function(t){<?
    ?>return String.fromCharCode(t.charCodeAt(0)&255);<?
  ?>});<?
?>}<?
?>function bin2arr(a){<?
  ?>return arr(a).replace(/[\s\S]/g,function(t){<?
    ?>v= t.charCodeAt(0);<?
    ?>return String.fromCharCode(v&0xff,v>>8);<?
  ?>})+arrl(a);<?
?>}<?
?>k=location.href.indexOf('?')+1;<?
?>ifra=location.href.slice(-1)=='#';<?
?>if(k)<?
  ?>param=location.href.substr(k,location.href.length-k-ifra),<?
  ?>t++,<?
  ?>ajax((param.slice(-1)=='c'<?
    ?>?(t++,'recorded/')<?
    ?>:(param.slice(-1)=='a'?'snaps/':'games/'))+param);<?
?>ajax('_<?=$x?>');<?
?></script><?
?></html>