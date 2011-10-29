function paintNormal(){
  mix= miy= 32;
  max= may= t= -1;
  if( scrl&7 ){
    while( ++t < 0x300 )
      if( t&0x1f )
        for ( col= scree[t+0x1800]
            , bk= pal[col    & 7
                    | col>>3 & 8]
            , fo= pal[col>>3 & 15]
            , dx= t & 0x1f
            , dy= t>>5
            , o= ( dy << 13 | t<<5 & 0x3ff ) - (scrl<<2)
            , u=  t    & 0xff 
                | t<<3 & 0x1800
            ; ! ( 0x1800
                & ( u ^ t<<3 )
                )
            ; u+= 0x100
            , o+= 0x400)
          if( k=  col>>7
                & flash>>4
                  ? ~scree[u]
                  : scree[u]
            , vm[u] != (col | k<<8) ){
            vm[u]= col | k<<8;
            if(dx-scrl<mix)
              mix= dx-scrl;
            else
              dx>max && (max= dx);
            if(dy < miy)
              miy= dy;
            else
              dy>may && (may= dy);
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
    t= -1;
    o= -scrl*4;
    while( ++t < 0x18 )
      for ( col= scree[t<<5 | 0x1800]
          , bk= pal[col    & 7
                  | col>>3 & 8]
          , fo= pal[col>>3 & 15]
          , col2= scree[t | 0x1b20]
          , bk2= pal[col2    & 7
                   | col2>>3 & 8]
          , fo2= pal[col2>>3 & 15]
          , u=  t<<5 & 0xff 
              | t<<8 & 0x1800
          ; ! ( 0x1800
              & ( u ^ t<<8 )
              )
          ; u+= 0x100
          , o+= 0x3e0)
        if( k=  col>>7
              & flash>>4
                ? ~scree[u]
                : scree[u]
          , vm[u] != (col | k<<8) ){
          vm[u]= col | k<<8;
          mix= 0;
          max= 31;
          if(t < miy)
            miy= t;
          else
            t>may && (may= t);
          for ( v= 0; v<scrl; v++, o+=4 )
            if( k&(128>>v) )
              eld[o+1024]= bk2[0],
              eld[o+1025]= bk2[1],
              eld[o+1026]= bk2[2];
            else
              eld[o+1024]= fo2[0],
              eld[o+1025]= fo2[1],
              eld[o+1026]= fo2[2];
          while( v<8 ){
            if( k&(128>>v) )
              eld[o  ]= bk[0],
              eld[o+1]= bk[1],
              eld[o+2]= bk[2];
            else
              eld[o  ]= fo[0],
              eld[o+1]= fo[1],
              eld[o+2]= fo[2];
            v++;
            o+= 4;
          }
        }
        else
          o+= 32;
  }
  else
    while( ++t < 0x300 )
      for ( col= scree[t+0x1800]
          , bk= pal[col    & 7
                  | col>>3 & 8]
          , fo= pal[col>>3 & 15]
          , dx= t & 0x1f
          , dy= t>>5
          , o=  dy<<13
              | t<<5 & 0x3ff
          , u=  t    & 0xff 
              | t<<3 & 0x1800
          , n=  0
          ; n < 8
          ; u+= 0x100
          , o+= 0x400
          , n++ )
        if( k=  col>>7
              & flash>>4
                ? ~scree[u]
                : scree[u]
          , vm[u] != (col | k<<8) ){
          vm[u]= col | k<<8;
          if(dx<mix)
            mix= dx;
          else
            dx>max && (max= dx);
          if(dy < miy)
            miy= dy;
          else
            dy>may && (may= dy);
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
  may >= miy &&
    ct.putImageData(elm, 0, 0, (mix<<3)-1, (miy<<3)-1, (max-mix<<3)+10, (may-miy<<3)+10);
}

function paintUlap(){
  mix= miy= 32;
  max= may= t= -1;
  while( ++t < 0x300 )
    for ( col= scree[t+0x1800]
        , bk= ulap[col>>2 & 0x30 | col & 7]
        , fo= ulap[col>>2 & 0x30 | col>>3 & 7 | 8]
        , dx= t & 0x1f
        , dy= t>>5
        , o=  dy<<13
            | t<<5 & 0x3ff
        , u=  t    & 0xff 
            | t<<3 & 0x1800
        , n=  0
        ; n < 8
        ; u+= 0x100
        , o+= 0x400
        , n++ )
      if( k= scree[u]
        , vm[u] != (col | k<<8) ){
        vm[u]= col | k<<8;
        if(dx<mix)
          mix= dx;
        else
          dx>max && (max= dx);
        if(dy < miy)
          miy= dy;
        else
          dy>may && (may= dy);
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
  may >= miy &&
    ct.putImageData(elm, 0, 0, (mix<<3)-1, (miy<<3)-1, (max-mix<<3)+10, (may-miy<<3)+10);
}

function doUlap(val){
  ulap[ula]= [parseInt((val>>2 & 7)*255/7), parseInt((val>>5)*255/7), parseInt((val&3)*255/3)];
  ula-8==bor&7 && (document.body.style.backgroundColor= 'rgb('+ulap[ula]+')');
  for (t= 0; t < 0x1800; t++)
    vm[t]= -1;
}

function doScrl(val){
  scrl= val;
  for (t= 0; t < 0x1800; t++)
    vm[t]= -1;
}