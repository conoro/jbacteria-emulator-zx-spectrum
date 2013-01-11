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
  ?>if(c==1)<?
    ?>emul=b;<?
  ?>else <?
    ?>game=b;<?
  ?>if(c==3)<?
    ?>document.write(game);<?
  ?>else if(!t--)<?
    ?>this.eval(emul.substr(<?=0x18018+$y?>));<?
  ?>else if(c==2){<?
    ?>k=b.indexOf('\0');<?
    ?>ci=b.length;<?
    ?>frc=bp=k+1;<?
    ?>while(bp<ci)<?
      ?>pbf+=(ap=b.charCodeAt(--ci)),<?
      ?>ap!=255&&bp++;<?
    ?>while(ci<b.length)<?
      ?>ap=b.charCodeAt(ci++),<?
      ?>pb[pbt++]=ap==255?ap:ap|b.charCodeAt(frc++)<<8;<?
    ?>frc=pb[0]&255;<?
    ?>ajax((b[k-1]==0?'snaps/':'games/')+(param=b.substr(0,k)),0);<?
  ?>}<?
?>}<?
?>function ajax(f,g,h){<?
  ?>var xhr=new XMLHttpRequest();<?
  ?>if(g<0)<?
    ?>xhr.onreadystatechange=function(){<?
      ?>if(xhr&&xhr.readyState==4)<?
        ?>rt(ie?bin2arr(xhr.responseBody):bin2str(xhr.responseText));<?
      ?>};<?
  ?>else <?
    ?>xhr.onreadystatechange=function(){<?
      ?>if(xhr&&xhr.readyState==4)<?
        ?>cb(ie?bin2arr(xhr.responseBody):bin2str(xhr.responseText),h);<?
      ?>};<?
  ?>xhr.open(g?'POST':'GET',f,true);<?
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
    ?>v=t.charCodeAt(0);<?
    ?>return String.fromCharCode(v&0xff,v>>8);<?
  ?>})+arrl(a);<?
?>}<?
?>k=location.href.indexOf('?')+1;<?
?>ifra=location.href.slice(-1)=='#';<?
?>if(k){<?
  ?>params=param=location.href.substr(k,location.href.length-k-ifra);<?
  ?>t++;<?
  ?>if(param.slice(-1)=='c')<?
    ?>t++,<?
    ?>ajax('recorded/'+param,0,2);<?
  ?>else <?
    ?>ajax((param.slice(-1)==0?'snaps/':'games/')+param,0);<?
?>}<?
?>ajax('_<?=$x?>.rom',0,1);<?
?></script><?
?></html>