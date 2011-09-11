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

<?
$mp= 1;

function a($a){
  echo 'function(){'.$a."},\n";
}
function nop($n){
  return 'st+='.$n;
}

function inc($r) {
  return 'st+=4;'.
  'f=f&1|szi['.$r.'='.$r.'+1&255]';
//  'ff=ff&256|(fr='.$r.'=(fa='.$r.')+(fb=1)&255)';
}

function dec($r) {
  return 'st+=4;'.
  'f=f&1|szd['.$r.'='.$r.'-1&255]';
//   ff=ff&256|(fr='.$r.'=(fa='.$r.')+(fb=-1)&255)';
}

function incdecphl($n) {
  return 'st+=11;'.
  'wb(t=l|h<<8,t=m[t]'.$n.'1&255);'.
  'f=f&1|sz'.($n=='+'?'i':'d').'[t]';
//'fa=m[t=l|h<<8];'.
//'ff=ff&256|(fr=fa+(fb='.($n=='+'?'':'-').'1)&255);'.
//'wb(t,fr)';
}

function incdecpi($a, $b) {
  return 'st+=19;'.
  'wb(t=((m[pc++&65535]^128)+128+('.$a.'l|'.$a.'h<<8))&65535,t=m[t]'.$b.'1&255);'.
  'f=f&1|sz'.($b=='+'?'i':'d').'[t]';
//'fa=m[t=((m[pc++&65535]^128)+128+('.$a.'l|'.$a.'h<<8))&65535];'.
//'ff=ff&256|(fr=fa+(fb='.($n=='+'?'':'-').'1)&255);'.
//'wb(t,fr)';
}

function incw($a, $b) {
  return 'st+=6;'.
  '++'.$b.'==256&&('.
                    $b.'=0,'.
                    $a.'='.$a.'+1&255)';
}

function decw($a, $b) {
  return 'st+=6;'.
  '--'.$b.'<0&&('.
                $a.'='.$a.'-1&('.$b.'=255))';
}

function ldpr($a, $b, $r) {
  global $mp;
  return  'st+=7;'.
          'wb('.$b.'|'.$a.'<<8,'.$r.')'.
          ($mp?';mp='.$b.'+1&255|a<<8':'');
}

function ldpri($a, $b) {
  return 'st+=15;'.
  'wb((se[m[pc++&65535]]+('.$b.'l|'.$b.'h<<8))&65535,'.$a.')';
}

function ldrp($a, $b, $r, $t) {
  return 'st+=7;'.
  ($t   ? $r.'=m[t='.$b.'|'.$a.'<<8];'.
          'mp=t+1'
        : $r.'=m['.$b.'|'.$a.'<<8]');
}

function ldrpi($a, $b) {
  return 'st+=15;'.
  $a.'=m[(se[m[pc++&65535]]+('.$b.'l|'.$b.'h<<8))&65535]';
}

function ldrrim($a, $b) {
  return 'st+=10;'.
  $b.'=m[pc++&65535];'.
  $a.'=m[pc++&65535]';
}

function ldrim($r) {
  return 'st+=7;'.
  $r.'=m[pc++&65535]';
}

function ldpin($r) {
  return 'st+=15;'.
  'wb((se[m[pc++&65535]]+('.$r.'l|'.$r.'h<<8))&65535, m[pc++&65535])';
}

function addrrrr($a, $b, $c, $d) {
  return 'st+=11;'.
  't='.$b.'+'.$d.'+('.$a.'+'.$c.'<<8);'.
  'f=f&196|t>>16|t>>8&40|(t>>8^'.$a.'^'.$c.')&16;'.
//  'ff=ff&128|t>>8&296;fb=fb&128|(t>>8^'.$a.'^'.$c.'^fr^fa)&16;'.
//  ($mp?'':'mp='.$b.'+1+('.$a.'<<8);');
  $a.'=t>>8&255;'.
  $b.'=t&255';
}

function addisp($r) {
  return 'st+=11;'.
  't=sp+('.$r.'l|'.$r.'h<<8);'.
  'f=f&196|t>>16|t>>8&40|(t>>8^sp>>8^'.$r.'h)&16;'.
  $r.'h=t>>8&255;'.
  $r.'l=t&255';
}

function jrc($c) {
  return 'if('.$c.')'.
    'st+=7,'.
    'pc++;'.
  'else '.
    'st+=12,'.
    'pc+=(m[pc&65535]^128)-127';
}

function jrci($c) {
  return 'if('.$c.')'.
    'st+=12,'.
    'pc+=(m[pc&65535]^128)-127';
  'else '.
    'st+=7,'.
    'pc++;'.
}

function jpc($c) {
  return 'st+=10;'.
  'if('.$c.')'.
    'pc+=2;'.
  'else '.
    'pc=m[pc&65535]|m[pc+1&65535]<<8';
}

function jpci($c) {
  return 'st+=10;'.
  'if('.$c.')'.
    'pc=m[pc&65535]|m[pc+1&65535]<<8';
  'else '.
    'pc+=2;'.
}

function callc($c) {
  return 'if('.$c.')'.
    'st+=10,'.
    'pc+=2;'.
  'else '.
    'st+=17,'.
    't=pc+2,'.
    'pc=m[pc&65535]|m[pc+1&65535]<<8,'.
    'wb(--sp&65535,t>>8&255),'.
    'wb(sp=sp-1&65535,t&255)';
}

function callci($c) {
  return 'if('.$c.')'.
    'st+=17,'.
    't=pc+2,'.
    'pc=m[pc&65535]|m[pc+1&65535]<<8,'.
    'wb(--sp&65535,t>>8&255),'.
    'wb(sp=sp-1&65535,t&255)';
  'else '.
    'st+=10,'.
    'pc+=2;'.
}

function retc($c) {
  return 'if('.$c.')'.
    'st+=5;'.
  'else '.
    'st+=11,'.
    'pc=m[sp]|m[sp+1&65535]<<8,'.
    'sp=sp+2&65535';
}

function retci($c) {
  return 'if('.$c.')'.
    'st+=11,'.
    'pc=m[sp]|m[sp+1&65535]<<8,'.
    'sp=sp+2&65535';
  'else '.
    'st+=5;'.
}

function ret($n){
  return 'st+='.$n.
  ';pc=m[sp]|m[sp+1&65535]<<8;'.
  'sp=sp+2&65535';
}

function ldpnnrr($a, $b, $n) {
  global $mp;
  return 'st+='.$n.';'.
  'wb('.($mp?'mp':'t').'=m[pc++&65535]|m[pc++&65535]<<8,'.$b.');'.
  'wb('.($mp?'mp=mp':'t').'+1&65535,'.$a.')';
}

function ldrrpnn($a, $b, $n) {
  global $mp;
  return 'st+='.$n.';'.
  $b.'=m[t=m[pc++&65535]|m[pc++&65535]<<8];'.
  ($mp?'mp=t+1;':'').
  $a.'=m[t+1&65535]';
}

function ldrr($a, $b, $n){
  return 'st+='.$n.';'.
  $a.'='.$b;
}

function add($a, $b, $n){
  return 'st+='.$n.
  ';f=a+'.$a.';'.
  'f=f>>8|(f^a^'.$b.')&16|((f^a)&(f^'.$b.')&128)>>5|sz[a=f&255]';
//';a=fr=(ff=(fa=a)+(fb='.$a.'))&255';   //quitar $b y la t de la $a
}

function adc($a, $b, $n){
  return 'st+='.$n.
  ';f=a+'.$a.'+(f&1);'.
  'f=f>>8|(f^a^'.$b.')&16|((f^a)&(f^'.$b.')&128)>>5|sz[a=f&255]';
//';a=fr=(ff=(fa=a)+(fb='.$a.')+(ff>>8&1))&255';   //quitar $b y la t de la $a
}

function sub($a, $b, $n){
  return 'st+='.$n.
  ';f=a-'.$a.';'.
  'f=f>>8&1|2|(f^a^'.$b.')&16|((f^a)&(a^'.$b.')&128)>>5|sz[a=f&255]';
//';a=fr=(ff=(fa=a)+(fb=~'.$a.')+1)&255';   //quitar $b y la t de la $a
}

function sbc($a, $b, $n){
  return 'st+='.$n.
  ';f=a-'.$a.'-(f&1);'.
  'f=f>>8&1|2|(f^a^'.$b.')&16|((f^a)&(a^'.$b.')&128)>>5|sz[a=f&255]';
//';a=fr=(ff=(fa=a)+(fb=~'.$a.')+(ff>>8&1^1))&255';   //quitar $b y la t de la $a
}

function anda($r, $n){
  return 'st+='.$n.
  ';f=16|szp[a&='.$r.']';
//';fa=~(a=ff=fr=a&'.$r.');fb=0';
}

function xoror($r, $n){
  return 'st+='.$n.
  ';f=szp[a'.$r.']';
//';fa=(ff=fr=a'.$r.')|256;fb=0';
}

function cp($a, $b, $n){
  return 'st+='.$n.
  ';f=a-'.$a.';'.
  'f=f>>8&1|2|(f^a^'.$b.')&16|((f^a)&(a^'.$b.')&128)>>5|'.$b.'&40|sz[f&255]&215';
//';fr=(fa=a)-'.$a.';fb=~'.$b.';ff=fr&-41|'.$b.'&40;fr&=255';
}

function push($a, $b){
  return 'st+=11;'.
  'wb(--sp&65535,'.$a.');'.
  'wb(sp=sp-1&65535,'.$b.')';
}

function pop($a, $b){
  return 'st+=10;'.
  $b.'=m[sp];'.
  $a.'=m[sp+1&65535];'.
  'sp=sp+2&65535';
}

function rst($n){
  global $mp;
  return 'st+=11;'.
  'wb(--sp&65535,pc>>8&255);'.
  'wb(sp=sp-1&65535,pc&255);'.
  ($mp?'mp=':'').'pc='.$n;
}

function rlc($r){
  return 'st+=8;'.
  $r.'='.$r.'<<1&255|'.$r.'>>7;'.
  'f='.$r.'&1|szp['.$r.']';
}

function rrc($r){
  return 'st+=8;'.
  $r.'='.$r.'>>1|'.$r.'<<7&128;'.
  'f='.$r.'>>7|szp['.$r.']';
}

function rl($r){
  return 'st+=8;'.
  'j='.$r.';'.
  $r.'='.$r.'<<1&255|f&1;'.
  'f=j>>7|szp['.$r.']';
}

function rr($r){
  return 'st+=8;'.
  'j='.$r.';'.
  $r.'='.$r.'>>1|f<<7&128;'.
  'f=j&1|szp['.$r.']';
}

function sla($r){
  return 'st+=8;'.
  'f='.$r.'>>7;'.
  $r.'='.$r.'<<1&255;'.
  'f|=szp['.$r.']';
}

function sra($r){
  return 'st+=8;'.
  'f='.$r.'&1;'.
  $r.'='.$r.'&128|'.$r.'>>1;'.
  'f|=szp['.$r.']';
}

function sll($r){
  return 'st+=8;'.
  'f='.$r.'>>7;'.
  $r.'='.$r.'<<1&255|1;'.
  'f|=szp['.$r.']';
}

function srl($r){
  return 'st+=8;'.
  'f='.$r.'&1;'.
  $r.'>>=1;'.
  'f|=szp['.$r.']';
}

function bit($n, $r){
  return 'st+=8;'.
  'f=f&1|'.$r.'&40|('.$r.'&'.$n.'?16:84)'.($n&128 ? '|'.$r.'&128' : '');
}

function biti($n){
  return 'st+=5;'.
  'f=f&1|u>>8&40|(t&'.$n.'?16:84)'.($n&128 ? '|t&128' : '');
}

function bithl($n){
  return 'st+=12;'.
  'f=f&1|(t=m[l|h<<8])&40|(t&'.$n.'?16:84)'.($n&128 ? '|t&128' : '');
}

function res($n, $r){
  return 'st+=8;'.
  $r.'&='.$n;
}

function reshl($n){
  return 'st+=15;'.
  'wb(t=l|h<<8,m[t]&'.$n.')';
}

function set($n, $r){
  return 'st+=8;'.
  $r.'|='.$n;
}

function sethl($n){
  return 'st+=15;'.
  'wb(t=l|h<<8,m[t]|'.$n.')';
}

function inr($r){
  return 'st+=12;'.
  $r.'=rp(c|b<<8);'.
  'f=f&1|szp['.$r.']';
}

function outr($r){
  return 'st+=12;'.
  'wp(c|b<<8,'.$r.')';
}

function sbchlrr($a, $b) {
  return 'st+=15;'.
  'f='.($a=='h'?'':'l-'.$b.'+(h-'.$a.'<<8)').'-(f&1);'.
  'l=f&255;'.
  'f=f>>16&1|(f>>8^h^'.$a.')&16|((f>>8^h)&(h^'.$a.')&128)>>5|(h=f>>8&255)&168|(l|h?2:66)';
}

function adchlrr($a, $b) {
  return 'st+=15;'.
  'f=l+'.$b.'+(h+'.$a.'<<8)+(f&1);'.
  'l=f&255;'.
  'f=f>>16|(f>>8^h^'.$a.')&16|((f>>8^h)&(f>>8^'.$a.')&128)>>5|(h=f>>8&255)&168|(l|h?0:64)';
}

function neg(){
  return 'st+=8;'.
  'f=(a?3:2)|(-a^a)&16|(-a&a&128)>>5|sz[a=-a&255]';
}

function ldair($r){
  return 'st+=9;'.
  'a='.$r.';'.
  'f=f&1|sz[a]|iff<<2';
}

function ldid($i, $r){
  return 'st+=16;'.
  'wb(e|d<<8,t=m[l|h<<8]);'.
  'if(!c--)'.
    'c=255,'.
    'b=b-1&255;'.
  'if('.($i?'++e>>8':'!e--').')'.
    'e='.($i?'0':'255').','.
    'd=d'.($i?'+':'-').'1&255;'.
  'if('.($i?'++l>>8':'!l--').')'.
    'l='.($i?'0':'255').','.
    'h=h'.($i?'+':'-').'1&255;'.
  'f=f&193|(b|c?4:0)|(t+=a)&8|t<<4&32;'.
  ($r?';if(c|b)st+=5,pc-=2':'');
}

function cpid($i, $r){
  return 'st+=16;'.
  't=a-(u=m[l|h<<8]);'.
  'if(!c--)'.
    'c=255,'.
    'b=b-1&255;'.
  'if('.($i?'++l>>8':'!l--').')'.
    'l='.($i?'0':'255').','.
    'h=h'.($i?'+':'-').'1&255;'.
  'f=f&1|(b|c?6:2)|(t^a^u)&16|(t?t&128:64);'.
  'if(f&16)'.
    't--;'.
  'f|=t&8|t<<4&32'.
  ($r?';if((f&68)==4)st+=5,pc-=2':'');
}

function inid($i, $r){
  return 'st+=16;'.
  'wb(l|h<<8,t=rp(c|b<<8));'.
  'b=b-1&255;'.
  'if('.($i?'++l>>8':'!l--').')'.
    'l='.($i?'0':'255').','.
    'h=h'.($i?'+':'-').'1&255;'.
  'u=t+c'.($i?'+':'-').'1&255;'.
  'f=t>>6&2|(u<t?17:0)|par[u&7^b]|sz[b]'.
  ($r?';if(b)st+=5,pc-=2':'');
}

