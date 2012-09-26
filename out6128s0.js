vb= [];
lutc0= [];
lutc1= [];

function init() {
  for (t= 0; t < 256; t++)
    lut0[t]= t>>7&1 | t>>3&4 | t>>2&2 | t<<2&8,
    lut1[t]= t>>6&1 | t>>2&4 | t>>1&2 | t<<3&8;
  for (t= 0; t < 256; t++)
    lutc0[t]= (lut0[t])==0 | ((lut0[t])==1)<<1 | ((lut0[t])==2)<<2 | ((lut0[t])==3)<<3 |
              ((lut0[t])==4)<<4 | ((lut0[t])==5)<<5 | ((lut0[t])==6)<<6 | ((lut0[t])==7)<<7 |
              ((lut0[t])==8)<<8 | ((lut0[t])==9)<<9 | ((lut0[t])==10)<<10 | ((lut0[t])==11)<<11 |
              ((lut0[t])==12)<<12 | ((lut0[t])==13)<<13 | ((lut0[t])==14)<<14 | ((lut0[t])==15)<<15 |
              (lut1[t])==0 | ((lut1[t])==1)<<1 | ((lut1[t])==2)<<2 | ((lut1[t])==3)<<3 |
              ((lut1[t])==4)<<4 | ((lut1[t])==5)<<5 | ((lut1[t])==6)<<6 | ((lut1[t])==7)<<7 |
              ((lut1[t])==8)<<8 | ((lut1[t])==9)<<9 | ((lut1[t])==10)<<10 | ((lut1[t])==11)<<11 |
              ((lut1[t])==12)<<12 | ((lut1[t])==13)<<13 | ((lut1[t])==14)<<14 | ((lut1[t])==15)<<15,
    lutc1[t]= ((t>>7&1 | t>>2&2)==0) | ((t>>7&1 | t>>2&2)==1)<<1 | ((t>>7&1 | t>>2&2)==2)<<2 | ((t>>7&1 | t>>2&2)==3)<<3 |
              ((t>>6&1 | t>>1&2)==0) | ((t>>6&1 | t>>1&2)==1)<<1 | ((t>>6&1 | t>>1&2)==2)<<2 | ((t>>6&1 | t>>1&2)==3)<<3 |
              ((t>>5&1 | t   &2)==0) | ((t>>5&1 | t   &2)==1)<<1 | ((t>>5&1 | t   &2)==2)<<2 | ((t>>5&1 | t   &2)==3)<<3 |
              ((t>>4&1 | t<<1&2)==0) | ((t>>4&1 | t<<1&2)==1)<<1 | ((t>>4&1 | t<<1&2)==2)<<2 | ((t>>4&1 | t<<1&2)==3)<<3;
  eld1= 0;
  if( typeof eld.set=='function' ){
    pal= [110|125<<8|107<<16|255<<24,// 13 #40
          110|123<<8|109<<16|255<<24,// 27 #41
            0|243<<8|107<<16|255<<24,// 19 #42
          243|243<<8|109<<16|255<<24,// 25 #43
            0|  3<<8|107<<16|255<<24,//  1 #44
          240|  3<<8|104<<16|255<<24,//  6 #45
            0|120<<8|104<<16|255<<24,// 10 #46
          243|125<<8|107<<16|255<<24,// 16 #47
          243|  3<<8|104<<16|255<<24,// 28 #48
          243|243<<8|107<<16|255<<24,// 29 #49
          243|243<<8| 14<<16|255<<24,// 24 #4A
          255|243<<8|249<<16|255<<24,// 26 #4B
          243|  5<<8|  6<<16|255<<24,//  6 #4C
          243|  3<<8|244<<16|255<<24,//  8 #4D
          243|125<<8| 14<<16|255<<24,// 15 #4E
          250|128<<8|249<<16|255<<24,// 17 #4F
            0|  3<<8|104<<16|255<<24,// 30 #50
            3|243<<8|107<<16|255<<24,// 31 #51
            3|240<<8|  1<<16|255<<24,// 18 #52
           15|243<<8|241<<16|255<<24,// 20 #53
            0|  3<<8|  1<<16|255<<24,//  0 #54
           12|  3<<8|244<<16|255<<24,//  2 #55
            3|120<<8|  1<<16|255<<24,//  9 #56
           12|123<<8|244<<16|255<<24,// 11 #57
          105|  3<<8|104<<16|255<<24,//  4 #58
          113|243<<8|107<<16|255<<24,// 22 #59
          113|245<<8|  4<<16|255<<24,// 21 #5A
          113|243<<8|244<<16|255<<24,// 23 #5B
          108|  3<<8|  1<<16|255<<24,//  3 #5C
          108|  3<<8|241<<16|255<<24,//  5 #5D
          110|123<<8|  1<<16|255<<24,// 12 #5E
          110|123<<8|246<<16|255<<24,// 14 #5F
    // paleta en blanco y negro
          144|144<<8|144<<16|255<<24,
          144|144<<8|144<<16|255<<24,
          192|192<<8|192<<16|255<<24,
          240|240<<8|240<<16|255<<24,
           48| 48<<8| 48<<16|255<<24,
           96| 96<<8| 96<<16|255<<24,
          120|120<<8|120<<16|255<<24,
          168|168<<8|168<<16|255<<24,
           96| 96<<8| 96<<16|255<<24,
          240|240<<8|240<<16|255<<24,
          232|232<<8|232<<16|255<<24,
          248|248<<8|248<<16|255<<24,
           88| 88<<8| 88<<16|255<<24,
          104|104<<8|104<<16|255<<24,
          160|160<<8|160<<16|255<<24,
          176|176<<8|176<<16|255<<24,
           48| 48<<8| 48<<16|255<<24,
          192|192<<8|192<<16|255<<24,
          184|184<<8|184<<16|255<<24,
          200|200<<8|200<<16|255<<24,
           40| 40<<8| 40<<16|255<<24,
           56| 56<<8| 56<<16|255<<24,
          112|112<<8|112<<16|255<<24,
          128|128<<8|128<<16|255<<24,
           72| 72<<8| 72<<16|255<<24,
          216|216<<8|216<<16|255<<24,
          208|208<<8|208<<16|255<<24,
          224|224<<8|224<<16|255<<24,
           64| 64<<8| 64<<16|255<<24,
           80| 80<<8| 80<<16|255<<24,
          136|136<<8|136<<16|255<<24,
          152|152<<8|152<<16|255<<24,
    // paleta fósforo verde
          0|144<<8|0<<16|255<<24,
          0|144<<8|0<<16|255<<24,
          0|192<<8|0<<16|255<<24,
          0|240<<8|0<<16|255<<24,
          0| 48<<8|0<<16|255<<24,
          0| 96<<8|0<<16|255<<24,
          0|120<<8|0<<16|255<<24,
          0|168<<8|0<<16|255<<24,
          0| 96<<8|0<<16|255<<24,
          0|240<<8|0<<16|255<<24,
          0|232<<8|0<<16|255<<24,
          0|248<<8|0<<16|255<<24,
          0| 88<<8|0<<16|255<<24,
          0|104<<8|0<<16|255<<24,
          0|160<<8|0<<16|255<<24,
          0|176<<8|0<<16|255<<24,
          0| 48<<8|0<<16|255<<24,
          0|192<<8|0<<16|255<<24,
          0|184<<8|0<<16|255<<24,
          0|200<<8|0<<16|255<<24,
          0| 40<<8|0<<16|255<<24,
          0| 56<<8|0<<16|255<<24,
          0|112<<8|0<<16|255<<24,
          0|128<<8|0<<16|255<<24,
          0| 72<<8|0<<16|255<<24,
          0|216<<8|0<<16|255<<24,
          0|208<<8|0<<16|255<<24,
          0|224<<8|0<<16|255<<24,
          0| 64<<8|0<<16|255<<24,
          0| 80<<8|0<<16|255<<24,
          0|136<<8|0<<16|255<<24,
          0|152<<8|0<<16|255<<24];
    eld1= new ArrayBuffer(eld.length),
    eld2= new Uint8ClampedArray(eld1),
    eld3= new Uint32Array(eld1);
    eld3[0]= 0x18020304;
    be= eld2[0] & 0x18;
    if( be )
      for (t= 0; t < 96; t++)
        pal[t]= rever32(pal[t]);
    paintScreen= function(){
      u= -1;
      mix= miy= 300;
      max= may= 0;
      if(gm==0){
        for(z= 0; z<=cr[9]; z++)
          for(y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
            for(x= 0, pos= (t= y*cr[9]+y+z)*(cr[1]<<gm+2); x<cr[1]; x++){
              by= ram[ma>>12][v=ma<<1&0x7ff|z<<11];
              if(vb[++u]!=by){
                vb[u]= by;
                x<mix && (mix= x);
                x>max && (max= x);
                t<miy && (miy= t);
                t>may && (may= t);
                eld3[pos++]= pl[lut0[by]]
                eld3[pos++]= pl[lut1[by]];
              }
              else
                pos+= 2;
              by= ram[ma++>>12][v+1];
              if(vb[++u]!=by){
                vb[u]= by;
                x<mix && (mix= x);
                x>max && (max= x);
                t<miy && (miy= t);
                t>may && (may= t);
                eld3[pos++]= pl[lut0[by]],
                eld3[pos++]= pl[lut1[by]];
              }
              else
                pos+= 2;
            }
        if( may >= miy )
          eld.set(eld2),
          ct.putImageData(elm, 0, 0, (mix<<2)-1, miy-1, (max-mix<<2)+6, may-miy+3);
      }
      else if(gm==1){
        for(z= 0; z<=cr[9]; z++)
          for(y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
            for(x= 0, pos= (t= y*cr[9]+y+z)*(cr[1]<<gm+2); x<cr[1]; x++){
              by= ram[ma>>12][v= ma<<1&0x7ff|z<<11];
              if(vb[++u]!=by){
                vb[u]= by;
                x<mix && (mix= x);
                x>max && (max= x);
                t<miy && (miy= t);
                t>may && (may= t);
                eld3[pos++]= pl[by>>7&1 | by>>2&2];
                eld3[pos++]= pl[by>>6&1 | by>>1&2];
                eld3[pos++]= pl[by>>5&1 | by   &2];
                eld3[pos++]= pl[by>>4&1 | by<<1&2];
              }
              else
                pos+= 4;
              by= ram[ma++>>12][v+1];
              if(vb[++u]!=by){
                vb[u]= by;
                x<mix && (mix= x);
                x>max && (max= x);
                t<miy && (miy= t);
                t>may && (may= t);
                eld3[pos++]= pl[by>>7&1 | by>>2&2];
                eld3[pos++]= pl[by>>6&1 | by>>1&2];
                eld3[pos++]= pl[by>>5&1 | by   &2];
                eld3[pos++]= pl[by>>4&1 | by<<1&2];
              }
              else
                pos+= 4;
            }
        if( may >= miy )
          eld.set(eld2),
          ct.putImageData(elm, 0, 0, (mix<<3)-1, miy-1, (max-mix<<3)+10, may-miy+3);
      }
      else{
        for(var z= 0; z<=cr[9]; z++)
          for(var y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
            for(var x= 0, pos= (t= y*cr[9]+y+z)*(cr[1]<<gm+2); x<cr[1]<<1; x++){
              by= ram[ma>>12][ma<<1&0x7ff|z<<11|x&1];
              if(x&1)
                ++ma;
              if(vb[++u]!=by){
                vb[u]= by;
                x<mix && (mix= x);
                x>max && (max= x);
                t<miy && (miy= t);
                t>may && (may= t);
                eld3[pos++]= pl[by>>7&1];
                eld3[pos++]= pl[by>>6&1];
                eld3[pos++]= pl[by>>5&1];
                eld3[pos++]= pl[by>>4&1];
                eld3[pos++]= pl[by>>3&1];
                eld3[pos++]= pl[by>>2&1];
                eld3[pos++]= pl[by>>1&1];
                eld3[pos++]= pl[by   &1];
              }
              else
                pos+= 8;
            }
        if( may >= miy )
          eld.set(eld2),
          ct.putImageData(elm, 0, 0, (mix<<3)-1, miy-1, (max-mix<<3)+10, may-miy+3);
      }
    };
    onresize= function(){
      cv.width= cr[1] ? cr[1]<<gm+2 : 1;
      cv.height= (cr[9]+1)*cr[6];
      eld= (elm= (ct= cv.getContext('2d')).getImageData(0,0,cv.width,cv.height)).data;
      eld1= new ArrayBuffer(eld.length);
      eld2= new Uint8ClampedArray(eld1);
      eld3= new Uint32Array(eld1);
      t= cr[1]*(cr[9]+1)*cr[6]<<1;
      while(t--)
        vb[t]= -1;
      ratio= innerWidth/innerHeight;
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
    };
    rotapal= function(){
      while( t-- )
        for (u= 0; u < 32; u++)
          v= pal[u+32],
          pal[u+32]= pal[u+64],
          pal[u+64]= pal[u],
          pal[u]= v;
      for (t= 0; t < 17; t++)
        pl[t]= pal[gc[t]];
      document.body.style.backgroundColor= '#'+(pl[16]&0xffffff).toString(16);
    };
    border= function(){
      document.body.style.backgroundColor= '#'+('00000'+(be?pl[16]:rever32(pl[16])>>8).toString(16)).slice(-6);
      if( ifra )
        put.style.color= (pl[16]>>be&255)+(pl[16]>>8&255)+(pl[16]>>16&255)<300 ? '#fff' : '#000';
      if( pbt )
        tim.style.color= (pl[16]>>be&255)+(pl[16]>>8&255)+(pl[16]>>16&255)<300 ? '#fff' : '#000';
    };
  }
  else{
    pal= [[110, 125, 107], // 13 #40
          [110, 123, 109], // 27 #41
          [  0, 243, 107], // 19 #42
          [243, 243, 109], // 25 #43
          [  0,   3, 107], //  1 #44
          [240,   3, 104], //  6 #45
          [  0, 120, 104], // 10 #46
          [243, 125, 107], // 16 #47
          [243,   3, 104], // 28 #48
          [243, 243, 107], // 29 #49
          [243, 243,  14], // 24 #4A
          [255, 243, 249], // 26 #4B
          [243,   5,   6], //  6 #4C
          [243,   3, 244], //  8 #4D
          [243, 125,  14], // 15 #4E
          [250, 128, 249], // 17 #4F
          [  0,   3, 104], // 30 #50
          [  3, 243, 107], // 31 #51
          [  3, 240,   1], // 18 #52
          [ 15, 243, 241], // 20 #53
          [  0,   3,   1], //  0 #54
          [ 12,   3, 244], //  2 #55
          [  3, 120,   1], //  9 #56
          [ 12, 123, 244], // 11 #57
          [105,   3, 104], //  4 #58
          [113, 243, 107], // 22 #59
          [113, 245,   4], // 21 #5A
          [113, 243, 244], // 23 #5B
          [108,   3,   1], //  3 #5C
          [108,   3, 241], //  5 #5D
          [110, 123,   1], // 12 #5E
          [110, 123, 246], // 14 #5F
    // paleta en blanco y negro
          [144, 144, 144],
          [144, 144, 144],
          [192, 192, 192],
          [240, 240, 240],
          [ 48,  48,  48],
          [ 96,  96,  96],
          [120, 120, 120],
          [168, 168, 168],
          [ 96,  96,  96],
          [240, 240, 240],
          [232, 232, 232],
          [248, 248, 248],
          [ 88,  88,  88],
          [104, 104, 104],
          [160, 160, 160],
          [176, 176, 176],
          [ 48,  48,  48],
          [192, 192, 192],
          [184, 184, 184],
          [200, 200, 200],
          [ 40,  40,  40],
          [ 56,  56,  56],
          [112, 112, 112],
          [128, 128, 128],
          [ 72,  72,  72],
          [216, 216, 216],
          [208, 208, 208],
          [224, 224, 224],
          [ 64,  64,  64],
          [ 80,  80,  80],
          [136, 136, 136],
          [152, 152, 152],
    // paleta fósforo verde
          [0, 144, 0],
          [0, 144, 0],
          [0, 192, 0],
          [0, 240, 0],
          [0,  48, 0],
          [0,  96, 0],
          [0, 120, 0],
          [0, 168, 0],
          [0,  96, 0],
          [0, 240, 0],
          [0, 232, 0],
          [0, 248, 0],
          [0,  88, 0],
          [0, 104, 0],
          [0, 160, 0],
          [0, 176, 0],
          [0,  48, 0],
          [0, 192, 0],
          [0, 184, 0],
          [0, 200, 0],
          [0,  40, 0],
          [0,  56, 0],
          [0, 112, 0],
          [0, 128, 0],
          [0,  72, 0],
          [0, 216, 0],
          [0, 208, 0],
          [0, 224, 0],
          [0,  64, 0],
          [0,  80, 0],
          [0, 136, 0],
          [0, 152, 0]];
    paintScreen= function(){
      u= -1;
      mix= miy= 300;
      max= may= 0;
      if(gm==0){
        for(z= 0; z<=cr[9]; z++)
          for(y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
            for(x= 0, pos= (t= y*cr[9]+y+z)*(cr[1]<<gm+2)<<2; x<cr[1]; x++){
              by= ram[ma>>12][v=ma<<1&0x7ff|z<<11];
              if(vb[++u]!=by){
                vb[u]= by;
                x<mix && (mix= x);
                x>max && (max= x);
                t<miy && (miy= t);
                t>may && (may= t);
                b0= pl[lut0[by]];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[lut1[by]];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
              }
              else
                pos+= 8;
              by= ram[ma++>>12][v+1];
              if(vb[++u]!=by){
                vb[u]= by;
                x<mix && (mix= x);
                x>max && (max= x);
                t<miy && (miy= t);
                t>may && (may= t);
                b0= pl[lut0[by]],
                eld[pos++]= b0[0],
                eld[pos++]= b0[1],
                eld[pos++]= b0[2],
                pos++,
                b0= pl[lut1[by]],
                eld[pos++]= b0[0],
                eld[pos++]= b0[1],
                eld[pos++]= b0[2],
                pos++;
              }
              else
                pos+= 8;
            }
        if( may >= miy )
          ct.putImageData(elm, 0, 0, (mix<<2)-1, miy-1, (max-mix<<2)+6, may-miy+3);
      }
      else if(gm==1){
        for(z= 0; z<=cr[9]; z++)
          for(y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
            for(x= 0, pos= (t= y*cr[9]+y+z)*(cr[1]<<gm+2)<<2; x<cr[1]; x++){
              by= ram[ma>>12][v= ma<<1&0x7ff|z<<11];
              if(vb[++u]!=by){
                vb[u]= by;
                x<mix && (mix= x);
                x>max && (max= x);
                t<miy && (miy= t);
                t>may && (may= t);
                b0= pl[by>>7&1 | by>>2&2];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>6&1 | by>>1&2];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>5&1 | by   &2];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>4&1 | by<<1&2];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
              }
              else
                pos+= 16;
              by= ram[ma++>>12][v+1];
              if(vb[++u]!=by){
                vb[u]= by;
                x<mix && (mix= x);
                x>max && (max= x);
                t<miy && (miy= t);
                t>may && (may= t);
                b0= pl[by>>7&1 | by>>2&2];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>6&1 | by>>1&2];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>5&1 | by   &2];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>4&1 | by<<1&2];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
              }
              else
                pos+= 16;
            }
        if( may >= miy )
          ct.putImageData(elm, 0, 0, (mix<<3)-1, miy-1, (max-mix<<3)+10, may-miy+3);
      }
      else{
        for(var z= 0; z<=cr[9]; z++)
          for(var y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
            for(var x= 0, pos= (t= y*cr[9]+y+z)*(cr[1]<<gm+2)<<2; x<cr[1]<<1; x++){
              by= ram[ma>>12][ma<<1&0x7ff|z<<11|x&1];
              if(x&1)
                ++ma;
              if(vb[++u]!=by){
                vb[u]= by;
                x<mix && (mix= x);
                x>max && (max= x);
                t<miy && (miy= t);
                t>may && (may= t);
                b0= pl[by>>7&1];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>6&1];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>5&1];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>4&1];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>3&1];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>2&1];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by>>1&1];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
                b0= pl[by&1];
                eld[pos++]= b0[0];
                eld[pos++]= b0[1];
                eld[pos++]= b0[2];
                pos++;
              }
              else
                pos+= 32;
            }
        if( may >= miy )
          ct.putImageData(elm, 0, 0, (mix<<3)-1, miy-1, (max-mix<<3)+10, may-miy+3);
      }
    };
    onresize= function (){
      cv.width= cr[1] ? cr[1]<<gm+2 : 1;
      cv.height= (cr[9]+1)*cr[6];
      eld= (elm= (ct= cv.getContext('2d')).getImageData(0,0,cv.width,cv.height)).data;
      t= cr[1]*(cr[9]+1)*cr[6]<<1;
      u= t<<gm+3;
      while(u--)
        eld[u]= 255;
      while(t--)
        vb[t]= -1;
      ratio= innerWidth/innerHeight;
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
    };
    rotapal= function (){
      while( t-- )
        for (u= 0; u < 32; u++)
          v= pal[u+32],
          pal[u+32]= pal[u+64],
          pal[u+64]= pal[u],
          pal[u]= v;
      for (t= 0; t < 17; t++)
        pl[t]= pal[gc[t]];
      document.body.style.backgroundColor= 'rgb('+pl[16].toString()+')';
      t= cr[1]*(cr[9]+1)*cr[6]<<1;
      while(t--)
        vb[t]= -1;
    };
    border= function(){
      document.body.style.backgroundColor= 'rgb('+pl[16].toString()+')';
      if( ifra )
        put.style.color= pl[16][0]+pl[16][1]+pl[16][2]<300 ? '#fff' : '#000';
      if( pbt )
        tim.style.color= pl[16][0]+pl[16][1]+pl[16][2]<300 ? '#fff' : '#000';
    };
  }
  noir= rs= gm= 1;
  for (t= 0; t < 17; t++)
    pl[t]= pal[gc[t]];
  cv.setAttribute('style', 'image-rendering:'+( localStorage.ft & 1
                                                ? 'optimizeSpeed'
                                                : '' ));
  t= localStorage.ft>>3;
  rotapal();
  onresize();
  pbcs= frcs= pbc= bp= ci= ap= io= vsync= ay= envc= envx= ay13= noic= noiv= tons= cp= ga= f1= f3= f4= st= time= flash= 0;
  ayr= [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0]; // last 3 values for tone counter
  if( localStorage.ft==undefined )
    localStorage.ft= 4;
  fdcinit();
     b= c= d= e= h= l= xl=xh=fa= fb= fr= ff= r7=i=
  a_=b_=   d_=e_=h_=l_=yl=yh=fa_=fb_=fr_=ff_=r= im=pc= iff= halted= 0;
  a= 0x0d;
  c_= 0x89;
  sp= 0xbfec;
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
      put.title= 'Roland6128 '+parseInt(trein/((nt= new Date().getTime())-time))+'%';
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
  for (r= 0; r < 49152; r++)        // fill memory
    rom[r>>14][r&16383]= emul.charCodeAt(0x30045+r) & 255;
  for (j= 0; j < 131072; j++)        // fill memory
    ram[j>>14][j&16383]= j < 65536 ? emul.charCodeAt(0x30045+r++) & 255 : 0;
  for (j= 0; j < param2.length; j++)        // fill memory
    ram[j+0xac8a>>14][j+0xac8a&16383]= param2.charCodeAt(j);
  mw[0]= ram[0];
  mw[3]= ram[3];
  m[0]= rom[0];
  m[1]= mw[1]= ram[1];
  m[2]= mw[2]= ram[2];
  m[3]= rom[1];
  if(game)                               // emulate LOAD ""
    pc= 0x1bc4;
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
        audioOutput.mozSetup(1, 62400); // 62400/1248= 50  19968/1248= 16.  16/4= 4
        myrun= mozrun;
      }
      catch (er){}
      interval= setInterval(myrun, 20);
    }
    else
      interval= setInterval(myrun, 20);
  }
  self.focus();
}

