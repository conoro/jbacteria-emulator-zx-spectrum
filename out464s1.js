function init() {
  gm= 1;
  for (t= 0; t < 17; t++)
    pl[t]= pal[gc[t]];
  for (t= 0; t < 256; t++)
    lut0[t]= t>>7&1 | t>>3&4 | t>>2&2 | t<<2&8,
    lut1[t]= t>>6&1 | t>>2&4 | t>>1&2 | t<<3&8;
  cv.setAttribute('style', 'image-rendering:'+( localStorage.ft & 1
                                                ? 'optimizeSpeed'
                                                : '' ));
  t= localStorage.ft>>3;
  rotapal();
  onresize();
  pbcs= frcs= pbc= bp= ci= ap= io= vsync= ay= envc= envx= ay13= noic= noir= noiv= tons= cp= ga= f1= f3= f4= st= time= flash= 0;
  ayr= [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0]; // last 3 values for tone counter
  if( localStorage.ft==undefined )
    localStorage.ft= 4;
        c= d= e= h= l= xl=xh=fa= fb= fr= ff= r7=i=
  a_=b_=c_=d_=e_=h_=l_=yl=yh=fa_=fb_=fr_=ff_=r= im=pc= iff= halted= 0;
  a= 0x09;
  b= 0xf7;
  sp= 0xbfe8;
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
      put.title= 'Roland464 '+parseInt(trein/((nt= new Date().getTime())-time))+'%';
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
  for (r= 0; r < 32768; r++)        // fill memory
    rom[r>>14][r&16383]= emul.charCodeAt(0x30045+r) & 255;
  for (j= 0; j < 65536; j++)        // fill memory
    mw[j>>14][j&16383]= emul.charCodeAt(0x30045+r++) & 255;
  m[0]= rom[0];
  m[1]= mw[1];
  m[2]= mw[2];
  m[3]= rom[1];
  rom[0][0x2a68]= 0x01;
  rom[0][0x286d]= 0x10,
  rom[0][0x286e]= 0xfe,
  rom[0][0x286f]= 0x3d,
  rom[0][0x2870]= 0x20,
  rom[0][0x2871]= 0xfa,
  rom[0][0x2836]= 0xed,
  rom[0][0x2837]= 0xfc;
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
        audioOutput.mozSetup(1, 62400); // 62400/1248= 50  19968/1248= 16.  16/4= 4
        myrun= mozrun;
      }
      catch (er){}
      interval= setInterval(myrun, 20);
    }
    else
      interval= setInterval(myrun, 20);
  }
  self.focus();
}

function wp(addr, val) {
  if ((addr&0xC000)==0x4000){ //01xxxxxx ... gate array
    if(val&0x80){
      if(~val&0x40){ //screen mode
        m[0]= val&4 ? mw[0] : rom[0];
        m[3]= val&8 ? mw[3] : rom[1];
        if(gm != (val&3))
          gm= val&3,
          onresize();
      }
    }
    else{ 
      if(val & 0x40 && gc[ga] != (val&0x1f)){ //colour for pen
        gc[ga]= val&0x1f;
        pl[ga]= pal[val&0x1f];
        if( ga==16 )
          border();
      }
      else{ //select pen
        ga= val;
      }
    }
  }
  if (!(addr&0x4300)){ //x0xxxx00 ... crtc select
    ci= val&0x1f;
  }
  else if((addr&0x4300)==0x0100 && cr[ci] != val){ //x0xxxx01 ... crtc data
    cr[ci]= val;
    if(1<<ci&0x242)
      onresize();
  }
  if (~addr&0x0800){ //xxxx0xxx ... 8255
    if(addr&0x0200){
      if(addr&0x0100){ //xxxx0x11 ... 8255 control
        if (val >> 7) //set configuration
          io= val,
          ap= bp= cp= 0;
        else{ //bit/set in C port
          if(val & 0x08){ //bit/set from 4..7
            if(~io & 0x08){ //upper C is output?
              if (val & 0x01)
                cp|=    1 << (val >> 1 & 0x07);
              else
                cp&= ~ (1 << (val >> 1 & 0x07));
            }
            if(cp & 0x80){ //write PSG
              if (cp & 0x40)
                ay= ap & 0x0f;
              else
                ayw(ap);
            }
          }
          else{ //bit/set from 0..3
            if(~io & 0x01){
              if (val & 0x01)
                cp|=    1 << (val >> 1 & 0x07);
              else
                cp&= ~ (1 << (val >> 1 & 0x07));
            }
          }
        }
      }
      else{ //xxxx0x10 ... 8255 port C
        if(~io & 0x08){ //upper C is output?
          cp= cp & 0x0f | val & 0xf0;
          if(cp & 0x80){
            if (cp & 0x40)
              ay= ap & 0x0f;
            else
              ayw(ap);
          }
        }
        if(~io & 0x01)
          cp= cp & 0xf0 | val & 0x0f;
      }
    }
    else{
      if(addr&0x0100){ //xxxx0x01 ... 8255 port B
        if (~io & 0x02)
          bp= val;
      }
      else{ //xxxx0x00 ... 8255 port A
        if (~io & 0x10){
          ap= val;
          if(cp & 0x80){
            if (cp & 0x40)
              ay= ap & 0x0f;
            else
              ayw(ap);
          }
        }
      }
    }
  }
}