function otid($i, $r){
  return 'st+=16;'.
  'b=b-1&255;'.
  'wp(c|b<<8,t=m[l|h<<8]);'.
  'if('.($i?'++l>>8':'!l--').')'.
    'l='.($i?'0':'255').','.
    'h=h'.($i?'+':'-').'1&255;'.
  'u=t+l&255;'.
  'f=t>>6&2|(u<t?17:0)|par[u&7^b]|sz[b]'.
  ($r?';if(b)st+=5,pc-=2':'');
}

function exspi($r){
  global $mp;
  return 'st+=19;'.
  't=m[sp];'.
  'wb(sp,'.$r.'l);'.
  $r.'l=t;'.
  't=m[sp+1&65535];'.
  'wb(sp+1&65535,'.$r.'h);'.
  $r.'h=t'.
  ($mp?';mp='.$r.'l|'.$r.'h<<8':'');
}

function ldsppci($a, $b){
  return 'st+='.($a=='sp'?6:4).';'.
  $a.'='.$b.'l|'.$b.'h<<8';
}

echo 'g=[';
a(nop(4));                                                  // 00 // NOP
a(ldrrim('b', 'c'));                                        // 01 // LD BC,nn
a(ldpr('b', 'c', 'a'));                                     // 02 // LD (BC),A
a(incw('b', 'c'));                                          // 03 // INC BC
a(inc('b'));                                                // 04 // INC B
a(dec('b'));                                                // 05 // DEC B
a(ldrim('b'));                                              // 06 // LD B,n
a('st+=4;a=a<<1&255|a>>7;f=f&196|a&41');                    // 07 // RLCA
//a('st+=4;a=a*257>>7;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
a('st+=4;t=a;a=a_;a_=t;t=f;f=f_;f_=t');                     // 08 // EX AF,AF'
//a('st+=4;t=a_;a_=a;a=t;t=ff_;ff_=ff;ff=t;t=fr_;fr_=fr;fr=t;t=fa_;fa_=fa;fa=t;t=fb_;fb_=fb;fb=t');
a(addrrrr('h', 'l', 'b', 'c'));                             // 09 // ADD HL,BC
a(ldrp('b', 'c', 'a', $mp));                                // 0A // LD A,(BC)
a(decw('b', 'c'));                                          // 0B // DEC BC
a(inc('c'));                                                // 0C // INC C
a(dec('c'));                                                // 0D // DEC C
a(ldrim('c'));                                              // 0E // LD C,n
a('st+=4;f=f&196|a&1|a>>1&40;a=a>>1|a<<7&128');             // 0F // RRCA
//a('st+=4;a=a>>1|((a&1)+1^1)<<7;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
                                                            //10  // DJNZ
a('st+=8;if(b=b-1&255)st+=5,'.($mp?'mp=':'').'pc+=(m[pc&65535]^128)-127;else pc++');
a(ldrrim('d', 'e'));                                        // 11 // LD DE,nn
a(ldpr('d', 'e', 'a'));                                     // 12 // LD (DE),A
a(incw('d', 'e'));                                          // 13 // INC DE
a(inc('d'));                                                // 14 // INC D
a(dec('d'));                                                // 15 // DEC D
a(ldrim('d'));                                              // 16 // LD D,n
a('t=a;st+=4;a=a<<1&255|f&1;f=f&196|a&40|t>>7');            // 17 // RLA
//a('st+=4;a=a<<1|ff>>8&1;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
a('st+=12;'.($mp?'mp=':'').'pc+=(m[pc&65535]^128)-127');    // 18 // JR
a(addrrrr('h', 'l', 'd', 'e'));                             // 19 // ADD HL,DE
a(ldrp('d', 'e', 'a', $mp));                                // 1A // LD A,(DE)
a(decw('d', 'e'));                                          // 1B // DEC DE
a(inc('e'));                                                // 1C // INC E
a(dec('e'));                                                // 1D // DEC E
a(ldrim('e'));                                              // 1E // LD E,n
a('st+=4;t=a;a=a>>1|f<<7&128;f=f&196|a&40|t&1');            // 1F // RRA
//a('st+=4;a=(a*513|ff&256)>>1;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
a(jrc('f&64'));                                             // 20 // JR NZ,s8
//a(jrc('fr'));                                             // 20 // JR NZ,s8
a(ldrrim('h', 'l'));                                        // 21 // LD HL,nn
a(ldpnnrr('h', 'l', 16));                                   // 22 // LD (nn),HL
a(incw('h', 'l'));                                          // 23 // INC HL
a(inc('h'));                                                // 24 // INC H
a(dec('h'));                                                // 25 // DEC H
a(ldrim('h'));                                              // 26 // LD H,n
                                                            // 27 // DAA
a('st+=4;u=f&16||(a&15)>9?6:0;if(f&1||a>153)u|=96;if(a>153)f|=1;f=f&2?f&1|2|((t=a-u)^a^u)&16|szp[a=t&255]:f&1|((t=a+u)^a^u)&16|szp[a=t&255]');
//a('st+=4;t=(fr^fa^fb^fb>>8)&16;u=0;(a|ff&256)>153&&(u=352);(a&15|t)>9&&(u+=6);fa=a|256;fb&512?(a-=u,fb=~u):a+=fb=u,ff=(fr=a&=255)|u&256');
a(jrc('~f&64'));                                            // 28 // JR Z,s8
//a(jrci('fr'));                                             // 28 // JR Z,s8
a(addrrrr('h', 'l', 'h', 'l'));                             // 29 // ADD HL,HL
a(ldrrpnn('h', 'l', 16));                                   // 2a // LD HL,(nn)
a(decw('h', 'l'));                                          // 2b // DEC HL
a(inc('l'));                                                // 2c // INC L
a(dec('l'));                                                // 2d // DEC L
a(ldrim('l'));                                              // 2e // LD L,n
a('st+=4;a^=255;f=f&197|a&40|18');                          // 2f // CPL
//a('st+=4;ff=ff&-41|(a^=255)&40;fb|=-129;fa=fa&-17|~fr&16');
a(jrc('f&1'));                                              // 30 // JR NC,s8
//a(jrc('ff&256'));                                           // 30 // JR NC,s8
a('st+=10;sp=m[pc++&65535]|m[pc++&65535]<<8');              // 31 // LD SP,nn
                                                            // 32 // LD (nn),A
a('st+=13;wb('.($mp?'t=':'').'m[pc++&65535]|m[pc++&65535]<<8,a)'.($mp?';mp='.$b.'+1&255|a<<8':''));
a('st+=6;sp=sp+1&65535');                                   // 33 // INC SP
a(incdecphl('+'));                                          // 34 // INC (HL)
a(incdecphl('-'));                                          // 35 // DEC (HL)
a('st+=10;wb(l|h<<8,m[pc++&65535])');                       // 36 // LD (HL),n
a('st+=4;f=f&196|a&40|1');                                  // 37 // SCF
//a('st+=4;fb=fb&128|(fr^fa)&16;ff=256|ff&128|a&40');
a(jrc('~f&1'));                                             // 38 // JR C,s8
//a(jrci('ff&256'));                                          // 38 // JR C,s8
a(addisp(''));                                              // 39 // ADD HL,SP
                                                            // 3a // LD A,(nn)
a('st+=13;a=m['.($mp?'t=':'').'m[pc++&65535]|m[pc++&65535]<<8]'.($mp?';mp=t+1':''));
a('st+=6;sp=sp-1&65535');                                   // 3b // DEC SP
a(inc('a'));                                                // 3c // INC A
a(dec('a'));                                                // 3d // DEC A
a(ldrim('a'));                                              // 3e // LD A,n
a('st+=4;f=f&196|(f&1?16:1)|a&40');                         // 3f // CCF
//a('st+=4;fb=fb&128|(ff>>4^fr^fa)&16;ff=~ff&256|ff&128|a&40');
a(nop(4));                                                  // 40 // LD B,B
a(ldrr('b', 'c', 4));                                       // 41 // LD B,C
a(ldrr('b', 'd', 4));                                       // 42 // LD B,D
a(ldrr('b', 'e', 4));                                       // 43 // LD B,E
a(ldrr('b', 'h', 4));                                       // 44 // LD B,H
a(ldrr('b', 'l', 4));                                       // 45 // LD B,L
a(ldrp('h', 'l', 'b', 0));                                  // 46 // LD B,(HL)
a(ldrr('b', 'a', 4));                                       // 47 // LD B,A
a(ldrr('c', 'b', 4));                                       // 48 // LD C,B
a(nop(4));                                                  // 49 // LD C,C
a(ldrr('c', 'd', 4));                                       // 4a // LD C,D
a(ldrr('c', 'e', 4));                                       // 4b // LD C,E
a(ldrr('c', 'h', 4));                                       // 4c // LD C,H
a(ldrr('c', 'l', 4));                                       // 4d // LD C,L
a(ldrp('h', 'l', 'c', 0));                                  // 4e // LD C,(HL)
a(ldrr('c', 'a', 4));                                       // 4f // LD C,A
a(ldrr('d', 'b', 4));                                       // 50 // LD D,B
a(ldrr('d', 'c', 4));                                       // 51 // LD D,C
a(nop(4));                                                  // 52 // LD D,D
a(ldrr('d', 'e', 4));                                       // 53 // LD D,E
a(ldrr('d', 'h', 4));                                       // 54 // LD D,H
a(ldrr('d', 'l', 4));                                       // 55 // LD D,L
a(ldrp('h', 'l', 'd', 0));                                  // 56 // LD D,(HL)
a(ldrr('d', 'a', 4));                                       // 57 // LD D,A
a(ldrr('e', 'b', 4));                                       // 58 // LD E,B
a(ldrr('e', 'c', 4));                                       // 59 // LD E,C
a(ldrr('e', 'd', 4));                                       // 5a // LD E,D
a(nop(4));                                                  // 5b // LD E,E
a(ldrr('e', 'h', 4));                                       // 5c // LD E,H
a(ldrr('e', 'l', 4));                                       // 5d // LD E,L
a(ldrp('h', 'l', 'e', 0));                                  // 5e // LD E,(HL)
a(ldrr('e', 'a', 4));                                       // 5f // LD E,A
a(ldrr('h', 'b', 4));                                       // 60 // LD H,B
a(ldrr('h', 'c', 4));                                       // 61 // LD H,C
a(ldrr('h', 'd', 4));                                       // 62 // LD H,D
a(ldrr('h', 'e', 4));                                       // 63 // LD H,E
a(nop(4));                                                  // 64 // LD H,H
a(ldrr('h', 'l', 4));                                       // 65 // LD H,L
a(ldrp('h', 'l', 'h', 0));                                  // 66 // LD H,(HL)
a(ldrr('h', 'a', 4));                                       // 67 // LD H,A
a(ldrr('l', 'b', 4));                                       // 68 // LD L,B
a(ldrr('l', 'c', 4));                                       // 69 // LD L,C
a(ldrr('l', 'd', 4));                                       // 6a // LD L,D
a(ldrr('l', 'e', 4));                                       // 6b // LD L,E
a(ldrr('l', 'h', 4));                                       // 6c // LD L,H
a(nop(4));                                                  // 6d // LD L,L
a(ldrp('h', 'l', 'l', 0));                                  // 6e // LD L,(HL)
a(ldrr('l', 'a', 4));                                       // 6f // LD L,A
a(ldpr('h', 'l', 'b'));                                     // 70 // LD (HL),B
a(ldpr('h', 'l', 'c'));                                     // 71 // LD (HL),C
a(ldpr('h', 'l', 'd'));                                     // 72 // LD (HL),D
a(ldpr('h', 'l', 'e'));                                     // 73 // LD (HL),E
a(ldpr('h', 'l', 'h'));                                     // 74 // LD (HL),H
a(ldpr('h', 'l', 'l'));                                     // 75 // LD (HL),L
a('st+=4;halted=1;pc--');                                   // 76 // HALT
a(ldpr('h', 'l', 'a'));                                     // 77 // LD (HL),A
a(ldrr('a', 'b', 4));                                       // 78 // LD A,B
a(ldrr('a', 'c', 4));                                       // 79 // LD A,C
a(ldrr('a', 'd', 4));                                       // 7a // LD A,D
a(ldrr('a', 'e', 4));                                       // 7b // LD A,E
a(ldrr('a', 'h', 4));                                       // 7c // LD A,H
a(ldrr('a', 'l', 4));                                       // 7d // LD A,L
a(ldrp('h', 'l', 'a', 0));                                  // 7e // LD A,(HL)
a(nop(4));                                                  // 7f // LD A,A
a(add('b', 'b', 4));                                        // 80 // ADD A,B
a(add('c', 'c', 4));                                        // 81 // ADD A,C
a(add('d', 'd', 4));                                        // 82 // ADD A,D
a(add('e', 'e', 4));                                        // 83 // ADD A,E
a(add('h', 'h', 4));                                        // 84 // ADD A,H
a(add('l', 'l', 4));                                        // 85 // ADD A,L
a(add('(t=m[l|h<<8])', 't', 7));                            // 86 // ADD A,(HL)
a(add('a', 'a', 4));                                        // 87 // ADD A,A
//a(a=fr=(ff=2*(fa=fb=a))&255');
a(adc('b', 'b', 4));                                        // 88 // ADC A,B
a(adc('c', 'c', 4));                                        // 89 // ADC A,C
a(adc('d', 'd', 4));                                        // 8a // ADC A,D
a(adc('e', 'e', 4));                                        // 8b // ADC A,E
a(adc('h', 'h', 4));                                        // 8c // ADC A,H
a(adc('l', 'l', 4));                                        // 8d // ADC A,L
a(adc('(t=m[l|h<<8])', 't', 7));                            // 8e // ADC A,(HL)
a(adc('a', 'a', 4));                                        // 8f // ADC A,A
//a('a=fr=(ff=2*(fa=fb=a)+(ff>>8&1))&255');
a(sub('b', 'b', 4));                                        // 90 // SUB A,B
a(sub('c', 'c', 4));                                        // 91 // SUB A,C
a(sub('d', 'd', 4));                                        // 92 // SUB A,D
a(sub('e', 'e', 4));                                        // 93 // SUB A,E
a(sub('h', 'h', 4));                                        // 94 // SUB A,H
a(sub('l', 'l', 4));                                        // 95 // SUB A,L
a(sub('(t=m[l|h<<8])', 't', 7));                            // 96 // SUB A,(HL)
a(sub('a', 'a', 4));                                        // 97 // SUB A,A
//a('fb=~(fa=a);a=fr=ff=0');
a(sbc('b', 'b', 4));                                        // 98 // SBC A,B
a(sbc('c', 'c', 4));                                        // 99 // SBC A,C
a(sbc('d', 'd', 4));                                        // 9a // SBC A,D
a(sbc('e', 'e', 4));                                        // 9b // SBC A,E
a(sbc('h', 'h', 4));                                        // 9c // SBC A,H
a(sbc('l', 'l', 4));                                        // 9d // SBC A,L
a(sbc('(t=m[l|h<<8])', 't', 7));                            // 9e // SBC A,(HL)
a(sbc('a', 'a', 4));                                        // 9f // SBC A,A
//a('fb=~(fa=a);a=fr=(ff=ff&256/-256)&255');
a(anda('b', 4));                                            // a0 // AND B
a(anda('c', 4));                                            // a1 // AND C
a(anda('d', 4));                                            // a2 // AND D
a(anda('e', 4));                                            // a3 // AND E
a(anda('h', 4));                                            // a4 // AND H
a(anda('l', 4));                                            // a5 // AND L
a(anda('m[l|h<<8]', 7));                                    // a6 // AND (HL)
a(anda('a', 4));                                            // a7 // AND A
//a('fa=~(ff=fr=a);fb=0');
a(xoror('^=b', 4));                                         // a8 // XOR B
a(xoror('^=c', 4));                                         // a9 // XOR C
a(xoror('^=d', 4));                                         // aa // XOR D
a(xoror('^=e', 4));                                         // ab // XOR E
a(xoror('^=h', 4));                                         // ac // XOR H
a(xoror('^=l', 4));                                         // ad // XOR L
a(xoror('^=m[l|h<<8]', 7));                                 // ae // XOR (HL)
a(xoror('^=a', 4));                                         // af // XOR A
//a('a=ff=fr=fb=0;fa=256');
a(xoror('|=b', 4));                                         // b0 // OR B
a(xoror('|=c', 4));                                         // b1 // OR C
a(xoror('|=d', 4));                                         // b2 // OR D
a(xoror('|=e', 4));                                         // b3 // OR E
a(xoror('|=h', 4));                                         // b4 // OR H
a(xoror('|=l', 4));                                         // b5 // OR L
a(xoror('|=m[l|h<<8]', 7));                                 // b6 // OR (HL)
a(xoror('|=a', 4));                                         // b7 // OR A
//a('fa=(ff=fr=a)|256;fb=0');
a(cp('b', 'b', 4));                                         // b8 // CP B
a(cp('c', 'c', 4));                                         // b9 // CP C
a(cp('d', 'd', 4));                                         // ba // CP D
a(cp('e', 'e', 4));                                         // bb // CP E
a(cp('h', 'h', 4));                                         // bc // CP H
a(cp('l', 'l', 4));                                         // bd // CP L
a(cp('(t=m[l|h<<8])', 't', 7));                             // be // CP (HL)
a(cp('a', 'a', 4));                                         // bf // CP A
//a('fr=0;fb=~(fa=a);ff=a&40');
a(retc('f&64'));                                            // c0 // RET NZ
//a(retc('fr'));                                            // c0 // RET NZ
a(pop('b', 'c'));                                           // c1 // POP BC
a(jpc('f&64'));                                             // c2 // JP NZ
//a(jpc('fr'));                                               // c2 // JP NZ
a('st+=10;'.($mp?'mp=':'').'pc=m[pc&65535]|m[pc+1&65535]<<8');//c3// JP nn
a(callc('f&64'));                                           // c4 // CALL NZ
//a(callc('fr'));                                             // c4 // CALL NZ
a(push('b', 'c'));                                          // c5 // PUSH BC
a(add('(t=m[pc++&65535])', 't', 7));                        // c6 // ADD A,n
a(rst(0));                                                  // c7 // RST 0x00
a(retc('~f&64'));                                           // c8 // RET Z
//a(retci('fr'));                                             // c8 // RET Z
a(ret(10));                                                 // c9 // RET
a(jpc('~f&64'));                                            // ca // JP Z
//a(jpci('fr'));                                              // ca // JP Z
a('r++;g[768+m[pc++&65535]]()');                            // cb // op cb
a(callc('~f&64'));                                          // cc // CALL Z
//a(callci('fr'));                                            // cc // CALL Z
                                                            // cd // CALL NN
