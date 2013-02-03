sector= 0;
sectorpos= 0;
compos= 0;
com= [];

function sdin(){
  if( sdact==0xf6 ){
    switch( com[0] ){
      case 0x51:
        if( !sector )
          return 0xff;
        else if( sectorpos>-1 && sectorpos<512)
          return sector.charCodeAt(sectorpos++);
        else if( sectorpos++>0 ){
          if ( sectorpos<515 )
            return 0;
          else{
            sector= 0;
            return 0xff;
          }
        }
        else
          return sectorpos?0:0xfe;
      case 0x52:
        if( !sector )
          return 0xff;
        else if( sectorpos>-1 && sectorpos<512)
          return sector.charCodeAt(sectorpos++);
        else if( sectorpos++>0 ){
          if ( sectorpos<515 )
            return 0;
          else{
            ++com[1];
            if (++com[1]==256)
              if (++com[2]==256)
                if (++com[3]==256)
                   ++com[4];
            sectorpos= -1;
            sdajax('sd.php', com);
            sector= 0;
            return 0xff;
          }
        }
        else
          return sectorpos?0:0xfe;
      case 0x4c:
        return 0;
    }
  }
  return 0;
}

function sdout( val ){
//  console.log('compos', compos, val);
  com[compos++]= val;
  if( compos==6 ){
    compos= 0;
    switch( com[0] ){
      case 0x51:
      case 0x52:
        sector= 0;
        sectorpos= -2;
  console.log('sd', (com[4]|com[3]<<8|com[2]<<16|com[1]<<24).toString(16));
        sdajax('sd.php', com);
        break;
      case 0x4c:
        sector= 0;
    }
  }
}

function sdselect( val ){
  sdact= val;
}

function sdajax( f, g ){
  var xhr=new XMLHttpRequest();
  xhr.onreadystatechange=function(){
    if(xhr&&xhr.readyState==4)
      sdcallback(bin2str(xhr.responseText));
  }
  xhr.open('POST',f,true);
  xhr.overrideMimeType('text/plain;charset=x-user-defined');
  xhr.send(g);
}

function sdcallback( f ){
  sector= f;
}
