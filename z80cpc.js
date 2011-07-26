sz= [];                              // sign, zero, flag5, flag3 table
par= [];                             // parity table
szp= [];                             // sign, zero... parity table
szi= [];                             // sign, zero... increment table
szd= [];                             // sign, zero... decrement table
se= [];                              // sign extend

function z80init() {
  for(j= 0; j<256; j++)
    se[j]= j < 128 ? j : j-256,
    sz[j]= j & 168,
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
    szp[j]= sz[j] | par[j],
    szi[j]= sz[j] | ( j == 128 ? 4 : 0 ) | ( j&15 ? 0 : 16 ),
    szd[j]= sz[j] | ( j == 127 ? 6 : 2 ) | ( j+1 & 15 ? 0 : 16 );
  szi[0] |= 64;
  szd[0] |= 64;
  sz[0] |= 64;
  szp[0] |= 64;
}

function z80interrupt() {
  if(iff){
    if(halted)
      pc++,
      halted= 0;
    iff= 0;
//    wb(sp-1&65535, pc >> 8);
//    wb(sp=sp-2&65535, pc);
    mw[sp-1>>14&3][sp-1&16383]= pc >> 8 & 255;
    mw[(sp=sp-2&65535)>>14][sp&16383]= pc & 255;
    r++;
    switch(im) {
      case 1:
        st++;
      case 0: 
        pc= 56;
        st+= 3;
        break;
      default:
        t= 255 | i << 8;
        pc= m[t>>14][t&16383] | m[++t>>14][t&16383] << 8;
        st+= 5;
        break;
    }
  }
}

function nop(n){
  return n-1?'st+='+n:'st++';
}

function inc(r) {
  return 'st++;'+
  'f=f&1|szi['+r+'='+r+'+1&255]';
}

function dec(r) {
  return 'st++;'+
  'f=f&1|szd['+r+'='+r+'-1&255]';
}

function incdecphl(n) {
  return 'st+=3;'+
  't=mw[t=h>>6][u=l|h<<8&16383]=m[t][u]'+n+'1&255;'+
  'f=f&1|sz'+(n=='+'?'i':'d')+'[t]';
}

function incdecpi(a, b) {
  return 'st+=5;'+
  't=(se[m[pc>>14&3][pc++&16383]]+('+a+'l|'+a+'h<<8))&65535;'+
  'f=f&1|sz'+(b=='+'?'i':'d')+'[mw[u=t>>14][t&=16383]=m[u][t]'+b+'1&255]';
}

function incw(a, b) {
  return 'st+=2;'+
  'if(++'+b+'>>8)'+
    b+'=0,'+
    a+'='+a+'+1&255';
}

function decw(a, b) {
  return 'st+=2;'+
  'if(!'+b+'--)'+
    b+'=255,'+
    a+'='+a+'-1&255';
}

function ldpr(a, b, r) {
  return 'st+=2;'+
  'mw['+a+'>>6]['+b+'|'+a+'<<8&16383]='+r;
}

function ldpri(a, b) {
  return 'st+=4;'+
  'mw[(t=(se[m[pc>>14&3][pc++&16383]]+('+b+'l|'+b+'h<<8))&65535)>>14][t&16383]='+a;
}

function ldrp(a, b, r) {
  return 'st+=2;'+
  r+'=m['+a+'>>6]['+b+'|'+a+'<<8&16383]';
}

function ldrpi(a, b) {
  return 'st+=4;'+
  a+'=m[(t=se[m[pc>>14&3][pc++&16383]]+('+b+'l|'+b+'h<<8))>>14&3][t&16383]';
}

function ldrrim(a, b) {
  return 'st+=3;'+
  b+'=m[pc>>14&3][pc++&16383];'+
  a+'=m[pc>>14&3][pc++&16383]';
}

function ldrim(r) {
  return 'st+=2;'+
  r+'=m[pc>>14&3][pc++&16383]';
}

function ldpin(r) {
  return 'st+=4;'+
  'mw[(t=(se[m[pc>>14&3][pc++&16383]]+('+r+'l|'+r+'h<<8))&65535)>>14][t&16383]=m[pc>>14&3][pc++&16383]';
}

function addrrrr(a, b, c, d) {
  return 'st+=3;'+
  't='+b+'+'+d+'+('+a+'+'+c+'<<8);'+
  'f=f&196|t>>16|t>>8&40|(t>>8^'+a+'^'+c+')&16;'+
  a+'=t>>8&255;'+
  b+'=t&255';
}

function addisp(r) {
  return 'st+=3;'+
  't=sp+('+r+'l|'+r+'h<<8);'+
  'f=f&196|t>>16|t>>8&40|(t>>8^sp>>8^'+r+'h)&16;'+
  r+'h=t>>8&255;'+
  r+'l=t&255';
}

function jrc(c) {
  return 'st+=2;'+
  'if('+c+')'+
    'pc++;'+
  'else '+
    'st++,'+
    'pc+=se[m[pc>>14&3][pc&16383]]+1'
}

function jpc(c) {
  return 'st+=3;'+
  'if('+c+')'+
    'pc+=2;'+
  'else '+
    'pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8';
}

function callc(c) {
  return 'if('+c+')'+
    'st+=3,'+
    'pc+=2;'+
  'else '+
    'st+=5,'+
    't=pc+2,'+
    'pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8,'+
    'mw[--sp>>14&3][sp&16383]=t>>8&255,'+
    'mw[(sp=sp-1&65535)>>14][sp&16383]=t&255';
//    'wb(--sp&65535,t>>8),'+
//    'wb(sp=sp-1&65535,t)';
}

function retc(c) {
  return 'if('+c+')'+
    'st++;'+
  'else '+
    'st+=3,'+
    'pc=m[sp>>14][sp&16383]|m[sp+1>>14&3][sp+1&16383]<<8,'+
    'sp=sp+2&65535';
}

function ret(n){
  return 'st+='+n+
  ';pc=m[sp>>14][sp&16383]|m[sp+1>>14&3][sp+1&16383]<<8;'+
  'sp=sp+2&65535';
}

function ldpnnrr(a, b, n) {
  return 'st+='+n+';'+
  'mw[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383]='+b+';'+
  'mw[t+1>>14&3][t+1&16383]='+a;
}

function ldrrpnn(a, b, n) {
  return 'st+='+n+';'+
  b+'=m[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383];'+
  a+'=m[t+1>>14&3][t+1&16383]';
}

function ldrr(a, b, n){
  return (n-1?'st+='+n:'st++')+';'+
  a+'='+b;
}

function add(a, b, n){
  return (n-1?'st+='+n:'st++')+
  ';f=a+'+a+';'+
  'f=f>>8|(f^a^'+b+')&16|((f^a)&(f^'+b+')&128)>>5|sz[a=f&255]';
}

function adc(a, b, n){
  return (n-1?'st+='+n:'st++')+
  ';f=a+'+a+'+(f&1);'+
  'f=f>>8|(f^a^'+b+')&16|((f^a)&(f^'+b+')&128)>>5|sz[a=f&255]';
}

function sub(a, b, n){
  return (n-1?'st+='+n:'st++')+
  ';f=a-'+a+';'+
  'f=f>>8&1|2|(f^a^'+b+')&16|((f^a)&(a^'+b+')&128)>>5|sz[a=f&255]';
}

function sbc(a, b, n){
  return (n-1?'st+='+n:'st++')+
  ';f=a-'+a+'-(f&1);'+
  'f=f>>8&1|2|(f^a^'+b+')&16|((f^a)&(a^'+b+')&128)>>5|sz[a=f&255]';
}

function and(r, n){
  return (n-1?'st+='+n:'st++')+
  ';f=16|szp[a&='+r+']';
}

function xoror(r, n){
  return (n-1?'st+='+n:'st++')+
  ';f=szp[a'+r+']';
}

function cp(a, b, n){
  return (n-1?'st+='+n:'st++')+
  ';f=a-'+a+';'+
  'f=f>>8&1|2|(f^a^'+b+')&16|((f^a)&(a^'+b+')&128)>>5|'+b+'&40|sz[f&255]&215';
}

function push(a, b){
  return 'st+=3;'+
  'mw[--sp>>14&3][sp&16383]='+a+';'+
  'mw[(sp=sp-1&65535)>>14][sp&16383]='+b;
}

function pop(a, b){
  return 'st+=3;'+
  b+'=m[sp>>14][sp&16383];'+
  a+'=m[sp+1>>14&3][sp+1&16383];'+
  'sp=sp+2&65535';
}

function rst(n){
  return 'st+=3;'+
  'mw[--sp>>14&3][sp&16383]=pc>>8&255;'+
  'mw[(sp=sp-1&65535)>>14][sp&16383]=pc&255;'+
//  'wb(--sp&65535,pc>>8);'+
//  'wb(sp=sp-1&65535,pc);'+
  'pc='+n;
}

function rlc(r){
  return 'st+=2;'+
  r+'='+r+'<<1&255|'+r+'>>7;'+
  'f='+r+'&1|szp['+r+']';
}

function rrc(r){
  return 'st+=2;'+
  r+'='+r+'>>1|'+r+'<<7&128;'+
  'f='+r+'>>7|szp['+r+']';
}

function rl(r){
  return 'st+=2;'+
  'j='+r+';'+
  r+'='+r+'<<1&255|f&1;'+
  'f=j>>7|szp['+r+']';
}

function rr(r){
  return 'st+=2;'+
  'j='+r+';'+
  r+'='+r+'>>1|f<<7&128;'+
  'f=j&1|szp['+r+']';
}

function sla(r){
  return 'st+=2;'+
  'f='+r+'>>7;'+
  r+'='+r+'<<1&255;'+
  'f|=szp['+r+']';
}

function sra(r){
  return 'st+=2;'+
  'f='+r+'&1;'+
  r+'='+r+'&128|'+r+'>>1;'+
  'f|=szp['+r+']';
}

function sll(r){
  return 'st+=2;'+
  'f='+r+'>>7;'+
  r+'='+r+'<<1&255|1;'+
  'f|=szp['+r+']';
}

function srl(r){
  return 'st+=2;'+
  'f='+r+'&1;'+
  r+'>>=1;'+
  'f|=szp['+r+']';
}

function bit(n, r){
  return 'st+=2;'+
  'f=f&1|'+r+'&40|('+r+'&'+n+'?16:84)'+(n&128 ? '|'+r+'&128' : '');
}

function biti(n){
  return 'st+=2;'+
  'f=f&1|u>>8&40|(t&'+n+'?16:84)'+(n&128 ? '|t&128' : '');
}

function bithl(n){
  return 'st+=3;'+
  'f=f&1|(t=m[h>>6][l|h<<8&16383])&40|(t&'+n+'?16:84)'+(n&128 ? '|t&128' : '');
}

function res(n, r){
  return 'st+=2;'+
  r+'&='+n;
}

function reshl(n){
  return 'st+=4;'+
  'mw[t=h>>6][u=l|h<<8&16383]=m[t][u]&'+n;
}

function set(n, r){
  return 'st+=2;'+
  r+'|='+n;
}

function sethl(n){
  return 'st+=4;'+
  'mw[t=h>>6][u=l|h<<8&16383]=m[t][u]|'+n;
}

function inr(r){
  return 'st+=4;'+
  r+'=rp(c|b<<8);'+
  'f=f&1|szp['+r+']';
}

function outr(r){
  return 'st+=4;'+
  'wp(c|b<<8,'+r+')';
}

function sbchlrr(a, b) {
  return 'st+=4;'+
  'f='+(a=='h'?'':'l-'+b+'+(h-'+a+'<<8)')+'-(f&1);'+
  'l=f&255;'+
  'f=f>>16&1|(f>>8^h^'+a+')&16|((f>>8^h)&(h^'+a+')&128)>>5|(h=f>>8&255)&168|(l|h?2:66)';
}

function adchlrr(a, b) {
  return 'st+=4;'+
  'f=l+'+b+'+(h+'+a+'<<8)+(f&1);'+
  'l=f&255;'+
  'f=f>>16|(f>>8^h^'+a+')&16|((f>>8^h)&(f>>8^'+a+')&128)>>5|(h=f>>8&255)&168|(l|h?0:64)';
}

function neg(){
  return 'st+=2;'+
  'f=(a?3:2)|(-a^a)&16|(-a&a&128)>>5|sz[a=-a&255]';
}

function ldair(r){
  return 'st+=3;'+
  'a='+r+';'+
  'f=f&1|sz[a]|iff<<2';
}