a('st+=17;t=pc+2;'.($mp?'mp=':'').'pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8&255);wb(sp=sp-1&65535,t&255)');
a(adc('(t=m[pc++&65535])', 't', 7));                        // ce // ADC A,n
a(rst(8));                                                  // cf // RST 0x08
a(retc('f&1'));                                             // d0 // RET NC
//a(retc('ff&256'));                                           // d0 // RET NC
a(pop('d', 'e'));                                           // d1 // POP DE
a(jpc('f&1'));                                              // d2 // JP NC
//a(jpc('ff&256'));                                           // d2 // JP NC
                                                            // d3 // OUT (n),A
a('st+=11;wp('.($mp?'t=':'').'m[pc++&65535]|a<<8,a)'.($mp?';mp=t+1&255|t&65280':''));
a(callc('f&1'));                                            // d4 // CALL NC
//a(callc('ff&256'));                                         // d4 // CALL NC
a(push('d', 'e'));                                          // d5 // PUSH DE
a(sub('(t=m[pc++&65535])', 't', 7));                        // d6 // SUB A,n
a(rst(16));                                                 // d7 // RST 0x10
a(retc('~f&1'));                                            // d8 // RET C
                                                            // d9 // EXX
a('st+=4;t=b;b=b_;b_=t;t=c;c=c_;c_=t;t=d;d=d_;d_=t;t=e;e=e_;e_=t;t=h;h=h_;h_=t;t=l;l=l_;l_=t');
a(jpc('~f&1'));                                             // da // JP C
                                                            // db // IN A,(n)
a('st+=11;a=rp('.($mp?'t=':'').'m[pc++&65535]|a<<8)'.($mp?';mp=t+1':''));
a(callc('~f&1'));                                           // dc // CALL C
//a(callci('ff&256'));                                        // dc // CALL C
a('st+=4;r++;g[256+m[pc++&65535]]()');                      // dd //op dd
a(sbc('(t=m[pc++&65535])', 't', 7));                        // de // SBC A,n
a(rst(24));                                                 // df // RST 0x18
a(retc('f&4'));                                             // e0 // RET PO
a(pop('h', 'l'));                                           // e1 // POP HL
a(jpc('f&4'));                                              // e2 // JP PO
a(exspi(''));                                               // e3 // EX (SP));HL
a(callc('f&4'));                                            // e4 // CALL PO
//a(callc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128');//e4//CALL PO
a(push('h', 'l'));                                          // e5 // PUSH HL
a(anda('m[pc++&65535]', 7));                                // e6 // AND A,n
a(rst(32));                                                 // e7 // RST 0x20
a(retc('~f&4'));                                            // e8 // RET PE
a(ldsppci('pc', ''));                                       // e9 // JP (HL)
a(jpc('~f&4'));                                             // ea // JP PE
a('st+=4;t=d;d=h;h=t;t=e;e=l;l=t');                         // eb // EX DE,HL
a(callc('~f&4'));                                           // ec // CALL PE
//a(callci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128');//ec//CALL PE
a('r++;g[1280+m[pc++&65535]]()');                           // ed // op ed
a(xoror('^=m[pc++&65535]', 7));                             // ee // XOR A,n
a(rst(40));                                                 // ef // RST 0x28
a(retc('f&128'));                                           // f0 // RET P
a(pop('a', 'f'));                                           // f1 // POP AF
a(jpc('f&128'));                                            // f2 // JP P
a('st+=4;iff=0');                                           // f3 // DI
a(callc('f&128'));                                          // f4 // CALL P
//a(callci('ff&128'));                                        // f4 // CALL P
a(push('a', 'f'));                                          // f5 // PUSH AF
a(xoror('|=m[pc++&65535]', 7));                             // f6 // OR A,n
a(rst(48));                                                 // f7 // RST 0x30
a(retc('~f&128'));                                          // f8 // RET M
a(ldsppci('sp', ''));                                       // f9 // LD SP,HL
a(jpc('~f&128'));                                           // fa // JP M
a('st+=4;iff=1');                                           // fb // EI
a(callc('~f&128'));                                         // fc // CALL M
//a(callc('ff&128'));                                         // f4 // CALL P
a('st+=4;r++;g[512+m[pc++&65535]]()');                      // fd // op fd
a(cp('(t=m[pc++&65535])', 't', 7));                         // fe // CP A,n
a(rst(56));                                                 // ff // RST 0x38

