function loadblock() {
  if( !game )
    return;
  o= game.charCodeAt(tapep++) | game.charCodeAt(tapep++)<<8;
  tapei++;
  tapep++;
  for ( j= 0
      ; j < o-2
      ; j++ )
    wb(xl | xh << 8, game.charCodeAt(tapep++)),
    g[0x123]();
  setf_(0x6d);
  a= d= e= 0;
  pc= 0x590;
  tapep++;
  o=  game.charCodeAt(tapep) | game.charCodeAt(tapep+1)<<8;
  if( !o )
    tapei= tapep= 0;
  pt.selectedIndex= tapei;
}

function init() {
document.body.style.backgroundColor= '#111';
  cv.setAttribute('style', 'image-rendering:'+( localStorage.ft & 1
                                                ? 'optimizeSpeed'
                                                : '' ));
  onresize();
  scrl= ula= sample= pbcs= pbc= cts= playp= vbp= bor= f1= f3= f4= st= time= flash= 0;
  if( localStorage.ft==undefined )
    localStorage.ft= 4;
  pressF2(1);
  paintScreen= localStorage.ft&8 ? paintBascolace : paintNormal;
  a= b= c= d= e= h= l= fa= fb= fr= ff= xl= xh= r7= i= sp= 
  a_=b_=c_=d_=e_=h_=l_=fa_=fb_=fr_=ff_=yl= yh= r= pc= iff= im= halted= t= u= 0;
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
      put.title= na+parseInt(trein/((nt= new Date().getTime())-time))+'%';
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
      ; j < 0x2000
      ; j++ )        // fill memory
    m[j]= emul.charCodeAt(j+0xc00c);
  run();
  run();
  run();
  run();
  run();
  run();
  for ( j= 0
      ; j < 0x2000
      ; j++ )        // fill memory
    m[j]= emul.charCodeAt(j+0xe00c);
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
      paso= 64896/1024,
      node= cts.createJavaScriptNode(1024, 1, 1),
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
      catch (er){}
      paso= 64896/2048;
      interval= setInterval(myrun, 20);
    }
    else
      interval= setInterval(myrun, 20);
  }
  self.focus();
}

function paintBascolace(){
  t= -1;
  while( t++ < 0x2ff )
    for ( u= m[t+0x2000]
        , v= u & 0x80 ? 255 : 0
        , fo= pal[ m[t+0x4000]>>3 & 15 ]
        , ti= pal[ m[t+0x4000]>>3 & 8 
                 | m[t+0x4000]    & 7 ]
        , u= u<<3 | 0x2800
        , o= t>>5 << 13
           | t<<5 & 0x3ff
        , n= 8
        ; n--
        ; o+= 0x400 ){
      k= m[u++]^v;
      if( k&128 )
        eld[o  ]= ti[0],
        eld[o+1]= ti[1],
        eld[o+2]= ti[2];
      else
        eld[o  ]= fo[0],
        eld[o+1]= fo[1],
        eld[o+2]= fo[2];
      if( k&64 )
        eld[o+4]= ti[0],
        eld[o+5]= ti[1],
        eld[o+6]= ti[2];
      else
        eld[o+4]= fo[0],
        eld[o+5]= fo[1],
        eld[o+6]= fo[2];
      if( k&32 )
        eld[o+8 ]= ti[0],
        eld[o+9 ]= ti[1],
        eld[o+10]= ti[2];
      else
        eld[o+8 ]= fo[0],
        eld[o+9 ]= fo[1],
        eld[o+10]= fo[2];
      if( k&16 )
        eld[o+12]= ti[0],
        eld[o+13]= ti[1],
        eld[o+14]= ti[2];
      else
        eld[o+12]= fo[0],
        eld[o+13]= fo[1],
        eld[o+14]= fo[2];
      if( k&8 )
        eld[o+16]= ti[0],
        eld[o+17]= ti[1],
        eld[o+18]= ti[2];
      else
        eld[o+16]= fo[0],
        eld[o+17]= fo[1],
        eld[o+18]= fo[2];
      if( k&4 )
        eld[o+20]= ti[0],
        eld[o+21]= ti[1],
        eld[o+22]= ti[2];
      else
        eld[o+20]= fo[0],
        eld[o+21]= fo[1],
        eld[o+22]= fo[2];
      if( k&2 )
        eld[o+24]= ti[0],
        eld[o+25]= ti[1],
        eld[o+26]= ti[2];
      else
        eld[o+24]= fo[0],
        eld[o+25]= fo[1],
        eld[o+26]= fo[2];
      if( k&1 )
        eld[o+28]= ti[0],
        eld[o+29]= ti[1],
        eld[o+30]= ti[2];
      else
        eld[o+28]= fo[0],
        eld[o+29]= fo[1],
        eld[o+30]= fo[2];
    }
  ct.putImageData(elm, 0, 0);
}

function wb(addr, val) {
  if( addr < 0x2000 )
    return;
  else if ( addr < 0x3000 )
    m[addr]= m[addr^0x400]= val;
  else if ( addr < 0x4000 )
    m[addr]= m[addr^0x400]= m[addr^0x800]= m[addr^0xc00]= val;
  else
    m[addr]= val;
}

function paintNormal(){
  t= -1;
  while( t++ < 0x2ff )
    if( (u=m[t+0x2000]) & 0x80 )
      for ( u= u<<3 | 0x2800
          , o= t>>5 << 13
             | t<<5 & 0x3ff
          , n= 8
          ; n--
          ; o+= 0x400 )
        k= m[u++],
        eld[o   ]= eld[o+1 ]= eld[o+2 ]= k&0x80 ? 0 : 0xff,
        eld[o+4 ]= eld[o+5 ]= eld[o+6 ]= k&0x40 ? 0 : 0xff,
        eld[o+8 ]= eld[o+9 ]= eld[o+10]= k&0x20 ? 0 : 0xff,
        eld[o+12]= eld[o+13]= eld[o+14]= k&0x10 ? 0 : 0xff,
        eld[o+16]= eld[o+17]= eld[o+18]= k&0x08 ? 0 : 0xff,
        eld[o+20]= eld[o+21]= eld[o+22]= k&0x04 ? 0 : 0xff,
        eld[o+24]= eld[o+25]= eld[o+26]= k&0x02 ? 0 : 0xff,
        eld[o+28]= eld[o+29]= eld[o+30]= k&0x01 ? 0 : 0xff;
    else
      for ( u= u<<3 | 0x2800
          , o= t>>5 << 13
             | t<<5 & 0x3ff
          , n= 8
          ; n--
          ; o+= 0x400 )
        k= m[u++],
        eld[o   ]= eld[o+1 ]= eld[o+2 ]= k&0x80 ? 0xff : 0,
        eld[o+4 ]= eld[o+5 ]= eld[o+6 ]= k&0x40 ? 0xff : 0,
        eld[o+8 ]= eld[o+9 ]= eld[o+10]= k&0x20 ? 0xff : 0,
        eld[o+12]= eld[o+13]= eld[o+14]= k&0x10 ? 0xff : 0,
        eld[o+16]= eld[o+17]= eld[o+18]= k&0x08 ? 0xff : 0,
        eld[o+20]= eld[o+21]= eld[o+22]= k&0x04 ? 0xff : 0,
        eld[o+24]= eld[o+25]= eld[o+26]= k&0x02 ? 0xff : 0,
        eld[o+28]= eld[o+29]= eld[o+30]= k&0x01 ? 0xff : 0;
  ct.putImageData(elm, 0, 0);
}