function paintNormal(){
  t= -1;
  if( scrl & 136 ){
    while( ++t < 0x300 )
      for ( col= m[t+0x5800]
          , bk= pal[col    & 7
                  | col>>3 & 8]
          , fo= pal[col>>3 & 15]
          , o=  ( t>>5 << 13 | t<<5 & 0x3ff )
              - ( scrl << 6 & 7168 )
              - ( scrl << 2 & 28 )
          , u=  0x4000
              | t    & 0xff 
              | t<<3 & 0x1800
          ; ! ( 0x1800
              & ( u ^ t<<3 )
              )
          ; u+= 0x100
          , o+= 0x400){
        k= col>>7 & flash>>4
            ? ~m[u]
            : m[u];
        if( k&128 )
          eld[o  ]= bk[0],
          eld[o+1]= bk[1],
          eld[o+2]= bk[2];
        else
          eld[o  ]= fo[0],
          eld[o+1]= fo[1],
          eld[o+2]= fo[2];
        if( k&64 )
          eld[o+4]= bk[0],
          eld[o+5]= bk[1],
          eld[o+6]= bk[2];
        else
          eld[o+4]= fo[0],
          eld[o+5]= fo[1],
          eld[o+6]= fo[2];
        if( k&32 )
          eld[o+8 ]= bk[0],
          eld[o+9 ]= bk[1],
          eld[o+10]= bk[2];
        else
          eld[o+8 ]= fo[0],
          eld[o+9 ]= fo[1],
          eld[o+10]= fo[2];
        if( k&16 )
          eld[o+12]= bk[0],
          eld[o+13]= bk[1],
          eld[o+14]= bk[2];
        else
          eld[o+12]= fo[0],
          eld[o+13]= fo[1],
          eld[o+14]= fo[2];
        if( k&8 )
          eld[o+16]= bk[0],
          eld[o+17]= bk[1],
          eld[o+18]= bk[2];
        else
          eld[o+16]= fo[0],
          eld[o+17]= fo[1],
          eld[o+18]= fo[2];
        if( k&4 )
          eld[o+20]= bk[0],
          eld[o+21]= bk[1],
          eld[o+22]= bk[2];
        else
          eld[o+20]= fo[0],
          eld[o+21]= fo[1],
          eld[o+22]= fo[2];
        if( k&2 )
          eld[o+24]= bk[0],
          eld[o+25]= bk[1],
          eld[o+26]= bk[2];
        else
          eld[o+24]= fo[0],
          eld[o+25]= fo[1],
          eld[o+26]= fo[2];
        if( k&1 )
          eld[o+28]= bk[0],
          eld[o+29]= bk[1],
          eld[o+30]= bk[2];
        else
          eld[o+28]= fo[0],
          eld[o+29]= fo[1],
          eld[o+30]= fo[2];
      }
    bk= pal[bor&7];
    if( scrl & 128 )
      for ( o= 0x2e000
          ; o < 0x30000
          ; o+=4 )
        eld[o]= bk[0],
        eld[o+1]= bk[1],
        eld[o+2]= bk[2];
    if( scrl & 8 )
      for ( t= 0
          , o= -32
          ; t < 192
          ; o+= 0x3e0
          , t++ )
        for ( v= 0; v<8; v++, o+=4 )
          eld[o+1024]= bk[0],
          eld[o+1025]= bk[1],
          eld[o+1026]= bk[2];
  }
  else
    while( ++t < 0x300 )
      for ( col= m[t+0x5800]
          , bk= pal[col    & 7
                  | col>>3 & 8]
          , fo= pal[col>>3 & 15]
          , o=  t>>5 << 13 
              | t<<5 & 0x3ff
          , u=  0x4000
              | t    & 0xff 
              | t<<3 & 0x1800
          ; ! ( 0x1800
              & ( u ^ t<<3 )
              )
          ; u+= 0x100
          , o+= 0x400){
        k= col>>7 & flash>>4
            ? ~m[u]
            : m[u];
        if( k&128 )
          eld[o  ]= bk[0],
          eld[o+1]= bk[1],
          eld[o+2]= bk[2];
        else
          eld[o  ]= fo[0],
          eld[o+1]= fo[1],
          eld[o+2]= fo[2];
        if( k&64 )
          eld[o+4]= bk[0],
          eld[o+5]= bk[1],
          eld[o+6]= bk[2];
        else
          eld[o+4]= fo[0],
          eld[o+5]= fo[1],
          eld[o+6]= fo[2];
        if( k&32 )
          eld[o+8 ]= bk[0],
          eld[o+9 ]= bk[1],
          eld[o+10]= bk[2];
        else
          eld[o+8 ]= fo[0],
          eld[o+9 ]= fo[1],
          eld[o+10]= fo[2];
        if( k&16 )
          eld[o+12]= bk[0],
          eld[o+13]= bk[1],
          eld[o+14]= bk[2];
        else
          eld[o+12]= fo[0],
          eld[o+13]= fo[1],
          eld[o+14]= fo[2];
        if( k&8 )
          eld[o+16]= bk[0],
          eld[o+17]= bk[1],
          eld[o+18]= bk[2];
        else
          eld[o+16]= fo[0],
          eld[o+17]= fo[1],
          eld[o+18]= fo[2];
        if( k&4 )
          eld[o+20]= bk[0],
          eld[o+21]= bk[1],
          eld[o+22]= bk[2];
        else
          eld[o+20]= fo[0],
          eld[o+21]= fo[1],
          eld[o+22]= fo[2];
        if( k&2 )
          eld[o+24]= bk[0],
          eld[o+25]= bk[1],
          eld[o+26]= bk[2];
        else
          eld[o+24]= fo[0],
          eld[o+25]= fo[1],
          eld[o+26]= fo[2];
        if( k&1 )
          eld[o+28]= bk[0],
          eld[o+29]= bk[1],
          eld[o+30]= bk[2];
        else
          eld[o+28]= fo[0],
          eld[o+29]= fo[1],
          eld[o+30]= fo[2];
      }
  ct.putImageData(elm, 0, 0);
}

