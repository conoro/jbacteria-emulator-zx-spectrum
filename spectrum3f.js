rom= [[],[],[],[]]; //  rom= [new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384)];

function init() {
  cv.setAttribute('style', 'image-rendering:'+( localStorage.ft & 1
                                                ? 'optimizeSpeed'
                                                : '' ));
  onresize();
  ay= envc= envx= ay13= noic= noir= tons= 0;
  ayr= [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0]; // last 3 values for tone counter
  cts= playp= vbp= bor= p0= p1= sha= f1= st= time= flash= 0;
  if( localStorage.ft==undefined )
    localStorage.ft= 4;
  if ( localStorage.ft & 8 )
    rotapal();
  sample= 0;
  pag= 1;
  z80init();
  fdcinit();
  a= b= c= d= f= h= l= a_= b_= c_= d_= e_= h_= l_= r= r7= pc= iff= im= halted= t= u= 0;
  e=  0x11;
  f_= 0x01;
  xh= 0x5c;
  xl= 0xe2;
  yh= 0x5c;
  yl= 0x3a;
  i=  0x3f;
  sp= 0xff46;
  if( ifra ){
    put= document.createElement('div');
    put.style.width= '40px';
    put.style.textAlign= 'right';
    document.body.appendChild(put);
    titul= function(){
      put.innerHTML= parseInt(trein/((nt= new Date().getTime())-time))+'%';
    }
  }
  else{
    put= top==self ? document : parent.document;
    titul= function(){
      put.title= 'jAmeba3 '+parseInt(trein/((nt= new Date().getTime())-time))+'%';
    }
  }
  while(t<0x30000)
    eld[t++]= 0xff;
  for ( o= 0
      ; o < 15
      ; o++ )
    ayr[o]= 0;
  for ( r= 0
      ; r < 0x10000
      ; r++ )
    rom[r>>14][r&0x3fff]= emul.charCodeAt(0x18018+r) & 0xff;
  for (j= 0; j < 0x24000; j++)        // fill memory
    ram[j>>14][j&16383]= 1 << (j>>14) & 161 ? emul.charCodeAt(0x18018+r++) & 255 : 0;
//  mw[0]= ram[8]; //dummy for rom write
  m[1]= mw[1]= ram[5];
  m[2]= mw[2]= ram[2];
/*  if(game)                               // emulate LOAD ""
    p1= 4,
    pc= 1388;*/
  wp(0x7ffd, game ? 16 : 0);
  document.ondragover= handleDragOver;
  document.ondrop= handleFileSelect;
  document.onkeydown= kdown;          // key event handling
  document.onkeyup= kup;
  document.onkeypress= kpress;
  document.onresize= document.body.onresize= onresize;
  trein= 32000;
  myrun= run;
  if(typeof webkitAudioContext == 'function'){
    cts= new webkitAudioContext();
    if( cts.sampleRate>44000 && cts.sampleRate<50000 )
      trein*= 50*1024/cts.sampleRate,
      paso= 70908/1024,
      node= cts.createJavaScriptNode(1024, 0, 1),
      node.onaudioprocess= audioprocess,
      node.connect(cts.destination);
    else
      interval= setInterval(myrun, 20);
  }
  else{
    if( typeof Audio == 'function'
     && (audioOutput= new Audio())
     && typeof audioOutput.mozSetup == 'function' ){
      try{
        audioOutput.mozSetup(1, 55400);
        myrun= mozrun;
      }
      catch (e){}
      paso= 70908/1108; // 55400/1108= 50  70908/1108= 16*4
      interval= setInterval(myrun, 20);
    }
    else
      interval= setInterval(myrun, 20);
  }
  self.focus();
}

function audioprocess0(e){
  data1= e.outputBuffer.getChannelData(0);
  data2= e.outputBuffer.getChannelData(1);
  j= 0;
  while( j<1024 )
    data1[j++]= data2[j]= 0;
}

function audioprocess(e){
  vbp= play= playp= j= 0;
  run();
  data1= e.outputBuffer.getChannelData(0);
  data2= e.outputBuffer.getChannelData(1);
  if( localStorage.ft & 4 )
    while( j<1024 ){ // 48000/1024= 46.875  70908/1024= 69.24
      aymute();
      aymute();
      aymute();
      data1[j++]= data2[j]= (aystep()+sample)/2;
      play+= paso;
      if( play > vb[playp] && playp<vbp )
        playp++,
        sample^= 1;
    }
  else
    while( j<1024 )
      data1[j++]= data2[j]= 0;
}

