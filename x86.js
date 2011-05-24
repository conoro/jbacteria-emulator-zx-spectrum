/*This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  Author: mail@antoniovillena.es. Inspired in Matthew Westcott's JSSpeccy
  Antonio José Villena Godoy. Malaga, Spain 29 Aug 2010*/

var sz= []                              // sign, zero, table
  , par= []                             // parity table
  , szp= []                             // sign, zero, parity table
//  , szi= []                             // sign, zero... increment table
//  , szd= []                             // sign, zero... decrement table
  , f= 0
  , fh= 512
  , al= 0
  , ah= 0
  , bx= 0
  , cl= 255
  , ch= 0
  , dl= 0
  , dh= 0
  , bp= 0x0912
  , si= 0x100
  , di= 0xFFFE
  , cs= 0
  , ds= 0
  , es= 0
  , ss= 0
  , sp= 0xFFFE
  , pc= 0x100
  , t= 0                                // temporary variables
  , u= 0;

function x86init() {
  for(j= 0; j<256; j++)
    sz[j]= j & 128,
    k= j,
    n= 1,
    n^= k & 1,
    k>>= 1,
    n^= k & 1,
    k>>= 1,
    n^= k & 1,
    k>>= 1,
    n^= k & 1,
    k>>= 1,
    n^= k & 1,
    k>>= 1,
    n^= k & 1,
    k>>= 1,
    n^= k & 1,
    k>>= 1,
    n^= k & 1,
    par[j]= n << 2,
//  szi[j]= sz[j] | ( j == 128 ? 4 : 0 ) | ( j&15 ? 0 : 16 ),
//  szd[j]= sz[j] | ( j == 127 ? 6 : 2 ) | ( j+1 & 15 ? 0 : 16 ),
    szp[j]= sz[j] | par[j];
//szi[0] |= 64;
//szd[0] |= 64;
  sz[0] |= 64;
  szp[0] |= 64;
}

/*function z80interrupt() {
  if( iff ) {
    if( halted )
      pc= (pc+1) & 65535,
      halted= 0;
    iff= 0;
    sp= (sp-1) & 65535;
    wb( sp, pc >> 8 );
    sp= (sp-1) & 65535;
    wb( sp, pc & 255 );
    r++;
    switch(im) {
      case 1:
        st++;
      case 0: 
        pc= 56;
        st+= 12;
        break;
      default:
        pc= m[t= 255 | i << 8] | m[++t&65535] << 8;
        st+=19;
        break;
    }
  }
}*/

function se(v) {
  return v < 128 ? v : v-256;
}

function op0(x, n, a){
  if (log[n]==' ')
    return 'u='+(n==3?'-(f&1)+':'')+(n==2?'(f&1)+':'')+'(f='+(x<192?'m[ds+'+(n==7?ea[x>>6][x&7]:ea0[x>>6][x&7])+']':ebr[x&7])+')'+(n<3?'+':'-')+'(v='+a+');'+
           'f=u>>8'+(n<3?'':'&1')+'|szp[u&=255]|(('+(n<3?'u':'f')+'^v)&(f^=u)&128)<<4|(f^v)&16'+
           (n==7?'':';'+(x<192?'m[wr(ds+t)]=u':ebw(x&7,'u')));
  else
    return 'f=szp['+( x<192 ? 'm[wr(ds+'+ea[x>>6][x&7]+')]'+log[n]+'='+a
                            : ebwo(x&7, a, log[n])
                    )+']';
}

function op1(x, n, a, b, c){
  if (log[n]==' ')
    return x<192 ? 'f='+(n==3?'-(f&1)+':'')+(n==2?'(f&1)+':'')+'(u=m[ds+'+ea0[x>>6][x&7]+']|m[ds+(t+1&65535)]<<8)'+(n<3?'+':'-')+'(v='+a+');'+
                   'f=f>>16'+(n<3?'':'&1')+'|f>>8&128|((f&=65535)?0:64)|'+
                       'par['+(n==7?'f&255':'m[wr(ds+t)]=f&255,m[wr(ds+(t+1&65535))]=f>>8')+']|(('+(n<3?'f':'u')+'^v)&(u^=f)&32768)>>4|(u^v)&16'
                 : 'u='+(n==3?'-(f&1)+':'')+(n==2?'(f&1)+':'')+'(f='+ewr[x&7]+')'+(n<3?'+':'-')+'(v='+a+');'+
                   'f=u>>16'+(n<3?'':'&1')+'|u>>8&128|((u&=65535)?0:64)|par[u&255]|(('+(n<3?'u':'f')+'^v)&(f^=u)&32768)>>4|(f^v)&16'+
                   (n==7?'':';'+ewwo(x&7, 'u', 'u&255', 'u>>8', ''));
  else
    return x<192 ? 'f=m[wr(ds+'+ea0[x>>6][x&7]+')]'+log[n]+'='+b+
                   ';u=m[wr(ds+(t+1&65535))]'+log[n]+'='+c+
                   ';f=u&128|(f|u?par[f]:64|par[f])'
                 : ewwo(x&7, a, b, c, log[n])+
                   ';f='+ewrhh[x&7]+'&128|('+((x&7)<4?ewrl[x&7]+'|'+ewrh[x&7]:ewr[x&7])+'?par['+ewrl[x&7]+']:64|par['+ewrl[x&7]+'])';
}

