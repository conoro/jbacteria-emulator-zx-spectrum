caca= 0;//0x10000000;
function cond() {
//  if(pc==0xc96d && ope==16 && a==0x0f)  //16 seek 0 2
//console.log(hex(a));
//    generateSnap();

}

function generateSnap() {
  clearInterval(interval);
  o= wm();
  t= new ArrayBuffer(o.length);
  u= new Uint8Array(t, 0);
  for (j=0; j<o.length; j++)
    u[j]= o.charCodeAt(j);
  j= new WebKitBlobBuilder(); 
  j.append(t);
  ir.src= webkitURL.createObjectURL(j.getBlob());
}

function hex(n){
  var h= '0123456789ABCDEF';
  return h[n>>12]+h[n>>8&15]+h[n>>4&15]+h[n&15];
}
/*
function rm(o) {
  j= 17;
  f= o.charCodeAt(j++);
  a= o.charCodeAt(j++);
  c= o.charCodeAt(j++);
  b= o.charCodeAt(j++);
  e= o.charCodeAt(j++);
  d= o.charCodeAt(j++);
  l= o.charCodeAt(j++);
  h= o.charCodeAt(j++);
  r= o.charCodeAt(j++);
  i= o.charCodeAt(j++);
  iff= o.charCodeAt(j++)&1;
  j++;
  xl= o.charCodeAt(j++);
  xh= o.charCodeAt(j++);
  yl= o.charCodeAt(j++);
  yh= o.charCodeAt(j++);
  sp= o.charCodeAt(j++)|o.charCodeAt(j++)<<8;
  pc= o.charCodeAt(j++)|o.charCodeAt(j++)<<8;
  im= o.charCodeAt(j++);
  f_= o.charCodeAt(j++);
  a_= o.charCodeAt(j++);
  c_= o.charCodeAt(j++);
  b_= o.charCodeAt(j++);
  e_= o.charCodeAt(j++);
  d_= o.charCodeAt(j++);
  l_= o.charCodeAt(j++);
  h_= o.charCodeAt(j++);
  ga= o.charCodeAt(j++);

  gc= [o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++)];
  for (t= 0; t < 17; t++)
    pl[t]= pal[gc[t]];
  ap= o.charCodeAt(j++);
  gm= ap&3;
  rb= o.charCodeAt(j++);
  mw[0]= ram[rb==2 ? 4 : 0],
  m[1]= mw[1]= ram[rb ? (rb==2 ? 5 : rb) : 1],
  m[2]= mw[2]= ram[rb==2 ? 6 : 2],
  mw[3]= ram[rb && rb<4 ? 7 : 3];
  m[0]= ap&4 ? mw[0] : rom[0];
  ci= o.charCodeAt(j++);
  cr= [o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++)];
  rs= o.charCodeAt(j++)==7 ? 2 : 1;
  m[3]= ap&8 ? mw[3] : rom[rs];
console.log(ap, rb, m[0]==ram[0], m[1]==ram[7], m[2]==ram[2], m[3]==ram[3]);
  ap= o.charCodeAt(j++);
  bp= o.charCodeAt(j++);
  cp= o.charCodeAt(j++);
  o.charCodeAt(j++);
  ay= o.charCodeAt(j++);
  ayr= [o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++),
       o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++), o.charCodeAt(j++)];
  j+= 149;
  for (t= 0; t < 131072; t++)
    ram[t>>14][t&16383]= o.charCodeAt(j++);
  onresize();
  caca= 0;
}
*/