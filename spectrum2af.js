suf= '2a';
ay= 0;
ayr= [];
rom= [[],[],[],[]]; //  rom= [new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384)];

function init() {
  resize();
  p0= p1= sha= ft= st= time= tape= flash= tapep= 0;
  pag= 1;
  z80init();
  a= b= c= d= f= h= l= a_= b_= c_= d_= e_= h_= l_= r= r7= pc= iff= im= halted= t= u= 0;
  e= 17;
  f_= 1;
  xh= 92;
  xl= 226;
  yh= 92;
  yl= 58;
  i= 63;
  sp= 65350;
  put= top==self ? document : parent.document;
  while(t<0x30000)
    eld[t++]= 255;
  for (o= 0; o< 768; o++)
    vm[o]= 255;
  for (o= 0; o< 15; o++)
    ayr[o]= 0;
  for (r= 0; r < 65536; r++)        // fill memory
    rom[r>>14][r&16383]= emul.charCodeAt(0x18018+r) & 255;
  for (j= 0; j < 0x24000; j++)        // fill memory
    ram[j>>14][j&16383]= 1 << (j>>14) & 161 ? emul.charCodeAt(0x18018+r++) & 255 : 0;
  mw[0]= ram[8]; //dummy for rom write
  m[1]= mw[1]= ram[5];
  m[2]= mw[2]= ram[2];
  if(game)                               // emulate LOAD ""
    p1= 4,
    pc= 1388;
  wp(32765, game ? 16 : 0);
  document.ondragover= handleDragOver;
  document.ondrop= handleFileSelect;
  document.onkeydown= kdown;          // key event handling
  document.onkeyup= kup;
  document.onkeypress= kpress;
  document.body.onresize= resize;
  interval= setInterval(run, 20);
  self.focus();
}

function rp(addr) {
  j= 255;
  if (!(addr & 224))                    // read kempston
    j^= kb[8];
  else if (~addr & 1){                   // read keyboard
    for (k= 8; k < 16; k++)
      if (~addr & 1 << k)            // scan row
        j&= kb[k-8];
  }
  else if((addr&49154)==49152)
    j= ayr[ay];
  else{
    t= parseInt(st/224);
    u= st%224;
    if(u<192 && t<124 && !(t&4))
      j= m[t>>1&1 | t>>2 | (t&1 ? 6144 | u<<2&992 : u&6144 | u<<2&224 | u<<8&1792)];
  }
  return j;
}

function wp(addr, val) {                // write port, only border color emulation
  if (~addr & 1)
    document.body.style.backgroundColor= '#'+palb.substr(3*(bor=val&7), 3);
  else if(~addr&0x0002){    // xxxx xxxx xxxx xx0x
    if(addr&0x8000){        // 1xxx xxxx xxxx xx0x
      if(addr&0x4000)       // 11xx xxxx xxxx xx0x
        ay= val&15;
      else                  // 10xx xxxx xxxx xx0x
        val&= 1<<ay&8234 ? 15 : (1<<ay&1792 ? 31 : 255),
        ayr[ay]= val;
    }
    else{                   // 0xxx xxxx xxxx xx0x
      if(addr&0x4000){      // 01xx xxxx xxxx xx0x
        if (pag){
          scree= val&8 ? ram[7] : ram[5];
          if((p0^val) & 8)
            for(t= 0; t<768; t++)
              vm[t]= 255;
          p0= val;
          pag= ~val & 32;
          if(~p1&1)
            mw[0]= ram[8], //dummy for rom write
            m[0]= rom[p0>>4&1|p1>>1&2],
            m[1]= mw[1]= ram[5], //for good reset
            m[2]= mw[2]= ram[2], //
            m[3]= mw[3]= ram[p0&7];
        }
      }
      else{                 // 00xx xxxx xxxx xx0x
        if (pag && addr>>12==1){ // 0001 xxxx xxxx xx0x
          p1= val;
          if(val&1)
            m[0]= mw[0]= ram[val&6?4:0],
            m[1]= mw[1]= ram['1557'[val>>1&3]],
            m[2]= mw[2]= ram[val&6?6:2],
            m[3]= mw[3]= ram[val>>1==1?7:3];
          else
            mw[0]= ram[8],
            m[0]= rom[p0>>4&1|p1>>1&2],
            m[1]= mw[1]= ram[5],
            m[2]= mw[2]= ram[2],
            m[3]= mw[3]= ram[p0&7];
        }
      }
    }
  }
}

