m= [];         // memory
kc= [0,0,0,0,0,0,0,0,
    5|2<<3,    // 8 backspace, same as cursor left
    0|8<<3,    // 9 tab @
    0,0,0,
    0|2<<3,    // 13 enter 
    0,0,
    0|1<<3,    // 16 shift
    2|2<<3,    // 17 control (break)
    0,0,0,0,0,0,0,0,0,
    1|2<<3,    // 27 esc (clear)
    0,0,0,0,
    7|2<<3,    // 32 space
    0,0,0,0,
    5|2<<3,    // cursor left
    3|2<<3,    // cursor up
    6|2<<3,    // cursor right
    4|2<<3,    // cursor down
    0,0,0,0,0,0,0,
    0|4<<3,    // 0 (48)
    1|4<<3,    // 1
    2|4<<3,    // 2
    3|4<<3,    // 3
    4|4<<3,    // 4
    5|4<<3,    // 5
    6|4<<3,    // 6
    7|4<<3,    // 7
    0|3<<3,    // 8
    1|3<<3,    // 9
    0,0,0,0,0,0,0,
    1|8<<3,    // A (65)
    2|8<<3,    // B
    3|8<<3,    // C
    4|8<<3,    // D
    5|8<<3,    // E
    6|8<<3,    // F
    7|8<<3,    // G
    0|7<<3,    // H
    1|7<<3,    // I
    2|7<<3,    // J
    3|7<<3,    // K
    4|7<<3,    // L
    5|7<<3,    // M
    6|7<<3,    // N
    7|7<<3,    // O
    0|6<<3,    // P
    1|6<<3,    // Q
    2|6<<3,    // R
    3|6<<3,    // S
    4|6<<3,    // T
    5|6<<3,    // U
    6|6<<3,    // V
    7|6<<3,    // W
    0|5<<3,    // X
    1|5<<3,    // Y
    2|5<<3,    // Z (90)
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
    3|3<<3,    // 186 ;
    5|3<<3,    // 187 - qwerty -
    4|3<<3,    // 188 ,
    2|3<<3,    // 189 : qwerty =
    6|3<<3,    // 190 .
    7|3<<3,    // 191 /
    0,0,0,0,0,0,0,0,     // 192
    0,0,0,0,0,0,0,0,0,0, // 200
    0,0,0,0,0,0,0,0,0,   // 210
    2|3<<3,    // 219 : dvorak [
    0,         // 220
    5|3<<3];   // 221 - dvorak ]

function run() {
  while(st < 67584)                       // execute z80 instructions during a frame
    r++,
    g[m[pc++]]();
  if ( !(++flash & 15) )
    titul(),
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
  a= b= c= d= e= h= l= xl=xh=fa= fb= fr= ff= r7=i= sp=
  a_=b_=c_=d_=e_=h_=l_=yl=yh=fa_=fb_=fr_=ff_=r= im=pc= iff= halted= t= u= 0;
  if( ifra ){
    put= document.createElement('div');
    put.style.color= '#888';
    put.style.width= '40px';
    put.style.textAlign= 'right';
    document.body.appendChild(put);
    titul= function(){
      put.innerHTML= parseInt(52800/((nt= new Date().getTime())-time))+'%';
    }
  }
  else{
    put= top==self ? document : parent.document;
    titul= function(){
      put.title= 'jTandyIII '+parseInt(52800/((nt= new Date().getTime())-time))+'%';
    }
  }
  while( t < 0x60000 )
    eld[t++]= 0xff;
  for ( j= 0
      ; j < 0x10000
      ; j++ )        // fill memory
    m[j]= j < 0x3800
          ? emul.charCodeAt(j+0xc00c) & 0xff
          : ( j < 0x4000
              ? 0
              : 0x76 );
  if( game )
    loadFile();
  document.ondragover= handleDragOver;
  document.ondrop= handleFileSelect;
  document.onkeydown= kdown;
  document.onkeyup= kup;
  document.onkeypress= kpress;
  document.onresize= document.body.onresize= onresize;
  interval= setInterval(run, 33);
  self.focus();
}

function handleFileSelect(evt) {
  evt.stopPropagation();
  evt.preventDefault();
  switch(evt.dataTransfer.files[0].name.slice(-3).toLowerCase()){
    case 'sna':
      if( evt.dataTransfer.files[0].size != 0xc500 )
        return alert('Invalid SNA file');
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        o= ev.target.result;
        rm(o);
      }
      reader.readAsBinaryString(evt.dataTransfer.files[0]);
      break;
    default:
      return alert(evt.dataTransfer.files[0].name+' has an invalid extension');
    case 'cmd':
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        game= ev.target.result;
        loadFile();
      }
      reader.readAsBinaryString(evt.dataTransfer.files[0]);
  }
}

function handleDragOver(evt) {
  evt.stopPropagation();
  evt.preventDefault();
}