function mozrun(){
  vbp= play= playp= j= 0;
  run();
  if( localStorage.ft & 4 ){
    while( j<1108 ){
      aymute();
      aymute();
      aymute();
      data[j++]= (aystep()+sample)/2;
      play+= paso;
      if( play > vb[playp] && playp<vbp )
        playp++,
        sample^= 1;
    }
    audioOutput.mozWriteAudio(data);
  }
}

function rp(addr) {
  j= 0xff;
  if( !(addr & 0xe0) )                   // read kempston
    j^= kb[8];
  else if( ~addr & 1 ){                   // read keyboard
    for ( k= 8
        ; k < 16
        ; k++ )
      if( ~addr & 1<<k )            // scan row
        j&= kb[k-8];
  }
  else if( (addr&0xc002)==0xc000 )
    j= ayr[ay];
  else if( (addr&0xe002)==0x2000 ){
    if( addr&0x1000 )
      j&= fdcdr();
    else
      j&= fdc_msr_read();
//      j&= fdcs;
  }
  return j;
}

function wp(addr, val) {                // write port, only border color emulation
  if( ~addr & 1 ){
    if( (bor^val) & 0x10 )
      vb[vbp++]= st;
    document.body.style.backgroundColor=  'rgb('
                                        + pal[(bor= val)&7].toString()
                                        + ')';
    if( ifra )
      put.style.color= pal[bor&7][0]+pal[bor&7][1]+pal[bor&7][2]<300 ? '#fff' : '#000';
  }
  else if( ~addr&0x0002 )   // xxxx xxxx xxxx xx0x
    if( addr&0x8000 )       // 1xxx xxxx xxxx xx0x
      if( addr&0x4000 )     // 11xx xxxx xxxx xx0x
        ay= val&15;
      else                  // 10xx xxxx xxxx xx0x
        val&= 1<<ay & 0x202a
              ? 15
              : ( 1<<ay & 0x700
                  ? 0x1f
                  : 0xff),
        ayr[ay]= val;       // 0xxx xxxx xxxx xx0x
    else if( pag && addr&0x4000 ){     // 01xx xxxx xxxx xx0x
      scree= val&8 ? ram[7] : ram[5];
      p0= val;
      pag= ~val & 32;
      if( ~p1&1 )
        mw[0]= ram[8], //dummy for rom write
        m[0]= rom[  p0>>4 & 1
                  | p1>>1 & 2 ],
        m[1]= mw[1]= ram[5], //for good reset
        m[2]= mw[2]= ram[2], //
        m[3]= mw[3]= ram[p0&7];
    }
    else if( addr&0x2000 )
      fdcdw(val);
    else if( pag && addr&0x1000 ){
      p1= val;
      if(val&1)
        m[0]= mw[0]= ram[val&6 ? 4 : 0],
        m[1]= mw[1]= ram['1557'[val>>1 & 3]],
        m[2]= mw[2]= ram[val&6 ? 6 : 2],
        m[3]= mw[3]= ram[val>>1==1 ? 7 : 3];
      else
        mw[0]= ram[8],
        m[0]= rom[  p0>>4 & 1
                  | p1>>1 & 2 ],
        m[1]= mw[1]= ram[5],
        m[2]= mw[2]= ram[2],
        m[3]= mw[3]= ram[p0&7];
    }
}

function rm(o) {
  if(o.charCodeAt(6)|o.charCodeAt(7) ||
     o.charCodeAt(12)==255 ||
     o.charCodeAt(30)!=55 ||
     o.charCodeAt(34)!=7)
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
}

function wm() {
  t= String.fromCharCode(a,f,c,b,l,h,0,0,sp&255,sp>>8,i,r,r7>>7|bor<<1,e,d,
                         c_,b_,e_,d_,l_,h_,a_,f_,yl,yh,xl,xh,iff,iff,im,55,0,
                         pc&255,pc>>8,7,p0,0,0,ayr);
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