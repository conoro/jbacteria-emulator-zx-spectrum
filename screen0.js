vb= [];

function paintScreen(){
  u= -1;
  mix= miy= 300;
  max= may= 0;
  if(gm==0){
    for(z= 0; z<=cr[9]; z++)
      for(y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
        for(x= 0, pos= (t= y*cr[9]+y+z)*(cr[1]<<gm+2)<<2; x<cr[1]; x++){
          by= mw[ma>>12][v=ma<<1&0x7ff|z<<11];
          if(vb[++u]!=by){
            vb[u]= by;
            if(x<mix)
              mix= x;
            else if(x>max)
              max= x;
            if(t < miy)
              miy= t;
            else if(t > may)
              may= t;
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
          by= mw[ma++>>12][v+1];
          if(vb[++u]!=by){
            vb[u]= by;
            if(x<mix)
              mix= x;
            else if(x>max)
              max= x;
            if(t < miy)
              miy= t;
            else if(t > may)
              may= t;
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
    if(may>miy)
      ct.putImageData(elm, 0, 0, (mix<<2)-1, miy-1, (max-mix<<2)+6, may-miy+3);
  }
  else if(gm==1){
    for(z= 0; z<=cr[9]; z++)
      for(y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
        for(x= 0, pos= (t= y*cr[9]+y+z)*(cr[1]<<gm+2)<<2; x<cr[1]; x++){
          by= mw[ma>>12][v= ma<<1&0x7ff|z<<11];
          if(vb[++u]!=by){
            vb[u]= by;
            if(x<mix)
              mix= x;
            else if(x>max)
              max= x;
            if(t < miy)
              miy= t;
            else if(t > may)
              may= t;
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
          by= mw[ma++>>12][v+1];
          if(vb[++u]!=by){
            vb[u]= by;
            if(x<mix)
              mix= x;
            else if(x>max)
              max= x;
            if(t < miy)
              miy= t;
            else if(t > may)
              may= t;
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
    if(may>miy)
      ct.putImageData(elm, 0, 0, (mix<<3)-1, miy-1, (max-mix<<3)+10, may-miy+3);
  }
  else{
    for(var z= 0; z<=cr[9]; z++)
      for(var y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
        for(var x= 0, pos= (t= y*cr[9]+y+z)*(cr[1]<<gm+2)<<2; x<cr[1]<<1; x++){
          by= mw[ma>>12][ma<<1&0x7ff|z<<11|x&1];
          if(x&1)
            ++ma;
          if(vb[++u]!=by){
            vb[u]= by;
            if(x<mix)
              mix= x;
            else if(x>max)
              max= x;
            if(t < miy)
              miy= t;
            else if(t > may)
              may= t;
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
    if(may>miy)
      ct.putImageData(elm, 0, 0, (mix<<3)-1, miy-1, (max-mix<<3)+10, may-miy+3);
  }
}

function resize() {
  cv.width= cr[1]<<gm+2;
  cv.height= (cr[9]+1)*cr[6];
  eld= (elm= (ct= cv.getContext('2d')).getImageData(0,0,cv.width,cv.height)).data;
  t= cr[1]*(cr[9]+1)*cr[6]<<1;
  u= t<<gm+3;
  while(u--)
    eld[u]= 255;
  while(t--)
    vb[t]= -1;
  var ratio= innerWidth/innerHeight;
  document.body.style.height= '0';
  document.body.style.width= '0';
  if (ratio>1.33)
    cv.style.height= innerHeight-50+'px',
    cv.style.width= parseInt(ratio=(innerHeight-50)*1.33)+'px',
    cv.style.marginTop= '25px',
    cv.style.marginLeft= ((innerWidth-ratio)>>1)+'px';
  else
    cv.style.width= innerWidth-50+'px',
    cv.style.height= parseInt(ratio=(innerWidth-50)/1.33)+'px',
    cv.style.marginLeft= '25px',
    cv.style.marginTop= ((innerHeight-ratio)>>1)+'px';
  he.style.width= cv.style.width;
  he.style.height= cv.style.height;
  he.style.left= cv.style.marginLeft;
  he.style.top= cv.style.marginTop;
}