gc= [0x04,0x0a,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00];
cr= [0x3f,0x28,0x00,0x00,0x26,0x00,0x19,0x00,0x00,0x07,0x00,0x00,0x30,0x00,0x00,0x00];
pl= [];
lut0= [];
lut1= [];
data= [];
m= [];                                 // memory
mw= [[],[],[],[]];        // [new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384), new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384)]
kb= [255,255,255,255,255,255,255,255,255,255]; // keyboard state
ks= [255,255,255,255,255,255,255,255,255,255]; // keyboard state playback
kc= [255,255,255,255,255,255,255,255,      // keyboard codes
    0x97,// 8 del qwerty backspace
    localStorage.ft & 2
    ? 0x94
    : 0x84,       // 9 tab
          255,255,255,
    0x22,// 13 enter 
          255,255,
    0x25,// 16 caps
    0x27,// 17 ctrl
          255,    // 18 qwerty alt
          255,
    0x86,// 20 caps lock
          255,255,255,255,255,255,
    0x82,// 27 esc
          255,255,255,255,
    0x57,// 32 space
          255,255,255,255,
    localStorage.ft & 2
    ? 0x92
    : 0x10,// cursor left
    localStorage.ft & 2
    ? 0x90
    : 0x00,// cursor up
    localStorage.ft & 2
    ? 0x93
    : 0x01,// cursor right
    localStorage.ft & 2
    ? 0x91
    : 0x02,// cursor down
          255,255,255,255,
    0x11,// 45 COPY querty Ins
    0x20,// 46 CLR qwerty Del
          255,
    0x40,// 0 (48)
    0x80,// 1
    0x81,// 2
    0x71,// 3
    0x70,// 4
    0x61,// 5
    0x60,// 6
    0x51,// 7
    0x50,// 8
    0x41,// 9
          255,255,255,255,255,255,255,
    0x85,// A (65)
    0x66,// B
    0x76,// C
    0x75,// D
    0x72,// E
    0x65,// F
    0x64,// G
    0x54,// H
    0x43,// I
    0x55,// J
    0x45,// K
    0x44,// L
    0x46,// M
    0x56,// N
    0x42,// O
    0x33,// P
    0x83,// Q
    0x62,// R
    0x74,// S
    0x63,// T
    0x52,// U
    0x67,// V
    0x73,// W
    0x77,// X
    0x53,// Y
    0x87,// Z (90)
          255,255,255,255,255,
    0x17,//  96 F0 qwerty NumKey0
    0x15,//  97 F1 qwerty NumKey1
    0x16,//  98 F2 qwerty NumKey2
    0x05,//  99 F3 qwerty NumKey3
    0x24,// 100 F4 qwerty NumKey4
    0x14,// 101 F5 qwerty NumKey5
    0x04,// 102 F6 qwerty NumKey6
    0x12,// 103 F7 qwerty NumKey7
    0x13,// 104 F8 qwerty NumKey8
    0x03,// 105 F9 qwerty NumKey9
          255,
    0x06,// 107 ENTER qwerty NumKey+
          255,
          255,
    0x07,// 110 F. qwerty NumKey.
          255,255,255,255,255,255,255,255,255,255,
          255,255,255,255,255,255,255,255,255,255,
          255,255,255,255,255,255,255,255,255,255,
          255,255,255,255,255,255,255,255,255,255,
          255,255,255,255,255,255,255,255,255,255,
          255,255,255,255,255,255,255,255,255,255,
          255,255,255,255,255,255,255,255,255,255,
          255,255,255,255,255,
    0x35,// 186 ; qwerty :
    0x30,// 187 ^ qwerty =
    0x47,// 188 ,
    0x31,// 189 -
    0x37,// 190 .
    0x36,// 191 /
    0x32,// 192 @ qwerty `
          255,255,255,255,255,255,255,255,255,255,
          255,255,255,255,255,255,255,255,255,255,
          255,255,255,255,255,255,
    0x21,// 219 [
    0x26,// 220 \
    0x23,// 221 ]
    0x34];// 222 ' qwerty ;
    
