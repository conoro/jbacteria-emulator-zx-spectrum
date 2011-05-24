document.body.style.margin= 0;
he= document.createElement('canvas');
he.width= 512;
he.height= 384;
he.setAttribute('style','display:none;position:absolute');
document.body.appendChild(he);
eld= (elm= (ct= he.getContext('2d')).getImageData(0,0,512,384)).data;
ir= document.createElement('iframe');
ir.setAttribute('style','display:none');
document.body.appendChild(ir);
while(t<98303)
  a= emul.charCodeAt(++t+21) >> 4,
  eld[u++]= emul.charCodeAt(3*a) & 255,
  eld[u++]= emul.charCodeAt(3*a+1) & 255,
  eld[u++]= emul.charCodeAt(3*a+2) & 255,
  eld[u++]= a ? 255 : 55,
  a= emul.charCodeAt(t+21) & 15,
  eld[u++]= emul.charCodeAt(3*a) & 255,
  eld[u++]= emul.charCodeAt(3*a+1) & 255,
  eld[u++]= emul.charCodeAt(3*a+2) & 255,
  eld[u++]= a ? 255 : 55;
ct.putImageData(elm, 0, 0);
cv= document.createElement('canvas');
cv.width= 160;
cv.height= 200;
document.body.appendChild(cv);
eld= (elm= (ct= cv.getContext('2d')).getImageData(0,0,160,200)).data;
init();