m= [];                                 // memory
mw= [];                                // write access memory
vm= words(6144);                       // video memory
vb= [];
data= [];
ram= [bytes(16384), bytes(16384), bytes(16384), bytes(16384),
      bytes(16384), bytes(16384), bytes(16384), bytes(16384), bytes(16384)];
kb= [0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff]; // keyboard state
ks= [0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff]; // keyboard state
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
pal= [[  0,   0,   0],
      [  0,   0, 202],
      [202,   0,   0],
      [202,   0, 202],
      [  0, 202,   0],
      [  0, 202, 202],
      [202, 202,   0],
      [197, 199, 197],
      [  0,   0,   0],
      [  0,   0, 255],
      [255,   0,   0],
      [255,   0, 255],
      [  0, 255,   0],
      [  0, 255, 255],
      [255, 255,   0],
      [255, 255, 255],
// grayscale
      [  0,   0,   0],
      [ 23,  23,  23],
      [ 60,  60,  60],
      [ 83,  83,  83],
      [119, 119, 119],
      [142, 142, 142],
      [179, 179, 179],
      [198, 198, 198],
      [  0,   0,   0],
      [ 29,  29,  29],
      [ 76,  76,  76],
      [105, 105, 105],
      [150, 150, 150],
      [179, 179, 179],
      [226, 226, 226],
      [255, 255, 255]];

ulap=[[  0,   0,   0],
      [  0,   0, 202],
      [202,   0,   0],
      [202,   0, 202],
      [  0, 202,   0],
      [  0, 202, 202],
      [202, 202,   0],
      [197, 199, 197],
      [  0,   0,   0],
      [  0,   0, 202],
      [202,   0,   0],
      [202,   0, 202],
      [  0, 202,   0],
      [  0, 202, 202],
      [202, 202,   0],
      [197, 199, 197],
      [  0,   0,   0],
      [  0,   0, 255],
      [255,   0,   0],
      [255,   0, 255],
      [  0, 255,   0],
      [  0, 255, 255],
      [255, 255,   0],
      [255, 255, 255],
      [  0,   0,   0],
      [  0,   0, 255],
      [255,   0,   0],
      [255,   0, 255],
      [  0, 255,   0],
      [  0, 255, 255],
      [255, 255,   0],
      [255, 255, 255],
      [  0,   0,   0],
      [  0,   0, 202],
      [202,   0,   0],
      [202,   0, 202],
      [  0, 202,   0],
      [  0, 202, 202],
      [202, 202,   0],
      [197, 199, 197],
      [  0,   0,   0],
      [  0,   0, 202],
      [202,   0,   0],
      [202,   0, 202],
      [  0, 202,   0],
      [  0, 202, 202],
      [202, 202,   0],
      [197, 199, 197],
      [  0,   0,   0],
      [  0,   0, 255],
      [255,   0,   0],
      [255,   0, 255],
      [  0, 255,   0],
      [  0, 255, 255],
      [255, 255,   0],
      [255, 255, 255],
      [  0,   0,   0],
      [  0,   0, 255],
      [255,   0,   0],
      [255,   0, 255],
      [  0, 255,   0],
      [  0, 255, 255],
      [255, 255,   0],
      [255, 255, 255]];

function bytes(a) {
  try{
    return new Uint8Array(a);
  }
  catch (b){
    var c = Array(a), d = a;
    while (d)
      c[--d]= 0;
    return c;
  }
}

function words(a) {
  try{
    return new Uint16Array(a);
  }
  catch (b){
    var c = Array(a), d = a;
    while (d)
      c[--d]= 0;
    return c;
  }
}

function run() {
  while(st < 70908)
//cond(),
    r++,
    g[m[pc>>14&3][pc++&0x3fff]]();
  if( pbt ){
    if( !frc-- ){
      do{
        t= pb[pbc]>>8;
        (pb[pbc]&255)!=255 && (ks[t>>3]^= 1 << (t&7));
        frc= pb[++pbc]&255;
      } while( pbc<pbt && !(frc&255) )
      if(pbc==pbt)
        tim.innerHTML= '',
        pbt= 0;
      else
        frc--;
    }
  }
  else{
    for ( t= 0; t<80; t++ )
      if( (kb[t>>3] ^ ks[t>>3]) & (1 << (t&7)) )
        pb[pbc++]= frc | t<<8,
        frc= 0;
    if( ++frc == 255 )
      pb[pbc++]= frc,
      frc= 0;
    for ( t= 0; t<10; t++ )
      ks[t]= kb[t];
  }
  if( !(++flash & 15) )
    titul(),
    time= nt;
  paintScreen();
  st-= 70908;
  z80interrupt();
}

function handleDragOver(ev) {
  ev.stopPropagation();
  ev.preventDefault();
}

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
          interval= setInterval(myrun, 20);
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
      pbt && (
        pbt= 0,
        tim.innerHTML= '',
        frc= (pb[pbc]&255)-frc);
