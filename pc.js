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

  Author: mail@antoniovillena.es. Inspired in Matthew Westcott's JSSpeccy
  Antonio José Villena Godoy. Malaga, Spain 29 Aug 2010*/
var ft= st= time= tape= flash= tapep= 0       // states, time (miliseconts), tape data, flash frame, tape pointer
  , tr= []                                // trasformation table (invert paper and ink positions)
  , m= []                                 // memory
  , vm= []                                // video memory
  , cv= document.getElementById('screen') // pointer to screen (canvas)
  , ct= cv.getContext('2d')               // canvas controller
  , kb= [255,255,255,255,255,255,255,255,255] // keyboard state
  , kc = [0,0,0,0,0,0,0,0,      // keyboard codes
  385,  // 8 backspace, 129+256
  0,  // 9 tab (extend), 226+256
  0,0,0,
  193,  // 13 enter 
  0,0,
  1,    // 16 caps
  226,  // 17 sym
  0,    // 18 alt (kempston fire)
  0,0,0,0,0,0,0,0,
  353,  // 27 esc (edit), 97+256
  0,0,0,0,
  225,  // 32 space
  0,0,0,0,
  368,  // cursor left, 112+256
  392,  // cursor up, 136+256
  388,  // cursor right, 132+256
  400,  // cursor down, 144+256
  0,0,0,0,0,0,0,
  129,  // 0 (48)
  97,   // 1
  98,   // 2
  100,  // 3
  104,  // 4
  112,  // 5
  144,  // 6
  136,  // 7
  132,  // 8
  130,  // 9
  0,0,0,0,0,0,0,
  33,   // A (65)
  240,  // B
  8,    // C
  36,   // D
  68,   // E
  40,   // F
  48,   // G
  208,  // H
  164,  // I
  200,  // J
  196,  // K
  194,  // L
  228,  // M
  232,  // N
  162,  // O
  161,  // P
  65,   // Q
  72,   // R
  34,   // S
  80,   // T
  168,  // U
  16,   // V
  66,   // W
  4,    // X
  176,  // Y
  2]    // Z (97)
  , pal= [
      [  0,  0,  0],
      [  0,  0,170],
      [  0,170,  0],
      [  0,170,170],
      [170,  0,  0],
      [170,  0,170],
      [170, 85,  0],
      [170,170,170],
      [ 85, 85, 85],
      [ 85, 85,255],
      [ 85,255, 85],
      [ 85,255,255],
      [255, 85, 85],
      [255, 85,255],
      [255,255, 85],
      [255,255,255]];


function run() {
  while(st++ < 10000 && !eval(breakpoint))
    g[m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8]();
  if(eval(breakpoint))
//    console.log('br '+breakpoint),
    tape= 1,
    clearInterval(interval);
  paintScreen();
//  console.log(tapep++);
  flash++;                                // increment flash frame counter
  if (!(flash & 15)){                     // redraw flashing attributes
    put.title= 'jComputer '+parseInt(32000/((nt= new Date().getTime())-time))+'%';
    time= nt;
/*    for (o= 22528; o< 23296; o++)
      if (m[o] & 128)
        drawattr(o, m[o]);*/
  }
  st= 0;
//  z80interrupt();
}

