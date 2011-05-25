na= 'jBacteriaSe ';
kc= [0,0,0,0,0,0,0,0,      // keyboard codes
    0x05<<7|0x25, // 8 backspace
    0x05<<7|0x3c, // 9 tab (extend)
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
    0x05<<7|0x19, // cursor left
    0x05<<7|0x22, // cursor up
    0x05<<7|0x23, // cursor right
    0x05<<7|0x21, // cursor down
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
    if( ft^= 1 ){
      if( trein==32000 )
        clearInterval(interval);
      else
        node.onaudioprocess= 0;
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
    alert(kc[9]&4
          ? 'Cursors enabled'
          : 'Joystick enabled on Cursors + Tab');
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
    localStorage.savese= wm();
  else if( evt.keyCode==115 )
    rm(localStorage.savese);
  else if( evt.keyCode==119 )
    pc= 0;
  else if( evt.keyCode==121 ){
    o= wm();
    t= new ArrayBuffer(o.length);
    u= new Uint8Array(t, 0);
    for ( j=0; j<o.length; j++ )
      u[j]= o.charCodeAt(j);
    j= new WebKitBlobBuilder(); 
    j.append(t);
    ir.src= webkitURL.createObjectURL(j.getBlob());
    alert('Snapshot saved.\nRename the file (without extension) to SNA');
  }
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