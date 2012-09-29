/*function showr(){
  console.log('PC='+pc.toString(16)
             ,'AFp='+(f_()|a_<<8).toString(16)
             ,'AF='+(f()|a<<8).toString(16)
             ,'BC='+(c|b<<8).toString(16)
             ,'DE='+(e|d<<8).toString(16)
             ,'HL='+(l|h<<8).toString(16)
             ,'IX='+(xl|xh<<8).toString(16)
             ,'IY='+(yl|yh<<8).toString(16));
}*/

function loadblock() {
  if( !game )
    return;
  o= game.charCodeAt(tapep++) | game.charCodeAt(tapep++)<<8;
// console.log(o);
  tapei++;
  for ( j= 0
      ; j < o
      ; j++ )
    wb(yl | yh << 8, game.charCodeAt(tapep++)),
    g[0x223]();
//  setf_(0xa9);
//  a_= 0xff;
  a= h= d= e= 0;
  pc= 0x18f9;
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
  paintScreen= paintBascolace= paintNormal;
  for ( t= 0x300; t < 0x380; t++ )
    vm[t]= 1;
  a= b= c= d= e= h= l= fa= fb= fr= ff= xl= xh= r7= i= sp= 
  a_=b_=c_=d_=e_=h_=l_=fa_=fb_=fr_=ff_=yl= yh= r= pc= iff= im= halted= t= u= 0;
  pbf= ' / '+('0'+parseInt(pbf/3000)).slice(-2)+':'+('0'+parseInt(pbf/50)%60).slice(-2);
  if( ifra ){
    put= document.createElement('div');
    put.style.width= '40px';
    put.style.color= '#fff';
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
    tim.style.color= '#fff',
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

function wb(addr, val) {
  if( addr < 0x2000 )
    return;
  else if ( addr < 0x2800 )
    m[addr]= m[addr^0x400]= val;
  else if ( addr < 0x3000 ){
    if( m[addr]!= val )
      m[addr]= m[addr^0x400]= val,
      vm[addr>>3&0x7f|0x300]= 1;
  }
  else if ( addr < 0x4000 )
    m[addr]= m[addr^0x400]= m[addr^0x800]= m[addr^0xc00]= val;
  else
    m[addr]= val;
}

function paintNormal(){
  mix= miy= 32;
  max= may= t= -1;
  while( t++ < 0x2ff )
    if( vm[t]!=(u=m[t+0x2000]) || vm[u&0x7f|0x300] ){
      vm[t]= u;
      dx= t&0x1f;
      dy= t>>5;
      dx<mix && (mix= dx);
      dx>max && (max= dx);
      dy<miy && (miy= dy);
      dy>may && (may= dy);
      if( u & 0x80 )
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
    }
  for ( t= 0x300; t < 0x380; t++ )
    vm[t]= 0;
  may >= miy &&
    ct.putImageData(elm, 0, 0, (mix<<3)-1, (miy<<3)-1, (max-mix<<3)+10, (may-miy<<3)+10);
}

function pressF2(al){
  al || (localStorage.ft= +localStorage.ft+2&6 | +localStorage.ft&25);
  switch( localStorage.ft & 6 ){
    case 0: kc[9]=  0x05<<7 | 0x24;
            kc[37]= 0x05<<7 | 0x19;
            kc[38]= 0x05<<7 | 0x21;
            kc[39]= 0x05<<7 | 0x23;
            kc[40]= 0x05<<7 | 0x22;
            al || alert('Cursors enabled (Tab=Graph)'); break;
    case 2: kc[9]=  0x40;
            kc[37]= 0x42;
            kc[38]= 0x45;
            kc[39]= 0x43;
            kc[40]= 0x44;
            al || alert('Boldfield Joystick enabled on Cursors + Tab'); break;
    case 4: kc[9]=  0x24;
            kc[37]= 0x19;
            kc[38]= 0x21;
            kc[39]= 0x23;
            kc[40]= 0x22;
            al || alert('5 6 7 8 9 on Cursors + Tab'); break;
    case 6: kc[9]=  0x3c;
            kc[37]= 0x2c;
            kc[38]= 0x15;
            kc[39]= 0x2d;
            kc[40]= 0x0d;
            al || alert('O P Q A M on Cursors + Tab');
  }
}