function op2(x, n){
  if (log[n]==' ')
    return 'u='+(n==3?'-(f&1)+':'')+(n==2?'(f&1)+':'')+'(f='+(x<192?'m[ds+'+ea[x>>6][x&7]+']':ebr[x&7])+')'+(n<3?'+':'-')+ebr[x>>3&7]+';'+
           'f=u>>8'+(n<3?'':'&1')+'|szp[u&=255]|(('+(n<3?'u':'f')+'^'+ebr[x>>3&7]+')&(f^=u)&128)<<4|(f^'+ebr[x>>3&7]+')&16'+
           (n==7?'':';'+ebw(x>>3&7,'u'));
  else
    return 'f=szp['+( x<192 ? ebwo(x>>3&7, 'm[ds+'+ea[x>>6][x&7]+']', log[n])
                            : ebwo(x>>3&7, ebr[x&7], log[n]) 
                    )+']';
}

function op3(x, n){
  if (log[n]==' ')
    return 'u='+(n==3?'-(f&1)+':'')+(n==2?'(f&1)+':'')+'(f='+(x<192?'m[ds+'+ea0[x>>6][x&7]+']|m[ds+(t+1&65535)]<<8':ewr[x&7])+')'+(n<3?'+':'-')+'(v='+ewr[x>>3&7]+');'+
           'f=u>>16'+(n<3?'':'&1')+'|u>>8&128|((u&=65535)?0:64)|par[u&255]|(('+(n<3?'u':'f')+'^v)&(f^=u)&32768)>>4|(f^v)&16'+
           (n==7?'':';'+ewwo(x>>3&7, 'u', 'u&255', 'u>>8', ''));
  else
    return x<192 ? ewwo(x>>3&7, 'm[ds+'+ea0[x>>6][x&7]+']|m[ds+(t+1&65535)]<<8', 
                        'm[ds+'+ea0[x>>6][x&7]+']', 'm[ds+(t+1&65535)]', log[n])+
                   ';f='+((x>>3&7)<4?ewrh[x>>3&7]:ewr[x>>3&7]+'>>8')+'&128|('+
                        ((x>>3&7)<4?ewrl[x>>3&7]+'|'+ewrh[x>>3&7]:ewr[x>>3&7])+'?par['+ewrl[x>>3&7]+']:64|par['+ewrl[x>>3&7]+'])'
                 : ewwo(x>>3&7, ewr[x&7], ewrl[x&7], ewrh[x&7], log[n])+
                   ';f='+((x>>3&7)<4?ewrh[x>>3&7]:ewr[x>>3&7]+'>>8')+'&128|('+
                        ((x>>3&7)<4?ewrl[x>>3&7]+'|'+ewrh[x>>3&7]:ewr[x>>3&7])+'?par['+ewrl[x>>3&7]+']:64|par['+ewrl[x>>3&7]+'])';
}

function op4(x, n){
  if (log[n]==' ')
    return 't='+(n==3?'-(f&1)+':'')+(n==2?'(f&1)+':'')+'al'+(n<3?'+':'-')+x+';'+
           'f=t>>8'+(n<3?'':'&1')+'|szp[t&=255]|('+((n<3?128:0)^(x&128)?'~al&t':'al&~t')+'&128)<<4|'+(x&16?'~':'')+'(al^t)&16'+
           (n==7?'':';al=t');
  else
    return 'f=szp[al'+log[n]+'='+x+']';
}

function op5(x, n){
  if (log[n]==' ')
    return 'u='+(n==3?'-(f&1)+':'')+(n==2?'(f&1)+':'')+
           ( n<3 ? 'al+'+x+'+(ah+(t=m[cs+(pc++&65535)])<<8)'
                 : '(al|ah<<8)-('+x+'|(t=m[cs+(pc++&65535)])<<8)'
           )+';f=u>>16'+(n<3?'':'&1')+'|u>>8&128|((u&=65535)?0:64)|'+
                    '((u>>8^ah)&('+(n<3?'u>>8':'ah')+'^t)&128)<<4|'+(x&16?'~':'')+'(u^al)&16|par['+(n==7?'u&255':'al=u&255,ah=u>>8')+']';
  else
    return 'al'+log[n]+'='+x+
           ';ah'+log[n]+'=m[cs+(pc++&65535)];'+
           'f=ah&128|(al|ah?par[al]:64|par[al])';
}

function incw0(a, b){//mejorar
  return 'if(++'+b+'>>8)'+
           b+'=0,'+
           a+'='+a+'+1&255;'+
         'f=f&1|'+a+'&128|('+b+'&15?0:16)|('+b+'||'+a+'!=128?0:2048)|('+b+'|'+a+'?par['+b+']:64|par['+b+'])';
}
function decw0(a, b){
  return 'if(!'+b+'--)'+
           b+'=255,'+
           a+'='+a+'-1&255;'+
         'f=f&1|'+a+'&128|(~'+b+'&15?0:16)|('+b+'==255&&'+a+'==127?2048:0)|('+b+'|'+a+'?par['+b+']:64|par['+b+'])';
}