function run() {
  paintScreen();
  vsync= 1;
  while(st < 128) // 2 scanlines
//cond(),
    r++,
    g[m[pc>>14&3][pc++&16383]]();
  st-= 128;
  z80interrupt();
  while(st < 896) // 14 scanlines
//cond(),
    r++,
    g[m[pc>>14&3][pc++&16383]]();
  st-= 896;
  vsync= 0;
  while(st < 2432) // 38 scanlines
//cond(),
    r++,
    g[m[pc>>14&3][pc++&16383]]();
  st-= 2432;
  z80interrupt();
  for (vs= 0; vs<4; vs++){
    while(st < 3328) // 4*52 scanlines
//cond(),
      r++,
      g[m[pc>>14&3][pc++&16383]]();
    st-= 3328;
    z80interrupt();
  }
  while(st < 3200) // 50 scanlines
//cond(),
    r++,
    g[m[pc>>14&3][pc++&16383]]();
  st-= 3200;

  if( pbt ){
    if( !frc-- ){
      do{
        t= pb[pbc]>>8;
        (pb[pbc]&255)!=255 && (ks[t>>3]^= 1 << (t&7));
        frc= pb[++pbc]&255;
      } while( pbc<pbt && !(frc&255) )
      if(pbc==pbt)
//        console.log(frc),
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
  if (!(++flash & 15))
    titul(),
    time= nt;
}

function handleDragOver(ev) {
  ev.stopPropagation();
  ev.preventDefault();
}

function kdown(ev) {
  var code= kc[ev.keyCode];
  if( code<255 )
    kb[code>>4]&= ~(1 << (code & 0x07));
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
      kc[9]^= 0x10;
      kc[37]^= 0x82;
      kc[38]^= 0x90;
      kc[39]^= 0x92;
      kc[40]^= 0x93;
      alert((localStorage.ft^= 2) & 2
            ? 'Joystick enabled on Cursors + Tab'
            : 'Joystick disabled');
      self.focus();
      break;
    case 114: // F3
      pbt && (
        pbt= 0,
        tim.innerHTML= '',
        frc= (pb[pbc]&255)-frc);
      frcs= frc;
      pbcs= pbc;
      f3++;
      localStorage.save= wm();
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
        frc= frcs,
        pbc= pbcs,
        f4++,
        rm(localStorage.save);
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
        ajax('record.php', t);
        document.documentElement.innerHTML= 'Please wait...';
      }
      break;
    case 118: // F7
      localStorage.ft= +localStorage.ft+8 % 24;
      t= 1;
      rotapal();
      break;
    case 119: // F8
      m[0]= rom[pc= 0];
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
  if( !ev.metaKey )
    return false;
}

function kup(ev) {
  var code= kc[ev.keyCode];
  if( code<255 )
    kb[code>>4]|= 1 << (code & 0x07);
  if( !ev.metaKey )
    return false;
}

function kpress(ev) {
  if( ev.keyCode==116 || ev.keyCode==122 )
    return 1;
  if( !ev.metaKey )
    return false;
}

function audioprocess0(e){
  data= e.outputBuffer.getChannelData(0);
  j= 0;
  while( j<1024 )
    data[j++]= 0;
}

function audioprocess(e){
  run();
  data= e.outputBuffer.getChannelData(0);
  j= 0;
  if( localStorage.ft & 4 )
    while( j<1024 ) // 48000/1024= 46.875  19968/1024= 19.5. 19.5/4=5
      aymute(),
      aymute(),
      data[j++]= aystep();
  else
    while( j<1024 )
      data[j++]= 0;
}

function rt(f){
  rm(f);
  pbcs= pbc= pbt;
  frcs= frc= f.charCodeAt(255);
  f3++;
  localStorage.save= wm();
  tim.innerHTML= '';
  pbt= 0;
  if( trein==32000 )
    interval= setInterval(run, 20);
  else
    node.onaudioprocess= audioprocess;
}

function rever32(a){
  return  a>>24&0x000000ff
        | a>> 8&0x0000ff00
        | a<< 8&0x00ff0000
        | a<<24&0xff000000;
}