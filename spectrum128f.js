rom= [bytes(16384), bytes(16384)];

function init() {
  paintScreen= paintNormal;
  cv.setAttribute('style', 'image-rendering:'+( localStorage.ft & 1
                                                ? 'optimizeSpeed'
                                                : '' ));
  onresize();
  scrl= ula= sample= pbcs= frcs= pbc= cts= playp= vbp= bor= f1= f3= f4= st= time= flash= lo= ay= envc= envx= ay13= noic= tons= 0;
  ayr= [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0]; // last 3 values for tone counter
  if( localStorage.ft==undefined )
    localStorage.ft= 4;
  if ( localStorage.ft & 8 )
    rotapal();
  noir= pag= 1;
  a= b= c= d= h= l= fa= fb= fr= ff= r7=
  a_=b_=c_=d_=h_=l_=fa_=fb_=fr_=e_= r= pc= iff= im= halted= t= u= 0;
  e=  0x11;
  ff_= 0x100;
  xh= 0x5c;
  xl= 0xe2;
  yh= 0x5c;
  yl= 0x3a;
  i=  0x3f;
  sp= 0xff46;
  pbf= ' / '+('0'+parseInt(pbf/3000)).slice(-2)+':'+('0'+parseInt(pbf/50)%60).slice(-2);
  if( ifra ){
    put= document.createElement('div');
    put.style.width= '40px';
    put.style.textAlign= 'right';
    document.body.appendChild(put);
    titul= function(){
      put.innerHTML= parseInt(trein/((nt= new Date().getTime())-time))+'%';
      if( pbt )
        tim.innerHTML= ('0'+parseInt(flash/3000)).slice(-2)+':'+('0'+parseInt(flash/50)%60).slice(-2)+pbf;
    }
  }
  else{
    put= top==self ? document : parent.document;
    titul= function(){
      put.title= 'jAmeba '+parseInt(trein/((nt= new Date().getTime())-time))+'%';
      if( pbt )
        tim.innerHTML= ('0'+parseInt(flash/3000)).slice(-2)+':'+('0'+parseInt(flash/50)%60).slice(-2)+pbf;
    }
  }
  if( pbt )
    tim= document.createElement('div'),
    tim.style.position= 'absolute',
    tim.style.top= '0',
    tim.style.width= '100px',
    tim.style.textAlign= 'right',
    document.body.appendChild(tim);
  while( t < 0x30000 )
    eld[t++]= 0xff;
  for ( r= 0
      ; r < 0x8000
      ; r++ )
    rom[r>>14][r&0x3fff]= emul.charCodeAt(301*250+24+r) & 0xff;
  if( game )
    for ( j= 0
        ; j < 0x24000
        ; j++)
      ram[j>>14][j&0x3fff]= 1 << (j>>14) & 0xa1
                            ? emul.charCodeAt(301*250+24+r++) & 0xff 
                            : 0;
  mw[0]= ram[8];
  m[1]= mw[1]= ram[5];
  m[2]= mw[2]= ram[2];
  game && (pc= 0x56c, tp());
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
      node= cts.createJavaScriptNode(1024, 1, 1),
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
      catch (er){}
      paso= 70908/1108; // 55400/1108= 50  70908/1108= 16*4
      interval= setInterval(myrun, 20);
    }
    else
      interval= setInterval(myrun, 20);
  }
  self.focus();
}

function audioprocess0(e){
  data= e.outputBuffer.getChannelData(0);
  j= 0;
  while( j<1024 )
    data[j++]= 0;
}

function audioprocess(e){
  vbp= play= playp= 0;
  run();
  data= e.outputBuffer.getChannelData(0);
  j= 0;
  if( localStorage.ft & 4 )
    while( j<1024 ){ // 48000/1024= 46.875  70908/1024= 69.24
      aymute();
      aymute();
      aymute();
      data[j++]= (aystep()+sample)/2;
      play+= paso;
      if( play > vb[playp] && playp<vbp )
        playp++,
        sample^= 1;
    }
  else
    while( j<1024 )
      data[j++]= 0;
}

