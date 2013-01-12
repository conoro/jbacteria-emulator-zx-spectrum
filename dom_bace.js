document.body.style.margin= 0;
pt= document.createElement('select');
pt.setAttribute('onchange','tapep=this.value;tapei=this.selectedIndex');
cu= document.createElement('div');
cu.setAttribute('style','overflow-y:auto;background:#fff;opacity:0.9;padding:0 5px');
cu.innerHTML='F1: pause/help<br/>'+
    'F2: toggle joystick/opqam<br/>'+
    'F3: save quick snapshot<br/>'+
    'F4: load quick snapshot (also works in other session)<br/>'+
    'F5: reload (browser refresh)<br/>'+
    'F6: save gameplay<br/>'+
    'F7: toggle color/black & white pallete<br/>'+
    'F8: reset machine<br/>'+
    'F9: toggle bilinear/nearest neighbor scaling (Firefox only)<br/>'+
    'F10: save snapshot to local file (Chrome only)<br/>'+
    'F11: toggle fullscreen<br/>'+
    'F12: toggle sound (Firefox and Chrome)<br/><br/>'+
    '<a href="//jupiler.retrolandia.net" target="_blank">jupiler</a> version 20130112 by <a href="//antoniovillena.es" target="_blank">Antonio Villena</a><br/>'+
    'GPLv3 licensed, source code available at <a href="//emuscriptoria.svn.sourceforge.net/viewvc/emuscriptoria" target="_blank">EmuScriptoria</a>';
dv= document.createElement('div');
dv.setAttribute('style','display:none;position:absolute');
dv.appendChild(pt);
dv.appendChild(cu);
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
cv.width= 256;
cv.height= 192;
document.body.appendChild(cv);
document.body.appendChild(he);
document.body.appendChild(dv);
eld= (elm= (ct= cv.getContext('2d')).getImageData(0,0,256,192)).data;
init();