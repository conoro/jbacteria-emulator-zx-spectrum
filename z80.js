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
    wb(sp-1&65535, pc >> 8 & 255);
    wb(sp=sp-2&65535, pc & 255);
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
}

function nop(n){
  return 'st+='+n;
}

function inc(r) {
  return 'st+=4;'+
  'f=f&1|szi['+r+'='+r+'+1&255]';
}

function dec(r) {
  return 'st+=4;'+
  'f=f&1|szd['+r+'='+r+'-1&255]';
}

function incdecphl(n) {
  return 'st+=11;'+
  'wb(t=l|h<<8,t=m[t]'+n+'1&255);'+
  'f=f&1|sz'+(n=='+'?'i':'d')+'[t]';
}

function incdecpi(a, b) {
  return 'st+=19;'+
  'wb(t=(se[m[pc++&65535]]+('+a+'l|'+a+'h<<8))&65535,t=m[t]'+b+'1&255);'+
  'f=f&1|sz'+(b=='+'?'i':'d')+'[t]';
}

function incw(a, b) {
  return 'st+=6;'+
  'if(++'+b+'>>8)'+
    b+'=0,'+
    a+'='+a+'+1&255';
}

function decw(a, b) {
  return 'st+=6;'+
  'if(!'+b+'--)'+
    b+'=255,'+
    a+'='+a+'-1&255';
}

function ldpr(a, b, r) {
  return 'st+=7;'+
  'wb('+b+'|'+a+'<<8,'+r+')'
}

function ldpri(a, b) {
  return 'st+=15;'+
  'wb((se[m[pc++&65535]]+('+b+'l|'+b+'h<<8))&65535,'+a+')';
}

function ldrp(a, b, r) {
  return 'st+=7;'+
  r+'=m['+b+'|'+a+'<<8]';
}

function ldrpi(a, b) {
  return 'st+=15;'+
  a+'=m[(se[m[pc++&65535]]+('+b+'l|'+b+'h<<8))&65535]';
}

function ldrrim(a, b) {
  return 'st+=10;'+
  b+'=m[pc++&65535];'+
  a+'=m[pc++&65535]';
}

function ldrim(r) {
  return 'st+=7;'+
  r+'=m[pc++&65535]';
}

function ldpin(r) {
  return 'st+=15;'+
  'wb((se[m[pc++&65535]]+('+r+'l|'+r+'h<<8))&65535, m[pc++&65535])';
}

function addrrrr(a, b, c, d) {
  return 'st+=11;'+
  't='+b+'+'+d+'+('+a+'+'+c+'<<8);'+
  'f=f&196|t>>16|t>>8&40|(t>>8^'+a+'^'+c+')&16;'+
  a+'=t>>8&255;'+
  b+'=t&255';
}

function addisp(r) {
  return 'st+=11;'+
  't=sp+('+r+'l|'+r+'h<<8);'+
  'f=f&196|t>>16|t>>8&40|(t>>8^sp>>8^'+r+'h)&16;'+
  r+'h=t>>8&255;'+
  r+'l=t&255';
}

function jrc(c) {
  return 'if('+c+')'+
    'st+=7,'+
    'pc++;'+
  'else '+
    'st+=12,'+
    'pc+=se[m[pc&65535]]+1'
}

function jpc(c) {
  return 'st+=10;'+
  'if('+c+')'+
    'pc+=2;'+
  'else '+
    'pc=m[pc&65535]|m[pc+1&65535]<<8';
}

function callc(c) {
  return 'if('+c+')'+
    'st+=10,'+
    'pc+=2;'+
  'else '+
    'st+=17,'+
    't=pc+2,'+
    'pc=m[pc&65535]|m[pc+1&65535]<<8,'+
    'wb(--sp&65535,t>>8&255),'+
    'wb(sp=sp-1&65535,t&255)';
//    'wb(--sp&65535,t>>8),'+
//    'wb(sp=sp-1&65535,t)';
}

function retc(c) {
  return 'if('+c+')'+
    'st+=5;'+
  'else '+
    'st+=11,'+
    'pc=m[sp]|m[sp+1&65535]<<8,'+
    'sp=sp+2&65535';
}

function ret(n){
  return 'st+='+n+
  ';pc=m[sp]|m[sp+1&65535]<<8;'+
  'sp=sp+2&65535';
}

function ldpnnrr(a, b, n) {
  return 'st+='+n+';'+
  'wb(t=m[pc++&65535]|m[pc++&65535]<<8,'+b+');'+
  'wb(t+1&65535,'+a+')';
}

function ldrrpnn(a, b, n) {
  return 'st+='+n+';'+
  b+'=m[t=m[pc++&65535]|m[pc++&65535]<<8];'+
  a+'=m[t+1&65535]';
}

function ldrr(a, b, n){
  return 'st+='+n+';'+
  a+'='+b;
}

function add(a, b, n){
  return 'st+='+n+
  ';f=a+'+a+';'+
  'f=f>>8|(f^a^'+b+')&16|((f^a)&(f^'+b+')&128)>>5|sz[a=f&255]';
}

function adc(a, b, n){
  return 'st+='+n+
  ';f=a+'+a+'+(f&1);'+
  'f=f>>8|(f^a^'+b+')&16|((f^a)&(f^'+b+')&128)>>5|sz[a=f&255]';
}

function sub(a, b, n){
  return 'st+='+n+
  ';f=a-'+a+';'+
  'f=f>>8&1|2|(f^a^'+b+')&16|((f^a)&(a^'+b+')&128)>>5|sz[a=f&255]';
}

function sbc(a, b, n){
  return 'st+='+n+
  ';f=a-'+a+'-(f&1);'+
  'f=f>>8&1|2|(f^a^'+b+')&16|((f^a)&(a^'+b+')&128)>>5|sz[a=f&255]';
}

function and(r, n){
  return 'st+='+n+
  ';f=16|szp[a&='+r+']';
}

function xoror(r, n){
  return 'st+='+n+
  ';f=szp[a'+r+']';
}

function cp(a, b, n){
  return 'st+='+n+
  ';f=a-'+a+';'+
  'f=f>>8&1|2|(f^a^'+b+')&16|((f^a)&(a^'+b+')&128)>>5|'+b+'&40|sz[f&255]&215';
}

function push(a, b){
  return 'st+=11;'+
  'wb(--sp&65535,'+a+');'+
  'wb(sp=sp-1&65535,'+b+')';
}

function pop(a, b){
  return 'st+=10;'+
  b+'=m[sp];'+
  a+'=m[sp+1&65535];'+
  'sp=sp+2&65535';
}

function rst(n){
  return 'st+=11;'+
  'wb(--sp&65535,pc>>8&255);'+
  'wb(sp=sp-1&65535,pc&255);'+
//  'wb(--sp&65535,pc>>8);'+
//  'wb(sp=sp-1&65535,pc);'+
  'pc='+n;
}

function rlc(r){
  return 'st+=8;'+
  r+'='+r+'<<1&255|'+r+'>>7;'+
  'f='+r+'&1|szp['+r+']';
}

function rrc(r){
  return 'st+=8;'+
  r+'='+r+'>>1|'+r+'<<7&128;'+
  'f='+r+'>>7|szp['+r+']';
}

function rl(r){
  return 'st+=8;'+
  'j='+r+';'+
  r+'='+r+'<<1&255|f&1;'+
  'f=j>>7|szp['+r+']';
}

function rr(r){
  return 'st+=8;'+
  'j='+r+';'+
  r+'='+r+'>>1|f<<7&128;'+
  'f=j&1|szp['+r+']';
}

function sla(r){
  return 'st+=8;'+
  'f='+r+'>>7;'+
  r+'='+r+'<<1&255;'+
  'f|=szp['+r+']';
}

function sra(r){
  return 'st+=8;'+
  'f='+r+'&1;'+
  r+'='+r+'&128|'+r+'>>1;'+
  'f|=szp['+r+']';
}

function sll(r){
  return 'st+=8;'+
  'f='+r+'>>7;'+
  r+'='+r+'<<1&255|1;'+
  'f|=szp['+r+']';
}

function srl(r){
  return 'st+=8;'+
  'f='+r+'&1;'+
  r+'>>=1;'+
  'f|=szp['+r+']';
}

function bit(n, r){
  return 'st+=8;'+
  'f=f&1|'+r+'&40|('+r+'&'+n+'?16:84)'+(n&128 ? '|'+r+'&128' : '');
}

function biti(n){
  return 'st+=5;'+
  'f=f&1|u>>8&40|(t&'+n+'?16:84)'+(n&128 ? '|t&128' : '');
}

function bithl(n){
  return 'st+=12;'+
  'f=f&1|(t=m[l|h<<8])&40|(t&'+n+'?16:84)'+(n&128 ? '|t&128' : '');
}

function res(n, r){
  return 'st+=8;'+
  r+'&='+n;
}

function reshl(n){
  return 'st+=15;'+
  'wb(t=l|h<<8,m[t]&'+n+')';
}

function set(n, r){
  return 'st+=8;'+
  r+'|='+n;
}

function sethl(n){
  return 'st+=15;'+
  'wb(t=l|h<<8,m[t]|'+n+')';
}

function inr(r){
  return 'st+=12;'+
  r+'=rp(c|b<<8);'+
  'f=f&1|szp['+r+']';
}

function outr(r){
  return 'st+=12;'+
  'wp(c|b<<8,'+r+')';
}

function sbchlrr(a, b) {
  return 'st+=15;'+
  'f='+(a=='h'?'':'l-'+b+'+(h-'+a+'<<8)')+'-(f&1);'+
  'l=f&255;'+
  'f=f>>16&1|(f>>8^h^'+a+')&16|((f>>8^h)&(h^'+a+')&128)>>5|(h=f>>8&255)&168|(l|h?2:66)';
}

