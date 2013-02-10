document.body.style.margin= 0;
pt= document.createElement('select');
pt.setAttribute('onchange','tapep=this.value;tapei=this.selectedIndex');
dv= document.createElement('div');
dv.setAttribute('style','display:none;position:absolute');
dv.appendChild(pt);
he= document.createElement('canvas');
he.width= 500;
he.height= 200;
he.setAttribute('style','display:none;position:absolute');
kld= (klm= (kct= he.getContext('2d')).getImageData(0,0,500,200)).data;
ir= document.createElement('iframe');
ir.setAttribute('style','display:none');
document.body.appendChild(ir);
while(t<62499)
  a= emul.charCodeAt(++t+12524) >> 4,
  kld[u++]= emul.charCodeAt(3*a),
  kld[u++]= emul.charCodeAt(3*a+1),
  kld[u++]= emul.charCodeAt(3*a+2),
  kld[u++]= a ? 255 : 25,
  a= emul.charCodeAt(t+12524) & 15,
  kld[u++]= emul.charCodeAt(3*a),
  kld[u++]= emul.charCodeAt(3*a+1),
  kld[u++]= emul.charCodeAt(3*a+2),
  kld[u++]= a ? 255 : 25;
kct.putImageData(klm, 0, 0);
cv= document.createElement('canvas');
cv.width= 256;
cv.height= 192;
document.body.appendChild(cv);
document.body.appendChild(he);
document.body.appendChild(dv);
eld= (elm= (ct= cv.getContext('2d')).getImageData(0,0,256,192)).data;
init();