function loadFile() {
  pc= j= 0;
  run();
  run();
  run();
  run();
  run();
  run();
//  if( (game.charCodeAt(j)&0xff) < 31 ) // CMD file
  while( j < game.length )
    switch( game.charCodeAt(j++) ){
      case 1:
        n= (game.charCodeAt(j++)&0xff)-2;
        n+= n-2 & 0x100;
        r=  game.charCodeAt(j++)    & 0xff
          | game.charCodeAt(j++)<<8 & 0xffff;
        while(n--)
          m[r++]= game.charCodeAt(j++) & 0xff;
        break;
      case 2:
        j++;
        pc=  game.charCodeAt(j++)    & 0xff
           | game.charCodeAt(j++)<<8 & 0xffff;
        j= game.length;
        break;
      default:
        j+= 1+game.charCodeAt(j++) & 0xff;
    }
//  else if( game.charCodeAt(j) < 57 ){
//  }

/*    o= wm();
    t= new ArrayBuffer(o.length);
    u= new Uint8Array(t, 0);
    for ( j=0; j<o.length; j++ )
      u[j]= o.charCodeAt(j);
    j= new WebKitBlobBuilder(); 
    j.append(t);
    ir.src= webkitURL.createObjectURL(j.getBlob());
    alert('Snapshot saved.\nRename the file (without extension) to .SNA.');*/

}

function kdown(evt) {
  if( kc[evt.keyCode] )
    m[0x3800  |  0x100 >> (kc[evt.keyCode]>>3)]|= 1 << (kc[evt.keyCode]&7);
  else if( evt.keyCode==114 )
    localStorage.save= wm();
  else if( evt.keyCode==115 )
    rm(localStorage.save);
  else if( evt.keyCode==116 )
    location.reload();
  else if( evt.keyCode==119 )
    pc= 0;
  else if( evt.keyCode==120 )
    cv.setAttribute('style', 'image-rendering:'+( (ft^= 2) & 2
                                                  ? 'optimizeSpeed'
                                                  : '' )),
    onresize(),
    alert(ft & 2
          ? 'Nearest neighbor scaling'
          : 'Bilinear scaling'),
    self.focus();
  else if( evt.keyCode==122 )
    return 1;
  else if( evt.keyCode==112 )
    if( (ft^= 1) & 1 )
      clearInterval(interval),
      he.style.display= 'block';
    else
      interval= setInterval(run, 33),
      he.style.display= 'none';
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
  }
  if (!evt.metaKey)
    return false;
}

function kup(evt) {
  if( kc[evt.keyCode] )
    m[0x3800  |  0x100 >> (kc[evt.keyCode]>>3)]&= 0xff  ^  1 << (kc[evt.keyCode]&7);
  if (!evt.metaKey)
    return false;
}

function kpress(evt) {
  if( ev.keyCode==116 || ev.keyCode==122 )
    return 1;
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
    case 0xe0: return bIRQ ? 0xfb : 0xff; // status of video IRQ
    case 0xff: return p236 & 0xfc;        // port 0xff gives most of 236
    case 0xec: bIRQ= 0;
    case 0xf8: return 0x30;               // printer is ready!
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

function wm() {
  t= 'TRS80m3 - SNA'+String.fromCharCode(0,0,0,1,f(),a,c,b,e,d,l,h,r,i,iff,0,xl,xh,yl,yh,
     sp&255,sp>>8,pc&255,pc>>8,im,f_(),a_,c_,b_,e_,d_,l_,h_,bIRQ, bIRQe, p236);
  for (j= 0; j < 207; j++)
    t+= String.fromCharCode(0);
  for (j= 0x3c00; j < 0x10000; j++)
    t+= String.fromCharCode(m[j]);
  return t;
}

function rm(o) {
  j= 17;
  setf(o.charCodeAt(j++));
  a= o.charCodeAt(j++);
  c= o.charCodeAt(j++);
  b= o.charCodeAt(j++);
  e= o.charCodeAt(j++);
  d= o.charCodeAt(j++);
  l= o.charCodeAt(j++);
  h= o.charCodeAt(j++);
  r= o.charCodeAt(j++);
  i= o.charCodeAt(j++);
  iff= o.charCodeAt(j++)&1;
  j++;
  xl= o.charCodeAt(j++);
  xh= o.charCodeAt(j++);
  yl= o.charCodeAt(j++);
  yh= o.charCodeAt(j++);
  sp= o.charCodeAt(j++) | o.charCodeAt(j++)<<8;
  pc= o.charCodeAt(j++) | o.charCodeAt(j++)<<8;
  im= o.charCodeAt(j++);
  setf_(o.charCodeAt(j++));
  a_= o.charCodeAt(j++);
  c_= o.charCodeAt(j++);
  b_= o.charCodeAt(j++);
  e_= o.charCodeAt(j++);
  d_= o.charCodeAt(j++);
  l_= o.charCodeAt(j++);
  h_= o.charCodeAt(j++);
  bIRQ= o.charCodeAt(j++);
  bIRQe= o.charCodeAt(j++);
  p236= o.charCodeAt(j++);
  for (j= 0x3c00; j < 0x10000; j++)
    m[j]= o.charCodeAt(j-0x3b00);
}