na= 'jBacteriaSe ';
kc= [0,0,0,0,0,0,0,0,      // keyboard codes
    0x05<<7|0x25, // 8 backspace
    localStorage.ft & 2
    ? 0x05<<7|0x3c
    : 0x41,       // 9 tab (extend)
    0,0,0,
    0x35,         // 13 enter 
    0,0,
    0x05,         // 16 caps
    0x3c,         // 17 sym
    0,0,0,0,0,0,0,0,0,
    0x05<<7|0x1d, // 27 esc (edit)
    0,0,0,0,
    0x3d,         // 32 space
    0,0,0,0,
    localStorage.ft & 2
    ? 0x05<<7|0x19
    : 0x44,       // cursor left
    localStorage.ft & 2
    ? 0x05<<7|0x22 
    : 0x42,       // cursor up
    localStorage.ft & 2
    ? 0x05<<7|0x23
    : 0x45,       // cursor right
    localStorage.ft & 2
    ? 0x05<<7|0x21
    : 0x43,       // cursor down
    0,0,0,0,0,0,0,
    0x25,         // 0 (48)
    0x1d,         // 1
    0x1c,         // 2
    0x1b,         // 3
    0x1a,         // 4
    0x19,         // 5
    0x21,         // 6
    0x22,         // 7
    0x23,         // 8
    0x24,         // 9
    0,0,0,0,0,0,0,
    0x0d,         // A (65)
    0x39,         // B
    0x02,         // C
    0x0b,         // D
    0x13,         // E
    0x0a,         // F
    0x09,         // G
    0x31,         // H
    0x2b,         // I
    0x32,         // J
    0x33,         // K
    0x34,         // L
    0x3b,         // M
    0x3a,         // N
    0x2c,         // O
    0x2d,         // P
    0x15,         // Q
    0x12,         // R
    0x0c,         // S
    0x11,         // T
    0x2a,         // U
    0x01,         // V
    0x14,         // W
    0x03,         // X
    0x29,         // Y
    0x04,         // Z (90)
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0x3c<<7|0x2c, // 186
    0x3c<<7|0x34,
    0x3c<<7|0x3a,
    0x3c<<7|0x32,
    0x3c<<7|0x3b,
    0x3c<<7|0x01,
    0x3c<<7|0x03, //192
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    0x3c<<7|0x29, //219
    0x3c<<7|0x0b,
    0x3c<<7|0x2a,
    0x3c<<7|0x22];

function kdown(ev) {
  var code= kc[ev.keyCode];
  if( code )
    if( code>0x7f )
      kb[code>>3 & 15]&=  ~(0x20 >> (code     & 7)),
      kb[code>>10]&=      ~(0x20 >> (code>>7  & 7));
    else
      kb[code>>3]&=       ~(0x20 >> (code     & 7));
  switch( ev.keyCode ){
    case 112: // F1
      if( f1= ~f1 ){
        if( trein==32000 )
          clearInterval(interval);
        else
          node.onaudioprocess= audioprocess0;
        dv.style.display= he.style.display= 'block';
      }
      else{
        if( trein==32000 )
          interval= setInterval(run, 20);
        else
          node.onaudioprocess= audioprocess;
        dv.style.display= he.style.display= 'none';
      }
      break;
    case 113: // F2
      kc[9]^=  0x41^(0x05<<7 | 0x3c);
      kc[37]^= 0x44^(0x05<<7 | 0x19);
      kc[38]^= 0x42^(0x05<<7 | 0x22);
      kc[39]^= 0x45^(0x05<<7 | 0x23);
      kc[40]^= 0x43^(0x05<<7 | 0x21);
      alert((localStorage.ft^= 2) & 2
            ? 'Cursors enabled'
            : 'Joystick enabled on Cursors + Tab');
      self.focus();
      break;
    case 114: // F3
      localStorage.savese= wm();
      break;
    case 115: // F4
      rm(localStorage.savese);
      break;
    case 116: // F5
      return 1;
    case 118: // F7
      localStorage.ft^= 8;
      rotapal();
      break;
    case 119: // F8
      paintScreen= paintNormal;
      pc= 0;
      break;
    case 120: // F9
      cv.setAttribute('style', 'image-rendering:'+( (localStorage.ft^= 1) & 1
                                                    ? 'optimizeSpeed'
                                                    : '' ));
      onresize();
      alert(localStorage.ft & 1
            ? 'Nearest neighbor scaling'
            : 'Bilinear scaling');
      self.focus();
      break;
    case 121: // F10
      o= wm();
      u= new Uint8Array(o.length);
      for ( j=0; j<o.length; j++ )
        u[j]= o.charCodeAt(j);
      ir.src= URL.createObjectURL(new Blob([u.buffer], {type: 'application/octet-binary'}));
      alert('Snapshot saved.\nRename the file (without extension) to .SNA.');
      self.focus();
      break;
    case 122: // F11
      return 1;
    case 123: // F12
      alert('Sound '+ ( (localStorage.ft^= 4) & 4
                        ? 'en'
                        : 'dis' ) +'abled');
      self.focus();
  }
  if( code==0x05 )
    kc[186]= 0x3c<<7|0x04,
    kc[187]= 0x3c<<7|0x33,
    kc[188]= 0x3c<<7|0x12,
    kc[189]= 0x3c<<7|0x25,
    kc[190]= 0x3c<<7|0x11,
    kc[191]= 0x3c<<7|0x02,
    kc[192]= 0x3c<<7|0x0d,
    kc[219]= 0x3c<<7|0x0a,
    kc[220]= 0x3c<<7|0x0c,
    kc[221]= 0x3c<<7|0x09,
    kc[222]= 0x3c<<7|0x2d;
  if( code==(0x3c<<7|0x04)
   || code==(0x3c<<7|0x33)
   || code==(0x3c<<7|0x12)
   || code==(0x3c<<7|0x25)
   || code==(0x3c<<7|0x11)
   || code==(0x3c<<7|0x02)
   || code==(0x3c<<7|0x0d)
   || code==(0x3c<<7|0x0a)
   || code==(0x3c<<7|0x0c)
   || code==(0x3c<<7|0x09)
   || code==(0x3c<<7|0x2d) )
    kb[0]|= 1;
  if( !ev.metaKey )
    return false;
}