function adchlrr(a, b) {
  return 'st+=15;'+
  'f=l+'+b+'+(h+'+a+'<<8)+(f&1);'+
  'l=f&255;'+
  'f=f>>16|(f>>8^h^'+a+')&16|((f>>8^h)&(f>>8^'+a+')&128)>>5|(h=f>>8&255)&168|(l|h?0:64)';
}

function neg(){
  return 'st+=8;'+
  'f=(a?3:2)|(-a^a)&16|(-a&a&128)>>5|sz[a=-a&255]';
}

function ldair(r){
  return 'st+=9;'+
  'a='+r+';'+
  'f=f&1|sz[a]|iff<<2';
}

function ldid(i, r){
  return 'st+=16;'+
  'wb(e|d<<8,t=m[l|h<<8]);'+
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
  (r?';if(c|b)st+=5,pc-=2':'');
}

function cpid(i, r){
  return 'st+=16;'+
  't=a-(u=m[l|h<<8]);'+
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
  (r?';if((f&68)==4)st+=5,pc-=2':'');
}

function inid(i, r){
  return 'st+=16;'+
  'wb(l|h<<8,t=rp(c|b<<8));'+
  'b=b-1&255;'+
  'if('+(i?'++l>>8':'!l--')+')'+
    'l='+(i?'0':'255')+','+
    'h=h'+(i?'+':'-')+'1&255;'+
  'u=t+c'+(i?'+':'-')+'1&255;'+
  'f=t>>6&2|(u<t?17:0)|par[u&7^b]|sz[b]'+
  (r?';if(b)st+=5,pc-=2':'');
}

function otid(i, r){
  return 'st+=16;'+
  'wp(c|b<<8,t=m[l|h<<8]);'+
  'b=b-1&255;'+
  'if('+(i?'++l>>8':'!l--')+')'+
    'l='+(i?'0':'255')+','+
    'h=h'+(i?'+':'-')+'1&255;'+
  'u=t+l&255;'+
  'f=t>>6&2|(u<t?17:0)|par[u&7^b]|sz[b]'+
  (r?';if(b)st+=5,pc-=2':'');
}

function exspi(r){
  return 'st+=19;'+
  't=m[sp];'+
  'wb(sp,'+r+'l);'+
  r+'l=t;'+
  't=m[sp+1&65535];'+
  'wb(sp+1&65535,'+r+'h);'+
  r+'h=t';
}

function ldsppci(a, b){
  return 'st+='+(a=='sp'?6:4)+';'+
  a+'='+b+'l|'+b+'h<<8';
}

