 bp= 0;
  gc= [0x04,0x0a,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00];
  ayr= [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00];
  cr= [0x00,0x28,0x00,0x00,0x00,0x00,0x19,0x00,0x00,0x07,0x00,0x00,0x30,0x00,0x00,0x00];
pl= [];
lut0= [];
lut1= [];

  ay= 0;
  ci= 0;
  ap= 0;
  io= 0;
  vsync= 0;

m= [];                                 // memory
mw= [[],[],[],[]];        // [new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384), new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384),new Uint8Array(16384)]
kb= [255,255,255,255,255,255,255,255,
     255,255,255,255,255,255,255,255]; // keyboard state
kc= [255,255,255,255,255,255,255,255,      // keyboard codes
    0x97,// 8 del qwerty backspace
    0x84,// 9 tab 
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
    0x10,// cursor left
    0x00,// cursor up
    0x01,// cursor right
    0x02,// cursor down
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
    
pal=[[128, 128, 128],
     [128, 128, 128],
     [  0, 255, 128],
     [255, 255, 128],
     [  0,   0, 128],
     [255,   0, 128],
     [  0, 128, 128],
     [255, 128, 128],
     [255,   0, 128],
     [255, 255, 128],
     [255, 255,   0],
     [255, 255, 255],
     [255,   0,   0],
     [255,   0, 255],
     [255, 128,   0],
     [255, 128, 255],
     [  0,   0, 128],
     [  0, 255, 128],
     [  0, 255,   0],
     [  0, 255, 255],
     [  0,   0,   0],
     [  0,   0, 255],
     [  0, 128,   0],
     [  0, 128, 255],
     [128,   0, 128],
     [128, 255, 128],
     [128, 255,   0],
     [128, 255, 255],
     [128,   0,   0],
     [128,   0, 255],
     [128, 128,   0],
     [128, 128, 255]];

function run() {
  for (vs= 0; vs<5; vs++){
    while(st < 10000) // 4000000MHz/50Hz= 80000cycles/frame*0.75= 60000/6=10000
//cond(),
      r++,
      g[m[pc>>14&3][pc++&16383]]();
    st= 0;
    z80interrupt();
  }
  while(st < 10000-4400)
//cond(),
    r++,
    g[m[pc>>14&3][pc++&16383]]();
  st= 0;
  vsync= 1;

  while(st < 400)
//cond(),
    r++,
    g[m[pc>>14&3][pc++&16383]]();
  st= 0;
  z80interrupt();

  while(st < 4000)
//cond(),
    r++,
    g[m[pc>>14&3][pc++&16383]]();
  vsync= 0;
  st= 0;

  paintScreen();
  if (!(++flash & 15))
    put.title= 'Roland'+suf+' '+parseInt(32000/((nt= new Date().getTime())-time))+'%',
    time= nt;
}

function handleDragOver(evt) {
  evt.stopPropagation();
  evt.preventDefault();
}

function kdown(evt) {
  var code= kc[evt.keyCode];
  if (code<255)
    kb[code>>4]&= ~(1 << (code & 0x07));
  else if(evt.keyCode==116)
    location.reload();
  else if(evt.keyCode==122)
    return 1;
  else if(evt.keyCode==112)
    if(ft^= 1)
      clearInterval(interval),
      he.style.display= 'block';
    else
      interval= setInterval(run, 20),
      he.style.display= 'none';
  else if(evt.keyCode==113)
    kc[9]^= 0x10,
    kc[37]^= 0x82,
    kc[38]^= 0x90,
    kc[39]^= 0x92,
    kc[40]^= 0x93,
    alert('Joystick '+(kc[9]&0x10?'en':'dis')+'abled on Cursors + Tab');
  else if(evt.keyCode==114)
    save= wm();
  else if(evt.keyCode==115)
    rm(save);
  else if(evt.keyCode==119)
    m[0]= rom[pc= 0];
  else if(evt.keyCode==121){
    o= wm();
    t= new ArrayBuffer(o.length);
    u= new Uint8Array(t, 0);
    for (j=0; j<o.length; j++)
      u[j]= o.charCodeAt(j);
    j= new WebKitBlobBuilder(); 
    j.append(t);
    ir.src= webkitURL.createObjectURL(j.getBlob());
    alert('Snapshot saved.\nRename the file (without extension) to .SNA.');
  }
  if (!evt.metaKey)
    return false;
}

function kup(evt) {
  var code= kc[evt.keyCode];
  if (code<255)
    kb[code>>4]|= 1 << (code & 0x07);
  if (!evt.metaKey)
    return false;
}

function kpress(evt) {
  if (!evt.metaKey)
    return false;
}