function mozrun(){
  vbp= play= playp= 0;
  run();
  if( localStorage.ft & 4 ){
    j= 0;
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
  if( !(addr & 0xe0) )                    // read kempston
    j^= ks[8];
  else if( ~addr & 1 ){                   // read keyboard
    j= 0xbf;
    for ( k= 8
        ; k < 16
        ; k++ )
      if( ~addr & 1<<k )            // scan row
        j&= ks[k-8];
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
    bor-val && (document.body.style.backgroundColor=  'rgb('
                                                    + ( paintScreen==paintNormal
                                                          ? pal[(bor= val)&7]
                                                          : ulap[8|(bor= val)&7] )
                                                    + ')');
    if( ifra )
      put.style.color= pal[bor&7][0]+pal[bor&7][1]+pal[bor&7][2]<300 ? '#fff' : '#000';
    if( pbt )
      tim.style.color= pal[bor&7][0]+pal[bor&7][1]+pal[bor&7][2]<300 ? '#fff' : '#000';
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
  else if( addr == 0x7f3b )
    doScrl(val);
  else if( addr == 0xbf3b )
    ula= val;
  else if( addr == 0xff3b ){
    if( ula==0x40 )
      paintScreen= val&1 ? paintUlap : paintNormal;
    else if( ula<0x40 )
      doUlap(val);
  }
}

function rm(o) {
  if(o.charCodeAt(6)|o.charCodeAt(7) ||
     o.charCodeAt(12)==255 ||
     o.charCodeAt(30)!=55 ||
     (o.charCodeAt(34)&7)!=4)
    return 1;
  j= 0;
  a= o.charCodeAt(j++);
  setf(o.charCodeAt(j++));
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
  o08();
  setf(o.charCodeAt(j++));
  o08();
  yl= o.charCodeAt(j++);
  yh= o.charCodeAt(j++);
  xl= o.charCodeAt(j++);
  xh= o.charCodeAt(j++);
  iff= o.charCodeAt(j++);
  im= o.charCodeAt(j+1)&3;
  u= o.charCodeAt(30);
  lo= o.charCodeAt(38);
  if( u>23 ){
    pc= o.charCodeAt(j+4) | o.charCodeAt(j+5)<<8;
    for (v= 0; v < 10; v++ )
      ks[v]= o.charCodeAt(v+75);
  }
  else
    pc= o.charCodeAt(6) | o.charCodeAt(7)<<8;
  j+= u+4;
  while( j<o.length ){
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
  wp(0x7ffd, lo);
  r7<<= 7;
}

function wm() {
  v= String.fromCharCode(a,f(),c,b,l,h,0,0,sp&255,sp>>8,i,r,r7>>7|bor<<1,e,d,
                         c_,b_,e_,d_,l_,h_,a_);
  o08();
  v+= String.fromCharCode(f(),yl,yh,xl,xh,iff,iff,im,55,0,pc&255,pc>>8,4,lo,0,0,ayr);
  o08();
  for (u= 0; u< 16; u++)
    v+= String.fromCharCode(ayr[u]);
  for (j= 0; j < 20; j++)
    v+= String.fromCharCode(0);
  for (j= 0; j < 10; j++ )
    v+= String.fromCharCode(ks[j]);
  v+= String.fromCharCode(frc, 0);
  for (u= 0; u< 8; u++)
    for (j= 0, v+= String.fromCharCode(255,255,u+3); j < 0x4000; j++)
      v+= String.fromCharCode(ram[u][j]);
  return v;
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
        j= 0;
        o= ev.target.result;
        i= o.charCodeAt(j++);
        l_= o.charCodeAt(j++);
        h_= o.charCodeAt(j++);
        e_= o.charCodeAt(j++);
        d_= o.charCodeAt(j++);
        c_= o.charCodeAt(j++);
        b_= o.charCodeAt(j++);
        setf(o.charCodeAt(j++));
        a= o.charCodeAt(j++);
        o08();
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
        setf(o.charCodeAt(j++));
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
      reader.readAsBinaryString(evt.dataTransfer.files[0]);
      break;
    case 'z80':
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        o= ev.target.result;
        if(rm(o))
          return alert('Invalid Z80 file');
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