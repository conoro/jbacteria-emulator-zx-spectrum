function init() {
  rs= gm= 1;
  for (t= 0; t < 17; t++)
    pl[t]= pal[gc[t]];
  for (t= 0; t < 256; t++)
    lut0[t]= t>>7&1 | t>>3&4 | t>>2&2 | t<<2&8,
    lut1[t]= t>>6&1 | t>>2&4 | t>>1&2 | t<<3&8;
  onresize();
  ay= envc= envx= ay13= noic= noir= tons= 0;
  ayr= [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0]; // last 3 values for tone counter
  ga= f1= st= time= flash= 0;
  if( localStorage.ft==undefined )
    localStorage.ft= 0;
  z80init();
  fdcinit();
  d= r= r7= pc= iff= halted= t= u= 0;
  a= 0x0d;
  f= 0x0;
  b= 0;
  c= 0;
  b_= 0;
  c_= 0x89;
  h= 0;
  l= 0;
  h_= 0;
  l_= 0;
  e= 0;
  d_= 0;
  e_= 0;
  f_= 0;
  a_= 0;
  xh= 0;
  xl= 0;
  yh= 0;
  yl= 0;
  i= 0;
  im= 0;
  sp= 0xbfec;
  put= top==self ? document : parent.document;
  for (r= 0; r < 49152; r++)        // fill memory
    rom[r>>14][r&16383]= emul.charCodeAt(0x18015+r) & 255;
  for (j= 0; j < 65536; j++)        // fill memory
    mw[j>>14][j&16383]= emul.charCodeAt(0x18015+r++) & 255;
  for (j= 0; j < param.length; j++)        // fill memory
    mw[j+0xac8a>>14][j+0xac8a&16383]= param.charCodeAt(j);
  m[0]= rom[0];
  m[1]= mw[1];
  m[2]= mw[2];
  m[3]= rom[1];
  if(game)                               // emulate LOAD ""
    pc= 0x1bc4;
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
      audioOutput.mozSetup(1, 187500); // 187500/3750= 50  60000/3750= 16
      myrun= mozrun;
      interval= setInterval(myrun, 20);
    }
    else
      interval= setInterval(myrun, 20);
  }
  self.focus();
}

function audioprocess0(e){
  data1= e.outputBuffer.getChannelData(0);
  data2= e.outputBuffer.getChannelData(1);
  j= 0;
  while( j<1024 )
    data1[j++]= data2[j]= 0;
}

function audioprocess(e){
  run();
  data1= e.outputBuffer.getChannelData(0);
  data2= e.outputBuffer.getChannelData(1);
  j= 0;
  if( localStorage.ft & 4 )
    while( j<1024 ) // 48000/1024= 46.875  60000/1024= 58.59
      data1[j++]= data2[j]= (aystep()+aystep()+aystep()+aystep())/4;
}

function mozrun(){
  run();
  if( localStorage.ft & 4 ){
    j= 0;
    while( j<3750 )
      data[j++]= aystep();
    audioOutput.mozWriteAudio(data);
  }
}

function wp(addr, val) {
  if ((addr&0xC000)==0x4000){ //01xxxxxx ... gate array
    if(val&0x80){
      if(~val&0x40){ //screen mode
        m[0]= val&4 ? mw[0] : rom[0];
        m[3]= val&8 ? mw[3] : rom[rs];
        if(gm != (val&3))
          gm= val&3,
          onresize();
      }
    }
    else{ 
      if(val & 0x40 && gc[ga] != (val&0x1f)){ //colour for pen
        gc[ga]= val&0x1f;
        pl[ga]= pal[val&0x1f];
        if(ga==16)
          document.body.style.backgroundColor= 'rgb('+pl[ga][0]+','+pl[ga][1]+','+pl[ga][2]+')';
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
  if (~addr&0x2000){ //xx0xxxxx ... upper rom bank
    rs= val==7 ? 2 : 1;
    if(m[3] != mw[3])
      m[3]= rom[rs];
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
  if (!(addr&0x0480)){ //xxxxx0xx 0xxxxxxx ... fdc
    if((addr&0x0101)==0x0101) //xxxxx0x1 0xxxxxx1 ... fdc data
      fdcdw(val);
    else if(~addr&0x0100) //xxxxx0x0 0xxxxxxx ... fdc motor
      fdcmw(val);
  }
}
