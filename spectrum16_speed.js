var na= 'jBacteria16 ';

function init() {
  cv.setAttribute('style', 'image-rendering:'+( localStorage.ft & 1
                                                ? 'optimizeSpeed'
                                                : '' ));
  onresize();
  cts= playp= vbp= bor= f1= st= time= flash= 0;
  if( localStorage.ft==undefined )
    localStorage.ft= 4;
  if ( localStorage.ft & 8 )
    rotapal();
  sample= 0;
  z80init();
  a= b= c= d= f= h= l= a_= b_= c_= d_= e_= h_= l_= r= r7= pc= iff= im= halted= t= u= 0;
  e=  0x11;
  f_= 0x01;
  xh= 0x5c;
  xl= 0xe2;
  yh= 0x5c;
  yl= 0x3a;
  i=  0x3f;
  sp= 0x7f4b;
  try{
    put= top==self ? document : parent.document;
  }
  catch(error){
    put= document;
  }
  while( t < 0x30000 )
    eld[t++]= 0xff;
  for ( j= 0
      ; j < 0x10000
      ; j++ )        // fill memory
    m[j]= j < 0x8000
          ? emul.charCodeAt(j+0x18018) & 0xff
          : 0xff;
  if(game)                               // emulate LOAD ""
    tp(),
    pc= 0x56c;
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
      paso= 69888/1024,
      node= cts.createJavaScriptNode(1024, 0, 1),
      node.onaudioprocess= audioprocess,
      node.connect(cts.destination);
    else
      interval= setInterval(myrun, 20);
  }
  else{
    if( typeof Audio == 'function'
     && (audioOutput= new Audio())
     && typeof audioOutput.mozSetup == 'function' ){
      paso= 69888/2048;
      audioOutput.mozSetup(2, 51200);
      myrun= mozrun;
      interval= setInterval(myrun, 20);
    }
    else
      interval= setInterval(myrun, 20);
  }
  self.focus();
}

function wb(addr, val) {
  if( addr > 0x3fff && addr < 0x8000 )
    m[addr]= val;
}