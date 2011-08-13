lutc0= [];
lutc1= [];

function init() {
  gm= 1;
  for (t= 0; t < 17; t++)
    pl[t]= pal[gc[t]];
  for (t= 0; t < 256; t++)
    lut0[t]= t>>7&1 | t>>3&4 | t>>2&2 | t<<2&8,
    lut1[t]= t>>6&1 | t>>2&4 | t>>1&2 | t<<3&8,
    lutc0[t]= (lut0[t])==0 | ((lut0[t])==1)<<1 | ((lut0[t])==2)<<2 | ((lut0[t])==3)<<3 |
              ((lut0[t])==4)<<4 | ((lut0[t])==5)<<5 | ((lut0[t])==6)<<6 | ((lut0[t])==7)<<7 |
              ((lut0[t])==8)<<8 | ((lut0[t])==9)<<9 | ((lut0[t])==10)<<10 | ((lut0[t])==11)<<11 |
              ((lut0[t])==12)<<12 | ((lut0[t])==13)<<13 | ((lut0[t])==14)<<14 | ((lut0[t])==15)<<15 |
              (lut1[t])==0 | ((lut1[t])==1)<<1 | ((lut1[t])==2)<<2 | ((lut1[t])==3)<<3 |
              ((lut1[t])==4)<<4 | ((lut1[t])==5)<<5 | ((lut1[t])==6)<<6 | ((lut1[t])==7)<<7 |
              ((lut1[t])==8)<<8 | ((lut1[t])==9)<<9 | ((lut1[t])==10)<<10 | ((lut1[t])==11)<<11 |
              ((lut1[t])==12)<<12 | ((lut1[t])==13)<<13 | ((lut1[t])==14)<<14 | ((lut1[t])==15)<<15,
    lutc1[t]= ((t>>7&1 | t>>2&2)==0) | ((t>>7&1 | t>>2&2)==1)<<1 | ((t>>7&1 | t>>2&2)==2)<<2 | ((t>>7&1 | t>>2&2)==3)<<3 |
              ((t>>6&1 | t>>1&2)==0) | ((t>>6&1 | t>>1&2)==1)<<1 | ((t>>6&1 | t>>1&2)==2)<<2 | ((t>>6&1 | t>>1&2)==3)<<3 |
              ((t>>5&1 | t   &2)==0) | ((t>>5&1 | t   &2)==1)<<1 | ((t>>5&1 | t   &2)==2)<<2 | ((t>>5&1 | t   &2)==3)<<3 |
              ((t>>4&1 | t<<1&2)==0) | ((t>>4&1 | t<<1&2)==1)<<1 | ((t>>4&1 | t<<1&2)==2)<<2 | ((t>>4&1 | t<<1&2)==3)<<3;
  cv.setAttribute('style', 'image-rendering:'+( localStorage.ft & 1
                                                ? 'optimizeSpeed'
                                                : '' ));
  t= localStorage.ft>>3;
  rotapal();
  onresize();
  pbc= bp= ci= ap= io= vsync= ay= envc= envx= ay13= noic= noir= tons= cp= ga= f1= st= time= flash= 0;
  ayr= [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0]; // last 3 values for tone counter
  if( localStorage.ft==undefined )
    localStorage.ft= 4;
  z80init();
  d= r= r7= pc= iff= halted= f= c= b_= c_= h= l= h_= l_= e= d_= e_= f_= a_= xh= xl= yh= yl= i= im= 0;
  a= 0x09;
  b= 0xf7;
  sp= 0xbfe8;
  if( ifra ){
    put= document.createElement('div');
    put.style.width= '40px';
    put.style.textAlign= 'right';
    document.body.appendChild(put);
    titul= function(){
      put.innerHTML= parseInt(trein/((nt= new Date().getTime())-time))+'%';
    }
  }
  else{
    put= top==self ? document : parent.document;
    titul= function(){
      put.title= 'Roland464 '+parseInt(trein/((nt= new Date().getTime())-time))+'%';
    }
  }
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
  if( game )                               // emulate LOAD ""
    tp(),
    pc= 0x2a5e;
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
      catch (e){}
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
        t= cr[1]*(cr[9]+1)*cr[6]<<1;
        if( ga==16 ){
          document.body.style.backgroundColor= 'rgb('+pl[16].toString()+')';
          if( ifra )
            put.style.color= pl[16][0]+pl[16][1]+pl[16][2]<300 ? '#fff' : '#000';
        }
        else if(ga<1<<(4>>gm)){
          u= 1<<ga;
          if(gm==0){
            while(t--)
              if(lutc0[vb[t]]&u)
                vb[t]= -1;
          }
          else if(gm==1){
            while(t--)
              if(lutc1[vb[t]]&u)
                vb[t]= -1;
          }
          else{
            if(ga){
              while(t--)
                if(vb[t])
                  vb[t]= -1;
            }
            else{
              while(t--)
                if(vb[t]<255)
                  vb[t]= -1;
            }
          }
        }
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
    if(1<<ci&0x3000){
      t= cr[1]*(cr[9]+1)*cr[6]<<1;
      while(t--)
        vb[t]= -1;
    }
    else if(1<<ci&0x242)
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
