var na= 'jBacteria16 ';

function init() {
  resize();
  ft= st= time= tape= flash= tapep= 0;
  z80init();
  a= b= c= d= f= h= l= a_= b_= c_= d_= e_= h_= l_= r= r7= pc= iff= im= halted= t= u= 0;
  e= 17;
  f_= 1;
  xh= 92;
  xl= 226;
  yh= 92;
  yl= 58;
  i= 63;
  sp= 32587;
  put= top==self ? document : parent.document;
  while(t<0x30000)
    eld[t++]= 255;
  for (o= 0; o < 768; o++)
    vm[o]= 255;
  for (j= 0; j < 65536; j++)        // fill memory
    m[j]= j < 32768 ? emul.charCodeAt(j+0x30018) & 255 : 255;
  if(game)                               // emulate LOAD ""
    pc= 1388;
  document.ondragover= handleDragOver;
  document.ondrop= handleFileSelect;
  document.onkeydown= kdown;          // key event handling
  document.onkeyup= kup;
  document.onkeypress= kpress;
  document.body.onresize= resize;
  interval= setInterval(run, 20);
  self.focus();
}

function wb(addr, val) {
  if (addr > 16383 && addr < 32768 && val != m[addr]){
    m[addr]= val;
    if (addr < 22528)
      vm[addr & 255 | addr >> 3 & 768]|= 1<< (addr >> 8 & 7);
    else if (addr < 23296)
      vm[addr-22528]= 255;
 }
}