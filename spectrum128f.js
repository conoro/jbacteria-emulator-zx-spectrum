suf= '';
rom= [[],[]]; //  , rom= [new Uint8Array(16384),new Uint8Array(16384)];

function init() {
  cv.setAttribute('style', 'image-rendering:'+( localStorage.ft & 1
                                                ? 'optimizeSpeed'
                                                : '' ));
  onresize();
  ay= envc= envx= ay13= noic= noir= tons= 0;
  ayr= [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0]; // last 3 values for tone counter
  cts= playp= vbp= bor= f1= st= time= flash= lo= 0;
  if( localStorage.ft==undefined )
    localStorage.ft= 4;
 console.log(localStorage.ft);
  sample= 0.5;
  pag= 1;
  z80init();
  a= b= c= d= f= h= l= a_= b_= c_= d_= e_= h_= l_= r= r7= pc= iff= im= halted= t= u= 0;
  e=  0x11;
  f_= 0x01;
  xh= 0x5c;
  xl= 0xe2;
  yh= 0x5c;
  yl= 0x3a;
  i=  0x3f;
  sp= 0xff46;
  try{
    put= top==self ? document : parent.document;
  }
  catch(error){
    put= document;
  }
  while( t < 0x30000 )
    eld[t++]= 0xff;
  for ( r= 0
      ; r < 0x8000
      ; r++ )
    rom[r>>14][r&0x3fff]= emul.charCodeAt(0x18018+r) & 0xff;
  for ( j= 0
      ; j < 0x24000
      ; j++)
    ram[j>>14][j&0x3fff]= 1 << (j>>14) & 0xa1
                          ? emul.charCodeAt(0x18018+r++) & 0xff 
                          : 0;
  mw[0]= ram[8]; //dummy for rom write
  m[1]= mw[1]= ram[5];
  m[2]= mw[2]= ram[2];
  if(game)                               // emulate LOAD ""
    tp(),
    pc= 0x56c;
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
      paso= 70908/2048; // 221600/4432= 50  70908/4432= 16
      audioOutput.mozSetup(1, 221600);
      myrun= mozrun;
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
      data1[j++]= data2[j]= (aystep()+aystep()+aystep()+aystep()+sample*4)/4;
      play+= paso;
      if( play > vb[playp] && playp<vbp )
        playp++,
        sample= -sample;
    }
  else
    while( j<1024 )
      data1[j++]= data2[j]= 0;
}

function mozrun(){
  vbp= play= playp= j= 0;
  run();
  if( localStorage.ft & 4 ){
    while( j<4432 ){
      data[j++]= aystep()+sample;
      play+= paso;
      if( play > vb[playp] && playp<vbp )
        playp++,
        sample= -sample;
    }
    audioOutput.mozWriteAudio(data);
  }
}

function rp(addr) {
  j= 0xff;
  if( !(addr & 0xe0) )                    // read kempston
    j^= kb[8];
  else if( ~addr & 1 ){                   // read keyboard
    for ( k= 8
        ; k < 16
        ; k++ )
      if( ~addr & 1<<k )            // scan row
        j&= kb[k-8];
  }
  else if( (addr&0xc002) == 0xc000 )
    j= ayr[ay];
  else{
    t= parseInt(st/224);
    u= st%224;
    if( u<0xc0
     && t<124
     && !(t&4) )
      j=  m [ t>>1 & 1
            | t>>2
            | ( t&1
                ?   0x1800
                  | u<<2 & 0x3e0
                :   u    & 0x1800
                  | u<<2 & 0xe0
                  | u<<8 & 0x700
              )];
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
  }
  else if( pag && !(addr & 0x8002) ){
    m[3]= mw[3]= ram[val&7];
    scree= val&8
           ? ram[7]
           : ram[5];
    m[0]= rom[val>>4 & 1];
    pag= ~val & 0x20;
    lo= val;
    sha=  lo&8
          ? ( ~lo&7
              ? 0x10000
              : 0x8000 )
          : 0;
  }
  else if( (addr&0x8002) == 0x8000 )
    if( addr&0x4000 )
      ay= val&15;
    else
      ayw(val);
}