function incw1(a){
  return a+'='+a+'+1&65535;'+
         'f=f&1|'+a+'>>8&128|('+a+'&15?0:16)|('+a+'==32768?2048:0)|('+a+'?par['+a+'&255]:64|par['+a+'&255])';
}

function decw1(a){
  return a+'='+a+'-1&65535;'+
         'f=f&1|'+a+'>>8&128|(~'+a+'&15?0:16)|('+a+'==32767?2048:0)|('+a+'?par['+a+'&255]:64|par['+a+'&255])';
}

function push(a, b){
  return  'm[wr(ss+(--sp&65535))]='+a+';'+
          'm[wr(ss+(sp=sp-1&65535))]='+b;
}

function pop(a, b){
  return  b+'=m[ss+sp];'+
          a+'=m[ss+(sp+1&65535)];'+
          'sp=sp+2&65535';
}

function popw(a){
  return  a+'=m[ss+sp]|m[ss+(sp+1&65535)]<<8;'+
          'sp=sp+2&65535';
}

function popws(a){
  return  a+'=m[ss+sp]<<4|m[ss+(sp+1&65535)]<<12;'+
          'sp=sp+2&65535';
}

function jcond(c, a) {
  return 'if('+c+')pc+=se('+a+')';
}

ea=[
['(bx+si&65535)',
'(bx+di&65535)',
'(bp+si&65535)',
'(bp+di&65535)',
'si',
'di',
'(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)',
'bx'],

['(bx+si+se(m[cs+(pc++&65535)])&65535)',
'(bx+di+se(m[cs+(pc++&65535)])&65535)',
'(bp+si+se(m[cs+(pc++&65535)])&65535)',
'(bp+di+se(m[cs+(pc++&65535)])&65535)',
'(si+se(m[cs+(pc++&65535)])&65535)',
'(di+se(m[cs+(pc++&65535)])&65535)',
'(bp+se(m[cs+(pc++&65535)])&65535)',
'(bx+se(m[cs+(pc++&65535)])&65535)'],

['(bx+si+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(bx+di+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(bp+si+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(bp+di+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(si+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(di+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(bp+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(bx+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)']];

ea0=[ //quitar ea0
['((t=bx+si)&65535)',
'((t=bx+di)&65535)',
'((t=bp+si)&65535)',
'((t=bp+di)&65535)',
'(t=si)',
'(t=di)',
'(t=m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)',
'(t=bx)'],

['(t=bx+si+se(m[cs+(pc++&65535)])&65535)',
'(t=bx+di+se(m[cs+(pc++&65535)])&65535)',
'(t=bp+si+se(m[cs+(pc++&65535)])&65535)',
'(t=bp+di+se(m[cs+(pc++&65535)])&65535)',
'(t=si+se(m[cs+(pc++&65535)])&65535)',
'(t=di+se(m[cs+(pc++&65535)])&65535)',
'(t=bp+se(m[cs+(pc++&65535)])&65535)',
'(t=bx+se(m[cs+(pc++&65535)])&65535)'],

['(t=bx+si+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(t=bx+di+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(t=bp+si+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(t=bp+di+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(t=si+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(t=di+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(t=bp+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)',
'(t=bx+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)&65535)']];

eabt=[
['(bx+si+t&65535)',
'(bx+di+t&65535)',
'(bp+si+t&65535)',
'(bp+di+t&65535)',
'(si+t&65535)',
'(di+t&65535)',
'((m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)+t&65535)',
'(bx+t&65535)'],

['(bx+si+se(m[cs+(pc++&65535)])+t&65535)',
'(bx+di+se(m[cs+(pc++&65535)])+t&65535)',
'(bp+si+se(m[cs+(pc++&65535)])+t&65535)',
'(bp+di+se(m[cs+(pc++&65535)])+t&65535)',
'(si+se(m[cs+(pc++&65535)])+t&65535)',
'(di+se(m[cs+(pc++&65535)])+t&65535)',
'(bp+se(m[cs+(pc++&65535)])+t&65535)',
'(bx+se(m[cs+(pc++&65535)])+t&65535)'],

['(bx+si+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)+t&65535)',
'(bx+di+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)+t&65535)',
'(bp+si+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)+t&65535)',
'(bp+di+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)+t&65535)',
'(si+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)+t&65535)',
'(di+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)+t&65535)',
'(bp+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)+t&65535)',
'(bx+(m[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8)+t&65535)']];

ebr=[
'al',
'cl',
'dl',
'(bx&255)',
'ah',
'ch',
'dh',
'(bx>>8)',
];

ewr=[
'al|ah<<8',
'cl|ch<<8',
'dl|dh<<8',
'bx',
'sp',
'bp',
'si',
'di',
];

ewrl=[
'al',
'cl',
'dl',
'bx&255',
'sp&255',
'bp&255',
'si&255',
'di&255',
];

ewrh=[
'ah',
'ch',
'dh',
'bx>>8',
'sp>>8',
'bp>>8',
'si>>8',
'di>>8',
];

ewrll=[
'al',
'cl',
'dl',
'bx',
'sp',
'bp',
'si',
'di',
];


ewrhh=[
'ah<<8',
'ch<<8',
'dh<<8',
'bx',
'sp',
'bp',
'si',
'di',
];