function rm(o) {
  if(o.charCodeAt(6)|o.charCodeAt(7) ||
     o.charCodeAt(12)==255 ||
     o.charCodeAt(30)!=55 ||
     o.charCodeAt(34)!=13)
    return 1;
  j= 0;
  a= o.charCodeAt(j++);
  f= o.charCodeAt(j++);
  c= o.charCodeAt(j++);
  b= o.charCodeAt(j++);
  l= o.charCodeAt(j++);
  h= o.charCodeAt(j++);
  j+= 2;
  sp= o.charCodeAt(j++)|o.charCodeAt(j++)<<8;
  i= o.charCodeAt(j++);
  r= o.charCodeAt(j++);
  r7= o.charCodeAt(j++);
  bor= r7>>1&7;
  wp(0, bor);
  e= o.charCodeAt(j++);
  d= o.charCodeAt(j++);
  c_= o.charCodeAt(j++);
  b_= o.charCodeAt(j++);
  e_= o.charCodeAt(j++);
  d_= o.charCodeAt(j++);
  l_= o.charCodeAt(j++);
  h_= o.charCodeAt(j++);
  a_= o.charCodeAt(j++);
  f_= o.charCodeAt(j++);
  yl= o.charCodeAt(j++);
  yh= o.charCodeAt(j++);
  xl= o.charCodeAt(j++);
  xh= o.charCodeAt(j++);
  iff= o.charCodeAt(j++);
  im= o.charCodeAt(j+1)&3;
  j+= 4;
  pc= o.charCodeAt(j++)|o.charCodeAt(j++)<<8;
  j++;
  p0= o.charCodeAt(j++);
  j+= 2;
  ay= o.charCodeAt(j++)&3;
  for (t= 0; t< 16; t++)
    ayr[t]= o.charCodeAt(j++) & (1<<t&8234 ? 15 : (1<<t&1792 ? 31 : 255));
  j+= 31;
  p1= o.charCodeAt(j++);
  while(j<o.length){
    t= o.charCodeAt(j++)|o.charCodeAt(j++)<<8;
    u= o.charCodeAt(j++)-3;
    v= 0;
    if(t==0xffff)
      while(v<0x4000)
        ram[u][v++]= o.charCodeAt(j++);
    else
      while(t--)
        if(o.charCodeAt(j)==0xed && o.charCodeAt(j+1)==0xed){
          t-= 3;
          w= o.charCodeAt(j+2);
          j+= 4;
          while(w--)
            ram[u][v++]= o.charCodeAt(j-1);
        }
        else
          ram[u][v++]= o.charCodeAt(j++);
  }
  r7<<= 7;
  wp(0x7ffd, p0);
  wp(0x1ffd, p1);
  for (o= 0; o< 768; o++)
    vm[o]= 255;
}

function wm() {
  t= String.fromCharCode(a,f,c,b,l,h,0,0,sp&255,sp>>8,i,r,r7>>7|bor<<1,e,d,
                         c_,b_,e_,d_,l_,h_,a_,f_,yl,yh,xl,xh,iff,iff,im,55,0,
                         pc&255,pc>>8,13,p0,0,0,ayr);
  for (u= 0; u< 16; u++)
    t+= String.fromCharCode(ayr[u]);
  t+= String.fromCharCode(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,p1);
  for (u= 0; u< 8; u++)
    for (j= 0, t+= String.fromCharCode(255,255,u+3); j < 0x4000; j++)
      t+= String.fromCharCode(ram[u][j]);
  return t;
}

function handleFileSelect(evt) {
  evt.stopPropagation();
  evt.preventDefault();
  if(evt.dataTransfer.files[0].name.slice(-3).toLowerCase()!='z80')
    return alert('Invalid Z80 file');
  var reader= new FileReader();
  reader.onloadend = function(ev) {
    o= ev.target.result;
    if(rm(o))
      return alert('Invalid Z80 file');
  }
  reader.readAsBinaryString(evt.dataTransfer.files[0]);
}
