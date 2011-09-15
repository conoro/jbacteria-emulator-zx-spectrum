caca= 0;//0x10000000;
function cond() {
  caca && caca++==0x20509 && generateSnap();
}

function generateSnap() {
console.log('snap',t,hex(f()));
  node.onaudioprocess= audioprocess0;
//  clearInterval(interval);
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

function rm(o) {
caca= 1;
  j= 0;
  i= o.charCodeAt(j++);
  l_= o.charCodeAt(j++);
  h_= o.charCodeAt(j++);
  e_= o.charCodeAt(j++);
  d_= o.charCodeAt(j++);
  c_= o.charCodeAt(j++);
  b_= o.charCodeAt(j++);
  setf_(o.charCodeAt(j++));
  a_= o.charCodeAt(j++);
  l= o.charCodeAt(j++);
  h= o.charCodeAt(j++);
  e= o.charCodeAt(j++);
  d= o.charCodeAt(j++);
  c= o.charCodeAt(j++);
  b= o.charCodeAt(j++);
  yl= o.charCodeAt(j++);
  yh= o.charCodeAt(j++);
  xl= o.charCodeAt(j++);
  xh= o.charCodeAt(j++);
  iff= o.charCodeAt(j++)>>2 & 1;
  r= r7= o.charCodeAt(j++);
  setf(o.charCodeAt(j++));
  a= o.charCodeAt(j++);
  sp= o.charCodeAt(j++) | o.charCodeAt(j++)<<8;
  im= o.charCodeAt(j++);
  wp(0, bor=o.charCodeAt(j++)); //bordercolor
  for ( t= 0
      ; t < 0x4000
      ; t++ )
    ram[5][t]= o.charCodeAt(j++);
  for ( t= 0
      ; t < 0x4000
      ; t++ )
    ram[2][t]= o.charCodeAt(j++);
  wp(0x7ffd, lo= o.charCodeAt(49152+27+2));
  for ( t= 0
      ; t < 0x4000
      ; t++ )
    ram[lo&7][t]= o.charCodeAt(j++);
  pc= o.charCodeAt(j++) | o.charCodeAt(j++)<<8;
  j+= 2;
  for ( t= 0
      ; t < 8
      ; t++)
    if( t != 2
     && t != 5
     && t != (lo&7) )
      for ( u= 0
          ; u < 0x4000
          ; u++ )
        ram[t][u]= o.charCodeAt(j++);
}