log= ' |  & ^ ';

function ebw(op, dest){
  switch(op){
    case 0: return 'al='+dest;
    case 1: return 'cl='+dest;
    case 2: return 'dl='+dest;
    case 3: return 'bx=bx&65280|'+dest;
    case 4: return 'ah='+dest;
    case 5: return 'ch='+dest;
    case 6: return 'dh='+dest;
    case 7: return 'bx=bx&255|'+dest+'<<8';
  }
}

function ebwo(op, dest, alu){
  switch(op){
    case 0: return 'al'+alu+'='+dest;
    case 1: return 'cl'+alu+'='+dest;
    case 2: return 'dl'+alu+'='+dest;
    case 3: return '(bx'+alu+'='+dest+')&255';
    case 4: return 'ah'+alu+'='+dest;
    case 5: return 'ch'+alu+'='+dest;
    case 6: return 'dh'+alu+'='+dest;
    case 7: return '(bx'+alu+'='+dest+'<<8)>>8';
  }
}

function eww(op, destw, destl, desth){
  switch(op){
    case 0: return 'al='+destl+';ah='+desth;
    case 1: return 'cl='+destl+';ch='+desth;
    case 2: return 'dl='+destl+';dh='+desth;
    case 3: return 'bx='+destw;
    case 4: return 'sp='+destw;
    case 5: return 'bp='+destw;
    case 6: return 'si='+destw;
    case 7: return 'di='+destw;
  }
}

function ewwo(op, destw, destl, desth, alu){
  switch(op){
    case 0: return 'al'+alu+'='+destl+';ah'+alu+'='+desth;
    case 1: return 'cl'+alu+'='+destl+';ch'+alu+'='+desth;
    case 2: return 'dl'+alu+'='+destl+';dh'+alu+'='+desth;
    case 3: return 'bx'+alu+'='+destw;
    case 4: return 'sp'+alu+'='+destw;
    case 5: return 'bp'+alu+'='+destw;
    case 6: return 'si'+alu+'='+destw;
    case 7: return 'di'+alu+'='+destw;
  }
}