function ldid(i, r){
  return 'st+=5;'+
  't=mw[d>>6][e|d<<8&16383]=m[h>>6][l|h<<8&16383];'+
  'if(!c--)'+
    'c=255,'+
    'b=b-1&255;'+
  'if('+(i?'++e>>8':'!e--')+')'+
    'e='+(i?'0':'255')+','+
    'd=d'+(i?'+':'-')+'1&255;'+
  'if('+(i?'++l>>8':'!l--')+')'+
    'l='+(i?'0':'255')+','+
    'h=h'+(i?'+':'-')+'1&255;'+
  'f=f&193|(b|c?4:0)|(t+=a)&8|t<<4&32;'+
  (r?';if(c|b)st++,pc-=2':'');
}

function cpid(i, r){
  return 'st+=4;'+
  't=a-(u=m[h>>6][l|h<<8&16383]);'+
  'if(!c--)'+
    'c=255,'+
    'b=b-1&255;'+
  'if('+(i?'++l>>8':'!l--')+')'+
    'l='+(i?'0':'255')+','+
    'h=h'+(i?'+':'-')+'1&255;'+
  'f=f&1|(b|c?6:2)|(t^a^u)&16|(t?t&128:64);'+
  'if(f&16)'+
    't--;'+
  'f|=t&8|t<<4&32'+
  (r?';if((f&68)==4)st++,pc-=2':'');
}

function inid(i, r){
  return 'st+=5;'+
  't=mw[h>>6][l|h<<8&16383]=rp(c|b<<8);'+
  'b=b-1&255;'+
  'if('+(i?'++l>>8':'!l--')+')'+
    'l='+(i?'0':'255')+','+
    'h=h'+(i?'+':'-')+'1&255;'+
  'u=t+c'+(i?'+':'-')+'1&255;'+
  'f=t>>6&2|(u<t?17:0)|par[u&7^b]|sz[b]'+
  (r?';if(b)st++,pc-=2':'');
}

function otid(i, r){
  return 'st+=5;'+
  'wp(c|b<<8,t=m[h>>6][l|h<<8&16383]);'+
  'b=b-1&255;'+
  'if('+(i?'++l>>8':'!l--')+')'+
    'l='+(i?'0':'255')+','+
    'h=h'+(i?'+':'-')+'1&255;'+
  'u=t+l&255;'+
  'f=t>>6&2|(u<t?17:0)|par[u&7^b]|sz[b]'+
  (r?';if(b)st++,pc-=2':'');
}

function exspi(r){
  return 'st+=5;'+
  'v=m[t=sp>>14][u=sp&16383];'+
  'mw[t][u]='+r+'l;'+
  r+'l=v;'+
  'v=m[t=sp+1>>14&3][u=sp+1&16383];'+
  'mw[t][u]='+r+'h;'+
  r+'h=v';
}

function ldsppci(a, b){
  return (a=='sp'?'st+=2':'st++')+';'+
  a+'='+b+'l|'+b+'h<<8';
}

