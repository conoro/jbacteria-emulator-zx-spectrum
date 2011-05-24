na= 'jBacteriaSe ';
kc= [0,0,0,0,0,0,0,0,      // keyboard codes
    385,  // 8 backspace, 129+256
    482,  // 9 tab (extend), 226+256
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
    2,    // Z (97)
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,3,
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,
    58018,
    58050,
    58088,
    58056,
    58084,
    57872,
    57860,
    0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,
    58032,
    57892,
    58024,
    57992];

function kdown(evt) {
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
    if(ft^= 1)
      clearInterval(interval),
      he.style.display= 'block';
    else
      interval= setInterval(run, 20),
      he.style.display= 'none';
  else if(evt.keyCode==113)
    kc[9]^= 482,
    kc[37]^= 368,
    kc[38]^= 392,
    kc[39]^= 388,
    kc[40]^= 400;
  if(code==1)
    kc[186]= 57858,
    kc[187]= 58052,
    kc[188]= 57928,
    kc[189]= 57985,
    kc[190]= 57936,
    kc[191]= 57864,
    kc[192]= 57889,
    kc[219]= 57896,
    kc[220]= 57890,
    kc[221]= 57904,
    kc[222]= 58017;
  if(code==57858||code==58052||code==57928||code==57985||code==57936||
     code==57864||code==57889||code==57896||code==57890||code==57904||code==58017)
    kb[0]|= 1;
  if (!evt.metaKey)
    return false;
}

function kup(evt) {
  if(evt.keyCode>36&&evt.keyCode<41||evt.keyCode==9)
    kb[8]|= 1 << '41302'[(evt.keyCode-9)%9];
  var code= kc[evt.keyCode];
  if(code==1)
    kc[186]= 58018,
    kc[187]= 58050,
    kc[188]= 58088,
    kc[189]= 58056,
    kc[190]= 58084,
    kc[191]= 57872,
    kc[192]= 57860,
    kc[219]= 58032,
    kc[220]= 57892,
    kc[221]= 58024,
    kc[222]= 57992;
  if (code)
    if(code>256)
      kb[code>>5&7]|= code & 31,
      kb[code>>13]|= code >> 8 & 31;
    else
      kb[code>>5]|= code & 31;
  if (!evt.metaKey)
    return false;
}