p=[
function(x){//00. ADD r/m8, r8
  return op0(x, 0, ebr[x>>3&7]);
},
function(x){//01. ADD r/m16, r16
  return op1(x, 0, ewr[x>>3&7], ewrl[x>>3&7], ewrh[x>>3&7]);
},
function(x){//02. ADD r8, r/m8
  return op2(x, 0);
},
function(x){//03. ADD r16, r/m16
  return op3(x, 0);
},
function(x){//04. ADD AL, imm
  return op4(x, 0);
},
function(x){//05. ADD AX, imm
  return op5(x, 0);
},
function(x){//06. PUSH ES
  return push('es>>12', 'es&4095>>4')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//07. POP ES
  return popws('es')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//08. OR r/m8, r8
  return op0(x, 1, ebr[x>>3&7]);
},
function(x){//09. OR r/m16, r16
  return op1(x, 1, ewr[x>>3&7], ewrl[x>>3&7], ewrh[x>>3&7]);
},
function(x){//0A. OR r8, r/m8
  return op2(x, 1);
},
function(x){//0B. OR r16, r/m16
  return op3(x, 1);
},
function(x){//0C. OR AL, imm
  return op4(x, 1);
},
function(x){//0D. OR AX, imm
  return op5(x, 1);
},
function(x){//0E. PUSH CS
  return push('cs>>12', 'cs&4095>>4')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//0F. POP CS
  switch(x){
    case 163://A3. BT r/m16, r16
      return x<192 ? 'u=m[cs+(pc++&65535)];'+
                     'v=eval(ewr[u>>3&7]);'+
                     't=v>>3;'+
                     'f=f&2260|m[ds+eval(eabt[u>>6][u&7])]>>(v&7)&1'
                   : 'u=m[cs+(pc++&65535)];'+
                     'v=eval(ewr[u>>3&7]);'+
                     't=v>>4;'+
                     'f=f&2260|eval(ewr[u>>3&7])>>(v&15)&1';
    case 186://BA. BT,BTS,BTR,BTC,BSF,BSR,MOVSX
      return 0;
  }
},

function(x){//10. ADC r/m8, r8
  return op0(x, 2, ebr[x>>3&7]);
},
function(x){//11. ADC r/m16, r16
  return op1(x, 2, ewr[x>>3&7], ewrl[x>>3&7], ewrh[x>>3&7]);
},
function(x){//12. ADC r8, r/m8
  return op2(x, 2);
},
function(x){//13. ADC r16, r/m16
  return op3(x, 2);
},
function(x){//14. ADC AL, imm
  return op4(x, 2);
},
function(x){//15. ADC AX, imm
  return op5(x, 2);
},
function(x){//16. PUSH SS
  return push('ss>>12', 'ss&4095>>4')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//17. POP SS
  return popws('ss')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//18. SBB r/m8, r8
  return op0(x, 3, ebr[x>>3&7]);
},
function(x){//19. SBB r/m16, r16
  return op1(x, 3, ewr[x>>3&7], ewrl[x>>3&7], ewrh[x>>3&7]);
},
function(x){//1A. SBB r8, r/m8
  return op2(x, 3);
},
function(x){//1B. SBB r16, r/m16
  return op3(x, 3);
},
function(x){//1C. SBB AL, imm
  return op4(x, 3);
},
function(x){//1D. SBB AX, imm
  return op5(x, 3);
},
function(x){//1E. PUSH DS
  return push('ds>>12', 'ds&4095>>4')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//1F. POP DS
  return popws('ds')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},

function(x){//20. AND r/m8, r8
  return op0(x, 4, ebr[x>>3&7]);
},
function(x){//21. AND r/m16, r16
  return op1(x, 4, ewr[x>>3&7], ewrl[x>>3&7], ewrh[x>>3&7]);
},
function(x){//22. AND r8, r/m8
  return op2(x, 4);
},
function(x){//23. AND r16, r/m16
  return op3(x, 4);
},
function(x){//24. AND AL, imm
  return op4(x, 4);
},
function(x){//25. AND AX, imm
  return op5(x, 4);
},
function(x){//26. ES: (prefix)
  return 'xs=ds;ds=es;st++;g['+x+'|m[cs+(pc++&65535)]<<8]();ds=xs';
},
function(x){//27. DAA
  return 0
},
function(x){//28. SUB r/m8, r8
  return op0(x, 5, ebr[x>>3&7]);
},
function(x){//29. SUB r/m16, r16
  return op1(x, 5, ewr[x>>3&7], ewrl[x>>3&7], ewrh[x>>3&7]);
},
function(x){//2A. SUB r8, r/m8
  return op2(x, 5);
},
function(x){//2B. SUB r16, r/m16
  return op3(x, 5);
},
function(x){//2C. SUB AL, imm
  return op4(x, 5);
},
function(x){//2D. SUB AX, imm
  return op5(x, 5);
},
function(x){//2E. CS: (prefix)
  return 0
},
function(x){//2F. DAS
  return 0
},

function(x){//30. XOR r/m8, r8
  return op0(x, 6, ebr[x>>3&7]);
},
function(x){//31. XOR r/m16, r16
  return op1(x, 6, ewr[x>>3&7], ewrl[x>>3&7], ewrh[x>>3&7]);
},
function(x){//32. XOR r8, r/m8
  return op2(x, 6);
},
function(x){//33. XOR r16, r/m16
  return op3(x, 6);
},
function(x){//34. XOR AL, imm
  return op4(x, 6);
},
function(x){//35. XOR AX, imm
  return op5(x, 6);
},
function(x){//36. SS: (prefix)
  return 0
},
function(x){//37. AAA
  return 0
},
function(x){//38. CMP r/m8, r8
  return op0(x, 7, ebr[x>>3&7]);
},
function(x){//39. CMP r/m16, r16
  return op1(x, 7, ewr[x>>3&7], ewrl[x>>3&7], ewrh[x>>3&7]);
},
function(x){//3A. CMP r8, r/m8
  return op2(x, 7);
},
function(x){//3B. CMP r16, r/m16
  return op3(x, 7);
},
function(x){//3C. CMP AL, imm
  return op4(x, 7);
},
function(x){//3D. CMP AX, imm
  return op5(x, 7);
},
function(x){//3E. DS: (prefix)
  return 0
},
function(x){//3F. AAS
  return ''
},

function(x){//40. INC AX
  return incw0('ah', 'al')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//41. INC CX
  return incw0('ch', 'cl')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//42. INC DX
  return incw0('dh', 'dl')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//43. INC BX
  return incw1('bx')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//44. INC SP
  return incw1('sp')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//45. INC BP
  return incw1('bp')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//46. INC SI
  return incw1('si')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//47. INC DI
  return incw1('di')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//48. DEC AX
  return decw0('ah', 'al')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//49. DEC CX
  return decw0('ch', 'cl')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//4A. DEC DX
  return decw0('dh', 'dl')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//4B. DEC BX
  return decw1('bx')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//4C. DEC SP
  return decw1('sp')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//4D. DEC BP
  return decw1('bp')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//4E. DEC SI
  return decw1('si')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//4F. DEC DI
  return decw1('di')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},

function(x){//50. PUSH AX
  return push('ah', 'al')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//51. PUSH CX
  return push('ch', 'cl')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//52. PUSH DX
  return push('dh', 'dl')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//53. PUSH BX
  return push('bx>>8', 'bx&255')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//54. PUSH SP
  return push('sp>>8', 'sp&255')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//55. PUSH BP
  return push('bp>>8', 'bp&255')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//56. PUSH SI
  return push('si>>8', 'si&255')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//57. PUSH DI
  return push('di>>8', 'di&255')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//58. POP AX
  return pop('ah', 'al')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//59. POP CX
  return pop('ch', 'cl')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//5A. POP DX
  return pop('dh', 'dl')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//5B. POP BX
  return popw('bx')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//5C. POP SP
  return popw('sp')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//5D. POP BP
  return popw('bp')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//5E. POP SI
  return popw('si')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//5F. POP DI
  return popw('di')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},

function(x){//60
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){//68. PUSH imm16
  return push('m[cs+(pc++&65535)]', x);
},
function(x){
  return 0
},
function(x){//6A. PUSH imm8
  return push(x&128?255:0, x);
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},

function(x){//70. JO imm8
  return jcond('f&2048', x);
},
function(x){//71. JNO imm8
  return jcond('~f&2048', x);
},
function(x){//72. JC imm8
  return jcond('f&1', x);
},
function(x){//73. JNC imm8
  return jcond('~f&1', x);
},
function(x){//74. JZ imm8
  return jcond('f&64', x);
},
function(x){//75. JNZ imm8
  return jcond('~f&64', x);
},
function(x){//76. JBE imm8
  return jcond('f&65', x);
},
function(x){//77. JA imm8
  return jcond('!(f&65)', x);
},
function(x){//78. JS imm8
  return jcond('f&128', x);
},
function(x){//79. JNS imm8
  return jcond('~f&128', x);
},
function(x){//7A. JPE imm8
  return jcond('f&4', x);
},
function(x){//7B. JPO imm8
  return jcond('~f&4', x);
},
function(x){//7C. JL imm8
  return jcond('f^f>>4&128', x);
},
function(x){//7D. JGE imm8
  return jcond('~f^f>>4&128', x);
},
function(x){//7C. JLE imm8
  return jcond('f^f>>4&128||f&64', x); //abcd || es mas rapido que |?
},
function(x){//7D. JG imm8
  return jcond('~f^f>>4&128&&~f&64', x);
},

function(x){//80. OP r/m8, imm8
  return op0(x, x>>3&7, 'm[cs+(pc++&65535)]');
},
function(x){//81. OP r/m16, imm16
  return op1(x, x>>3&7, 'm[cs+(pc++&65535)]|m[cs+(pc++&65535)]<<8', 'm[cs+(pc++&65535)]', 'm[cs+(pc++&65535)]');
},
function(x){//82. OP r/m8, imm8 (alias 80)
  return op0(x, x>>3&7, 'm[cs+(pc++&65535)]');
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){//8A. MOV r8, r/m8
  return ebwo(x>>3&7, x<192?'m[ds+'+ea[x>>6][x&7]+']':ebr[x&7], '');
},
function(x){//8B. MOV r16, r/m16
  return x<192 ? ewwo(x>>3&7, 'm[ds+'+ea0[x>>6][x&7]+']|m[ds+(t+1&65535)]<<8', 
                       'm[ds+'+ea0[x>>6][x&7]+']', 'm[ds+(t+1&65535)]', '')
               : ewwo(x>>3&7, ewr[x&7], ewrl[x&7], ewrh[x&7], '');
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},

function(x){//90. NOP
  return 'st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//91. XCHG AX, CX
  return 't=al;al=cl;cl=t;t=ah;ah=ch;ch=t;st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//92. XCHG AX, DX
  return 't=al;al=dl;dl=t;t=ah;ah=dh;dh=t;st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//93. XCHG AX, BX
  return 't=al|ah<<8;al=bx&255;ah=bx>>8;bx=t;st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//94. XCHG AX, SP
  return 't=al|ah<<8;al=sp&255;ah=sp>>8;sp=t;st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//95. XCHG AX, BP
  return 't=al|ah<<8;al=bp&255;ah=bp>>8;bp=t;st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//96. XCHG AX, SI
  return 't=al|ah<<8;al=si&255;ah=si>>8;si=t;st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//97. XCHG AX, DI
  return 't=al|ah<<8;al=di&255;ah=di>>8;di=t;st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//98. CBW
  return 'ah=al&128?0:255;st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//99. CWD
  return 'dl=dh=ah&128?255:0;st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//9A. CALL seg:ofs
  return push('cs>>12', 'cs&4095>>4')+
         ';t='+x+'|m[cs+(pc++&65535)]<<8;'+
         'cs=m[cs+(pc++&65535)]<<4|m[cs+(pc++&65535)]<<12;'+
//         push('pc>>8&255', 'pc&255')+
         push('pc>>8', 'pc&255')+
         ';pc=t';
},
function(x){//9B. WAIT
  return 0
},
function(x){//9C. PUSHF
  return push('fh', 'f')+';st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//9D. POPF
  return 0
},
function(x){//9E. SAHF
  return 0
},
function(x){//9F. LAHF
  return 0
},

function(x){//A0. MOV AL, [imm16]
  return 0
},
function(x){//A1. MOV AX, [imm16]
  return 0
},
function(x){//A2. MOV [imm16], AL
  return 0
},
function(x){//A3. MOV [imm16], AX
  return 0
},
function(x){//A4. MOVSB
  return 0
},
function(x){//A5. MOVSW
  return 0
},
function(x){//A6. CMPSB
  return 0
},
function(x){//A7. CMPSW
  return 0
},
function(x){//A8. TEST AL, imm8
  return 0
},
function(x){//A9. TEST AX, imm16
  return 0
},
function(x){//AA. STOSB
  return 0
},
function(x){//AB. STOSW
  return 'm[wr(es+di++)]=al;'+
         'm[wr(es+(di++&65535))]=ah;'+
         'di&=65535;st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//AC. LODSB
  return 0
},
function(x){//AD. LODSW
  return 0
},
function(x){//AE. SCASB
  return 0
},
function(x){//AF. SCASW
  return 'di=di+2&65535;st++;g['+x+'|m[cs+(pc++&65535)]<<8]()'; //arreglar
},

function(x){//B0. MOV AL,imm
  return ebw(0, x);
},
function(x){//B1. MOV AH,imm
  return ebw(1, x);
},
function(x){//B2. MOV DL,imm
  return ebw(2, x);
},
function(x){//B3. MOV DH,imm
  return ebw(3, x);
},
function(x){//B4. MOV CL,imm
  return ebw(4, x);
},
function(x){//B5. MOV CH,imm
  return ebw(5, x);
},
function(x){//B6. MOV BL,imm
  return ebw(6, x);
},
function(x){//B7. MOV BH,imm
  return ebw(7, x);
},
function(x){//B8. MOV AX,imm
  return eww(0, '', x, 'm[cs+(pc++&65535)]');
},
function(x){//B9. MOV DX,imm
  return eww(1, '', x, 'm[cs+(pc++&65535)]');
},
function(x){//BA. MOV CX,imm
  return eww(2, '', x, 'm[cs+(pc++&65535)]');
},
function(x){//BB. MOV BX,imm
  return eww(3, x+'|m[cs+(pc++&65535)]<<8');
},
function(x){//BC. MOV SP,imm
  return eww(4, x+'|m[cs+(pc++&65535)]<<8');
},
function(x){//BD. MOV BP,imm
  return eww(5, x+'|m[cs+(pc++&65535)]<<8');
},
function(x){//BE. MOV SI,imm
  return eww(6, x+'|m[cs+(pc++&65535)]<<8');
},
function(x){//BF. MOV DI,imm
  return eww(7, x+'|m[cs+(pc++&65535)]<<8');
},

function(x){//C0
  return 0
},
function(x){
  return 0
},
function(x){//C2. RET imm16
  return 0
},
function(x){//C3. RET
  return popw('pc');
},
function(x){//C4. LES r16, r/m16
  return 0
},
function(x){//C5. LDS r16, r/m16
  return 0
},
function(x){//C6. MOV r/m8, imm8
  return 0
},
function(x){//C7: MOV r/m16, imm16
  return 0
},
function(x){//C8
  return 0
},
function(x){
  return 0
},
function(x){//CA. RETF imm16
  return 0
},
function(x){//CB. RETF
  return 0
},
function(x){//CC. INT 3
  return 0
},
function(x){//CD. INT imm8
  return '';
},
function(x){//CE. INTO
  return 0
},
function(x){//CF. IRET
  return 0
},

function(x){//D0. ROL, ROR, RCL, RCR, SHL, SHR, SAR r/m8, 1
  return 0
},
function(x){//D1. ROL, ROR, RCL, RCR, SHL, SHR, SAR r/m16, 1
  return 0
},
function(x){//D2. ROL, ROR, RCL, RCR, SHL, SHR, SAR r/m8, CL
  return 0
},
function(x){//D3. ROL, ROR, RCL, RCR, SHL, SHR, SAR r/m16, CL
  return 0
},
function(x){//D4. AAM imm8
  return 0
},
function(x){//D5. AAD imm8
  return 0
},
function(x){//D6. SETALC
  return 0
},
function(x){//D7. XLAT
  return 'al=m[ds+(bx+al&65535)];st++;g['+x+'|m[cs+(pc++&65535)]<<8]()';
},
function(x){//D8. ESC (floating point)
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},
function(x){
  return 0
},

function(x){//E0. LOOPNZ imm8
  return 0
},
function(x){//E1. LOOPZ imm8
  return 0
},
function(x){//E2. LOOP imm8
  return 'if(!cl--)'+
           'cl=255,'+
           'ch=ch-1&255;'+
         'pc+=cl|ch?se('+x+'):0';  //probar con if
},
function(x){//E3. JCXZ imm8
  return 0
},
function(x){//E4. IN AL, imm8
  return 0
},
function(x){//E5. IN AX, imm8
  return 0
},
function(x){//E6. OUT imm8, AL
  return 0
},
function(x){//E7. OUT imm8, AX
  return 0
},
function(x){//E8. CALL imm16
  return 't=('+x+'|m[cs+(pc++&65535)]<<8)+pc;'+
         push('pc>>8', 'pc&255')+
         ';pc=t';
},
function(x){//E9. JMP imm16
  return 0
},
function(x){//EA. JMP seg:ofs 
  return 0
},
function(x){//EB. JMP imm8
  return 'pc+=se('+x+')';
},
function(x){//EC. IN AL, DX
  return 0
},
function(x){//ED. IN AX, DX
  return 0
},
function(x){//EE. OUT DX, AL
  return 0
},
function(x){//EF. OUT DX, AX
  return 0
},

function(x){//F0. LOCK
  return 0
},
function(x){
  return 0
},
function(x){//F2. REPNZ
  return 0
},
function(x){//F3. REP
  return 0
},
function(x){//F4. HLT
  return 0
},
function(x){//F5. CMC
  return 0
},
function(x){//F6. OP r/m8, imm8    TEST,(TEST),NOT,NEG,MUL,IMUL,DIV,IDIV
  switch(x>>3&7){
    case 0://TEST
    case 1://TEST 
      return 'f=szp['+(x<192?'m[ds+'+ea[x>>6][x&7]+']':ebr[x&7])+'&m[cs+(pc++&65535)]]';
    case 2://NOT
      return x<192?'m[wr(ds+'+ea[x>>6][x&7]+')]^=255':(~x&3?ebr[x&7]:'bx')+'^='+(~x&7?'255':'65280');
    case 3://NEG
      return 'u=-(f='+(x<192?'m[ds+'+ea0[x>>6][x&7]+']':ebr[x&7])+');'+
             'f=u>>8&1|szp[u&=255]|(f&u&128)<<4|(f^u)&16;'+
             (x<192?'m[wr(ds+t)]=u':ebw(x&7,'u'));
    case 4://MUL
      return 'al*='+(x<192?'m[ds+'+ea[x>>6][x&7]+']':ebr[x&7])+
             ';ah=al>>8;'+
             'f=f&148|(ah?2112:0)|((al&=255)?0:64)';
    case 5://IMUL,DIV,IDIV
      return 0;
    case 6: return 0;
    case 7: return 0;
  }
},
function(x){//F7. OP r/m8, imm16   TEST,(TEST),NOT,NEG,MUL,IMUL,DIV,IDIV
  switch(x>>3&7){
    case 0://TEST falta word
    case 1://TEST falta word 
      return 'f=szp['+(x<192?'m[ds+'+ea[x>>6][x&7]+']':ebr[x&7])+'&m[cs+(pc++&65535)]]';
    case 2://NOT falta word
      return x<192?'m[wr(ds+'+ea[x>>6][x&7]+')]^=255':(~x&3?ebr[x&7]:'bx')+'^='+(~x&7?'255':'65280');
    case 3://NEG falta word
      return 'u=-(f='+(x<192?'m[ds+'+ea0[x>>6][x&7]+']':ebr[x&7])+');'+
             'f=u>>8&1|szp[u&=255]|(f&u&128)<<4|(f^u)&16;'+
             (x<192?'m[wr(ds+t)]=u':ebw(x&7,'u'));
    case 4://MUL
      return 'u=(al|ah<<8)*('+(x<192?'m[ds+'+ea0[x>>6][x&7]+']|m[ds+(t+1&65535)]<<8':ewr[x&7])+');'+
             'dh=u>>24;'+
             'dl=u>>16&255;'+
             'ah=u>>8&255;'+
             'al=u&255;'+
             'f=f&148|(u>>16?2112:0)|(u&65535?0:64)';
    case 5://IMUL,DIV,IDIV
      return 0;
    case 6: return 0;
    case 7: return 0;
  }
},
function(x){//F8. CLC
  return 0
},
function(x){//F9. STC
  return 0
},
function(x){//FA. CLI
  return 0
},
function(x){//FB. STI
  return 0
},
function(x){//FC. CLD
  return 0
},
function(x){//FD. STD
  return 0
},
function(x){//FE. INC, DEC r/m8
  return 0
},
function(x){//FF. OP r/m16    INC,DEC,CALL16,CALL32,JMP16,JMP32,PUSH
  switch(x>>3&7){
    case 0://INC
      return x<192 ? 'if((u=++m[wr(ds+'+ea0[x>>6][x&7]+')])>>8)'+
                       'm[ds+t]=0,'+
                       'm[wr(v=ds+(t+1&65535))]=m[v]+1&255,'+
                       'f=f&1|(v=m[v])&128|(v!=128?0:2048)|(v?20:84);'+
                     'else '+
                       'f=f&1|m[ds+(t+1&65535)]&128|(u&15?0:16)|par[u]'
                   : ((x&7)<4?incw0(ewrh[x&7], ewrl[x&7]):incw1(ewr[x&7]));
    case 1://DEC
      return x<192 ? 'if((u=--m[wr(ds+'+ea0[x>>6][x&7]+')])>>8)'+
                       'm[ds+t]=255,'+
                       'm[wr(v=ds+(t+1&65535))]=m[v]-1&255,'+
                       'f=f&1|(v=m[v])&128|(v!=127?0:2048)|(v?20:84);'+
                     'else '+
                       'f=f&1|(v=m[ds+(t+1&65535)])&128|(u&15?0:16)|(u|v?par[u]:64|par[u])'
                   : ((x&7)<4?decw0(ewrh[x&7], ewrl[x&7]):decw1(ewr[x&7]));
    case 2://CALL16
      return x<192 ? 't=m[ds+'+ea0[x>>6][x&7]+']|m[ds+(t+1&65535)]<<8;'+
                     push('pc>>8', 'pc&255')+';pc=t'
                   : push('pc>>8', 'pc&255')+';pc='+ewr[x&7];

    case 3://CALL32 falta
      return 0;
    case 4://JMP16 falta
      return 0;
    case 5://JMP32 falta
      return 0;
    case 6: return 0;
    case 7: return 0;
  }
},

];

g= [];
for (i=0; i<256; i++){
//  console.log(i);
  for (j=0; j<256; j++)
    g[i|j<<8]= new Function(p[i](j));

}

//alert(g[0x018B]);

console.log('init');

function hex(n){
  var h= '0123456789ABCDEF';
  return h[n>>12]+h[n>>8&15]+h[n>>4&15]+h[n&15];
}
