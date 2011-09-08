rom= [[],[]]; //  , rom= [new Uint8Array(16384),new Uint8Array(16384)];

function rm(o) {
  j= 17;
  f= o.charCodeAt(j++);
  a= o.charCodeAt(j++);
  c= o.charCodeAt(j++);
  b= o.charCodeAt(j++);
  e= o.charCodeAt(j++);
  d= o.charCodeAt(j++);
  l= o.charCodeAt(j++);
  h= o.charCodeAt(j++);
  r= o.charCodeAt(j++);
  i= o.charCodeAt(j++);
  iff= o.charCodeAt(j++)&1;
  j++;
  xl= o.charCodeAt(j++);
  xh= o.charCodeAt(j++);
  yl= o.charCodeAt(j++);
  yh= o.charCodeAt(j++);
  sp= o.charCodeAt(j++)|o.charCodeAt(j++)<<8;
  pc= o.charCodeAt(j++)|o.charCodeAt(j++)<<8;
  im= o.charCodeAt(j++);
  f_= o.charCodeAt(j++);
  a_= o.charCodeAt(j++);
  c_= o.charCodeAt(j++);
  b_= o.charCodeAt(j++);
  e_= o.charCodeAt(j++);
  d_= o.charCodeAt(j++);
  l_= o.charCodeAt(j++);
  h_= o.charCodeAt(j++);
  ga= o.charCodeAt(j++);

  gc= [o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++)];
  for (t= 0; t < 17; t++)
    pl[t]= pal[gc[t]];
  ap= o.charCodeAt(j++);
  m[0]= ap&4 ? mw[0] : rom[0];
  m[3]= ap&8 ? mw[3] : rom[1];
  gm= ap&3;
  j++;
  ci= o.charCodeAt(j++);
  cr= [o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++)];
  j++;
  ap= o.charCodeAt(j++);
  bp= o.charCodeAt(j++);
  cp= o.charCodeAt(j++);
  /*pm=*/ o.charCodeAt(j++);
  ay= o.charCodeAt(j++);
  ayr= [o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++)];
  j+= 149;
  for (t= 0; t < 65536; t++)
    mw[t>>14][t&16383]= o.charCodeAt(j++);
  onresize();
}

function wm() {
  t= 'MV - SNA'+String.fromCharCode(0,0,0,0,0,0,0,0,2,f,a,c,b,e,d,l,h,r,i,iff,0,xl,xh,yl,yh,
     sp&255,sp>>8,pc&255,pc>>8,im,f_,a_,c_,b_,e_,d_,l_,h_,ga);
  for (j= 0; j < 17; j++)
    t+= String.fromCharCode(gc[j]);
  t+= String.fromCharCode(gm+(m[0]==mw[0]?4:0)+(m[3]==mw[3]?8:0),0,ci);
  for (j= 0; j < 18; j++)
    t+= String.fromCharCode(cr[j]);
  t+= String.fromCharCode(0,ap,bp,cp,io,ay);
  for (j= 0; j < 16; j++)
    t+= String.fromCharCode(ayr[j]);
  t+= String.fromCharCode(64,0, 0,0, 1,1,1,1,1,1);
  for (j= 0; j < 139; j++)
    t+= String.fromCharCode(0);
  for (j= 0; j < 65536; j++)
    t+= String.fromCharCode(mw[j>>14][j&16383]);
  return t;
}

function tp(){
  tapei= tapep= t= j= 0;
  v= '';
  while(u=  game.charCodeAt(t)      & 0xff
          | game.charCodeAt(t+1)<<8 & 0xffff)
    v+= '<option value="'+t+'">#'+ ++j+
        ( game.charCodeAt(t+2) == 0x2c
          ? ' Prog: '+game.substr(t+3,16).replace(/\0/g, '')
          : ' Data: '+u+' bytes'
        )+'</option>',
    t+= 2+u;
  if( ie )
    pt.outerHTML= '<select onchange="tapep=this.value;tapei=this.selectedIndex">'+v+'</select>';
  else
    pt.innerHTML= v;
}

function loadblock() {
  o=  game.charCodeAt(tapep++)    & 0xff
    | game.charCodeAt(tapep++)<<8 & 0xffff;
  tapei++;
  tapep++;
  for ( j= 0
      ; j < o-1
      ; j++ )
    mw[h >> 6][l | h<<8 & 0x3fff]= game.charCodeAt(tapep++) & 0xff,
    g[0x23]();
  iff= 1;
  pc= 0x286d;                           // exit address
  f= 0x45;
  o=  game.charCodeAt(tapep)      & 0xff
    | game.charCodeAt(tapep+1)<<8 & 0xffff;
  if( !o )
    tapei= tapep= 0;
  pt.selectedIndex= tapei;
}

function rp(addr) {
  j= 255;
  if((addr&0x4300)==0x0300){//x0xxxx11 ... crtc data
    if(ci>9)
      j&= cr[ci];
  }
  if (~addr&0x0800){ //xxxx0xxx ... 8255
    if(addr&0x0200){ //xxxx0x1x
      if(~addr&0x0100) //xxxx0x10 ... 8255 port C
        j&= cp;
    }
    else{
      if(addr&0x0100) //xxxx0x01 ... 8255 port B
        j&= io & 0x02 ? 0x7e | vsync : bp;
      else //xxxx0x00 ... 8255 port A
        j&= (ay==14 ? ks[cp&0x0f] : ayr[ay]) & (io & 0x10 ? 0xff : ap);
    }
  }
  return j;
}

function handleFileSelect(evt) {
  evt.stopPropagation();
  evt.preventDefault();
  switch(evt.dataTransfer.files[0].name.slice(-3).toLowerCase()){
    case 'sna':
      if(evt.dataTransfer.files[0].size!=65792)
        return alert('Invalid SNA file');
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        o= ev.target.result;
        rm(o);
      }
      reader.readAsBinaryString(evt.dataTransfer.files[0]);
      break;
    default:
      return alert(evt.dataTransfer.files[0].name+' has an invalid extension');
    case 'tap':
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        game= ev.target.result;
        tp();
      }
      reader.readAsBinaryString(evt.dataTransfer.files[0]);
  }
}
