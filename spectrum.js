na= 'jBacteria ';
m= [];
vm= [];
vb= [];
data= [];
kb= [0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff]; // keyboard state
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
    0x04];        // Z (97)
pal= [[   0,    0,    0],
      [   0,    0, 0xc0],
      [0xc0,    0,    0],
      [0xc0,    0, 0xc0],
      [   0, 0xc0,    0],
      [   0, 0xc0, 0xc0],
      [0xc0, 0xc0,    0],
      [0xc0, 0xc0, 0xc0],
      [   0,    0,    0],
      [   0,    0, 0xff],
      [0xff,    0,    0],
      [0xff,    0, 0xff],
      [   0, 0xff,    0],
      [   0, 0xff, 0xff],
      [0xff, 0xff,    0],
      [0xff, 0xff, 0xff]];

function run() {
  while( st < 69888 )                       // execute z80 instructions during a frame
//cond(),
    r++,
    g[m[pc++&0xffff]]();
  if( !(++flash & 15) )
    put.title=  na
              + parseInt( trein
                        / ( (nt= new Date().getTime())
                          - time
                          )
                        )
              + '%',
    time= nt;
  t= -1;
  while( t++ < 0x2ff )
    for ( col= m[t+0x5800]
        , bk= pal[col    & 7
                | col>>3 & 8]
        , fr= pal[col>>3 & 15]
        , o=  t>>5 << 13 
            | t<<5 & 0x3ff
        , u=  0x4000
            | t    & 0xff 
            | t<<3 & 0x1800
        ; ! ( 0x1800
            & ( u ^ t<<3 )
            )
        ; u+= 0x100
        , o+= 0x400 )
      if( k=  col>>7
            & flash>>4
              ? ~m[u]
              : m[u]
        , vm[u] != (col | k<<8) ){
        vm[u]= col | k<<8;
        if( k&128 )
          eld[o  ]= bk[0],
          eld[o+1]= bk[1],
          eld[o+2]= bk[2];
        else
          eld[o  ]= fr[0],
          eld[o+1]= fr[1],
          eld[o+2]= fr[2];
        if( k&64 )
          eld[o+4]= bk[0],
          eld[o+5]= bk[1],
          eld[o+6]= bk[2];
        else
          eld[o+4]= fr[0],
          eld[o+5]= fr[1],
          eld[o+6]= fr[2];
        if( k&32 )
          eld[o+8 ]= bk[0],
          eld[o+9 ]= bk[1],
          eld[o+10]= bk[2];
        else
          eld[o+8 ]= fr[0],
          eld[o+9 ]= fr[1],
          eld[o+10]= fr[2];
        if( k&16 )
          eld[o+12]= bk[0],
          eld[o+13]= bk[1],
          eld[o+14]= bk[2];
        else
          eld[o+12]= fr[0],
          eld[o+13]= fr[1],
          eld[o+14]= fr[2];
        if( k&8 )
          eld[o+16]= bk[0],
          eld[o+17]= bk[1],
          eld[o+18]= bk[2];
        else
          eld[o+16]= fr[0],
          eld[o+17]= fr[1],
          eld[o+18]= fr[2];
        if( k&4 )
          eld[o+20]= bk[0],
          eld[o+21]= bk[1],
          eld[o+22]= bk[2];
        else
          eld[o+20]= fr[0],
          eld[o+21]= fr[1],
          eld[o+22]= fr[2];
        if( k&2 )
          eld[o+24]= bk[0],
          eld[o+25]= bk[1],
          eld[o+26]= bk[2];
        else
          eld[o+24]= fr[0],
          eld[o+25]= fr[1],
          eld[o+26]= fr[2];
        if( k&1 )
          eld[o+28]= bk[0],
          eld[o+29]= bk[1],
          eld[o+30]= bk[2];
        else
          eld[o+28]= fr[0],
          eld[o+29]= fr[1],
          eld[o+30]= fr[2];
      }
  ct.putImageData(elm, 0, 0);
  st= 0;
  z80interrupt();
}