a(nop(4));                                                  // 01 // NOP
a(ldrrim('b', 'c'));                                        // 01 // LD BC,nn
a(ldpr('b', 'c', 'a'));                                     // 01 // LD (BC),A
a(incw('b', 'c'));                                          // 01 // INC BC
a(inc('b'));                                                // 01 // INC B
a(dec('b'));                                                // 01 // DEC B
a(ldrim('b'));                                              // 01 // LD B,n
a('st+=4;a=a<<1&255|a>>7;f=f&196|a&41');
a('st+=4;t=a;a=aa;aa=t;t=f;f=fa;fa=t');                     // 01 // EX AF,AF'
a(addrrrr('xh', 'xl', 'b', 'c'));                           // 01 // ADD IX,BC
a(ldrp('b', 'c', 'a', $mp));                                // 01 // LD A,(BC)
a(decw('b', 'c'));                                          // 01 // DEC BC
a(inc('c'));                                                // 01 // INC C
a(dec('c'));                                                // 01 // DEC C
a(ldrim('c'));                                              // 01 // LD C,n
a('st+=4;f=f&196|a&1|a>>1&40;a=a>>1|a<<7&128');
a('st+=8;if(b=b-1&255)st+=5,pc+=se[m[pc&65535]]+1;else pc++');
a(ldrrim('d', 'e'));                                        // 01 // LD DE,nn
a(ldpr('d', 'e', 'a'));                                     // 01 // LD (DE),A
a(incw('d', 'e'));                                          // 01 // INC DE
a(inc('d'));                                                // 01 // INC D
a(dec('d'));                                                // 01 // DEC D
a(ldrim('d'));                                              // 01 // LD D,n
a('t=a;st+=4;a=a<<1&255|f&1;f=f&196|a&40|t>>7');
a('st+=12;pc+=se[m[pc&65535]]+1');
a(addrrrr('xh', 'xl', 'd', 'e'));                           // 01 // ADD IX,DE
a(ldrp('d', 'e', 'a', $mp));                                // 01 // LD A,(DE)
a(decw('d', 'e'));                                          // 01 // DEC DE
a(inc('e'));                                                // 01 // INC E
a(dec('e'));                                                // 01 // DEC E
a(ldrim('e'));                                              // 01 // LD E,n
a('st+=4;t=a;a=a>>1|f<<7&128;f=f&196|a&40|t&1');
a(jrc('f&64'));                                             // 01 // JR NZ,s8
a(ldrrim('xh', 'xl'));                                      // 01 // LD IX,nn
a(ldpnnrr('xh', 'xl', 16));                                 // 01 // LD (nn,IX
a(incw('xh', 'xl'));                                        // 01 // INC IX
a(inc('xh'));                                               // 01 // INC IXH
a(dec('xh'));                                               // 01 // DEC IXH
a(ldrim('xh'));                                             // 01 // LD IXH,n
a('st+=4;u=f&16||(a&15)>9?6:0;if(f&1||a>153)u|=96;if(a>153)f|=1;f=f&2?f&1|2|((t=a-u)^a^u)&16|szp[a=t&255]:f&1|((t=a+u)^a^u)&16|szp[a=t&255]');
a(jrc('~f&64'));                                            // 01 // JR Z,s8
a(addrrrr('xh', 'xl', 'xh', 'xl'));                                 // 01 // ADD IX,IX
a(ldrrpnn('xh', 'xl', 16));                                 // 01 // LD IX,(nn)
a(decw('xh', 'xl'));                                        // 01 // DEC IX
a(inc('xl'));                                               // 01 // INC IXL
a(dec('xl'));                                               // 01 // DEC IXL
a(ldrim('xl'));                                             // 01 // LD IXL,n
a('st+=4;a^=255;f=f&197|a&40|18');
a(jrc('f&1'));                                              // 01 // JR NC,s8
a('st+=10;sp=m[pc++&65535]|m[pc++&65535]<<8');
a('st+=13;wb(m[pc++&65535]|m[pc++&65535]<<8,a)');
a('st+=6;sp=sp+1&65535');
a(incdecpi('x', '+'));                                      // 01 // INC (IX+d)
a(incdecpi('x', '-'));                                      // 01 // DEC (IX+d)
a(ldpin('x'));                                              // 01 // LD (IX+d,n
a('st+=4;f=f&196|a&40|1');
a(jrc('~f&1'));                                             // 01 // JR C,s8
a(addisp('x'));                                             // 01 // ADD IX,SP
a('st+=13;a=m[m[pc++&65535]|m[pc++&65535]<<8]');
a('st+=6;sp=sp-1&65535');
a(inc('a'));                                                // 01 // INC A
a(dec('a'));                                                // 01 // DEC A
a(ldrim('a'));                                              // 01 // LD A,n
a('st+=4;f=f&196|(f&1?16:1)|a&40');
a(nop(4));                                                  // 01 // LD B,B
a(ldrr('b', 'c', 4));                                       // 01 // LD B,C
a(ldrr('b', 'd', 4));                                       // 01 // LD B,D
a(ldrr('b', 'e', 4));                                       // 01 // LD B,E
a(ldrr('b', 'xh', 4));                                      // 01 // LD B,IXH
a(ldrr('b', 'xl', 4));                                      // 01 // LD B,IXL
a(ldrpi('b', 'x'));                                         // 01 // LD B,(IX+d)
a(ldrr('b', 'a', 4));                                       // 01 // LD B,C
a(ldrr('c', 'b', 4));                                       // 01 // LD C,B
a(nop(4));                                                  // 01 // LD C,C
a(ldrr('c', 'd', 4));                                       // 01 // LD C,D
a(ldrr('c', 'e', 4));                                       // 01 // LD C,E
a(ldrr('c', 'xh', 4));                                      // 01 // LD C,IXH
a(ldrr('c', 'xl', 4));                                      // 01 // LD C,IXL
a(ldrpi('c', 'x'));                                         // 01 // LD C,(IX+d)
a(ldrr('c', 'a', 4));                                       // 01 // LD C,A
a(ldrr('d', 'b', 4));                                       // 01 // LD D,B
a(ldrr('d', 'c', 4));                                       // 01 // LD D,C
a(nop(4));                                                  // 01 // LD D,D
a(ldrr('d', 'e', 4));                                       // 01 // LD D,E
a(ldrr('d', 'xh', 4));                                      // 01 // LD D,IXH
a(ldrr('d', 'xl', 4));                                      // 01 // LD D,IXL
a(ldrpi('d', 'x'));                                         // 01 // LD D,(IX+d)
a(ldrr('d', 'a', 4));                                       // 01 // LD D,A
a(ldrr('e', 'b', 4));                                       // 01 // LD E,B
a(ldrr('e', 'c', 4));                                       // 01 // LD E,C
a(ldrr('e', 'd', 4));                                       // 01 // LD E,D
a(nop(4));                                                  // 01 // LD E,E
a(ldrr('e', 'xh', 4));                                      // 01 // LD E,IXH
a(ldrr('e', 'xl', 4));                                      // 01 // LD E,IXL
a(ldrpi('e', 'x'));                                         // 01 // LD E,(IX+d)
a(ldrr('e', 'a', 4));                                       // 01 // LD E,A
a(ldrr('xh', 'b', 4));                                      // 01 // LD IXH,B
a(ldrr('xh', 'c', 4));                                      // 01 // LD IXH,C
a(ldrr('xh', 'd', 4));                                      // 01 // LD IXH,D
a(ldrr('xh', 'e', 4));                                      // 01 // LD IXH,E
a(nop(4));                                                  // 01 // LD IXH,IXH
a(ldrr('xh', 'xl', 4));                                     // 01 // LD IXH,IXL
a(ldrpi('h', 'x'));                                         // 01 // LD H,(IX+d)
a(ldrr('xh', 'a', 4));                                      // 01 // LD IXH,A
a(ldrr('xl', 'b', 4));                                      // 01 // LD IXL,B
a(ldrr('xl', 'c', 4));                                      // 01 // LD IXL,C
a(ldrr('xl', 'd', 4));                                      // 01 // LD IXL,D
a(ldrr('xl', 'e', 4));                                      // 01 // LD IXL,E
a(ldrr('xl', 'xh', 4));                                     // 01 // LD IXL,IXH
a(nop(4));                                                  // 01 // LD IXL,IXL
a(ldrpi('l', 'x'));                                         // 01 // LD L,(IX+d)
a(ldrr('xl', 'a', 4));                                      // 01 // LD IXL,A
a(ldpri('b', 'x'));                                         // 01 // LD (IX+d,B
a(ldpri('c', 'x'));                                         // 01 // LD (IX+d,C
a(ldpri('d', 'x'));                                         // 01 // LD (IX+d,D
a(ldpri('e', 'x'));                                         // 01 // LD (IX+d,E
a(ldpri('h', 'x'));                                         // 01 // LD (IX+d,H
a(ldpri('l', 'x'));                                         // 01 // LD (IX+d,L
a('st+=4;halted=1;pc--');
a(ldpri('a', 'x'));                                         // 01 // LD (IX+d,A
a(ldrr('a', 'b', 4));                                       // 01 // LD A,B
a(ldrr('a', 'c', 4));                                       // 01 // LD A,C
a(ldrr('a', 'd', 4));                                       // 01 // LD A,D
a(ldrr('a', 'e', 4));                                       // 01 // LD A,E
a(ldrr('a', 'xh', 4));                                      // 01 // LD A,IXH
a(ldrr('a', 'xl', 4));                                      // 01 // LD A,IXL
a(ldrpi('a', 'x'));                                         // 01 // LD A,(IX+d)
a(nop(4));                                                  // 01 // LD A,A
a(add('b', 'b', 4));                                        // 01 // ADD A,B
a(add('c', 'c', 4));                                        // 01 // ADD A,C
a(add('d', 'd', 4));                                        // 01 // ADD A,D
a(add('e', 'e', 4));                                        // 01 // ADD A,E
a(add('xh', 'xh', 4));                                      // 01 // ADD A,IXH
a(add('xl', 'xl', 4));                                      // 01 // ADD A,IXL
a(add('(t=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535])', 't', 15));//01//ADD A,(IX+d)
a(add('a', 'a', 4));                                        // 01 // ADD A,A
a(adc('b', 'b', 4));                                        // 01 // ADC A,B
a(adc('c', 'c', 4));                                        // 01 // ADC A,C
a(adc('d', 'd', 4));                                        // 01 // ADC A,D
a(adc('e', 'e', 4));                                        // 01 // ADC A,E
a(adc('xh', 'xh', 4));                                      // 01 // ADC A,IXH
a(adc('xl', 'xl', 4));                                      // 01 // ADC A,IXL
a(adc('(t=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535])', 't', 15));//01//ADC A,(IX+d)
a(adc('a', 'a', 4));                                        // 01 // ADC A,A
a(sub('b', 'b', 4));                                        // 01 // SUB A,B
a(sub('c', 'c', 4));                                        // 01 // SUB A,C
a(sub('d', 'd', 4));                                        // 01 // SUB A,D
a(sub('e', 'e', 4));                                        // 01 // SUB A,E
a(sub('xh', 'xh', 4));                                      // 01 // SUB A,IXH
a(sub('xl', 'xl', 4));                                      // 01 // SUB A,IXL
a(sub('(t=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535])', 't', 15));//01//SUB A,(IX+d)
a(sub('a', 'a', 4));                                        // 01 // SUB A,A
a(sbc('b', 'b', 4));                                        // 01 // SBC A,B
a(sbc('c', 'c', 4));                                        // 01 // SBC A,C
a(sbc('d', 'd', 4));                                        // 01 // SBC A,D
a(sbc('e', 'e', 4));                                        // 01 // SBC A,E
a(sbc('xh', 'xh', 4));                                      // 01 // SBC A,IXH
a(sbc('xl', 'xl', 4));                                      // 01 // SBC A,IXL
a(sbc('(t=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535])', 't', 15));//01//SBC A,(IX+d)
a(sbc('a', 'a', 4));                                        // 01 // SBC A,A
a(anda('b', 4));                                            // 01 // AND B
a(anda('c', 4));                                            // 01 // AND C
a(anda('d', 4));                                            // 01 // AND D
a(anda('e', 4));                                            // 01 // AND E
a(anda('xh', 4));                                           // 01 // AND IXH
a(anda('xl', 4));                                           // 01 // AND IXL
a(anda('m[(se[m[pc++&65535]]+(xl|xh<<8))&65535]', 15));     // 01 // AND (IX+d)
a(anda('a', 4));                                            // 01 // AND A
a(xoror('^=b', 4));                                         // 01 // XOR B
a(xoror('^=c', 4));                                         // 01 // XOR C
a(xoror('^=d', 4));                                         // 01 // XOR D
a(xoror('^=e', 4));                                         // 01 // XOR E
a(xoror('^=xh', 4));                                        // 01 // XOR IXH
a(xoror('^=xl', 4));                                        // 01 // XOR IXL
a(xoror('^=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535]', 15));  // 01 // XOR (IX+d)
a(xoror('^=a', 4));                                         // 01 // XOR A
a(xoror('|=b', 4));                                         // 01 // OR B
a(xoror('|=c', 4));                                         // 01 // OR C
a(xoror('|=d', 4));                                         // 01 // OR D
a(xoror('|=e', 4));                                         // 01 // OR E
a(xoror('|=xh', 4));                                        // 01 // OR IXH
a(xoror('|=xl', 4));                                        // 01 // OR IXL
a(xoror('|=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535]', 15));  // 01 // OR (IX+d)
a(xoror('|=a', 4));                                         // 01 // OR A
a(cp('b', 'b', 4));                                         // 01 // CP B
a(cp('c', 'c', 4));                                         // 01 // CP C
a(cp('d', 'd', 4));                                         // 01 // CP D
a(cp('e', 'e', 4));                                         // 01 // CP E
a(cp('xh', 'xh', 4));                                       // 01 // CP IXH
a(cp('xl', 'xl', 4));                                       // 01 // CP IXL
a(cp('(t=m[(se[m[pc++&65535]]+(xl|xh<<8))&65535])', 't', 15));//01// CP (IX+d)
a(cp('a', 'a', 4));                                         // 01 // CP A
a(retc('f&64'));                                            // 01 // RET NZ
a(pop('b', 'c'));                                           // 01 // POP BC
a(jpc('f&64'));                                             // 01 // JP NZ
a('st+=10;pc=m[pc&65535]|m[pc+1&65535]<<8');
a(callc('f&64'));                                           // 01 // CALL NZ
a(push('b', 'c'));                                          // 01 // PUSH BC
a(add('(t=m[pc++&65535])', 't', 7));                        // 01 // ADD A,n
a(rst(0));                                                  // 01 // RST 0x00
a(retc('~f&64'));                                           // 01 // RET Z
a(ret(10));                                                 // 01 // RET
a(jpc('~f&64'));                                            // 01 // JP Z
a('st+=11;t=m[u=(se[m[pc++&65535]]+(xl|xh<<8))&65535];g[1024+m[pc++&65535]]()');// 01 // op ddcb
a(callc('~f&64'));                                          // 01 // CALL Z
a('st+=17;t=pc+2;pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8&255);wb(sp=sp-1&65535,t&255)');// 01 // CALL NN
a(adc('(t=m[pc++&65535])', 't', 7));                        // 01 // ADC A,n
a(rst(8));                                                  // 01 // RST 0x08
a(retc('f&1'));                                             // 01 // RET NC
a(pop('d', 'e'));                                           // 01 // POP DE
a(jpc('f&1'));                                              // 01 // JP NC
a('st+=11;wp(m[pc++&65535]|a<<8,a)');
a(callc('f&1'));                                            // 01 // CALL NC
a(push('d', 'e'));                                          // 01 // PUSH DE
a(sub('(t=m[pc++&65535])', 't', 7));                        // 01 // SUB A,n
a(rst(16));                                                 // 01 // RST 0x10
a(retc('~f&1'));                                            // 01 // RET C
a('st+=4;t=b;b=ba;ba=t;t=c;c=ca;ca=t;t=d;d=da;da=t;t=e;e=ea;ea=t;t=h;h=ha;ha=t;t=l;l=la;la=t');
a(jpc('~f&1'));                                             // 01 // JP C
a('st+=11;a=rp(m[pc++&65535]|a<<8)');
a(callc('~f&1'));                                           // 01 // CALL C
a(nop(4));                                                  // 01 // op dd
a(sbc('(t=m[pc++&65535])', 't', 7));                        // 01 // SBC A,n
a(rst(24));                                                 // 01 // RST 0x18
a(retc('f&4'));                                             // 01 // RET PO
a(pop('xh', 'xl'));                                         // 01 // POP IX
a(jpc('f&4'));                                              // 01 // JP PO
a(exspi('x'));                                              // 01 // EX (SP,IX
a(callc('f&4'));                                            // 01 // CALL PO
a(push('xh', 'xl'));                                        // 01 // PUSH IX
a(anda('m[pc++&65535]', 7));                                // 01 // AND A,n
a(rst(32));                                                 // 01 // RST 0x20
a(retc('~f&4'));                                            // 01 // RET PE
a(ldsppci('pc', 'x'));                                      // 01 // JP (IX)
a(jpc('~f&4'));                                             // 01 // JP PE
a('st+=4;t=d;d=h;h=t;t=e;e=l;l=t');
a(callc('~f&4'));                                           // 01 // CALL PE
a('r++;g[1280+m[pc++&65535]]()');                           // 01 //op ed
a(xoror('^=m[pc++&65535]', 7));                             // 01 // XOR A,n
a(rst(40));                                                 // 01 // RST 0x28
a(retc('f&128'));                                           // 01 // RET P
a(pop('a', 'f'));                                           // 01 // POP AF
a(jpc('f&128'));                                            // 01 // JP P
a('st+=4;iff=0');
a(callc('f&128'));                                          // 01 // CALL P
a(push('a', 'f'));                                          // 01 // PUSH AF
a(xoror('|=m[pc++&65535]', 7));                             // 01 // OR A,n
a(rst(48));                                                 // 01 // RST 0x30
a(retc('~f&128'));                                          // 01 // RET M
a(ldsppci('sp', 'x'));                                      // 01 // LD SP,IX
a(jpc('~f&128'));                                           // 01 // JP M
a('st+=4;iff=1');
a(callc('~f&128'));                                         // 01 // CALL M
a(nop(4));                                                  // 01 // op fd
a(cp('(t=m[pc++&65535])', 't', 7));                         // 01 // CP A,n
a(rst(56));                                                 // 01 // RST 0x38