function kup(evt) {
  var code= kc[evt.keyCode];
  if( code==0x05 )
    kc[186]= 0x3c<<7|0x2c,
    kc[187]= 0x3c<<7|0x34,
    kc[188]= 0x3c<<7|0x3a,
    kc[189]= 0x3c<<7|0x32,
    kc[190]= 0x3c<<7|0x3b,
    kc[191]= 0x3c<<7|0x01,
    kc[192]= 0x3c<<7|0x03,
    kc[219]= 0x3c<<7|0x29,
    kc[220]= 0x3c<<7|0x0b,
    kc[221]= 0x3c<<7|0x2a,
    kc[222]= 0x3c<<7|0x22;
  if( code )
    if( code>0x7f )
      kb[code>>3 & 15]|=  0x20 >> (code     & 7),
      kb[code>>10]|=      0x20 >> (code>>7  & 7);
    else
      kb[code>>3]|=       0x20 >> (code     & 7);
  if( !evt.metaKey )
    return false;
}

function init() {
  paintScreen= paintNormal;
  cv.setAttribute('style', 'image-rendering:'+( localStorage.ft & 1
                                                ? 'optimizeSpeed'
                                                : '' ));
  onresize();
  scrl= ula= sample= pbcs= pbc= cts= playp= vbp= bor= f1= f3= f4= st= time= flash= 0;
  if( localStorage.ft==undefined )
    localStorage.ft= 4;
  if ( localStorage.ft & 8 )
    rotapal();
  a= b= c= d= h= l= fa= fb= fr= ff= r7=
  a_=b_=c_=d_=h_=l_=fa_=fb_=fr_=e_= r= pc= iff= im= halted= t= u= 0;
  e=  0x11;
  ff_= 0x100;
  xh= 0x5c;
  xl= 0xe2;
  yh= 0x5c;
  yl= 0x3a;
  i=  0x3f;
  sp= 0xfff2;
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
      put.title= na+parseInt(trein/((nt= new Date().getTime())-time))+'%';
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
  for ( j= 0
      ; j < 0x10000
      ; j++ )        // fill memory
    m[j]= emul.charCodeAt(j+301*250+24);
  game && (pc= 0x56c, tp());
  document.ondragover= handleDragOver;
  document.ondrop= handleFileSelect;
  document.onkeydown= kdown;          // key event handling
  document.onkeyup= kup;
  document.onkeypress= kpress;
  document.onresize= document.body.onresize= onresize;
  trein= 32000;
  if(typeof AudioContext == 'function'){
    cts= new AudioContext();
    if( cts.sampleRate>44000 && cts.sampleRate<50000 )
      trein*= 50*1024/cts.sampleRate,
      paso= 69888/1024,
      node= cts.createScriptProcessor(1024, 1, 1),
      node.onaudioprocess= audioprocess,
      node.connect(cts.destination);
    else
      interval= setInterval(run, 20);
  }
  else
    interval= setInterval(run, 20);
  self.focus();
}