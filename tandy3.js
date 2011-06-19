m= [];                                 // memory
kc= [0,0,0,0,0,0,0,0,      // keyboard codes
    517,  // 8 backspace, same as cursor left
    8,    // 9 tab @
    0,0,0,
    512,  // 13 enter 
    0,0,
    1024, // 16 shift
    514,  // 17 control (break)
    0,    // 18 alt
    0,0,0,0,0,0,0,0,
    513,  // 27 esc (clear)
    0,0,0,0,
    519,  // 32 space
    0,0,0,0,
    517,  // cursor left
    515,  // cursor up
    518,  // cursor right
    516,  // cursor down
    0,0,0,0,0,0,0,
    128,  // 0 (48)
    129,  // 1
    130,  // 2
    131,  // 3
    132,  // 4
    133,  // 5
    134,  // 6
    135,  // 7
    256,  // 8
    257,  // 9
    0,0,0,0,0,0,0,
    9,    // A (65)
    10,   // B
    11,   // C
    12,   // D
    13,   // E
    14,   // F
    15,   // G
    16,   // H
    17,   // I
    18,   // J
    19,   // K
    20,   // L
    21,   // M
    22,   // N
    23,   // O
    32,   // P
    33,   // Q
    34,   // R
    35,   // S
    36,   // T
    37,   // U
    38,   // V
    39,   // W
    64,   // X
    65,   // Y
    66,   // Z (90)
    0,0,0,0,0,0,0,0,0,   // 91
    0,0,0,0,0,0,0,0,0,0, // 100
    0,0,0,0,0,0,0,0,0,0, // 110
    0,0,0,0,0,0,0,0,0,0, // 120
    0,0,0,0,0,0,0,0,0,0, // 130
    0,0,0,0,0,0,0,0,0,0, // 140
    0,0,0,0,0,0,0,0,0,0, // 150
    0,0,0,0,0,0,0,0,0,0, // 160
    0,0,0,0,0,0,0,0,0,0, // 170
    0,0,0,0,0,0,         // 180
    259,                 // 186 ;
    261,                 // 187 - qwerty -
    260,                 // 188 ,
    258,                 // 189 : qwerty =
    262,                 // 190 .
    263,0,0,0,0,0,0,0,0, // 191 /
    0,0,0,0,0,0,0,0,0,0, // 200
    0,0,0,0,0,0,0,0,0,   // 210
    258,0,               // 219 : dvorak [ 
    261                  // 221 - dvorak ]
];  

function run() {
  while(st < 67584)                       // execute z80 instructions during a frame
    r++,
    g[m[pc++]]();
  if ( !(++flash & 15) )
    put.title=  'jTandyIII '
              + parseInt( 52800
                        / ( (nt= new Date().getTime())
                          - time
                          )
                        )
              + '%',
    time= nt;
  t= -1;
  if( p236 & 4 )
    while( t++ < 0x3ff )
      for ( u= (  ~p236 & 8  &&  m[t+0x3c00] > 0xc0
                  ? m[t+0x3c00] + 0x40
                  : m[t+0x3c00] )
             * 12
             + 0xf80c
          , o=  (t>>6) * 12*512*4
              | t++<<5 & 0x7ff
          , n= 12
          ; n--
          ; o+= 0x800 )
        k= emul.charCodeAt(u++),
        eld[o   ]= eld[o+1 ]= eld[o+2 ]= eld[o+4 ]= eld[o+5 ]= eld[o+6 ]= k&0x80 ? 0xff : 0,
        eld[o+8 ]= eld[o+9 ]= eld[o+10]= eld[o+12]= eld[o+13]= eld[o+14]= k&0x40 ? 0xff : 0,
        eld[o+16]= eld[o+17]= eld[o+18]= eld[o+20]= eld[o+21]= eld[o+22]= k&0x20 ? 0xff : 0,
        eld[o+24]= eld[o+25]= eld[o+26]= eld[o+28]= eld[o+29]= eld[o+30]= k&0x10 ? 0xff : 0,
        eld[o+32]= eld[o+33]= eld[o+34]= eld[o+36]= eld[o+37]= eld[o+38]= k&0x08 ? 0xff : 0,
        eld[o+40]= eld[o+41]= eld[o+42]= eld[o+44]= eld[o+45]= eld[o+46]= k&0x04 ? 0xff : 0,
        eld[o+48]= eld[o+49]= eld[o+50]= eld[o+52]= eld[o+53]= eld[o+54]= k&0x02 ? 0xff : 0,
        eld[o+56]= eld[o+57]= eld[o+58]= eld[o+60]= eld[o+61]= eld[o+62]= k&0x01 ? 0xff : 0;
  else
    while( t++ < 0x3ff )
      for ( u= (  ~p236 & 8  &&  m[t+0x3c00] > 0xc0
                  ? m[t+0x3c00] + 0x40
                  : m[t+0x3c00] )
             * 12
             + 0xf80c
          , o=  (t>>6) * 12*512*4
              | t<<5 & 0x7ff
          , n= 12
          ; n--
          ; o+= 0x800 )
        k= emul.charCodeAt(u++),
        eld[o   ]= eld[o+1 ]= eld[o+2 ]= k&0x80 ? 0xff : 0,
        eld[o+4 ]= eld[o+5 ]= eld[o+6 ]= k&0x40 ? 0xff : 0,
        eld[o+8 ]= eld[o+9 ]= eld[o+10]= k&0x20 ? 0xff : 0,
        eld[o+12]= eld[o+13]= eld[o+14]= k&0x10 ? 0xff : 0,
        eld[o+16]= eld[o+17]= eld[o+18]= k&0x08 ? 0xff : 0,
        eld[o+20]= eld[o+21]= eld[o+22]= k&0x04 ? 0xff : 0,
        eld[o+24]= eld[o+25]= eld[o+26]= k&0x02 ? 0xff : 0,
        eld[o+28]= eld[o+29]= eld[o+30]= k&0x01 ? 0xff : 0;
  ct.putImageData(elm, 0, 0);
  st= 0;
  if(bIRQe)
    bIRQ= 1,
    z80interrupt();
}