a(nop(4));                                                  // 01 // NOP
a(ldrrim('b', 'c'));                                        // 01 // LD BC,nn
a(ldpr('b', 'c', 'a'));                                     // 01 // LD (BC),A
a(incw('b', 'c'));                                          // 01 // INC BC
a(inc('b'));                                                // 01 // INC B
a(dec('b'));                                                // 01 // DEC B
a(ldrim('b'));                                              // 01 // LD B,n
a('st+=4;a=a<<1&255|a>>7;f=f&196|a&41');
a('st+=4;t=a;a=aa;aa=t;t=f;f=fa;fa=t');                     // 01 // EX AF,AF'
a(addrrrr('yh', 'yl', 'b', 'c'));                           // 01 // ADD IY,BC
a(ldrp('b', 'c', 'a', $mp));                                // 01 // LD A,(BC)
a(decw('b', 'c'));                                          // 01 // DEC BC
a(inc('c'));                                                // 01 // INC C
a(dec('c'));                                                // 01 // DEC C
a(ldrim('c'));                                              // 01 // LD C,n
a('st+=4;f=f&196|a&1|a>>1&40;a=a>>1|a<<7&128');
a('st+=8;if(b=b-1&255)st+=5,pc+=se[m[pc&65535]]+1;else pc++');
a(ldrrim('d', 'e'));                                        // 01 // LD DE,nn
a(ldpr('d', 'e', 'a'));                                     // 01 // LD (DE),A
a(incw('d', 'e'));                                          // 01 // INC DE
a(inc('d'));                                                // 01 // INC D
a(dec('d'));                                                // 01 // DEC D
a(ldrim('d'));                                              // 01 // LD D,n
a('t=a;st+=4;a=a<<1&255|f&1;f=f&196|a&40|t>>7');
a('st+=12;pc+=se[m[pc&65535]]+1');
a(addrrrr('yh', 'yl', 'd', 'e'));                           // 01 // ADD IY,DE
a(ldrp('d', 'e', 'a', $mp));                                // 01 // LD A,(DE)
a(decw('d', 'e'));                                          // 01 // DEC DE
a(inc('e'));                                                // 01 // INC E
a(dec('e'));                                                // 01 // DEC E
a(ldrim('e'));                                              // 01 // LD E,n
a('st+=4;t=a;a=a>>1|f<<7&128;f=f&196|a&40|t&1');
a(jrc('f&64'));                                             // 01 // JR NZ,s8
a(ldrrim('yh', 'yl'));                                      // 01 // LD IY,nn
a(ldpnnrr('yh', 'yl', 16));                                 // 01 // LD (nn,IY
a(incw('yh', 'yl'));                                        // 01 // INC IY
a(inc('yh'));                                               // 01 // INC IYH
a(dec('yh'));                                               // 01 // DEC IYH
a(ldrim('yh'));                                             // 01 // LD IYH,n
a('st+=4;u=f&16||(a&15)>9?6:0;if(f&1||a>153)u|=96;if(a>153)f|=1;f=f&2?f&1|2|((t=a-u)^a^u)&16|szp[a=t&255]:f&1|((t=a+u)^a^u)&16|szp[a=t&255]');
a(jrc('~f&64'));                                            // 01 // JR Z,s8
a(addrrrr('yh', 'yl', 'yh', 'yl'));                         // 01 // ADD IY,IY
a(ldrrpnn('yh', 'yl', 16));                                 // 01 // LD IY,(nn)
a(decw('yh', 'yl'));                                        // 01 // DEC IY
a(inc('yl'));                                               // 01 // INC IYL
a(dec('yl'));                                               // 01 // DEC IYL
a(ldrim('yl'));                                             // 01 // LD IYL,n
a('st+=4;a^=255;f=f&197|a&40|18');
a(jrc('f&1'));                                              // 01 // JR NC,s8
a('st+=10;sp=m[pc++&65535]|m[pc++&65535]<<8');
a('st+=13;wb(m[pc++&65535]|m[pc++&65535]<<8,a)');
a('st+=6;sp=sp+1&65535');
a(incdecpi('y', '+'));                                      // 01 // INC (IY+d)
a(incdecpi('y', '-'));                                      // 01 // DEC (IY+d)
a(ldpin('y'));                                              // 01 // LD (IY+d,n
a('st+=4;f=f&196|a&40|1');
a(jrc('~f&1'));                                             // 01 // JR C,s8
a(addisp('y'));                                             // 01 // ADD IY,SP
a('st+=13;a=m[m[pc++&65535]|m[pc++&65535]<<8]');
a('st+=6;sp=sp-1&65535');
a(inc('a'));                                                // 01 // INC A
a(dec('a'));                                                // 01 // DEC A
a(ldrim('a'));                                              // 01 // LD A,n
a('st+=4;f=f&196|(f&1?16:1)|a&40');
a(nop(4));                                                  // 01 // LD B,B
a(ldrr('b', 'c', 4));                                       // 01 // LD B,C
a(ldrr('b', 'd', 4));                                       // 01 // LD B,D
a(ldrr('b', 'e', 4));                                       // 01 // LD B,E
a(ldrr('b', 'yh', 4));                                      // 01 // LD B,IYH
a(ldrr('b', 'yl', 4));                                      // 01 // LD B,IYL
a(ldrpi('b', 'y'));                                         // 01 // LD B,(IY+d)
a(ldrr('b', 'a', 4));                                       // 01 // LD B,C
a(ldrr('c', 'b', 4));                                       // 01 // LD C,B
a(nop(4));                                                  // 01 // LD C,C
a(ldrr('c', 'd', 4));                                       // 01 // LD C,D
a(ldrr('c', 'e', 4));                                       // 01 // LD C,E
a(ldrr('c', 'yh', 4));                                      // 01 // LD C,IYH
a(ldrr('c', 'yl', 4));                                      // 01 // LD C,IYL
a(ldrpi('c', 'y'));                                         // 01 // LD C,(IY+d)
a(ldrr('c', 'a', 4));                                       // 01 // LD C,A
a(ldrr('d', 'b', 4));                                       // 01 // LD D,B
a(ldrr('d', 'c', 4));                                       // 01 // LD D,C
a(nop(4));                                                  // 01 // LD D,D
a(ldrr('d', 'e', 4));                                       // 01 // LD D,E
a(ldrr('d', 'yh', 4));                                      // 01 // LD D,IYH
a(ldrr('d', 'yl', 4));                                      // 01 // LD D,IYL
a(ldrpi('d', 'y'));                                         // 01 // LD D,(IY+d)
a(ldrr('d', 'a', 4));                                       // 01 // LD D,A
a(ldrr('e', 'b', 4));                                       // 01 // LD E,B
a(ldrr('e', 'c', 4));                                       // 01 // LD E,C
a(ldrr('e', 'd', 4));                                       // 01 // LD E,D
a(nop(4));                                                  // 01 // LD E,E
a(ldrr('e', 'yh', 4));                                      // 01 // LD E,IYH
a(ldrr('e', 'yl', 4));                                      // 01 // LD E,IYL
a(ldrpi('e', 'y'));                                         // 01 // LD E,(IY+d)
a(ldrr('e', 'a', 4));                                       // 01 // LD E,A
a(ldrr('yh', 'b', 4));                                      // 01 // LD IYH,B
a(ldrr('yh', 'c', 4));                                      // 01 // LD IYH,C
a(ldrr('yh', 'd', 4));                                      // 01 // LD IYH,D
a(ldrr('yh', 'e', 4));                                      // 01 // LD IYH,E
a(nop(4));                                                  // 01 // LD IYH,IYH
a(ldrr('yh', 'yl', 4));                                     // 01 // LD IYH,IYL
a(ldrpi('h', 'y'));                                         // 01 // LD H,(IY+d)
a(ldrr('yh', 'a', 4));                                      // 01 // LD IYH,A
a(ldrr('yl', 'b', 4));                                      // 01 // LD IYL,B
a(ldrr('yl', 'c', 4));                                      // 01 // LD IYL,C
a(ldrr('yl', 'd', 4));                                      // 01 // LD IYL,D
a(ldrr('yl', 'e', 4));                                      // 01 // LD IYL,E
a(ldrr('yl', 'yh', 4));                                     // 01 // LD IYL,IYH
a(nop(4));                                                  // 01 // LD IYL,IYL
a(ldrpi('l', 'y'));                                         // 01 // LD L,(IY+d)
a(ldrr('yl', 'a', 4));                                      // 01 // LD IYL,A
a(ldpri('b', 'y'));                                         // 01 // LD (IY+d,B
a(ldpri('c', 'y'));                                         // 01 // LD (IY+d,C
a(ldpri('d', 'y'));                                         // 01 // LD (IY+d,D
a(ldpri('e', 'y'));                                         // 01 // LD (IY+d,E
a(ldpri('h', 'y'));                                         // 01 // LD (IY+d,H
a(ldpri('l', 'y'));                                         // 01 // LD (IY+d,L
a('st+=4;halted=1;pc--');
a(ldpri('a', 'y'));                                         // 01 // LD (IY+d,A
a(ldrr('a', 'b', 4));                                       // 01 // LD A,B
a(ldrr('a', 'c', 4));                                       // 01 // LD A,C
a(ldrr('a', 'd', 4));                                       // 01 // LD A,D
a(ldrr('a', 'e', 4));                                       // 01 // LD A,E
a(ldrr('a', 'yh', 4));                                      // 01 // LD A,IYH
a(ldrr('a', 'yl', 4));                                      // 01 // LD A,IYL
a(ldrpi('a', 'y'));                                         // 01 // LD A,(IY+d)
a(nop(4));                                                  // 01 // LD A,A
a(add('b', 'b', 4));                                        // 01 // ADD A,B
a(add('c', 'c', 4));                                        // 01 // ADD A,C
a(add('d', 'd', 4));                                        // 01 // ADD A,D
a(add('e', 'e', 4));                                        // 01 // ADD A,E
a(add('yh', 'yh', 4));                                      // 01 // ADD A,IYH
a(add('yl', 'yl', 4));                                      // 01 // ADD A,IYL
a(add('(t=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535])', 't', 15));// 01 // ADD A,(IY+d)
a(add('a', 'a', 4));                                        // 01 // ADD A,A
a(adc('b', 'b', 4));                                        // 01 // ADC A,B
a(adc('c', 'c', 4));                                        // 01 // ADC A,C
a(adc('d', 'd', 4));                                        // 01 // ADC A,D
a(adc('e', 'e', 4));                                        // 01 // ADC A,E
a(adc('yh', 'yh', 4));                                      // 01 // ADC A,IYH
a(adc('yl', 'yl', 4));                                      // 01 // ADC A,IYL
a(adc('(t=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535])', 't', 15));// 01 // ADC A,(IY+d)
a(adc('a', 'a', 4));                                        // 01 // ADC A,A
a(sub('b', 'b', 4));                                        // 01 // SUB A,B
a(sub('c', 'c', 4));                                        // 01 // SUB A,C
a(sub('d', 'd', 4));                                        // 01 // SUB A,D
a(sub('e', 'e', 4));                                        // 01 // SUB A,E
a(sub('yh', 'yh', 4));                                      // 01 // SUB A,IYH
a(sub('yl', 'yl', 4));                                      // 01 // SUB A,IYL
a(sub('(t=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535])', 't', 15));// 01 // SUB A,(IY+d)
a(sub('a', 'a', 4));                                        // 01 // SUB A,A
a(sbc('b', 'b', 4));                                        // 01 // SBC A,B
a(sbc('c', 'c', 4));                                        // 01 // SBC A,C
a(sbc('d', 'd', 4));                                        // 01 // SBC A,D
a(sbc('e', 'e', 4));                                        // 01 // SBC A,E
a(sbc('yh', 'yh', 4));                                      // 01 // SBC A,IYH
a(sbc('yl', 'yl', 4));                                      // 01 // SBC A,IYL
a(sbc('(t=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535])', 't', 15));// 01 // SBC A,(IY+d)
a(sbc('a', 'a', 4));                                        // 01 // SBC A,A
a(anda('b', 4));                                            // 01 // AND B
a(anda('c', 4));                                            // 01 // AND C
a(anda('d', 4));                                            // 01 // AND D
a(anda('e', 4));                                            // 01 // AND E
a(anda('yh', 4));                                           // 01 // AND IYH
a(anda('yl', 4));                                           // 01 // AND IYL
a(anda('m[(se[m[pc++&65535]]+(yl|yh<<8))&65535]', 15));     // 01 // AND (IY+d)
a(anda('a', 4));                                            // 01 // AND A
a(xoror('^=b', 4));                                         // 01 // XOR B
a(xoror('^=c', 4));                                         // 01 // XOR C
a(xoror('^=d', 4));                                         // 01 // XOR D
a(xoror('^=e', 4));                                         // 01 // XOR E
a(xoror('^=yh', 4));                                        // 01 // XOR IYH
a(xoror('^=yl', 4));                                        // 01 // XOR IYL
a(xoror('^=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535]', 15));  // 01 // XOR (IY+d)
a(xoror('^=a', 4));                                         // 01 // XOR A
a(xoror('|=b', 4));                                         // 01 // OR B
a(xoror('|=c', 4));                                         // 01 // OR C
a(xoror('|=d', 4));                                         // 01 // OR D
a(xoror('|=e', 4));                                         // 01 // OR E
a(xoror('|=yh', 4));                                        // 01 // OR IYH
a(xoror('|=yl', 4));                                        // 01 // OR IYL
a(xoror('|=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535]', 15));  // 01 // OR (IY+d)
a(xoror('|=a', 4));                                         // 01 // OR A
a(cp('b', 'b', 4));                                         // 01 // CP B
a(cp('c', 'c', 4));                                         // 01 // CP C
a(cp('d', 'd', 4));                                         // 01 // CP D
a(cp('e', 'e', 4));                                         // 01 // CP E
a(cp('yh', 'yh', 4));                                       // 01 // CP IYH
a(cp('yl', 'yl', 4));                                       // 01 // CP IYL
a(cp('(t=m[(se[m[pc++&65535]]+(yl|yh<<8))&65535])', 't', 15));//01// CP (IY+d)
a(cp('a', 'a', 4));                                         // 01 // CP A
a(retc('f&64'));                                            // 01 // RET NZ
a(pop('b', 'c'));                                           // 01 // POP BC
a(jpc('f&64'));                                             // 01 // JP NZ
a('st+=10;pc=m[pc&65535]|m[pc+1&65535]<<8');
a(callc('f&64'));                                           // 01 // CALL NZ
a(push('b', 'c'));                                          // 01 // PUSH BC
a(add('(t=m[pc++&65535])', 't', 7));                        // 01 // ADD A,n
a(rst(0));                                                  // 01 // RST 0x00
a(retc('~f&64'));                                           // 01 // RET Z
a(ret(10));                                                 // 01 // RET
a(jpc('~f&64'));                                            // 01 // JP Z
a('st+=11;t=m[u=(se[m[pc++&65535]]+(yl|yh<<8))&65535];g[1024+m[pc++&65535]]()');
a(callc('~f&64'));                                          // 01 // CALL Z
a('st+=17;t=pc+2;pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8&255);wb(sp=sp-1&65535,t&255)');                               // 01 // CALL NN
a(adc('(t=m[pc++&65535])', 't', 7));                        // 01 // ADC A,n
a(rst(8));                                                  // 01 // RST 0x08
a(retc('f&1'));                                             // 01 // RET NC
a(pop('d', 'e'));                                           // 01 // POP DE
a(jpc('f&1'));                                              // 01 // JP NC
a('st+=11;wp(m[pc++&65535]|a<<8,a)');
a(callc('f&1'));                                            // 01 // CALL NC
a(push('d', 'e'));                                          // 01 // PUSH DE
a(sub('(t=m[pc++&65535])', 't', 7));                        // 01 // SUB A,n
a(rst(16));                                                 // 01 // RST 0x10
a(retc('~f&1'));                                            // 01 // RET C
a('st+=4;t=b;b=ba;ba=t;t=c;c=ca;ca=t;t=d;d=da;da=t;t=e;e=ea;ea=t;t=h;h=ha;ha=t;t=l;l=la;la=t');
a(jpc('~f&1'));                                             // 01 // JP C
a('st+=11;a=rp(m[pc++&65535]|a<<8)');
a(callc('~f&1'));                                           // 01 // CALL C
a(nop(4));                                                  // 01 // op dd
a(sbc('(t=m[pc++&65535])', 't', 7));                        // 01 // SBC A,n
a(rst(24));                                                 // 01 // RST 0x18
a(retc('f&4'));                                             // 01 // RET PO
a(pop('yh', 'yl'));                                         // 01 // POP IY
a(jpc('f&4'));                                              // 01 // JP PO
a(exspi('y'));                                              // 01 // EX (SP,IY
a(callc('f&4'));                                            // 01 // CALL PO
a(push('yh', 'yl'));                                        // 01 // PUSH IY
a(anda('m[pc++&65535]', 7));                                // 01 // AND A,n
a(rst(32));                                                 // 01 // RST 0x20
a(retc('~f&4'));                                            // 01 // RET PE
a(ldsppci('pc', 'y'));                                      // 01 // JP (IY)
a(jpc('~f&4'));                                             // 01 // JP PE
a('st+=4;t=d;d=h;h=t;t=e;e=l;l=t');
a(callc('~f&4'));                                           // 01 // CALL PE
a('r++;g[1280+m[pc++&65535]]()');                           // 01 //op ed
a(xoror('^=m[pc++&65535]', 7));                             // 01 // XOR A,n
a(rst(40));                                                 // 01 // RST 0x28
a(retc('f&128'));                                           // 01 // RET P
a(pop('a', 'f'));                                           // 01 // POP AF
a(jpc('f&128'));                                            // 01 // JP P
a('st+=4;iff=0');
a(callc('f&128'));                                          // 01 // CALL P
a(push('a', 'f'));                                          // 01 // PUSH AF
a(xoror('|=m[pc++&65535]', 7));                             // 01 // OR A,n
a(rst(48));                                                 // 01 // RST 0x30
a(retc('~f&128'));                                          // 01 // RET M
a(ldsppci('sp', 'y'));                                      // 01 // LD SP,IY
a(jpc('~f&128'));                                           // 01 // JP M
a('st+=4;iff=1');
a(callc('~f&128'));                                         // 01 // CALL M
a(nop(4));                                                  // 01 // op fd
a(cp('(t=m[pc++&65535])', 't', 7));                         // 01 // CP A,n
a(rst(56));                                                 // 01 // RST 0x38