function init() {
  resize();
  x86init();
  put= top==self ? document : parent.document;

m= [205,32,255,159,0,234,255,255,173,222,230,1,176,21,176,1,
176,21,131,2,20,16,147,1,1,1,1,0,2,255,255,255,
255,255,255,255,255,255,255,255,255,255,255,255,148,72,246,245,
242,32,20,0,24,0,159,72,255,255,255,255,0,0,0,0,
5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
205,33,203,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,13,0,255,176,246,97,34,163,1,44,247,1,128,255,255,
44,247,255,255,0,0,198,246,1,2,128,53,44,247,1,128,
1,0,2,0,0,0,242,32,220,246,40,6,10,0,1,128,
210,246,51,35,2,0,255,255,228,246,97,34,163,1,247,83,
244,246,40,6,16,0,0,0,16,0,186,5,247,83,11,0,
61,0,0,247,213,4,250,4,149,4,247,83,174,170,125,0,
172,8,174,170,174,170,140,247,22,2,240,58,174,170,247,83,
0,0,116,100,104,101,108,112,46,116,100,104,0,68,72,0,

176,3,205,16,104,0,184,7,175,153,189,34,1,255,213,114,
45,190,0,16,255,213,17,246,115,250,138,98,59,117,27,150,
205,22,15,163,86,77,66,195,215,147,183,255,255,213,16,201,
255,213,114,248,38,139,1,171,226,250,177,1,176,32,36,33,
255,213,16,192,115,250,60,7,119,237,116,193,255,213,187,105,
1,114,213,179,87,215,235,223,176,177,178,219,220,32,112,7,
8,14,15,104,111,6,118,120,127,96,244,102,94,254,90,98,
242,100,242,59,169,138,212,170,46,38,253,19,90,149,200,205,
253,195,12,199,140,208,214,1,112,57,154,244,171,228,184,146,
85,147,65,17,97,35,63,168,130,169,166,214,167,234,106,134,
68,2,3,224,208,51,161,142,100,210,132,237,4,32,242,0,
84,239,106,72,18,179,176,72,91,0,162,35,52,113,16,91,
112,136,228,116,210,173,10,149,171,217,44,36,236,56,210,43,
8,68,16,33,196,104,4,75,141,84,39,210,122,214,194,180,
92,126,23,73,168,115,130,104,23,253,178,223,11,0,4,160,
65,185,250,61,100,201,15,135,164,65,61,168,138,194,37,170,
150,170,200,80,2,57,252,191,87,122,211,119,126,151,121,203,
183,155,121,133,55,125,195,55,126,211,255,67,163,73,49,49,
65,149,72,169,4,133,137,172,102,0,197,187,138,176,72,29,
108,112,198,66,240,153,4,34,253,170,230,24,32,112,79,48,
67,239,184,210,122,231,218,228,40,42,105,224,168,142,1,142,
106,142,1,117,150,193,211,34,78,94,226,13,223,225,29,222,
243,56,146,150,117,163,171,73,72,154,186,34,14,142,11,85,
2,33,179,227,73,139,56,121,137,55,124,155,183,121,251,119,
127,211,55,125,187,39,108,60,112,31,114,52,236,8,80,205,
108,72,2,53,105,204,194,184,176,73,26,128,107,145,48,252,
86,142,0,142,167,18,13,159,16,26,116,140,204,4,145,14,
109,42,98,174,39,1,241,79,137,60,252,108,66,16,193,49,
33,65,28,50,38,4,197,194,164,142,192,193,86,83,142,43,
9,244,177,24,25,50,84,40,233,132,36,49,52,89,200,172,
142,0,115,135,142,42,57,30,200,80,109,51,74,140,8,77,
104,40,227,58,66,161,101,36,59,29,0,84,150,171,73,161,
68,142,106,142,33,13,21,179,70,144,49,241,89,48,26,172,
195,225,132,184,180,83,72,57,2,109,40,101,58,153,228,168,
18,229,24,230,162,72,110,222,249,141,47,72,172,50,74,184,
201,173,210,231,12,128,203,46,43,191,115,184,128,212,191,3
];

  for (j= 0; j < 63; j++)                  // fill video memory
    vm[j]= 0;

  wr= write_text_mode;

  for (j= m.length; j < 65536; j++)        // fill memory
    m[j]= 0;
  for (j= 0xB8000; j < 0xB8FA0; j++)        // fill video memory
    m[j]= 0;//(j*1337)&255;

//alert(m[0x100]);

  tab= document.getElementById('table').getContext('2d');
  tab.drawImage(document.getElementById('tab'), 0, 0);

//  for (o= 0; o< 4000; o++)
//    drawbyte(o, Math.random()*256);


  document.onkeydown= kdown;          // key event handling
  document.onkeyup= kup;
  document.onkeypress= kpress;
  document.body.onresize= resize;
  breakpoint= 'pc==0x134';
  interval= setInterval(run, 20);
  self.focus();
}

function paintRegisters(){
  document.getElementById('reg').innerHTML=
  'ax '+hex(al|ah<<8)+'  c='+(f&1)+'<br/>'+
  'bx '+hex(bx)+'  z='+(f>>6&1)+'<br/>'+
  'cx '+hex(cl|ch<<8)+'  s='+(f>>7&1)+'<br/>'+
  'dx '+hex(dl|dh<<8)+'  o='+(f>>11&1)+'<br/>'+
  'si '+hex(si)+'  p='+(f>>2&1)+'<br/>'+
  'di '+hex(di)+'  a='+(f>>4&1)+'<br/>'+
  'bp '+hex(bp)+'  i='+(fh>>9&1)+'<br/>'+
  'sp '+hex(sp)+'  d='+(fh>>10&1)+'<br/>'+
  'ds '+hex(ds>>4)+'<br/>'+
  'es '+hex(es>>4)+'<br/>'+
  'ss '+hex(ss>>4)+'<br/>'+
  'cs '+hex(cs>>4)+'<br/>'+
  'ip '+hex(pc)+'<br/>';
}

