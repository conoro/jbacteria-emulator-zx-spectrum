

function paintScreen(){
  if(gm==0)
    for(z= 0; z<=cr[9]; z++)
      for(y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
        for(x= 0, pos= (y*cr[9]+y+z)*(cr[1]<<gm+2)<<2; x<cr[1]; x++)
          by= mw[ma>>12][t=ma<<1&0x7ff|z<<11],
          b0= pl[lut0[by]],
          eld[pos++]= b0[0],
          eld[pos++]= b0[1],
          eld[pos++]= b0[2],
          pos++,
          b0= pl[lut1[by]],
          eld[pos++]= b0[0],
          eld[pos++]= b0[1],
          eld[pos++]= b0[2],
          pos++,
          by= mw[ma++>>12][t+1],
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
  else if(gm==1)
    for(z= 0; z<=cr[9]; z++)
      for(y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
        for(x= 0, pos= (y*cr[9]+y+z)*(cr[1]<<gm+2)<<2; x<cr[1]; x++)
          by= mw[ma>>12][t= ma<<1&0x7ff|z<<11],
          b0= pl[by>>7&1 | by>>2&2],
          eld[pos++]= b0[0],
          eld[pos++]= b0[1],
          eld[pos++]= b0[2],
          pos++,
          b0= pl[by>>6&1 | by>>1&2],
          eld[pos++]= b0[0],
          eld[pos++]= b0[1],
          eld[pos++]= b0[2],
          pos++,
          b0= pl[by>>5&1 | by   &2],
          eld[pos++]= b0[0],
          eld[pos++]= b0[1],
          eld[pos++]= b0[2],
          pos++,
          b0= pl[by>>4&1 | by<<1&2],
          eld[pos++]= b0[0],
          eld[pos++]= b0[1],
          eld[pos++]= b0[2],
          pos++,
          by= mw[ma++>>12][t+1],
          b0= pl[by>>7&1 | by>>2&2],
          eld[pos++]= b0[0],
          eld[pos++]= b0[1],
          eld[pos++]= b0[2],
          pos++,
          b0= pl[by>>6&1 | by>>1&2],
          eld[pos++]= b0[0],
          eld[pos++]= b0[1],
          eld[pos++]= b0[2],
          pos++,
          b0= pl[by>>5&1 | by   &2],
          eld[pos++]= b0[0],
          eld[pos++]= b0[1],
          eld[pos++]= b0[2],
          pos++,
          b0= pl[by>>4&1 | by<<1&2],
          eld[pos++]= b0[0],
          eld[pos++]= b0[1],
          eld[pos++]= b0[2],
          pos++;
  else
    for(var z= 0; z<=cr[9]; z++)
      for(var y= 0, ma= cr[13]|cr[12]<<8; y<cr[6]; y++)
        for(var x= 0, pos= (y*cr[9]+y+z)*(cr[1]<<gm+2)<<2; x<cr[1]<<1; x++){
          by= mw[ma>>12][ma<<1&0x7ff|z<<11|x&1];
          if(x&1)
            ++ma;
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
  ct.putImageData(elm, 0, 0);
}

function onresize() {
  cv.width= cr[1]<<gm+2;
  cv.height= (cr[9]+1)*cr[6];
  eld= (elm= (ct= cv.getContext('2d')).getImageData(0,0,cv.width,cv.height)).data;
  u= cr[1]*(cr[9]+1)*cr[6]<<gm+4;
  while(u--)
    eld[u]= 255;
  ratio= innerWidth/innerHeight;
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
  pt.style.left= he.style.left= cv.style.marginLeft;
  pt.style.top= he.style.top= cv.style.marginTop;
}
