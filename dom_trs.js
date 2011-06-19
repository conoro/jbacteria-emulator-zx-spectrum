document.body.style.margin= 0;
document.body.style.background= '#111';
he= document.createElement('canvas');
he.width= 512;
he.height= 384;
he.setAttribute('style','display:none;position:absolute');
eld= (elm= (ct= he.getContext('2d')).getImageData(0,0,512,384)).data;
ir= document.createElement('iframe');
ir.setAttribute('style','display:none');
document.body.appendChild(ir);
while( t < 0xbfff )
  a= emul.charCodeAt(++t+12)>>6 & 3,
  eld[u++]= emul.charCodeAt(3*a),
  eld[u++]= emul.charCodeAt(3*a+1),
  eld[u++]= emul.charCodeAt(3*a+2),
  eld[u++]= a ? 255 : 55,
  a= emul.charCodeAt(t+12)>>4 & 3,
  eld[u++]= emul.charCodeAt(3*a),
  eld[u++]= emul.charCodeAt(3*a+1),
  eld[u++]= emul.charCodeAt(3*a+2),
  eld[u++]= a ? 255 : 55,
  a= emul.charCodeAt(t+12)>>2 & 3,
  eld[u++]= emul.charCodeAt(3*a),
  eld[u++]= emul.charCodeAt(3*a+1),
  eld[u++]= emul.charCodeAt(3*a+2),
  eld[u++]= a ? 255 : 55,
  a= emul.charCodeAt(t+12) & 3,
  eld[u++]= emul.charCodeAt(3*a),
  eld[u++]= emul.charCodeAt(3*a+1),
  eld[u++]= emul.charCodeAt(3*a+2),
  eld[u++]= a ? 255 : 55;
ct.putImageData(elm, 0, 0);
cv= document.createElement('canvas');
cv.width= 512;
cv.height= 192;
document.body.appendChild(cv);
document.body.appendChild(he);
eld= (elm= (ct= cv.getContext('2d')).getImageData(0,0,512,192)).data;
init();