p=[
nop(1),                   // NOP
ldrrim('b', 'c'),         // LD BC,nn
ldpr('b', 'c', 'a'),      // LD (BC),A
incw('b', 'c'),           // INC BC
inc('b'),                 // INC B
dec('b'),                 // DEC B
ldrim('b'),               // LD B,n
'st++;a=a<<1&255|a>>7;f=f&196|a&41',// RLCA
'st++;t=a;a=a_;a_=t;t=f;f=f_;f_=t',// EX AF,AF'
addrrrr('h', 'l', 'b', 'c'),  // ADD HL,BC
ldrp('b', 'c', 'a'),      // LD A,(BC)
decw('b', 'c'),           // DEC BC
inc('c'),                 // INC C
dec('c'),                 // DEC C
ldrim('c'),               // LD C,n
'st++;f=f&196|a&1|a>>1&40;a=a>>1|a<<7&128',// RRCA
'st+=3;if(b=b-1&255)st++,pc+=se[m[pc>>14&3][pc&16383]]+1;else pc++',// DJNZ
ldrrim('d', 'e'),         // LD DE,nn
ldpr('d', 'e', 'a'),      // LD (DE),A
incw('d', 'e'),           // INC DE
inc('d'),                 // INC D
dec('d'),                 // DEC D
ldrim('d'),               // LD D,n
't=a;st++;a=a<<1&255|f&1;f=f&196|a&40|t>>7',// RLA
'st+=3;pc+=se[m[pc>>14&3][pc&16383]]+1',// JR
addrrrr('h', 'l', 'd', 'e'),// ADD HL,DE
ldrp('d', 'e', 'a'),      // LD A,(DE)
decw('d', 'e'),           // DEC DE
inc('e'),                 // INC E
dec('e'),                 // DEC E
ldrim('e'),               // LD E,n
'st++;t=a;a=a>>1|f<<7&128;f=f&196|a&40|t&1',// RRA
jrc('f&64'),              // JR NZ,s8
ldrrim('h', 'l'),         // LD HL,nn
ldpnnrr('h', 'l', 5),     // LD (nn),HL
incw('h', 'l'),           // INC HL
inc('h'),                 // INC H
dec('h'),                 // DEC H
ldrim('h'),               // LD H,n
'st++;u=f&16||(a&15)>9?6:0;if(f&1||a>153)u|=96;if(a>153)f|=1;f=f&2?f&1|2|((t=a-u)^a^u)&16|szp[a=t&255]:f&1|((t=a+u)^a^u)&16|szp[a=t&255]',// DAA
jrc('~f&64'),             // JR Z,s8
addrrrr('h', 'l', 'h', 'l'),  // ADD HL,HL
ldrrpnn('h', 'l', 5),     // LD HL,(nn)
decw('h', 'l'),           // DEC HL
inc('l'),                 // INC L
dec('l'),                 // DEC L
ldrim('l'),               // LD L,n
'st++;a^=255;f=f&197|a&40|18',// CPL
jrc('f&1'),               // JR NC,s8
'st+=3;sp=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8',// LD SP,nn
'st+=4;mw[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383]=a',// LD (nn),A
'st+=2;sp=sp+1&65535',    // INC SP
incdecphl('+'),           // INC (HL)
incdecphl('-'),           // DEC (HL)
'st+=3;mw[h>>6][l|h<<8&16383]=m[pc>>14&3][pc++&16383]', // LD (HL),N
'st++;f=f&196|a&40|1',    // SCF
jrc('~f&1'),              // JR C,s8
addisp(''),               // ADD HL,SP
'st+=4;a=m[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383]',// LD A,(nn)
'st+=2;sp=sp-1&65535',    // DEC SP
inc('a'),                 // INC A
dec('a'),                 // DEC A
ldrim('a'),               // LD A,n
'st++;f=f&196|(f&1?16:1)|a&40',// CCF
nop(1),                   // LD B,B
ldrr('b', 'c', 1),        // LD B,C
ldrr('b', 'd', 1),        // LD B,D
ldrr('b', 'e', 1),        // LD B,E
ldrr('b', 'h', 1),        // LD B,H
ldrr('b', 'l', 1),        // LD B,L
ldrp('h', 'l', 'b'),      // LD B,(HL)
ldrr('b', 'a', 1),        // LD B,C
ldrr('c', 'b', 1),        // LD C,B
nop(1),                   // LD C,C
ldrr('c', 'd', 1),        // LD C,D
ldrr('c', 'e', 1),        // LD C,E
ldrr('c', 'h', 1),        // LD C,H
ldrr('c', 'l', 1),        // LD C,L
ldrp('h', 'l', 'c'),      // LD C,(HL)
ldrr('c', 'a', 1),        // LD C,A
ldrr('d', 'b', 1),        // LD D,B
ldrr('d', 'c', 1),        // LD D,C
nop(1),                   // LD D,D
ldrr('d', 'e', 1),        // LD D,E
ldrr('d', 'h', 1),        // LD D,H
ldrr('d', 'l', 1),        // LD D,L
ldrp('h', 'l', 'd'),      // LD D,(HL)
ldrr('d', 'a', 1),        // LD D,A
ldrr('e', 'b', 1),        // LD E,B
ldrr('e', 'c', 1),        // LD E,C
ldrr('e', 'd', 1),        // LD E,D
nop(1),                   // LD E,E
ldrr('e', 'h', 1),        // LD E,H
ldrr('e', 'l', 1),        // LD E,L
ldrp('h', 'l', 'e'),      // LD E,(HL)
ldrr('e', 'a', 1),        // LD E,A
ldrr('h', 'b', 1),        // LD H,B
ldrr('h', 'c', 1),        // LD H,C
ldrr('h', 'd', 1),        // LD H,D
ldrr('h', 'e', 1),        // LD H,E
nop(1),                   // LD H,H
ldrr('h', 'l', 1),        // LD H,L
ldrp('h', 'l', 'h'),      // LD H,(HL)
ldrr('h', 'a', 1),        // LD H,A
ldrr('l', 'b', 1),        // LD L,B
ldrr('l', 'c', 1),        // LD L,C
ldrr('l', 'd', 1),        // LD L,D
ldrr('l', 'e', 1),        // LD L,E
ldrr('l', 'h', 1),        // LD L,H
nop(1),                   // LD L,L
ldrp('h', 'l', 'l'),      // LD L,(HL)
ldrr('l', 'a', 1),        // LD L,A
ldpr('h', 'l', 'b'),      // LD (HL),B
ldpr('h', 'l', 'c'),      // LD (HL),C
ldpr('h', 'l', 'd'),      // LD (HL),D
ldpr('h', 'l', 'e'),      // LD (HL),E
ldpr('h', 'l', 'h'),      // LD (HL),H
ldpr('h', 'l', 'l'),      // LD (HL),L
'st++;halted=1;pc--',     // HALT
ldpr('h', 'l', 'a'),      // LD (HL),A
ldrr('a', 'b', 1),        // LD A,B
ldrr('a', 'c', 1),        // LD A,C
ldrr('a', 'd', 1),        // LD A,D
ldrr('a', 'e', 1),        // LD A,E
ldrr('a', 'h', 1),        // LD A,H
ldrr('a', 'l', 1),        // LD A,L
ldrp('h', 'l', 'a'),      // LD A,(HL)
nop(1),                   // LD A,A
add('b', 'b', 1),         // ADD A,B
add('c', 'c', 1),         // ADD A,C
add('d', 'd', 1),         // ADD A,D
add('e', 'e', 1),         // ADD A,E
add('h', 'h', 1),         // ADD A,H
add('l', 'l', 1),         // ADD A,L
add('(t=m[h>>6][l|h<<8&16383])', 't', 2),// ADD A,(HL)
add('a', 'a', 1),         // ADD A,A
adc('b', 'b', 1),         // ADC A,B
adc('c', 'c', 1),         // ADC A,C
adc('d', 'd', 1),         // ADC A,D
adc('e', 'e', 1),         // ADC A,E
adc('h', 'h', 1),         // ADC A,H
adc('l', 'l', 1),         // ADC A,L
adc('(t=m[h>>6][l|h<<8&16383])', 't', 2),// ADC A,(HL)
adc('a', 'a', 1),         // ADC A,A
sub('b', 'b', 1),         // SUB A,B
sub('c', 'c', 1),         // SUB A,C
sub('d', 'd', 1),         // SUB A,D
sub('e', 'e', 1),         // SUB A,E
sub('h', 'h', 1),         // SUB A,H
sub('l', 'l', 1),         // SUB A,L
sub('(t=m[h>>6][l|h<<8&16383])', 't', 2),// SUB A,(HL)
sub('a', 'a', 1),         // SUB A,A
sbc('b', 'b', 1),         // SBC A,B
sbc('c', 'c', 1),         // SBC A,C
sbc('d', 'd', 1),         // SBC A,D
sbc('e', 'e', 1),         // SBC A,E
sbc('h', 'h', 1),         // SBC A,H
sbc('l', 'l', 1),         // SBC A,L
sbc('(t=m[h>>6][l|h<<8&16383])', 't', 2),// SBC A,(HL)
sbc('a', 'a', 1),         // SBC A,A
and('b', 1),              // AND B
and('c', 1),              // AND C
and('d', 1),              // AND D
and('e', 1),              // AND E
and('h', 1),              // AND H
and('l', 1),              // AND L
and('m[h>>6][l|h<<8&16383]', 2),      // AND (HL)
and('a', 1),              // AND A
xoror('^=b', 1),          // XOR B
xoror('^=c', 1),          // XOR C
xoror('^=d', 1),          // XOR D
xoror('^=e', 1),          // XOR E
xoror('^=h', 1),          // XOR H
xoror('^=l', 1),          // XOR L
xoror('^=m[h>>6][l|h<<8&16383]', 2),// XOR (HL)
xoror('^=a', 1),          // XOR A
xoror('|=b', 1),          // OR B
xoror('|=c', 1),          // OR C
xoror('|=d', 1),          // OR D
xoror('|=e', 1),          // OR E
xoror('|=h', 1),          // OR H
xoror('|=l', 1),          // OR L
xoror('|=m[h>>6][l|h<<8&16383]', 2),// OR (HL)
xoror('|=a', 1),          // OR A
cp('b', 'b', 1),          // CP B
cp('c', 'c', 1),          // CP C
cp('d', 'd', 1),          // CP D
cp('e', 'e', 1),          // CP E
cp('h', 'h', 1),          // CP H
cp('l', 'l', 1),          // CP L
cp('(t=m[h>>6][l|h<<8&16383])', 't', 2),// CP (HL)
cp('a', 'a', 1),          // CP A
retc('f&64'),             // RET NZ
pop('b', 'c'),            // POP BC
jpc('f&64'),              // JP NZ
'st+=3;pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8',// JP nn
callc('f&64'),            // CALL NZ
push('b', 'c'),           // PUSH BC
add('(t=m[pc>>14&3][pc++&16383])', 't', 7),// ADD A,n
rst(0),                   // RST 0x00
retc('~f&64'),            // RET Z
ret(3),                   // RET
jpc('~f&64'),             // JP Z
'r++;g[768+m[pc>>14&3][pc++&16383]]()',//op cb
callc('~f&64'),           // CALL Z
'st+=5;t=pc+2;pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8;mw[--sp>>14&3][sp&16383]=t>>8&255;mw[(sp=sp-1&65535)>>14][sp&16383]=t&255',// CALL NN
//'st+=5;t=pc+2;pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8;wb(--sp&65535,t>>8);wb(sp=sp-1&65535,t)',// CALL NN
adc('(t=m[pc>>14&3][pc++&16383])', 't', 7),// ADC A,n
rst(8),                   // RST 0x08
retc('f&1'),              // RET NC
pop('d', 'e'),            // POP DE
jpc('f&1'),               // JP NC
'st+=3;wp(m[pc>>14&3][pc++&16383]|a<<8,a)',// OUT (n),A
callc('f&1'),             // CALL NC
push('d', 'e'),           // PUSH DE
sub('(t=m[pc>>14&3][pc++&16383])', 't', 7),// SUB A,n
rst(16),                  // RST 0x10
retc('~f&1'),             // RET C
'st++;t=b;b=b_;b_=t;t=c;c=c_;c_=t;t=d;d=d_;d_=t;t=e;e=e_;e_=t;t=h;h=h_;h_=t;t=l;l=l_;l_=t',// EXX
jpc('~f&1'),              // JP C
'st+=3;a=rp(m[pc>>14&3][pc++&16383]|a<<8)',// IN A,(n)
callc('~f&1'),            // CALL C
'st++;r++;g[256+m[pc>>14&3][pc++&16383]]()',//op dd
sbc('(t=m[pc>>14&3][pc++&16383])', 't', 7),// SBC A,n
rst(24),                  // RST 0x18
retc('f&4'),              // RET PO
pop('h', 'l'),            // POP HL
jpc('f&4'),               // JP PO
exspi(''),                // EX (SP,IY
callc('f&4'),             // CALL PO
push('h', 'l'),           // PUSH HL
and('m[pc>>14&3][pc++&16383]', 7),// AND A,n
rst(32),                  // RST 0x20
retc('~f&4'),             // RET PE
ldsppci('pc', ''),        // JP (HL)
jpc('~f&4'),              // JP PE
'st++;t=d;d=h;h=t;t=e;e=l;l=t',// EX DE,HL
callc('~f&4'),            // CALL PE
'r++;g[1280+m[pc>>14&3][pc++&16383]]()',// op ed
xoror('^=m[pc>>14&3][pc++&16383]', 7),// XOR A,n
rst(40),                  // RST 0x28
retc('f&128'),            // RET P
pop('a', 'f'),            // POP AF
jpc('f&128'),             // JP P
'st++;iff=0',             // DI
callc('f&128'),           // CALL P
push('a', 'f'),           // PUSH AF
xoror('|=m[pc>>14&3][pc++&16383]', 7),// OR A,n
rst(48),                  // RST 0x30
retc('~f&128'),           // RET M
ldsppci('sp', ''),        // LD SP,HL
jpc('~f&128'),            // JP M
'st++;iff=1',             // EI
callc('~f&128'),          // CALL M
'st++;r++;g[512+m[pc>>14&3][pc++&16383]]()',// op fd
cp('(t=m[pc>>14&3][pc++&16383])', 't', 7),// CP A,n
rst(56),                  // RST 0x38

nop(1),                   // NOP
ldrrim('b', 'c'),         // LD BC,nn
ldpr('b', 'c', 'a'),      // LD (BC),A
incw('b', 'c'),           // INC BC
inc('b'),                 // INC B
dec('b'),                 // DEC B
ldrim('b'),               // LD B,n
'st++;a=a<<1&255|a>>7;f=f&196|a&41',// RLCA
'st++;t=a;a=a_;a_=t;t=f;f=f_;f_=t',// EX AF,AF'
addrrrr('xh', 'xl', 'b', 'c'),  // ADD IX,BC
ldrp('b', 'c', 'a'),      // LD A,(BC)
decw('b', 'c'),           // DEC BC
inc('c'),                 // INC C
dec('c'),                 // DEC C
ldrim('c'),               // LD C,n
'st++;f=f&196|a&1|a>>1&40;a=a>>1|a<<7&128',// RRCA
'st+=3;if(b=b-1&255)st++,pc+=se[m[pc>>14&3][pc&16383]]+1;else pc++',// DJNZ
ldrrim('d', 'e'),         // LD DE,nn
ldpr('d', 'e', 'a'),      // LD (DE),A
incw('d', 'e'),           // INC DE
inc('d'),                 // INC D
dec('d'),                 // DEC D
ldrim('d'),               // LD D,n
't=a;st++;a=a<<1&255|f&1;f=f&196|a&40|t>>7',// RLA
'st+=3;pc+=se[m[pc>>14&3][pc&16383]]+1',// JR
addrrrr('xh', 'xl', 'd', 'e'), // ADD IX,DE
ldrp('d', 'e', 'a'),      // LD A,(DE)
decw('d', 'e'),           // DEC DE
inc('e'),                 // INC E
dec('e'),                 // DEC E
ldrim('e'),               // LD E,n
'st++;t=a;a=a>>1|f<<7&128;f=f&196|a&40|t&1',// RRA
jrc('f&64'),              // JR NZ,s8
ldrrim('xh', 'xl'),       // LD IX,nn
ldpnnrr('xh', 'xl', 5),   // LD (nn),IX
incw('xh', 'xl'),         // INC IX
inc('xh'),                // INC IXH
dec('xh'),                // DEC IXH
ldrim('xh'),              // LD IXH,n
'st++;u=f&16||(a&15)>9?6:0;if(f&1||a>153)u|=96;if(a>153)f|=1;f=f&2?f&1|2|((t=a-u)^a^u)&16|szp[a=t&255]:f&1|((t=a+u)^a^u)&16|szp[a=t&255]',// DAA
jrc('~f&64'),             // JR Z,s8
addrrrr('xh', 'xl', 'xh', 'xl'),  // ADD IX,IX
ldrrpnn('xh', 'xl', 5),   // LD IX,(nn)
decw('xh', 'xl'),         // DEC IX
inc('xl'),                // INC IXL
dec('xl'),                // DEC IXL
ldrim('xl'),              // LD IXL,n
'st++;a^=255;f=f&197|a&40|18',// CPL
jrc('f&1'),               // JR NC,s8
'st+=3;sp=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8',// LD SP,nn
'st+=4;mw[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383]=a',// LD (nn),A
'st+=2;sp=sp+1&65535',    // INC SP
incdecpi('x', '+'),       // INC (IX+d)
incdecpi('x', '-'),       // DEC (IX+d)
ldpin('x'),               // LD (IX+d),n
'st++;f=f&196|a&40|1',    // SCF
jrc('~f&1'),              // JR C,s8
addisp('x'),              // ADD IX,SP
'st+=4;a=m[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383]',// LD A,(nn)
'st+=2;sp=sp-1&65535',    // DEC SP
inc('a'),                 // INC A
dec('a'),                 // DEC A
ldrim('a'),            // LD A,n
'st++;f=f&196|(f&1?16:1)|a&40',// CCF
nop(1),                   // LD B,B
ldrr('b', 'c', 1),        // LD B,C
ldrr('b', 'd', 1),        // LD B,D
ldrr('b', 'e', 1),        // LD B,E
ldrr('b', 'xh', 1),       // LD B,IXH
ldrr('b', 'xl', 1),       // LD B,IXL
ldrpi('b', 'x'),          // LD B,(IX+d)
ldrr('b', 'a', 1),        // LD B,C
ldrr('c', 'b', 1),        // LD C,B
nop(1),                   // LD C,C
ldrr('c', 'd', 1),        // LD C,D
ldrr('c', 'e', 1),        // LD C,E
ldrr('c', 'xh', 1),       // LD C,IXH
ldrr('c', 'xl', 1),       // LD C,IXL
ldrpi('c', 'x'),          // LD C,(IX+d)
ldrr('c', 'a', 1),        // LD C,A
ldrr('d', 'b', 1),        // LD D,B
ldrr('d', 'c', 1),        // LD D,C
nop(1),                   // LD D,D
ldrr('d', 'e', 1),        // LD D,E
ldrr('d', 'xh', 1),       // LD D,IXH
ldrr('d', 'xl', 1),       // LD D,IXL
ldrpi('d', 'x'),          // LD D,(IX+d)
ldrr('d', 'a', 1),        // LD D,A
ldrr('e', 'b', 1),        // LD E,B
ldrr('e', 'c', 1),        // LD E,C
ldrr('e', 'd', 1),        // LD E,D
nop(1),                   // LD E,E
ldrr('e', 'xh', 1),       // LD E,IXH
ldrr('e', 'xl', 1),       // LD E,IXL
ldrpi('e', 'x'),          // LD E,(IX+d)
ldrr('e', 'a', 1),        // LD E,A
ldrr('xh', 'b', 1),       // LD IXH,B
ldrr('xh', 'c', 1),       // LD IXH,C
ldrr('xh', 'd', 1),       // LD IXH,D
ldrr('xh', 'e', 1),       // LD IXH,E
nop(1),                   // LD IXH,IXH
ldrr('xh', 'xl', 1),      // LD IXH,IXL
ldrpi('h', 'x'),          // LD H,(IX+d)
ldrr('xh', 'a', 1),       // LD IXH,A
ldrr('xl', 'b', 1),       // LD IXL,B
ldrr('xl', 'c', 1),       // LD IXL,C
ldrr('xl', 'd', 1),       // LD IXL,D
ldrr('xl', 'e', 1),       // LD IXL,E
ldrr('xl', 'xh', 1),      // LD IXL,IXH
nop(1),                   // LD IXL,IXL
ldrpi('l', 'x'),          // LD L,(IX+d)
ldrr('xl', 'a', 1),       // LD IXL,A
ldpri('b', 'x'),          // LD (IX+d),B
ldpri('c', 'x'),          // LD (IX+d),C
ldpri('d', 'x'),          // LD (IX+d),D
ldpri('e', 'x'),          // LD (IX+d),E
ldpri('h', 'x'),          // LD (IX+d),H
ldpri('l', 'x'),          // LD (IX+d),L
'st++;halted=1;pc--',     // HALT
ldpri('a', 'x'),          // LD (IX+d),A
ldrr('a', 'b', 1),        // LD A,B
ldrr('a', 'c', 1),        // LD A,C
ldrr('a', 'd', 1),        // LD A,D
ldrr('a', 'e', 1),        // LD A,E
ldrr('a', 'xh', 1),       // LD A,IXH
ldrr('a', 'xl', 1),       // LD A,IXL
ldrpi('a', 'x'),          // LD A,(IX+d)
nop(1),                   // LD A,A
add('b', 'b', 1),         // ADD A,B
add('c', 'c', 1),         // ADD A,C
add('d', 'd', 1),         // ADD A,D
add('e', 'e', 1),         // ADD A,E
add('xh', 'xh', 1),       // ADD A,IXH
add('xl', 'xl', 1),       // ADD A,IXL
add('(t=m[(u=se[m[pc>>14&3][pc++&16383]]+(xl|xh<<8))>>14&3][u&16383])', 't', 4),// ADD A,(IX+d)
add('a', 'a', 1),         // ADD A,A
adc('b', 'b', 1),         // ADC A,B
adc('c', 'c', 1),         // ADC A,C
adc('d', 'd', 1),         // ADC A,D
adc('e', 'e', 1),         // ADC A,E
adc('xh', 'xh', 1),       // ADC A,IXH
adc('xl', 'xl', 1),       // ADC A,IXL
adc('(t=m[(u=se[m[pc>>14&3][pc++&16383]]+(xl|xh<<8))>>14&3][u&16383])', 't', 4),// ADC A,(IX+d)
adc('a', 'a', 1),         // ADC A,A
sub('b', 'b', 1),         // SUB A,B
sub('c', 'c', 1),         // SUB A,C
sub('d', 'd', 1),         // SUB A,D
sub('e', 'e', 1),         // SUB A,E
sub('xh', 'xh', 1),       // SUB A,IXH
sub('xl', 'xl', 1),       // SUB A,IXL
sub('(t=m[(u=se[m[pc>>14&3][pc++&16383]]+(xl|xh<<8))>>14&3][u&16383])', 't', 4),// SUB A,(IX+d)
sub('a', 'a', 1),         // SUB A,A
sbc('b', 'b', 1),         // SBC A,B
sbc('c', 'c', 1),         // SBC A,C
sbc('d', 'd', 1),         // SBC A,D
sbc('e', 'e', 1),         // SBC A,E
sbc('xh', 'xh', 1),       // SBC A,IXH
sbc('xl', 'xl', 1),       // SBC A,IXL
sbc('(t=m[(u=se[m[pc>>14&3][pc++&16383]]+(xl|xh<<8))>>14&3][u&16383])', 't', 4),// SBC A,(IX+d)
sbc('a', 'a', 1),         // SBC A,A
and('b', 1),              // AND B
and('c', 1),              // AND C
and('d', 1),              // AND D
and('e', 1),              // AND E
and('xh', 1),             // AND IXH
and('xl', 1),             // AND IXL
and('m[(u=se[m[pc>>14&3][pc++&16383]]+(xl|xh<<8))>>14&3][u&16383]', 4),// AND (IX+d)
and('a', 1),              // AND A
xoror('^=b', 1),          // XOR B
xoror('^=c', 1),          // XOR C
xoror('^=d', 1),          // XOR D
xoror('^=e', 1),          // XOR E
xoror('^=xh', 1),         // XOR IXH
xoror('^=xl', 1),         // XOR IXL
xoror('^=m[(u=se[m[pc>>14&3][pc++&16383]]+(xl|xh<<8))>>14&3][u&16383]', 4),// XOR (IX+d)
xoror('^=a', 1),          // XOR A
xoror('|=b', 1),          // OR B
xoror('|=c', 1),          // OR C
xoror('|=d', 1),          // OR D
xoror('|=e', 1),          // OR E
xoror('|=xh', 1),         // OR IXH
xoror('|=xl', 1),         // OR IXL
xoror('|=m[(u=se[m[pc>>14&3][pc++&16383]]+(xl|xh<<8))>>14&3][u&16383]', 4),// OR (IX+d)
xoror('|=a', 1),          // OR A
cp('b', 'b', 1),          // CP B
cp('c', 'c', 1),          // CP C
cp('d', 'd', 1),          // CP D
cp('e', 'e', 1),          // CP E
cp('xh', 'xh', 1),        // CP IXH
cp('xl', 'xl', 1),        // CP IXL
cp('(t=m[(u=se[m[pc>>14&3][pc++&16383]]+(xl|xh<<8))>>14&3][u&16383])', 't', 4),// CP (IX+d)
cp('a', 'a', 1),          // CP A
retc('f&64'),             // RET NZ
pop('b', 'c'),            // POP BC
jpc('f&64'),              // JP NZ
'st+=3;pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8',// JP nn
callc('f&64'),            // CALL NZ
push('b', 'c'),           // PUSH BC
add('(t=m[pc>>14&3][pc++&16383])', 't', 7),// ADD A,n
rst(0),                   // RST 0x00
retc('~f&64'),            // RET Z
ret(3),                   // RET
jpc('~f&64'),             // JP Z
'st+=3;t=m[(u=se[m[pc>>14&3][pc++&16383]]+(xl|xh<<8))>>14&3][u&16383];g[1024+m[pc>>14&3][pc++&16383]]()',//op cb
callc('~f&64'),           // CALL Z
'st+=5;t=pc+2;pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8;mw[--sp>>14&3][sp&16383]=t>>8&255;mw[(sp=sp-1&65535)>>14][sp&16383]=t&255',// CALL NN
//'st+=5;t=pc+2;pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8;wb(--sp&65535,t>>8);wb(sp=sp-1&65535,t)',// CALL NN
adc('(t=m[pc>>14&3][pc++&16383])', 't', 7),// ADC A,n
rst(8),                   // RST 0x08
retc('f&1'),              // RET NC
pop('d', 'e'),            // POP DE
jpc('f&1'),               // JP NC
'st+=3;wp(m[pc>>14&3][pc++&16383]|a<<8,a)',// OUT (n),A
callc('f&1'),             // CALL NC
push('d', 'e'),           // PUSH DE
sub('(t=m[pc>>14&3][pc++&16383])', 't', 7),// SUB A,n
rst(16),                  // RST 0x10
retc('~f&1'),             // RET C
'st++;t=b;b=b_;b_=t;t=c;c=c_;c_=t;t=d;d=d_;d_=t;t=e;e=e_;e_=t;t=h;h=h_;h_=t;t=l;l=l_;l_=t',// EXX
jpc('~f&1'),              // JP C
'st+=3;a=rp(m[pc>>14&3][pc++&16383]|a<<8)',// IN A,(n)
callc('~f&1'),            // CALL C
nop(1),                   // op dd
sbc('(t=m[pc>>14&3][pc++&16383])', 't', 7),// SBC A,n
rst(24),                  // RST 0x18
retc('f&4'),              // RET PO
pop('xh', 'xl'),          // POP IX
jpc('f&4'),               // JP PO
exspi('x'),               // EX (SP,IX
callc('f&4'),             // CALL PO
push('xh', 'xl'),         // PUSH IX
and('m[pc>>14&3][pc++&16383]', 7),// AND A,n
rst(32),                  // RST 0x20
retc('~f&4'),             // RET PE
ldsppci('pc', 'x'),       // JP (IX)
jpc('~f&4'),              // JP PE
'st++;t=d;d=h;h=t;t=e;e=l;l=t',// EX DE,HL
callc('~f&4'),            // CALL PE
'r++;g[1280+m[pc>>14&3][pc++&16383]]()', //op ed
xoror('^=m[pc>>14&3][pc++&16383]', 7),// XOR A,n
rst(40),                  // RST 0x28
retc('f&128'),            // RET P
pop('a', 'f'),            // POP AF
jpc('f&128'),             // JP P
'st++;iff=0',             // DI
callc('f&128'),           // CALL P
push('a', 'f'),           // PUSH AF
xoror('|=m[pc>>14&3][pc++&16383]', 7),// OR A,n
rst(48),                  // RST 0x30
retc('~f&128'),           // RET M
ldsppci('sp', 'x'),       // LD SP,IX
jpc('~f&128'),            // JP M
'st++;iff=1',             // EI
callc('~f&128'),          // CALL M
nop(1),                   // op fd
cp('(t=m[pc>>14&3][pc++&16383])', 't', 7),// CP A,n
rst(56),                  // RST 0x38

nop(1),                   // NOP
ldrrim('b', 'c'),         // LD BC,nn
ldpr('b', 'c', 'a'),      // LD (BC),A
incw('b', 'c'),           // INC BC
inc('b'),                 // INC B
dec('b'),                 // DEC B
ldrim('b'),               // LD B,n
'st++;a=a<<1&255|a>>7;f=f&196|a&41',// RLCA
'st++;t=a;a=a_;a_=t;t=f;f=f_;f_=t',// EX AF,AF'
addrrrr('yh', 'yl', 'b', 'c'),  // ADD IY,BC
ldrp('b', 'c', 'a'),      // LD A,(BC)
decw('b', 'c'),           // DEC BC
inc('c'),                 // INC C
dec('c'),                 // DEC C
ldrim('c'),               // LD C,n
'st++;f=f&196|a&1|a>>1&40;a=a>>1|a<<7&128',// RRCA
'st+=3;if(b=b-1&255)st++,pc+=se[m[pc>>14&3][pc&16383]]+1;else pc++',// DJNZ
ldrrim('d', 'e'),         // LD DE,nn
ldpr('d', 'e', 'a'),      // LD (DE),A
incw('d', 'e'),           // INC DE
inc('d'),                 // INC D
dec('d'),                 // DEC D
ldrim('d'),               // LD D,n
't=a;st++;a=a<<1&255|f&1;f=f&196|a&40|t>>7',// RLA
'st+=3;pc+=se[m[pc>>14&3][pc&16383]]+1',// JR
addrrrr('yh', 'yl', 'd', 'e'), // ADD IY,DE
ldrp('d', 'e', 'a'),      // LD A,(DE)
decw('d', 'e'),           // DEC DE
inc('e'),                 // INC E
dec('e'),                 // DEC E
ldrim('e'),               // LD E,n
'st++;t=a;a=a>>1|f<<7&128;f=f&196|a&40|t&1',// RRA
jrc('f&64'),              // JR NZ,s8
ldrrim('yh', 'yl'),       // LD IY,nn
ldpnnrr('yh', 'yl', 5),   // LD (nn),IY
incw('yh', 'yl'),         // INC IY
inc('yh'),                // INC IYH
dec('yh'),                // DEC IYH
ldrim('yh'),              // LD IYH,n
'st++;u=f&16||(a&15)>9?6:0;if(f&1||a>153)u|=96;if(a>153)f|=1;f=f&2?f&1|2|((t=a-u)^a^u)&16|szp[a=t&255]:f&1|((t=a+u)^a^u)&16|szp[a=t&255]',// DAA
jrc('~f&64'),             // JR Z,s8
addrrrr('yh', 'yl', 'yh', 'yl'),  // ADD IY,IY
ldrrpnn('yh', 'yl', 5),   // LD IY,(nn)
decw('yh', 'yl'),         // DEC IY
inc('yl'),                // INC IYL
dec('yl'),                // DEC IYL
ldrim('yl'),              // LD IYL,n
'st++;a^=255;f=f&197|a&40|18',// CPL
jrc('f&1'),               // JR NC,s8
'st+=3;sp=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8',// LD SP,nn
'st+=4;mw[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383]=a',// LD (nn),A
'st+=2;sp=sp+1&65535',    // INC SP
incdecpi('y', '+'),       // INC (IY+d)
incdecpi('y', '-'),       // DEC (IY+d)
ldpin('y'),               // LD (IY+d),n
'st++;f=f&196|a&40|1',    // SCF
jrc('~f&1'),              // JR C,s8
addisp('y'),              // ADD IY,SP
'st+=4;a=m[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383]',// LD A,(nn)
'st+=2;sp=sp-1&65535',    // DEC SP
inc('a'),                 // INC A
dec('a'),                 // DEC A
ldrim('a'),            // LD A,n
'st++;f=f&196|(f&1?16:1)|a&40',// CCF
nop(1),                   // LD B,B
ldrr('b', 'c', 4),        // LD B,C
ldrr('b', 'd', 4),        // LD B,D
ldrr('b', 'e', 4),        // LD B,E
ldrr('b', 'yh', 4),       // LD B,IYH
ldrr('b', 'yl', 4),       // LD B,IYL
ldrpi('b', 'y'),          // LD B,(IY+d)
ldrr('b', 'a', 4),        // LD B,C
ldrr('c', 'b', 4),        // LD C,B
nop(1),                   // LD C,C
ldrr('c', 'd', 4),        // LD C,D
ldrr('c', 'e', 4),        // LD C,E
ldrr('c', 'yh', 4),       // LD C,IYH
ldrr('c', 'yl', 4),       // LD C,IYL
ldrpi('c', 'y'),          // LD C,(IY+d)
ldrr('c', 'a', 4),        // LD C,A
ldrr('d', 'b', 4),        // LD D,B
ldrr('d', 'c', 4),        // LD D,C
nop(1),                   // LD D,D
ldrr('d', 'e', 4),        // LD D,E
ldrr('d', 'yh', 4),       // LD D,IYH
ldrr('d', 'yl', 4),       // LD D,IYL
ldrpi('d', 'y'),          // LD D,(IY+d)
ldrr('d', 'a', 4),        // LD D,A
ldrr('e', 'b', 4),        // LD E,B
ldrr('e', 'c', 4),        // LD E,C
ldrr('e', 'd', 4),        // LD E,D
nop(1),                   // LD E,E
ldrr('e', 'yh', 4),       // LD E,IYH
ldrr('e', 'yl', 4),       // LD E,IYL
ldrpi('e', 'y'),          // LD E,(IY+d)
ldrr('e', 'a', 4),        // LD E,A
ldrr('yh', 'b', 4),       // LD IYH,B
ldrr('yh', 'c', 4),       // LD IYH,C
ldrr('yh', 'd', 4),       // LD IYH,D
ldrr('yh', 'e', 4),       // LD IYH,E
nop(1),                   // LD IYH,IYH
ldrr('yh', 'yl', 4),      // LD IYH,IYL
ldrpi('h', 'y'),          // LD H,(IY+d)
ldrr('yh', 'a', 4),       // LD IYH,A
ldrr('yl', 'b', 4),       // LD IYL,B
ldrr('yl', 'c', 4),       // LD IYL,C
ldrr('yl', 'd', 4),       // LD IYL,D
ldrr('yl', 'e', 4),       // LD IYL,E
ldrr('yl', 'yh', 4),      // LD IYL,IYH
nop(1),                   // LD IYL,IYL
ldrpi('l', 'y'),          // LD L,(IY+d)
ldrr('yl', 'a', 4),       // LD IYL,A
ldpri('b', 'y'),          // LD (IY+d),B
ldpri('c', 'y'),          // LD (IY+d),C
ldpri('d', 'y'),          // LD (IY+d),D
ldpri('e', 'y'),          // LD (IY+d),E
ldpri('h', 'y'),          // LD (IY+d),H
ldpri('l', 'y'),          // LD (IY+d),L
'st++;halted=1;pc--',     // HALT
ldpri('a', 'y'),          // LD (IY+d),A
ldrr('a', 'b', 4),        // LD A,B
ldrr('a', 'c', 4),        // LD A,C
ldrr('a', 'd', 4),        // LD A,D
ldrr('a', 'e', 4),        // LD A,E
ldrr('a', 'yh', 4),       // LD A,IYH
ldrr('a', 'yl', 4),       // LD A,IYL
ldrpi('a', 'y'),          // LD A,(IY+d)
nop(1),                   // LD A,A
add('b', 'b', 4),         // ADD A,B
add('c', 'c', 4),         // ADD A,C
add('d', 'd', 4),         // ADD A,D
add('e', 'e', 4),         // ADD A,E
add('yh', 'yh', 4),       // ADD A,IYH
add('yl', 'yl', 4),       // ADD A,IYL
add('(t=m[(u=se[m[pc>>14&3][pc++&16383]]+(yl|yh<<8))>>14&3][u&16383])', 't', 15),// ADD A,(IY+d)
add('a', 'a', 4),         // ADD A,A
adc('b', 'b', 4),         // ADC A,B
adc('c', 'c', 4),         // ADC A,C
adc('d', 'd', 4),         // ADC A,D
adc('e', 'e', 4),         // ADC A,E
adc('yh', 'yh', 4),       // ADC A,IYH
adc('yl', 'yl', 4),       // ADC A,IYL
adc('(t=m[(u=se[m[pc>>14&3][pc++&16383]]+(yl|yh<<8))>>14&3][u&16383])', 't', 15),// ADC A,(IY+d)
adc('a', 'a', 4),         // ADC A,A
sub('b', 'b', 4),         // SUB A,B
sub('c', 'c', 4),         // SUB A,C
sub('d', 'd', 4),         // SUB A,D
sub('e', 'e', 4),         // SUB A,E
sub('yh', 'yh', 4),       // SUB A,IYH
sub('yl', 'yl', 4),       // SUB A,IYL
sub('(t=m[(u=se[m[pc>>14&3][pc++&16383]]+(yl|yh<<8))>>14&3][u&16383])', 't', 15),// SUB A,(IY+d)
sub('a', 'a', 4),         // SUB A,A
sbc('b', 'b', 4),         // SBC A,B
sbc('c', 'c', 4),         // SBC A,C
sbc('d', 'd', 4),         // SBC A,D
sbc('e', 'e', 4),         // SBC A,E
sbc('yh', 'yh', 4),       // SBC A,IYH
sbc('yl', 'yl', 4),       // SBC A,IYL
sbc('(t=m[(u=se[m[pc>>14&3][pc++&16383]]+(yl|yh<<8))>>14&3][u&16383])', 't', 15),// SBC A,(IY+d)
sbc('a', 'a', 4),         // SBC A,A
and('b', 4),              // AND B
and('c', 4),              // AND C
and('d', 4),              // AND D
and('e', 4),              // AND E
and('yh', 4),             // AND IYH
and('yl', 4),             // AND IYL
and('m[(u=se[m[pc>>14&3][pc++&16383]]+(yl|yh<<8))>>14&3][u&16383]', 15),// AND (IY+d)
and('a', 4),              // AND A
xoror('^=b', 4),          // XOR B
xoror('^=c', 4),          // XOR C
xoror('^=d', 4),          // XOR D
xoror('^=e', 4),          // XOR E
xoror('^=yh', 4),         // XOR IYH
xoror('^=yl', 4),         // XOR IYL
xoror('^=m[(u=se[m[pc>>14&3][pc++&16383]]+(yl|yh<<8))>>14&3][u&16383]', 15),// XOR (IY+d)
xoror('^=a', 4),          // XOR A
xoror('|=b', 4),          // OR B
xoror('|=c', 4),          // OR C
xoror('|=d', 4),          // OR D
xoror('|=e', 4),          // OR E
xoror('|=yh', 4),         // OR IYH
xoror('|=yl', 4),         // OR IYL
xoror('|=m[(u=se[m[pc>>14&3][pc++&16383]]+(yl|yh<<8))>>14&3][u&16383]', 15),// OR (IY+d)
xoror('|=a', 4),          // OR A
cp('b', 'b', 4),          // CP B
cp('c', 'c', 4),          // CP C
cp('d', 'd', 4),          // CP D
cp('e', 'e', 4),          // CP E
cp('yh', 'yh', 4),        // CP IYH
cp('yl', 'yl', 4),        // CP IYL
cp('(t=m[(u=se[m[pc>>14&3][pc++&16383]]+(yl|yh<<8))>>14&3][u&16383])', 't', 15),// CP (IY+d)
cp('a', 'a', 4),          // CP A
retc('f&64'),             // RET NZ
pop('b', 'c'),            // POP BC
jpc('f&64'),              // JP NZ
'st+=3;pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8',// JP nn
callc('f&64'),            // CALL NZ
push('b', 'c'),           // PUSH BC
add('(t=m[pc>>14&3][pc++&16383])', 't', 7),// ADD A,n
rst(0),                   // RST 0x00
retc('~f&64'),            // RET Z
ret(3),                   // RET
jpc('~f&64'),             // JP Z
'st+=3;t=m[(u=se[m[pc>>14&3][pc++&16383]]+(yl|yh<<8))>>14&3][u&16383];g[1024+m[pc>>14&3][pc++&16383]]()',//op cb   abcd >>14&&3
callc('~f&64'),           // CALL Z
'st+=5;t=pc+2;pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8;mw[--sp>>14&3][sp&16383]=t>>8&255;mw[(sp=sp-1&65535)>>14][sp&16383]=t&255',// CALL NN
//'st+=5;t=pc+2;pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8;wb(--sp&65535,t>>8);wb(sp=sp-1&65535,t)',// CALL NN
adc('(t=m[pc>>14&3][pc++&16383])', 't', 7),// ADC A,n
rst(8),                   // RST 0x08
retc('f&1'),              // RET NC
pop('d', 'e'),            // POP DE
jpc('f&1'),               // JP NC
'st+=3;wp(m[pc>>14&3][pc++&16383]|a<<8,a)',// OUT (n),A
callc('f&1'),             // CALL NC
push('d', 'e'),           // PUSH DE
sub('(t=m[pc>>14&3][pc++&16383])', 't', 7),// SUB A,n
rst(16),                  // RST 0x10
retc('~f&1'),             // RET C
'st++;t=b;b=b_;b_=t;t=c;c=c_;c_=t;t=d;d=d_;d_=t;t=e;e=e_;e_=t;t=h;h=h_;h_=t;t=l;l=l_;l_=t',// EXX
jpc('~f&1'),              // JP C
'st+=3;a=rp(m[pc>>14&3][pc++&16383]|a<<8)',// IN A,(n)
callc('~f&1'),            // CALL C
nop(1),                   // op dd
sbc('(t=m[pc>>14&3][pc++&16383])', 't', 7),// SBC A,n
rst(24),                  // RST 0x18
retc('f&4'),              // RET PO
pop('yh', 'yl'),          // POP IY
jpc('f&4'),               // JP PO
exspi('y'),               // EX (SP,IY
callc('f&4'),             // CALL PO
push('yh', 'yl'),         // PUSH IY
and('m[pc>>14&3][pc++&16383]', 7),  // AND A,n
rst(32),                  // RST 0x20
retc('~f&4'),             // RET PE
ldsppci('pc', 'y'),       // JP (IY)
jpc('~f&4'),              // JP PE
'st++;t=d;d=h;h=t;t=e;e=l;l=t',// EX DE,HL
callc('~f&4'),            // CALL PE
'r++;g[1280+m[pc>>14&3][pc++&16383]]()',// op ed
xoror('^=m[pc>>14&3][pc++&16383]', 7),// XOR A,n
rst(40),                  // RST 0x28
retc('f&128'),            // RET P
pop('a', 'f'),            // POP AF
jpc('f&128'),             // JP P
'st++;iff=0',             // DI
callc('f&128'),           // CALL P
push('a', 'f'),           // PUSH AF
xoror('|=m[pc>>14&3][pc++&16383]', 7),// OR A,n
rst(48),                  // RST 0x30
retc('~f&128'),           // RET M
ldsppci('sp', 'y'),       // LD SP,IY
jpc('~f&128'),            // JP M
'st++;iff=1',             // EI
callc('~f&128'),          // CALL M
nop(1),                   // op fd
cp('(t=m[pc>>14&3][pc++&16383])', 't', 7),// CP A,n
rst(56),                  // RST 0x38

rlc('b'),                 // RLC B
rlc('c'),                 // RLC C
rlc('d'),                 // RLC D
rlc('e'),                 // RLC E
rlc('h'),                 // RLC H
rlc('l'),                 // RLC L
'st+=4;v=m[t=h>>6][u=l|h<<8&16383];'+rlc('v')+';mw[t][u]=v', // RLC (HL)
rlc('a'),                 // RLC A
rrc('b'),                 // RRC B
rrc('c'),                 // RRC C
rrc('d'),                 // RRC D
rrc('e'),                 // RRC E
rrc('h'),                 // RRC H
rrc('l'),                 // RRC L
'st+=4;v=m[t=h>>6][u=l|h<<8&16383];'+rrc('v')+';mw[t][u]=v',
rrc('a'),                 // RRC A
rl('b'),                  // RL B
rl('c'),                  // RL C
rl('d'),                  // RL D
rl('e'),                  // RL E
rl('h'),                  // RL H
rl('l'),                  // RL L
'st+=4;v=m[t=h>>6][u=l|h<<8&16383];'+rl('v')+';mw[t][u]=v',
rl('a'),                  // RL A
rr('b'),                  // RR B
rr('c'),                  // RR C
rr('d'),                  // RR D
rr('e'),                  // RR E
rr('h'),                  // RR H
rr('l'),                  // RR L
'st+=4;v=m[t=h>>6][u=l|h<<8&16383];'+rr('v')+';mw[t][u]=v',
rr('a'),                  // RR A
sla('b'),                 // SLA B
sla('c'),                 // SLA C
sla('d'),                 // SLA D
sla('e'),                 // SLA E
sla('h'),                 // SLA H
sla('l'),                 // SLA L
'st+=4;v=m[t=h>>6][u=l|h<<8&16383];'+sla('v')+';mw[t][u]=v',
sla('a'),                 // SLA A
sra('b'),                 // SRA B
sra('c'),                 // SRA C
sra('d'),                 // SRA D
sra('e'),                 // SRA E
sra('h'),                 // SRA H
sra('l'),                 // SRA L
'st+=4;v=m[t=h>>6][u=l|h<<8&16383];'+sra('v')+';mw[t][u]=v',
sra('a'),                 // SRA A
sll('b'),                 // SLL B
sll('c'),                 // SLL C
sll('d'),                 // SLL D
sll('e'),                 // SLL E
sll('h'),                 // SLL H
sll('l'),                 // SLL L
'st+=4;v=m[t=h>>6][u=l|h<<8&16383];'+sll('v')+';mw[t][u]=v',
sll('a'),                 // SLL A
srl('b'),                 // SRL B
srl('c'),                 // SRL C
srl('d'),                 // SRL D
srl('e'),                 // SRL E
srl('h'),                 // SRL H
srl('l'),                 // SRL L
'st+=4;v=m[t=h>>6][u=l|h<<8&16383];'+srl('v')+';mw[t][u]=v',
srl('a'),                 // SRL A
bit(1,'b'),              // BIT 0,B
bit(1,'c'),              // BIT 0,C
bit(1,'d'),              // BIT 0,D
bit(1,'e'),              // BIT 0,E
bit(1,'h'),              // BIT 0,H
bit(1,'l'),              // BIT 0,L
bithl(1),                 // BIT 0,(HL)
bit(1,'a'),              // BIT 0,A
bit(2,'b'),              // BIT 1,B
bit(2,'c'),              // BIT 1,C
bit(2,'d'),              // BIT 1,D
bit(2,'e'),              // BIT 1,E
bit(2,'h'),              // BIT 1,H
bit(2,'l'),              // BIT 1,L
bithl(2),                 // BIT 1,(HL)
bit(2,'a'),              // BIT 1,A
bit(4,'b'),              // BIT 2,B
bit(4,'c'),              // BIT 2,C
bit(4,'d'),              // BIT 2,D
bit(4,'e'),              // BIT 2,E
bit(4,'h'),              // BIT 2,H
bit(4,'l'),              // BIT 2,L
bithl(4),                 // BIT 2,(HL)
bit(4,'a'),              // BIT 2,A
bit(8,'b'),              // BIT 3,B
bit(8,'c'),              // BIT 3,C
bit(8,'d'),              // BIT 3,D
bit(8,'e'),              // BIT 3,E
bit(8,'h'),              // BIT 3,H
bit(8,'l'),              // BIT 3,L
bithl(8),                 // BIT 3,(HL)
bit(8,'a'),              // BIT 3,A
bit(16,'b'),             // BIT 4,B
bit(16,'c'),             // BIT 4,C
bit(16,'d'),             // BIT 4,D
bit(16,'e'),             // BIT 4,E
bit(16,'h'),             // BIT 4,H
bit(16,'l'),             // BIT 4,L
bithl(16),                // BIT 4,(HL)
bit(16,'a'),             // BIT 4,A
bit(32,'b'),             // BIT 5,B
bit(32,'c'),             // BIT 5,C
bit(32,'d'),             // BIT 5,D
bit(32,'e'),             // BIT 5,E
bit(32,'h'),             // BIT 5,H
bit(32,'l'),             // BIT 5,L
bithl(32),                // BIT 5,(HL)
bit(32,'a'),             // BIT 5,A
bit(64,'b'),             // BIT 6,B
bit(64,'c'),             // BIT 6,C
bit(64,'d'),             // BIT 6,D
bit(64,'e'),             // BIT 6,E
bit(64,'h'),             // BIT 6,H
bit(64,'l'),             // BIT 6,L
bithl(64),                // BIT 6,(HL)
bit(64,'a'),             // BIT 6,A
bit(128,'b'),            // BIT 7,B
bit(128,'c'),            // BIT 7,C
bit(128,'d'),            // BIT 7,D
bit(128,'e'),            // BIT 7,E
bit(128,'h'),            // BIT 7,H
bit(128,'l'),            // BIT 7,L
bithl(128),               // BIT 7,(HL)
bit(128,'a'),            // BIT 7,A
res(254,'b'),            // RES 0,B
res(254,'c'),            // RES 0,C
res(254,'d'),            // RES 0,D
res(254,'e'),            // RES 0,E
res(254,'h'),            // RES 0,H
res(254,'l'),            // RES 0,L
reshl(254),               // RES 0,(HL)
res(254,'a'),            // RES 0,A
res(253,'b'),            // RES 1,B
res(253,'c'),            // RES 1,C
res(253,'d'),            // RES 1,D
res(253,'e'),            // RES 1,E
res(253,'h'),            // RES 1,H
res(253,'l'),            // RES 1,L
reshl(253),               // RES 1,(HL)
res(253,'a'),            // RES 1,A
res(251,'b'),            // RES 2,B
res(251,'c'),            // RES 2,C
res(251,'d'),            // RES 2,D
res(251,'e'),            // RES 2,E
res(251,'h'),            // RES 2,H
res(251,'l'),            // RES 2,L
reshl(251),               // RES 2,(HL)
res(251,'a'),            // RES 2,A
res(247,'b'),            // RES 3,B
res(247,'c'),            // RES 3,C
res(247,'d'),            // RES 3,D
res(247,'e'),            // RES 3,E
res(247,'h'),            // RES 3,H
res(247,'l'),            // RES 3,L
reshl(247),               // RES 3,(HL)
res(247,'a'),            // RES 3,A
res(239,'b'),            // RES 4,B
res(239,'c'),            // RES 4,C
res(239,'d'),            // RES 4,D
res(239,'e'),            // RES 4,E
res(239,'h'),            // RES 4,H
res(239,'l'),            // RES 4,L
reshl(239),               // RES 4,(HL)
res(239,'a'),            // RES 4,A
res(223,'b'),            // RES 5,B
res(223,'c'),            // RES 5,C
res(223,'d'),            // RES 5,D
res(223,'e'),            // RES 5,E
res(223,'h'),            // RES 5,H
res(223,'l'),            // RES 5,L
reshl(223),               // RES 5,(HL)
res(223,'a'),            // RES 5,A
res(191,'b'),            // RES 6,B
res(191,'c'),            // RES 6,C
res(191,'d'),            // RES 6,D
res(191,'e'),            // RES 6,E
res(191,'h'),            // RES 6,H
res(191,'l'),            // RES 6,L
reshl(191),               // RES 6,(HL)
res(191,'a'),            // RES 6,A
res(127,'b'),            // RES 7,B
res(127,'c'),            // RES 7,C
res(127,'d'),            // RES 7,D
res(127,'e'),            // RES 7,E
res(127,'h'),            // RES 7,H
res(127,'l'),            // RES 7,L
reshl(127),               // RES 7,(HL)
res(127,'a'),            // RES 7,A
set(1,'b'),              // SET 0,B
set(1,'c'),              // SET 0,C
set(1,'d'),              // SET 0,D
set(1,'e'),              // SET 0,E
set(1,'h'),              // SET 0,H
set(1,'l'),              // SET 0,L
sethl(1),                 // SET 0,(HL)
set(1,'a'),              // SET 0,A
set(2,'b'),              // SET 1,B
set(2,'c'),              // SET 1,C
set(2,'d'),              // SET 1,D
set(2,'e'),              // SET 1,E
set(2,'h'),              // SET 1,H
set(2,'l'),              // SET 1,L
sethl(2),                 // SET 1,(HL)
set(2,'a'),              // SET 1,A
set(4,'b'),              // SET 2,B
set(4,'c'),              // SET 2,C
set(4,'d'),              // SET 2,D
set(4,'e'),              // SET 2,E
set(4,'h'),              // SET 2,H
set(4,'l'),              // SET 2,L
sethl(4),                 // SET 2,(HL)
set(4,'a'),              // SET 2,A
set(8,'b'),              // SET 3,B
set(8,'c'),              // SET 3,C
set(8,'d'),              // SET 3,D
set(8,'e'),              // SET 3,E
set(8,'h'),              // SET 3,H
set(8,'l'),              // SET 3,L
sethl(8),                 // SET 3,(HL)
set(8,'a'),              // SET 3,A
set(16,'b'),             // SET 4,B
set(16,'c'),             // SET 4,C
set(16,'d'),             // SET 4,D
set(16,'e'),             // SET 4,E
set(16,'h'),             // SET 4,H
set(16,'l'),             // SET 4,L
sethl(16),                // SET 4,(HL)
set(16,'a'),             // SET 4,A
set(32,'b'),             // SET 5,B
set(32,'c'),             // SET 5,C
set(32,'d'),             // SET 5,D
set(32,'e'),             // SET 5,E
set(32,'h'),             // SET 5,H
set(32,'l'),             // SET 5,L
sethl(32),                // SET 5,(HL)
set(32,'a'),             // SET 5,A
set(64,'b'),             // SET 6,B
set(64,'c'),             // SET 6,C
set(64,'d'),             // SET 6,D
set(64,'e'),             // SET 6,E
set(64,'h'),             // SET 6,H
set(64,'l'),             // SET 6,L
sethl(64),                // SET 6,(HL)
set(64,'a'),             // SET 6,A
set(128,'b'),            // SET 7,B
set(128,'c'),            // SET 7,C
set(128,'d'),            // SET 7,D
set(128,'e'),            // SET 7,E
set(128,'h'),            // SET 7,H
set(128,'l'),            // SET 7,L
sethl(128),               // SET 7,(HL)
set(128,'a'),            // SET 7,A

rlc('t')+';b=mw[u>>14][u&16383]=t',// LD B,RLC(IY+d)
rlc('t')+';c=mw[u>>14][u&16383]=t',// LD C,RLC(IY+d)
rlc('t')+';d=mw[u>>14][u&16383]=t',// LD D,RLC(IY+d)
rlc('t')+';e=mw[u>>14][u&16383]=t',// LD E,RLC(IY+d)
rlc('t')+';h=mw[u>>14][u&16383]=t',// LD H,RLC(IY+d)
rlc('t')+';l=mw[u>>14][u&16383]=t',// LD L,RLC(IY+d)
rlc('t')+';mw[u>>14][u&16383]=t',  // RLC(IY+d)
rlc('t')+';a=mw[u>>14][u&16383]=t',// LD A,RLC(IY+d)
rrc('t')+';b=mw[u>>14][u&16383]=t',// LD B,RRC(IY+d)
rrc('t')+';c=mw[u>>14][u&16383]=t',// LD C,RRC(IY+d)
rrc('t')+';d=mw[u>>14][u&16383]=t',// LD D,RRC(IY+d)
rrc('t')+';e=mw[u>>14][u&16383]=t',// LD E,RRC(IY+d)
rrc('t')+';h=mw[u>>14][u&16383]=t',// LD H,RRC(IY+d)
rrc('t')+';l=mw[u>>14][u&16383]=t',// LD L,RRC(IY+d)
rrc('t')+';mw[u>>14][u&16383]=t',  // RRC(IY+d)
rrc('t')+';a=mw[u>>14][u&16383]=t',// LD A,RRC(IY+d)
rl('t')+';b=mw[u>>14][u&16383]=t',// LD B,rl(IY+d)
rl('t')+';c=mw[u>>14][u&16383]=t',// LD C,rl(IY+d)
rl('t')+';d=mw[u>>14][u&16383]=t',// LD D,rl(IY+d)
rl('t')+';e=mw[u>>14][u&16383]=t',// LD E,rl(IY+d)
rl('t')+';h=mw[u>>14][u&16383]=t',// LD H,rl(IY+d)
rl('t')+';l=mw[u>>14][u&16383]=t',// LD L,rl(IY+d)
rl('t')+';mw[u>>14][u&16383]=t',  // rl(IY+d)
rl('t')+';a=mw[u>>14][u&16383]=t',// LD A,rl(IY+d)
rr('t')+';b=mw[u>>14][u&16383]=t',// LD B,rr(IY+d)
rr('t')+';c=mw[u>>14][u&16383]=t',// LD C,rr(IY+d)
rr('t')+';d=mw[u>>14][u&16383]=t',// LD D,rr(IY+d)
rr('t')+';e=mw[u>>14][u&16383]=t',// LD E,rr(IY+d)
rr('t')+';h=mw[u>>14][u&16383]=t',// LD H,rr(IY+d)
rr('t')+';l=mw[u>>14][u&16383]=t',// LD L,rr(IY+d)
rr('t')+';mw[u>>14][u&16383]=t',  // rr(IY+d)
rr('t')+';a=mw[u>>14][u&16383]=t',// LD A,rr(IY+d)
sla('t')+';b=mw[u>>14][u&16383]=t',// LD B,sla(IY+d)
sla('t')+';c=mw[u>>14][u&16383]=t',// LD C,sla(IY+d)
sla('t')+';d=mw[u>>14][u&16383]=t',// LD D,sla(IY+d)
sla('t')+';e=mw[u>>14][u&16383]=t',// LD E,sla(IY+d)
sla('t')+';h=mw[u>>14][u&16383]=t',// LD H,sla(IY+d)
sla('t')+';l=mw[u>>14][u&16383]=t',// LD L,sla(IY+d)
sla('t')+';mw[u>>14][u&16383]=t',  // sla(IY+d)
sla('t')+';a=mw[u>>14][u&16383]=t',// LD A,sla(IY+d)
sra('t')+';b=mw[u>>14][u&16383]=t',// LD B,sra(IY+d)
sra('t')+';c=mw[u>>14][u&16383]=t',// LD C,sra(IY+d)
sra('t')+';d=mw[u>>14][u&16383]=t',// LD D,sra(IY+d)
sra('t')+';e=mw[u>>14][u&16383]=t',// LD E,sra(IY+d)
sra('t')+';h=mw[u>>14][u&16383]=t',// LD H,sra(IY+d)
sra('t')+';l=mw[u>>14][u&16383]=t',// LD L,sra(IY+d)
sra('t')+';mw[u>>14][u&16383]=t',  // sra(IY+d)
sra('t')+';a=mw[u>>14][u&16383]=t',// LD A,sra(IY+d)
sll('t')+';b=mw[u>>14][u&16383]=t',// LD B,sll(IY+d)
sll('t')+';c=mw[u>>14][u&16383]=t',// LD C,sll(IY+d)
sll('t')+';d=mw[u>>14][u&16383]=t',// LD D,sll(IY+d)
sll('t')+';e=mw[u>>14][u&16383]=t',// LD E,sll(IY+d)
sll('t')+';h=mw[u>>14][u&16383]=t',// LD H,sll(IY+d)
sll('t')+';l=mw[u>>14][u&16383]=t',// LD L,sll(IY+d)
sll('t')+';mw[u>>14][u&16383]=t',  // sll(IY+d)
sll('t')+';a=mw[u>>14][u&16383]=t',// LD A,sll(IY+d)
srl('t')+';b=mw[u>>14][u&16383]=t',// LD B,srl(IY+d)
srl('t')+';c=mw[u>>14][u&16383]=t',// LD C,srl(IY+d)
srl('t')+';d=mw[u>>14][u&16383]=t',// LD D,srl(IY+d)
srl('t')+';e=mw[u>>14][u&16383]=t',// LD E,srl(IY+d)
srl('t')+';h=mw[u>>14][u&16383]=t',// LD H,srl(IY+d)
srl('t')+';l=mw[u>>14][u&16383]=t',// LD L,srl(IY+d)
srl('t')+';mw[u>>14][u&16383]=t',  // srl(IY+d)
srl('t')+';a=mw[u>>14][u&16383]=t',// LD A,srl(IY+d)
biti(1),             // BIT 0,(IY+d)
biti(1),             // BIT 0,(IY+d)
biti(1),             // BIT 0,(IY+d)
biti(1),             // BIT 0,(IY+d)
biti(1),             // BIT 0,(IY+d)
biti(1),             // BIT 0,(IY+d)
biti(1),             // BIT 0,(IY+d)
biti(1),             // BIT 0,(IY+d)
biti(2),             // BIT 1,(IY+d)
biti(2),             // BIT 1,(IY+d)
biti(2),             // BIT 1,(IY+d)
biti(2),             // BIT 1,(IY+d)
biti(2),             // BIT 1,(IY+d)
biti(2),             // BIT 1,(IY+d)
biti(2),             // BIT 1,(IY+d)
biti(2),             // BIT 1,(IY+d)
biti(4),             // BIT 2,(IY+d)
biti(4),             // BIT 2,(IY+d)
biti(4),             // BIT 2,(IY+d)
biti(4),             // BIT 2,(IY+d)
biti(4),             // BIT 2,(IY+d)
biti(4),             // BIT 2,(IY+d)
biti(4),             // BIT 2,(IY+d)
biti(4),             // BIT 2,(IY+d)
biti(8),             // BIT 3,(IY+d)
biti(8),             // BIT 3,(IY+d)
biti(8),             // BIT 3,(IY+d)
biti(8),             // BIT 3,(IY+d)
biti(8),             // BIT 3,(IY+d)
biti(8),             // BIT 3,(IY+d)
biti(8),             // BIT 3,(IY+d)
biti(8),             // BIT 3,(IY+d)
biti(16),            // BIT 4,(IY+d)
biti(16),            // BIT 4,(IY+d)
biti(16),            // BIT 4,(IY+d)
biti(16),            // BIT 4,(IY+d)
biti(16),            // BIT 4,(IY+d)
biti(16),            // BIT 4,(IY+d)
biti(16),            // BIT 4,(IY+d)
biti(16),            // BIT 4,(IY+d)
biti(32),            // BIT 5,(IY+d)
biti(32),            // BIT 5,(IY+d)
biti(32),            // BIT 5,(IY+d)
biti(32),            // BIT 5,(IY+d)
biti(32),            // BIT 5,(IY+d)
biti(32),            // BIT 5,(IY+d)
biti(32),            // BIT 5,(IY+d)
biti(32),            // BIT 5,(IY+d)
biti(64),            // BIT 6,(IY+d)
biti(64),            // BIT 6,(IY+d)
biti(64),            // BIT 6,(IY+d)
biti(64),            // BIT 6,(IY+d)
biti(64),            // BIT 6,(IY+d)
biti(64),            // BIT 6,(IY+d)
biti(64),            // BIT 6,(IY+d)
biti(64),            // BIT 6,(IY+d)
biti(128),           // BIT 7,(IY+d)
biti(128),           // BIT 7,(IY+d)
biti(128),           // BIT 7,(IY+d)
biti(128),           // BIT 7,(IY+d)
biti(128),           // BIT 7,(IY+d)
biti(128),           // BIT 7,(IY+d)
biti(128),           // BIT 7,(IY+d)
biti(128),           // BIT 7,(IY+d)
res(254,'t')+';b=mw[u>>14][u&16383]=t',// LD B,RES 0,(IY+d)
res(254,'t')+';c=mw[u>>14][u&16383]=t',// LD C,RES 0,(IY+d)
res(254,'t')+';d=mw[u>>14][u&16383]=t',// LD D,RES 0,(IY+d)
res(254,'t')+';e=mw[u>>14][u&16383]=t',// LD E,RES 0,(IY+d)
res(254,'t')+';h=mw[u>>14][u&16383]=t',// LD H,RES 0,(IY+d)
res(254,'t')+';l=mw[u>>14][u&16383]=t',// LD L,RES 0,(IY+d)
res(254,'t')+';mw[u>>14][u&16383]=t',  // RES 0,(IY+d)
res(254,'t')+';a=mw[u>>14][u&16383]=t',// LD A,RES 0,(IY+d)
res(253,'t')+';b=mw[u>>14][u&16383]=t',// LD B,RES 1,(IY+d)
res(253,'t')+';c=mw[u>>14][u&16383]=t',// LD C,RES 1,(IY+d)
res(253,'t')+';d=mw[u>>14][u&16383]=t',// LD D,RES 1,(IY+d)
res(253,'t')+';e=mw[u>>14][u&16383]=t',// LD E,RES 1,(IY+d)
res(253,'t')+';h=mw[u>>14][u&16383]=t',// LD H,RES 1,(IY+d)
res(253,'t')+';l=mw[u>>14][u&16383]=t',// LD L,RES 1,(IY+d)
res(253,'t')+';mw[u>>14][u&16383]=t',  // RES 1,(IY+d)
res(253,'t')+';a=mw[u>>14][u&16383]=t',// LD A,RES 1,(IY+d)
res(251,'t')+';b=mw[u>>14][u&16383]=t',// LD B,RES 2,(IY+d)
res(251,'t')+';c=mw[u>>14][u&16383]=t',// LD C,RES 2,(IY+d)
res(251,'t')+';d=mw[u>>14][u&16383]=t',// LD D,RES 2,(IY+d)
res(251,'t')+';e=mw[u>>14][u&16383]=t',// LD E,RES 2,(IY+d)
res(251,'t')+';h=mw[u>>14][u&16383]=t',// LD H,RES 2,(IY+d)
res(251,'t')+';l=mw[u>>14][u&16383]=t',// LD L,RES 2,(IY+d)
res(251,'t')+';mw[u>>14][u&16383]=t',  // RES 2,(IY+d)
res(251,'t')+';a=mw[u>>14][u&16383]=t',// LD A,RES 2,(IY+d)
res(247,'t')+';b=mw[u>>14][u&16383]=t',// LD B,RES 3,(IY+d)
res(247,'t')+';c=mw[u>>14][u&16383]=t',// LD C,RES 3,(IY+d)
res(247,'t')+';d=mw[u>>14][u&16383]=t',// LD D,RES 3,(IY+d)
res(247,'t')+';e=mw[u>>14][u&16383]=t',// LD E,RES 3,(IY+d)
res(247,'t')+';h=mw[u>>14][u&16383]=t',// LD H,RES 3,(IY+d)
res(247,'t')+';l=mw[u>>14][u&16383]=t',// LD L,RES 3,(IY+d)
res(247,'t')+';mw[u>>14][u&16383]=t',  // RES 3,(IY+d)
res(247,'t')+';a=mw[u>>14][u&16383]=t',// LD A,RES 3,(IY+d)
res(239,'t')+';b=mw[u>>14][u&16383]=t',// LD B,RES 4,(IY+d)
res(239,'t')+';c=mw[u>>14][u&16383]=t',// LD C,RES 4,(IY+d)
res(239,'t')+';d=mw[u>>14][u&16383]=t',// LD D,RES 4,(IY+d)
res(239,'t')+';e=mw[u>>14][u&16383]=t',// LD E,RES 4,(IY+d)
res(239,'t')+';h=mw[u>>14][u&16383]=t',// LD H,RES 4,(IY+d)
res(239,'t')+';l=mw[u>>14][u&16383]=t',// LD L,RES 4,(IY+d)
res(239,'t')+';mw[u>>14][u&16383]=t',  // RES 4,(IY+d)
res(239,'t')+';a=mw[u>>14][u&16383]=t',// LD A,RES 4,(IY+d)
res(223,'t')+';b=mw[u>>14][u&16383]=t',// LD B,RES 5,(IY+d)
res(223,'t')+';c=mw[u>>14][u&16383]=t',// LD C,RES 5,(IY+d)
res(223,'t')+';d=mw[u>>14][u&16383]=t',// LD D,RES 5,(IY+d)
res(223,'t')+';e=mw[u>>14][u&16383]=t',// LD E,RES 5,(IY+d)
res(223,'t')+';h=mw[u>>14][u&16383]=t',// LD H,RES 5,(IY+d)
res(223,'t')+';l=mw[u>>14][u&16383]=t',// LD L,RES 5,(IY+d)
res(223,'t')+';mw[u>>14][u&16383]=t',  // RES 5,(IY+d)
res(223,'t')+';a=mw[u>>14][u&16383]=t',// LD A,RES 5,(IY+d)
res(191,'t')+';b=mw[u>>14][u&16383]=t',// LD B,RES 6,(IY+d)
res(191,'t')+';c=mw[u>>14][u&16383]=t',// LD C,RES 6,(IY+d)
res(191,'t')+';d=mw[u>>14][u&16383]=t',// LD D,RES 6,(IY+d)
res(191,'t')+';e=mw[u>>14][u&16383]=t',// LD E,RES 6,(IY+d)
res(191,'t')+';h=mw[u>>14][u&16383]=t',// LD H,RES 6,(IY+d)
res(191,'t')+';l=mw[u>>14][u&16383]=t',// LD L,RES 6,(IY+d)
res(191,'t')+';mw[u>>14][u&16383]=t',  // RES 6,(IY+d)
res(191,'t')+';a=mw[u>>14][u&16383]=t',// LD A,RES 6,(IY+d)
res(127,'t')+';b=mw[u>>14][u&16383]=t',// LD B,RES 7,(IY+d)
res(127,'t')+';c=mw[u>>14][u&16383]=t',// LD C,RES 7,(IY+d)
res(127,'t')+';d=mw[u>>14][u&16383]=t',// LD D,RES 7,(IY+d)
res(127,'t')+';e=mw[u>>14][u&16383]=t',// LD E,RES 7,(IY+d)
res(127,'t')+';h=mw[u>>14][u&16383]=t',// LD H,RES 7,(IY+d)
res(127,'t')+';l=mw[u>>14][u&16383]=t',// LD L,RES 7,(IY+d)
res(127,'t')+';mw[u>>14][u&16383]=t',  // RES 7,(IY+d)
res(127,'t')+';a=mw[u>>14][u&16383]=t',// LD A,RES 7,(IY+d)
set(1,'t')+';b=mw[u>>14][u&16383]=t',  // LD B,SET 0,(IY+d)
set(1,'t')+';c=mw[u>>14][u&16383]=t',  // LD C,SET 0,(IY+d)
set(1,'t')+';d=mw[u>>14][u&16383]=t',  // LD D,SET 0,(IY+d)
set(1,'t')+';e=mw[u>>14][u&16383]=t',  // LD E,SET 0,(IY+d)
set(1,'t')+';h=mw[u>>14][u&16383]=t',  // LD H,SET 0,(IY+d)
set(1,'t')+';l=mw[u>>14][u&16383]=t',  // LD L,SET 0,(IY+d)
set(1,'t')+';mw[u>>14][u&16383]=t',    // SET 0,(IY+d)
set(1,'t')+';a=mw[u>>14][u&16383]=t',  // LD A,SET 0,(IY+d)
set(2,'t')+';b=mw[u>>14][u&16383]=t',  // LD B,SET 1,(IY+d)
set(2,'t')+';c=mw[u>>14][u&16383]=t',  // LD C,SET 1,(IY+d)
set(2,'t')+';d=mw[u>>14][u&16383]=t',  // LD D,SET 1,(IY+d)
set(2,'t')+';e=mw[u>>14][u&16383]=t',  // LD E,SET 1,(IY+d)
set(2,'t')+';h=mw[u>>14][u&16383]=t',  // LD H,SET 1,(IY+d)
set(2,'t')+';l=mw[u>>14][u&16383]=t',  // LD L,SET 1,(IY+d)
set(2,'t')+';mw[u>>14][u&16383]=t',    // SET 1,(IY+d)
set(2,'t')+';a=mw[u>>14][u&16383]=t',  // LD A,SET 1,(IY+d)
set(4,'t')+';b=mw[u>>14][u&16383]=t',  // LD B,SET 2,(IY+d)
set(4,'t')+';c=mw[u>>14][u&16383]=t',  // LD C,SET 2,(IY+d)
set(4,'t')+';d=mw[u>>14][u&16383]=t',  // LD D,SET 2,(IY+d)
set(4,'t')+';e=mw[u>>14][u&16383]=t',  // LD E,SET 2,(IY+d)
set(4,'t')+';h=mw[u>>14][u&16383]=t',  // LD H,SET 2,(IY+d)
set(4,'t')+';l=mw[u>>14][u&16383]=t',  // LD L,SET 2,(IY+d)
set(4,'t')+';mw[u>>14][u&16383]=t',    // SET 2,(IY+d)
set(4,'t')+';a=mw[u>>14][u&16383]=t',  // LD A,SET 2,(IY+d)
set(8,'t')+';b=mw[u>>14][u&16383]=t',  // LD B,SET 3,(IY+d)
set(8,'t')+';c=mw[u>>14][u&16383]=t',  // LD C,SET 3,(IY+d)
set(8,'t')+';d=mw[u>>14][u&16383]=t',  // LD D,SET 3,(IY+d)
set(8,'t')+';e=mw[u>>14][u&16383]=t',  // LD E,SET 3,(IY+d)
set(8,'t')+';h=mw[u>>14][u&16383]=t',  // LD H,SET 3,(IY+d)
set(8,'t')+';l=mw[u>>14][u&16383]=t',  // LD L,SET 3,(IY+d)
set(8,'t')+';mw[u>>14][u&16383]=t',    // SET 3,(IY+d)
set(8,'t')+';a=mw[u>>14][u&16383]=t',  // LD A,SET 3,(IY+d)
set(16,'t')+';b=mw[u>>14][u&16383]=t', // LD B,SET 4,(IY+d)
set(16,'t')+';c=mw[u>>14][u&16383]=t', // LD C,SET 4,(IY+d)
set(16,'t')+';d=mw[u>>14][u&16383]=t', // LD D,SET 4,(IY+d)
set(16,'t')+';e=mw[u>>14][u&16383]=t', // LD E,SET 4,(IY+d)
set(16,'t')+';h=mw[u>>14][u&16383]=t', // LD H,SET 4,(IY+d)
set(16,'t')+';l=mw[u>>14][u&16383]=t', // LD L,SET 4,(IY+d)
set(16,'t')+';mw[u>>14][u&16383]=t',   // SET 4,(IY+d)
set(16,'t')+';a=mw[u>>14][u&16383]=t', // LD A,SET 4,(IY+d)
set(32,'t')+';b=mw[u>>14][u&16383]=t', // LD B,SET 5,(IY+d)
set(32,'t')+';c=mw[u>>14][u&16383]=t', // LD C,SET 5,(IY+d)
set(32,'t')+';d=mw[u>>14][u&16383]=t', // LD D,SET 5,(IY+d)
set(32,'t')+';e=mw[u>>14][u&16383]=t', // LD E,SET 5,(IY+d)
set(32,'t')+';h=mw[u>>14][u&16383]=t', // LD H,SET 5,(IY+d)
set(32,'t')+';l=mw[u>>14][u&16383]=t', // LD L,SET 5,(IY+d)
set(32,'t')+';mw[u>>14][u&16383]=t',   // SET 5,(IY+d)
set(32,'t')+';a=mw[u>>14][u&16383]=t', // LD A,SET 5,(IY+d)
set(64,'t')+';b=mw[u>>14][u&16383]=t', // LD B,SET 6,(IY+d)
set(64,'t')+';c=mw[u>>14][u&16383]=t', // LD C,SET 6,(IY+d)
set(64,'t')+';d=mw[u>>14][u&16383]=t', // LD D,SET 6,(IY+d)
set(64,'t')+';e=mw[u>>14][u&16383]=t', // LD E,SET 6,(IY+d)
set(64,'t')+';h=mw[u>>14][u&16383]=t', // LD H,SET 6,(IY+d)
set(64,'t')+';l=mw[u>>14][u&16383]=t', // LD L,SET 6,(IY+d)
set(64,'t')+';mw[u>>14][u&16383]=t',   // SET 6,(IY+d)
set(64,'t')+';a=mw[u>>14][u&16383]=t', // LD A,SET 6,(IY+d)
set(128,'t')+';b=mw[u>>14][u&16383]=t',// LD B,SET 7,(IY+d)
set(128,'t')+';c=mw[u>>14][u&16383]=t',// LD C,SET 7,(IY+d)
set(128,'t')+';d=mw[u>>14][u&16383]=t',// LD D,SET 7,(IY+d)
set(128,'t')+';e=mw[u>>14][u&16383]=t',// LD E,SET 7,(IY+d)
set(128,'t')+';h=mw[u>>14][u&16383]=t',// LD H,SET 7,(IY+d)
set(128,'t')+';l=mw[u>>14][u&16383]=t',// LD L,SET 7,(IY+d)
set(128,'t')+';mw[u>>14][u&16383]=t',  // SET 7,(IY+d)
set(128,'t')+';a=mw[u>>14][u&16383]=t',// LD A,SET 7,(IY+d)

nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
inr('b'),                 // IN B,(C)
outr('b'),                // OUT (C,B
sbchlrr('b', 'c'),        // SBC HL,BC
ldpnnrr('b', 'c', 6),     // LD (NN),BC
neg(),                    // NEG
ret(4),                   // RETN
'st+=2;im=0',             // IM 0
ldrr('i', 'a', 2),        // LD I,A
inr('c'),                 // IN C,(C)
outr('c'),                // OUT (C,C
adchlrr('b', 'c'),        // ADC HL,BC
ldrrpnn('b', 'c', 6),     // LD BC,(NN)
neg(),                    // NEG
ret(4),                   // RETI
'st+=2;im=0',             // IM 0
ldrr('r=r7', 'a', 2),     // LD R,A
inr('d'),                 // IN D,(C)
outr('d'),                // OUT (C,D
sbchlrr('d', 'e'),        // SBC HL,DE
ldpnnrr('d', 'e', 6),     // LD (NN),DE
neg(),                    // NEG
ret(4),                   // RETN
'st+=2;im=1',             // IM 1
ldair('i'),               // LD A,I
inr('e'),                 // IN E,(C)
outr('e'),                // OUT (C,E
adchlrr('d', 'e'),        // ADC HL,DE
ldrrpnn('d', 'e', 6),     // LD DE,(NN)
neg(),                    // NEG
ret(4),                   // RETI
'st+=2;im=2',             // IM 2
ldair('r&127|r7&128'),    // LD A,R
inr('h'),                 // IN H,(C)
outr('h'),                // OUT (C,H
sbchlrr('h', 'l'),        // SBC HL,HL
ldpnnrr('h', 'l', 6),     // LD (NN),HL
neg(),                    // NEG
ret(4),                   // RETN
'st+=2;im=0',             // IM 0
'st+=5;v=m[t=h>>6][u=l|h<<8&16383];mw[t][u]=a<<4&240|v>>4;a=a&240|v&15;f=f&1|szp[a]',// RRD
inr('l'),                 // IN L,(C)
outr('l'),                // OUT (C,L
adchlrr('h', 'l'),        // ADC HL,HL
ldrrpnn('h', 'l', 6),     // LD HL,(NN)
neg(),                    // NEG
ret(4),                   // RETI
'st+=2;im=0',             // IM 0
'st+=5;v=m[t=h>>6][u=l|h<<8&16383];mw[t][u]=v<<4&240|a&15;a=a&240|v>>4;f=f&1|szp[a]',// RLD
inr('t'),                 // IN X,(C)
outr('0'),                // OUT (C),X
'st+=4;f=(l|h<<8)-sp-(f&1);l=f&255;f=f>>16&1|(f>>8^sp>>8^h)&16|((f>>8^h)&(h^sp>>8)&128)>>5|(h=f>>8&255)&168|(l|h?2:66)',// SBC HL,SP
'st+=6;mw[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383]=sp&255;mw[t+1>>14&3][t+1&16383]=sp>>8',// LD (NN),SP
//'st+=6;wb(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8,sp);wb(t+1&65535,sp>>8)',
neg(),                    // NEG
ret(4),                   // RETN
'st+=2;im=1',             // IM 1
nop(2),                   // NOP
inr('a'),                 // IN A,(C)
outr('a'),                // OUT (C),A
'st+=4;f=(l|h<<8)+sp+(f&1);t=h>>3&17|sp>>10&34|f>>9&68;h=f>>8&255;l=f&255;f=f>>16|ova[t>>4]|h&168|hca[t&7]|(l|h?0:64)',// ADC HL,SP
'st+=6;sp=m[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383]|m[t+1>>14&3][t+1&16383]<<8',// LD SP,(NN)
neg(),                    // NEG
ret(4),                   // RETI
'st+=2;im=2',             // IM 2
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
ldid(1, 0),               // LDI
cpid(1, 0),               // CPI
inid(1, 0),               // INI
otid(1, 0),               // OUTI
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
ldid(0, 0),               // LDD
cpid(0, 0),               // CPD
inid(0, 0),               // IND
otid(0, 0),               // OUTD
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
ldid(1, 1),               // LDIR
cpid(1, 1),               // CPIR
inid(1, 1),               // INIR
otid(1, 1),               // OTIR
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
ldid(0, 1),               // LDDR
cpid(0, 1),               // CPDR
inid(0, 1),               // INDR
otid(0, 1),               // OTDR
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
'loadblock()',            // tape loader trap
nop(2),                   // NOP
nop(2),                   // NOP
nop(2),                   // NOP
];

g= [];
for (j=0; j<1536; j++)
  g[j]= new Function(p[j]);