p=[
nop(4),                   // NOP
ldrrim('b', 'c'),         // LD BC,nn
ldpr('b', 'c', 'a'),      // LD (BC,A
incw('b', 'c'),           // INC BC
inc('b'),                 // INC B
dec('b'),                 // DEC B
ldrim('b'),               // LD B,n
'st+=4;a=a<<1&255|a>>7;f=f&196|a&41',// RLCA
'st+=4;t=a;a=a_;a_=t;t=f;f=f_;f_=t',// EX AF,AF'
addrrrr('h', 'l', 'b', 'c'),  // ADD HL,BC
ldrp('b', 'c', 'a'),      // LD A,(BC)
decw('b', 'c'),           // DEC BC
inc('c'),                 // INC C
dec('c'),                 // DEC C
ldrim('c'),               // LD C,n
'st+=4;f=f&196|a&1|a>>1&40;a=a>>1|a<<7&128',// RRCA
'st+=8;if(b=b-1&255)st+=5,pc+=se[m[pc&65535]]+1;else pc++',// DJNZ
ldrrim('d', 'e'),         // LD DE,nn
ldpr('d', 'e', 'a'),      // LD (DE,A
incw('d', 'e'),           // INC DE
inc('d'),                 // INC D
dec('d'),                 // DEC D
ldrim('d'),               // LD D,n
't=a;st+=4;a=a<<1&255|f&1;f=f&196|a&40|t>>7',// RLA
'st+=12;pc+=se[m[pc&65535]]+1',// JR
addrrrr('h', 'l', 'd', 'e'),// ADD HL,DE
ldrp('d', 'e', 'a'),      // LD A,(DE)
decw('d', 'e'),           // DEC DE
inc('e'),                 // INC E
dec('e'),                 // DEC E
ldrim('e'),               // LD E,n
'st+=4;t=a;a=a>>1|f<<7&128;f=f&196|a&40|t&1',// RRA
jrc('f&64'),              // JR NZ,s8
ldrrim('h', 'l'),         // LD HL,nn
ldpnnrr('h', 'l', 16),    // LD (nn,HL
incw('h', 'l'),           // INC HL
inc('h'),                 // INC H
dec('h'),                 // DEC H
ldrim('h'),               // LD H,n
'st+=4;u=f&16||(a&15)>9?6:0;if(f&1||a>153)u|=96;if(a>153)f|=1;f=f&2?f&1|2|((t=a-u)^a^u)&16|szp[a=t&255]:f&1|((t=a+u)^a^u)&16|szp[a=t&255]',//DAA
jrc('~f&64'),             // JR Z,s8
addrrrr('h', 'l', 'h', 'l'),  // ADD HL,HL
ldrrpnn('h', 'l', 16),    // LD HL,(nn)
decw('h', 'l'),           // DEC HL
inc('l'),                 // INC L
dec('l'),                 // DEC L
ldrim('l'),               // LD L,n
'st+=4;a^=255;f=f&197|a&40|18',// CPL
jrc('f&1'),               // JR NC,s8
'st+=10;sp=m[pc++&65535]|m[pc++&65535]<<8',// LD SP,nn
'st+=13;wb(m[pc++&65535]|m[pc++&65535]<<8,a)',// LD (nn),A
'st+=6;sp=sp+1&65535',    // INC SP
incdecphl('+'),           // INC (HL)
incdecphl('-'),           // DEC (HL)
'st+=10;wb(l|h<<8,m[pc++&65535])', // LD (HL),n
'st+=4;f=f&196|a&40|1',   // SCF
jrc('~f&1'),              // JR C,s8
addisp(''),               // ADD HL,SP
'st+=13;a=m[m[pc++&65535]|m[pc++&65535]<<8]',// LD A,(nn)
'st+=6;sp=sp-1&65535',    // DEC SP
inc('a'),                 // INC A
dec('a'),                 // DEC A
ldrim('a'),               // LD A,n
'st+=4;f=f&196|(f&1?16:1)|a&40',// CCF
nop(4),                   // LD B,B
ldrr('b', 'c', 4),        // LD B,C
ldrr('b', 'd', 4),        // LD B,D
ldrr('b', 'e', 4),        // LD B,E
ldrr('b', 'h', 4),        // LD B,H
ldrr('b', 'l', 4),        // LD B,L
ldrp('h', 'l', 'b'),      // LD B,(HL)
ldrr('b', 'a', 4),        // LD B,C
ldrr('c', 'b', 4),        // LD C,B
nop(4),                   // LD C,C
ldrr('c', 'd', 4),        // LD C,D
ldrr('c', 'e', 4),        // LD C,E
ldrr('c', 'h', 4),        // LD C,H
ldrr('c', 'l', 4),        // LD C,L
ldrp('h', 'l', 'c'),      // LD C,(HL)
ldrr('c', 'a', 4),        // LD C,A
ldrr('d', 'b', 4),        // LD D,B
ldrr('d', 'c', 4),        // LD D,C
nop(4),                   // LD D,D
ldrr('d', 'e', 4),        // LD D,E
ldrr('d', 'h', 4),        // LD D,H
ldrr('d', 'l', 4),        // LD D,L
ldrp('h', 'l', 'd'),      // LD D,(HL)
ldrr('d', 'a', 4),        // LD D,A
ldrr('e', 'b', 4),        // LD E,B
ldrr('e', 'c', 4),        // LD E,C
ldrr('e', 'd', 4),        // LD E,D
nop(4),                   // LD E,E
ldrr('e', 'h', 4),        // LD E,H
ldrr('e', 'l', 4),        // LD E,L
ldrp('h', 'l', 'e'),      // LD E,(HL)
ldrr('e', 'a', 4),        // LD E,A
ldrr('h', 'b', 4),        // LD H,B
ldrr('h', 'c', 4),        // LD H,C
ldrr('h', 'd', 4),        // LD H,D
ldrr('h', 'e', 4),        // LD H,E
nop(4),                   // LD H,H
ldrr('h', 'l', 4),        // LD H,L
ldrp('h', 'l', 'h'),      // LD H,(HL)
ldrr('h', 'a', 4),        // LD H,A
ldrr('l', 'b', 4),        // LD L,B
ldrr('l', 'c', 4),        // LD L,C
ldrr('l', 'd', 4),        // LD L,D
ldrr('l', 'e', 4),        // LD L,E
ldrr('l', 'h', 4),        // LD L,H
nop(4),                   // LD L,L
ldrp('h', 'l', 'l'),      // LD L,(HL)
ldrr('l', 'a', 4),        // LD L,A
ldpr('h', 'l', 'b'),      // LD (HL,B
ldpr('h', 'l', 'c'),      // LD (HL,C
ldpr('h', 'l', 'd'),      // LD (HL,D
ldpr('h', 'l', 'e'),      // LD (HL,E
ldpr('h', 'l', 'h'),      // LD (HL,H
ldpr('h', 'l', 'l'),      // LD (HL,L
'st+=4;halted=1;pc--',    // HALT
ldpr('h', 'l', 'a'),      // LD (HL,A
ldrr('a', 'b', 4),        // LD A,B
ldrr('a', 'c', 4),        // LD A,C
ldrr('a', 'd', 4),        // LD A,D
ldrr('a', 'e', 4),        // LD A,E
ldrr('a', 'h', 4),        // LD A,H
ldrr('a', 'l', 4),        // LD A,L
ldrp('h', 'l', 'a'),      // LD A,(HL)
nop(4),                   // LD A,A
add('b', 'b', 4),         // ADD A,B
add('c', 'c', 4),         // ADD A,C
add('d', 'd', 4),         // ADD A,D
add('e', 'e', 4),         // ADD A,E
add('h', 'h', 4),         // ADD A,H
add('l', 'l', 4),         // ADD A,L
add('(t=m[l|h<<8])', 't', 7),// ADD A,(HL)
add('a', 'a', 4),         // ADD A,A
adc('b', 'b', 4),         // ADC A,B
adc('c', 'c', 4),         // ADC A,C
adc('d', 'd', 4),         // ADC A,D
adc('e', 'e', 4),         // ADC A,E
adc('h', 'h', 4),         // ADC A,H
adc('l', 'l', 4),         // ADC A,L
adc('(t=m[l|h<<8])', 't', 7),// ADC A,(HL)
adc('a', 'a', 4),         // ADC A,A
sub('b', 'b', 4),         // SUB A,B
sub('c', 'c', 4),         // SUB A,C
sub('d', 'd', 4),         // SUB A,D
sub('e', 'e', 4),         // SUB A,E
sub('h', 'h', 4),         // SUB A,H
sub('l', 'l', 4),         // SUB A,L
sub('(t=m[l|h<<8])', 't', 7),// SUB A,(HL)
sub('a', 'a', 4),         // SUB A,A
sbc('b', 'b', 4),         // SBC A,B
sbc('c', 'c', 4),         // SBC A,C
sbc('d', 'd', 4),         // SBC A,D
sbc('e', 'e', 4),         // SBC A,E
sbc('h', 'h', 4),         // SBC A,H
sbc('l', 'l', 4),         // SBC A,L
sbc('(t=m[l|h<<8])', 't', 7),// SBC A,(HL)
sbc('a', 'a', 4),         // SBC A,A
and('b', 4),              // AND B
and('c', 4),              // AND C
and('d', 4),              // AND D
and('e', 4),              // AND E
and('h', 4),              // AND H
and('l', 4),              // AND L
and('m[l|h<<8]', 7),      // AND (HL)
and('a', 4),              // AND A
xoror('^=b', 4),          // XOR B
xoror('^=c', 4),          // XOR C
xoror('^=d', 4),          // XOR D
xoror('^=e', 4),          // XOR E
xoror('^=h', 4),          // XOR H
xoror('^=l', 4),          // XOR L
xoror('^=m[l|h<<8]', 7),// XOR (HL)
xoror('^=a', 4),          // XOR A
xoror('|=b', 4),          // OR B
xoror('|=c', 4),          // OR C
xoror('|=d', 4),          // OR D
xoror('|=e', 4),          // OR E
xoror('|=h', 4),          // OR H
xoror('|=l', 4),          // OR L
xoror('|=m[l|h<<8]', 7),// OR (HL)
xoror('|=a', 4),          // OR A
cp('b', 'b', 4),          // CP B
cp('c', 'c', 4),          // CP C
cp('d', 'd', 4),          // CP D
cp('e', 'e', 4),          // CP E
cp('h', 'h', 4),          // CP H
cp('l', 'l', 4),          // CP L
cp('(t=m[l|h<<8])', 't', 7),// CP (HL)
cp('a', 'a', 4),          // CP A
retc('f&64'),             // RET NZ
pop('b', 'c'),            // POP BC
jpc('f&64'),              // JP NZ
'st+=10;pc=m[pc&65535]|m[pc+1&65535]<<8',// JP nn
callc('f&64'),            // CALL NZ
push('b', 'c'),           // PUSH BC
add('(t=m[pc++&65535])', 't', 7),// ADD A,n
rst(0),                   // RST 0x00
retc('~f&64'),            // RET Z
ret(10),                  // RET
jpc('~f&64'),             // JP Z
'r++;g[768+m[pc++&65535]]()',// op cb
callc('~f&64'),           // CALL Z
'st+=17;t=pc+2;pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8&255);wb(sp=sp-1&65535,t&255)',// CALL NN
//'st+=17;t=pc+2;pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8);wb(sp=sp-1&65535,t)',// CALL NN
adc('(t=m[pc++&65535])', 't', 7),// ADC A,n
rst(8),                   // RST 0x08
retc('f&1'),              // RET NC
pop('d', 'e'),            // POP DE
jpc('f&1'),               // JP NC
'st+=11;wp(m[pc++&65535]|a<<8,a)',// OUT (n),A
callc('f&1'),             // CALL NC
push('d', 'e'),           // PUSH DE
sub('(t=m[pc++&65535])', 't', 7),// SUB A,n
rst(16),                  // RST 0x10
retc('~f&1'),             // RET C
'st+=4;t=b;b=b_;b_=t;t=c;c=c_;c_=t;t=d;d=d_;d_=t;t=e;e=e_;e_=t;t=h;h=h_;h_=t;t=l;l=l_;l_=t',// EXX
jpc('~f&1'),              // JP C
'st+=11;a=rp(m[pc++&65535]|a<<8)',// IN A,(n)
callc('~f&1'),            // CALL C
'st+=4;r++;g[256+m[pc++&65535]]()',//op dd
sbc('(t=m[pc++&65535])', 't', 7),// SBC A,n
rst(24),                  // RST 0x18
retc('f&4'),              // RET PO
pop('h', 'l'),            // POP HL
jpc('f&4'),               // JP PO
exspi(''),                // EX (SP),IY
callc('f&4'),             // CALL PO
push('h', 'l'),           // PUSH HL
and('m[pc++&65535]', 7),  // AND A,n
rst(32),                  // RST 0x20
retc('~f&4'),             // RET PE
ldsppci('pc', ''),        // JP (HL)
jpc('~f&4'),              // JP PE
'st+=4;t=d;d=h;h=t;t=e;e=l;l=t',// EX DE,HL
callc('~f&4'),            // CALL PE
'r++;g[1280+m[pc++&65535]]()',// op ed
xoror('^=m[pc++&65535]', 7),// XOR A,n
rst(40),                  // RST 0x28
retc('f&128'),            // RET P
pop('a', 'f'),            // POP AF
jpc('f&128'),             // JP P
'st+=4;iff=0',            // DI
callc('f&128'),           // CALL P
push('a', 'f'),           // PUSH AF
xoror('|=m[pc++&65535]', 7),// OR A,n
rst(48),                  // RST 0x30
retc('~f&128'),           // RET M
ldsppci('sp', ''),        // LD SP,HL
jpc('~f&128'),            // JP M
'st+=4;iff=1',            // EI
callc('~f&128'),          // CALL M
'st+=4;r++;g[512+m[pc++&65535]]()',// op fd
cp('(t=m[pc++&65535])', 't', 7),// CP A,n
rst(56),                  // RST 0x38

nop(4),                   // NOP
ldrrim('b', 'c'),         // LD BC,nn
ldpr('b', 'c', 'a'),      // LD (BC,A
incw('b', 'c'),           // INC BC
inc('b'),                 // INC B
dec('b'),                 // DEC B
ldrim('b'),               // LD B,n
'st+=4;a=a<<1&255|a>>7;f=f&196|a&41',
'st+=4;t=a;a=a_;a_=t;t=f;f=f_;f_=t',// EX AF,AF'
addrrrr('xh', 'xl', 'b', 'c'),  // ADD IX,BC
ldrp('b', 'c', 'a'),      // LD A,(BC)
decw('b', 'c'),           // DEC BC
inc('c'),                 // INC C
dec('c'),                 // DEC C
ldrim('c'),               // LD C,n
'st+=4;f=f&196|a&1|a>>1&40;a=a>>1|a<<7&128',
'st+=8;if(b=b-1&255)st+=5,pc+=se[m[pc&65535]]+1;else pc++',
ldrrim('d', 'e'),         // LD DE,nn
ldpr('d', 'e', 'a'),      // LD (DE,A
incw('d', 'e'),           // INC DE
inc('d'),                 // INC D
dec('d'),                 // DEC D
ldrim('d'),               // LD D,n
't=a;st+=4;a=a<<1&255|f&1;f=f&196|a&40|t>>7',
'st+=12;pc+=se[m[pc&65535]]+1',
addrrrr('xh', 'xl', 'd', 'e'), // ADD IX,DE
ldrp('d', 'e', 'a'),      // LD A,(DE)
decw('d', 'e'),           // DEC DE
inc('e'),                 // INC E
dec('e'),                 // DEC E
ldrim('e'),               // LD E,n
'st+=4;t=a;a=a>>1|f<<7&128;f=f&196|a&40|t&1',
jrc('f&64'),              // JR NZ,s8
ldrrim('xh', 'xl'),       // LD IX,nn
ldpnnrr('xh', 'xl', 16),  // LD (nn,IX
incw('xh', 'xl'),         // INC IX
inc('xh'),                // INC IXH
dec('xh'),                // DEC IXH
ldrim('xh'),              // LD IXH,n
'st+=4;u=f&16||(a&15)>9?6:0;if(f&1||a>153)u|=96;if(a>153)f|=1;f=f&2?f&1|2|((t=a-u)^a^u)&16|szp[a=t&255]:f&1|((t=a+u)^a^u)&16|szp[a=t&255]',
jrc('~f&64'),             // JR Z,s8
addrrrr('xh', 'xl', 'xh', 'xl'),  // ADD IX,IX
ldrrpnn('xh', 'xl', 16),  // LD IX,(nn)
decw('xh', 'xl'),         // DEC IX
inc('xl'),                // INC IXL
dec('xl'),                // DEC IXL
ldrim('xl'),              // LD IXL,n
'st+=4;a^=255;f=f&197|a&40|18',
jrc('f&1'),               // JR NC,s8
'st+=10;sp=m[pc++&65535]|m[pc++&65535]<<8',
'st+=13;wb(m[pc++&65535]|m[pc++&65535]<<8,a)',
'st+=6;sp=sp+1&65535',
incdecpi('x', '+'),       // INC (IX+d)
incdecpi('x', '-'),       // DEC (IX+d)
ldpin('x'),               // LD (IX+d,n
'st+=4;f=f&196|a&40|1',
jrc('~f&1'),              // JR C,s8
addisp('x'),              // ADD IX,SP
'st+=13;a=m[m[pc++&65535]|m[pc++&65535]<<8]',
'st+=6;sp=sp-1&65535',
inc('a'),                 // INC A
dec('a'),                 // DEC A
ldrim('a'),            // LD A,n
'st+=4;f=f&196|(f&1?16:1)|a&40',
nop(4),                   // LD B,B
ldrr('b', 'c', 4),        // LD B,C
ldrr('b', 'd', 4),        // LD B,D
ldrr('b', 'e', 4),        // LD B,E
ldrr('b', 'xh', 4),       // LD B,IXH
ldrr('b', 'xl', 4),       // LD B,IXL
ldrpi('b', 'x'),          // LD B,(IX+d)
ldrr('b', 'a', 4),        // LD B,C
ldrr('c', 'b', 4),        // LD C,B
nop(4),                   // LD C,C
ldrr('c', 'd', 4),        // LD C,D
ldrr('c', 'e', 4),        // LD C,E
ldrr('c', 'xh', 4),       // LD C,IXH
ldrr('c', 'xl', 4),       // LD C,IXL
ldrpi('c', 'x'),          // LD C,(IX+d)
ldrr('c', 'a', 4),        // LD C,A
ldrr('d', 'b', 4),        // LD D,B
ldrr('d', 'c', 4),        // LD D,C
nop(4),                   // LD D,D
ldrr('d', 'e', 4),        // LD D,E
ldrr('d', 'xh', 4),       // LD D,IXH
ldrr('d', 'xl', 4),       // LD D,IXL
ldrpi('d', 'x'),          // LD D,(IX+d)
ldrr('d', 'a', 4),        // LD D,A
ldrr('e', 'b', 4),        // LD E,B
ldrr('e', 'c', 4),        // LD E,C
ldrr('e', 'd', 4),        // LD E,D
nop(4),                   // LD E,E
ldrr('e', 'xh', 4),       // LD E,IXH
ldrr('e', 'xl', 4),       // LD E,IXL
ldrpi('e', 'x'),          // LD E,(IX+d)
ldrr('e', 'a', 4),        // LD E,A
ldrr('xh', 'b', 4),       // LD IXH,B
ldrr('xh', 'c', 4),       // LD IXH,C
ldrr('xh', 'd', 4),       // LD IXH,D
ldrr('xh', 'e', 4),       // LD IXH,E
nop(4),                   // LD IXH,IXH
ldrr('xh', 'xl', 4),      // LD IXH,IXL
ldrpi('h', 'x'),          // LD H,(IX+d)
ldrr('xh', 'a', 4),       // LD IXH,A
ldrr('xl', 'b', 4),       // LD IXL,B
ldrr('xl', 'c', 4),       // LD IXL,C
ldrr('xl', 'd', 4),       // LD IXL,D
ldrr('xl', 'e', 4),       // LD IXL,E
ldrr('xl', 'xh', 4),      // LD IXL,IXH
nop(4),                   // LD IXL,IXL
ldrpi('l', 'x'),          // LD L,(IX+d)
ldrr('xl', 'a', 4),       // LD IXL,A
ldpri('b', 'x'),          // LD (IX+d,B
ldpri('c', 'x'),          // LD (IX+d,C
ldpri('d', 'x'),          // LD (IX+d,D
ldpri('e', 'x'),          // LD (IX+d,E
ldpri('h', 'x'),          // LD (IX+d,H
ldpri('l', 'x'),          // LD (IX+d,L
'st+=4;halted=1;pc--',
ldpri('a', 'x'),          // LD (IX+d,A
ldrr('a', 'b', 4),        // LD A,B
ldrr('a', 'c', 4),        // LD A,C
ldrr('a', 'd', 4),        // LD A,D
ldrr('a', 'e', 4),        // LD A,E
ldrr('a', 'xh', 4),       // LD A,IXH
ldrr('a', 'xl', 4),       // LD A,IXL
ldrpi('a', 'x'),          // LD A,(IX+d)
nop(4),                   // LD A,A
add('b', 'b', 4),         // ADD A,B
add('c', 'c', 4),         // ADD A,C
add('d', 'd', 4),         // ADD A,D
add('e', 'e', 4),         // ADD A,E
add('xh', 'xh', 4),       // ADD A,IXH
add('xl', 'xl', 4),       // ADD A,IXL
add('(t=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535])', 't', 15),// ADD A,(IX+d)
add('a', 'a', 4),         // ADD A,A
adc('b', 'b', 4),         // ADC A,B
adc('c', 'c', 4),         // ADC A,C
adc('d', 'd', 4),         // ADC A,D
adc('e', 'e', 4),         // ADC A,E
adc('xh', 'xh', 4),       // ADC A,IXH
adc('xl', 'xl', 4),       // ADC A,IXL
adc('(t=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535])', 't', 15),// ADC A,(IX+d)
adc('a', 'a', 4),         // ADC A,A
sub('b', 'b', 4),         // SUB A,B
sub('c', 'c', 4),         // SUB A,C
sub('d', 'd', 4),         // SUB A,D
sub('e', 'e', 4),         // SUB A,E
sub('xh', 'xh', 4),       // SUB A,IXH
sub('xl', 'xl', 4),       // SUB A,IXL
sub('(t=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535])', 't', 15),// SUB A,(IX+d)
sub('a', 'a', 4),         // SUB A,A
sbc('b', 'b', 4),         // SBC A,B
sbc('c', 'c', 4),         // SBC A,C
sbc('d', 'd', 4),         // SBC A,D
sbc('e', 'e', 4),         // SBC A,E
sbc('xh', 'xh', 4),       // SBC A,IXH
sbc('xl', 'xl', 4),       // SBC A,IXL
sbc('(t=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535])', 't', 15),// SBC A,(IX+d)
sbc('a', 'a', 4),         // SBC A,A
and('b', 4),              // AND B
and('c', 4),              // AND C
and('d', 4),              // AND D
and('e', 4),              // AND E
and('xh', 4),             // AND IXH
and('xl', 4),             // AND IXL
and('m[(se[m[pc++&65535]]+(xl|xh<<8))&65535]', 15),// AND (IX+d)
and('a', 4),              // AND A
xoror('^=b', 4),          // XOR B
xoror('^=c', 4),          // XOR C
xoror('^=d', 4),          // XOR D
xoror('^=e', 4),          // XOR E
xoror('^=xh', 4),         // XOR IXH
xoror('^=xl', 4),         // XOR IXL
xoror('^=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535]', 15),// XOR (IX+d)
xoror('^=a', 4),          // XOR A
xoror('|=b', 4),          // OR B
xoror('|=c', 4),          // OR C
xoror('|=d', 4),          // OR D
xoror('|=e', 4),          // OR E
xoror('|=xh', 4),         // OR IXH
xoror('|=xl', 4),         // OR IXL
xoror('|=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535]', 15),// OR (IX+d)
xoror('|=a', 4),          // OR A
cp('b', 'b', 4),          // CP B
cp('c', 'c', 4),          // CP C
cp('d', 'd', 4),          // CP D
cp('e', 'e', 4),          // CP E
cp('xh', 'xh', 4),        // CP IXH
cp('xl', 'xl', 4),        // CP IXL
cp('(t=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535])', 't', 15),// CP (IX+d)
cp('a', 'a', 4),          // CP A
retc('f&64'),             // RET NZ
pop('b', 'c'),            // POP BC
jpc('f&64'),              // JP NZ
'st+=10;pc=m[pc&65535]|m[pc+1&65535]<<8',
callc('f&64'),            // CALL NZ
push('b', 'c'),           // PUSH BC
add('(t=m[pc++&65535])', 't', 7),// ADD A,n
rst(0),                   // RST 0x00
retc('~f&64'),            // RET Z
ret(10),                  // RET
jpc('~f&64'),             // JP Z
'st+=11;t=m[u=(se[m[pc++&65535]]+(xl|xh<<8))&65535];g[1024+m[pc++&65535]]()',// op ddcb
callc('~f&64'),           // CALL Z
'st+=17;t=pc+2;pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8&255);wb(sp=sp-1&65535,t&255)',// CALL NN
//'st+=17;t=pc+2;pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8);wb(sp=sp-1&65535,t)',// CALL NN
adc('(t=m[pc++&65535])', 't', 7),// ADC A,n
rst(8),                   // RST 0x08
retc('f&1'),              // RET NC
pop('d', 'e'),            // POP DE
jpc('f&1'),               // JP NC
'st+=11;wp(m[pc++&65535]|a<<8,a)',
callc('f&1'),             // CALL NC
push('d', 'e'),           // PUSH DE
sub('(t=m[pc++&65535])', 't', 7),// SUB A,n
rst(16),                  // RST 0x10
retc('~f&1'),             // RET C
'st+=4;t=b;b=b_;b_=t;t=c;c=c_;c_=t;t=d;d=d_;d_=t;t=e;e=e_;e_=t;t=h;h=h_;h_=t;t=l;l=l_;l_=t',
jpc('~f&1'),              // JP C
'st+=11;a=rp(m[pc++&65535]|a<<8)',
callc('~f&1'),            // CALL C
nop(4),                   // op dd
sbc('(t=m[pc++&65535])', 't', 7),// SBC A,n
rst(24),                  // RST 0x18
retc('f&4'),              // RET PO
pop('xh', 'xl'),          // POP IX
jpc('f&4'),               // JP PO
exspi('x'),               // EX (SP,IX
callc('f&4'),             // CALL PO
push('xh', 'xl'),         // PUSH IX
and('m[pc++&65535]', 7),// AND A,n
rst(32),                  // RST 0x20
retc('~f&4'),             // RET PE
ldsppci('pc', 'x'),       // JP (IX)
jpc('~f&4'),              // JP PE
'st+=4;t=d;d=h;h=t;t=e;e=l;l=t',
callc('~f&4'),            // CALL PE
'r++;g[1280+m[pc++&65535]]()', //op ed
xoror('^=m[pc++&65535]', 7),// XOR A,n
rst(40),                  // RST 0x28
retc('f&128'),            // RET P
pop('a', 'f'),            // POP AF
jpc('f&128'),             // JP P
'st+=4;iff=0',
callc('f&128'),           // CALL P
push('a', 'f'),           // PUSH AF
xoror('|=m[pc++&65535]', 7),// OR A,n
rst(48),                  // RST 0x30
retc('~f&128'),           // RET M
ldsppci('sp', 'x'),       // LD SP,IX
jpc('~f&128'),            // JP M
'st+=4;iff=1',
callc('~f&128'),          // CALL M
nop(4),                   // op fd
cp('(t=m[pc++&65535])', 't', 7),// CP A,n
rst(56),                  // RST 0x38

nop(4),                   // NOP
ldrrim('b', 'c'),         // LD BC,nn
ldpr('b', 'c', 'a'),      // LD (BC,A
incw('b', 'c'),           // INC BC
inc('b'),                 // INC B
dec('b'),                 // DEC B
ldrim('b'),               // LD B,n
'st+=4;a=a<<1&255|a>>7;f=f&196|a&41',
'st+=4;t=a;a=a_;a_=t;t=f;f=f_;f_=t',// EX AF,AF'
addrrrr('yh', 'yl', 'b', 'c'),  // ADD IY,BC
ldrp('b', 'c', 'a'),      // LD A,(BC)
decw('b', 'c'),           // DEC BC
inc('c'),                 // INC C
dec('c'),                 // DEC C
ldrim('c'),               // LD C,n
'st+=4;f=f&196|a&1|a>>1&40;a=a>>1|a<<7&128',
'st+=8;if(b=b-1&255)st+=5,pc+=se[m[pc&65535]]+1;else pc++',
ldrrim('d', 'e'),         // LD DE,nn
ldpr('d', 'e', 'a'),      // LD (DE,A
incw('d', 'e'),           // INC DE
inc('d'),                 // INC D
dec('d'),                 // DEC D
ldrim('d'),               // LD D,n
't=a;st+=4;a=a<<1&255|f&1;f=f&196|a&40|t>>7',
'st+=12;pc+=se[m[pc&65535]]+1',
addrrrr('yh', 'yl', 'd', 'e'), // ADD IY,DE
ldrp('d', 'e', 'a'),      // LD A,(DE)
decw('d', 'e'),           // DEC DE
inc('e'),                 // INC E
dec('e'),                 // DEC E
ldrim('e'),               // LD E,n
'st+=4;t=a;a=a>>1|f<<7&128;f=f&196|a&40|t&1',
jrc('f&64'),              // JR NZ,s8
ldrrim('yh', 'yl'),       // LD IY,nn
ldpnnrr('yh', 'yl', 16),  // LD (nn,IY
incw('yh', 'yl'),         // INC IY
inc('yh'),                // INC IYH
dec('yh'),                // DEC IYH
ldrim('yh'),              // LD IYH,n
'st+=4;u=f&16||(a&15)>9?6:0;if(f&1||a>153)u|=96;if(a>153)f|=1;f=f&2?f&1|2|((t=a-u)^a^u)&16|szp[a=t&255]:f&1|((t=a+u)^a^u)&16|szp[a=t&255]',
jrc('~f&64'),             // JR Z,s8
addrrrr('yh', 'yl', 'yh', 'yl'),  // ADD IY,IY
ldrrpnn('yh', 'yl', 16),  // LD IY,(nn)
decw('yh', 'yl'),         // DEC IY
inc('yl'),                // INC IYL
dec('yl'),                // DEC IYL
ldrim('yl'),              // LD IYL,n
'st+=4;a^=255;f=f&197|a&40|18',
jrc('f&1'),               // JR NC,s8
'st+=10;sp=m[pc++&65535]|m[pc++&65535]<<8',
'st+=13;wb(m[pc++&65535]|m[pc++&65535]<<8,a)',
'st+=6;sp=sp+1&65535',
incdecpi('y', '+'),       // INC (IY+d)
incdecpi('y', '-'),       // DEC (IY+d)
ldpin('y'),               // LD (IY+d,n
'st+=4;f=f&196|a&40|1',
jrc('~f&1'),              // JR C,s8
addisp('y'),              // ADD IY,SP
'st+=13;a=m[m[pc++&65535]|m[pc++&65535]<<8]',
'st+=6;sp=sp-1&65535',
inc('a'),                 // INC A
dec('a'),                 // DEC A
ldrim('a'),            // LD A,n
'st+=4;f=f&196|(f&1?16:1)|a&40',
nop(4),                   // LD B,B
ldrr('b', 'c', 4),        // LD B,C
ldrr('b', 'd', 4),        // LD B,D
ldrr('b', 'e', 4),        // LD B,E
ldrr('b', 'yh', 4),       // LD B,IYH
ldrr('b', 'yl', 4),       // LD B,IYL
ldrpi('b', 'y'),          // LD B,(IY+d)
ldrr('b', 'a', 4),        // LD B,C
ldrr('c', 'b', 4),        // LD C,B
nop(4),                   // LD C,C
ldrr('c', 'd', 4),        // LD C,D
ldrr('c', 'e', 4),        // LD C,E
ldrr('c', 'yh', 4),       // LD C,IYH
ldrr('c', 'yl', 4),       // LD C,IYL
ldrpi('c', 'y'),          // LD C,(IY+d)
ldrr('c', 'a', 4),        // LD C,A
ldrr('d', 'b', 4),        // LD D,B
ldrr('d', 'c', 4),        // LD D,C
nop(4),                   // LD D,D
ldrr('d', 'e', 4),        // LD D,E
ldrr('d', 'yh', 4),       // LD D,IYH
ldrr('d', 'yl', 4),       // LD D,IYL
ldrpi('d', 'y'),          // LD D,(IY+d)
ldrr('d', 'a', 4),        // LD D,A
ldrr('e', 'b', 4),        // LD E,B
ldrr('e', 'c', 4),        // LD E,C
ldrr('e', 'd', 4),        // LD E,D
nop(4),                   // LD E,E
ldrr('e', 'yh', 4),       // LD E,IYH
ldrr('e', 'yl', 4),       // LD E,IYL
ldrpi('e', 'y'),          // LD E,(IY+d)
ldrr('e', 'a', 4),        // LD E,A
ldrr('yh', 'b', 4),       // LD IYH,B
ldrr('yh', 'c', 4),       // LD IYH,C
ldrr('yh', 'd', 4),       // LD IYH,D
ldrr('yh', 'e', 4),       // LD IYH,E
nop(4),                   // LD IYH,IYH
ldrr('yh', 'yl', 4),      // LD IYH,IYL
ldrpi('h', 'y'),          // LD H,(IY+d)
ldrr('yh', 'a', 4),       // LD IYH,A
ldrr('yl', 'b', 4),       // LD IYL,B
ldrr('yl', 'c', 4),       // LD IYL,C
ldrr('yl', 'd', 4),       // LD IYL,D
ldrr('yl', 'e', 4),       // LD IYL,E
ldrr('yl', 'yh', 4),      // LD IYL,IYH
nop(4),                   // LD IYL,IYL
ldrpi('l', 'y'),          // LD L,(IY+d)
ldrr('yl', 'a', 4),       // LD IYL,A
ldpri('b', 'y'),          // LD (IY+d,B
ldpri('c', 'y'),          // LD (IY+d,C
ldpri('d', 'y'),          // LD (IY+d,D
ldpri('e', 'y'),          // LD (IY+d,E
ldpri('h', 'y'),          // LD (IY+d,H
ldpri('l', 'y'),          // LD (IY+d,L
'st+=4;halted=1;pc--',
ldpri('a', 'y'),          // LD (IY+d,A
ldrr('a', 'b', 4),        // LD A,B
ldrr('a', 'c', 4),        // LD A,C
ldrr('a', 'd', 4),        // LD A,D
ldrr('a', 'e', 4),        // LD A,E
ldrr('a', 'yh', 4),       // LD A,IYH
ldrr('a', 'yl', 4),       // LD A,IYL
ldrpi('a', 'y'),          // LD A,(IY+d)
nop(4),                   // LD A,A
add('b', 'b', 4),         // ADD A,B
add('c', 'c', 4),         // ADD A,C
add('d', 'd', 4),         // ADD A,D
add('e', 'e', 4),         // ADD A,E
add('yh', 'yh', 4),       // ADD A,IYH
add('yl', 'yl', 4),       // ADD A,IYL
add('(t=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535])', 't', 15),// ADD A,(IY+d)
add('a', 'a', 4),         // ADD A,A
adc('b', 'b', 4),         // ADC A,B
adc('c', 'c', 4),         // ADC A,C
adc('d', 'd', 4),         // ADC A,D
adc('e', 'e', 4),         // ADC A,E
adc('yh', 'yh', 4),       // ADC A,IYH
adc('yl', 'yl', 4),       // ADC A,IYL
adc('(t=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535])', 't', 15),// ADC A,(IY+d)
adc('a', 'a', 4),         // ADC A,A
sub('b', 'b', 4),         // SUB A,B
sub('c', 'c', 4),         // SUB A,C
sub('d', 'd', 4),         // SUB A,D
sub('e', 'e', 4),         // SUB A,E
sub('yh', 'yh', 4),       // SUB A,IYH
sub('yl', 'yl', 4),       // SUB A,IYL
sub('(t=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535])', 't', 15),// SUB A,(IY+d)
sub('a', 'a', 4),         // SUB A,A
sbc('b', 'b', 4),         // SBC A,B
sbc('c', 'c', 4),         // SBC A,C
sbc('d', 'd', 4),         // SBC A,D
sbc('e', 'e', 4),         // SBC A,E
sbc('yh', 'yh', 4),       // SBC A,IYH
sbc('yl', 'yl', 4),       // SBC A,IYL
sbc('(t=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535])', 't', 15),// SBC A,(IY+d)
sbc('a', 'a', 4),         // SBC A,A
and('b', 4),              // AND B
and('c', 4),              // AND C
and('d', 4),              // AND D
and('e', 4),              // AND E
and('yh', 4),             // AND IYH
and('yl', 4),             // AND IYL
and('m[(se[m[pc++&65535]]+(yl|yh<<8))&65535]', 15),// AND (IY+d)
and('a', 4),              // AND A
xoror('^=b', 4),          // XOR B
xoror('^=c', 4),          // XOR C
xoror('^=d', 4),          // XOR D
xoror('^=e', 4),          // XOR E
xoror('^=yh', 4),         // XOR IYH
xoror('^=yl', 4),         // XOR IYL
xoror('^=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535]', 15),// XOR (IY+d)
xoror('^=a', 4),          // XOR A
xoror('|=b', 4),          // OR B
xoror('|=c', 4),          // OR C
xoror('|=d', 4),          // OR D
xoror('|=e', 4),          // OR E
xoror('|=yh', 4),         // OR IYH
xoror('|=yl', 4),         // OR IYL
xoror('|=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535]', 15),// OR (IY+d)
xoror('|=a', 4),          // OR A
cp('b', 'b', 4),          // CP B
cp('c', 'c', 4),          // CP C
cp('d', 'd', 4),          // CP D
cp('e', 'e', 4),          // CP E
cp('yh', 'yh', 4),        // CP IYH
cp('yl', 'yl', 4),        // CP IYL
cp('(t=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535])', 't', 15),// CP (IY+d)
cp('a', 'a', 4),          // CP A
retc('f&64'),             // RET NZ
pop('b', 'c'),            // POP BC
jpc('f&64'),              // JP NZ
'st+=10;pc=m[pc&65535]|m[pc+1&65535]<<8',
callc('f&64'),            // CALL NZ
push('b', 'c'),           // PUSH BC
add('(t=m[pc++&65535])', 't', 7),// ADD A,n
rst(0),                   // RST 0x00
retc('~f&64'),            // RET Z
ret(10),                  // RET
jpc('~f&64'),             // JP Z
'st+=11;t=m[u=(se[m[pc++&65535]]+(yl|yh<<8))&65535];g[1024+m[pc++&65535]]()',
callc('~f&64'),           // CALL Z
'st+=17;t=pc+2;pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8&255);wb(sp=sp-1&65535,t&255)',// CALL NN
//'st+=17;t=pc+2;pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8);wb(sp=sp-1&65535,t)',// CALL NN
adc('(t=m[pc++&65535])', 't', 7),// ADC A,n
rst(8),                   // RST 0x08
retc('f&1'),              // RET NC
pop('d', 'e'),            // POP DE
jpc('f&1'),               // JP NC
'st+=11;wp(m[pc++&65535]|a<<8,a)',
callc('f&1'),             // CALL NC
push('d', 'e'),           // PUSH DE
sub('(t=m[pc++&65535])', 't', 7),// SUB A,n
rst(16),                  // RST 0x10
retc('~f&1'),             // RET C
'st+=4;t=b;b=b_;b_=t;t=c;c=c_;c_=t;t=d;d=d_;d_=t;t=e;e=e_;e_=t;t=h;h=h_;h_=t;t=l;l=l_;l_=t',
jpc('~f&1'),              // JP C
'st+=11;a=rp(m[pc++&65535]|a<<8)',
callc('~f&1'),            // CALL C
nop(4),                   // op dd
sbc('(t=m[pc++&65535])', 't', 7),// SBC A,n
rst(24),                  // RST 0x18
retc('f&4'),              // RET PO
pop('yh', 'yl'),          // POP IY
jpc('f&4'),               // JP PO
exspi('y'),               // EX (SP,IY
callc('f&4'),             // CALL PO
push('yh', 'yl'),         // PUSH IY
and('m[pc++&65535]', 7),  // AND A,n
rst(32),                  // RST 0x20
retc('~f&4'),             // RET PE
ldsppci('pc', 'y'),       // JP (IY)
jpc('~f&4'),              // JP PE
'st+=4;t=d;d=h;h=t;t=e;e=l;l=t',
callc('~f&4'),            // CALL PE
'r++;g[1280+m[pc++&65535]]()', //op ed
xoror('^=m[pc++&65535]', 7),// XOR A,n
rst(40),                  // RST 0x28
retc('f&128'),            // RET P
pop('a', 'f'),            // POP AF
jpc('f&128'),             // JP P
'st+=4;iff=0',
callc('f&128'),           // CALL P
push('a', 'f'),           // PUSH AF
xoror('|=m[pc++&65535]', 7),// OR A,n
rst(48),                  // RST 0x30
retc('~f&128'),           // RET M
ldsppci('sp', 'y'),       // LD SP,IY
jpc('~f&128'),            // JP M
'st+=4;iff=1',
callc('~f&128'),          // CALL M
nop(4),                   // op fd
cp('(t=m[pc++&65535])', 't', 7),// CP A,n
rst(56),                  // RST 0x38

rlc('b'),                 // RLC B
rlc('c'),                 // RLC C
rlc('d'),                 // RLC D
rlc('e'),                 // RLC E
rlc('h'),                 // RLC H
rlc('l'),                 // RLC L
'st+=15;t=l|h<<8;u=m[t];'+rlc('u')+';wb(t,u)',
rlc('a'),                 // RLC A
rrc('b'),                 // RRC B
rrc('c'),                 // RRC C
rrc('d'),                 // RRC D
rrc('e'),                 // RRC E
rrc('h'),                 // RRC H
rrc('l'),                 // RRC L
'st+=15;t=l|h<<8;u=m[t];'+rrc('u')+';wb(t,u)',
rrc('a'),                 // RRC A
rl('b'),                  // RL B
rl('c'),                  // RL C
rl('d'),                  // RL D
rl('e'),                  // RL E
rl('h'),                  // RL H
rl('l'),                  // RL L
'st+=15;t=l|h<<8;u=m[t];'+rl('u')+';wb(t,u)',
rl('a'),                  // RL A
rr('b'),                  // RR B
rr('c'),                  // RR C
rr('d'),                  // RR D
rr('e'),                  // RR E
rr('h'),                  // RR H
rr('l'),                  // RR L
'st+=15;t=l|h<<8;u=m[t];'+rr('u')+';wb(t,u)',
rr('a'),                  // RR A
sla('b'),                 // SLA B
sla('c'),                 // SLA C
sla('d'),                 // SLA D
sla('e'),                 // SLA E
sla('h'),                 // SLA H
sla('l'),                 // SLA L
'st+=15;t=l|h<<8;u=m[t];'+sla('u')+';wb(t,u)',
sla('a'),                 // SLA A
sra('b'),                 // SRA B
sra('c'),                 // SRA C
sra('d'),                 // SRA D
sra('e'),                 // SRA E
sra('h'),                 // SRA H
sra('l'),                 // SRA L
'st+=15;t=l|h<<8;u=m[t];'+sra('u')+';wb(t,u)',
sra('a'),                 // SRA A
sll('b'),                 // SLL B
sll('c'),                 // SLL C
sll('d'),                 // SLL D
sll('e'),                 // SLL E
sll('h'),                 // SLL H
sll('l'),                 // SLL L
'st+=15;t=l|h<<8;u=m[t];'+sll('u')+';wb(t,u)',
sll('a'),                 // SLL A
srl('b'),                 // SRL B
srl('c'),                 // SRL C
srl('d'),                 // SRL D
srl('e'),                 // SRL E
srl('h'),                 // SRL H
srl('l'),                 // SRL L
'st+=15;t=l|h<<8;u=m[t];'+srl('u')+';wb(t,u)',
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

rlc('t')+';wb(u,b=t)',// LD B,RLC(IY+d)
rlc('t')+';wb(u,c=t)',// LD C,RLC(IY+d)
rlc('t')+';wb(u,d=t)',// LD D,RLC(IY+d)
rlc('t')+';wb(u,e=t)',// LD E,RLC(IY+d)
rlc('t')+';wb(u,h=t)',// LD H,RLC(IY+d)
rlc('t')+';wb(u,l=t)',// LD L,RLC(IY+d)
rlc('t')+';wb(u,t)',  // RLC(IY+d)
rlc('t')+';wb(u,a=t)',// LD A,RLC(IY+d)
rrc('t')+';wb(u,b=t)',// LD B,RRC(IY+d)
rrc('t')+';wb(u,c=t)',// LD C,RRC(IY+d)
rrc('t')+';wb(u,d=t)',// LD D,RRC(IY+d)
rrc('t')+';wb(u,e=t)',// LD E,RRC(IY+d)
rrc('t')+';wb(u,h=t)',// LD H,RRC(IY+d)
rrc('t')+';wb(u,l=t)',// LD L,RRC(IY+d)
rrc('t')+';wb(u,t)',  // RRC(IY+d)
rrc('t')+';wb(u,a=t)',// LD A,RRC(IY+d)
rl('t')+';wb(u,b=t)',// LD B,RL(IY+d)
rl('t')+';wb(u,c=t)',// LD C,RL(IY+d)
rl('t')+';wb(u,d=t)',// LD D,RL(IY+d)
rl('t')+';wb(u,e=t)',// LD E,RL(IY+d)
rl('t')+';wb(u,h=t)',// LD H,RL(IY+d)
rl('t')+';wb(u,l=t)',// LD L,RL(IY+d)
rl('t')+';wb(u,t)',  // RL(IY+d)
rl('t')+';wb(u,a=t)',// LD A,RR(IY+d)
rr('t')+';wb(u,b=t)',// LD B,RR(IY+d)
rr('t')+';wb(u,c=t)',// LD C,RR(IY+d)
rr('t')+';wb(u,d=t)',// LD D,RR(IY+d)
rr('t')+';wb(u,e=t)',// LD E,RR(IY+d)
rr('t')+';wb(u,h=t)',// LD H,RR(IY+d)
rr('t')+';wb(u,l=t)',// LD L,RR(IY+d)
rr('t')+';wb(u,t)',  // RR(IY+d)
rr('t')+';wb(u,a=t)',// LD A,RR(IY+d)
sla('t')+';wb(u,b=t)',// LD B,SLA(IY+d)
sla('t')+';wb(u,c=t)',// LD C,SLA(IY+d)
sla('t')+';wb(u,d=t)',// LD D,SLA(IY+d)
sla('t')+';wb(u,e=t)',// LD E,SLA(IY+d)
sla('t')+';wb(u,h=t)',// LD H,SLA(IY+d)
sla('t')+';wb(u,l=t)',// LD L,SLA(IY+d)
sla('t')+';wb(u,t)',  // SLA(IY+d)
sla('t')+';wb(u,a=t)',// LD A,SLA(IY+d)
sra('t')+';wb(u,b=t)',// LD B,SRA(IY+d)
sra('t')+';wb(u,c=t)',// LD C,SRA(IY+d)
sra('t')+';wb(u,d=t)',// LD D,SRA(IY+d)
sra('t')+';wb(u,e=t)',// LD E,SRA(IY+d)
sra('t')+';wb(u,h=t)',// LD H,SRA(IY+d)
sra('t')+';wb(u,l=t)',// LD L,SRA(IY+d)
sra('t')+';wb(u,t)',  // SRA(IY+d)
sra('t')+';wb(u,a=t)',// LD A,SRA(IY+d)
sll('t')+';wb(u,b=t)',// LD B,SLL(IY+d)
sll('t')+';wb(u,c=t)',// LD C,SLL(IY+d)
sll('t')+';wb(u,d=t)',// LD D,SLL(IY+d)
sll('t')+';wb(u,e=t)',// LD E,SLL(IY+d)
sll('t')+';wb(u,h=t)',// LD H,SLL(IY+d)
sll('t')+';wb(u,l=t)',// LD L,SLL(IY+d)
sll('t')+';wb(u,t)',  // SLL(IY+d)
sll('t')+';wb(u,a=t)',// LD A,SLL(IY+d)
srl('t')+';wb(u,b=t)',// LD B,SRL(IY+d)
srl('t')+';wb(u,c=t)',// LD C,SRL(IY+d)
srl('t')+';wb(u,d=t)',// LD D,SRL(IY+d)
srl('t')+';wb(u,e=t)',// LD E,SRL(IY+d)
srl('t')+';wb(u,h=t)',// LD H,SRL(IY+d)
srl('t')+';wb(u,l=t)',// LD L,SRL(IY+d)
srl('t')+';wb(u,t)',  // SRL(IY+d)
srl('t')+';wb(u,a=t)',// LD A,SRL(IY+d)
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
res(254,'t')+';wb(u,b=t)',// LD B,RES 0,(IY+d)
res(254,'t')+';wb(u,c=t)',// LD C,RES 0,(IY+d)
res(254,'t')+';wb(u,d=t)',// LD D,RES 0,(IY+d)
res(254,'t')+';wb(u,e=t)',// LD E,RES 0,(IY+d)
res(254,'t')+';wb(u,h=t)',// LD H,RES 0,(IY+d)
res(254,'t')+';wb(u,l=t)',// LD L,RES 0,(IY+d)
res(254,'t')+';wb(u,t)',  // RES 0,(IY+d)
res(254,'t')+';wb(u,a=t)',// LD A,RES 0,(IY+d)
res(253,'t')+';wb(u,b=t)',// LD B,RES 1,(IY+d)
res(253,'t')+';wb(u,c=t)',// LD C,RES 1,(IY+d)
res(253,'t')+';wb(u,d=t)',// LD D,RES 1,(IY+d)
res(253,'t')+';wb(u,e=t)',// LD E,RES 1,(IY+d)
res(253,'t')+';wb(u,h=t)',// LD H,RES 1,(IY+d)
res(253,'t')+';wb(u,l=t)',// LD L,RES 1,(IY+d)
res(253,'t')+';wb(u,t)',  // RES 1,(IY+d)
res(253,'t')+';wb(u,a=t)',// LD A,RES 1,(IY+d)
res(251,'t')+';wb(u,b=t)',// LD B,RES 2,(IY+d)
res(251,'t')+';wb(u,c=t)',// LD C,RES 2,(IY+d)
res(251,'t')+';wb(u,d=t)',// LD D,RES 2,(IY+d)
res(251,'t')+';wb(u,e=t)',// LD E,RES 2,(IY+d)
res(251,'t')+';wb(u,h=t)',// LD H,RES 2,(IY+d)
res(251,'t')+';wb(u,l=t)',// LD L,RES 2,(IY+d)
res(251,'t')+';wb(u,t)',  // RES 2,(IY+d)
res(251,'t')+';wb(u,a=t)',// LD A,RES 2,(IY+d)
res(247,'t')+';wb(u,b=t)',// LD B,RES 3,(IY+d)
res(247,'t')+';wb(u,c=t)',// LD C,RES 3,(IY+d)
res(247,'t')+';wb(u,d=t)',// LD D,RES 3,(IY+d)
res(247,'t')+';wb(u,e=t)',// LD E,RES 3,(IY+d)
res(247,'t')+';wb(u,h=t)',// LD H,RES 3,(IY+d)
res(247,'t')+';wb(u,l=t)',// LD L,RES 3,(IY+d)
res(247,'t')+';wb(u,t)',  // RES 3,(IY+d)
res(247,'t')+';wb(u,a=t)',// LD A,RES 3,(IY+d)
res(239,'t')+';wb(u,b=t)',// LD B,RES 4,(IY+d)
res(239,'t')+';wb(u,c=t)',// LD C,RES 4,(IY+d)
res(239,'t')+';wb(u,d=t)',// LD D,RES 4,(IY+d)
res(239,'t')+';wb(u,e=t)',// LD E,RES 4,(IY+d)
res(239,'t')+';wb(u,h=t)',// LD H,RES 4,(IY+d)
res(239,'t')+';wb(u,l=t)',// LD L,RES 4,(IY+d)
res(239,'t')+';wb(u,t)',  // RES 4,(IY+d)
res(239,'t')+';wb(u,a=t)',// LD A,RES 4,(IY+d)
res(223,'t')+';wb(u,b=t)',// LD B,RES 5,(IY+d)
res(223,'t')+';wb(u,c=t)',// LD C,RES 5,(IY+d)
res(223,'t')+';wb(u,d=t)',// LD D,RES 5,(IY+d)
res(223,'t')+';wb(u,e=t)',// LD E,RES 5,(IY+d)
res(223,'t')+';wb(u,h=t)',// LD H,RES 5,(IY+d)
res(223,'t')+';wb(u,l=t)',// LD L,RES 5,(IY+d)
res(223,'t')+';wb(u,t)',  // RES 5,(IY+d)
res(223,'t')+';wb(u,a=t)',// LD A,RES 5,(IY+d)
res(191,'t')+';wb(u,b=t)',// LD B,RES 6,(IY+d)
res(191,'t')+';wb(u,c=t)',// LD C,RES 6,(IY+d)
res(191,'t')+';wb(u,d=t)',// LD D,RES 6,(IY+d)
res(191,'t')+';wb(u,e=t)',// LD E,RES 6,(IY+d)
res(191,'t')+';wb(u,h=t)',// LD H,RES 6,(IY+d)
res(191,'t')+';wb(u,l=t)',// LD L,RES 6,(IY+d)
res(191,'t')+';wb(u,t)',  // RES 6,(IY+d)
res(191,'t')+';wb(u,a=t)',// LD A,RES 6,(IY+d)
res(127,'t')+';wb(u,b=t)',// LD B,RES 7,(IY+d)
res(127,'t')+';wb(u,c=t)',// LD C,RES 7,(IY+d)
res(127,'t')+';wb(u,d=t)',// LD D,RES 7,(IY+d)
res(127,'t')+';wb(u,e=t)',// LD E,RES 7,(IY+d)
res(127,'t')+';wb(u,h=t)',// LD H,RES 7,(IY+d)
res(127,'t')+';wb(u,l=t)',// LD L,RES 7,(IY+d)
res(127,'t')+';wb(u,t)',  // RES 7,(IY+d)
res(127,'t')+';wb(u,a=t)',// LD A,RES 7,(IY+d)
set(1,'t')+';wb(u,b=t)',  // LD B,SET 0,(IY+d)
set(1,'t')+';wb(u,c=t)',  // LD C,SET 0,(IY+d)
set(1,'t')+';wb(u,d=t)',  // LD D,SET 0,(IY+d)
set(1,'t')+';wb(u,e=t)',  // LD E,SET 0,(IY+d)
set(1,'t')+';wb(u,h=t)',  // LD H,SET 0,(IY+d)
set(1,'t')+';wb(u,l=t)',  // LD L,SET 0,(IY+d)
set(1,'t')+';wb(u,t)',    // SET 0,(IY+d)
set(1,'t')+';wb(u,a=t)',  // LD A,SET 0,(IY+d)
set(2,'t')+';wb(u,b=t)',  // LD B,SET 1,(IY+d)
set(2,'t')+';wb(u,c=t)',  // LD C,SET 1,(IY+d)
set(2,'t')+';wb(u,d=t)',  // LD D,SET 1,(IY+d)
set(2,'t')+';wb(u,e=t)',  // LD E,SET 1,(IY+d)
set(2,'t')+';wb(u,h=t)',  // LD H,SET 1,(IY+d)
set(2,'t')+';wb(u,l=t)',  // LD L,SET 1,(IY+d)
set(2,'t')+';wb(u,t)',    // SET 1,(IY+d)
set(2,'t')+';wb(u,a=t)',  // LD A,SET 1,(IY+d)
set(4,'t')+';wb(u,b=t)',  // LD B,SET 2,(IY+d)
set(4,'t')+';wb(u,c=t)',  // LD C,SET 2,(IY+d)
set(4,'t')+';wb(u,d=t)',  // LD D,SET 2,(IY+d)
set(4,'t')+';wb(u,e=t)',  // LD E,SET 2,(IY+d)
set(4,'t')+';wb(u,h=t)',  // LD H,SET 2,(IY+d)
set(4,'t')+';wb(u,l=t)',  // LD L,SET 2,(IY+d)
set(4,'t')+';wb(u,t)',    // SET 2,(IY+d)
set(4,'t')+';wb(u,a=t)',  // LD A,SET 2,(IY+d)
set(8,'t')+';wb(u,b=t)',  // LD B,SET 3,(IY+d)
set(8,'t')+';wb(u,c=t)',  // LD C,SET 3,(IY+d)
set(8,'t')+';wb(u,d=t)',  // LD D,SET 3,(IY+d)
set(8,'t')+';wb(u,e=t)',  // LD E,SET 3,(IY+d)
set(8,'t')+';wb(u,h=t)',  // LD H,SET 3,(IY+d)
set(8,'t')+';wb(u,l=t)',  // LD L,SET 3,(IY+d)
set(8,'t')+';wb(u,t)',    // SET 3,(IY+d)
set(8,'t')+';wb(u,a=t)',  // LD A,SET 3,(IY+d)
set(16,'t')+';wb(u,b=t)', // LD B,SET 4,(IY+d)
set(16,'t')+';wb(u,c=t)', // LD C,SET 4,(IY+d)
set(16,'t')+';wb(u,d=t)', // LD D,SET 4,(IY+d)
set(16,'t')+';wb(u,e=t)', // LD E,SET 4,(IY+d)
set(16,'t')+';wb(u,h=t)', // LD H,SET 4,(IY+d)
set(16,'t')+';wb(u,l=t)', // LD L,SET 4,(IY+d)
set(16,'t')+';wb(u,t)',   // SET 4,(IY+d)
set(16,'t')+';wb(u,a=t)', // LD A,SET 4,(IY+d)
set(32,'t')+';wb(u,b=t)', // LD B,SET 5,(IY+d)
set(32,'t')+';wb(u,c=t)', // LD C,SET 5,(IY+d)
set(32,'t')+';wb(u,d=t)', // LD D,SET 5,(IY+d)
set(32,'t')+';wb(u,e=t)', // LD E,SET 5,(IY+d)
set(32,'t')+';wb(u,h=t)', // LD H,SET 5,(IY+d)
set(32,'t')+';wb(u,l=t)', // LD L,SET 5,(IY+d)
set(32,'t')+';wb(u,t)',   // SET 5,(IY+d)
set(32,'t')+';wb(u,a=t)', // LD A,SET 5,(IY+d)
set(64,'t')+';wb(u,b=t)', // LD B,SET 6,(IY+d)
set(64,'t')+';wb(u,c=t)', // LD C,SET 6,(IY+d)
set(64,'t')+';wb(u,d=t)', // LD D,SET 6,(IY+d)
set(64,'t')+';wb(u,e=t)', // LD E,SET 6,(IY+d)
set(64,'t')+';wb(u,h=t)', // LD H,SET 6,(IY+d)
set(64,'t')+';wb(u,l=t)', // LD L,SET 6,(IY+d)
set(64,'t')+';wb(u,t)',   // SET 6,(IY+d)
set(64,'t')+';wb(u,a=t)', // LD A,SET 6,(IY+d)
set(128,'t')+';wb(u,b=t)',// LD B,SET 7,(IY+d)
set(128,'t')+';wb(u,c=t)',// LD C,SET 7,(IY+d)
set(128,'t')+';wb(u,d=t)',// LD D,SET 7,(IY+d)
set(128,'t')+';wb(u,e=t)',// LD E,SET 7,(IY+d)
set(128,'t')+';wb(u,h=t)',// LD H,SET 7,(IY+d)
set(128,'t')+';wb(u,l=t)',// LD L,SET 7,(IY+d)
set(128,'t')+';wb(u,t)',  // SET 7,(IY+d)
set(128,'t')+';wb(u,a=t)',// LD A,SET 7,(IY+d)

nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
inr('b'),                 // IN B,(C)
outr('b'),                // OUT (C,B
sbchlrr('b', 'c'),        // SBC HL,BC
ldpnnrr('b', 'c', 20),    // LD (NN,BC
neg(),                    // NEG
ret(14),                  // RETN
'st+=8;im=0',             // IM 0
ldrr('i', 'a', 9),        // LD I,A
inr('c'),                 // IN C,(C)
outr('c'),                // OUT (C,C
adchlrr('b', 'c'),        // ADC HL,BC
ldrrpnn('b', 'c', 20),    // LD BC,(NN)
neg(),                    // NEG
ret(14),                  // RETI
'st+=8;im=0',             // IM 0
ldrr('r=r7', 'a', 9),     // LD R,A
inr('d'),                 // IN D,(C)
outr('d'),                // OUT (C,D
sbchlrr('d', 'e'),        // SBC HL,DE
ldpnnrr('d', 'e', 20),    // LD (NN,DE
neg(),                    // NEG
ret(14),                  // RETN
'st+=8;im=1',             // IM 1
ldair('i'),               // LD A,I
inr('e'),                 // IN E,(C)
outr('e'),                // OUT (C,E
adchlrr('d', 'e'),        // ADC HL,DE
ldrrpnn('d', 'e', 20),    // LD DE,(NN)
neg(),                    // NEG
ret(14),                  // RETI
'st+=8;im=2',             // IM 2
ldair('r&127|r7&128'),    // LD A,R
inr('h'),                 // IN H,(C)
outr('h'),                // OUT (C,H
sbchlrr('h', 'l'),        // SBC HL,HL
ldpnnrr('h', 'l', 20),    // LD (NN,HL
neg(),                    // NEG
ret(14),                  // RETN
'st+=8;im=0',             // IM 0
'st+=18;t=m[u=l|h<<8];wb(u,a<<4&240|t>>4);a=a&240|t&15;f=f&1|szp[a]',// RRD
inr('l'),                 // IN L,(C)
outr('l'),                // OUT (C,L
adchlrr('h', 'l'),        // ADC HL,HL
ldrrpnn('h', 'l', 20),    // LD HL,(NN)
neg(),                    // NEG
ret(14),                  // RETI
'st+=8;im=0',             // IM 0
'st+=18;t=m[u=l|h<<8];wb(u,t<<4&240|a&15);a=a&240|t>>4;f=f&1|szp[a]',// RLD
inr('t'),               // IN X,(C)
outr('0'),                // OUT (C,X
'st+=15;f=(l|h<<8)-sp-(f&1);l=f&255;f=f>>16&1|(f>>8^sp>>8^h)&16|((f>>8^h)&(h^sp>>8)&128)>>5|(h=f>>8&255)&168|(l|h?2:66)',// SBC HL,SP
'st+=20;wb(t=m[pc++&65535]|m[pc++&65535]<<8,sp&255);wb(t+1&65535,sp>>8)',// LD (NN),SP
//'st+=20;wb(t=m[pc++&65535]|m[pc++&65535]<<8,sp);wb(t+1&65535,sp>>8)',// LD (NN),SP
neg(),                    // NEG
ret(14),                  // RETN
'st+=8;im=1',             // IM 1
nop(8),                   // NOP
inr('a'),                 // IN A,(C)
outr('a'),                // OUT (C,A
'st+=15;f=(l|h<<8)+sp+(f&1);l=f&255;f=f>>16|(f>>8^sp>>8^h)&16|((f^h<<8)&(f^sp)&32768)>>13|(h=f>>8&255)&168|(l|h?0:64)',// ADC HL,SP
'st+=20;sp=m[t=m[pc++&65535]|m[pc++&65535]<<8]|m[t+1&65535]<<8',// LD SP,(NN)
neg(),                    // NEG
ret(14),                  // RETI
'st+=8;im=2',             // IM 2
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
ldid(1, 0),               // LDI
cpid(1, 0),               // CPI
inid(1, 0),               // INI
otid(1, 0),               // OUTI
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
ldid(0, 0),               // LDD
cpid(0, 0),               // CPD
inid(0, 0),               // IND
otid(0, 0),               // OUTD
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
ldid(1, 1),               // LDIR
cpid(1, 1),               // CPIR
inid(1, 1),               // INIR
otid(1, 1),               // OTIR
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
ldid(0, 1),               // LDDR
cpid(0, 1),               // CPDR
inid(0, 1),               // INDR
otid(0, 1),               // OTDR
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
'loadblock()',            // tape loader trap
nop(8),                   // NOP
nop(8),                   // NOP
nop(8),                   // NOP
];

g= [];
for (j=0; j<1536; j++)
  g[j]= new Function(p[j]);
