na= 'jBacteria ';
m= bytes(65536);
vm= words(6144);
vb= [];
data= [];
kb= [0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff]; // keyboard state
ks= [0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff]; // keyboard state
kc= [0,0,0,0,0,0,0,0,      // keyboard codes
    0x05<<7|0x25, // 8 backspace
    localStorage.ft >> 3
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
    localStorage.ft >> 3
    ? 0x05<<7|0x19
    : 0x44,       // cursor left
    localStorage.ft >> 3
    ? 0x05<<7|0x22 
    : 0x42,       // cursor up
    localStorage.ft >> 3
    ? 0x05<<7|0x23
    : 0x45,       // cursor right
    localStorage.ft >> 3
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

/*function cond() {
  if( pc==0x9cd4 )
    console.log( 'aaa', (c|b<<8).toString(16), (l|h<<8).toString(16), (e|d<<8).toString(16), (xl|xh<<8).toString(16) );
}*/

function run() {
  while( st < 69888 )                       // execute z80 instructions during a frame
//cond(),
    r++,
    g[m[pc++&0xffff]]();
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
  st-= 69888;
  z80interrupt();
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
  if ( localStorage.ft & 2 )
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
  sp= 0xff4a;
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
    m[j]= emul.charCodeAt(j+62524);
  game && (pc= 0x56c, tp());
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
      node= cts.createJavaScriptNode(1024, 1, 1),
      node.onaudioprocess= audioprocess,
      node.connect(cts.destination);
    else
      interval= setInterval(myrun, 20);
  }
  else{
    if( typeof Audio == 'function'
     && (audioOutput= new Audio())
     && typeof audioOutput.mozSetup == 'function' ){
      try{
        audioOutput.mozSetup(1, 51200);
        myrun= mozrun;
      }
      catch (er){}
      paso= 69888/2048;
      interval= setInterval(myrun, 20);
    }
    else
      interval= setInterval(myrun, 20);
  }
  self.focus();
}

function audioprocess0(e){
  data= e.outputBuffer.getChannelData(0);
  j= 0;
  while( j<1024 )
    data[j++]= 0;
}

function audioprocess(e){
  vbp= play= playp= 0;
  run();
  data= e.outputBuffer.getChannelData(0);
  j= 0;
  if( localStorage.ft & 4 )
    while( j < 1024 ){
      data[j++]= sample;
      play+= paso;
      if( play > vb[playp] && playp<vbp )
        playp++,
        sample^= 1;
    }
  else
    while( j<1024 )
      data[j++]= 0;
}

function mozrun(){
  vbp= play= playp= 0;
  run();
  if( localStorage.ft & 4 ){
    j= 0;
    while( j < 2048 ){
      data[j++]= sample;
      play+= paso;
      if( play > vb[playp] && playp<vbp )
        playp++,
        sample^= 1;
    }
    audioOutput.mozWriteAudio(data);
  }
}

function handleFileSelect(ev) {
  ev.stopPropagation();
  ev.preventDefault();
  switch(ev.dataTransfer.files[0].name.slice(-3).toLowerCase()){
    case 'sna':
      if( ev.dataTransfer.files[0].size != 0xc01b )
        return alert('Invalid SNA file');
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        o= ev.target.result;
        j= 0;
        i= o.charCodeAt(j++);
        l_= o.charCodeAt(j++);
        h_= o.charCodeAt(j++);
        e_= o.charCodeAt(j++);
        d_= o.charCodeAt(j++);
        c_= o.charCodeAt(j++);
        b_= o.charCodeAt(j++);
        setf(o.charCodeAt(j++));
        a= o.charCodeAt(j++);
        o08();
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
        setf(o.charCodeAt(j++));
        a= o.charCodeAt(j++);
        sp= o.charCodeAt(j++) | o.charCodeAt(j++)<<8;
        im= o.charCodeAt(j++);
        wp(0,o.charCodeAt(j++));
        while( j < 0xc01b )
          m[j+0x3fe5]= o.charCodeAt(j++);
        g[0xc9]();
      }
      reader.readAsBinaryString(ev.dataTransfer.files[0]);
      break;
    case 'z80':
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        o= ev.target.result;
        if(rm(o))
          return alert('Invalid Z80 file');
      }
      reader.readAsBinaryString(ev.dataTransfer.files[0]);
      break;
    default:
      return alert(ev.dataTransfer.files[0].name+' has an invalid extension');
    case 'tap':
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        game= ev.target.result;
        tp();
      }
      reader.readAsBinaryString(ev.dataTransfer.files[0]);
  }
}

