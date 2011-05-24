/*This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  Author: mail@antoniovillena.es. Inspired in Peter Phillips's TRS-80 Model III Emulator
  Antonio José Villena Godoy. Malaga, Spain 05 Nov 2010*/
var ft= st= time= tape= flash= p236= bIRQ= bIRQe= 0  // states, time (miliseconts), tape data, flash frame, tape pointer
  , m= []                                 // memory
  , cv= document.getElementById('screen') // pointer to screen (canvas)
  , ct= cv.getContext('2d')               // canvas controller
  , kc = [0,0,0,0,0,0,0,0,      // keyboard codes
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
if(bcu)ct.putImageData(ct.getImageData(0, 0, 512, 192), 0, 0);
  while(st < 67584)                       // execute z80 instructions during a frame
    r++,
    g[m[pc++]](),
    pc&= 65535;
  flash++;                                // increment flash frame counter
  if (!(flash & 15))                      // redraw flashing attributes
    put.title= 'jTandyIII '+parseInt(52800/((nt= new Date().getTime())-time))+'%',
    time= nt;
  st= 0;
  if(bIRQe)
    bIRQ= 1,
    z80interrupt();
}

function init() {
bcu= navigator.userAgent.indexOf("Chrome/7.0.517") != -1;
  resize();
  z80init();
  a= b= c= d= f= h= l= a_= b_= c_= d_= e_= h_= l_= r= r7= pc= iff= im= halted= t= u= 0;
  e= 17;
  f_= 1;
  xh= 92;
  xl= 226;
  yh= 92;
  yl= 58;
  i= 63;
  sp= 65354;
  put= top==self ? document : parent.document;
  load= document.getElementById('load').getContext('2d');
  load.drawImage(document.getElementById('rom'), 0, 0);
  k= location.href.indexOf('?')+1     // read url argument
  n= load.getImageData(0, 0, 1024, 14).data;
  for (j= 0; j < 14336; j++)          // fill ROM
    m[j]= n[j*4];
  for (j= 14336; j < 65536; j++)      // fill memory
    m[j]= j<0x3C00 ? 0 : 118;
  if(k)                               // load file from server
    document.getElementById('rom').src= location.href.substr(k),
    document.getElementById('rom').onload= function(){
      load.drawImage(this, 0, 0);
      tape= load.getImageData(0, 0, 1024, this.height).data;
      loadFile(this.height*1024);
    }
  tab= document.getElementById('table').getContext('2d');
  tab.drawImage(document.getElementById('tab'), 0, 0);
  n= (j= tab.getImageData(0, 0, 1024, 120)).data;
  for(y= 0; y<60; y++)
    for(x= 0; x<512; x++)
      for(r= 0; r<4; r++)
        n[(y+60)*4096+8*x+4+r]= n[(y+60)*4096+8*x+r]= n[y*4096+x*4+r];
  tab.putImageData(j, 0, 0);
  document.ondragover= handleDragOver;
  document.ondrop= handleFileSelect;
  document.onkeydown= kdown;          // key event handling
  document.onkeyup= kup;
  document.onkeypress= kpress;
  document.body.onresize= resize;
  setInterval(run, 33);
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
    if (!ft)
      ft= 1,
      document.getElementById('tab').src= 'k',
      document.getElementById('tab').onload= function(){
        this.style.display= 'block';l
      }
    else
      ft= -ft,
      document.getElementById('tab').style.display= ft+1 ? 'block' : 'none';
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

function resize(evt) {
  var ratio= window.innerWidth/window.innerHeight;
  document.body.style.height= '0';
  document.body.style.width= '0';
  if (ratio>1.33)
    cv.style.height= window.innerHeight-50+'px',
    cv.style.width= parseInt(ratio=(window.innerHeight-50)*1.33)+'px',
    cv.style.marginTop= '25px',
    cv.style.marginLeft= ((window.innerWidth-ratio)>>1)+'px';
  else
    cv.style.width= window.innerWidth-50+'px',
    cv.style.height= parseInt(ratio=(window.innerWidth-50)/1.33)+'px',
    cv.style.marginLeft= '25px',
    cv.style.marginTop= ((window.innerHeight-ratio)>>1)+'px';
  document.getElementById('tab').style.width= cv.style.width;
  document.getElementById('tab').style.height= cv.style.height;
  document.getElementById('tab').style.left= cv.style.marginLeft;
  document.getElementById('tab').style.top= cv.style.marginTop;
}

function rp(addr) {
  switch(addr&255){
    // XXX - only reports status of video IRQ, not others.
    case 0xe0: return bIRQ ? 0xfb : 0xff;
    // XXX - big hack -- port 255 gives most of 236
    case 0xff: return p236 & 0xfc;
    case 0xec: bIRQ= 0;
    case 0xf8: return 0x30 // printer is ready!
  }
  return 255;
}

function wp(addr, val) {                // write port, only border color emulation
  addr&= 255;
  if (addr == 236){
    if(p236 != val){
      p236= val;
      for (o= 0; o< 0x400; o++)
        drawbyte(o, m[o+0x3C00]);
    }
  }
  else if (addr == 0xe0)
    bIRQe= val & 4;
}

function wb(addr, val) {
  if (addr < 0x3C00)
    return;
  if (val != m[addr]){
    m[addr]= val;
    if ((addr-= 0x3C00) < 0x400)
      drawbyte(addr, val);
  }
}

function drawbyte(addr, val) {
  if(val>192 && ~p236&8)
    val+= 64;
  if(p236 & 4){
    if (~addr&1)
      ct.putImageData(tab.getImageData(val<<4&1023, 60+(val>>6)*12, 16, 12), addr << 3 & 511, (addr >> 6)*12);
  }
  else
    ct.putImageData(tab.getImageData(val<<3&511, (val>>6)*12, 8, 12), addr << 3 & 511, (addr >> 6)*12);
}

function loadblock() {
}