function init() {
  onresize();
  ft= st= time= tape= flash= p236= bIRQ= bIRQe= 0;  // states, time (miliseconts), tape data, flash frame, tape pointer
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
  while( t < 0x60000 )
    eld[t++]= 0xff;
  for ( j= 0
      ; j < 0x10000
      ; j++ )        // fill memory
    m[j]= j < 0x3800
          ? emul.charCodeAt(j+0xc00c) & 0xff
          : ( j < 0x3c00
              ? 0
              : 0x76 );
  if( game )                               // emulate LOAD ""
    loadFile();
//  tab= document.getElementById('table').getContext('2d');
//  tab.drawImage(document.getElementById('tab'), 0, 0);
//  n= (j= tab.getImageData(0, 0, 1024, 120)).data;
//  for(y= 0; y<60; y++)
//    for(x= 0; x<512; x++)
//      for(r= 0; r<4; r++)
//        n[(y+60)*4096+8*x+4+r]= n[(y+60)*4096+8*x+r]= n[y*4096+x*4+r];
//  tab.putImageData(j, 0, 0);
  document.ondragover= handleDragOver;
  document.ondrop= handleFileSelect;
  document.onkeydown= kdown;          // key event handling
  document.onkeyup= kup;
  document.onkeypress= kpress;
  document.onresize= document.body.onresize= onresize;
  interval= setInterval(run, 33);
  self.focus();
}

function handleFileSelect(evt) {
  evt.stopPropagation();
  evt.preventDefault();
  if(evt.dataTransfer.files[0].name.slice(-3).toLowerCase()!='cmd')
    return alert('Invalid CMD file');
  var reader= new FileReader();
  k= evt.dataTransfer.files[0].size;
  reader.onloadend = function(ev) {
    tape= load.getImageData(0, 0, 1024, 128).data;
    o= ev.target.result;
    for(j=0; j<k; j++)
      tape[j<<2]= o.charCodeAt(j)
    loadFile(k);
  }
  reader.readAsBinaryString(evt.dataTransfer.files[0]);
}

function handleDragOver(evt) {
  evt.stopPropagation();
  evt.preventDefault();
}

function loadFile(k) {
  pc= 0;
//  run();
  j= 0;
  if(tape[j<<2]<31) // CMD file
    while(j<k)
      switch(tape[j++<<2]){
        case 1:
          n= tape[j++<<2]-2;
          n+= n-2 & 256;
          r= tape[j++<<2]|tape[j++<<2]<<8;
          while(n--)
            m[r++]= tape[j++<<2];
          break;
        case 2:
          j++;
          pc= tape[j++<<2]|tape[j++<<2]<<8;
          k=j;
          break;
        default:
          j+= 1+tape[j++<<2]
      }
  else if(tape[j<<2]<57){
  }
}

function kdown(evt) {
  var code= kc[evt.keyCode];
//console.log(evt.keyCode, code);
  if (code)
    m[0x3800|code>>3]|= 1 << (code&7);
  else if(evt.keyCode==116)
    location.reload();
  else if(evt.keyCode==122)
    return true;
  else if(evt.keyCode==112)
    if( ft^= 1 )
      clearInterval(interval),
      he.style.display= 'block';
    else
      interval= setInterval(run, 33),
      he.style.display= 'none';
  if (!evt.metaKey)
    return false;
}

function kup(evt) {
  var code= kc[evt.keyCode];
  if (code)
    m[0x3800|code>>3]&= 255 ^ 1<<(code&7);
  if (!evt.metaKey)
    return false;
}

function kpress(evt) {
  if (!evt.metaKey)
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
  he.style.left= cv.style.marginLeft;
  he.style.top= cv.style.marginTop;
}

function rp(addr) {
  switch( addr & 0xff ){
    // XXX - only reports status of video IRQ, not others.
    case 0xe0: return bIRQ ? 0xfb : 0xff;
    // XXX - big hack -- port 255 gives most of 236
    case 0xff: return p236 & 0xfc;
    case 0xec: bIRQ= 0;
    case 0xf8: return 0x30 // printer is ready!
  }
  return 0xff;
}

function wp(addr, val) {                // write port, only border color emulation
  addr&= 0xff;
  if( addr == 0xec )
    p236= val;
  else if( addr == 0xe0 )
    bIRQe= val & 4;
}

function wb(addr, val) {
  if( addr > 0x3bff )
    m[addr]= val;
}