function handleDragOver(ev) {
  ev.stopPropagation();
  ev.preventDefault();
}

function pushk( value ){
  kb[value>>3]&= ~(0x20 >> (value & 7));
  if( localStorage.ft&8 ){
    value=  20+10*2000
          + ((value&32?0:3)^(value>>3&3))*2000*50
          + (value&32?4+(value&7):5-value&7)*200;
    for ( t= 0; t<30; ++t ){
      for ( u= 0; u<39; ++u, value+= 4 )
        if( kld[value]== 104 )
          kld[value]= kld[value+1]= 0;
      value+= 1844;
    }
    kct.putImageData(klm, 0, 0);
  }
}

function popk( value ){
  kb[value>>3]|= 0x20 >> (value & 7);
  if( localStorage.ft&8 ){
    value=  20+10*2000
          + ((value&32?0:3)^(value>>3&3))*2000*50
          + (value&32?4+(value&7):5-value&7)*200;
    for ( t= 0; t<30; ++t ){
      for ( u= 0; u<39; ++u, value+= 4 )
        if( kld[value+2]== 104 )
          kld[value]= kld[value+1]= 104;
      value+= 1844;
    }
    kct.putImageData(klm, 0, 0);
  }
}

function kdown(ev) {
  var code= kc[ev.keyCode];
  if( code )
    if( code>0x7f )
      pushk( code&0x7f ),
      pushk( code>>7 );
    else
      pushk( code );
  switch( ev.keyCode ){
    case 112: // F1
      if( f1= ~f1 ){
        if( trein==32000 )
          clearInterval(interval);
        else
          node.onaudioprocess= audioprocess0;
        dv.style.display= 'block';
      }
      else{
        if( trein==32000 )
          interval= setInterval(myrun, 20);
        else
          node.onaudioprocess= audioprocess;
        dv.style.display= 'none';
      }
      break;
    case 113: // F2
      localStorage.ft= localStorage.ft&0x67 | (((localStorage.ft>>3&3)+1)%3)<<3;
      if( localStorage.ft&16 ){
        console.log('joys');
        he.style.display= 'block';
      }
      else if( localStorage.ft&8 ){
        console.log('keyb');
        he.style.display= 'block';
      }
      else{
        console.log('none');
        he.style.display= 'none';
      }
      console.log(localStorage.ft>>3&3);
/*      kc[9]^=  0x41^(0x05<<7 | 0x3c);
      kc[37]^= 0x44^(0x05<<7 | 0x19);
      kc[38]^= 0x42^(0x05<<7 | 0x22);
      kc[39]^= 0x45^(0x05<<7 | 0x23);
      kc[40]^= 0x43^(0x05<<7 | 0x21);
      alert((localStorage.ft^= 2) & 2
            ? 'Cursors enabled'
            : 'Joystick enabled on Cursors + Tab');
      self.focus();*/
      break;
    case 114: // F3
      pbt && (
        pbt= 0,
        tim.innerHTML= '',
        frc= (pb[pbc]&255)-frc);
//      frcs= frc;
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
//        frc= frcs,
        frc= localStorage.save.charCodeAt(85),
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
        ajax('rec.php', t, 3);
        document.documentElement.innerHTML= 'Please wait...';
      }
      break;
    case 118: // F7
      localStorage.ft^= 2;
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
      t= new ArrayBuffer(o.length);
      u= new Uint8Array(t, 0);
      for ( j=0; j<o.length; j++ )
        u[j]= o.charCodeAt(j);
      j= new WebKitBlobBuilder(); 
      j.append(t);
      ir.src= webkitURL.createObjectURL(j.getBlob());
      alert('Snapshot saved.\nRename the file (without extension) to .Z80.');
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
  if( code )
    if( code>0x7f )
      popk( code&0x7f ),
      popk( code>>7 );
    else
      popk( code );
  if( !ev.metaKey )
    return false;
}

function kpress(ev) {
  if( ev.keyCode==116 || ev.keyCode==122 )
    return 1;
  if( !ev.metaKey )
    return false;
}

