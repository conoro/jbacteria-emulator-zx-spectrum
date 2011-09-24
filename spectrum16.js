function init() {
  cv.setAttribute('style', 'image-rendering:'+( localStorage.ft & 1
                                                ? 'optimizeSpeed'
                                                : '' ));
  onresize();
  sample= pbcs= frcs= pbc= cts= playp= vbp= bor= f1= f3= f4= st= time= flash= 0;
  if( localStorage.ft==undefined )
    localStorage.ft= 4;
  if ( localStorage.ft & 8 )
    rotapal();
  a= b= c= d= h= l= fa= fb= fr= ff= r7=
  a_=b_=c_=d_=h_=l_=fa_=fb_=fr_=e_= r= pc= iff= im= halted= t= u= 0;
  e=  0x11;
  ff_= 0x100;
  xh= 0x5c;
  xl= 0xe2;
  yh= 0x5c;
  yl= 0x3a;
  i=  0x3f;
  sp= 0x7f4b;
  pbf= ' / '+('0'+parseInt(pbf/3000)).slice(-2)+':'+('0'+parseInt(pbf/50)%60).slice(-2);
  if( ifra ){
    put= document.createElement('div');
    put.style.width= '40px';
    put.style.textAlign= 'right';
    document.body.appendChild(put);
    titul= function(){
      put.innerHTML= parseInt(trein/((nt= new Date().getTime())-time))+'%';
      if( pbt )
        tim.innerHTML= ('0'+parseInt(flash/3000)).slice(-2)+':'+('0'+parseInt(flash/50)%60).slice(-2)+pbf;
    }
  }
  else{
    put= top==self ? document : parent.document;
    titul= function(){
      put.title= 'jBacteria16 '+parseInt(trein/((nt= new Date().getTime())-time))+'%';
      if( pbt )
        tim.innerHTML= ('0'+parseInt(flash/3000)).slice(-2)+':'+('0'+parseInt(flash/50)%60).slice(-2)+pbf;
    }
  }
  if( pbt )
    tim= document.createElement('div'),
    tim.style.position= 'absolute',
    tim.style.top= '0',
    tim.style.width= '100px',
    tim.style.textAlign= 'right',
    document.body.appendChild(tim);
  while( t < 0x30000 )
    eld[t++]= 0xff;
  for ( j= 0
      ; j < 0x10000
      ; j++ )        // fill memory
    m[j]= j < 0x8000
          ? emul.charCodeAt(j+0x18018) & 0xff
          : 0xff;
  game && tp();
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
      try{
        audioOutput.mozSetup(1, 51200);
        myrun= mozrun;
      }
      catch (e){}
      paso= 69888/2048;
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