function kdown(evt) {
  if(evt.keyCode==32){
    if(tape)
      interval= setInterval(run, 20);
    else
      clearInterval(interval);
    tape^= 1;
  }
  else if(evt.keyCode==13)
    g[m[cs+pc++]|m[cs+pc++&65535]<<8]();
  else if(evt.keyCode==83)
    breakpoint=prompt('condition'),
    tape= 0,
    interval= setInterval(run, 20);
/*  else if(evt.keyCode==80)
    for (o= 0; o< 4000; o++)
      drawbyte(o, m[o+0xB8000]);*/

  paintScreen();
  if(evt.keyCode>36&&evt.keyCode<41||evt.keyCode==9)
    kb[8]&= (1 << '41302'[(evt.keyCode-9)%9])^255;
  var code= kc[evt.keyCode];
  if (code)
    if(code>256)
      kb[code>>5&7]&= ~code & 31,
      kb[code>>13]&= ~code >> 8 & 31;
    else
      kb[code>>5]&= ~code & 31;
  else if(evt.keyCode==116)
    location.reload();
  else if(evt.keyCode==122)
    return true;
  else if(evt.keyCode==112)
    if (!ft)
      ft= 1,
      document.getElementById('tab').src= 'k',
      document.getElementById('tab').onload= function(){
        this.style.display= 'block';
      }
    else
      ft= -ft,
      document.getElementById('tab').style.display= ft+1 ? 'block' : 'none';
  else if(evt.keyCode==113)
    kc[9]^= 482,
    kc[37]^= 368,
    kc[38]^= 392,
    kc[39]^= 388,
    kc[40]^= 400;
  if (!evt.metaKey)
    return false;
}

function kup(evt) {
  if(evt.keyCode>36&&evt.keyCode<41||evt.keyCode==9)
    kb[8]|= 1 << '41302'[(evt.keyCode-9)%9];
  var code= kc[evt.keyCode];
  if (code)
    if(code>256)
      kb[code>>5&7]|= code & 31,
      kb[code>>13]|= code >> 8 & 31;
    else
      kb[code>>5]|= code & 31;
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
  j= 255;
  if (!(addr & 224))                    // read kempston
    j^= kb[8];
  else if (~addr & 1)                   // read keyboard
    for (k= 8; k < 16; k++)
      if (~addr & 1 << k)            // scan row
        j&= kb[k-8];
  return j;
}

function wp(addr, val) {                // write port, only border color emulation
  if (~addr & 1)
    document.body.style.backgroundColor= '#'+pal.substr(3*(val&7), 3);
}

function write_text_mode(addr) {
  if (addr<0xb8000)
    return addr;
  else if (addr>0xb8f9f)
    return addr;
//console.log('esc '+addr);
  vm[(addr-0xb8000)>>6]|= 1<<((addr-0xb8000&63)>>1);
  return addr;
}

function paintScreen() {
  paintRegisters();
  for (i= 0; i < 63; i++){
    j= vm[i];
     console.log(j);
    vm[i]= 0;
    k= 32;
    while (k-- && j){
      if(j<0){
        var addr= i<<6|k<<1
          , val= m[addr+0xB8000]
          , bk= m[addr+0xB8001]
          , elm= tab.getImageData((val&31)*9, val>>1&112, 9, 16)
          , fr= bk&15;
//        console.log(addr,val,bk);

        bk>>= 4;
        for(o= 0; o<16*9*4; o++)
          if(elm.data[o])
            elm.data[o++]= pal[bk][0],
            elm.data[o++]= pal[bk][1],
            elm.data[o++]= pal[bk][2];
          else
            elm.data[o++]= pal[fr][0],
            elm.data[o++]= pal[fr][1],
            elm.data[o++]= pal[fr][2];
        ct.putImageData(elm, (addr>>1)%80*9, addr/160<<4);
      }
      j<<=1;
    }
  }
}

function drawbyte(addr, val) {
//  console.log(addr,val);
  if(addr&1)
    val= val;
  else{
    var elm= tab.getImageData((val&31)*9, val>>1&112, 9, 16)
      , bk= m[addr+0xB8001]
      , fr= bk&15;
    bk>>= 4;
    for(i= 0; i<16*9*4; i++)
      if(elm.data[i])
        elm.data[i++]= pal[bk][0],
        elm.data[i++]= pal[bk][1],
        elm.data[i++]= pal[bk][2];
      else
        elm.data[i++]= pal[fr][0],
        elm.data[i++]= pal[fr][1],
        elm.data[i++]= pal[fr][2];
    ct.putImageData(elm, (addr>>1)%80*9, addr/160<<4);
  }
}

