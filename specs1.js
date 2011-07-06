function paintScreen(){
  t= -1;
  while( t++ < 0x2ff )
    for ( col= m[t+0x5800]
        , bk= pal[col    & 7
                | col>>3 & 8]
        , fr= pal[col>>3 & 15]
        , o=  t>>5 << 13 
            | t<<5 & 0x3ff
        , u=  0x4000
            | t    & 0xff 
            | t<<3 & 0x1800
        ; ! ( 0x1800
            & ( u ^ t<<3 )
            )
        ; u+= 0x100
        , o+= 0x400 )
      if( k=  col>>7
            & flash>>4
              ? ~m[u]
              : m[u]
        , vm[u] != (col | k<<8) ){
        vm[u]= col | k<<8;
        if( k&128 )
          eld[o  ]= bk[0],
          eld[o+1]= bk[1],
          eld[o+2]= bk[2];
        else
          eld[o  ]= fr[0],
          eld[o+1]= fr[1],
          eld[o+2]= fr[2];
        if( k&64 )
          eld[o+4]= bk[0],
          eld[o+5]= bk[1],
          eld[o+6]= bk[2];
        else
          eld[o+4]= fr[0],
          eld[o+5]= fr[1],
          eld[o+6]= fr[2];
        if( k&32 )
          eld[o+8 ]= bk[0],
          eld[o+9 ]= bk[1],
          eld[o+10]= bk[2];
        else
          eld[o+8 ]= fr[0],
          eld[o+9 ]= fr[1],
          eld[o+10]= fr[2];
        if( k&16 )
          eld[o+12]= bk[0],
          eld[o+13]= bk[1],
          eld[o+14]= bk[2];
        else
          eld[o+12]= fr[0],
          eld[o+13]= fr[1],
          eld[o+14]= fr[2];
        if( k&8 )
          eld[o+16]= bk[0],
          eld[o+17]= bk[1],
          eld[o+18]= bk[2];
        else
          eld[o+16]= fr[0],
          eld[o+17]= fr[1],
          eld[o+18]= fr[2];
        if( k&4 )
          eld[o+20]= bk[0],
          eld[o+21]= bk[1],
          eld[o+22]= bk[2];
        else
          eld[o+20]= fr[0],
          eld[o+21]= fr[1],
          eld[o+22]= fr[2];
        if( k&2 )
          eld[o+24]= bk[0],
          eld[o+25]= bk[1],
          eld[o+26]= bk[2];
        else
          eld[o+24]= fr[0],
          eld[o+25]= fr[1],
          eld[o+26]= fr[2];
        if( k&1 )
          eld[o+28]= bk[0],
          eld[o+29]= bk[1],
          eld[o+30]= bk[2];
        else
          eld[o+28]= fr[0],
          eld[o+29]= fr[1],
          eld[o+30]= fr[2];
      }
  ct.putImageData(elm, 0, 0);
}