function wp(addr, val) {
  if (~addr&0x8000 && val>>6==3){ //0xxxxxxx ... RAM banking
    rb= val&7;
    mw[0]= ram[rb==2 ? 4 : 0];
    m[1]= mw[1]= ram[rb ? (rb==2 ? 5 : rb) : 1];
    m[2]= mw[2]= ram[rb==2 ? 6 : 2];
    mw[3]= ram[rb && rb<4 ? 7 : 3];
    if(m[0]!=rom[0])
      m[0]= mw[0];
    if(m[3]!=rom[rs])
      m[3]= mw[3];
  }
  if ((addr&0xC000)==0x4000){ //01xxxxxx ... gate array
    if(val&0x80){
      if(~val&0x40){ //screen mode
        m[0]= val&4 ? mw[0] : rom[0];
        m[3]= val&8 ? mw[3] : rom[rs];
        if(gm != (val&3))
          gm= val&3,
          onresize();
      }
    }
    else{ 
      if(val & 0x40 && gc[ga] != (val&0x1f)){ //colour for pen
        gc[ga]= val&0x1f;
        pl[ga]= pal[val&0x1f];
        t= cr[1]*(cr[9]+1)*cr[6]<<1;
        if( ga==16 )
          border();
        else if(ga<1<<(4>>gm)){
          u= 1<<ga;
          if(gm==0){
            while(t--)
              if(lutc0[vb[t]]&u)
                vb[t]= -1;
          }
          else if(gm==1){
            while(t--)
              if(lutc1[vb[t]]&u)
                vb[t]= -1;
          }
          else{
            if(ga){
              while(t--)
                if(vb[t])
                  vb[t]= -1;
            }
            else{
              while(t--)
                if(vb[t]<255)
                  vb[t]= -1;
            }
          }
        }
      }
      else{ //select pen
        ga= val;
      }
    }
  }
  if (!(addr&0x4300)){ //x0xxxx00 ... crtc select
    ci= val&0x1f;
  }
  else if((addr&0x4300)==0x0100 && cr[ci] != val){ //x0xxxx01 ... crtc data
    cr[ci]= val;
    if(1<<ci&0x3000){
      t= cr[1]*(cr[9]+1)*cr[6]<<1;
      while(t--)
        vb[t]= -1;
    }
    else if(1<<ci&0x242)
      onresize();
  }
  if (~addr&0x2000){ //xx0xxxxx ... upper rom bank
    if(m[3] == rom[rs])
      m[3]= rom[rs= val==7 ? 2 : 1];
    else
      rs= val==7 ? 2 : 1;
  }
  if (~addr&0x0800){ //xxxx0xxx ... 8255
    if(addr&0x0200){
      if(addr&0x0100){ //xxxx0x11 ... 8255 control
        if (val >> 7) //set configuration
          io= val,
          ap= bp= cp= 0;
        else{ //bit/set in C port
          if(val & 0x08){ //bit/set from 4..7
            if(~io & 0x08){ //upper C is output?
              if (val & 0x01)
                cp|=    1 << (val >> 1 & 0x07);
              else
                cp&= ~ (1 << (val >> 1 & 0x07));
            }
            if(cp & 0x80){ //write PSG
              if (cp & 0x40)
                ay= ap & 0x0f;
              else
                ayw(ap);
            }
          }
          else{ //bit/set from 0..3
            if(~io & 0x01){
              if (val & 0x01)
                cp|=    1 << (val >> 1 & 0x07);
              else
                cp&= ~ (1 << (val >> 1 & 0x07));
            }
          }
        }
      }
      else{ //xxxx0x10 ... 8255 port C
        if(~io & 0x08){ //upper C is output?
          cp= cp & 0x0f | val & 0xf0;
          if(cp & 0x80){
            if (cp & 0x40)
              ay= ap & 0x0f;
            else
              ayw(ap);
          }
        }
        if(~io & 0x01)
          cp= cp & 0xf0 | val & 0x0f;
      }
    }
    else{
      if(addr&0x0100){ //xxxx0x01 ... 8255 port B
        if (~io & 0x02)
          bp= val;
      }
      else{ //xxxx0x00 ... 8255 port A
        if (~io & 0x10){
          ap= val;
          if(cp & 0x80){
            if (cp & 0x40)
              ay= ap & 0x0f;
            else
              ayw(ap);
          }
        }
      }
    }
  }
  if (!(addr&0x0480)){ //xxxxx0xx 0xxxxxxx ... fdc
    if((addr&0x0101)==0x0101) //xxxxx0x1 0xxxxxx1 ... fdc data
      fdcdw(val);
    else if(~addr&0x0100) //xxxxx0x0 0xxxxxxx ... fdc motor
      fdcmw(val);
  }
}