function init() {
  cv.setAttribute('style', 'image-rendering:'+( localStorage.ft & 1
                                                ? 'optimizeSpeed'
                                                : '' ));
  onresize();
  cts= playp= vbp= bor= f1= st= time= flash= 0;
  if( localStorage.ft==undefined )
    localStorage.ft= 4;
  sample= 0.5;
  z80init();
  a= b= c= d= f= h= l= a_= b_= c_= d_= e_= h_= l_= r= r7= pc= iff= im= halted= t= u= 0;
  e=  0x11;
  f_= 0x01;
  xh= 0x5c;
  xl= 0xe2;
  yh= 0x5c;
  yl= 0x3a;
  i=  0x3f;
  sp= 0xff4a;
  try{
    put= top==self ? document : parent.document;
  }
  catch(error){
    put= document;
  }
  while( t < 0x30000 )
    eld[t++]= 0xff;
  for ( j= 0
      ; j < 0x10000
      ; j++ )        // fill memory
    m[j]= emul.charCodeAt(j+0x18018) & 0xff;
  if( game )                               // emulate LOAD ""
    tp(),
    pc= 0x56c;
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
      paso= 69888/1024,
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
      paso= 69888/2048;
      audioOutput.mozSetup(2, 51200);
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
    while( j < 1024 ){
      data1[j++]= data2[j]= sample;
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
    while( j < 2048 ){
      data[j++]= sample;
      play+= paso;
      if( play > vb[playp] && playp<vbp )
        playp++,
        sample= -sample;
    }
    audioOutput.mozWriteAudio(data);
  }
}