a(rlc('b'));                                                // 01 // RLC B
a(rlc('c'));                                                // 01 // RLC C
a(rlc('d'));                                                // 01 // RLC D
a(rlc('e'));                                                // 01 // RLC E
a(rlc('h'));                                                // 01 // RLC H
a(rlc('l'));                                                // 01 // RLC L
a('st+=15;t=l|h<<8;u=m[t];'.rlc('u').';wb(t,u)');
a(rlc('a'));                                                // 01 // RLC A
a(rrc('b'));                                                // 01 // RRC B
a(rrc('c'));                                                // 01 // RRC C
a(rrc('d'));                                                // 01 // RRC D
a(rrc('e'));                                                // 01 // RRC E
a(rrc('h'));                                                // 01 // RRC H
a(rrc('l'));                                                // 01 // RRC L
a('st+=15;t=l|h<<8;u=m[t];'.rrc('u').';wb(t,u)');
a(rrc('a'));                                                // 01 // RRC A
a(rl('b'));                                                 // 01 // RL B
a(rl('c'));                                                 // 01 // RL C
a(rl('d'));                                                 // 01 // RL D
a(rl('e'));                                                 // 01 // RL E
a(rl('h'));                                                 // 01 // RL H
a(rl('l'));                                                 // 01 // RL L
a('st+=15;t=l|h<<8;u=m[t];'.rl('u').';wb(t,u)');
a(rl('a'));                                                 // 01 // RL A
a(rr('b'));                                                 // 01 // RR B
a(rr('c'));                                                 // 01 // RR C
a(rr('d'));                                                 // 01 // RR D
a(rr('e'));                                                 // 01 // RR E
a(rr('h'));                                                 // 01 // RR H
a(rr('l'));                                                 // 01 // RR L
a('st+=15;t=l|h<<8;u=m[t];'.rr('u').';wb(t,u)');
a(rr('a'));                                                 // 01 // RR A
a(sla('b'));                                                // 01 // SLA B
a(sla('c'));                                                // 01 // SLA C
a(sla('d'));                                                // 01 // SLA D
a(sla('e'));                                                // 01 // SLA E
a(sla('h'));                                                // 01 // SLA H
a(sla('l'));                                                // 01 // SLA L
a('st+=15;t=l|h<<8;u=m[t];'.sla('u').';wb(t,u)');
a(sla('a'));                                                // 01 // SLA A
a(sra('b'));                                                // 01 // SRA B
a(sra('c'));                                                // 01 // SRA C
a(sra('d'));                                                // 01 // SRA D
a(sra('e'));                                                // 01 // SRA E
a(sra('h'));                                                // 01 // SRA H
a(sra('l'));                                                // 01 // SRA L
a('st+=15;t=l|h<<8;u=m[t];'.sra('u').';wb(t,u)');
a(sra('a'));                                                // 01 // SRA A
a(sll('b'));                                                // 01 // SLL B
a(sll('c'));                                                // 01 // SLL C
a(sll('d'));                                                // 01 // SLL D
a(sll('e'));                                                // 01 // SLL E
a(sll('h'));                                                // 01 // SLL H
a(sll('l'));                                                // 01 // SLL L
a('st+=15;t=l|h<<8;u=m[t];'.sll('u').';wb(t,u)');
a(sll('a'));                                                // 01 // SLL A
a(srl('b'));                                                // 01 // SRL B
a(srl('c'));                                                // 01 // SRL C
a(srl('d'));                                                // 01 // SRL D
a(srl('e'));                                                // 01 // SRL E
a(srl('h'));                                                // 01 // SRL H
a(srl('l'));                                                // 01 // SRL L
a('st+=15;t=l|h<<8;u=m[t];'.srl('u').';wb(t,u)');
a(srl('a'));                                                // 01 // SRL A
a(bit(1,'b'));                                              // 01 // BIT 0,B
a(bit(1,'c'));                                              // 01 // BIT 0,C
a(bit(1,'d'));                                              // 01 // BIT 0,D
a(bit(1,'e'));                                              // 01 // BIT 0,E
a(bit(1,'h'));                                              // 01 // BIT 0,H
a(bit(1,'l'));                                              // 01 // BIT 0,L
a(bithl(1));                                                // 01 // BIT 0,(HL)
a(bit(1,'a'));                                              // 01 // BIT 0,A
a(bit(2,'b'));                                              // 01 // BIT 1,B
a(bit(2,'c'));                                              // 01 // BIT 1,C
a(bit(2,'d'));                                              // 01 // BIT 1,D
a(bit(2,'e'));                                              // 01 // BIT 1,E
a(bit(2,'h'));                                              // 01 // BIT 1,H
a(bit(2,'l'));                                              // 01 // BIT 1,L
a(bithl(2));                                                // 01 // BIT 1,(HL)
a(bit(2,'a'));                                              // 01 // BIT 1,A
a(bit(4,'b'));                                              // 01 // BIT 2,B
a(bit(4,'c'));                                              // 01 // BIT 2,C
a(bit(4,'d'));                                              // 01 // BIT 2,D
a(bit(4,'e'));                                              // 01 // BIT 2,E
a(bit(4,'h'));                                              // 01 // BIT 2,H
a(bit(4,'l'));                                              // 01 // BIT 2,L
a(bithl(4));                                                // 01 // BIT 2,(HL)
a(bit(4,'a'));                                              // 01 // BIT 2,A
a(bit(8,'b'));                                              // 01 // BIT 3,B
a(bit(8,'c'));                                              // 01 // BIT 3,C
a(bit(8,'d'));                                              // 01 // BIT 3,D
a(bit(8,'e'));                                              // 01 // BIT 3,E
a(bit(8,'h'));                                              // 01 // BIT 3,H
a(bit(8,'l'));                                              // 01 // BIT 3,L
a(bithl(8));                                                // 01 // BIT 3,(HL)
a(bit(8,'a'));                                              // 01 // BIT 3,A
a(bit(16,'b'));                                             // 01 // BIT 4,B
a(bit(16,'c'));                                             // 01 // BIT 4,C
a(bit(16,'d'));                                             // 01 // BIT 4,D
a(bit(16,'e'));                                             // 01 // BIT 4,E
a(bit(16,'h'));                                             // 01 // BIT 4,H
a(bit(16,'l'));                                             // 01 // BIT 4,L
a(bithl(16));                                               // 01 // BIT 4,(HL)
a(bit(16,'a'));                                             // 01 // BIT 4,A
a(bit(32,'b'));                                             // 01 // BIT 5,B
a(bit(32,'c'));                                             // 01 // BIT 5,C
a(bit(32,'d'));                                             // 01 // BIT 5,D
a(bit(32,'e'));                                             // 01 // BIT 5,E
a(bit(32,'h'));                                             // 01 // BIT 5,H
a(bit(32,'l'));                                             // 01 // BIT 5,L
a(bithl(32));                                               // 01 // BIT 5,(HL)
a(bit(32,'a'));                                             // 01 // BIT 5,A
a(bit(64,'b'));                                             // 01 // BIT 6,B
a(bit(64,'c'));                                             // 01 // BIT 6,C
a(bit(64,'d'));                                             // 01 // BIT 6,D
a(bit(64,'e'));                                             // 01 // BIT 6,E
a(bit(64,'h'));                                             // 01 // BIT 6,H
a(bit(64,'l'));                                             // 01 // BIT 6,L
a(bithl(64));                                               // 01 // BIT 6,(HL)
a(bit(64,'a'));                                             // 01 // BIT 6,A
a(bit(128,'b'));                                            // 01 // BIT 7,B
a(bit(128,'c'));                                            // 01 // BIT 7,C
a(bit(128,'d'));                                            // 01 // BIT 7,D
a(bit(128,'e'));                                            // 01 // BIT 7,E
a(bit(128,'h'));                                            // 01 // BIT 7,H
a(bit(128,'l'));                                            // 01 // BIT 7,L
a(bithl(128));                                              // 01 // BIT 7,(HL)
a(bit(128,'a'));                                            // 01 // BIT 7,A
a(res(254,'b'));                                            // 01 // RES 0,B
a(res(254,'c'));                                            // 01 // RES 0,C
a(res(254,'d'));                                            // 01 // RES 0,D
a(res(254,'e'));                                            // 01 // RES 0,E
a(res(254,'h'));                                            // 01 // RES 0,H
a(res(254,'l'));                                            // 01 // RES 0,L
a(reshl(254));                                              // 01 // RES 0,(HL)
a(res(254,'a'));                                            // 01 // RES 0,A
a(res(253,'b'));                                            // 01 // RES 1,B
a(res(253,'c'));                                            // 01 // RES 1,C
a(res(253,'d'));                                            // 01 // RES 1,D
a(res(253,'e'));                                            // 01 // RES 1,E
a(res(253,'h'));                                            // 01 // RES 1,H
a(res(253,'l'));                                            // 01 // RES 1,L
a(reshl(253));                                              // 01 // RES 1,(HL)
a(res(253,'a'));                                            // 01 // RES 1,A
a(res(251,'b'));                                            // 01 // RES 2,B
a(res(251,'c'));                                            // 01 // RES 2,C
a(res(251,'d'));                                            // 01 // RES 2,D
a(res(251,'e'));                                            // 01 // RES 2,E
a(res(251,'h'));                                            // 01 // RES 2,H
a(res(251,'l'));                                            // 01 // RES 2,L
a(reshl(251));                                              // 01 // RES 2,(HL)
a(res(251,'a'));                                            // 01 // RES 2,A
a(res(247,'b'));                                            // 01 // RES 3,B
a(res(247,'c'));                                            // 01 // RES 3,C
a(res(247,'d'));                                            // 01 // RES 3,D
a(res(247,'e'));                                            // 01 // RES 3,E
a(res(247,'h'));                                            // 01 // RES 3,H
a(res(247,'l'));                                            // 01 // RES 3,L
a(reshl(247));                                              // 01 // RES 3,(HL)
a(res(247,'a'));                                            // 01 // RES 3,A
a(res(239,'b'));                                            // 01 // RES 4,B
a(res(239,'c'));                                            // 01 // RES 4,C
a(res(239,'d'));                                            // 01 // RES 4,D
a(res(239,'e'));                                            // 01 // RES 4,E
a(res(239,'h'));                                            // 01 // RES 4,H
a(res(239,'l'));                                            // 01 // RES 4,L
a(reshl(239));                                              // 01 // RES 4,(HL)
a(res(239,'a'));                                            // 01 // RES 4,A
a(res(223,'b'));                                            // 01 // RES 5,B
a(res(223,'c'));                                            // 01 // RES 5,C
a(res(223,'d'));                                            // 01 // RES 5,D
a(res(223,'e'));                                            // 01 // RES 5,E
a(res(223,'h'));                                            // 01 // RES 5,H
a(res(223,'l'));                                            // 01 // RES 5,L
a(reshl(223));                                              // 01 // RES 5,(HL)
a(res(223,'a'));                                            // 01 // RES 5,A
a(res(191,'b'));                                            // 01 // RES 6,B
a(res(191,'c'));                                            // 01 // RES 6,C
a(res(191,'d'));                                            // 01 // RES 6,D
a(res(191,'e'));                                            // 01 // RES 6,E
a(res(191,'h'));                                            // 01 // RES 6,H
a(res(191,'l'));                                            // 01 // RES 6,L
a(reshl(191));                                              // 01 // RES 6,(HL)
a(res(191,'a'));                                            // 01 // RES 6,A
a(res(127,'b'));                                            // 01 // RES 7,B
a(res(127,'c'));                                            // 01 // RES 7,C
a(res(127,'d'));                                            // 01 // RES 7,D
a(res(127,'e'));                                            // 01 // RES 7,E
a(res(127,'h'));                                            // 01 // RES 7,H
a(res(127,'l'));                                            // 01 // RES 7,L
a(reshl(127));                                              // 01 // RES 7,(HL)
a(res(127,'a'));                                            // 01 // RES 7,A
a(set(1,'b'));                                              // 01 // SET 0,B
a(set(1,'c'));                                              // 01 // SET 0,C
a(set(1,'d'));                                              // 01 // SET 0,D
a(set(1,'e'));                                              // 01 // SET 0,E
a(set(1,'h'));                                              // 01 // SET 0,H
a(set(1,'l'));                                              // 01 // SET 0,L
a(sethl(1));                                                // 01 // SET 0,(HL)
a(set(1,'a'));                                              // 01 // SET 0,A
a(set(2,'b'));                                              // 01 // SET 1,B
a(set(2,'c'));                                              // 01 // SET 1,C
a(set(2,'d'));                                              // 01 // SET 1,D
a(set(2,'e'));                                              // 01 // SET 1,E
a(set(2,'h'));                                              // 01 // SET 1,H
a(set(2,'l'));                                              // 01 // SET 1,L
a(sethl(2));                                                // 01 // SET 1,(HL)
a(set(2,'a'));                                              // 01 // SET 1,A
a(set(4,'b'));                                              // 01 // SET 2,B
a(set(4,'c'));                                              // 01 // SET 2,C
a(set(4,'d'));                                              // 01 // SET 2,D
a(set(4,'e'));                                              // 01 // SET 2,E
a(set(4,'h'));                                              // 01 // SET 2,H
a(set(4,'l'));                                              // 01 // SET 2,L
a(sethl(4));                                                // 01 // SET 2,(HL)
a(set(4,'a'));                                              // 01 // SET 2,A
a(set(8,'b'));                                              // 01 // SET 3,B
a(set(8,'c'));                                              // 01 // SET 3,C
a(set(8,'d'));                                              // 01 // SET 3,D
a(set(8,'e'));                                              // 01 // SET 3,E
a(set(8,'h'));                                              // 01 // SET 3,H
a(set(8,'l'));                                              // 01 // SET 3,L
a(sethl(8));                                                // 01 // SET 3,(HL)
a(set(8,'a'));                                              // 01 // SET 3,A
a(set(16,'b'));                                             // 01 // SET 4,B
a(set(16,'c'));                                             // 01 // SET 4,C
a(set(16,'d'));                                             // 01 // SET 4,D
a(set(16,'e'));                                             // 01 // SET 4,E
a(set(16,'h'));                                             // 01 // SET 4,H
a(set(16,'l'));                                             // 01 // SET 4,L
a(sethl(16));                                               // 01 // SET 4,(HL)
a(set(16,'a'));                                             // 01 // SET 4,A
a(set(32,'b'));                                             // 01 // SET 5,B
a(set(32,'c'));                                             // 01 // SET 5,C
a(set(32,'d'));                                             // 01 // SET 5,D
a(set(32,'e'));                                             // 01 // SET 5,E
a(set(32,'h'));                                             // 01 // SET 5,H
a(set(32,'l'));                                             // 01 // SET 5,L
a(sethl(32));                                               // 01 // SET 5,(HL)
a(set(32,'a'));                                             // 01 // SET 5,A
a(set(64,'b'));                                             // 01 // SET 6,B
a(set(64,'c'));                                             // 01 // SET 6,C
a(set(64,'d'));                                             // 01 // SET 6,D
a(set(64,'e'));                                             // 01 // SET 6,E
a(set(64,'h'));                                             // 01 // SET 6,H
a(set(64,'l'));                                             // 01 // SET 6,L
a(sethl(64));                                               // 01 // SET 6,(HL)
a(set(64,'a'));                                             // 01 // SET 6,A
a(set(128,'b'));                                            // 01 // SET 7,B
a(set(128,'c'));                                            // 01 // SET 7,C
a(set(128,'d'));                                            // 01 // SET 7,D
a(set(128,'e'));                                            // 01 // SET 7,E
a(set(128,'h'));                                            // 01 // SET 7,H
a(set(128,'l'));                                            // 01 // SET 7,L
a(sethl(128));                                              // 01 // SET 7,(HL)
a(set(128,'a'));                                            // 01 // SET 7,A