function paintUlap(){
  t= -1;
  while( ++t < 0x300 )
    for ( col= m[t+0x5800]
        , bk= ulap[col>>2 & 0x30 | col & 7]
        , fo= ulap[col>>2 & 0x30 | col>>3 & 7 | 8]
        , o=  t>>5 << 13 
            | t<<5 & 0x3ff
        , u=  0x4000
            | t    & 0xff 
            | t<<3 & 0x1800
        ; ! ( 0x1800
            & ( u ^ t<<3 )
            )
        ; u+= 0x100
        , o+= 0x400){
      k= m[u];
      if( k&128 )
        eld[o  ]= bk[0],
        eld[o+1]= bk[1],
        eld[o+2]= bk[2];
      else
        eld[o  ]= fo[0],
        eld[o+1]= fo[1],
        eld[o+2]= fo[2];
      if( k&64 )
        eld[o+4]= bk[0],
        eld[o+5]= bk[1],
        eld[o+6]= bk[2];
      else
        eld[o+4]= fo[0],
        eld[o+5]= fo[1],
        eld[o+6]= fo[2];
      if( k&32 )
        eld[o+8 ]= bk[0],
        eld[o+9 ]= bk[1],
        eld[o+10]= bk[2];
      else
        eld[o+8 ]= fo[0],
        eld[o+9 ]= fo[1],
        eld[o+10]= fo[2];
      if( k&16 )
        eld[o+12]= bk[0],
        eld[o+13]= bk[1],
        eld[o+14]= bk[2];
      else
        eld[o+12]= fo[0],
        eld[o+13]= fo[1],
        eld[o+14]= fo[2];
      if( k&8 )
        eld[o+16]= bk[0],
        eld[o+17]= bk[1],
        eld[o+18]= bk[2];
      else
        eld[o+16]= fo[0],
        eld[o+17]= fo[1],
        eld[o+18]= fo[2];
      if( k&4 )
        eld[o+20]= bk[0],
        eld[o+21]= bk[1],
        eld[o+22]= bk[2];
      else
        eld[o+20]= fo[0],
        eld[o+21]= fo[1],
        eld[o+22]= fo[2];
      if( k&2 )
        eld[o+24]= bk[0],
        eld[o+25]= bk[1],
        eld[o+26]= bk[2];
      else
        eld[o+24]= fo[0],
        eld[o+25]= fo[1],
        eld[o+26]= fo[2];
      if( k&1 )
        eld[o+28]= bk[0],
        eld[o+29]= bk[1],
        eld[o+30]= bk[2];
      else
        eld[o+28]= fo[0],
        eld[o+29]= fo[1],
        eld[o+30]= fo[2];
    }
  ct.putImageData(elm, 0, 0);
}

function wp(addr, val) {                // write port, only border color emulation
  if( ~addr & 1 ){
    if( (bor^val) & 0x10 )
      vb[vbp++]= st;
    bor-val && (document.body.style.backgroundColor=  'rgb('
                                                    + ( paintScreen==paintNormal
                                                          ? pal[(bor= val)&7]
                                                          : ulap[8|(bor= val)&7] )
                                                    + ')');
    if( ifra )
      put.style.color= pal[bor&7][0]+pal[bor&7][1]+pal[bor&7][2]<300 ? '#fff' : '#000';
    if( pbt )
      tim.style.color= pal[bor&7][0]+pal[bor&7][1]+pal[bor&7][2]<300 ? '#fff' : '#000';
  }
  else if( addr == 0x7f3b )
    scrl= val;
  else if( addr == 0xbf3b )
    ula= val;
  else if( addr == 0xff3b ){
    if( ula==0x40 )
      paintScreen= val&1 ? paintUlap : paintNormal;
    else if( ula<0x40 )
      ulap[ula]= [parseInt((val>>2 & 7)*255/7), parseInt((val>>5)*255/7), parseInt((val&3)*255/3)],
      ula-8==bor&7 && (document.body.style.backgroundColor= 'rgb('+ulap[ula]+')');
  }
}