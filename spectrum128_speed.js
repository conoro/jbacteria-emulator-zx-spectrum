m= [];                                 // memory
mw= [];                                // write access memory
vm= [];/*new Uint8Array(256)*/         // video memory
vb= [];/*new Uint8Array(0x1b00)*/         // video buffer
data= [];
ram= [[],[],[],[],[],[],[],[],[]];        // [new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384), new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384)]
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
  while(st < 70908)
//cond(),
    r++,
    g[m[pc>>14&3][pc++&0x3fff]]();
  if( !(++flash & 15) )
    put.title=  'jAmeba'
              + suf
              + ' '
              + parseInt( trein
                        / ( (nt= new Date().getTime())
                          - time
                          )
                        )
              + '%',
    time= nt;
  t= -1;
  while(t++ < 0x2ff){
    for ( col= scree[t+0x1800]
        , bk= pal[col    & 7
                | col>>3 & 8]
        , fr= pal[col>>3 & 15]
        , co= 0
        , dx= t<<3 & 0xff
        , dy= t>>5 << 3
        , o=  dy<<10
            | t<<5 & 0x3ff
        , u=  t    & 0xff 
            | t<<3 & 0x1800
        , n=  0
        ; n < 8
        ; u+= 0x100
        , o+= 0x400
        , n++ )
      if( k=  col>>7
            & flash>>4
              ? ~scree[u]
              : scree[u]
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
      else{
        if(n>co)
          ct.putImageData(elm, 0, 0, dx-1, dy+co-1, 10, n-co+2);
        co= n+1;
      }
    if(n>co)
      ct.putImageData(elm, 0, 0, dx-1, dy+co-1, 10, n-co+2);
  }
  st= 0;
  z80interrupt();
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
  if(code==0x05)
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
  else if( evt.keyCode==114 )
    localStorage.save128= wm();
  else if( evt.keyCode==115 )
    rm(localStorage.save128);
  else if( evt.keyCode==119 )
    pag= 1,
    wp(0x7ffd, pc= 0);
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
    alert('Snapshot saved.\nRename the file (without extension) to .'+(suf>'2'?'Z80':'SNA'));
  }
  else if( evt.keyCode==123 )
    localStorage.ft^= 4,
    alert('Sound '+(localStorage.ft & 4?'en':'dis')+'abled'),
    self.focus();
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
  if (!evt.metaKey)
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

function tp(){
  tapei= tapep= t= j= 0;
  v= '';
  while(u=  game.charCodeAt(t)      & 0xff
          | game.charCodeAt(t+1)<<8 & 0xffff)
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
    mw[xh>>6][xl | xh<<8 & 0x3fff]= game.charCodeAt(tapep++) & 0xff,
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