//      frcs= frc;
      pbcs= pbc;
      f3++;
      localStorage.save128= wm();
      break;
    case 115: // F4
      if( pbt ){
        if( trein==32000 )
          clearInterval(interval);
        else
          node.onaudioprocess= audioprocess0;
        ajax('snaps/'+params.slice(0,-3)+'sna', -1);
      }
      else
        frc= localStorage.save128.charCodeAt(85),
        pbc= pbcs,
        f4++,
        rm(localStorage.save128);
      break;
    case 116: // F5
      return 1;
    case 117: // F6
      if( !pbt ){
        if( trein==32000 )
          clearInterval(interval);
        else
          node.onaudioprocess= audioprocess0;
        t= wm()+String.fromCharCode(f3)+String.fromCharCode(f4)+param+String.fromCharCode(255);
        while( pbc )
          t+= String.fromCharCode(pb[--pbc]);
        ajax('rec.php', t);
        document.documentElement.innerHTML= 'Please wait...';
      }
      break;
    case 118: // F7
      localStorage.ft^= 8;
      rotapal();
      break;
    case 119: // F8
      paintScreen= paintNormal;
      pag= 1;
      wp(0x7ffd, pc= 0);
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
      t= new ArrayBuffer(o.length);
      u= new Uint8Array(t, 0);
      for ( j=0; j<o.length; j++ )
        u[j]= o.charCodeAt(j);
      j= new WebKitBlobBuilder(); 
      j.append(t);
      ir.src= webkitURL.createObjectURL(j.getBlob());
      alert('Snapshot saved.\nRename the file (without extension) to .Z80');
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

function kpress(evt) {
  if( ev.keyCode==116 || ev.keyCode==122 )
    return 1;
  if( !evt.metaKey )
    return false;
}

function onresize(ev) {
  ratio= innerWidth / innerHeight;
  if( ratio>1.33 )
    cv.style.height= innerHeight - 50 + 'px',
    cv.style.width= parseInt(ratio= (innerHeight-50)*1.33) + 'px',
    cu.style.height= parseInt((innerHeight-50)*.28)-20+'px',
    cu.style.width= parseInt(ratio*.6)+'px',
    cv.style.marginTop= '25px',
    cv.style.marginLeft= (innerWidth-ratio >> 1) + 'px';
  else
    cv.style.width= innerWidth-50+'px',
    cv.style.height= parseInt(ratio=(innerWidth-50)/1.33)+'px',
    cu.style.width= parseInt((innerWidth-50)*.6)+'px',
    cu.style.height= parseInt(ratio*.28)-20+'px',
    cv.style.marginLeft= '25px',
    cv.style.marginTop= (innerHeight-ratio >> 1) + 'px';
  he.style.width= cv.style.width;
  he.style.height= cv.style.height;
  dv.style.left= he.style.left= cv.style.marginLeft;
  dv.style.top= he.style.top= cv.style.marginTop;
}

function tp(){
  tapei= tapep= t= j= 0;
  if( game.charCodeAt(0)!=19 ){
    rm(game);
    return;
  }
  v= '';
  while(u=  game.charCodeAt(t)      & 0xff
          | game.charCodeAt(t+1)<<8 & 0xffff)
    v+= '<option value="'+t+'">#'+ ++j+
        ( game.charCodeAt(t+2)
          ? ' Data: '+(u-2)+' bytes'
          : ' Prog: '+game.substr(t+4,10).replace(/\0/g, '')
        )+'</option>',
    t+= 2+u;
  if( ie )
    pt.outerHTML= '<select onchange="tapep=this.value;tapei=this.selectedIndex">'+v+'</select>';
  else
    pt.innerHTML= v;
}

function loadblock() {
  o=  game.charCodeAt(tapep++) | game.charCodeAt(tapep++)<<8;
//console.log(o);
  tapei++;
  tapep++;
  for ( j= 0
      ; j < o-2
      ; j++ )
    mw[xh>>6][xl | xh<<8 & 0x3fff]= game.charCodeAt(tapep++),
    g[0x123]();
  setf_(0x6d);  //abcd
//  f_=0x6d;
  a= d= e= 0;
  pc= 0x5e0;                           // exit address
  tapep++;
  o=  game.charCodeAt(tapep) | game.charCodeAt(tapep+1)<<8;
  if( !o )
    tapei= tapep= 0;
  pt.selectedIndex= tapei;
}

function rotapal(){
  for (t= 0; t < 16; t++)
    u= pal[t],
    pal[t]= pal[t+16],
    pal[t+16]= u;
  for (t= 0; t < 0x1800; t++)
    vm[t]= -1;
  document.body.style.backgroundColor=  'rgb('
                                      + ( paintScreen==paintNormal
                                            ? pal[bor&7]
                                            : ulap[8] )
                                      + ')';
}

function rt(f){
  rm(f);
  pbcs= pbc= pbt;
  frc= f.charCodeAt(85);
  f3++;
  localStorage.save128= wm();
  tim.innerHTML= '';
  pbt= 0;
  if( trein==32000 )
    interval= setInterval(myrun, 20);
  else
    node.onaudioprocess= audioprocess;
}