function handleFileSelect(evt) {
  evt.stopPropagation();
  evt.preventDefault();
  switch(evt.dataTransfer.files[0].name.slice(-3).toLowerCase()){
    case 'sna':
      if( evt.dataTransfer.files[0].size != 0xc01b )
        return alert('Invalid SNA file');
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        o= ev.target.result;
        rm(o);
      }
      reader.readAsBinaryString(evt.dataTransfer.files[0]);
      break;
    case 'z80':
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
        while( j < o.length ){
          t= o.charCodeAt(j++) | o.charCodeAt(j++)<<8;
          u= o.charCodeAt(j++);
          u=  ( u==8
                ? 1
                : u-2
              )
              <<
              14;
          if( t<0xffff )
            while( t-- )
              if( o.charCodeAt(j)==0xed && o.charCodeAt(j+1)==0xed ){
                t-= 3;
                w= o.charCodeAt(j+2);
                j+= 4;
                while( w-- )
                  m[u++]= o.charCodeAt(j-1);
              }
              else
                m[u++]= o.charCodeAt(j++);
          else
            do m[u++]= o.charCodeAt(j++)
            while( u & 0x3fff );
        }
        r7<<= 7;
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

function handleDragOver(evt) {
  evt.stopPropagation();
  evt.preventDefault();
}

function kdown(evt) {
  var code= kc[evt.keyCode];
  if( code )
    if( code>0x7f )
      kb[code>>3 & 15]&=  ~(0x20 >> (code     & 7)),
      kb[code>>10]&=      ~(0x20 >> (code>>7  & 7));
    else
      kb[code>>3]&=       ~(0x20 >> (code     & 7));
  else if( evt.keyCode==116 )
    location.reload();
  else if( evt.keyCode==122 )
    return 1;
  else if( evt.keyCode==112 )
    if( f1= ~f1 ){
      if( trein==32000 )
        clearInterval(interval);
      else
        node.onaudioprocess= audioprocess0;
      pt.style.display= he.style.display= 'block';
    }
    else{
      if( trein==32000 )
        interval= setInterval(myrun, 20);
      else
        node.onaudioprocess= audioprocess;
      pt.style.display= he.style.display= 'none';
    }
  else if( evt.keyCode==113 )
    kc[9]^=  0x41^(0x05<<7 | 0x3c),
    kc[37]^= 0x44^(0x05<<7 | 0x19),
    kc[38]^= 0x42^(0x05<<7 | 0x22),
    kc[39]^= 0x45^(0x05<<7 | 0x23),
    kc[40]^= 0x43^(0x05<<7 | 0x21),
    alert((localStorage.ft^= 2) & 2
          ? 'Cursors enabled'
          : 'Joystick enabled on Cursors + Tab'),
    self.focus();
  else if( evt.keyCode==114 )
    localStorage.save= wm();
  else if( evt.keyCode==115 )
    rm(localStorage.save);
  else if( evt.keyCode==119 )
    pc= 0;
  else if( evt.keyCode==120 )
    cv.setAttribute('style', 'image-rendering:'+( (localStorage.ft^= 1) & 1
                                                  ? 'optimizeSpeed'
                                                  : '' )),
    onresize(),
    alert(localStorage.ft & 1
          ? 'Nearest neighbor scaling'
          : 'Bilinear scaling'),
    self.focus();
  else if( evt.keyCode==121 ){
    o= wm();
    t= new ArrayBuffer(o.length);
    u= new Uint8Array(t, 0);
    for ( j=0; j<o.length; j++ )
      u[j]= o.charCodeAt(j);
    j= new WebKitBlobBuilder(); 
    j.append(t);
    ir.src= webkitURL.createObjectURL(j.getBlob());
    alert('Snapshot saved.\nRename the file (without extension) to .SNA.');
    self.focus();
  }
  else if( evt.keyCode==123 )
    localStorage.ft^= 4,
    alert('Sound '+(localStorage.ft & 4?'en':'dis')+'abled'),
    self.focus();
  if( !evt.metaKey )
    return false;
}

function kup(evt) {
  var code= kc[evt.keyCode];
  if( code )
    if( code>0x7f )
      kb[code>>3 & 15]|=  0x20 >> (code     & 7),
      kb[code>>10]|=      0x20 >> (code>>7  & 7);
    else
      kb[code>>3]|=       0x20 >> (code     & 7);
  if( !evt.metaKey )
    return false;
}

function kpress(evt) {
  if( !evt.metaKey )
    return false;
}

function onresize(evt) {
  ratio= innerWidth / innerHeight;
  if( ratio>1.33 )
    cv.style.height= innerHeight - 50 + 'px',
    cv.style.width= parseInt(ratio= (innerHeight-50)*1.33) + 'px',
    cv.style.marginTop= '25px',
    cv.style.marginLeft= (innerWidth-ratio >> 1) + 'px';
  else
    cv.style.width= innerWidth-50+'px',
    cv.style.height= parseInt(ratio=(innerWidth-50)/1.33)+'px',
    cv.style.marginLeft= '25px',
    cv.style.marginTop= (innerHeight-ratio >> 1) + 'px';
  he.style.width= cv.style.width;
  he.style.height= cv.style.height;
  pt.style.left= he.style.left= cv.style.marginLeft;
  pt.style.top= he.style.top= cv.style.marginTop;
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
}

function wb(addr, val) {
  if( addr > 0x3fff )
    m[addr]= val;
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
  wp(0,o.charCodeAt(j++));
  while( j < 0xc01b )
    m[j+0x3fe5]= o.charCodeAt(j++);
  g[0xc9]();
}

function wm() {
  wb(sp-1 & 0xffff, pc>>8 & 0xff);
  wb(sp-2 & 0xffff, pc    & 0xff);
  t= String.fromCharCode(i, l_, h_, e_, d_, c_, b_, f_, a_, l, h, e, d, c, b, yl, yh,
                         xl, xh, iff<<2, r, f, a, sp-2&0xff, sp-2>>8, im&3, bor);
  for ( j= 0x4000
      ; j < 0x10000
      ; j++ )
    t+= String.fromCharCode(m[j]);
  return t;
}

function tp(){
  tapei= tapep= t= j= 0;
  v= '';
  while( u= game.charCodeAt(t)      & 0xff
          | game.charCodeAt(t+1)<<8 & 0xffff )
    v+= '<option value="'+t+'">#'+ ++j+
        ( game.charCodeAt(t+2)
          ? ' Data: '+u+' bytes'
          : ' Prog: '+game.substr(t+4,10).trim()
        )+'</option>',
    t+= 2+u;
  pt.innerHTML= v;
}

function loadblock() {
  o=  game.charCodeAt(tapep++)    & 0xff
    | game.charCodeAt(tapep++)<<8 & 0xffff;
  tapei++;
  tapep++;
  for ( j= 0
      ; j < o-2
      ; j++ )
    wb(xl | xh << 8, game.charCodeAt(tapep++) & 0xff),
    g[0x123]();
  f_= 0x6d;
  a= d= e= 0;
  pc= 0x5e0;                           // exit address
  tapep++;
  o=  game.charCodeAt(tapep)      & 0xff
    | game.charCodeAt(tapep+1)<<8 & 0xffff;
  if( !o )
    tapei= tapep= 0;
  pt.selectedIndex= tapei;
}