a(rlc('t').';wb(u,b=t)');                                   // 01 // LD B,RLC(IY+d)
a(rlc('t').';wb(u,c=t)');                                   // 01 // LD C,RLC(IY+d)
a(rlc('t').';wb(u,d=t)');                                   // 01 // LD D,RLC(IY+d)
a(rlc('t').';wb(u,e=t)');                                   // 01 // LD E,RLC(IY+d)
a(rlc('t').';wb(u,h=t)');                                   // 01 // LD H,RLC(IY+d)
a(rlc('t').';wb(u,l=t)');                                   // 01 // LD L,RLC(IY+d)
a(rlc('t').';wb(u,t)');                                     // 01 // RLC(IY+d)
a(rlc('t').';wb(u,a=t)');                                   // 01 // LD A,RLC(IY+d)
a(rrc('t').';wb(u,b=t)');                                   // 01 // LD B,RRC(IY+d)
a(rrc('t').';wb(u,c=t)');                                   // 01 // LD C,RRC(IY+d)
a(rrc('t').';wb(u,d=t)');                                   // 01 // LD D,RRC(IY+d)
a(rrc('t').';wb(u,e=t)');                                   // 01 // LD E,RRC(IY+d)
a(rrc('t').';wb(u,h=t)');                                   // 01 // LD H,RRC(IY+d)
a(rrc('t').';wb(u,l=t)');                                   // 01 // LD L,RRC(IY+d)
a(rrc('t').';wb(u,t)');                                     // 01 // RRC(IY+d)
a(rrc('t').';wb(u,a=t)');                                   // 01 // LD A,RRC(IY+d)
a(rl('t').';wb(u,b=t)');                                    // 01 // LD B,RL(IY+d)
a(rl('t').';wb(u,c=t)');                                    // 01 // LD C,RL(IY+d)
a(rl('t').';wb(u,d=t)');                                    // 01 // LD D,RL(IY+d)
a(rl('t').';wb(u,e=t)');                                    // 01 // LD E,RL(IY+d)
a(rl('t').';wb(u,h=t)');                                    // 01 // LD H,RL(IY+d)
a(rl('t').';wb(u,l=t)');                                    // 01 // LD L,RL(IY+d)
a(rl('t').';wb(u,t)');                                      // 01 // RL(IY+d)
a(rl('t').';wb(u,a=t)');                                    // 01 // LD A,RR(IY+d)
a(rr('t').';wb(u,b=t)');                                    // 01 // LD B,RR(IY+d)
a(rr('t').';wb(u,c=t)');                                    // 01 // LD C,RR(IY+d)
a(rr('t').';wb(u,d=t)');                                    // 01 // LD D,RR(IY+d)
a(rr('t').';wb(u,e=t)');                                    // 01 // LD E,RR(IY+d)
a(rr('t').';wb(u,h=t)');                                    // 01 // LD H,RR(IY+d)
a(rr('t').';wb(u,l=t)');                                    // 01 // LD L,RR(IY+d)
a(rr('t').';wb(u,t)');                                      // 01 // RR(IY+d)
a(rr('t').';wb(u,a=t)');                                    // 01 // LD A,RR(IY+d)
a(sla('t').';wb(u,b=t)');                                   // 01 // LD B,SLA(IY+d)
a(sla('t').';wb(u,c=t)');                                   // 01 // LD C,SLA(IY+d)
a(sla('t').';wb(u,d=t)');                                   // 01 // LD D,SLA(IY+d)
a(sla('t').';wb(u,e=t)');                                   // 01 // LD E,SLA(IY+d)
a(sla('t').';wb(u,h=t)');                                   // 01 // LD H,SLA(IY+d)
a(sla('t').';wb(u,l=t)');                                   // 01 // LD L,SLA(IY+d)
a(sla('t').';wb(u,t)');                                     // 01 // SLA(IY+d)
a(sla('t').';wb(u,a=t)');                                   // 01 // LD A,SLA(IY+d)
a(sra('t').';wb(u,b=t)');                                   // 01 // LD B,SRA(IY+d)
a(sra('t').';wb(u,c=t)');                                   // 01 // LD C,SRA(IY+d)
a(sra('t').';wb(u,d=t)');                                   // 01 // LD D,SRA(IY+d)
a(sra('t').';wb(u,e=t)');                                   // 01 // LD E,SRA(IY+d)
a(sra('t').';wb(u,h=t)');                                   // 01 // LD H,SRA(IY+d)
a(sra('t').';wb(u,l=t)');                                   // 01 // LD L,SRA(IY+d)
a(sra('t').';wb(u,t)');                                     // 01 // SRA(IY+d)
a(sra('t').';wb(u,a=t)');                                   // 01 // LD A,SRA(IY+d)
a(sll('t').';wb(u,b=t)');                                   // 01 // LD B,SLL(IY+d)
a(sll('t').';wb(u,c=t)');                                   // 01 // LD C,SLL(IY+d)
a(sll('t').';wb(u,d=t)');                                   // 01 // LD D,SLL(IY+d)
a(sll('t').';wb(u,e=t)');                                   // 01 // LD E,SLL(IY+d)
a(sll('t').';wb(u,h=t)');                                   // 01 // LD H,SLL(IY+d)
a(sll('t').';wb(u,l=t)');                                   // 01 // LD L,SLL(IY+d)
a(sll('t').';wb(u,t)');                                     // 01 // SLL(IY+d)
a(sll('t').';wb(u,a=t)');                                   // 01 // LD A,SLL(IY+d)
a(srl('t').';wb(u,b=t)');                                   // 01 // LD B,SRL(IY+d)
a(srl('t').';wb(u,c=t)');                                   // 01 // LD C,SRL(IY+d)
a(srl('t').';wb(u,d=t)');                                   // 01 // LD D,SRL(IY+d)
a(srl('t').';wb(u,e=t)');                                   // 01 // LD E,SRL(IY+d)
a(srl('t').';wb(u,h=t)');                                   // 01 // LD H,SRL(IY+d)
a(srl('t').';wb(u,l=t)');                                   // 01 // LD L,SRL(IY+d)
a(srl('t').';wb(u,t)');                                     // 01 // SRL(IY+d)
a(srl('t').';wb(u,a=t)');                                   // 01 // LD A,SRL(IY+d)
a(biti(1));                                                 // 01 // BIT 0,(IY+d)
a(biti(1));                                                 // 01 // BIT 0,(IY+d)
a(biti(1));                                                 // 01 // BIT 0,(IY+d)
a(biti(1));                                                 // 01 // BIT 0,(IY+d)
a(biti(1));                                                 // 01 // BIT 0,(IY+d)
a(biti(1));                                                 // 01 // BIT 0,(IY+d)
a(biti(1));                                                 // 01 // BIT 0,(IY+d)
a(biti(1));                                                 // 01 // BIT 0,(IY+d)
a(biti(2));                                                 // 01 // BIT 1,(IY+d)
a(biti(2));                                                 // 01 // BIT 1,(IY+d)
a(biti(2));                                                 // 01 // BIT 1,(IY+d)
a(biti(2));                                                 // 01 // BIT 1,(IY+d)
a(biti(2));                                                 // 01 // BIT 1,(IY+d)
a(biti(2));                                                 // 01 // BIT 1,(IY+d)
a(biti(2));                                                 // 01 // BIT 1,(IY+d)
a(biti(2));                                                 // 01 // BIT 1,(IY+d)
a(biti(4));                                                 // 01 // BIT 2,(IY+d)
a(biti(4));                                                 // 01 // BIT 2,(IY+d)
a(biti(4));                                                 // 01 // BIT 2,(IY+d)
a(biti(4));                                                 // 01 // BIT 2,(IY+d)
a(biti(4));                                                 // 01 // BIT 2,(IY+d)
a(biti(4));                                                 // 01 // BIT 2,(IY+d)
a(biti(4));                                                 // 01 // BIT 2,(IY+d)
a(biti(4));                                                 // 01 // BIT 2,(IY+d)
a(biti(8));                                                 // 01 // BIT 3,(IY+d)
a(biti(8));                                                 // 01 // BIT 3,(IY+d)
a(biti(8));                                                 // 01 // BIT 3,(IY+d)
a(biti(8));                                                 // 01 // BIT 3,(IY+d)
a(biti(8));                                                 // 01 // BIT 3,(IY+d)
a(biti(8));                                                 // 01 // BIT 3,(IY+d)
a(biti(8));                                                 // 01 // BIT 3,(IY+d)
a(biti(8));                                                 // 01 // BIT 3,(IY+d)
a(biti(16));                                                // 01 // BIT 4,(IY+d)
a(biti(16));                                                // 01 // BIT 4,(IY+d)
a(biti(16));                                                // 01 // BIT 4,(IY+d)
a(biti(16));                                                // 01 // BIT 4,(IY+d)
a(biti(16));                                                // 01 // BIT 4,(IY+d)
a(biti(16));                                                // 01 // BIT 4,(IY+d)
a(biti(16));                                                // 01 // BIT 4,(IY+d)
a(biti(16));                                                // 01 // BIT 4,(IY+d)
a(biti(32));                                                // 01 // BIT 5,(IY+d)
a(biti(32));                                                // 01 // BIT 5,(IY+d)
a(biti(32));                                                // 01 // BIT 5,(IY+d)
a(biti(32));                                                // 01 // BIT 5,(IY+d)
a(biti(32));                                                // 01 // BIT 5,(IY+d)
a(biti(32));                                                // 01 // BIT 5,(IY+d)
a(biti(32));                                                // 01 // BIT 5,(IY+d)
a(biti(32));                                                // 01 // BIT 5,(IY+d)
a(biti(64));                                                // 01 // BIT 6,(IY+d)
a(biti(64));                                                // 01 // BIT 6,(IY+d)
a(biti(64));                                                // 01 // BIT 6,(IY+d)
a(biti(64));                                                // 01 // BIT 6,(IY+d)
a(biti(64));                                                // 01 // BIT 6,(IY+d)
a(biti(64));                                                // 01 // BIT 6,(IY+d)
a(biti(64));                                                // 01 // BIT 6,(IY+d)
a(biti(64));                                                // 01 // BIT 6,(IY+d)
a(biti(128));                                               // 01 // BIT 7,(IY+d)
a(biti(128));                                               // 01 // BIT 7,(IY+d)
a(biti(128));                                               // 01 // BIT 7,(IY+d)
a(biti(128));                                               // 01 // BIT 7,(IY+d)
a(biti(128));                                               // 01 // BIT 7,(IY+d)
a(biti(128));                                               // 01 // BIT 7,(IY+d)
a(biti(128));                                               // 01 // BIT 7,(IY+d)
a(biti(128));                                               // 01 // BIT 7,(IY+d)
a(res(254,'t').';wb(u,b=t)');                               // 01 // LD B,RES 0,(IY+d)
a(res(254,'t').';wb(u,c=t)');                               // 01 // LD C,RES 0,(IY+d)
a(res(254,'t').';wb(u,d=t)');                               // 01 // LD D,RES 0,(IY+d)
a(res(254,'t').';wb(u,e=t)');                               // 01 // LD E,RES 0,(IY+d)
a(res(254,'t').';wb(u,h=t)');                               // 01 // LD H,RES 0,(IY+d)
a(res(254,'t').';wb(u,l=t)');                               // 01 // LD L,RES 0,(IY+d)
a(res(254,'t').';wb(u,t)');                                 // 01 // RES 0,(IY+d)
a(res(254,'t').';wb(u,a=t)');                               // 01 // LD A,RES 0,(IY+d)
a(res(253,'t').';wb(u,b=t)');                               // 01 // LD B,RES 1,(IY+d)
a(res(253,'t').';wb(u,c=t)');                               // 01 // LD C,RES 1,(IY+d)
a(res(253,'t').';wb(u,d=t)');                               // 01 // LD D,RES 1,(IY+d)
a(res(253,'t').';wb(u,e=t)');                               // 01 // LD E,RES 1,(IY+d)
a(res(253,'t').';wb(u,h=t)');                               // 01 // LD H,RES 1,(IY+d)
a(res(253,'t').';wb(u,l=t)');                               // 01 // LD L,RES 1,(IY+d)
a(res(253,'t').';wb(u,t)');                                 // 01 // RES 1,(IY+d)
a(res(253,'t').';wb(u,a=t)');                               // 01 // LD A,RES 1,(IY+d)
a(res(251,'t').';wb(u,b=t)');                               // 01 // LD B,RES 2,(IY+d)
a(res(251,'t').';wb(u,c=t)');                               // 01 // LD C,RES 2,(IY+d)
a(res(251,'t').';wb(u,d=t)');                               // 01 // LD D,RES 2,(IY+d)
a(res(251,'t').';wb(u,e=t)');                               // 01 // LD E,RES 2,(IY+d)
a(res(251,'t').';wb(u,h=t)');                               // 01 // LD H,RES 2,(IY+d)
a(res(251,'t').';wb(u,l=t)');                               // 01 // LD L,RES 2,(IY+d)
a(res(251,'t').';wb(u,t)');                                 // 01 // RES 2,(IY+d)
a(res(251,'t').';wb(u,a=t)');                               // 01 // LD A,RES 2,(IY+d)
a(res(247,'t').';wb(u,b=t)');                               // 01 // LD B,RES 3,(IY+d)
a(res(247,'t').';wb(u,c=t)');                               // 01 // LD C,RES 3,(IY+d)
a(res(247,'t').';wb(u,d=t)');                               // 01 // LD D,RES 3,(IY+d)
a(res(247,'t').';wb(u,e=t)');                               // 01 // LD E,RES 3,(IY+d)
a(res(247,'t').';wb(u,h=t)');                               // 01 // LD H,RES 3,(IY+d)
a(res(247,'t').';wb(u,l=t)');                               // 01 // LD L,RES 3,(IY+d)
a(res(247,'t').';wb(u,t)');                                 // 01 // RES 3,(IY+d)
a(res(247,'t').';wb(u,a=t)');                               // 01 // LD A,RES 3,(IY+d)
a(res(239,'t').';wb(u,b=t)');                               // 01 // LD B,RES 4,(IY+d)
a(res(239,'t').';wb(u,c=t)');                               // 01 // LD C,RES 4,(IY+d)
a(res(239,'t').';wb(u,d=t)');                               // 01 // LD D,RES 4,(IY+d)
a(res(239,'t').';wb(u,e=t)');                               // 01 // LD E,RES 4,(IY+d)
a(res(239,'t').';wb(u,h=t)');                               // 01 // LD H,RES 4,(IY+d)
a(res(239,'t').';wb(u,l=t)');                               // 01 // LD L,RES 4,(IY+d)
a(res(239,'t').';wb(u,t)');                                 // 01 // RES 4,(IY+d)
a(res(239,'t').';wb(u,a=t)');                               // 01 // LD A,RES 4,(IY+d)
a(res(223,'t').';wb(u,b=t)');                               // 01 // LD B,RES 5,(IY+d)
a(res(223,'t').';wb(u,c=t)');                               // 01 // LD C,RES 5,(IY+d)
a(res(223,'t').';wb(u,d=t)');                               // 01 // LD D,RES 5,(IY+d)
a(res(223,'t').';wb(u,e=t)');                               // 01 // LD E,RES 5,(IY+d)
a(res(223,'t').';wb(u,h=t)');                               // 01 // LD H,RES 5,(IY+d)
a(res(223,'t').';wb(u,l=t)');                               // 01 // LD L,RES 5,(IY+d)
a(res(223,'t').';wb(u,t)');                                 // 01 // RES 5,(IY+d)
a(res(223,'t').';wb(u,a=t)');                               // 01 // LD A,RES 5,(IY+d)
a(res(191,'t').';wb(u,b=t)');                               // 01 // LD B,RES 6,(IY+d)
a(res(191,'t').';wb(u,c=t)');                               // 01 // LD C,RES 6,(IY+d)
a(res(191,'t').';wb(u,d=t)');                               // 01 // LD D,RES 6,(IY+d)
a(res(191,'t').';wb(u,e=t)');                               // 01 // LD E,RES 6,(IY+d)
a(res(191,'t').';wb(u,h=t)');                               // 01 // LD H,RES 6,(IY+d)
a(res(191,'t').';wb(u,l=t)');                               // 01 // LD L,RES 6,(IY+d)
a(res(191,'t').';wb(u,t)');                                 // 01 // RES 6,(IY+d)
a(res(191,'t').';wb(u,a=t)');                               // 01 // LD A,RES 6,(IY+d)
a(res(127,'t').';wb(u,b=t)');                               // 01 // LD B,RES 7,(IY+d)
a(res(127,'t').';wb(u,c=t)');                               // 01 // LD C,RES 7,(IY+d)
a(res(127,'t').';wb(u,d=t)');                               // 01 // LD D,RES 7,(IY+d)
a(res(127,'t').';wb(u,e=t)');                               // 01 // LD E,RES 7,(IY+d)
a(res(127,'t').';wb(u,h=t)');                               // 01 // LD H,RES 7,(IY+d)
a(res(127,'t').';wb(u,l=t)');                               // 01 // LD L,RES 7,(IY+d)
a(res(127,'t').';wb(u,t)');                                 // 01 // RES 7,(IY+d)
a(res(127,'t').';wb(u,a=t)');                               // 01 // LD A,RES 7,(IY+d)
a(set(1,'t').';wb(u,b=t)');                                 // 01 // LD B,SET 0,(IY+d)
a(set(1,'t').';wb(u,c=t)');                                 // 01 // LD C,SET 0,(IY+d)
a(set(1,'t').';wb(u,d=t)');                                 // 01 // LD D,SET 0,(IY+d)
a(set(1,'t').';wb(u,e=t)');                                 // 01 // LD E,SET 0,(IY+d)
a(set(1,'t').';wb(u,h=t)');                                 // 01 // LD H,SET 0,(IY+d)
a(set(1,'t').';wb(u,l=t)');                                 // 01 // LD L,SET 0,(IY+d)
a(set(1,'t').';wb(u,t)');                                   // 01 // SET 0,(IY+d)
a(set(1,'t').';wb(u,a=t)');                                 // 01 // LD A,SET 0,(IY+d)
a(set(2,'t').';wb(u,b=t)');                                 // 01 // LD B,SET 1,(IY+d)
a(set(2,'t').';wb(u,c=t)');                                 // 01 // LD C,SET 1,(IY+d)
a(set(2,'t').';wb(u,d=t)');                                 // 01 // LD D,SET 1,(IY+d)
a(set(2,'t').';wb(u,e=t)');                                 // 01 // LD E,SET 1,(IY+d)
a(set(2,'t').';wb(u,h=t)');                                 // 01 // LD H,SET 1,(IY+d)
a(set(2,'t').';wb(u,l=t)');                                 // 01 // LD L,SET 1,(IY+d)
a(set(2,'t').';wb(u,t)');                                   // 01 // SET 1,(IY+d)
a(set(2,'t').';wb(u,a=t)');                                 // 01 // LD A,SET 1,(IY+d)
a(set(4,'t').';wb(u,b=t)');                                 // 01 // LD B,SET 2,(IY+d)
a(set(4,'t').';wb(u,c=t)');                                 // 01 // LD C,SET 2,(IY+d)
a(set(4,'t').';wb(u,d=t)');                                 // 01 // LD D,SET 2,(IY+d)
a(set(4,'t').';wb(u,e=t)');                                 // 01 // LD E,SET 2,(IY+d)
a(set(4,'t').';wb(u,h=t)');                                 // 01 // LD H,SET 2,(IY+d)
a(set(4,'t').';wb(u,l=t)');                                 // 01 // LD L,SET 2,(IY+d)
a(set(4,'t').';wb(u,t)');                                   // 01 // SET 2,(IY+d)
a(set(4,'t').';wb(u,a=t)');                                 // 01 // LD A,SET 2,(IY+d)
a(set(8,'t').';wb(u,b=t)');                                 // 01 // LD B,SET 3,(IY+d)
a(set(8,'t').';wb(u,c=t)');                                 // 01 // LD C,SET 3,(IY+d)
a(set(8,'t').';wb(u,d=t)');                                 // 01 // LD D,SET 3,(IY+d)
a(set(8,'t').';wb(u,e=t)');                                 // 01 // LD E,SET 3,(IY+d)
a(set(8,'t').';wb(u,h=t)');                                 // 01 // LD H,SET 3,(IY+d)
a(set(8,'t').';wb(u,l=t)');                                 // 01 // LD L,SET 3,(IY+d)
a(set(8,'t').';wb(u,t)');                                   // 01 // SET 3,(IY+d)
a(set(8,'t').';wb(u,a=t)');                                 // 01 // LD A,SET 3,(IY+d)
a(set(16,'t').';wb(u,b=t)');                                // 01 // LD B,SET 4,(IY+d)
a(set(16,'t').';wb(u,c=t)');                                // 01 // LD C,SET 4,(IY+d)
a(set(16,'t').';wb(u,d=t)');                                // 01 // LD D,SET 4,(IY+d)
a(set(16,'t').';wb(u,e=t)');                                // 01 // LD E,SET 4,(IY+d)
a(set(16,'t').';wb(u,h=t)');                                // 01 // LD H,SET 4,(IY+d)
a(set(16,'t').';wb(u,l=t)');                                // 01 // LD L,SET 4,(IY+d)
a(set(16,'t').';wb(u,t)');                                  // 01 // SET 4,(IY+d)
a(set(16,'t').';wb(u,a=t)');                                // 01 // LD A,SET 4,(IY+d)
a(set(32,'t').';wb(u,b=t)');                                // 01 // LD B,SET 5,(IY+d)
a(set(32,'t').';wb(u,c=t)');                                // 01 // LD C,SET 5,(IY+d)
a(set(32,'t').';wb(u,d=t)');                                // 01 // LD D,SET 5,(IY+d)
a(set(32,'t').';wb(u,e=t)');                                // 01 // LD E,SET 5,(IY+d)
a(set(32,'t').';wb(u,h=t)');                                // 01 // LD H,SET 5,(IY+d)
a(set(32,'t').';wb(u,l=t)');                                // 01 // LD L,SET 5,(IY+d)
a(set(32,'t').';wb(u,t)');                                  // 01 // SET 5,(IY+d)
a(set(32,'t').';wb(u,a=t)');                                // 01 // LD A,SET 5,(IY+d)
a(set(64,'t').';wb(u,b=t)');                                // 01 // LD B,SET 6,(IY+d)
a(set(64,'t').';wb(u,c=t)');                                // 01 // LD C,SET 6,(IY+d)
a(set(64,'t').';wb(u,d=t)');                                // 01 // LD D,SET 6,(IY+d)
a(set(64,'t').';wb(u,e=t)');                                // 01 // LD E,SET 6,(IY+d)
a(set(64,'t').';wb(u,h=t)');                                // 01 // LD H,SET 6,(IY+d)
a(set(64,'t').';wb(u,l=t)');                                // 01 // LD L,SET 6,(IY+d)
a(set(64,'t').';wb(u,t)');                                  // 01 // SET 6,(IY+d)
a(set(64,'t').';wb(u,a=t)');                                // 01 // LD A,SET 6,(IY+d)
a(set(128,'t').';wb(u,b=t)');                               // 01 // LD B,SET 7,(IY+d)
a(set(128,'t').';wb(u,c=t)');                               // 01 // LD C,SET 7,(IY+d)
a(set(128,'t').';wb(u,d=t)');                               // 01 // LD D,SET 7,(IY+d)
a(set(128,'t').';wb(u,e=t)');                               // 01 // LD E,SET 7,(IY+d)
a(set(128,'t').';wb(u,h=t)');                               // 01 // LD H,SET 7,(IY+d)
a(set(128,'t').';wb(u,l=t)');                               // 01 // LD L,SET 7,(IY+d)
a(set(128,'t').';wb(u,t)');                                 // 01 // SET 7,(IY+d)
a(set(128,'t').';wb(u,a=t)');                               // 01 // LD A,SET 7,(IY+d)

