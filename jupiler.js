na= 'jupiler ';
m= bytes(0x10000);
vm= bytes(0x380);
vb= [];
data= [];
kb= [0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff]; // keyboard state
ks= [0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff]; // keyboard state
kc= [0,0,0,0,0,0,0,0,      // keyboard codes
    0x05<<7|0x25, // 8 backspace
    0,            // 9 tab (graph)
    0,0,0,
    0x35,         // 13 enter 
    0,0,
    0x05,         // 16 caps
    0x04,         // 17 sym
    0,0,0,0,0,0,0,0,0,
    0x05<<7|0x1d, // 27 esc (edit)
    0,0,0,0,
    0x3d,         // 32 space
    0,0,0,0,
    0,            // cursor left
    0,            // cursor up
    0,            // cursor right
    0,            // cursor down
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
    0x3a,         // B
    0x01,         // C
    0x0b,         // D
    0x13,         // E
    0x0a,         // F
    0x09,         // G
    0x31,         // H
    0x2b,         // I
    0x32,         // J
    0x33,         // K
    0x34,         // L
    0x3c,         // M
    0x3b,         // N
    0x2c,         // O
    0x2d,         // P
    0x15,         // Q
    0x12,         // R
    0x0c,         // S
    0x11,         // T
    0x2a,         // U
    0x39,         // V
    0x14,         // W
    0x02,         // X
    0x29,         // Y
    0x03];        // Z (97)
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
/*function cond(){
 if (pc==0x1aa7) console.log(m[l|h<<8],m[e|d<<8]);
}*/
function run() {
  while( st < 64896 )                       // execute z80 instructions during a frame
    r++,
//cond(),
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
  st-= 64896;
  z80interrupt();
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
  if( localStorage.ft & 16 )
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
  if( localStorage.ft & 16 ){
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
    case 'ace':
      var reader= new FileReader();
      reader.onloadend = function(ev) {
        o= ev.target.result;
        if(rm(o))
          return alert('Invalid ACE file');
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
      pressF2();
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
      localStorage.save= wm();
      break;
    case 115: // F4
      if( pbt ){
        if( trein==32000 )
          clearInterval(interval);
        else
          node.onaudioprocess= audioprocess0;
        ajax('snaps/'+params.slice(0,-3)+'ace', -1);
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
        ajax('rec_ace.php', t);
        document.documentElement.innerHTML= 'Please wait...';
      }
      break;
    case 118: // F7
      paintScreen= paintScreen==paintNormal ? paintBascolace : paintNormal;
      localStorage.ft^= 8;
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
      u= new Uint8Array(o.length);
      for ( j=0; j<o.length; j++ )
        u[j]= o.charCodeAt(j);
      URL= window.URL || window.webkitURL;
      ir.src= URL.createObjectURL(new Blob([u], {type: 'application/x.cantab.ace'}));
      alert('Snapshot saved.\nRename the file (without extension) to .ACE.');
      self.focus();
      break;
    case 122: // F11
      return 1;
    case 123: // F12
      alert('Sound '+ ( (localStorage.ft^= 16) & 16
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
      kb[code>>3 & 15]|=  0x20 >> (code     & 7),
      kb[code>>10]|=      0x20 >> (code>>7  & 7);
    else
      kb[code>>3]|=       0x20 >> (code     & 7);
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

function rp(addr) {
  j= 0xff;
  if( ~addr & 2 )                    // read Boldfield Joystick
    j^= ks[8];
  if( ~addr & 1 ){                   // read keyboard
    if ( !bor )
      bor= 1,
      vb[vbp++]= st;
    j= 0xbf;
    for ( k= 8
        ; k < 16
        ; k++ )
      if( ~addr & 1<<k )            // scan row
        j&= ks[k-8];
  }
  return j;
}

function rm(o) {
  if( o.charCodeAt(0)!=1 &&
      o.charCodeAt(0)!=0x80 )
    return 1;
  j= 0;
  t= 0x2000;
  while( j<o.length ){
    if( o.charCodeAt(j)==0xed ){
      w= o.charCodeAt(j+1);
      j+= 3;
      while( w-- )
        m[t++]= o.charCodeAt(j-1);
    }
    else
      m[t++]= o.charCodeAt(j++);
  }
  j= 0x2100;
  setf(m[j++]);
  a= m[j++];
  j+= 2;
  c= m[j++];
  b= m[j++];
  j+= 2;
  e= m[j++];
  d= m[j++];
  j+= 2;
  l= m[j++];
  h= m[j++];
  j+= 2;
  xl= m[j++];
  xh= m[j++];
  j+= 2;
  yl= m[j++];
  yh= m[j++];
  j+= 2;
  sp= m[j++] | m[j++]<<8;
  j+= 2;
  pc= m[j++] | m[j++]<<8;
  j+= 2;
  setf_(m[j++]);
  a_= m[j++];
  j+= 2;
  c_= m[j++];
  b_= m[j++];
  j+= 2;
  e_= m[j++];
  d_= m[j++];
  j+= 2;
  l_= m[j++];
  h_= m[j++];
  j+= 2;
  im= m[j];
  iff= m[j+4];
  i= m[j+12];
  r7= r= m[j+16];
  for ( j= 0x2400; j<0x2800; j++ )
    wb( j, m[j] );
  for ( j= 0x2c00; j<0x3000; j++ )
    wb( j, m[j] );
  for ( j= 0x3c00; j<0x4000; j++ )
    wb( j, m[j] );
  for ( t= 0x300; t < 0x380; t++ )
    vm[t]= 1;
}

function wm() {
  t= String.fromCharCode( 1, 128 );
  for ( j= 0; j < 127; j++ )
    t+= String.fromCharCode(0);
  t+= String.fromCharCode(128,0,0,0,0,0,0,0,0,0,0,3,0,0,0,3,0,0,0,0xf7,0xfd);
  for ( j= 0; j < 106; j++ )
    t+= String.fromCharCode(0);
  t+= String.fromCharCode(f(),a,0,0,c,b,0,0,e,d,0,0,l,h,0,0,xl,xh,0,0,yl,yh,0,0,sp&255,sp>>8,
                          0,0,pc&255,pc>>8,0,0,f_(),a_,0,0,c_,b_,0,0,e_,d_,0,0,l_,h_,0,0,im,
                          0,0,0,iff,0,0,0,0,0,0,0,i,0,0,0,r&128|r7&127,0,0,0,128);
  for ( j= 0; j < 699; j++ )
    t+= String.fromCharCode(0);
  for ( j= 0x2400; j < 0x2800; j++ )
    t+= String.fromCharCode(m[j]);
  for ( j= 0; j < 0x400; j++)
    t+= String.fromCharCode(0);
  for ( j= 0x2c00; j < 0x3000; j++ )
    t+= String.fromCharCode(m[j]);
  for ( j= 0; j < 0xc00; j++)
    t+= String.fromCharCode(0);
  for ( j= 0x3c00; j < 0x10000; j++ )
    t+= String.fromCharCode(m[j]);
  u= v= '';
  w= -1;
  for ( j= 0; j<=t.length; j++ ){
    if( j<t.length && v==t[j] ){
      if( ++w==240 )
        u+= String.fromCharCode(0xed, 240)+v,
        w= 0;
    }
    else{
      if( w>3 )
        u+= String.fromCharCode(0xed, w+1)+v;
      else if( v.charCodeAt(0)==0xed )
        u+= String.fromCharCode(0xed, w+1, 0xed);
      else
        while ( w-- > -1 )
          u+= v;
      w= 0;
    }
    v= t[j];
  }
  return u;
}

function tp(){
  tapei= tapep= t= j= 0;
  if( game.charCodeAt(0)!=26 ){
    rm(game);
    return;
  }
  v= '';
  while( u= game.charCodeAt(t) | game.charCodeAt(t+1)<<8 )
    v+= '<option value="'+t+'">#'+ ++j+
        ( u!=26
          ? ' Data: '+(u-1)+' bytes'
          : ' Prog: '+game.substr(t+3,10).replace(/\0/g, '')
        )+'</option>',
    t+= 2+u;
  if( ie )
    pt.outerHTML= '<select onchange="tapep=this.value;tapei=this.selectedIndex">'+v+'</select>';
  else
    pt.innerHTML= v;
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

function wp(addr, val){
  if( ~addr & 1 && bor )
    bor= 0,
    vb[vbp++]= st;
}