function rm(o) {
  j= 0;
  i= o.charCodeAt(j++);
  l_= o.charCodeAt(j++);
  h_= o.charCodeAt(j++);
  e_= o.charCodeAt(j++);
  d_= o.charCodeAt(j++);
  c_= o.charCodeAt(j++);
  b_= o.charCodeAt(j++);
  f_= o.charCodeAt(j++);
  a_= o.charCodeAt(j++);
  l= o.charCodeAt(j++);
  h= o.charCodeAt(j++);
  e= o.charCodeAt(j++);
  d= o.charCodeAt(j++);
  c= o.charCodeAt(j++);
  b= o.charCodeAt(j++);
  yl= o.charCodeAt(j++);
  yh= o.charCodeAt(j++);
  xl= o.charCodeAt(j++);
  xh= o.charCodeAt(j++);
  iff= o.charCodeAt(j++)>>2 & 1;
  r= r7= o.charCodeAt(j++);
  f= o.charCodeAt(j++);
  a= o.charCodeAt(j++);
  sp= o.charCodeAt(j++) | o.charCodeAt(j++)<<8;
  im= o.charCodeAt(j++);
  wp(0, bor=o.charCodeAt(j++)); //bordercolor
  for ( t= 0
      ; t < 0x4000
      ; t++ )
    ram[5][t]= o.charCodeAt(j++);
  for ( t= 0
      ; t < 0x4000
      ; t++ )
    ram[2][t]= o.charCodeAt(j++);
  wp(0x7ffd, lo= o.charCodeAt(49152+27+2));
  for ( t= 0
      ; t < 0x4000
      ; t++ )
    ram[lo&7][t]= o.charCodeAt(j++);
  pc= o.charCodeAt(j++) | o.charCodeAt(j++)<<8;
  j+= 2;
  for ( t= 0
      ; t < 8
      ; t++)
    if( t != 2
     && t != 5
     && t != (lo&7) )
      for ( u= 0
          ; u < 0x4000
          ; u++ )
        ram[t][u]= o.charCodeAt(j++);
}

function wm() {
  t= String.fromCharCode(i, l_, h_, e_, d_, c_, b_, f_, a_, l, h, e, d, c, b, yl, yh,
                         xl, xh, iff<<2, r, f, a, sp&255, sp>>8, im&3,  bor);
  for ( j= 0x4000
      ; j < 0x10000
      ; j++ )
    t+= String.fromCharCode(m[j>>14][j&0x3fff]);
  t+= String.fromCharCode(pc&0xff, pc>>8 & 0xff, lo, 0);
  for ( j= 0
      ; j < 8
      ; j++ )
    if( j != 2
     && j != 5
     && j !=(lo&7) )
      for ( k= 0
          ; k < 0x4000
          ; k++ )
        t+= String.fromCharCode(ram[j][k]);
  return t;
}

function handleFileSelect(evt) {
  evt.stopPropagation();
  evt.preventDefault();
  switch(evt.dataTransfer.files[0].name.slice(-3).toLowerCase()){
    case 'sna':
      if( evt.dataTransfer.files[0].size != 0x2001f )
        return alert('Invalid SNA file');
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        o= ev.target.result;
        rm(o);
      }
      reader.readAsBinaryString(evt.dataTransfer.files[0]);
      break;
/*    case 'z80':
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        o= ev.target.result;
        u= o.charCodeAt(30);
        if( u>23 && o.charCodeAt(34) )
          return alert('Invalid Z80 file');
        j= 0;
        a= o.charCodeAt(j++);
        f= o.charCodeAt(j++);
        c= o.charCodeAt(j++);
        b= o.charCodeAt(j++);
        l= o.charCodeAt(j++);
        h= o.charCodeAt(j++);
        j+= 2;
        sp= o.charCodeAt(j++) | o.charCodeAt(j++)<<8;
        i= o.charCodeAt(j++);
        r= o.charCodeAt(j++);
        r7= o.charCodeAt(j++);
        bor= r7>>1 & 7;
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
        pc= u>23
            ? o.charCodeAt(j+4) | o.charCodeAt(j+5)<<8
            : o.charCodeAt(6) | o.charCodeAt(7)<<8;
        j+= u+4;
        while( j<o.length ){
          t= o.charCodeAt(j++) | o.charCodeAt(j++)<<8;
          u= o.charCodeAt(j++);
          u=  ( u==8
                ? 1
                : u-2
              )
              <<
              14;
          if( t<0xffff )
            while(t--)
              if( o.charCodeAt(j)==0xed && o.charCodeAt(j+1)==0xed ){
                t-= 3;
                w= o.charCodeAt(j+2);
                j+= 4;
                while(w--)
                  m[u++]= o.charCodeAt(j-1);
              }
              else
                m[u++]= o.charCodeAt(j++);
          else
            do m[u++]= o.charCodeAt(j++)
            while( u&0x3fff );
        }
        r7<<= 7;
      }
      reader.readAsBinaryString(evt.dataTransfer.files[0]);
      break;*/
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