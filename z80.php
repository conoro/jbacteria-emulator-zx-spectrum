sz= [];                              // sign, zero, flag5, flag3 table
par= [];                             // parity table
szp= [];                             // sign, zero... parity table
szi= [];                             // sign, zero... increment table
szd= [];                             // sign, zero... decrement table

function z80init() {
  for(j= 0; j<256; j++)
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

function f() {
  return fa & 256
      ? ff & 168 | ff >> 8 & 1 | !fr << 6 | fb >> 8 & 2 | (fr ^ fa ^ fb ^ fb >> 8) & 16
        | 154020 >> ((fr ^ fr >> 4) & 15) & 4
      : ff & 168 | ff >> 8 & 1 | !fr << 6 | fb >> 8 & 2 | (fr ^ fa ^ fb ^ fb >> 8) & 16
        | ((fr ^ fa) & (fr ^ fb)) >> 5 & 4;
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
  'ff=ff&256|(fr='.$r.'=(fa='.$r.')+(fb=1)&255)';
}

function dec($r) {
  return 'st+=4;'.
  'ff=ff&256|(fr='.$r.'=(fa='.$r.')+(fb=-1)&255)';
}

function incdecphl($n) {
  return 'st+=11;'.
  'fa=m[t=l|h<<8];'.
  'ff=ff&256|(fr=fa+(fb='.($n=='+'?'':'-').'1)&255);'.
  'wb(t,fr)';
}

function incdecpi($a, $b) {
  return 'st+=19;'.
  'fa=m[t=((m[pc++&65535]^128)-128+('.$a.'l|'.$a.'h<<8))&65535];'.
  'ff=ff&256|(fr=fa+(fb='.($n=='+'?'':'-').'1)&255);'.
  'wb(t,fr)';
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
  'wb(((m[pc++&65535]^128)-128+('.$b.'l|'.$b.'h<<8))&65535,'.$a.')';
}

function ldrp($a, $b, $r, $t) {
  return 'st+=7;'.
          $r.'=m['.($t?'mp=':'').$b.'|'.$a.'<<8]'.
          ($t?';++mp':'');
}

function ldrpi($a, $b) {
  return 'st+=15;'.
  $a.'=m[((m[pc++&65535]^128)-128+('.$b.'l|'.$b.'h<<8))&65535]';
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
  'wb(((m[pc++&65535]^128)-128+('.$r.'l|'.$r.'h<<8))&65535, m[pc++&65535])';
}

function addrrrr($a, $b, $c, $d) {
  return 'st+=11;'.
  't='.$b.'+'.$d.'+('.$a.'+'.$c.'<<8);'.
  'ff=ff&128|t>>8&296;fb=fb&128|(t>>8^'.$a.'^'.$c.'^fr^fa)&16;'.
  ($mp?'mp='.$b.'+1+('.$a.'<<8);':'');
  $a.'=t>>8&255;'.
  $b.'=t&255';
}

function addisp($r) {
  return 'st+=11;'.
  't=sp+('.$r.'l|'.$r.'h<<8);'.
  'ff=ff&128|t>>8&296;'.
  'fb=fb&128|(t>>8^sp>>8^'.$r.'h^fr^fa)&16;'.
  ($mp?'mp='.$b.'+1+('.$a.'<<8);':'');
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
    'pc+=(m[pc&65535]^128)-127;'.
  'else '.
    'st+=7,'.
    'pc++';
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
    'pc=m[pc&65535]|m[pc+1&65535]<<8;'.
  'else '.
    'pc+=2';
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
    'wb(sp=sp-1&65535,t&255);'.
  'else '.
    'st+=10,'.
    'pc+=2';
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
    'sp=sp+2&65535;'.
  'else '.
    'st+=5';
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
  $a.'=m['.($mp?'mp=':'').'t+1&65535]';
}

function ldrr($a, $b, $n){
  return 'st+='.$n.';'.
  $a.'='.$b;
}

function add($a, $n){
  return 'st+='.$n.
  ';a=fr=(ff=(fa=a)+(fb='.$a.'))&255';
}

function adc($a, $n){
  return 'st+='.$n.
  ';a=fr=(ff=(fa=a)+(fb='.$a.')+(ff>>8&1))&255';
}

function sub($a, $n){
  return 'st+='.$n.
  ';a=fr=(ff=(fa=a)+(fb=~'.$a.')+1)&255';
}

function sbc($a, $n){
  return 'st+='.$n.
  ';a=fr=(ff=(fa=a)+(fb=~'.$a.')+(ff>>8&1^1))&255';
}

function anda($r, $n){
  return 'st+='.$n.
  ';fa=~(a=ff=fr=a&'.$r.');fb=0';
}

function xoror($r, $n){
  return 'st+='.$n.
  ';fa=(ff=fr=a'.$r.')|256;fb=0';
}

function cp($a, $n){
  return 'st+='.$n.
  ';fr=(fa=a)-'.$a.';fb=~'.$a.';ff=fr&-41|'.$a.'&40;fr&=255';
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

function popaf(){
  return 'st+=10;'.
  't=m[sp];'.
  'fr=~t&64;'.
  'ff=t|=t<<8;'.
  'fa=255&(fb=t&-129|(t&4)<<5);'.
  'a=m[sp+1&65535];'.
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
  $r.'='.$r.'*257>>7;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function rrc($r){
  return 'st+=8;'.
  $r.'='.$r.'>>1|(('.$r.'&1)+1^1)<<7;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function rl($r){
  return 'st+=8;'.
  $r.'='.$r.'<<1|ff>>8&1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function rr($r){
  return 'st+=8;'.
  $r.'=('.$r.'*513|ff&256)>>1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function sla($r){
  return 'st+=8;'.
  $r.'<<=1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function sra($r){
  return 'st+=8;'.
  $r.'=('.$r.'*513+128^128)>>1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function sll($r){
  return 'st+=8;'.
  $r.'='.$r.'<<1|1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function srl($r){
  return 'st+=8;'.
  $r.'='.$r.'*513>>1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function bit($n, $r){
  return 'st+=8;'.
  'ff=ff&-256|'.$r.'&40|('.$r.'&='.$n.');'.
  'fa=~(fr=b);'.
  'fb=0';
}

function biti($n){
  return 'st+=5;'.
  'ff=ff&-256|t&40|(t&='.$n.');'.
  'fa=~(fr=b);'.
  'fb=0';
}

function bithl($n){
  return 'st+=12;'.
  'ff=ff&-256|(t=m[l|h<<8])&40|(t&='.$n.');'.
  'fa=~(fr=b);'.
  'fb=0';
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
  global $mp;
  return 'st+=12;'.
  $r.'=rp('.($mp?'mp=':'').'b<<8|c);'.
  ($mp?'++mp;':'').
  'ff=ff&-256|(fr='.$r.');'.
  'fa='.$r.'|256;'.
  'fb=0';
}

function outr($r){
  return 'st+=12;'.
  'wp('.($mp?'mp=':'').'c|b<<8,'.$r.')'.
  ($mp?';++mp':'');
}

function sbchlrr($a, $b) {
  return 'st+=15;'.
  't='.($a=='h'?'':'l-'.$b.'+(h-'.$a.'<<8)').'-(ff>>8&1);'.
  ($mp?'mp=l+1+(h<<8);':'').
  'ff=t>>8;'.
  'fa=h;'.
  'fb=~'.$a.';'.
  'h=t>>8&255;'.
  'fr='.$a.'|t<<8;'.
  'l=t&255';
}

function adchlrr($a, $b) {
  return 'st+=15;'.
  't=l+'.$b.'+(h+'.$a.'<<8)+(ff>>8&1);'.
  ($mp?'mp=l+1+(h<<8);':'').
  'ff=t>>8;'.
  'fa=h;'.
  'fb='.$a.';'.
  'h=t>>8&255;'.
  'fr='.$a.'|t<<8;'.
  'l=t&255';
}

function neg(){
  return 'st+=8;'.
  'a=fr=(ff=(fb=~a)+1)&255;fa=0';
}

function ldair($r){
  return 'st+=9;'.
  'ff=ff&-256|(a='.$r.');'.
  'fr=+!!'.$r.';'.
  'fa=fb=iff<<7&128';
}

function ldid($i, $r){
  global $mp;
  return 'st+=16;'.
  'wb(e|d<<8,t=m[l|h<<8]);'.
  ($i ? '++l==256&&(l=0,h=h+1&255);++e==256&&(e=0,d=d+1&255);'
      : '--l<0&&(h=h-1&(l=255));--e<0&&(d=d-1&(e=255));').
  '--c<0&&(b=b-1&(c=255));'.
  'fr&&(fr=1);'.
  't+=a;'.
  'ff=ff&-41|t&8|t<<4&32;'.
  'fa=0;'.
  'b|c&&(fa=128'.
  ($r ? ',st+=5,'.($mp?'mp=--pc,--pc':'pc-=2') : '').
  ');fb=fa';
}

function cpid($i, $r){
  global $mp;
  return 'st+=16;'.
  'u=a-(t=m[l|h<<8])&255;'.
  ($i ? '++l==256&&(l=0,h=h+1&255);'
      : '--l<0&&(h=h-1&(l=255));').
  '--c<0&&(b=b-1&(c=255));'.
  ($mp?($i ? '++mp;':'--mp;'):'').
  'fr=u&127|u>>7;'.
  'fb=~(t|128);'.
  'fa=a&127;'.
  'b|c&&(fa|=fb&128'.
  ($r ? ',u&&(st+=5,'.($mp?'mp=--pc,--pc)':'pc-=2)') : '').
  ');ff=ff&-256|u&-41;'.
  '(u^t^a)&16&&u--;'.
  'ff|=u<<4&32|u&8';
}

function inid($i, $r){
  global $mp;
  return 'st+=16;'.
  'wb(l|h<<8,t=rp('.($mp?'mp=':'').'c|b<<8));'.
  '++l==256&&(l=0,h=h+1&255);'.
  'b=b-1&255;'.
  ($mp?($i?'++mp;':'--mp;'):'').
  'u=t+(c'.($i?'+':'-').'1&255);'.
  ($r?'b&&(st+=5,'.($mp?'mp=--pc,--pc);':'pc-=2);'):'').
  'fb=u&7^b;'.
  'ff=b|(u&=256);'.
  'fa=(fr=b)^128;'.
  'fb=4928640>>((fb^fb>>4)&15);'.
  'fb=(fb^b)&128|u>>4|(t&128)<<2';
}

function otid($i, $r){
  global $mp;
  return 'st+=16;'.
  'b=b-1&255;'.
  'wp('.($mp?'mp=':'').'c|b<<8,t=m[l|h<<8]);'.
  ($mp?($i?'++mp;':'--mp;'):'').
  '++l==256&&(l=0,h=h+1&255);'.
  'u=t+l;'.
  ($r?'b&&(st+=5,'.($mp?'mp=--pc,--pc);':'pc-=2);'):'').
  'fb=u&7^b;'.
  'ff=b|(u&=256);'.
  'fa=(fr=b)^128;'.
  'fb=4928640>>((fb^fb>>4)&15);'.
  'fb=(fb^b)&128|u>>4|(t&128)<<2';
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
                                                            // 07 // RLCA
a('st+=4;a=a*257>>7;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
                                                            // 08 // EX AF,AF'
a('st+=4;t=a_;a_=a;a=t;t=ff_;ff_=ff;ff=t;t=fr_;fr_=fr;fr=t;t=fa_;fa_=fa;fa=t;t=fb_;fb_=fb;fb=t');
a(addrrrr('h', 'l', 'b', 'c'));                             // 09 // ADD HL,BC
a(ldrp('b', 'c', 'a', $mp));                                // 0A // LD A,(BC)
a(decw('b', 'c'));                                          // 0B // DEC BC
a(inc('c'));                                                // 0C // INC C
a(dec('c'));                                                // 0D // DEC C
a(ldrim('c'));                                              // 0E // LD C,n
                                                            // 0F // RRCA
a('st+=4;a=a>>1|((a&1)+1^1)<<7;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
                                                            //10  // DJNZ
a('st+=8;if(b=b-1&255)st+=5,'.($mp?'mp=':'').'pc+=(m[pc&65535]^128)-127;else pc++');
a(ldrrim('d', 'e'));                                        // 11 // LD DE,nn
a(ldpr('d', 'e', 'a'));                                     // 12 // LD (DE),A
a(incw('d', 'e'));                                          // 13 // INC DE
a(inc('d'));                                                // 14 // INC D
a(dec('d'));                                                // 15 // DEC D
a(ldrim('d'));                                              // 16 // LD D,n
                                                            // 17 // RLA
a('st+=4;a=a<<1|ff>>8&1;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
a('st+=12;'.($mp?'mp=':'').'pc+=(m[pc&65535]^128)-127');    // 18 // JR
a(addrrrr('h', 'l', 'd', 'e'));                             // 19 // ADD HL,DE
a(ldrp('d', 'e', 'a', $mp));                                // 1A // LD A,(DE)
a(decw('d', 'e'));                                          // 1B // DEC DE
a(inc('e'));                                                // 1C // INC E
a(dec('e'));                                                // 1D // DEC E
a(ldrim('e'));                                              // 1E // LD E,n
                                                            // 1F // RRA
a('st+=4;a=(a*513|ff&256)>>1;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
a(jrc('fr'));                                               // 20 // JR NZ,s8
a(ldrrim('h', 'l'));                                        // 21 // LD HL,nn
a(ldpnnrr('h', 'l', 16));                                   // 22 // LD (nn),HL
a(incw('h', 'l'));                                          // 23 // INC HL
a(inc('h'));                                                // 24 // INC H
a(dec('h'));                                                // 25 // DEC H
a(ldrim('h'));                                              // 26 // LD H,n
                                                            // 27 // DAA
a('st+=4;t=(fr^fa^fb^fb>>8)&16;u=0;(a|ff&256)>153&&(u=352);(a&15|t)>9&&(u+=6);fa=a|256;fb&512?(a-=u,fb=~u):a+=fb=u,ff=(fr=a&=255)|u&256');
a(jrci('fr'));                                              // 28 // JR Z,s8
a(addrrrr('h', 'l', 'h', 'l'));                             // 29 // ADD HL,HL
a(ldrrpnn('h', 'l', 16));                                   // 2a // LD HL,(nn)
a(decw('h', 'l'));                                          // 2b // DEC HL
a(inc('l'));                                                // 2c // INC L
a(dec('l'));                                                // 2d // DEC L
a(ldrim('l'));                                              // 2e // LD L,n
a('st+=4;ff=ff&-41|(a^=255)&40;fb|=-129;fa=fa&-17|~fr&16'); // 2f // CPL
a(jrc('ff&256'));                                           // 30 // JR NC,s8
a('st+=10;sp=m[pc++&65535]|m[pc++&65535]<<8');              // 31 // LD SP,nn
                                                            // 32 // LD (nn),A
a('st+=13;wb('.($mp?'t=':'').'m[pc++&65535]|m[pc++&65535]<<8,a)'.($mp?';mp='.$b.'+1&255|a<<8':''));
a('st+=6;sp=sp+1&65535');                                   // 33 // INC SP
a(incdecphl('+'));                                          // 34 // INC (HL)
a(incdecphl('-'));                                          // 35 // DEC (HL)
a('st+=10;wb(l|h<<8,m[pc++&65535])');                       // 36 // LD (HL),n
a('st+=4;fb=fb&128|(fr^fa)&16;ff=256|ff&128|a&40');         // 37 // SCF
a(jrci('ff&256'));                                          // 38 // JR C,s8
a(addisp(''));                                              // 39 // ADD HL,SP
                                                            // 3a // LD A,(nn)
a('st+=13;a=m['.($mp?'mp=':'').'m[pc++&65535]|m[pc++&65535]<<8]'.($mp?';++mp':''));
a('st+=6;sp=sp-1&65535');                                   // 3b // DEC SP
a(inc('a'));                                                // 3c // INC A
a(dec('a'));                                                // 3d // DEC A
a(ldrim('a'));                                              // 3e // LD A,n
a('st+=4;fb=fb&128|(ff>>4^fr^fa)&16;ff=~ff&256|ff&128|a&40');//3f // CCF
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
a(add('b', 4));                                             // 80 // ADD A,B
a(add('c', 4));                                             // 81 // ADD A,C
a(add('d', 4));                                             // 82 // ADD A,D
a(add('e', 4));                                             // 83 // ADD A,E
a(add('h', 4));                                             // 84 // ADD A,H
a(add('l', 4));                                             // 85 // ADD A,L
a(add('m[l|h<<8]', 7));                                     // 86 // ADD A,(HL)
a('a=fr=(ff=2*(fa=fb=a))&255');                             // 87 // ADD A,A
a(adc('b', 4));                                             // 88 // ADC A,B
a(adc('c', 4));                                             // 89 // ADC A,C
a(adc('d', 4));                                             // 8a // ADC A,D
a(adc('e', 4));                                             // 8b // ADC A,E
a(adc('h', 4));                                             // 8c // ADC A,H
a(adc('l', 4));                                             // 8d // ADC A,L
a(adc('m[l|h<<8]', 7));                                     // 8e // ADC A,(HL)
a('a=fr=(ff=2*(fa=fb=a)+(ff>>8&1))&255');                   // 8f // ADC A,A
a(sub('b', 4));                                             // 90 // SUB A,B
a(sub('c', 4));                                             // 91 // SUB A,C
a(sub('d', 4));                                             // 92 // SUB A,D
a(sub('e', 4));                                             // 93 // SUB A,E
a(sub('h', 4));                                             // 94 // SUB A,H
a(sub('l', 4));                                             // 95 // SUB A,L
a(sub('m[l|h<<8]', 7));                                     // 96 // SUB A,(HL)
a('fb=~(fa=a);a=fr=ff=0');                                  // 97 // SUB A,A
a(sbc('b', 4));                                             // 98 // SBC A,B
a(sbc('c', 4));                                             // 99 // SBC A,C
a(sbc('d', 4));                                             // 9a // SBC A,D
a(sbc('e', 4));                                             // 9b // SBC A,E
a(sbc('h', 4));                                             // 9c // SBC A,H
a(sbc('l', 4));                                             // 9d // SBC A,L
a(sbc('m[l|h<<8]', 7));                                     // 9e // SBC A,(HL)
a('fb=~(fa=a);a=fr=(ff=ff&256/-256)&255');                  // 9f // SBC A,A
a(anda('b', 4));                                            // a0 // AND B
a(anda('c', 4));                                            // a1 // AND C
a(anda('d', 4));                                            // a2 // AND D
a(anda('e', 4));                                            // a3 // AND E
a(anda('h', 4));                                            // a4 // AND H
a(anda('l', 4));                                            // a5 // AND L
a(anda('m[l|h<<8]', 7));                                    // a6 // AND (HL)
a('fa=~(ff=fr=a);fb=0');                                    // a7 // AND A
a(xoror('^=b', 4));                                         // a8 // XOR B
a(xoror('^=c', 4));                                         // a9 // XOR C
a(xoror('^=d', 4));                                         // aa // XOR D
a(xoror('^=e', 4));                                         // ab // XOR E
a(xoror('^=h', 4));                                         // ac // XOR H
a(xoror('^=l', 4));                                         // ad // XOR L
a(xoror('^=m[l|h<<8]', 7));                                 // ae // XOR (HL)
a('a=ff=fr=fb=0;fa=256');                                   // af // XOR A
a(xoror('|=b', 4));                                         // b0 // OR B
a(xoror('|=c', 4));                                         // b1 // OR C
a(xoror('|=d', 4));                                         // b2 // OR D
a(xoror('|=e', 4));                                         // b3 // OR E
a(xoror('|=h', 4));                                         // b4 // OR H
a(xoror('|=l', 4));                                         // b5 // OR L
a(xoror('|=m[l|h<<8]', 7));                                 // b6 // OR (HL)
a('fa=(ff=fr=a)|256;fb=0');                                 // b7 // OR A
a(cp('b', 4));                                              // b8 // CP B
a(cp('c', 4));                                              // b9 // CP C
a(cp('d', 4));                                              // ba // CP D
a(cp('e', 4));                                              // bb // CP E
a(cp('h', 4));                                              // bc // CP H
a(cp('l', 4));                                              // bd // CP L
a('t=m[l|h<<8];'.cp('t', 7));                               // be // CP (HL)
a('fr=0;fb=~(fa=a);ff=a&40');                               // bf // CP A
a(retc('fr'));                                              // c0 // RET NZ
a(pop('b', 'c'));                                           // c1 // POP BC
a(jpc('fr'));                                               // c2 // JP NZ
a('st+=10;'.($mp?'mp=':'').'pc=m[pc&65535]|m[pc+1&65535]<<8');//c3// JP nn
a(callc('fr'));                                             // c4 // CALL NZ
a(push('b', 'c'));                                          // c5 // PUSH BC
a(add('m[pc++&65535]', 7));                                 // c6 // ADD A,n
a(rst(0));                                                  // c7 // RST 0x00
a(retci('fr'));                                             // c8 // RET Z
a(ret(10));                                                 // c9 // RET
a(jpci('fr'));                                              // ca // JP Z
a('r++;g[768+m[pc++&65535]]()');                            // cb // op cb
a(callci('fr'));                                            // cc // CALL Z
                                                            // cd // CALL NN
a('st+=17;t=pc+2;'.($mp?'mp=':'').'pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8&255);wb(sp=sp-1&65535,t&255)');
a(adc('m[pc++&65535]', 7));                                 // ce // ADC A,n
a(rst(8));                                                  // cf // RST 0x08
a(retc('ff&256'));                                           // d0 // RET NC
a(pop('d', 'e'));                                           // d1 // POP DE
a(jpc('ff&256'));                                           // d2 // JP NC
                                                            // d3 // OUT (n),A
a('st+=11;wp('.($mp?'mp=':'').'m[pc++&65535]|a<<8,a)'.($mp?';mp=mp+1&255|mp&65280':''));
a(callc('ff&256'));                                         // d4 // CALL NC
a(push('d', 'e'));                                          // d5 // PUSH DE
a(sub('m[pc++&65535]', 7));                                 // d6 // SUB A,n
a(rst(16));                                                 // d7 // RST 0x10
a(retci('ff&256'));                                         // d8 // RET C
                                                            // d9 // EXX
a('st+=4;t=b;b=b_;b_=t;t=c;c=c_;c_=t;t=d;d=d_;d_=t;t=e;e=e_;e_=t;t=h;h=h_;h_=t;t=l;l=l_;l_=t');
a(jpci('ff&256'));                                          // da // JP C
                                                            // db // IN A,(n)
a('st+=11;a=rp('.($mp?'mp=':'').'m[pc++&65535]|a<<8)'.($mp?';++mp':''));
a(callci('ff&256'));                                        // dc // CALL C
a('st+=4;r++;g[256+m[pc++&65535]]()');                      // dd // OP dd
a(sbc('m[pc++&65535]', 7));                                 // de // SBC A,n
a(rst(24));                                                 // df // RST 0x18
a(retc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e0//RET PO
a(pop('h', 'l'));                                           // e1 // POP HL
a(jpc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e2// JP PO
a(exspi(''));                                               // e3 // EX (SP));HL
a(callc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e4//CALL PO
a(push('h', 'l'));                                          // e5 // PUSH HL
a(anda('m[pc++&65535]', 7));                                // e6 // AND A,n
a(rst(32));                                                 // e7 // RST 0x20
a(retci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e8//RET PE
a(ldsppci('pc', ''));                                       // e9 // JP (HL)
a(jpci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//ea//JP PE
a('st+=4;t=d;d=h;h=t;t=e;e=l;l=t');                         // eb // EX DE,HL
a(callci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//ec//CALL PE
a('r++;g[1280+m[pc++&65535]]()');                           // ed // op ed
a(xoror('^=m[pc++&65535]', 7));                             // ee // XOR A,n
a(rst(40));                                                 // ef // RST 0x28
a(retci('ff&128'));                                         // f0 // RET P
a(popaf());                                                 // f1 // POP AF
a(jpci('ff&128'));                                          // f2 // JP P
a('st+=4;iff=0');                                           // f3 // DI
a(callci('ff&128'));                                        // f4 // CALL P
a(push('a', 'f()'));                                        // f5 // PUSH AF
a(xoror('|=m[pc++&65535]', 7));                             // f6 // OR A,n
a(rst(48));                                                 // f7 // RST 0x30
a(retc('ff&128'));                                          // f8 // RET M
a(ldsppci('sp', ''));                                       // f9 // LD SP,HL
a(jpc('ff&128'));                                           // fa // JP M
a('st+=4;iff=1');                                           // fb // EI
a(callc('ff&128'));                                         // fc // CALL M
a('st+=4;r++;g[512+m[pc++&65535]]()');                      // fd // op fd
a('t=m[pc++&65535];'.cp('t', 7));                           // fe // CP A,n
a(rst(56));                                                 // ff // RST 0x38

a(nop(4));                                                  // 00 // NOP
a(ldrrim('b', 'c'));                                        // 01 // LD BC,nn
a(ldpr('b', 'c', 'a'));                                     // 02 // LD (BC),A
a(incw('b', 'c'));                                          // 03 // INC BC
a(inc('b'));                                                // 04 // INC B
a(dec('b'));                                                // 05 // DEC B
a(ldrim('b'));                                              // 06 // LD B,n
a('st+=4;a=a*257>>7;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');// RLCA
                                                            // 08 // EX AF,AF'
a('st+=4;t=a_;a_=a;a=t;t=ff_;ff_=ff;ff=t;t=fr_;fr_=fr;fr=t;t=fa_;fa_=fa;fa=t;t=fb_;fb_=fb;fb=t');
a(addrrrr('xh', 'xl', 'b', 'c'));                           // 09 // ADD IX,BC
a(ldrp('b', 'c', 'a', $mp));                                // 0A // LD A,(BC)
a(decw('b', 'c'));                                          // 0B // DEC BC
a(inc('c'));                                                // 0C // INC C
a(dec('c'));                                                // 0D // DEC C
a(ldrim('c'));                                              // 0E // LD C,n
                                                            // 0F // RRCA
a('st+=4;a=a>>1|((a&1)+1^1)<<7;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
                                                            //10  // DJNZ
a('st+=8;if(b=b-1&255)st+=5,'.($mp?'mp=':'').'pc+=(m[pc&65535]^128)-127;else pc++');
a(ldrrim('d', 'e'));                                        // 11 // LD DE,nn
a(ldpr('d', 'e', 'a'));                                     // 12 // LD (DE),A
a(incw('d', 'e'));                                          // 13 // INC DE
a(inc('d'));                                                // 14 // INC D
a(dec('d'));                                                // 15 // DEC D
a(ldrim('d'));                                              // 16 // LD D,n
                                                            // 17 // RLA
a('st+=4;a=a<<1|ff>>8&1;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
a('st+=12;'.($mp?'mp=':'').'pc+=(m[pc&65535]^128)-127');    // 18 // JR
a(addrrrr('xh', 'xl', 'd', 'e'));                           // 19 // ADD IX,DE
a(ldrp('d', 'e', 'a', $mp));                                // 1A // LD A,(DE)
a(decw('d', 'e'));                                          // 1B // DEC DE
a(inc('e'));                                                // 1C // INC E
a(dec('e'));                                                // 1D // DEC E
a(ldrim('e'));                                              // 1E // LD E,n
                                                            // 1F // RRA
a('st+=4;a=(a*513|ff&256)>>1;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
a(jrc('fr'));                                               // 20 // JR NZ,s8
a(ldrrim('xh', 'xl'));                                      // 21 // LD IX,nn
a(ldpnnrr('xh', 'xl', 16));                                 // 22 // LD (nn),IX
a(incw('xh', 'xl'));                                        // 23 // INC IX
a(inc('xh'));                                               // 24 // INC IXH
a(dec('xh'));                                               // 25 // DEC IXH
a(ldrim('xh'));                                             // 26 // LD IXH,n
                                                            // 27 // DAA
a('st+=4;t=(fr^fa^fb^fb>>8)&16;u=0;(a|ff&256)>153&&(u=352);(a&15|t)>9&&(u+=6);fa=a|256;fb&512?(a-=u,fb=~u):a+=fb=u,ff=(fr=a&=255)|u&256');
a(jrci('fr'));                                              // 28 // JR Z,s8
a(addrrrr('xh', 'xl', 'xh', 'xl'));                         // 29 // ADD IX,IX
a(ldrrpnn('xh', 'xl', 16));                                 // 2a // LD IX,(nn)
a(decw('xh', 'xl'));                                        // 2b // DEC IX
a(inc('xl'));                                               // 2c // INC IXL
a(dec('xl'));                                               // 2d // DEC IXL
a(ldrim('xl'));                                             // 2e // LD IXL,n
a('st+=4;ff=ff&-41|(a^=255)&40;fb|=-129;fa=fa&-17|~fr&16'); // 2f // CPL
a(jrc('ff&256'));                                           // 30 // JR NC,s8
a('st+=10;sp=m[pc++&65535]|m[pc++&65535]<<8');              // 31 // LD SP,nn
                                                            // 32 // LD (nn),A
a('st+=13;wb('.($mp?'t=':'').'m[pc++&65535]|m[pc++&65535]<<8,a)'.($mp?';mp='.$b.'+1&255|a<<8':''));
a('st+=6;sp=sp+1&65535');                                   // 33 // INC SP
a(incdecpi('x', '+'));                                      // 34 // INC (IX+d)
a(incdecpi('x', '-'));                                      // 35 // DEC (IX+d)
a(ldpin('x'));                                              // 36 // LD (IX+d),n
a('st+=4;fb=fb&128|(fr^fa)&16;ff=256|ff&128|a&40');         // 37 // SCF
a(jrci('ff&256'));                                          // 38 // JR C,s8
a(addisp('x'));                                             // 39 // ADD IX,SP
                                                            // 3a // LD A,(nn)
a('st+=13;a=m['.($mp?'mp=':'').'m[pc++&65535]|m[pc++&65535]<<8]'.($mp?';++mp':''));
a('st+=6;sp=sp-1&65535');                                   // 3b // DEC SP
a(inc('a'));                                                // 3c // INC A
a(dec('a'));                                                // 3d // DEC A
a(ldrim('a'));                                              // 3e // LD A,n
a('st+=4;fb=fb&128|(ff>>4^fr^fa)&16;ff=~ff&256|ff&128|a&40');//3f // CCF
a(nop(4));                                                  // 40 // LD B,B
a(ldrr('b', 'c', 4));                                       // 41 // LD B,C
a(ldrr('b', 'd', 4));                                       // 42 // LD B,D
a(ldrr('b', 'e', 4));                                       // 43 // LD B,E
a(ldrr('b', 'xh', 4));                                      // 44 // LD B,IXH
a(ldrr('b', 'xl', 4));                                      // 45 // LD B,IXL
a(ldrpi('b', 'x'));                                         // 46 // LD B,(IX+d)
a(ldrr('b', 'a', 4));                                       // 47 // LD B,A
a(ldrr('c', 'b', 4));                                       // 48 // LD C,B
a(nop(4));                                                  // 49 // LD C,C
a(ldrr('c', 'd', 4));                                       // 4a // LD C,D
a(ldrr('c', 'e', 4));                                       // 4b // LD C,E
a(ldrr('c', 'xh', 4));                                      // 4c // LD C,IXH
a(ldrr('c', 'xl', 4));                                      // 4d // LD C,IXL
a(ldrpi('c', 'x'));                                         // 4e // LD C,(IX+d)
a(ldrr('c', 'a', 4));                                       // 4f // LD C,A
a(ldrr('d', 'b', 4));                                       // 50 // LD D,B
a(ldrr('d', 'c', 4));                                       // 51 // LD D,C
a(nop(4));                                                  // 52 // LD D,D
a(ldrr('d', 'e', 4));                                       // 53 // LD D,E
a(ldrr('d', 'xh', 4));                                      // 54 // LD D,IXH
a(ldrr('d', 'xl', 4));                                      // 55 // LD D,IXL
a(ldrpi('d', 'x'));                                         // 56 // LD D,(IX+d)
a(ldrr('d', 'a', 4));                                       // 57 // LD D,A
a(ldrr('e', 'b', 4));                                       // 58 // LD E,B
a(ldrr('e', 'c', 4));                                       // 59 // LD E,C
a(ldrr('e', 'd', 4));                                       // 5a // LD E,D
a(nop(4));                                                  // 5b // LD E,E
a(ldrr('e', 'xh', 4));                                      // 5c // LD E,IXH
a(ldrr('e', 'xl', 4));                                      // 5d // LD E,IXL
a(ldrpi('e', 'x'));                                         // 5e // LD E,(IX+d)
a(ldrr('e', 'a', 4));                                       // 5f // LD E,A
a(ldrr('xh', 'b', 4));                                      // 60 // LD IXH,B
a(ldrr('xh', 'c', 4));                                      // 61 // LD IXH,C
a(ldrr('xh', 'd', 4));                                      // 62 // LD IXH,D
a(ldrr('xh', 'e', 4));                                      // 63 // LD IXH,E
a(nop(4));                                                  // 64 // LD IXH,IXH
a(ldrr('xh', 'xl', 4));                                     // 65 // LD IXH,IXL
a(ldrpi('h', 'x'));                                         // 66 // LD H,(IX+d)
a(ldrr('xh', 'a', 4));                                      // 67 // LD IXH,A
a(ldrr('xl', 'b', 4));                                      // 68 // LD IXL,B
a(ldrr('xl', 'c', 4));                                      // 69 // LD IXL,C
a(ldrr('xl', 'd', 4));                                      // 6a // LD IXL,D
a(ldrr('xl', 'e', 4));                                      // 6b // LD IXL,E
a(ldrr('xl', 'xh', 4));                                     // 6c // LD IXL,IXH
a(nop(4));                                                  // 6d // LD IXL,IXL
a(ldrpi('l', 'x'));                                         // 6e // LD L,(IX+d)
a(ldrr('xl', 'a', 4));                                      // 6f // LD IXL,A
a(ldpri('b', 'x'));                                         // 70 // LD (IX+d),B
a(ldpri('c', 'x'));                                         // 71 // LD (IX+d),C
a(ldpri('d', 'x'));                                         // 72 // LD (IX+d),D
a(ldpri('e', 'x'));                                         // 73 // LD (IX+d),E
a(ldpri('h', 'x'));                                         // 74 // LD (IX+d),H
a(ldpri('l', 'x'));                                         // 75 // LD (IX+d),L
a('st+=4;halted=1;pc--');                                   // 76 // HALT
a(ldpri('a', 'x'));                                         // 77 // LD (IX+d),A
a(ldrr('a', 'b', 4));                                       // 78 // LD A,B
a(ldrr('a', 'c', 4));                                       // 79 // LD A,C
a(ldrr('a', 'd', 4));                                       // 7a // LD A,D
a(ldrr('a', 'e', 4));                                       // 7b // LD A,E
a(ldrr('a', 'xh', 4));                                      // 7c // LD A,IXH
a(ldrr('a', 'xl', 4));                                      // 7d // LD A,IXL
a(ldrpi('a', 'x'));                                         // 7e // LD A,(IX+d)
a(nop(4));                                                  // 7f // LD A,A
a(add('b', 4));                                             // 80 // ADD A,B
a(add('c', 4));                                             // 81 // ADD A,C
a(add('d', 4));                                             // 82 // ADD A,D
a(add('e', 4));                                             // 83 // ADD A,E
a(add('xh', 4));                                            // 84 // ADD A,IXH
a(add('xl', 4));                                            // 85 // ADD A,IXL
a(add('m[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', 15));// 86 //ADD A,(IX+d)
a('a=fr=(ff=2*(fa=fb=a))&255');                             // 87 // ADD A,A
a(adc('b', 4));                                             // 88 // ADC A,B
a(adc('c', 4));                                             // 89 // ADC A,C
a(adc('d', 4));                                             // 8a // ADC A,D
a(adc('e', 4));                                             // 8b // ADC A,E
a(adc('xh', 4));                                            // 8c // ADC A,IXH
a(adc('xl', 4));                                            // 8d // ADC A,IXL
a(adc('m[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', 15));// 8e // ADC A,(IX+d)
a('a=fr=(ff=2*(fa=fb=a)+(ff>>8&1))&255');                   // 8f // ADC A,A
a(sub('b', 4));                                             // 90 // SUB A,B
a(sub('c', 4));                                             // 91 // SUB A,C
a(sub('d', 4));                                             // 92 // SUB A,D
a(sub('e', 4));                                             // 93 // SUB A,E
a(sub('xh', 4));                                            // 94 // SUB A,IXH
a(sub('xl', 4));                                            // 95 // SUB A,IXL
a(sub('m[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', 15));// 96 // SUB A,(IX+d)
a('fb=~(fa=a);a=fr=ff=0');                                  // 97 // SUB A,A
a(sbc('b', 4));                                             // 98 // SBC A,B
a(sbc('c', 4));                                             // 99 // SBC A,C
a(sbc('d', 4));                                             // 9a // SBC A,D
a(sbc('e', 4));                                             // 9b // SBC A,E
a(sbc('xh', 4));                                            // 9c // SBC A,IXH
a(sbc('xl', 4));                                            // 9d // SBC A,IXL
a(sbc('m[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', 15));// 9e // SBC A,(IX+d)
a('fb=~(fa=a);a=fr=(ff=ff&256/-256)&255');                  // 9f // SBC A,A
a(anda('b', 4));                                            // a0 // AND B
a(anda('c', 4));                                            // a1 // AND C
a(anda('d', 4));                                            // a2 // AND D
a(anda('e', 4));                                            // a3 // AND E
a(anda('xh', 4));                                           // a4 // AND IXH
a(anda('xl', 4));                                           // a5 // AND IXL
a(anda('m[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', 15));// a6 // AND (IX+d)
a('fa=~(ff=fr=a);fb=0');                                    // a7 // AND A
a(xoror('^=b', 4));                                         // a8 // XOR B
a(xoror('^=c', 4));                                         // a9 // XOR C
a(xoror('^=d', 4));                                         // aa // XOR D
a(xoror('^=e', 4));                                         // ab // XOR E
a(xoror('^=xh', 4));                                        // ac // XOR IXH
a(xoror('^=xl', 4));                                        // ad // XOR IXL
a(xoror('^=m[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', 15));// ae // XOR (IX+d)
a('a=ff=fr=fb=0;fa=256');                                   // af // XOR A
a(xoror('|=b', 4));                                         // b0 // OR B
a(xoror('|=c', 4));                                         // b1 // OR C
a(xoror('|=d', 4));                                         // b2 // OR D
a(xoror('|=e', 4));                                         // b3 // OR E
a(xoror('|=xh', 4));                                        // b4 // OR IXH
a(xoror('|=xl', 4));                                        // b5 // OR IXL
a(xoror('|=m[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', 15));// b6 // OR (IX+d)
a('fa=(ff=fr=a)|256;fb=0');                                 // b7 // OR A
a(cp('b', 4));                                              // b8 // CP B
a(cp('c', 4));                                              // b9 // CP C
a(cp('d', 4));                                              // ba // CP D
a(cp('e', 4));                                              // bb // CP E
a(cp('xh', 4));                                             // bc // CP IXH
a(cp('xl', 4));                                             // bd // CP IXL
a('t=m[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535];'.cp('t', 15));//be//CP (IX+d)
a('fr=0;fb=~(fa=a);ff=a&40');                               // bf // CP A
a(retc('fr'));                                              // c0 // RET NZ
a(pop('b', 'c'));                                           // c1 // POP BC
a(jpc('fr'));                                               // c2 // JP NZ
a('st+=10;'.($mp?'mp=':'').'pc=m[pc&65535]|m[pc+1&65535]<<8');//c3// JP nn
a(callc('fr'));                                             // c4 // CALL NZ
a(push('b', 'c'));                                          // c5 // PUSH BC
a(add('m[pc++&65535]', 7));                                 // c6 // ADD A,n
a(rst(0));                                                  // c7 // RST 0x00
a(retci('fr'));                                             // c8 // RET Z
a(ret(10));                                                 // c9 // RET
a(jpci('fr'));                                              // ca // JP Z
a('st+=11;t=m[u=((m[pc++&65535]^128)-128+(xl|xh<<8))&65535];g[1024+m[pc++&65535]]()');// cb // op ddcb
a(callci('fr'));                                            // cc // CALL Z
                                                            // cd // CALL NN
a('st+=17;t=pc+2;'.($mp?'mp=':'').'pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8&255);wb(sp=sp-1&65535,t&255)');
a(adc('m[pc++&65535]', 7));                                 // ce // ADC A,n
a(rst(8));                                                  // cf // RST 0x08
a(retc('ff&256'));                                          // d0 // RET NC
a(pop('d', 'e'));                                           // d1 // POP DE
a(jpc('ff&256'));                                           // d2 // JP NC
                                                            // d3 // OUT (n),A
a('st+=11;wp('.($mp?'mp=':'').'m[pc++&65535]|a<<8,a)'.($mp?';mp=mp+1&255|mp&65280':''));
a(callc('ff&256'));                                         // d4 // CALL NC
a(push('d', 'e'));                                          // d5 // PUSH DE
a(sub('m[pc++&65535]', 7));                                 // d6 // SUB A,n
a(rst(16));                                                 // d7 // RST 0x10
a(retci('ff&256'));                                         // d8 // RET C
                                                            // d9 // EXX
a('st+=4;t=b;b=b_;b_=t;t=c;c=c_;c_=t;t=d;d=d_;d_=t;t=e;e=e_;e_=t;t=h;h=h_;h_=t;t=l;l=l_;l_=t');
a(jpci('ff&256'));                                          // da // JP C
                                                            // db // IN A,(n)
a('st+=11;a=rp('.($mp?'mp=':'').'m[pc++&65535]|a<<8)'.($mp?';++mp':''));
a(callci('ff&256'));                                        // dc // CALL C
a(nop(4));                                                  // dd // op dd
a(sbc('m[pc++&65535]', 7));                                 // de // SBC A,n
a(rst(24));                                                 // df // RST 0x18
a(retc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e0//RET PO
a(pop('xh', 'xl'));                                         // e1 // POP IX
a(jpc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e2 //JP PO
a(exspi('x'));                                              // e3 // EX (SP),IX
a(callc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e4//CALL PO
a(push('xh', 'xl'));                                        // e5 // PUSH IX
a(anda('m[pc++&65535]', 7));                                // e6 // AND A,n
a(rst(32));                                                 // e7 // RST 0x20
a(retci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e8//RET PE
a(ldsppci('pc', 'x'));                                      // e9 // JP (IX)
a(jpci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//ea//JP PE
a('st+=4;t=d;d=h;h=t;t=e;e=l;l=t');                         // eb // EX DE,HL
a(callci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//ec//CALL PE
a('r++;g[1280+m[pc++&65535]]()');                           // ed // op ed
a(xoror('^=m[pc++&65535]', 7));                             // ee // XOR A,n
a(rst(40));                                                 // ef // RST 0x28
a(retci('ff&128'));                                         // f0 // RET P
a(popaf());                                                 // f1 // POP AF
a(jpci('ff&128'));                                          // f2 // JP P
a('st+=4;iff=0');                                           // f3 // DI
a(callci('ff&128'));                                        // f4 // CALL P
a(push('a', 'f()'));                                        // f5 // PUSH AF
a(xoror('|=m[pc++&65535]', 7));                             // f6 // OR A,n
a(rst(48));                                                 // f7 // RST 0x30
a(retc('ff&128'));                                          // f8 // RET M
a(ldsppci('sp', 'x'));                                      // f9 // LD SP,IX
a(jpc('ff&128'));                                           // fa // JP M
a('st+=4;iff=1');                                           // fb // EI
a(callc('ff&128'));                                         // fc // CALL M
a(nop(4));                                                  // 01 // op fd
a('t=m[pc++&65535];'.cp('t', 7));                           // fe // CP A,n
a(rst(56));                                                 // ff // RST 0x38

a(nop(4));                                                  // 00 // NOP
a(ldrrim('b', 'c'));                                        // 01 // LD BC,nn
a(ldpr('b', 'c', 'a'));                                     // 02 // LD (BC),A
a(incw('b', 'c'));                                          // 03 // INC BC
a(inc('b'));                                                // 04 // INC B
a(dec('b'));                                                // 05 // DEC B
a(ldrim('b'));                                              // 06 // LD B,n
a('st+=4;a=a*257>>7;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');// RLCA
                                                            // 08 // EX AF,AF'
a('st+=4;t=a_;a_=a;a=t;t=ff_;ff_=ff;ff=t;t=fr_;fr_=fr;fr=t;t=fa_;fa_=fa;fa=t;t=fb_;fb_=fb;fb=t');
a(addrrrr('yh', 'yl', 'b', 'c'));                           // 09 // ADD IY,BC
a(ldrp('b', 'c', 'a', $mp));                                // 0A // LD A,(BC)
a(decw('b', 'c'));                                          // 0B // DEC BC
a(inc('c'));                                                // 0C // INC C
a(dec('c'));                                                // 0D // DEC C
a(ldrim('c'));                                              // 0E // LD C,n
                                                            // 0F // RRCA
a('st+=4;a=a>>1|((a&1)+1^1)<<7;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
                                                            //10  // DJNZ
a('st+=8;if(b=b-1&255)st+=5,'.($mp?'mp=':'').'pc+=(m[pc&65535]^128)-127;else pc++');
a(ldrrim('d', 'e'));                                        // 11 // LD DE,nn
a(ldpr('d', 'e', 'a'));                                     // 12 // LD (DE),A
a(incw('d', 'e'));                                          // 13 // INC DE
a(inc('d'));                                                // 14 // INC D
a(dec('d'));                                                // 15 // DEC D
a(ldrim('d'));                                              // 16 // LD D,n
                                                            // 17 // RLA
a('st+=4;a=a<<1|ff>>8&1;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
a('st+=12;'.($mp?'mp=':'').'pc+=(m[pc&65535]^128)-127');    // 18 // JR
a(addrrrr('yh', 'yl', 'd', 'e'));                           // 19 // ADD IY,DE
a(ldrp('d', 'e', 'a', $mp));                                // 1A // LD A,(DE)
a(decw('d', 'e'));                                          // 1B // DEC DE
a(inc('e'));                                                // 1C // INC E
a(dec('e'));                                                // 1D // DEC E
a(ldrim('e'));                                              // 1E // LD E,n
                                                            // 1F // RRA
a('st+=4;a=(a*513|ff&256)>>1;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
a(jrc('fr'));                                               // 20 // JR NZ,s8
a(ldrrim('yh', 'yl'));                                      // 21 // LD IY,nn
a(ldpnnrr('yh', 'yl', 16));                                 // 22 // LD (nn),IY
a(incw('yh', 'yl'));                                        // 23 // INC IY
a(inc('yh'));                                               // 24 // INC IYH
a(dec('yh'));                                               // 25 // DEC IYH
a(ldrim('yh'));                                             // 26 // LD IYH,n
                                                            // 27 // DAA
a('st+=4;t=(fr^fa^fb^fb>>8)&16;u=0;(a|ff&256)>153&&(u=352);(a&15|t)>9&&(u+=6);fa=a|256;fb&512?(a-=u,fb=~u):a+=fb=u,ff=(fr=a&=255)|u&256');
a(jrci('fr'));                                              // 28 // JR Z,s8
a(addrrrr('yh', 'yl', 'yh', 'yl'));                         // 29 // ADD IY,IY
a(ldrrpnn('yh', 'yl', 16));                                 // 2a // LD IY,(nn)
a(decw('yh', 'yl'));                                        // 2b // DEC IY
a(inc('yl'));                                               // 2c // INC IYL
a(dec('yl'));                                               // 2d // DEC IYL
a(ldrim('yl'));                                             // 2e // LD IYL,n
a('st+=4;ff=ff&-41|(a^=255)&40;fb|=-129;fa=fa&-17|~fr&16'); // 2f // CPL
a(jrc('ff&256'));                                           // 30 // JR NC,s8
a('st+=10;sp=m[pc++&65535]|m[pc++&65535]<<8');              // 31 // LD SP,nn
                                                            // 32 // LD (nn),A
a('st+=13;wb('.($mp?'t=':'').'m[pc++&65535]|m[pc++&65535]<<8,a)'.($mp?';mp='.$b.'+1&255|a<<8':''));
a('st+=6;sp=sp+1&65535');                                   // 33 // INC SP
a(incdecpi('y', '+'));                                      // 34 // INC (IY+d)
a(incdecpi('y', '-'));                                      // 35 // DEC (IY+d)
a(ldpin('y'));                                              // 36 // LD (IY+d),n
a('st+=4;fb=fb&128|(fr^fa)&16;ff=256|ff&128|a&40');         // 37 // SCF
a(jrci('ff&256'));                                          // 38 // JR C,s8
a(addisp('y'));                                             // 39 // ADD IY,SP
                                                            // 3a // LD A,(nn)
a('st+=13;a=m['.($mp?'mp=':'').'m[pc++&65535]|m[pc++&65535]<<8]'.($mp?';++mp':''));
a('st+=6;sp=sp-1&65535');                                   // 3b // DEC SP
a(inc('a'));                                                // 3c // INC A
a(dec('a'));                                                // 3d // DEC A
a(ldrim('a'));                                              // 3e // LD A,n
a('st+=4;fb=fb&128|(ff>>4^fr^fa)&16;ff=~ff&256|ff&128|a&40');//3f // CCF
a(nop(4));                                                  // 40 // LD B,B
a(ldrr('b', 'c', 4));                                       // 41 // LD B,C
a(ldrr('b', 'd', 4));                                       // 42 // LD B,D
a(ldrr('b', 'e', 4));                                       // 43 // LD B,E
a(ldrr('b', 'yh', 4));                                      // 44 // LD B,IYH
a(ldrr('b', 'yl', 4));                                      // 45 // LD B,IYL
a(ldrpi('b', 'y'));                                         // 46 // LD B,(IY+d)
a(ldrr('b', 'a', 4));                                       // 47 // LD B,A
a(ldrr('c', 'b', 4));                                       // 48 // LD C,B
a(nop(4));                                                  // 49 // LD C,C
a(ldrr('c', 'd', 4));                                       // 4a // LD C,D
a(ldrr('c', 'e', 4));                                       // 4b // LD C,E
a(ldrr('c', 'yh', 4));                                      // 4c // LD C,IYH
a(ldrr('c', 'yl', 4));                                      // 4d // LD C,IYL
a(ldrpi('c', 'y'));                                         // 4e // LD C,(IY+d)
a(ldrr('c', 'a', 4));                                       // 4f // LD C,A
a(ldrr('d', 'b', 4));                                       // 50 // LD D,B
a(ldrr('d', 'c', 4));                                       // 51 // LD D,C
a(nop(4));                                                  // 52 // LD D,D
a(ldrr('d', 'e', 4));                                       // 53 // LD D,E
a(ldrr('d', 'yh', 4));                                      // 54 // LD D,IYH
a(ldrr('d', 'yl', 4));                                      // 55 // LD D,IYL
a(ldrpi('d', 'y'));                                         // 56 // LD D,(IY+d)
a(ldrr('d', 'a', 4));                                       // 57 // LD D,A
a(ldrr('e', 'b', 4));                                       // 58 // LD E,B
a(ldrr('e', 'c', 4));                                       // 59 // LD E,C
a(ldrr('e', 'd', 4));                                       // 5a // LD E,D
a(nop(4));                                                  // 5b // LD E,E
a(ldrr('e', 'yh', 4));                                      // 5c // LD E,IYH
a(ldrr('e', 'yl', 4));                                      // 5d // LD E,IYL
a(ldrpi('e', 'y'));                                         // 5e // LD E,(IY+d)
a(ldrr('e', 'a', 4));                                       // 5f // LD E,A
a(ldrr('yh', 'b', 4));                                      // 60 // LD IYH,B
a(ldrr('yh', 'c', 4));                                      // 61 // LD IYH,C
a(ldrr('yh', 'd', 4));                                      // 62 // LD IYH,D
a(ldrr('yh', 'e', 4));                                      // 63 // LD IYH,E
a(nop(4));                                                  // 64 // LD IYH,IYH
a(ldrr('yh', 'yl', 4));                                     // 65 // LD IYH,IYL
a(ldrpi('h', 'y'));                                         // 66 // LD H,(IY+d)
a(ldrr('yh', 'a', 4));                                      // 67 // LD IYH,A
a(ldrr('yl', 'b', 4));                                      // 68 // LD IYL,B
a(ldrr('yl', 'c', 4));                                      // 69 // LD IYL,C
a(ldrr('yl', 'd', 4));                                      // 6a // LD IYL,D
a(ldrr('yl', 'e', 4));                                      // 6b // LD IYL,E
a(ldrr('yl', 'yh', 4));                                     // 6c // LD IYL,IYH
a(nop(4));                                                  // 6d // LD IYL,IYL
a(ldrpi('l', 'y'));                                         // 6e // LD L,(IY+d)
a(ldrr('yl', 'a', 4));                                      // 6f // LD IYL,A
a(ldpri('b', 'y'));                                         // 70 // LD (IY+d),B
a(ldpri('c', 'y'));                                         // 71 // LD (IY+d),C
a(ldpri('d', 'y'));                                         // 72 // LD (IY+d),D
a(ldpri('e', 'y'));                                         // 73 // LD (IY+d),E
a(ldpri('h', 'y'));                                         // 74 // LD (IY+d),H
a(ldpri('l', 'y'));                                         // 75 // LD (IY+d),L
a('st+=4;halted=1;pc--');                                   // 76 // HALT
a(ldpri('a', 'y'));                                         // 77 // LD (IY+d),A
a(ldrr('a', 'b', 4));                                       // 78 // LD A,B
a(ldrr('a', 'c', 4));                                       // 79 // LD A,C
a(ldrr('a', 'd', 4));                                       // 7a // LD A,D
a(ldrr('a', 'e', 4));                                       // 7b // LD A,E
a(ldrr('a', 'yh', 4));                                      // 7c // LD A,IYH
a(ldrr('a', 'yl', 4));                                      // 7d // LD A,IYL
a(ldrpi('a', 'y'));                                         // 7e // LD A,(IY+d)
a(nop(4));                                                  // 7f // LD A,A
a(add('b', 4));                                             // 80 // ADD A,B
a(add('c', 4));                                             // 81 // ADD A,C
a(add('d', 4));                                             // 82 // ADD A,D
a(add('e', 4));                                             // 83 // ADD A,E
a(add('yh', 4));                                            // 84 // ADD A,IYH
a(add('yl', 4));                                            // 85 // ADD A,IYL
a(add('m[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', 15));// 86 // ADD A,(IY+d)
a('a=fr=(ff=2*(fa=fb=a))&255');                             // 87 // ADD A,A
a(adc('b', 4));                                             // 88 // ADC A,B
a(adc('c', 4));                                             // 89 // ADC A,C
a(adc('d', 4));                                             // 8a // ADC A,D
a(adc('e', 4));                                             // 8b // ADC A,E
a(adc('yh', 4));                                            // 8c // ADC A,IYH
a(adc('yl', 4));                                            // 8d // ADC A,IYL
a(adc('m[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', 15));// 8e // ADC A,(IY+d)
a('a=fr=(ff=2*(fa=fb=a)+(ff>>8&1))&255');                   // 8f // ADC A,A
a(sub('b', 4));                                             // 90 // SUB A,B
a(sub('c', 4));                                             // 91 // SUB A,C
a(sub('d', 4));                                             // 92 // SUB A,D
a(sub('e', 4));                                             // 93 // SUB A,E
a(sub('yh', 4));                                            // 94 // SUB A,IYH
a(sub('yl', 4));                                            // 95 // SUB A,IYL
a(sub('m[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', 15));// 96 // SUB A,(IY+d)
a('fb=~(fa=a);a=fr=ff=0');                                  // 97 // SUB A,A
a(sbc('b', 4));                                             // 98 // SBC A,B
a(sbc('c', 4));                                             // 99 // SBC A,C
a(sbc('d', 4));                                             // 9a // SBC A,D
a(sbc('e', 4));                                             // 9b // SBC A,E
a(sbc('yh', 4));                                            // 9c // SBC A,IYH
a(sbc('yl', 4));                                            // 9d // SBC A,IYL
a(sbc('m[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', 15));// 9e // SBC A,(IY+d)
a('fb=~(fa=a);a=fr=(ff=ff&256/-256)&255');                  // 9f // SBC A,A
a(anda('b', 4));                                            // a0 // AND B
a(anda('c', 4));                                            // a1 // AND C
a(anda('d', 4));                                            // a2 // AND D
a(anda('e', 4));                                            // a3 // AND E
a(anda('yh', 4));                                           // a4 // AND IYH
a(anda('yl', 4));                                           // a5 // AND IYL
a(anda('m[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', 15));//a6 // AND (IY+d)
a('fa=~(ff=fr=a);fb=0');                                    // a7 // AND A
a(xoror('^=b', 4));                                         // a8 // XOR B
a(xoror('^=c', 4));                                         // a9 // XOR C
a(xoror('^=d', 4));                                         // aa // XOR D
a(xoror('^=e', 4));                                         // ab // XOR E
a(xoror('^=yh', 4));                                        // ac // XOR IYH
a(xoror('^=yl', 4));                                        // ad // XOR IYL
a(xoror('^=m[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', 15));//ae//XOR (IY+d)
a('a=ff=fr=fb=0;fa=256');                                   // af // XOR A
a(xoror('|=b', 4));                                         // b0 // OR B
a(xoror('|=c', 4));                                         // b1 // OR C
a(xoror('|=d', 4));                                         // b2 // OR D
a(xoror('|=e', 4));                                         // b3 // OR E
a(xoror('|=yh', 4));                                        // b4 // OR IYH
a(xoror('|=yl', 4));                                        // b5 // OR IYL
a(xoror('|=m[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', 15));//b6//OR (IY+d)
a('fa=(ff=fr=a)|256;fb=0');                                 // b7 // OR A
a(cp('b', 4));                                              // b8 // CP B
a(cp('c', 4));                                              // b9 // CP C
a(cp('d', 4));                                              // ba // CP D
a(cp('e', 4));                                              // bb // CP E
a(cp('yh', 4));                                             // bc // CP IYH
a(cp('yl', 4));                                             // bd // CP IYL
a('t=m[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535];'.cp('t', 15));//be//CP (IY+d)
a('fr=0;fb=~(fa=a);ff=a&40');                               // bf // CP A
a(retc('fr'));                                              // c0 // RET NZ
a(pop('b', 'c'));                                           // c1 // POP BC
a(jpc('fr'));                                               // c2 // JP NZ
a('st+=10;'.($mp?'mp=':'').'pc=m[pc&65535]|m[pc+1&65535]<<8');//c3// JP nn
a(callc('fr'));                                             // c4 // CALL NZ
a(push('b', 'c'));                                          // c5 // PUSH BC
a(add('m[pc++&65535]', 7));                                 // c6 // ADD A,n
a(rst(0));                                                  // c7 // RST 0x00
a(retci('fr'));                                             // c8 // RET Z
a(ret(10));                                                 // c9 // RET
a(jpci('fr'));                                              // ca // JP Z
a('st+=11;t=m[u=((m[pc++&65535]^128)-128+(yl|yh<<8))&65535];g[1024+m[pc++&65535]]()');// cb // op ddcb
a(callci('fr'));                                            // cc // CALL Z
                                                            // cd // CALL NN
a('st+=17;t=pc+2;'.($mp?'mp=':'').'pc=m[pc&65535]|m[pc+1&65535]<<8;wb(--sp&65535,t>>8&255);wb(sp=sp-1&65535,t&255)');
a(adc('m[pc++&65535]', 7));                                 // ce // ADC A,n
a(rst(8));                                                  // cf // RST 0x08
a(retc('ff&256'));                                          // d0 // RET NC
a(pop('d', 'e'));                                           // d1 // POP DE
a(jpc('ff&256'));                                           // d2 // JP NC
                                                            // d3 // OUT (n),A
a('st+=11;wp('.($mp?'mp=':'').'m[pc++&65535]|a<<8,a)'.($mp?';mp=mp+1&255|mp&65280':''));
a(callc('ff&256'));                                         // d4 // CALL NC
a(push('d', 'e'));                                          // d5 // PUSH DE
a(sub('m[pc++&65535]', 7));                                 // d6 // SUB A,n
a(rst(16));                                                 // d7 // RST 0x10
a(retci('ff&256'));                                         // d8 // RET C
                                                            // d9 // EXX
a('st+=4;t=b;b=b_;b_=t;t=c;c=c_;c_=t;t=d;d=d_;d_=t;t=e;e=e_;e_=t;t=h;h=h_;h_=t;t=l;l=l_;l_=t');
a(jpci('ff&256'));                                          // da // JP C
                                                            // db // IN A,(n)
a('st+=11;a=rp('.($mp?'mp=':'').'m[pc++&65535]|a<<8)'.($mp?';++mp':''));
a(callci('ff&256'));                                        // dc // CALL C
a(nop(4));                                                  // dd // op dd
a(sbc('m[pc++&65535]', 7));                                 // de // SBC A,n
a(rst(24));                                                 // df // RST 0x18
a(retc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e0//RET PO
a(pop('yh', 'yl'));                                         // e1 // POP IY
a(jpc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e2 //JP PO
a(exspi('y'));                                              // e3 // EX (SP),IY
a(callc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e4//CALL PO
a(push('yh', 'yl'));                                        // e5 // PUSH IY
a(anda('m[pc++&65535]', 7));                                // e6 // AND A,n
a(rst(32));                                                 // e7 // RST 0x20
a(retci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e8//RET PE
a(ldsppci('pc', 'y'));                                      // e9 // JP (IY)
a(jpci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//ea//JP PE
a('st+=4;t=d;d=h;h=t;t=e;e=l;l=t');                         // eb // EX DE,HL
a(callci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//ec//CALL PE
a('r++;g[1280+m[pc++&65535]]()');                           // ed // op ed
a(xoror('^=m[pc++&65535]', 7));                             // ee // XOR A,n
a(rst(40));                                                 // ef // RST 0x28
a(retci('ff&128'));                                         // f0 // RET P
a(popaf());                                                 // f1 // POP AF
a(jpci('ff&128'));                                          // f2 // JP P
a('st+=4;iff=0');                                           // f3 // DI
a(callci('ff&128'));                                        // f4 // CALL P
a(push('a', 'f()'));                                        // f5 // PUSH AF
a(xoror('|=m[pc++&65535]', 7));                             // f6 // OR A,n
a(rst(48));                                                 // f7 // RST 0x30
a(retc('ff&128'));                                          // f8 // RET M
a(ldsppci('sp', 'y'));                                      // f9 // LD SP,IY
a(jpc('ff&128'));                                           // fa // JP M
a('st+=4;iff=1');                                           // fb // EI
a(callc('ff&128'));                                         // fc // CALL M
a(nop(4));                                                  // 01 // op fd
a('t=m[pc++&65535];'.cp('t', 7));                           // fe // CP A,n
a(rst(56));                                                 // ff // RST 0x38

a(rlc('b'));                                                // 00 // RLC B
a(rlc('c'));                                                // 01 // RLC C
a(rlc('d'));                                                // 02 // RLC D
a(rlc('e'));                                                // 03 // RLC E
a(rlc('h'));                                                // 04 // RLC H
a(rlc('l'));                                                // 05 // RLC L
a('st+=15;t=l|h<<8;u=m[t];'.rlc('u').';wb(t,u)');           // 06 // RLC (HL)
a(rlc('a'));                                                // 07 // RLC A
a(rrc('b'));                                                // 08 // RRC B
a(rrc('c'));                                                // 09 // RRC C
a(rrc('d'));                                                // 0a // RRC D
a(rrc('e'));                                                // 0b // RRC E
a(rrc('h'));                                                // 0c // RRC H
a(rrc('l'));                                                // 0d // RRC L
a('st+=15;t=l|h<<8;u=m[t];'.rrc('u').';wb(t,u)');           // 0e // RRC (HL)
a(rrc('a'));                                                // 0f // RRC A
a(rl('b'));                                                 // 10 // RL B
a(rl('c'));                                                 // 11 // RL C
a(rl('d'));                                                 // 12 // RL D
a(rl('e'));                                                 // 13 // RL E
a(rl('h'));                                                 // 14 // RL H
a(rl('l'));                                                 // 15 // RL L
a('st+=15;t=l|h<<8;u=m[t];'.rl('u').';wb(t,u)');            // 16 // RL (HL)
a(rl('a'));                                                 // 17 // RL A
a(rr('b'));                                                 // 18 // RR B
a(rr('c'));                                                 // 19 // RR C
a(rr('d'));                                                 // 1a // RR D
a(rr('e'));                                                 // 1b // RR E
a(rr('h'));                                                 // 1c // RR H
a(rr('l'));                                                 // 1d // RR L
a('st+=15;t=l|h<<8;u=m[t];'.rr('u').';wb(t,u)');            // 1e // RR (HL)
a(rr('a'));                                                 // 1f // RR A
a(sla('b'));                                                // 20 // SLA B
a(sla('c'));                                                // 21 // SLA C
a(sla('d'));                                                // 22 // SLA D
a(sla('e'));                                                // 23 // SLA E
a(sla('h'));                                                // 24 // SLA H
a(sla('l'));                                                // 25 // SLA L
a('st+=15;t=l|h<<8;u=m[t];'.sla('u').';wb(t,u)');           // 26 // SLA (HL)
a(sla('a'));                                                // 27 // SLA A
a(sra('b'));                                                // 28 // SRA B
a(sra('c'));                                                // 29 // SRA C
a(sra('d'));                                                // 2a // SRA D
a(sra('e'));                                                // 2b // SRA E
a(sra('h'));                                                // 2c // SRA H
a(sra('l'));                                                // 2d // SRA L
a('st+=15;t=l|h<<8;u=m[t];'.sra('u').';wb(t,u)');           // 2e // SRA (HL)
a(sra('a'));                                                // 2f // SRA A
a(sll('b'));                                                // 30 // SLL B
a(sll('c'));                                                // 31 // SLL C
a(sll('d'));                                                // 32 // SLL D
a(sll('e'));                                                // 33 // SLL E
a(sll('h'));                                                // 34 // SLL H
a(sll('l'));                                                // 35 // SLL L
a('st+=15;t=l|h<<8;u=m[t];'.sll('u').';wb(t,u)');           // 36 // SLL (HL)
a(sll('a'));                                                // 37 // SLL A
a(srl('b'));                                                // 38 // SRL B
a(srl('c'));                                                // 39 // SRL C
a(srl('d'));                                                // 3a // SRL D
a(srl('e'));                                                // 3b // SRL E
a(srl('h'));                                                // 3c // SRL H
a(srl('l'));                                                // 3d // SRL L
a('st+=15;t=l|h<<8;u=m[t];'.srl('u').';wb(t,u)');           // 3e // SRL (HL)
a(srl('a'));                                                // 3f // SRL A
a(bit(1,'b'));                                              // 40 // BIT 0,B
a(bit(1,'c'));                                              // 41 // BIT 0,C
a(bit(1,'d'));                                              // 42 // BIT 0,D
a(bit(1,'e'));                                              // 43 // BIT 0,E
a(bit(1,'h'));                                              // 44 // BIT 0,H
a(bit(1,'l'));                                              // 45 // BIT 0,L
a(bithl(1));                                                // 46 // BIT 0,(HL)
a(bit(1,'a'));                                              // 47 // BIT 0,A
a(bit(2,'b'));                                              // 48 // BIT 1,B
a(bit(2,'c'));                                              // 49 // BIT 1,C
a(bit(2,'d'));                                              // 4a // BIT 1,D
a(bit(2,'e'));                                              // 4b // BIT 1,E
a(bit(2,'h'));                                              // 4c // BIT 1,H
a(bit(2,'l'));                                              // 4d // BIT 1,L
a(bithl(2));                                                // 4e // BIT 1,(HL)
a(bit(2,'a'));                                              // 4f // BIT 1,A
a(bit(4,'b'));                                              // 50 // BIT 2,B
a(bit(4,'c'));                                              // 51 // BIT 2,C
a(bit(4,'d'));                                              // 52 // BIT 2,D
a(bit(4,'e'));                                              // 53 // BIT 2,E
a(bit(4,'h'));                                              // 54 // BIT 2,H
a(bit(4,'l'));                                              // 55 // BIT 2,L
a(bithl(4));                                                // 56 // BIT 2,(HL)
a(bit(4,'a'));                                              // 57 // BIT 2,A
a(bit(8,'b'));                                              // 58 // BIT 3,B
a(bit(8,'c'));                                              // 59 // BIT 3,C
a(bit(8,'d'));                                              // 5a // BIT 3,D
a(bit(8,'e'));                                              // 5b // BIT 3,E
a(bit(8,'h'));                                              // 5c // BIT 3,H
a(bit(8,'l'));                                              // 5d // BIT 3,L
a(bithl(8));                                                // 5e // BIT 3,(HL)
a(bit(8,'a'));                                              // 5f // BIT 3,A
a(bit(16,'b'));                                             // 60 // BIT 4,B
a(bit(16,'c'));                                             // 61 // BIT 4,C
a(bit(16,'d'));                                             // 62 // BIT 4,D
a(bit(16,'e'));                                             // 63 // BIT 4,E
a(bit(16,'h'));                                             // 64 // BIT 4,H
a(bit(16,'l'));                                             // 65 // BIT 4,L
a(bithl(16));                                               // 66 // BIT 4,(HL)
a(bit(16,'a'));                                             // 67 // BIT 4,A
a(bit(32,'b'));                                             // 68 // BIT 5,B
a(bit(32,'c'));                                             // 69 // BIT 5,C
a(bit(32,'d'));                                             // 6a // BIT 5,D
a(bit(32,'e'));                                             // 6b // BIT 5,E
a(bit(32,'h'));                                             // 6c // BIT 5,H
a(bit(32,'l'));                                             // 6d // BIT 5,L
a(bithl(32));                                               // 6e // BIT 5,(HL)
a(bit(32,'a'));                                             // 6f // BIT 5,A
a(bit(64,'b'));                                             // 70 // BIT 6,B
a(bit(64,'c'));                                             // 71 // BIT 6,C
a(bit(64,'d'));                                             // 72 // BIT 6,D
a(bit(64,'e'));                                             // 73 // BIT 6,E
a(bit(64,'h'));                                             // 74 // BIT 6,H
a(bit(64,'l'));                                             // 75 // BIT 6,L
a(bithl(64));                                               // 76 // BIT 6,(HL)
a(bit(64,'a'));                                             // 77 // BIT 6,A
a(bit(128,'b'));                                            // 78 // BIT 7,B
a(bit(128,'c'));                                            // 79 // BIT 7,C
a(bit(128,'d'));                                            // 7a // BIT 7,D
a(bit(128,'e'));                                            // 7b // BIT 7,E
a(bit(128,'h'));                                            // 7c // BIT 7,H
a(bit(128,'l'));                                            // 7d // BIT 7,L
a(bithl(128));                                              // 7e // BIT 7,(HL)
a(bit(128,'a'));                                            // 7f // BIT 7,A
a(res(254,'b'));                                            // 80 // RES 0,B
a(res(254,'c'));                                            // 81 // RES 0,C
a(res(254,'d'));                                            // 82 // RES 0,D
a(res(254,'e'));                                            // 83 // RES 0,E
a(res(254,'h'));                                            // 84 // RES 0,H
a(res(254,'l'));                                            // 85 // RES 0,L
a(reshl(254));                                              // 86 // RES 0,(HL)
a(res(254,'a'));                                            // 87 // RES 0,A
a(res(253,'b'));                                            // 88 // RES 1,B
a(res(253,'c'));                                            // 89 // RES 1,C
a(res(253,'d'));                                            // 8a // RES 1,D
a(res(253,'e'));                                            // 8b // RES 1,E
a(res(253,'h'));                                            // 8c // RES 1,H
a(res(253,'l'));                                            // 8d // RES 1,L
a(reshl(253));                                              // 8e // RES 1,(HL)
a(res(253,'a'));                                            // 8f // RES 1,A
a(res(251,'b'));                                            // 90 // RES 2,B
a(res(251,'c'));                                            // 91 // RES 2,C
a(res(251,'d'));                                            // 92 // RES 2,D
a(res(251,'e'));                                            // 93 // RES 2,E
a(res(251,'h'));                                            // 94 // RES 2,H
a(res(251,'l'));                                            // 95 // RES 2,L
a(reshl(251));                                              // 96 // RES 2,(HL)
a(res(251,'a'));                                            // 97 // RES 2,A
a(res(247,'b'));                                            // 98 // RES 3,B
a(res(247,'c'));                                            // 99 // RES 3,C
a(res(247,'d'));                                            // 9a // RES 3,D
a(res(247,'e'));                                            // 9b // RES 3,E
a(res(247,'h'));                                            // 9c // RES 3,H
a(res(247,'l'));                                            // 9d // RES 3,L
a(reshl(247));                                              // 9e // RES 3,(HL)
a(res(247,'a'));                                            // 9f // RES 3,A
a(res(239,'b'));                                            // a0 // RES 4,B
a(res(239,'c'));                                            // a1 // RES 4,C
a(res(239,'d'));                                            // a2 // RES 4,D
a(res(239,'e'));                                            // a3 // RES 4,E
a(res(239,'h'));                                            // a4 // RES 4,H
a(res(239,'l'));                                            // a5 // RES 4,L
a(reshl(239));                                              // a6 // RES 4,(HL)
a(res(239,'a'));                                            // a7 // RES 4,A
a(res(223,'b'));                                            // a8 // RES 5,B
a(res(223,'c'));                                            // a9 // RES 5,C
a(res(223,'d'));                                            // aa // RES 5,D
a(res(223,'e'));                                            // ab // RES 5,E
a(res(223,'h'));                                            // ac // RES 5,H
a(res(223,'l'));                                            // ad // RES 5,L
a(reshl(223));                                              // ae // RES 5,(HL)
a(res(223,'a'));                                            // af // RES 5,A
a(res(191,'b'));                                            // b0 // RES 6,B
a(res(191,'c'));                                            // b1 // RES 6,C
a(res(191,'d'));                                            // b2 // RES 6,D
a(res(191,'e'));                                            // b3 // RES 6,E
a(res(191,'h'));                                            // b4 // RES 6,H
a(res(191,'l'));                                            // b5 // RES 6,L
a(reshl(191));                                              // b6 // RES 6,(HL)
a(res(191,'a'));                                            // b7 // RES 6,A
a(res(127,'b'));                                            // b8 // RES 7,B
a(res(127,'c'));                                            // b9 // RES 7,C
a(res(127,'d'));                                            // ba // RES 7,D
a(res(127,'e'));                                            // bb // RES 7,E
a(res(127,'h'));                                            // bc // RES 7,H
a(res(127,'l'));                                            // bd // RES 7,L
a(reshl(127));                                              // be // RES 7,(HL)
a(res(127,'a'));                                            // bf // RES 7,A
a(set(1,'b'));                                              // c0 // SET 0,B
a(set(1,'c'));                                              // c1 // SET 0,C
a(set(1,'d'));                                              // c2 // SET 0,D
a(set(1,'e'));                                              // c3 // SET 0,E
a(set(1,'h'));                                              // c4 // SET 0,H
a(set(1,'l'));                                              // c5 // SET 0,L
a(sethl(1));                                                // c6 // SET 0,(HL)
a(set(1,'a'));                                              // c7 // SET 0,A
a(set(2,'b'));                                              // c8 // SET 1,B
a(set(2,'c'));                                              // c9 // SET 1,C
a(set(2,'d'));                                              // ca // SET 1,D
a(set(2,'e'));                                              // cb // SET 1,E
a(set(2,'h'));                                              // cc // SET 1,H
a(set(2,'l'));                                              // cd // SET 1,L
a(sethl(2));                                                // ce // SET 1,(HL)
a(set(2,'a'));                                              // cf // SET 1,A
a(set(4,'b'));                                              // d0 // SET 2,B
a(set(4,'c'));                                              // d1 // SET 2,C
a(set(4,'d'));                                              // d2 // SET 2,D
a(set(4,'e'));                                              // d3 // SET 2,E
a(set(4,'h'));                                              // d4 // SET 2,H
a(set(4,'l'));                                              // d5 // SET 2,L
a(sethl(4));                                                // d6 // SET 2,(HL)
a(set(4,'a'));                                              // d7 // SET 2,A
a(set(8,'b'));                                              // d8 // SET 3,B
a(set(8,'c'));                                              // d9 // SET 3,C
a(set(8,'d'));                                              // da // SET 3,D
a(set(8,'e'));                                              // db // SET 3,E
a(set(8,'h'));                                              // dc // SET 3,H
a(set(8,'l'));                                              // dd // SET 3,L
a(sethl(8));                                                // de // SET 3,(HL)
a(set(8,'a'));                                              // df // SET 3,A
a(set(16,'b'));                                             // e0 // SET 4,B
a(set(16,'c'));                                             // e1 // SET 4,C
a(set(16,'d'));                                             // e2 // SET 4,D
a(set(16,'e'));                                             // e3 // SET 4,E
a(set(16,'h'));                                             // e4 // SET 4,H
a(set(16,'l'));                                             // e5 // SET 4,L
a(sethl(16));                                               // e6 // SET 4,(HL)
a(set(16,'a'));                                             // e7 // SET 4,A
a(set(32,'b'));                                             // e8 // SET 5,B
a(set(32,'c'));                                             // e9 // SET 5,C
a(set(32,'d'));                                             // ea // SET 5,D
a(set(32,'e'));                                             // eb // SET 5,E
a(set(32,'h'));                                             // ec // SET 5,H
a(set(32,'l'));                                             // ed // SET 5,L
a(sethl(32));                                               // ee // SET 5,(HL)
a(set(32,'a'));                                             // ef // SET 5,A
a(set(64,'b'));                                             // f0 // SET 6,B
a(set(64,'c'));                                             // f1 // SET 6,C
a(set(64,'d'));                                             // f2 // SET 6,D
a(set(64,'e'));                                             // f3 // SET 6,E
a(set(64,'h'));                                             // f4 // SET 6,H
a(set(64,'l'));                                             // f5 // SET 6,L
a(sethl(64));                                               // f6 // SET 6,(HL)
a(set(64,'a'));                                             // f7 // SET 6,A
a(set(128,'b'));                                            // f8 // SET 7,B
a(set(128,'c'));                                            // f9 // SET 7,C
a(set(128,'d'));                                            // fa // SET 7,D
a(set(128,'e'));                                            // fb // SET 7,E
a(set(128,'h'));                                            // fc // SET 7,H
a(set(128,'l'));                                            // fd // SET 7,L
a(sethl(128));                                              // fe // SET 7,(HL)
a(set(128,'a'));                                            // ff // SET 7,A

a(rlc('t').';wb(u,b=t)');                                   // 00 // LD B,RLC(IY+d)
a(rlc('t').';wb(u,c=t)');                                   // 01 // LD C,RLC(IY+d)
a(rlc('t').';wb(u,d=t)');                                   // 02 // LD D,RLC(IY+d)
a(rlc('t').';wb(u,e=t)');                                   // 03 // LD E,RLC(IY+d)
a(rlc('t').';wb(u,h=t)');                                   // 04 // LD H,RLC(IY+d)
a(rlc('t').';wb(u,l=t)');                                   // 05 // LD L,RLC(IY+d)
a(rlc('t').';wb(u,t)');                                     // 06 // RLC(IY+d)
a(rlc('t').';wb(u,a=t)');                                   // 07 // LD A,RLC(IY+d)
a(rrc('t').';wb(u,b=t)');                                   // 08 // LD B,RRC(IY+d)
a(rrc('t').';wb(u,c=t)');                                   // 09 // LD C,RRC(IY+d)
a(rrc('t').';wb(u,d=t)');                                   // 0a // LD D,RRC(IY+d)
a(rrc('t').';wb(u,e=t)');                                   // 0b // LD E,RRC(IY+d)
a(rrc('t').';wb(u,h=t)');                                   // 0c // LD H,RRC(IY+d)
a(rrc('t').';wb(u,l=t)');                                   // 0d // LD L,RRC(IY+d)
a(rrc('t').';wb(u,t)');                                     // 0e // RRC(IY+d)
a(rrc('t').';wb(u,a=t)');                                   // 0f // LD A,RRC(IY+d)
a(rl('t').';wb(u,b=t)');                                    // 10 // LD B,RL(IY+d)
a(rl('t').';wb(u,c=t)');                                    // 11 // LD C,RL(IY+d)
a(rl('t').';wb(u,d=t)');                                    // 12 // LD D,RL(IY+d)
a(rl('t').';wb(u,e=t)');                                    // 13 // LD E,RL(IY+d)
a(rl('t').';wb(u,h=t)');                                    // 14 // LD H,RL(IY+d)
a(rl('t').';wb(u,l=t)');                                    // 15 // LD L,RL(IY+d)
a(rl('t').';wb(u,t)');                                      // 16 // RL(IY+d)
a(rl('t').';wb(u,a=t)');                                    // 17 // LD A,RR(IY+d)
a(rr('t').';wb(u,b=t)');                                    // 18 // LD B,RR(IY+d)
a(rr('t').';wb(u,c=t)');                                    // 19 // LD C,RR(IY+d)
a(rr('t').';wb(u,d=t)');                                    // 1a // LD D,RR(IY+d)
a(rr('t').';wb(u,e=t)');                                    // 1b // LD E,RR(IY+d)
a(rr('t').';wb(u,h=t)');                                    // 1c // LD H,RR(IY+d)
a(rr('t').';wb(u,l=t)');                                    // 1d // LD L,RR(IY+d)
a(rr('t').';wb(u,t)');                                      // 1e // RR(IY+d)
a(rr('t').';wb(u,a=t)');                                    // 1f // LD A,RR(IY+d)
a(sla('t').';wb(u,b=t)');                                   // 20 // LD B,SLA(IY+d)
a(sla('t').';wb(u,c=t)');                                   // 21 // LD C,SLA(IY+d)
a(sla('t').';wb(u,d=t)');                                   // 22 // LD D,SLA(IY+d)
a(sla('t').';wb(u,e=t)');                                   // 23 // LD E,SLA(IY+d)
a(sla('t').';wb(u,h=t)');                                   // 24 // LD H,SLA(IY+d)
a(sla('t').';wb(u,l=t)');                                   // 25 // LD L,SLA(IY+d)
a(sla('t').';wb(u,t)');                                     // 26 // SLA(IY+d)
a(sla('t').';wb(u,a=t)');                                   // 27 // LD A,SLA(IY+d)
a(sra('t').';wb(u,b=t)');                                   // 28 // LD B,SRA(IY+d)
a(sra('t').';wb(u,c=t)');                                   // 29 // LD C,SRA(IY+d)
a(sra('t').';wb(u,d=t)');                                   // 2a // LD D,SRA(IY+d)
a(sra('t').';wb(u,e=t)');                                   // 2b // LD E,SRA(IY+d)
a(sra('t').';wb(u,h=t)');                                   // 2c // LD H,SRA(IY+d)
a(sra('t').';wb(u,l=t)');                                   // 2d // LD L,SRA(IY+d)
a(sra('t').';wb(u,t)');                                     // 2e // SRA(IY+d)
a(sra('t').';wb(u,a=t)');                                   // 2f // LD A,SRA(IY+d)
a(sll('t').';wb(u,b=t)');                                   // 30 // LD B,SLL(IY+d)
a(sll('t').';wb(u,c=t)');                                   // 31 // LD C,SLL(IY+d)
a(sll('t').';wb(u,d=t)');                                   // 32 // LD D,SLL(IY+d)
a(sll('t').';wb(u,e=t)');                                   // 33 // LD E,SLL(IY+d)
a(sll('t').';wb(u,h=t)');                                   // 34 // LD H,SLL(IY+d)
a(sll('t').';wb(u,l=t)');                                   // 35 // LD L,SLL(IY+d)
a(sll('t').';wb(u,t)');                                     // 36 // SLL(IY+d)
a(sll('t').';wb(u,a=t)');                                   // 37 // LD A,SLL(IY+d)
a(srl('t').';wb(u,b=t)');                                   // 38 // LD B,SRL(IY+d)
a(srl('t').';wb(u,c=t)');                                   // 39 // LD C,SRL(IY+d)
a(srl('t').';wb(u,d=t)');                                   // 3a // LD D,SRL(IY+d)
a(srl('t').';wb(u,e=t)');                                   // 3b // LD E,SRL(IY+d)
a(srl('t').';wb(u,h=t)');                                   // 3c // LD H,SRL(IY+d)
a(srl('t').';wb(u,l=t)');                                   // 3d // LD L,SRL(IY+d)
a(srl('t').';wb(u,t)');                                     // 3e // SRL(IY+d)
a(srl('t').';wb(u,a=t)');                                   // 3f // LD A,SRL(IY+d)
a(biti(1));                                                 // 40 // BIT 0,(IY+d)
a(biti(1));                                                 // 41 // BIT 0,(IY+d)
a(biti(1));                                                 // 42 // BIT 0,(IY+d)
a(biti(1));                                                 // 43 // BIT 0,(IY+d)
a(biti(1));                                                 // 44 // BIT 0,(IY+d)
a(biti(1));                                                 // 45 // BIT 0,(IY+d)
a(biti(1));                                                 // 46 // BIT 0,(IY+d)
a(biti(1));                                                 // 47 // BIT 0,(IY+d)
a(biti(2));                                                 // 48 // BIT 1,(IY+d)
a(biti(2));                                                 // 49 // BIT 1,(IY+d)
a(biti(2));                                                 // 4a // BIT 1,(IY+d)
a(biti(2));                                                 // 4b // BIT 1,(IY+d)
a(biti(2));                                                 // 4c // BIT 1,(IY+d)
a(biti(2));                                                 // 4d // BIT 1,(IY+d)
a(biti(2));                                                 // 4e // BIT 1,(IY+d)
a(biti(2));                                                 // 4f // BIT 1,(IY+d)
a(biti(4));                                                 // 50 // BIT 2,(IY+d)
a(biti(4));                                                 // 51 // BIT 2,(IY+d)
a(biti(4));                                                 // 52 // BIT 2,(IY+d)
a(biti(4));                                                 // 53 // BIT 2,(IY+d)
a(biti(4));                                                 // 54 // BIT 2,(IY+d)
a(biti(4));                                                 // 55 // BIT 2,(IY+d)
a(biti(4));                                                 // 56 // BIT 2,(IY+d)
a(biti(4));                                                 // 57 // BIT 2,(IY+d)
a(biti(8));                                                 // 58 // BIT 3,(IY+d)
a(biti(8));                                                 // 59 // BIT 3,(IY+d)
a(biti(8));                                                 // 5a // BIT 3,(IY+d)
a(biti(8));                                                 // 5b // BIT 3,(IY+d)
a(biti(8));                                                 // 5c // BIT 3,(IY+d)
a(biti(8));                                                 // 5d // BIT 3,(IY+d)
a(biti(8));                                                 // 5e // BIT 3,(IY+d)
a(biti(8));                                                 // 5f // BIT 3,(IY+d)
a(biti(16));                                                // 60 // BIT 4,(IY+d)
a(biti(16));                                                // 61 // BIT 4,(IY+d)
a(biti(16));                                                // 62 // BIT 4,(IY+d)
a(biti(16));                                                // 63 // BIT 4,(IY+d)
a(biti(16));                                                // 64 // BIT 4,(IY+d)
a(biti(16));                                                // 65 // BIT 4,(IY+d)
a(biti(16));                                                // 66 // BIT 4,(IY+d)
a(biti(16));                                                // 67 // BIT 4,(IY+d)
a(biti(32));                                                // 68 // BIT 5,(IY+d)
a(biti(32));                                                // 69 // BIT 5,(IY+d)
a(biti(32));                                                // 6a // BIT 5,(IY+d)
a(biti(32));                                                // 6b // BIT 5,(IY+d)
a(biti(32));                                                // 6c // BIT 5,(IY+d)
a(biti(32));                                                // 6d // BIT 5,(IY+d)
a(biti(32));                                                // 6e // BIT 5,(IY+d)
a(biti(32));                                                // 7f // BIT 5,(IY+d)
a(biti(64));                                                // 70 // BIT 6,(IY+d)
a(biti(64));                                                // 71 // BIT 6,(IY+d)
a(biti(64));                                                // 72 // BIT 6,(IY+d)
a(biti(64));                                                // 73 // BIT 6,(IY+d)
a(biti(64));                                                // 74 // BIT 6,(IY+d)
a(biti(64));                                                // 75 // BIT 6,(IY+d)
a(biti(64));                                                // 76 // BIT 6,(IY+d)
a(biti(64));                                                // 77 // BIT 6,(IY+d)
a(biti(128));                                               // 78 // BIT 7,(IY+d)
a(biti(128));                                               // 79 // BIT 7,(IY+d)
a(biti(128));                                               // 7a // BIT 7,(IY+d)
a(biti(128));                                               // 7b // BIT 7,(IY+d)
a(biti(128));                                               // 7c // BIT 7,(IY+d)
a(biti(128));                                               // 7d // BIT 7,(IY+d)
a(biti(128));                                               // 7e // BIT 7,(IY+d)
a(biti(128));                                               // 7f // BIT 7,(IY+d)
a(res(254,'t').';wb(u,b=t)');                               // 80 // LD B,RES 0,(IY+d)
a(res(254,'t').';wb(u,c=t)');                               // 81 // LD C,RES 0,(IY+d)
a(res(254,'t').';wb(u,d=t)');                               // 82 // LD D,RES 0,(IY+d)
a(res(254,'t').';wb(u,e=t)');                               // 83 // LD E,RES 0,(IY+d)
a(res(254,'t').';wb(u,h=t)');                               // 84 // LD H,RES 0,(IY+d)
a(res(254,'t').';wb(u,l=t)');                               // 85 // LD L,RES 0,(IY+d)
a(res(254,'t').';wb(u,t)');                                 // 86 // RES 0,(IY+d)
a(res(254,'t').';wb(u,a=t)');                               // 87 // LD A,RES 0,(IY+d)
a(res(253,'t').';wb(u,b=t)');                               // 88 // LD B,RES 1,(IY+d)
a(res(253,'t').';wb(u,c=t)');                               // 89 // LD C,RES 1,(IY+d)
a(res(253,'t').';wb(u,d=t)');                               // 8a // LD D,RES 1,(IY+d)
a(res(253,'t').';wb(u,e=t)');                               // 8b // LD E,RES 1,(IY+d)
a(res(253,'t').';wb(u,h=t)');                               // 8c // LD H,RES 1,(IY+d)
a(res(253,'t').';wb(u,l=t)');                               // 8d // LD L,RES 1,(IY+d)
a(res(253,'t').';wb(u,t)');                                 // 8e // RES 1,(IY+d)
a(res(253,'t').';wb(u,a=t)');                               // 8f // LD A,RES 1,(IY+d)
a(res(251,'t').';wb(u,b=t)');                               // 90 // LD B,RES 2,(IY+d)
a(res(251,'t').';wb(u,c=t)');                               // 91 // LD C,RES 2,(IY+d)
a(res(251,'t').';wb(u,d=t)');                               // 92 // LD D,RES 2,(IY+d)
a(res(251,'t').';wb(u,e=t)');                               // 93 // LD E,RES 2,(IY+d)
a(res(251,'t').';wb(u,h=t)');                               // 94 // LD H,RES 2,(IY+d)
a(res(251,'t').';wb(u,l=t)');                               // 95 // LD L,RES 2,(IY+d)
a(res(251,'t').';wb(u,t)');                                 // 96 // RES 2,(IY+d)
a(res(251,'t').';wb(u,a=t)');                               // 97 // LD A,RES 2,(IY+d)
a(res(247,'t').';wb(u,b=t)');                               // 98 // LD B,RES 3,(IY+d)
a(res(247,'t').';wb(u,c=t)');                               // 99 // LD C,RES 3,(IY+d)
a(res(247,'t').';wb(u,d=t)');                               // 9a // LD D,RES 3,(IY+d)
a(res(247,'t').';wb(u,e=t)');                               // 9b // LD E,RES 3,(IY+d)
a(res(247,'t').';wb(u,h=t)');                               // 9c // LD H,RES 3,(IY+d)
a(res(247,'t').';wb(u,l=t)');                               // 9d // LD L,RES 3,(IY+d)
a(res(247,'t').';wb(u,t)');                                 // 9e // RES 3,(IY+d)
a(res(247,'t').';wb(u,a=t)');                               // 9f // LD A,RES 3,(IY+d)
a(res(239,'t').';wb(u,b=t)');                               // a0 // LD B,RES 4,(IY+d)
a(res(239,'t').';wb(u,c=t)');                               // a1 // LD C,RES 4,(IY+d)
a(res(239,'t').';wb(u,d=t)');                               // a2 // LD D,RES 4,(IY+d)
a(res(239,'t').';wb(u,e=t)');                               // a3 // LD E,RES 4,(IY+d)
a(res(239,'t').';wb(u,h=t)');                               // a4 // LD H,RES 4,(IY+d)
a(res(239,'t').';wb(u,l=t)');                               // a5 // LD L,RES 4,(IY+d)
a(res(239,'t').';wb(u,t)');                                 // a6 // RES 4,(IY+d)
a(res(239,'t').';wb(u,a=t)');                               // a7 // LD A,RES 4,(IY+d)
a(res(223,'t').';wb(u,b=t)');                               // a8 // LD B,RES 5,(IY+d)
a(res(223,'t').';wb(u,c=t)');                               // a9 // LD C,RES 5,(IY+d)
a(res(223,'t').';wb(u,d=t)');                               // aa // LD D,RES 5,(IY+d)
a(res(223,'t').';wb(u,e=t)');                               // ab // LD E,RES 5,(IY+d)
a(res(223,'t').';wb(u,h=t)');                               // ac // LD H,RES 5,(IY+d)
a(res(223,'t').';wb(u,l=t)');                               // ad // LD L,RES 5,(IY+d)
a(res(223,'t').';wb(u,t)');                                 // ae // RES 5,(IY+d)
a(res(223,'t').';wb(u,a=t)');                               // af // LD A,RES 5,(IY+d)
a(res(191,'t').';wb(u,b=t)');                               // b0 // LD B,RES 6,(IY+d)
a(res(191,'t').';wb(u,c=t)');                               // b1 // LD C,RES 6,(IY+d)
a(res(191,'t').';wb(u,d=t)');                               // b2 // LD D,RES 6,(IY+d)
a(res(191,'t').';wb(u,e=t)');                               // b3 // LD E,RES 6,(IY+d)
a(res(191,'t').';wb(u,h=t)');                               // b4 // LD H,RES 6,(IY+d)
a(res(191,'t').';wb(u,l=t)');                               // b5 // LD L,RES 6,(IY+d)
a(res(191,'t').';wb(u,t)');                                 // b6 // RES 6,(IY+d)
a(res(191,'t').';wb(u,a=t)');                               // b7 // LD A,RES 6,(IY+d)
a(res(127,'t').';wb(u,b=t)');                               // b8 // LD B,RES 7,(IY+d)
a(res(127,'t').';wb(u,c=t)');                               // b9 // LD C,RES 7,(IY+d)
a(res(127,'t').';wb(u,d=t)');                               // ba // LD D,RES 7,(IY+d)
a(res(127,'t').';wb(u,e=t)');                               // bb // LD E,RES 7,(IY+d)
a(res(127,'t').';wb(u,h=t)');                               // bc // LD H,RES 7,(IY+d)
a(res(127,'t').';wb(u,l=t)');                               // bd // LD L,RES 7,(IY+d)
a(res(127,'t').';wb(u,t)');                                 // be // RES 7,(IY+d)
a(res(127,'t').';wb(u,a=t)');                               // bf // LD A,RES 7,(IY+d)
a(set(1,'t').';wb(u,b=t)');                                 // c0 // LD B,SET 0,(IY+d)
a(set(1,'t').';wb(u,c=t)');                                 // c1 // LD C,SET 0,(IY+d)
a(set(1,'t').';wb(u,d=t)');                                 // c2 // LD D,SET 0,(IY+d)
a(set(1,'t').';wb(u,e=t)');                                 // c3 // LD E,SET 0,(IY+d)
a(set(1,'t').';wb(u,h=t)');                                 // c4 // LD H,SET 0,(IY+d)
a(set(1,'t').';wb(u,l=t)');                                 // c5 // LD L,SET 0,(IY+d)
a(set(1,'t').';wb(u,t)');                                   // c6 // SET 0,(IY+d)
a(set(1,'t').';wb(u,a=t)');                                 // c7 // LD A,SET 0,(IY+d)
a(set(2,'t').';wb(u,b=t)');                                 // c8 // LD B,SET 1,(IY+d)
a(set(2,'t').';wb(u,c=t)');                                 // c9 // LD C,SET 1,(IY+d)
a(set(2,'t').';wb(u,d=t)');                                 // ca // LD D,SET 1,(IY+d)
a(set(2,'t').';wb(u,e=t)');                                 // cb // LD E,SET 1,(IY+d)
a(set(2,'t').';wb(u,h=t)');                                 // cc // LD H,SET 1,(IY+d)
a(set(2,'t').';wb(u,l=t)');                                 // cd // LD L,SET 1,(IY+d)
a(set(2,'t').';wb(u,t)');                                   // ce // SET 1,(IY+d)
a(set(2,'t').';wb(u,a=t)');                                 // cf // LD A,SET 1,(IY+d)
a(set(4,'t').';wb(u,b=t)');                                 // d0 // LD B,SET 2,(IY+d)
a(set(4,'t').';wb(u,c=t)');                                 // d1 // LD C,SET 2,(IY+d)
a(set(4,'t').';wb(u,d=t)');                                 // d2 // LD D,SET 2,(IY+d)
a(set(4,'t').';wb(u,e=t)');                                 // d3 // LD E,SET 2,(IY+d)
a(set(4,'t').';wb(u,h=t)');                                 // d4 // LD H,SET 2,(IY+d)
a(set(4,'t').';wb(u,l=t)');                                 // d5 // LD L,SET 2,(IY+d)
a(set(4,'t').';wb(u,t)');                                   // d6 // SET 2,(IY+d)
a(set(4,'t').';wb(u,a=t)');                                 // d7 // LD A,SET 2,(IY+d)
a(set(8,'t').';wb(u,b=t)');                                 // d8 // LD B,SET 3,(IY+d)
a(set(8,'t').';wb(u,c=t)');                                 // d9 // LD C,SET 3,(IY+d)
a(set(8,'t').';wb(u,d=t)');                                 // da // LD D,SET 3,(IY+d)
a(set(8,'t').';wb(u,e=t)');                                 // db // LD E,SET 3,(IY+d)
a(set(8,'t').';wb(u,h=t)');                                 // dc // LD H,SET 3,(IY+d)
a(set(8,'t').';wb(u,l=t)');                                 // dd // LD L,SET 3,(IY+d)
a(set(8,'t').';wb(u,t)');                                   // de // SET 3,(IY+d)
a(set(8,'t').';wb(u,a=t)');                                 // df // LD A,SET 3,(IY+d)
a(set(16,'t').';wb(u,b=t)');                                // e0 // LD B,SET 4,(IY+d)
a(set(16,'t').';wb(u,c=t)');                                // e1 // LD C,SET 4,(IY+d)
a(set(16,'t').';wb(u,d=t)');                                // e2 // LD D,SET 4,(IY+d)
a(set(16,'t').';wb(u,e=t)');                                // e3 // LD E,SET 4,(IY+d)
a(set(16,'t').';wb(u,h=t)');                                // e4 // LD H,SET 4,(IY+d)
a(set(16,'t').';wb(u,l=t)');                                // e5 // LD L,SET 4,(IY+d)
a(set(16,'t').';wb(u,t)');                                  // e6 // SET 4,(IY+d)
a(set(16,'t').';wb(u,a=t)');                                // e7 // LD A,SET 4,(IY+d)
a(set(32,'t').';wb(u,b=t)');                                // e8 // LD B,SET 5,(IY+d)
a(set(32,'t').';wb(u,c=t)');                                // e9 // LD C,SET 5,(IY+d)
a(set(32,'t').';wb(u,d=t)');                                // ea // LD D,SET 5,(IY+d)
a(set(32,'t').';wb(u,e=t)');                                // eb // LD E,SET 5,(IY+d)
a(set(32,'t').';wb(u,h=t)');                                // ec // LD H,SET 5,(IY+d)
a(set(32,'t').';wb(u,l=t)');                                // ed // LD L,SET 5,(IY+d)
a(set(32,'t').';wb(u,t)');                                  // ee // SET 5,(IY+d)
a(set(32,'t').';wb(u,a=t)');                                // ef // LD A,SET 5,(IY+d)
a(set(64,'t').';wb(u,b=t)');                                // f0 // LD B,SET 6,(IY+d)
a(set(64,'t').';wb(u,c=t)');                                // f1 // LD C,SET 6,(IY+d)
a(set(64,'t').';wb(u,d=t)');                                // f2 // LD D,SET 6,(IY+d)
a(set(64,'t').';wb(u,e=t)');                                // f3 // LD E,SET 6,(IY+d)
a(set(64,'t').';wb(u,h=t)');                                // f4 // LD H,SET 6,(IY+d)
a(set(64,'t').';wb(u,l=t)');                                // f5 // LD L,SET 6,(IY+d)
a(set(64,'t').';wb(u,t)');                                  // f6 // SET 6,(IY+d)
a(set(64,'t').';wb(u,a=t)');                                // f7 // LD A,SET 6,(IY+d)
a(set(128,'t').';wb(u,b=t)');                               // f8 // LD B,SET 7,(IY+d)
a(set(128,'t').';wb(u,c=t)');                               // f9 // LD C,SET 7,(IY+d)
a(set(128,'t').';wb(u,d=t)');                               // fa // LD D,SET 7,(IY+d)
a(set(128,'t').';wb(u,e=t)');                               // fb // LD E,SET 7,(IY+d)
a(set(128,'t').';wb(u,h=t)');                               // fc // LD H,SET 7,(IY+d)
a(set(128,'t').';wb(u,l=t)');                               // fd // LD L,SET 7,(IY+d)
a(set(128,'t').';wb(u,t)');                                 // fe // SET 7,(IY+d)
a(set(128,'t').';wb(u,a=t)');                               // ff // LD A,SET 7,(IY+d)

a(nop(8));                                                  // 00 // NOP
a(nop(8));                                                  // 01 // NOP
a(nop(8));                                                  // 02 // NOP
a(nop(8));                                                  // 03 // NOP
a(nop(8));                                                  // 04 // NOP
a(nop(8));                                                  // 05 // NOP
a(nop(8));                                                  // 06 // NOP
a(nop(8));                                                  // 07 // NOP
a(nop(8));                                                  // 08 // NOP
a(nop(8));                                                  // 09 // NOP
a(nop(8));                                                  // 0a // NOP
a(nop(8));                                                  // 0b // NOP
a(nop(8));                                                  // 0c // NOP
a(nop(8));                                                  // 0d // NOP
a(nop(8));                                                  // 0e // NOP
a(nop(8));                                                  // 0f // NOP
a(nop(8));                                                  // 10 // NOP
a(nop(8));                                                  // 11 // NOP
a(nop(8));                                                  // 12 // NOP
a(nop(8));                                                  // 13 // NOP
a(nop(8));                                                  // 14 // NOP
a(nop(8));                                                  // 15 // NOP
a(nop(8));                                                  // 16 // NOP
a(nop(8));                                                  // 17 // NOP
a(nop(8));                                                  // 18 // NOP
a(nop(8));                                                  // 19 // NOP
a(nop(8));                                                  // 1a // NOP
a(nop(8));                                                  // 1b // NOP
a(nop(8));                                                  // 1c // NOP
a(nop(8));                                                  // 1d // NOP
a(nop(8));                                                  // 1e // NOP
a(nop(8));                                                  // 1f // NOP
a(nop(8));                                                  // 20 // NOP
a(nop(8));                                                  // 21 // NOP
a(nop(8));                                                  // 22 // NOP
a(nop(8));                                                  // 23 // NOP
a(nop(8));                                                  // 24 // NOP
a(nop(8));                                                  // 25 // NOP
a(nop(8));                                                  // 26 // NOP
a(nop(8));                                                  // 27 // NOP
a(nop(8));                                                  // 28 // NOP
a(nop(8));                                                  // 29 // NOP
a(nop(8));                                                  // 2a // NOP
a(nop(8));                                                  // 2b // NOP
a(nop(8));                                                  // 2c // NOP
a(nop(8));                                                  // 2d // NOP
a(nop(8));                                                  // 2e // NOP
a(nop(8));                                                  // 2f // NOP
a(nop(8));                                                  // 30 // NOP
a(nop(8));                                                  // 31 // NOP
a(nop(8));                                                  // 32 // NOP
a(nop(8));                                                  // 33 // NOP
a(nop(8));                                                  // 34 // NOP
a(nop(8));                                                  // 35 // NOP
a(nop(8));                                                  // 36 // NOP
a(nop(8));                                                  // 37 // NOP
a(nop(8));                                                  // 38 // NOP
a(nop(8));                                                  // 39 // NOP
a(nop(8));                                                  // 3a // NOP
a(nop(8));                                                  // 3b // NOP
a(nop(8));                                                  // 3c // NOP
a(nop(8));                                                  // 3d // NOP
a(nop(8));                                                  // 3e // NOP
a(nop(8));                                                  // 3f // NOP
a(inr('b'));                                                // 40 // IN B,(C)
a(outr('b'));                                               // 41 // OUT (C),B
a(sbchlrr('b', 'c'));                                       // 42 // SBC HL,BC
a(ldpnnrr('b', 'c', 20));                                   // 43 // LD (NN),BC
a(neg());                                                   // 44 // NEG
a(ret(14));                                                 // 45 // RETN
a('st+=8;im=0');                                            // 46 // IM 0
a(ldrr('i', 'a', 9));                                       // 47 // LD I,A
a(inr('c'));                                                // 48 // IN C,(C)
a(outr('c'));                                               // 49 // OUT (C),C
a(adchlrr('b', 'c'));                                       // 4a // ADC HL,BC
a(ldrrpnn('b', 'c', 20));                                   // 4b // LD BC,(NN)
a(neg());                                                   // 4c // NEG
a(ret(14));                                                 // 4d // RETI
a('st+=8;im=0');                                            // 4e // IM 0
a(ldrr('r=r7', 'a', 9));                                    // 4f // LD R,A
a(inr('d'));                                                // 50 // IN D,(C)
a(outr('d'));                                               // 51 // OUT (C),D
a(sbchlrr('d', 'e'));                                       // 52 // SBC HL,DE
a(ldpnnrr('d', 'e', 20));                                   // 53 // LD (NN),DE
a(neg());                                                   // 54 // NEG
a(ret(14));                                                 // 55 // RETN
a('st+=8;im=1');                                            // 56 // IM 1
a(ldair('i'));                                              // 57 // LD A,I
a(inr('e'));                                                // 58 // IN E,(C)
a(outr('e'));                                               // 59 // OUT (C),E
a(adchlrr('d', 'e'));                                       // 5a // ADC HL,DE
a(ldrrpnn('d', 'e', 20));                                   // 5b // LD DE,(NN)
a(neg());                                                   // 5c // NEG
a(ret(14));                                                 // 5d // RETI
a('st+=8;im=2');                                            // 5e // IM 2
a(ldair('r&127|r7&128'));                                   // 5f // LD A,R
a(inr('h'));                                                // 60 // IN H,(C)
a(outr('h'));                                               // 61 // OUT (C),H
a(sbchlrr('h', 'l'));                                       // 62 // SBC HL,HL
a(ldpnnrr('h', 'l', 20));                                   // 63 // LD (NN),HL
a(neg());                                                   // 64 // NEG
a(ret(14));                                                 // 65 // RETN
a('st+=8;im=0');                                            // 66 // IM 0
a('st+=18;'.                                                // 67 // RRD
  't=m[mp=l|h<<8]|a<<8;'.
  'a=a&240|t&15;'.
  'ff=ff&-256|(fr=a);'.
  'fa=a|256;'.
  'fb=0;'.
  'wb(mp,t>>4&255)'.
  ($mp?';++mp':''));
a(inr('l'));                                                // 68 // IN L,(C)
a(outr('l'));                                               // 69 // OUT (C),L
a(adchlrr('h', 'l'));                                       // 6a // ADC HL,HL
a(ldrrpnn('h', 'l', 20));                                   // 6b // LD HL,(NN)
a(neg());                                                   // 6c // NEG
a(ret(14));                                                 // 6d // RETI
a('st+=8;im=0');                                            // 6e // IM 0
a('st+=18;'.                                                // 6f // RLD
  't=m[mp=l|h<<8]<<4|a&15;'.
  'a=a&240|t>>8;'.
  'Ff=Ff&-256|(Fr=a);'.
  'Fa=a|256;'.
  'Fb=0;'.
  'wb(mp,t&255);'.
  ($mp?';++mp':''));
a(inr('t'));                                                // 70 // IN X,(C)
a(outr('0'));                                               // 71 // OUT (C),X
a('st+=15;'.                                                // 72 // SBC HL,SP
  't=('.($mp?'mp=':'').'l|h<<8)-sp-(ff>>8&1);'.
  ($mp?'++mp;':'').
  'ff=t>>8;'.
  'fa=h;'.
  'fb=~(u=sp>>8);'.
  'h=t>>8&255;'.
  'fr=u|t<<8;'.
  'l=t&255');
a('st+=20;'.                                                // 73 // LD (NN),SP
  'wb('.($mp?'mp':'t').'=m[pc++&65535]|m[pc++&65535]<<8,sp&255);'.
  'wb('.($mp?'mp=mp':'t').'+1&65535,sp>>8)');
a(neg());                                                   // 74 // NEG
a(ret(14));                                                 // 75 // RETN
a('st+=8;im=1');                                            // 76 // IM 1
a(nop(8));                                                  // 77 // NOP
a(inr('a'));                                                // 78 // IN A,(C)
a(outr('a'));                                               // 79 // OUT (C),A
a('st+=15;'.                                                // 7a // ADC HL,SP
  't=('.($mp?'mp=':'').'l|h<<8)+sp+(ff>>8&1);'.
  ($mp?'++mp;':'').
  'ff=t>>8;'.
  'fa=h;'.
  'fb=sp>>8;'.
  'h=t>>8&255;'.
  'fr=fb|t<<8;'.
  'l=t&255');
                                                            // 7b // LD SP,(NN)
a('st+=20;sp=m[t=m[pc++&65535]|m[pc++&65535]<<8]|m['.($mp?'mp=':'').'t+1&65535]<<8');
a(neg());                                                   // 7c // NEG
a(ret(14));                                                 // 7d // RETI
a('st+=8;im=2');                                            // 7e // IM 2
a(nop(8));                                                  // 7f // NOP
a(nop(8));                                                  // 80 // NOP
a(nop(8));                                                  // 81 // NOP
a(nop(8));                                                  // 82 // NOP
a(nop(8));                                                  // 83 // NOP
a(nop(8));                                                  // 84 // NOP
a(nop(8));                                                  // 85 // NOP
a(nop(8));                                                  // 86 // NOP
a(nop(8));                                                  // 87 // NOP
a(nop(8));                                                  // 88 // NOP
a(nop(8));                                                  // 89 // NOP
a(nop(8));                                                  // 8a // NOP
a(nop(8));                                                  // 8b // NOP
a(nop(8));                                                  // 8c // NOP
a(nop(8));                                                  // 8d // NOP
a(nop(8));                                                  // 8e // NOP
a(nop(8));                                                  // 8f // NOP
a(nop(8));                                                  // 90 // NOP
a(nop(8));                                                  // 91 // NOP
a(nop(8));                                                  // 92 // NOP
a(nop(8));                                                  // 93 // NOP
a(nop(8));                                                  // 94 // NOP
a(nop(8));                                                  // 95 // NOP
a(nop(8));                                                  // 96 // NOP
a(nop(8));                                                  // 97 // NOP
a(nop(8));                                                  // 98 // NOP
a(nop(8));                                                  // 99 // NOP
a(nop(8));                                                  // 9a // NOP
a(nop(8));                                                  // 9b // NOP
a(nop(8));                                                  // 9c // NOP
a(nop(8));                                                  // 9d // NOP
a(nop(8));                                                  // 9e // NOP
a(nop(8));                                                  // 9f // NOP
a(ldid(1, 0));                                              // a0 // LDI
a(cpid(1, 0));                                              // a1 // CPI
a(inid(1, 0));                                              // a2 // INI
a(otid(1, 0));                                              // a3 // OUTI
a(nop(8));                                                  // a4 // NOP
a(nop(8));                                                  // a5 // NOP
a(nop(8));                                                  // a6 // NOP
a(nop(8));                                                  // a7 // NOP
a(ldid(0, 0));                                              // a8 // LDD
a(cpid(0, 0));                                              // a9 // CPD
a(inid(0, 0));                                              // aa // IND
a(otid(0, 0));                                              // ab // OUTD
a(nop(8));                                                  // ac // NOP
a(nop(8));                                                  // ad // NOP
a(nop(8));                                                  // ae // NOP
a(nop(8));                                                  // af // NOP
a(ldid(1, 1));                                              // b0 // LDIR
a(cpid(1, 1));                                              // b1 // CPIR
a(inid(1, 1));                                              // b2 // INIR
a(otid(1, 1));                                              // b3 // OTIR
a(nop(8));                                                  // b4 // NOP
a(nop(8));                                                  // b5 // NOP
a(nop(8));                                                  // b6 // NOP
a(nop(8));                                                  // b7 // NOP
a(ldid(0, 1));                                              // b8 // LDDR
a(cpid(0, 1));                                              // b9 // CPDR
a(inid(0, 1));                                              // ba // INDR
a(otid(0, 1));                                              // bb // OTDR
a(nop(8));                                                  // bc // NOP
a(nop(8));                                                  // bd // NOP
a(nop(8));                                                  // be // NOP
a(nop(8));                                                  // bf // NOP
a(nop(8));                                                  // c0 // NOP
a(nop(8));                                                  // c1 // NOP
a(nop(8));                                                  // c2 // NOP
a(nop(8));                                                  // c3 // NOP
a(nop(8));                                                  // c4 // NOP
a(nop(8));                                                  // c5 // NOP
a(nop(8));                                                  // c6 // NOP
a(nop(8));                                                  // c7 // NOP
a(nop(8));                                                  // c8 // NOP
a(nop(8));                                                  // c9 // NOP
a(nop(8));                                                  // ca // NOP
a(nop(8));                                                  // cb // NOP
a(nop(8));                                                  // cc // NOP
a(nop(8));                                                  // cd // NOP
a(nop(8));                                                  // ce // NOP
a(nop(8));                                                  // cf // NOP
a(nop(8));                                                  // d0 // NOP
a(nop(8));                                                  // d1 // NOP
a(nop(8));                                                  // d2 // NOP
a(nop(8));                                                  // d3 // NOP
a(nop(8));                                                  // d4 // NOP
a(nop(8));                                                  // d5 // NOP
a(nop(8));                                                  // d6 // NOP
a(nop(8));                                                  // d7 // NOP
a(nop(8));                                                  // d8 // NOP
a(nop(8));                                                  // d9 // NOP
a(nop(8));                                                  // da // NOP
a(nop(8));                                                  // db // NOP
a(nop(8));                                                  // dc // NOP
a(nop(8));                                                  // dd // NOP
a(nop(8));                                                  // de // NOP
a(nop(8));                                                  // df // NOP
a(nop(8));                                                  // e0 // NOP
a(nop(8));                                                  // e1 // NOP
a(nop(8));                                                  // e2 // NOP
a(nop(8));                                                  // e3 // NOP
a(nop(8));                                                  // e4 // NOP
a(nop(8));                                                  // e5 // NOP
a(nop(8));                                                  // e6 // NOP
a(nop(8));                                                  // e7 // NOP
a(nop(8));                                                  // e8 // NOP
a(nop(8));                                                  // e9 // NOP
a(nop(8));                                                  // ea // NOP
a(nop(8));                                                  // eb // NOP
a(nop(8));                                                  // ec // NOP
a(nop(8));                                                  // ed // NOP
a(nop(8));                                                  // ee // NOP
a(nop(8));                                                  // ef // NOP
a(nop(8));                                                  // f0 // NOP
a(nop(8));                                                  // f1 // NOP
a(nop(8));                                                  // f2 // NOP
a(nop(8));                                                  // f3 // NOP
a(nop(8));                                                  // f4 // NOP
a(nop(8));                                                  // f5 // NOP
a(nop(8));                                                  // f6 // NOP
a(nop(8));                                                  // f7 // NOP
a(nop(8));                                                  // f8 // NOP
a(nop(8));                                                  // f9 // NOP
a(nop(8));                                                  // fa // NOP
a(nop(8));                                                  // fb // NOP
a('loadblock()');                                           // fc // tape loader trap
a(nop(8));                                                  // fd // NOP
a(nop(8));                                                  // fe // NOP
a(nop(8));                                                  // ff // NOP
?>
];