a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(inr('b'));                                                // 01 // IN B,(C)
a(outr('b'));                                               // 01 // OUT (C,B
a(sbchlrr('b', 'c'));                                       // 01 // SBC HL,BC
a(ldpnnrr('b', 'c', 20));                                   // 01 // LD (NN,BC
a(neg());                                                   // 01 // NEG
a(ret(14));                                                 // 01 // RETN
a('st+=8;im=0');                                            // 01 // IM 0
a(ldrr('i', 'a', 9));                                       // 01 // LD I,A
a(inr('c'));                                                // 01 // IN C,(C)
a(outr('c'));                                               // 01 // OUT (C,C
a(adchlrr('b', 'c'));                                       // 01 // ADC HL,BC
a(ldrrpnn('b', 'c', 20));                                   // 01 // LD BC,(NN)
a(neg());                                                   // 01 // NEG
a(ret(14));                                                 // 01 // RETI
a('st+=8;im=0');                                            // 01 // IM 0
a(ldrr('r=r7', 'a', 9));                                    // 01 // LD R,A
a(inr('d'));                                                // 01 // IN D,(C)
a(outr('d'));                                               // 01 // OUT (C,D
a(sbchlrr('d', 'e'));                                       // 01 // SBC HL,DE
a(ldpnnrr('d', 'e', 20));                                   // 01 // LD (NN,DE
a(neg());                                                   // 01 // NEG
a(ret(14));                                                 // 01 // RETN
a('st+=8;im=1');                                            // 01 // IM 1
a(ldair('i'));                                              // 01 // LD A,I
a(inr('e'));                                                // 01 // IN E,(C)
a(outr('e'));                                               // 01 // OUT (C,E
a(adchlrr('d', 'e'));                                       // 01 // ADC HL,DE
a(ldrrpnn('d', 'e', 20));                                   // 01 // LD DE,(NN)
a(neg());                                                   // 01 // NEG
a(ret(14));                                                 // 01 // RETI
a('st+=8;im=2');                                            // 01 // IM 2
a(ldair('r&127|r7&128'));                                   // 01 // LD A,R
a(inr('h'));                                                // 01 // IN H,(C)
a(outr('h'));                                               // 01 // OUT (C,H
a(sbchlrr('h', 'l'));                                       // 01 // SBC HL,HL
a(ldpnnrr('h', 'l', 20));                                   // 01 // LD (NN,HL
a(neg());                                                   // 01 // NEG
a(ret(14));                                                 // 01 // RETN
a('st+=8;im=0');                                            // 01 // IM 0
a('st+=18;t=m[u=l|h<<8];wb(u,a<<4&240|t>>4);a=a&240|t&15;f=f&1|szp[a]');// 01 // RRD
a(inr('l'));                                                // 01 // IN L,(C)
a(outr('l'));                                               // 01 // OUT (C,L
a(adchlrr('h', 'l'));                                       // 01 // ADC HL,HL
a(ldrrpnn('h', 'l', 20));                                   // 01 // LD HL,(NN)
a(neg());                                                   // 01 // NEG
a(ret(14));                                                 // 01 // RETI
a('st+=8;im=0');                                            // 01 // IM 0
a('st+=18;t=m[u=l|h<<8];wb(u,t<<4&240|a&15);a=a&240|t>>4;f=f&1|szp[a]');// 01 // RLD
a(inr('t'));                                                // 01 // IN X,(C)
a(outr('0'));                                               // 01 // OUT (C,X
a('st+=15;f=(l|h<<8)-sp-(f&1);l=f&255;f=f>>16&1|(f>>8^sp>>8^h)&16|((f>>8^h)&(h^sp>>8)&128)>>5|(h=f>>8&255)&168|(l|h?2:66)');// 01 // SBC HL,SP
a('st+=20;wb(t=m[pc++&65535]|m[pc++&65535]<<8,sp&255);wb(t+1&65535,sp>>8)');// 01 // LD (NN));SP
a(neg());                                                   // 01 // NEG
a(ret(14));                                                 // 01 // RETN
a('st+=8;im=1');                                            // 01 // IM 1
a(nop(8));                                                  // 01 // NOP
a(inr('a'));                                                // 01 // IN A,(C)
a(outr('a'));                                               // 01 // OUT (C,A
a('st+=15;f=(l|h<<8)+sp+(f&1);l=f&255;f=f>>16|(f>>8^sp>>8^h)&16|((f^h<<8)&(f^sp)&32768)>>13|(h=f>>8&255)&168|(l|h?0:64)');// 01 // ADC HL,SP
a('st+=20;sp=m[t=m[pc++&65535]|m[pc++&65535]<<8]|m[t+1&65535]<<8');// 01 // LD SP,(NN)
a(neg());                                                   // 01 // NEG
a(ret(14));                                                 // 01 // RETI
a('st+=8;im=2');                                            // 01 // IM 2
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(ldid(1, 0));                                              // 01 // LDI
a(cpid(1, 0));                                              // 01 // CPI
a(inid(1, 0));                                              // 01 // INI
a(otid(1, 0));                                              // 01 // OUTI
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(ldid(0, 0));                                              // 01 // LDD
a(cpid(0, 0));                                              // 01 // CPD
a(inid(0, 0));                                              // 01 // IND
a(otid(0, 0));                                              // 01 // OUTD
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(ldid(1, 1));                                              // 01 // LDIR
a(cpid(1, 1));                                              // 01 // CPIR
a(inid(1, 1));                                              // 01 // INIR
a(otid(1, 1));                                              // 01 // OTIR
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(ldid(0, 1));                                              // 01 // LDDR
a(cpid(0, 1));                                              // 01 // CPDR
a(inid(0, 1));                                              // 01 // INDR
a(otid(0, 1));                                              // 01 // OTDR
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a('loadblock()');                                           // 01 // tape loader trap
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 01 // NOP
?>
];