function onresize(ev) {
  ratio= innerWidth / innerHeight;
  if( ratio>1.33 )
    cv.style.height= (height= innerHeight - 50) + 'px',
    cv.style.width= (width= parseInt(tmp= height*1.33)) + 'px',
    cv.style.marginTop= (marginTop= 25) + 'px',
    cv.style.marginLeft= (marginLeft= innerWidth-tmp >> 1) + 'px';
  else
    cv.style.width= (width= innerWidth - 50) + 'px',
    cv.style.height= (height= parseInt(width/1.33)) + 'px',
    cv.style.marginLeft= (marginLeft= 25) + 'px',
    cv.style.marginTop= (marginTop= 25) + 'px';
  he.style.width= cv.style.width;
  he.style.height= (0.4*height) + 'px';
  he.style.top= (innerHeight-25-0.4833*height) + 'px';
  dv.style.left= he.style.left= cv.style.marginLeft;
  dv.style.top= cv.style.marginTop;
}

function rp(addr) {
  j= 0xff;
  if( !(addr & 0xe0) )                    // read kempston
    j^= ks[8];
  else if( ~addr & 1 ){                   // read keyboard
    j= 0xbf;
    for ( k= 8
        ; k < 16
        ; k++ )
      if( ~addr & 1<<k )            // scan row
        j&= ks[k-8];
  }
  else if( (addr&0xff) == 0x3f )
    j&= sdin();
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

function wb(addr, val) {
  if( addr > 0x3fff )
    m[addr]= val;
}

function rm(o) {
  if(o.charCodeAt(6)|o.charCodeAt(7) ||
     o.charCodeAt(12)==255 ||
     o.charCodeAt(30)!=55 ||
     o.charCodeAt(34))
    return 1;
  j= 0;
  a= o.charCodeAt(j++);
  setf(o.charCodeAt(j++));
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
  o08();
  setf(o.charCodeAt(j++));
  o08();
  yl= o.charCodeAt(j++);
  yh= o.charCodeAt(j++);
  xl= o.charCodeAt(j++);
  xh= o.charCodeAt(j++);
  iff= o.charCodeAt(j++);
  im= o.charCodeAt(j+1)&3;
  u= o.charCodeAt(30);
  if( u>23 ){
    pc= o.charCodeAt(j+4) | o.charCodeAt(j+5)<<8;
    for (v= 0; v < 10; v++ )
      ks[v]= o.charCodeAt(v+75);
  }
  else
    pc= o.charCodeAt(6) | o.charCodeAt(7)<<8;
  j+= u+4;
  while( j<o.length ){
    t= o.charCodeAt(j++)|o.charCodeAt(j++)<<8;
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

function wm() {
  u= String.fromCharCode(a,f(),c,b,l,h,0,0,sp&255,sp>>8,i,r,r7>>7|bor<<1,e,d,
                         c_,b_,e_,d_,l_,h_,a_);
  o08();
  u+= String.fromCharCode(f(),yl,yh,xl,xh,iff,iff,im,55,0,pc&255,pc>>8);
  o08();
  for (j= 0; j < 41; j++)
    u+= String.fromCharCode(0);
  for (j= 0; j < 10; j++ )
    u+= String.fromCharCode(ks[j]);
  u+= String.fromCharCode(frc, 0);
  for (t= 1; t< 4; t++)
    for (j= 0, u+= String.fromCharCode(255,255,'845'[t-1]); j < 0x4000; j++)
      u+= String.fromCharCode(m[j|t<<14]);
  return u;
}

function tp(){
  tapei= tapep= t= j= 0;
  if( game.charCodeAt(0)!=19 ){
    rm(game);
    return;
  }
  v= '';
  while( u= game.charCodeAt(t) | game.charCodeAt(t+1)<<8 )
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
  o= game.charCodeAt(tapep++) | game.charCodeAt(tapep++)<<8;
  tapei++;
  tapep++;
  for ( j= 0
      ; j < o-2
      ; j++ )
    wb(xl | xh << 8, game.charCodeAt(tapep++)),
    g[0x123]();
  setf(0x6d);
  o08();
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
                                            : ulap[8|bor&7] )
                                      + ')';
}

function rt(f){
  rm(f);
  pbcs= pbc= pbt;
  frc= f.charCodeAt(85);
  f3++;
  localStorage.save= wm();
  tim.innerHTML= '';
  pbt= 0;
  if( trein==32000 )
    interval= setInterval(myrun, 20);
  else
    node.onaudioprocess= audioprocess;
}