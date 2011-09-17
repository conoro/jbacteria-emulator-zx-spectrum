<?
$mp= $m?$m:$_GET['m'];
$pag= $p?$p:$_GET['p'];
$cpc= $c?$c:$_GET['c'];
?>

function z80interrupt() {
  if(iff){
    if(halted)
      pc++,
      halted= 0;
    iff= 0;
<?if($pag){?>
    mw[sp-1>>14&3][sp-1&16383]= pc >> 8 & 255;
    mw[(sp=sp-2&65535)>>14][sp&16383]= pc & 255;
<?}else{?>
    wb(sp-1&65535, pc >> 8 & 255);
    wb(sp=sp-2&65535, pc & 255);
<?}?>
    r++;
    switch(im) {
      case 1:
        st++;
      case 0: 
        pc= 56;
        st+= <?=$cpc?3:12?>;
        break;
      default:
<?if($pag){?>
        t= 255 | i << 8;
        pc= m[t>>14][t&16383] | m[++t>>14][t&16383] << 8;
<?}else{?>
        pc= m[t= 255 | i << 8] | m[++t&65535] << 8;
<?}?>
        st+= <?=$cpc?5:19?>;
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

function f_() {
  return fa_ & 256
      ? ff_ & 168 | ff_ >> 8 & 1 | !fr_ << 6 | fb_ >> 8 & 2 | (fr_ ^ fa_ ^ fb_ ^ fb_ >> 8) & 16
        | 154020 >> ((fr_ ^ fr_ >> 4) & 15) & 4
      : ff_ & 168 | ff_ >> 8 & 1 | !fr_ << 6 | fb_ >> 8 & 2 | (fr_ ^ fa_ ^ fb_ ^ fb_ >> 8) & 16
        | ((fr_ ^ fa_) & (fr_ ^ fb_)) >> 5 & 4;
}

function setf(a) {
  fr= ~a & 64;
  ff= a|= a<<8;
  fa= 255 & (fb= a & -129 | (a&4)<<5);
}

function setf_(a) {
  fr_= ~a & 64;
  ff_= a|= a<<8;
  fa_= 255 & (fb_= a & -129 | (a&4)<<5);
}

<?

if(!function_exists('a')){
function a($a){
  echo 'function(){'.$a."},\n";
}

function b($a, $b){
  echo $a.'=function(){'.$b."},\n";
}

function c($a){
  echo $a.",\n";
}

function nop($n){
  return $n-1?'st+='.$n:'++st';
}

function inc($r) {
  global $cpc;
  return ($cpc?'++st;':'st+=4;').
  'ff=ff&256|(fr='.$r.'=(fa='.$r.')+(fb=1)&255)';
}

function dec($r) {
  global $cpc;
  return ($cpc?'++st;':'st+=4;').
  'ff=ff&256|(fr='.$r.'=(fa='.$r.')+(fb=-1)&255)';
}

function incdecphl($n) {
  global $pag, $cpc;
  return 'st+='.($cpc?3:11).';'.
  ($pag
    ? 'fa=m[t=h>>6][u=l|h<<8&16383];'.
      'ff=ff&256|(mw[t][u]=fr=fa+(fb='.($n=='+'?'':'-').'1)&255)'
    : 'fa=m[t=l|h<<8];'.
      'ff=ff&256|(fr=fa+(fb='.($n=='+'?'':'-').'1)&255);'.
      'wb(t,fr)');
}

function incdecpi($a, $b) {
  global $pag, $cpc;
  return 'st+='.($cpc?5:19).';'.
  ($pag
    ? 't=((m[pc>>14&3][pc++&16383]^128)-128+('.$a.'l|'.$a.'h<<8))&65535;'.
      'fa=m[u=t>>14][t&=16383];'.
      'ff=ff&256|(mw[u][t]=fr=fa+(fb='.($b=='+'?'':'-').'1)&255)'
    : 'fa=m[t=((m[pc++&65535]^128)-128+('.$a.'l|'.$a.'h<<8))&65535];'.
      'ff=ff&256|(fr=fa+(fb='.($b=='+'?'':'-').'1)&255);'.
      'wb(t,fr)');
}

function incw($a, $b) {
  global $cpc;
  return 'st+='.($cpc?2:6).';'.
  '++'.$b.'==256&&('.
                    $b.'=0,'.
                    $a.'='.$a.'+1&255)';
}

function decw($a, $b) {
  global $cpc;
  return 'st+='.($cpc?2:6).';'.
  '--'.$b.'<0&&('.
                $a.'='.$a.'-1&('.$b.'=255))';
}

function ldpr($a, $b, $r, $t) {
  global $pag, $cpc;
  return 'st+='.($cpc?2:7).';'.
          ($pag
            ? 'mw['.$a.'>>6]['.$b.'|'.$a.'<<8&16383]='.$r
            : 'wb('.$b.'|'.$a.'<<8,'.$r.')').
          ($t?';mp='.$b.'+1&255|a<<8':'');
}

function ldpri($a, $b) {
  global $pag, $cpc;
  return 'st+='.($cpc?4:15).';'.
          ($pag
            ? 't=((m[pc>>14&3][pc++&16383]^128)-128+('.$b.'l|'.$b.'h<<8))&65535;'.
              'mw[t>>14][t&16383]='.$a
            : 'wb(((m[pc++&65535]^128)-128+('.$b.'l|'.$b.'h<<8))&65535,'.$a.')');
}

function ldrp($a, $b, $r, $t) {
  global $pag, $cpc;
  return 'st+='.($cpc?2:7).';'.
          ($pag
            ? $r.'=m['.($t?'(mp='.$b.'|'.$a.'<<8)>>14][mp':$a.'>>6]['.$b.'|'.$a.'<<8').'&16383]'
            : $r.'=m['.($t?'mp=':'').$b.'|'.$a.'<<8]').
          ($t?';++mp':'');
}

function ldrpi($a, $b) {
  global $pag, $cpc;
  return 'st+='.($cpc?4:15).';'.
          ($pag
            ? 't=((m[pc>>14&3][pc++&16383]^128)-128+('.$b.'l|'.$b.'h<<8))&65535;'.
              $a.'=m[t>>14][t&16383]'
            : $a.'=m[((m[pc++&65535]^128)-128+('.$b.'l|'.$b.'h<<8))&65535]');
}

function ldrrim($a, $b) {
  global $pag, $cpc;
  return 'st+='.($cpc?3:10).';'.
          ($pag
            ? $b.'=m[pc>>14&3][pc++&16383];'.
              $a.'=m[pc>>14&3][pc++&16383]'
            : $b.'=m[pc++&65535];'.
              $a.'=m[pc++&65535]');
}

function ldrim($r) {
  global $pag, $cpc;
  return 'st+='.($cpc?2:7).';'.
          ($pag
            ? $r.'=m[pc>>14&3][pc++&16383]'
            : $r.'=m[pc++&65535]');
}

function ldpin($r) {
  global $pag, $cpc;
  return 'st+='.($cpc?5:15).';'.
          ($pag
            ? 't=((m[pc>>14&3][pc++&16383]^128)-128+('.$r.'l|'.$r.'h<<8))&65535;'.
              'mw[t>>14][t&16383]=m[pc>>14&3][pc++&16383]'
            : 'wb(((m[pc++&65535]^128)-128+('.$r.'l|'.$r.'h<<8))&65535, m[pc++&65535])');
}

function addrrrr($a, $b, $c, $d) {
  global $mp, $cpc;
  return 'st+='.($cpc?3:11).';'.
  't='.$b.'+'.$d.'+('.$a.'+'.$c.'<<8);'.
  'ff=ff&128|t>>8&296;fb=fb&128|(t>>8^'.$a.'^'.$c.'^fr^fa)&16;'.
  ($mp?'mp='.$b.'+1+('.$a.'<<8);':'').
  $a.'=t>>8&255;'.
  $b.'=t&255';
}

function addisp($r) {
  global $mp, $cpc;
  return 'st+='.($cpc?3:11).';'.
  't=sp+('.$r.'l|'.$r.'h<<8);'.
  'ff=ff&128|t>>8&296;'.
  'fb=fb&128|(t>>8^sp>>8^'.$r.'h^fr^fa)&16;'.
  ($mp?'mp='.$r.'l+1+('.$r.'h<<8);':'').
  $r.'h=t>>8&255;'.
  $r.'l=t&255';
}

function jrc($c) {
  global $pag, $cpc;
  return 'if('.$c.')'.
    'st+='.($cpc?2:7).','.
    'pc++;'.
  'else '.
    'st+='.($cpc?3:12).','.
($pag
  ? 'pc+=(m[pc>>14&3][pc++&16383]^128)-127'
  : 'pc+=(m[pc&65535]^128)-127');
}

function jrci($c) {
  global $pag, $cpc;
  return 'if('.$c.')'.
    'st+='.($cpc?3:12).','.
($pag
  ? 'pc+=(m[pc>>14&3][pc++&16383]^128)-127;'
  : 'pc+=(m[pc&65535]^128)-127;').
  'else '.
    'st+='.($cpc?2:7).','.
    'pc++';
}

function jpc($c) {
  global $pag, $cpc;
  return 'st+='.($cpc?3:10).';'.
  'if('.$c.')'.
    'pc+=2;'.
  'else '.
($pag
  ? 'pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8'
  : 'pc=m[pc&65535]|m[pc+1&65535]<<8');
}

function jpci($c) {
  global $pag, $cpc;
  return 'st+='.($cpc?3:10).';'.
  'if('.$c.')'.
($pag
  ? 'pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8;'
  : 'pc=m[pc&65535]|m[pc+1&65535]<<8;').
  'else '.
    'pc+=2';
}

function callc($c) {
  global $mp, $pag, $cpc;
  return 'if('.$c.')'.
    'st+='.($cpc?3:10).','.
    'pc+=2;'.
  'else '.
    'st+='.($cpc?5:17).','.
    't=pc+2,'.
    ($mp?'mp=':'').
($pag
  ? 'pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8,'.
    'mw[--sp>>14&3][sp&16383]=t>>8&255,'.
    'mw[(sp=sp-1&65535)>>14][sp&16383]=t&255'
  : 'pc=m[pc&65535]|m[pc+1&65535]<<8,'.
    'wb(--sp&65535,t>>8&255),'.
    'wb(sp=sp-1&65535,t&255)');
}

function callci($c) {
  global $mp, $pag, $cpc;
  return 'if('.$c.')'.
    'st+='.($cpc?5:17).','.
    't=pc+2,'.
    ($mp?'mp=':'').
($pag
  ? 'pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8,'.
    'mw[--sp>>14&3][sp&16383]=t>>8&255,'.
    'mw[(sp=sp-1&65535)>>14][sp&16383]=t&255;'
  : 'pc=m[pc&65535]|m[pc+1&65535]<<8,'.
    'wb(--sp&65535,t>>8&255),'.
    'wb(sp=sp-1&65535,t&255);').
  'else '.
    'st+='.($cpc?3:10).','.
    'pc+=2';
}

function retc($c) {
  global $mp, $pag;
  return 'if('.$c.')'.
    'st+='.($cpc?2:5).';'.
  'else '.
    'st+='.($cpc?4:11).','.
    ($mp?'mp=':'').
($pag
  ? 'pc=m[sp>>14][sp&16383]|m[sp+1>>14&3][sp+1&16383]<<8,'
  : 'pc=m[sp]|m[sp+1&65535]<<8,').
    'sp=sp+2&65535';
}

function retci($c) {
  global $mp, $pag;
  return 'if('.$c.')'.
    'st+='.($cpc?4:11).','.
    ($mp?'mp=':'').
($pag
  ? 'pc=m[sp>>14][sp&16383]|m[sp+1>>14&3][sp+1&16383]<<8,'
  : 'pc=m[sp]|m[sp+1&65535]<<8,').
    'sp=sp+2&65535;'.
  'else '.
    'st+='.($cpc?2:5);
}

function ret($n){
  global $mp, $pag;
  return 'st+='.$n.';'.
  ($mp?'mp=':'').
($pag
  ? 'pc=m[sp>>14][sp&16383]|m[sp+1>>14&3][sp+1&16383]<<8;'
  : 'pc=m[sp]|m[sp+1&65535]<<8;').
  'sp=sp+2&65535';
}

function ldpnnrr($a, $b, $n) {
  global $mp, $pag;
  return 'st+='.$n.';'.
($pag
  ? 'mw[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383]='.$b.';'.
    'mw['.($mp?'(mp=t+1)>>14&3][mp':'t+1>>14&3][t+1').'&16383]='.$a
  : 'wb(t=m[pc++&65535]|m[pc++&65535]<<8,'.$b.');'.
    'wb('.($mp?'mp=':'').'t+1&65535,'.$a.')');
}

function ldrrpnn($a, $b, $n) {
  global $mp, $pag;
  return 'st+='.$n.';'.
($pag
  ? $b.'=m[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383];'.
    $a.'=m['.($mp?'(mp=t+1)>>14&3][mp':'t+1>>14&3][t+1').'&16383]'
  : $b.'=m[t=m[pc++&65535]|m[pc++&65535]<<8];'.
    $a.'=m['.($mp?'mp=':'').'t+1&65535]');
}

function ldrr($a, $b, $n){
  return ($n-1?'st+='.$n:'++st').';'.
  $a.'='.$b;
}

function add($a, $n){
  return ($n-1?'st+='.$n:'++st').
  ';a=fr=(ff=(fa=a)+(fb='.$a.'))&255';
}

function adc($a, $n){
  return ($n-1?'st+='.$n:'++st').
  ';a=fr=(ff=(fa=a)+(fb='.$a.')+(ff>>8&1))&255';
}

function sub($a, $n){
  return ($n-1?'st+='.$n:'++st').
  ';a=fr=(ff=(fa=a)+(fb=~'.$a.')+1)&255';
}

function sbc($a, $n){
  return ($n-1?'st+='.$n:'++st').
  ';a=fr=(ff=(fa=a)+(fb=~'.$a.')+(ff>>8&1^1))&255';
}

function anda($r, $n){
  return ($n-1?'st+='.$n:'++st').
  ';fa=~(a=ff=fr=a&'.$r.');fb=0';
}

function xoror($r, $n){
  return ($n-1?'st+='.$n:'++st').
  ';fa=(ff=fr=a'.$r.')|256;fb=0';
}

function cp($a, $n){
  return ($n-1?'st+='.$n:'++st').
  ';fr=(fa=a)-'.$a.';fb=~'.$a.';ff=fr&-41|'.$a.'&40;fr&=255';
}

function push($a, $b){
  global $pag, $cpc;
  return 'st+='.($cpc?4:11).';'.
($pag
  ? 'mw[--sp>>14&3][sp&16383]='.$a.';'.
    'mw[(sp=sp-1&65535)>>14][sp&16383]='.$b
  : 'wb(--sp&65535,'.$a.');'.
    'wb(sp=sp-1&65535,'.$b.')');
}

function pop($a, $b){
  global $pag, $cpc;
  return 'st+='.($cpc?3:10).';'.
($pag
  ? $b.'=m[sp>>14][sp&16383];'.
    $a.'=m[sp+1>>14&3][sp+1&16383];'
  : $b.'=m[sp];'.
    $a.'=m[sp+1&65535];').
  'sp=sp+2&65535';
}

function popaf(){
  global $pag, $cpc;
  return 'st+='.($cpc?3:10).';'.
($pag
  ? 'setf(m[sp>>14][sp&16383]);'.
    'a=m[sp+1>>14&3][sp+1&16383];'
  : 'setf(m[sp]);'.
    'a=m[sp+1&65535];').
  'sp=sp+2&65535';
}

function rst($n){
  global $mp, $pag, $cpc;
  return 'st+='.($cpc?4:11).';'.
($pag
  ? 'mw[--sp>>14&3][sp&16383]=pc>>8&255;'.
    'mw[(sp=sp-1&65535)>>14][sp&16383]=pc&255;'
  : 'wb(--sp&65535,pc>>8&255);'.
    'wb(sp=sp-1&65535,pc&255);').
  ($mp?'mp=':'').'pc='.$n;
}

function rlc($r){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  $r.'='.$r.'*257>>7;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function rrc($r){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  $r.'='.$r.'>>1|(('.$r.'&1)+1^1)<<7;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function rl($r){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  $r.'='.$r.'<<1|ff>>8&1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function rr($r){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  $r.'=('.$r.'*513|ff&256)>>1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function sla($r){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  $r.'<<=1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function sra($r){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  $r.'=('.$r.'*513+128^128)>>1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function sll($r){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  $r.'='.$r.'<<1|1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function srl($r){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  $r.'='.$r.'*513>>1;'.
  'fa=256|(fr='.$r.'=(ff='.$r.')&255);'.
  'fb=0';
}

function bit($n, $r){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  'ff=ff&-256|'.$r.'&40|(fr='.$r.'&'.$n.');'.
  'fa=~fr;'.
  'fb=0';
}

function biti($n){
  global $mp, $cpc;
  return ($cpc?'++st;':'st+=5;').
  'ff=ff&-256|'.($mp?'mp>>8&40|-41&':'').'(t&='.$n.');'.
  'fa=~(fr=t);'.
  'fb=0';
}

function bithl($n){
  global $mp, $pag, $cpc;
  return 'st+='.($cpc?3:12).';'.
($pag
  ? 't=m[h>>6][l|h<<8&16383];'
  : 't=m[l|h<<8];').
  'ff=ff&-256|'.($mp?'mp>>8&40|-41&':'').'(t&='.$n.');'.
  'fa=~(fr=t);'.
  'fb=0';
}

function res($n, $r){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  $r.'&='.$n;
}

function reshl($n){
  global $pag, $cpc;
  return 'st+='.($cpc?4:15).';'.
($pag
  ? 'mw[t=h>>6][u=l|h<<8&16383]=m[t][u]&'.$n
  : 'wb(t=l|h<<8,m[t]&'.$n.')');
}

function set($n, $r){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  $r.'|='.$n;
}

function sethl($n){
  global $pag, $cpc;
  return 'st+='.($cpc?4:15).';'.
($pag
  ? 'mw[t=h>>6][u=l|h<<8&16383]=m[t][u]|'.$n
  : 'wb(t=l|h<<8,m[t]|'.$n.')');
}

function inr($r){
  global $mp, $cpc;
  return 'st+='.($cpc?4:12).';'.
  $r.'=rp('.($mp?'mp=':'').'b<<8|c);'.
  ($mp?'++mp;':'').
  'ff=ff&-256|(fr='.$r.');'.
  'fa='.$r.'|256;'.
  'fb=0';
}

function outr($r){
  global $mp, $cpc;
  return 'st+='.($cpc?3:12).';'.
  'wp('.($mp?'mp=':'').'c|b<<8,'.$r.')'.
  ($mp?';++mp':'');
}

function sbchlrr($a, $b) {
  global $mp, $cpc;
  return 'st+='.($cpc?4:15).';'.
  't='.($a=='h'?'':'l-'.$b.'+(h-'.$a.'<<8)').'-(ff>>8&1);'.
  ($mp?'mp=l+1+(h<<8);':'').
  'ff=t>>8;'.
  'fa=h;'.
  'fb=~'.$a.';'.
  'h=t>>8&255;'.
  'l=t&255;'.
  'fr=h|l<<8';
}

function adchlrr($a, $b) {
  global $mp, $cpc;
  return 'st+='.($cpc?4:15).';'.
  't=l+'.$b.'+(h+'.$a.'<<8)+(ff>>8&1);'.
  ($mp?'mp=l+1+(h<<8);':'').
  'ff=t>>8;'.
  'fa=h;'.
  'fb='.$a.';'.
  'h=t>>8&255;'.
  'l=t&255;'.
  'fr=h|l<<8';
}

function neg(){
  global $cpc;
  return 'st+='.($cpc?2:8).';'.
  'a=fr=(ff=(fb=~a)+1)&255;fa=0';
}

function ldair($r){
  global $cpc;
  return 'st+='.($cpc?3:9).';'.
  'ff=ff&-256|(a='.$r.');'.
  'fr=+!!'.$r.';'.
  'fa=fb=iff<<7&128';
}

function ldid($i, $r){
  global $mp, $pag, $cpc;
  return 'st+='.($cpc?5:16).';'.
($pag
  ? 't=mw[d>>6][e|d<<8&16383]=m[h>>6][l|h<<8&16383];'
  : 'wb(e|d<<8,t=m[l|h<<8]);').
  ($i ? '++l==256&&(l=0,h=h+1&255);++e==256&&(e=0,d=d+1&255);'
      : '--l<0&&(h=h-1&(l=255));--e<0&&(d=d-1&(e=255));').
  '--c<0&&(b=b-1&(c=255));'.
  'fr&&(fr=1);'.
  't+=a;'.
  'ff=ff&-41|t&8|t<<4&32;'.
  'fa=0;'.
  'b|c&&(fa=128'.
  ($r ? ','.($cpc?'++st':'st+=5').','.($mp?'mp=--pc,--pc':'pc-=2') : '').
  ');fb=fa';
}

function cpid($i, $r){
  global $mp, $pag, $cpc;
  return 'st+='.($cpc?4:16).';'.
($pag
  ? 'u=a-(t=m[h>>6][l|h<<8&16383])&255;'
  : 'u=a-(t=m[l|h<<8])&255;').
  ($i ? '++l==256&&(l=0,h=h+1&255);'
      : '--l<0&&(h=h-1&(l=255));').
  '--c<0&&(b=b-1&(c=255));'.
  ($mp?($i ? '++mp;':'--mp;'):'').
  'fr=u&127|u>>7;'.
  'fb=~(t|128);'.
  'fa=a&127;'.
  'b|c&&(fa|=128,fb|=128'.
  ($r ? ',u&&('.($cpc?'++st':'st+=5').','.($mp?'mp=--pc,--pc)':'pc-=2)') : '').
  ');ff=ff&-256|u&-41;'.
  '(u^t^a)&16&&u--;'.
  'ff|=u<<4&32|u&8';
}

function inid($i, $r){
  global $mp, $pag, $cpc;
  return 'st+='.($cpc?5:16).';'.
($pag
  ? 't=mw[h>>6][l|h<<8&16383]=rp('.($mp?'mp=':'').'c|b<<8);'
  : 'wb(l|h<<8,t=rp('.($mp?'mp=':'').'c|b<<8));').
  ($i ? '++l==256&&(l=0,h=h+1&255);'
      : '--l<0&&(h=h-1&(l=255));').
  'b=b-1&255;'.
  ($mp?($i?'++mp;':'--mp;'):'').
  'u=t+(c'.($i?'+':'-').'1&255);'.
  ($r?'b&&('.($cpc?'++st':'st+=5').','.($mp?'mp=--pc,--pc);':'pc-=2);'):'').
  'fb=u&7^b;'.
  'ff=b|(u&=256);'.
  'fa=(fr=b)^128;'.
  'fb=(4928640>>((fb^fb>>4)&15)^b)&128|u>>4|(t&128)<<2';
}

function otid($i, $r){
  global $mp, $pag, $cpc;
  return 'st+='.($cpc?4:16).';'.
  'b=b-1&255;'.
($pag
  ? 'wp('.($mp?'mp=':'').'c|b<<8,t=m[h>>6][l|h<<8&16383]);'
  : 'wp('.($mp?'mp=':'').'c|b<<8,t=m[l|h<<8]);').
  ($mp?($i?'++mp;':'--mp;'):'').
  ($i ? '++l==256&&(l=0,h=h+1&255);'
      : '--l<0&&(h=h-1&(l=255));').
  'u=t+l;'.
  ($r?'b&&('.($cpc?'++st':'st+=5').','.($mp?'mp=--pc,--pc);':'pc-=2);'):'').
  'fb=u&7^b;'.
  'ff=b|(u&=256);'.
  'fa=(fr=b)^128;'.
  'fb=(4928640>>((fb^fb>>4)&15)^b)&128|u>>4|(t&128)<<2';
}

function exspi($r){
  global $mp, $pag, $cpc;
  return 'st+='.($cpc?6:19).';'.
($pag
  ? 'v=m[t=sp>>14][u=sp&16383];'.
    'mw[t][u]='.$r.'l;'.
    $r.'l=v;'.
    'v=m[t=sp+1>>14&3][u=sp+1&16383];'.
    'mw[t][u]='.$r.'h;'.
    $r.'h=v'
  : 't=m[sp];'.
    'wb(sp,'.$r.'l);'.
    $r.'l=t;'.
    't=m[sp+1&65535];'.
    'wb(sp+1&65535,'.$r.'h);'.
    $r.'h=t').
  ($mp?';mp='.$r.'l|'.$r.'h<<8':'');
}

function ldsppci($a, $b){
  global $cpc;
  return ($cpc
            ? ($a=='sp'?'st+=2;':'++st;')
            : ($a=='sp'?'st+=6;':'st+=4;')).
  $a.'='.$b.'l|'.$b.'h<<8';
}}

echo 'g=[';
b('o00', nop($cpc?1:4));                                    // 00 // NOP
b('o01', ldrrim('b', 'c'));                                 // 01 // LD BC,nn
b('o02', ldpr('b', 'c', 'a', $mp));                         // 02 // LD (BC),A
b('o03', incw('b', 'c'));                                   // 03 // INC BC
b('o04', inc('b'));                                         // 04 // INC B
b('o05', dec('b'));                                         // 05 // DEC B
b('o06', ldrim('b'));                                       // 06 // LD B,n
                                                            // 07 // RLCA
b('o07', ($cpc?'++st':'st+=4').';a=a*257>>7;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
                                                            // 08 // EX AF,AF'
b('o08', ($cpc?'++st':'st+=4').';t=a_;a_=a;a=t;t=ff_;ff_=ff;ff=t;t=fr_;fr_=fr;fr=t;t=fa_;fa_=fa;fa=t;t=fb_;fb_=fb;fb=t');
a(addrrrr('h', 'l', 'b', 'c'));                             // 09 // ADD HL,BC
b('o0a', ldrp('b', 'c', 'a', $mp));                         // 0A // LD A,(BC)
b('o0b', decw('b', 'c'));                                   // 0B // DEC BC
b('o0c', inc('c'));                                         // 0C // INC C
b('o0d', dec('c'));                                         // 0D // DEC C
b('o0e', ldrim('c'));                                       // 0E // LD C,n
                                                            // 0F // RRCA
b('o0f', ($cpc?'++st':'st+=4').';a=a>>1|((a&1)+1^1)<<7;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
b('o10',                                                    // 10 // DJNZ
  'if(b=b-1&255)'.
    'st+='.($cpc?4:13).','.
    ($mp?'mp=':'').
($pag
  ? 'pc+=(m[pc>>14&3][pc&16383]^128)-127;'
  : 'pc+=(m[pc&65535]^128)-127;').
  'else st+='.($cpc?3:8).',pc++');
b('o11', ldrrim('d', 'e'));                                 // 11 // LD DE,nn
b('o12', ldpr('d', 'e', 'a', $mp));                         // 12 // LD (DE),A
b('o13', incw('d', 'e'));                                   // 13 // INC DE
b('o14', inc('d'));                                         // 14 // INC D
b('o15', dec('d'));                                         // 15 // DEC D
b('o16', ldrim('d'));                                       // 16 // LD D,n
                                                            // 17 // RLA
b('o17', ($cpc?'++st':'st+=4').';a=a<<1|ff>>8&1;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
b('o18', 'st+='.($cpc?3:12).';'.                            // 18 // JR
  ($mp?'mp=':'').
($pag
  ? 'pc+=(m[pc>>14&3][pc&16383]^128)-127'
  : 'pc+=(m[pc&65535]^128)-127'));
a(addrrrr('h', 'l', 'd', 'e'));                             // 19 // ADD HL,DE
b('o1a', ldrp('d', 'e', 'a', $mp));                         // 1A // LD A,(DE)
b('o1b', decw('d', 'e'));                                   // 1B // DEC DE
b('o1c', inc('e'));                                         // 1C // INC E
b('o1d', dec('e'));                                         // 1D // DEC E
b('o1e', ldrim('e'));                                       // 1E // LD E,n
                                                            // 1F // RRA
b('o1f', ($cpc?'++st':'st+=4').';a=(a*513|ff&256)>>1;ff=ff&215|a&296;fb=fb&128|(fa^fr)&16;a&=255');
b('o20', jrci('fr'));                                       // 20 // JR NZ,s8
a(ldrrim('h', 'l'));                                        // 21 // LD HL,nn
a(ldpnnrr('h', 'l', $cpc?5:16));                            // 22 // LD (nn),HL
a(incw('h', 'l'));                                          // 23 // INC HL
a(inc('h'));                                                // 24 // INC H
a(dec('h'));                                                // 25 // DEC H
a(ldrim('h'));                                              // 26 // LD H,n
                                                            // 27 // DAA
b('o27', ($cpc?'++st':'st+=4').';t=(fr^fa^fb^fb>>8)&16;u=0;(a|ff&256)>153&&(u=352);(a&15|t)>9&&(u+=6);fa=a|256;fb&512?(a-=u,fb=~u):a+=fb=u,ff=(fr=a&=255)|u&256');
b('o28', jrc('fr'));                                        // 28 // JR Z,s8
a(addrrrr('h', 'l', 'h', 'l'));                             // 29 // ADD HL,HL
a(ldrrpnn('h', 'l', $cpc?5:16));                            // 2a // LD HL,(nn)
a(decw('h', 'l'));                                          // 2b // DEC HL
a(inc('l'));                                                // 2c // INC L
a(dec('l'));                                                // 2d // DEC L
a(ldrim('l'));                                              // 2e // LD L,n
b('o2f', ($cpc?'++st':'st+=4').';ff=ff&-41|(a^=255)&40;fb|=-129;fa=fa&-17|~fr&16');// CPL
b('o30', jrc('ff&256'));                                    // 30 // JR NC,s8
b('o31', 'st+='.($cpc?3:10).';'.                            // 31 // LD SP,nn
($pag
  ? 'sp=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8'
  : 'sp=m[pc++&65535]|m[pc++&65535]<<8'));
b('o32', 'st+='.($cpc?4:13).';'.                            // 32 // LD (nn),A
($pag
  ? 'mw[(t=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][t&16383]=a'
  : 'wb('.($mp?'t=':'').'m[pc++&65535]|m[pc++&65535]<<8,a)').
  ($mp?';mp=t+1&255|a<<8':''));
b('o33', 'st+='.($cpc?2:6).';sp=sp+1&65535');               // 33 // INC SP
a(incdecphl('+'));                                          // 34 // INC (HL)
a(incdecphl('-'));                                          // 35 // DEC (HL)
a('st+='.($cpc?3:10).';'.                                   // 36 // LD (HL),n
($pag
  ? 'mw[h>>6][l|h<<8&16383]=m[pc>>14&3][pc++&16383]'
  : 'wb(l|h<<8,m[pc++&65535])'));
b('o37', ($cpc?'++st':'st+=4').                             // 37 // SCF
  ';fb=fb&128|(fr^fa)&16;ff=256|ff&128|a&40');
b('o38', jrci('ff&256'));                                   // 38 // JR C,s8
a(addisp(''));                                              // 39 // ADD HL,SP
b('o3a', 'st+='.($cpc?4:13).';'.                            // 3a // LD A,(nn)
($pag
  ? 'a=m[(mp=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][mp&16383]'
  : 'a=m['.($mp?'mp=':'').'m[pc++&65535]|m[pc++&65535]<<8]').
  ($mp?';++mp':''));
b('o3b', 'st+='.($cpc?2:6).';sp=sp-1&65535');               // 3b // DEC SP
b('o3c', inc('a'));                                         // 3c // INC A
b('o3d', dec('a'));                                         // 3d // DEC A
b('o3e', ldrim('a'));                                       // 3e // LD A,n
b('o3f', ($cpc?'++st':'st+=4').                             // 3f // CCF
  ';fb=fb&128|(ff>>4^fr^fa)&16;ff=~ff&256|ff&128|a&40');
c('o00');                                                   // 40 // LD B,B
b('o41', ldrr('b', 'c', $cpc?1:4));                         // 41 // LD B,C
b('o42', ldrr('b', 'd', $cpc?1:4));                         // 42 // LD B,D
b('o43', ldrr('b', 'e', $cpc?1:4));                         // 43 // LD B,E
a(ldrr('b', 'h', $cpc?1:4));                                // 44 // LD B,H
a(ldrr('b', 'l', $cpc?1:4));                                // 45 // LD B,L
a(ldrp('h', 'l', 'b', 0));                                  // 46 // LD B,(HL)
b('o47', ldrr('b', 'a', $cpc?1:4));                         // 47 // LD B,A
b('o48', ldrr('c', 'b', $cpc?1:4));                         // 48 // LD C,B
c('o00');                                                   // 49 // LD C,C
b('o4a', ldrr('c', 'd', $cpc?1:4));                         // 4a // LD C,D
b('o4b', ldrr('c', 'e', $cpc?1:4));                         // 4b // LD C,E
a(ldrr('c', 'h', $cpc?1:4));                                // 4c // LD C,H
a(ldrr('c', 'l', $cpc?1:4));                                // 4d // LD C,L
a(ldrp('h', 'l', 'c', 0));                                  // 4e // LD C,(HL)
b('o4f', ldrr('c', 'a', $cpc?1:4));                         // 4f // LD C,A
b('o50', ldrr('d', 'b', $cpc?1:4));                         // 50 // LD D,B
b('o51', ldrr('d', 'c', $cpc?1:4));                         // 51 // LD D,C
c('o00');                                                   // 52 // LD D,D
b('o53', ldrr('d', 'e', $cpc?1:4));                         // 53 // LD D,E
a(ldrr('d', 'h', $cpc?1:4));                                // 54 // LD D,H
a(ldrr('d', 'l', $cpc?1:4));                                // 55 // LD D,L
a(ldrp('h', 'l', 'd', 0));                                  // 56 // LD D,(HL)
b('o57', ldrr('d', 'a', $cpc?1:4));                         // 57 // LD D,A
b('o58', ldrr('e', 'b', $cpc?1:4));                         // 58 // LD E,B
b('o59', ldrr('e', 'c', $cpc?1:4));                         // 59 // LD E,C
b('o5a', ldrr('e', 'd', $cpc?1:4));                         // 5a // LD E,D
c('o00');                                                   // 5b // LD E,E
a(ldrr('e', 'h', $cpc?1:4));                                // 5c // LD E,H
a(ldrr('e', 'l', $cpc?1:4));                                // 5d // LD E,L
a(ldrp('h', 'l', 'e', 0));                                  // 5e // LD E,(HL)
b('o5f', ldrr('e', 'a', $cpc?1:4));                         // 5f // LD E,A
a(ldrr('h', 'b', $cpc?1:4));                                // 60 // LD H,B
a(ldrr('h', 'c', $cpc?1:4));                                // 61 // LD H,C
a(ldrr('h', 'd', $cpc?1:4));                                // 62 // LD H,D
a(ldrr('h', 'e', $cpc?1:4));                                // 63 // LD H,E
c('o00');                                                   // 64 // LD H,H
a(ldrr('h', 'l', $cpc?1:4));                                // 65 // LD H,L
a(ldrp('h', 'l', 'h', 0));                                  // 66 // LD H,(HL)
a(ldrr('h', 'a', $cpc?1:4));                                // 67 // LD H,A
a(ldrr('l', 'b', $cpc?1:4));                                // 68 // LD L,B
a(ldrr('l', 'c', $cpc?1:4));                                // 69 // LD L,C
a(ldrr('l', 'd', $cpc?1:4));                                // 6a // LD L,D
a(ldrr('l', 'e', $cpc?1:4));                                // 6b // LD L,E
a(ldrr('l', 'h', $cpc?1:4));                                // 6c // LD L,H
c('o00');                                                   // 6d // LD L,L
a(ldrp('h', 'l', 'l', 0));                                  // 6e // LD L,(HL)
a(ldrr('l', 'a', $cpc?1:4));                                // 6f // LD L,A
a(ldpr('h', 'l', 'b', 0));                                  // 70 // LD (HL),B
a(ldpr('h', 'l', 'c', 0));                                  // 71 // LD (HL),C
a(ldpr('h', 'l', 'd', 0));                                  // 72 // LD (HL),D
a(ldpr('h', 'l', 'e', 0));                                  // 73 // LD (HL),E
a(ldpr('h', 'l', 'h', 0));                                  // 74 // LD (HL),H
a(ldpr('h', 'l', 'l', 0));                                  // 75 // LD (HL),L
b('o76', ($cpc?'++st':'st+=4').';halted=1;pc--');           // 76 // HALT
a(ldpr('h', 'l', 'a', 0));                                  // 77 // LD (HL),A
b('o78', ldrr('a', 'b', $cpc?1:4));                         // 78 // LD A,B
b('o79', ldrr('a', 'c', $cpc?1:4));                         // 79 // LD A,C
b('o7a', ldrr('a', 'd', $cpc?1:4));                         // 7a // LD A,D
b('o7b', ldrr('a', 'e', $cpc?1:4));                         // 7b // LD A,E
a(ldrr('a', 'h', $cpc?1:4));                                // 7c // LD A,H
a(ldrr('a', 'l', $cpc?1:4));                                // 7d // LD A,L
a(ldrp('h', 'l', 'a', 0));                                  // 7e // LD A,(HL)
c('o00');                                                   // 7f // LD A,A
b('o80', add('b', $cpc?1:4));                               // 80 // ADD A,B
b('o81', add('c', $cpc?1:4));                               // 81 // ADD A,C
b('o82', add('d', $cpc?1:4));                               // 82 // ADD A,D
b('o83', add('e', $cpc?1:4));                               // 83 // ADD A,E
a(add('h', $cpc?1:4));                                      // 84 // ADD A,H
a(add('l', $cpc?1:4));                                      // 85 // ADD A,L
a(add($pag?'m[h>>6][l|h<<8&16383]':'m[l|h<<8]', $cpc?2:7)); // 86 // ADD A,(HL)
b('o87', ($cpc?'++st':'st+=4').';a=fr=(ff=2*(fa=fb=a))&255');//87 // ADD A,A
b('o88', adc('b', $cpc?1:4));                               // 88 // ADC A,B
b('o89', adc('c', $cpc?1:4));                               // 89 // ADC A,C
b('o8a', adc('d', $cpc?1:4));                               // 8a // ADC A,D
b('o8b', adc('e', $cpc?1:4));                               // 8b // ADC A,E
a(adc('h', $cpc?1:4));                                      // 8c // ADC A,H
a(adc('l', $cpc?1:4));                                      // 8d // ADC A,L
a(adc($pag?'m[h>>6][l|h<<8&16383]':'m[l|h<<8]', $cpc?2:7)); // 8e // ADC A,(HL)
b('o8f', ($cpc?'++st':'st+=4').                             // 8f // ADC A,A
  ';a=fr=(ff=2*(fa=fb=a)+(ff>>8&1))&255');
b('o90', sub('b', $cpc?1:4));                               // 90 // SUB A,B
b('o91', sub('c', $cpc?1:4));                               // 91 // SUB A,C
b('o92', sub('d', $cpc?1:4));                               // 92 // SUB A,D
b('o93', sub('e', $cpc?1:4));                               // 93 // SUB A,E
a(sub('h', $cpc?1:4));                                      // 94 // SUB A,H
a(sub('l', $cpc?1:4));                                      // 95 // SUB A,L
a(sub($pag?'m[h>>6][l|h<<8&16383]':'m[l|h<<8]', $cpc?2:7)); // 96 // SUB A,(HL)
b('o97', ($cpc?'++st':'st+=4').';fb=~(fa=a);a=fr=ff=0');    // 97 // SUB A,A
b('o98', sbc('b', $cpc?1:4));                               // 98 // SBC A,B
b('o99', sbc('c', $cpc?1:4));                               // 99 // SBC A,C
b('o9a', sbc('d', $cpc?1:4));                               // 9a // SBC A,D
b('o9b', sbc('e', $cpc?1:4));                               // 9b // SBC A,E
a(sbc('h', $cpc?1:4));                                      // 9c // SBC A,H
a(sbc('l', $cpc?1:4));                                      // 9d // SBC A,L
a(sbc($pag?'m[h>>6][l|h<<8&16383]':'m[l|h<<8]', $cpc?2:7)); // 9e // SBC A,(HL)
b('o9f', ($cpc?'++st':'st+=4').                             // 9f // SBC A,A
  ';fb=~(fa=a);a=fr=(ff=(ff&256)/-256)&255');
b('oa0', anda('b', $cpc?1:4));                              // a0 // AND B
b('oa1', anda('c', $cpc?1:4));                              // a1 // AND C
b('oa2', anda('d', $cpc?1:4));                              // a2 // AND D
b('oa3', anda('e', $cpc?1:4));                              // a3 // AND E
a(anda('h', $cpc?1:4));                                     // a4 // AND H
a(anda('l', $cpc?1:4));                                     // a5 // AND L
a(anda($pag?'m[h>>6][l|h<<8&16383]':'m[l|h<<8]', $cpc?2:7));// a6 // AND (HL)
b('oa7', ($cpc?'++st':'st+=4').';fa=~(ff=fr=a);fb=0');      // a7 // AND A
b('oa8', xoror('^=b', $cpc?1:4));                           // a8 // XOR B
b('oa9', xoror('^=c', $cpc?1:4));                           // a9 // XOR C
b('oaa', xoror('^=d', $cpc?1:4));                           // aa // XOR D
b('oab', xoror('^=e', $cpc?1:4));                           // ab // XOR E
a(xoror('^=h', $cpc?1:4));                                  // ac // XOR H
a(xoror('^=l', $cpc?1:4));                                  // ad // XOR L
a(xoror($pag?'^=m[h>>6][l|h<<8&16383]':'^=m[l|h<<8]', $cpc?2:7)); // XOR (HL)
b('oaf', ($cpc?'++st':'st+=4').';a=ff=fr=fb=0;fa=256');     // af // XOR A
b('ob0', xoror('|=b', $cpc?1:4));                           // b0 // OR B
b('ob1', xoror('|=c', $cpc?1:4));                           // b1 // OR C
b('ob2', xoror('|=d', $cpc?1:4));                           // b2 // OR D
b('ob3', xoror('|=e', $cpc?1:4));                           // b3 // OR E
a(xoror('|=h', $cpc?1:4));                                  // b4 // OR H
a(xoror('|=l', $cpc?1:4));                                  // b5 // OR L
a(xoror($pag?'|=m[h>>6][l|h<<8&16383]':'|=m[l|h<<8]', $cpc?2:7)); // OR (HL)
b('ob7', ($cpc?'++st':'st+=4').';fa=(ff=fr=a)|256;fb=0');   // b7 // OR A
b('ob8', cp('b', $cpc?1:4));                                // b8 // CP B
b('ob9', cp('c', $cpc?1:4));                                // b9 // CP C
b('oba', cp('d', $cpc?1:4));                                // ba // CP D
b('obb', cp('e', $cpc?1:4));                                // bb // CP E
a(cp('h', $cpc?1:4));                                       // bc // CP H
a(cp('l', $cpc?1:4));                                       // bd // CP L
a('t=m['.($pag?'h>>6][l|h<<8&16383':'l|h<<8').'];'.cp('t',$cpc?2:7));//CP (HL)
b('obf', ($cpc?'++st':'st+=4').';fr=0;fb=~(fa=a);ff=a&40'); // bf // CP A
b('oc0', retci('fr'));                                      // c0 // RET NZ
b('oc1', pop('b', 'c'));                                    // c1 // POP BC
b('oc2', jpci('fr'));                                       // c2 // JP NZ
b('oc3', 'st+='.($cpc?3:10).';'.                            // c3 // JP nn
  ($mp?'mp=':'').
($pag
  ? 'pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8'
  : 'pc=m[pc&65535]|m[pc+1&65535]<<8'));
b('oc4', callci('fr'));                                     // c4 // CALL NZ
b('oc5', push('b', 'c'));                                   // c5 // PUSH BC
b('oc6', add($pag?'m[pc>>14&3][pc++&16383]':'m[pc++&65535]', $cpc?2:7)); // ADD A,n
b('oc7', rst(0));                                           // c7 // RST 0x00
b('oc8', retc('fr'));                                       // c8 // RET Z
b('oc9', ret($cpc?3:10));                                   // c9 // RET
b('oca', jpc('fr'));                                        // ca // JP Z
a('r++;g[768+m['.($pag? 'pc>>14&3][pc++&16383'              // cb // op cb
                      : 'pc++&65535').']]()');
b('occ', callc('fr'));                                      // cc // CALL Z
b('ocd', 'st+='.($cpc?5:17).';'.                            // cd // CALL NN
  't=pc+2;'.
  ($mp?'mp=':'').
($pag
  ? 'pc=m[pc>>14&3][pc&16383]|m[pc+1>>14&3][pc+1&16383]<<8;'.
    'mw[--sp>>14&3][sp&16383]=t>>8&255;'.
    'mw[(sp=sp-1&65535)>>14][sp&16383]=t&255'
  : 'pc=m[pc&65535]|m[pc+1&65535]<<8;'.
    'wb(--sp&65535,t>>8&255);'.
    'wb(sp=sp-1&65535,t&255)'));
b('oce', adc($pag?'m[pc>>14&3][pc++&16383]':'m[pc++&65535]', $cpc?2:7)); // ADC A,n
b('ocf', rst(8));                                           // cf // RST 0x08
b('od0', retc('ff&256'));                                   // d0 // RET NC
b('od1', pop('d', 'e'));                                    // d1 // POP DE
b('od2', jpc('ff&256'));                                    // d2 // JP NC
b('od3', 'st+='.($cpc?3:11).';'.                            // d3 // OUT (n),A
($pag
  ? 'wp('.($mp?'mp=':'').'m[pc>>14&3][pc++&16383]|a<<8,a)'
  : 'wp('.($mp?'mp=':'').'m[pc++&65535]|a<<8,a)').
  ($mp?';mp=mp+1&255|mp&65280':''));
b('od4', callc('ff&256'));                                  // d4 // CALL NC
b('od5', push('d', 'e'));                                   // d5 // PUSH DE
b('od6', sub($pag?'m[pc>>14&3][pc++&16383]':'m[pc++&65535]', $cpc?2:7)); // SUB A,n
b('od7', rst(16));                                          // d7 // RST 0x10
b('od8', retci('ff&256'));                                  // d8 // RET C
                                                            // d9 // EXX
b('od9', ($cpc?'++st':'st+=4').';t=b;b=b_;b_=t;t=c;c=c_;c_=t;t=d;d=d_;d_=t;t=e;e=e_;e_=t;t=h;h=h_;h_=t;t=l;l=l_;l_=t');
b('oda', jpci('ff&256'));                                   // da // JP C
b('odb', 'st+='.($cpc?3:11).';'.                            // db // IN A,(n)
($pag
  ? 'a=rp('.($mp?'mp=':'').'m[pc>>14&3][pc++&16383]|a<<8)'
  : 'a=rp('.($mp?'mp=':'').'m[pc++&65535]|a<<8)').
  ($mp?';++mp':''));
b('odc', callci('ff&256'));                                 // dc // CALL C
b('odd', ($cpc?'++st':'st+=4').                             // dd // OP dd
  ';r++;g[256+m['.($pag ? 'pc>>14&3][pc++&16383'
                        : 'pc++&65535').']]()');
b('ode', sbc($pag?'m[pc>>14&3][pc++&16383]':'m[pc++&65535]', $cpc?2:7)); // SBC A,n
b('odf', rst(24));                                          // df // RST 0x18
b('oe0', retc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e0//RET PO
a(pop('h', 'l'));                                           // e1 // POP HL
b('oe2', jpc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e2//JP PO
a(exspi(''));                                               // e3 // EX (SP),HL
b('oe4', callc('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e4//CALL PO
a(push('h', 'l'));                                          // e5 // PUSH HL
b('oe6', anda($pag?'m[pc>>14&3][pc++&16383]':'m[pc++&65535]', $cpc?2:7));// AND A,n
b('oe7', rst(32));                                          // e7 // RST 0x20
b('oe8', retci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//e8//RET PE
a(ldsppci('pc', ''));                                       // e9 // JP (HL)
b('oea', jpci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//ea//JP PE
b('oeb', ($cpc?'++st':'st+=4').';t=d;d=h;h=t;t=e;e=l;l=t'); // eb // EX DE,HL
b('oec', callci('fa&256?38505>>((fr^fr>>4)&15)&1:(fr^fa)&(fr^fb)&128'));//ec//CALL PE
b('oed', 'r++;g[1280+m['.($pag ? 'pc>>14&3][pc++&16383'     // ed // op ed
                               : 'pc++&65535').']]()');
b('oee', xoror($pag?'^=m[pc>>14&3][pc++&16383]':'^=m[pc++&65535]',$cpc?2:7));//ee//XOR A,n
b('oef', rst(40));                                          // ef // RST 0x28
b('of0', retc('ff&128'));                                   // f0 // RET P
b('of1', popaf());                                          // f1 // POP AF
b('of2', jpc('ff&128'));                                    // f2 // JP P
b('of3', ($cpc?'++st':'st+=4').';iff=0');                   // f3 // DI
b('of4', callc('ff&128'));                                  // f4 // CALL P
b('of5', push('a', 'f()'));                                 // f5 // PUSH AF
b('of6', xoror($pag?'|=m[pc>>14&3][pc++&16383]':'|=m[pc++&65535]',$cpc?2:7));//f6//OR A,n
b('of7', rst(48));                                          // f7 // RST 0x30
b('of8', retci('ff&128'));                                  // f8 // RET M
a(ldsppci('sp', ''));                                       // f9 // LD SP,HL
b('ofa', jpci('ff&128'));                                   // fa // JP M
b('ofb', ($cpc?'++st':'st+=4').';iff=1');                   // fb // EI
b('ofc', callci('ff&128'));                                 // fc // CALL M
b('ofd', ($cpc?'++st':'st+=4').                             // fd // op fd
  ';r++;g[512+m['.($pag ? 'pc>>14&3][pc++&16383'
                        : 'pc++&65535').']]()');
b('ofe', ($pag                                              // fe // CP A,n
  ? 't=m[pc>>14&3][pc++&16383];'
  : 't=m[pc++&65535];').cp('t', $cpc?2:7));
b('off', rst(56));                                          // ff // RST 0x38

c('o00');                                                   // 00 // NOP
c('o01');                                                   // 01 // LD BC,nn
c('o02');                                                   // 02 // LD (BC),A
c('o03');                                                   // 03 // INC BC
c('o04');                                                   // 04 // INC B
c('o05');                                                   // 05 // DEC B
c('o06');                                                   // 06 // LD B,n
c('o07');                                                   // 07 // RLCA
c('o08');                                                   // 08 // EX AF,AF'
a(addrrrr('xh', 'xl', 'b', 'c'));                           // 09 // ADD IX,BC
c('o0a');                                                   // 0A // LD A,(BC)
c('o0b');                                                   // 0B // DEC BC
c('o0c');                                                   // 0C // INC C
c('o0d');                                                   // 0D // DEC C
c('o0e');                                                   // 0E // LD C,n
c('o0f');                                                   // 0F // RRCA
c('o10');                                                   // 10 // DJNZ
c('o11');                                                   // 11 // LD DE,nn
c('o12');                                                   // 12 // LD (DE),A
c('o13');                                                   // 13 // INC DE
c('o14');                                                   // 14 // INC D
c('o15');                                                   // 15 // DEC D
c('o16');                                                   // 16 // LD D,n
c('o17');                                                   // 17 // RLA
c('o18');                                                   // 18 // JR
a(addrrrr('xh', 'xl', 'd', 'e'));                           // 19 // ADD IX,DE
c('o1a');                                                   // 1A // LD A,(DE)
c('o1b');                                                   // 1B // DEC DE
c('o1c');                                                   // 1C // INC E
c('o1d');                                                   // 1D // DEC E
c('o1e');                                                   // 1E // LD E,n
c('o1f');                                                   // 1F // RRA
c('o20');                                                   // 20 // JR NZ,s8
a(ldrrim('xh', 'xl'));                                      // 21 // LD IX,nn
a(ldpnnrr('xh', 'xl', $cpc?5:16));                          // 22 // LD (nn),IX
a(incw('xh', 'xl'));                                        // 23 // INC IX
a(inc('xh'));                                               // 24 // INC IXH
a(dec('xh'));                                               // 25 // DEC IXH
a(ldrim('xh'));                                             // 26 // LD IXH,n
c('o27');                                                   // 27 // DAA
c('o28');                                                   // 28 // JR Z,s8
a(addrrrr('xh', 'xl', 'xh', 'xl'));                         // 29 // ADD IX,IX
a(ldrrpnn('xh', 'xl', $cpc?5:16));                          // 2a // LD IX,(nn)
a(decw('xh', 'xl'));                                        // 2b // DEC IX
a(inc('xl'));                                               // 2c // INC IXL
a(dec('xl'));                                               // 2d // DEC IXL
a(ldrim('xl'));                                             // 2e // LD IXL,n
c('o2f');                                                   // 2f // CPL
c('o30');                                                   // 30 // JR NC,s8
c('o31');                                                   // 31 // LD SP,nn
c('o32');                                                   // 32 // LD (nn),A
c('o33');                                                   // 33 // INC SP
a(incdecpi('x', '+'));                                      // 34 // INC (IX+d)
a(incdecpi('x', '-'));                                      // 35 // DEC (IX+d)
a(ldpin('x'));                                              // 36 // LD (IX+d),n
c('o37');                                                   // 37 // SCF
c('o38');                                                   // 38 // JR C,s8
a(addisp('x'));                                             // 39 // ADD IX,SP
c('o3a');                                                   // 3a // LD A,(nn)
c('o3b');                                                   // 3b // DEC SP
c('o3c');                                                   // 3c // INC A
c('o3d');                                                   // 3d // DEC A
c('o3e');                                                   // 3e // LD A,n
c('o3f');                                                   // 3f // CCF
c('o00');                                                   // 40 // LD B,B
c('o41');                                                   // 41 // LD B,C
c('o42');                                                   // 42 // LD B,D
c('o43');                                                   // 43 // LD B,E
a(ldrr('b', 'xh', $cpc?1:4));                               // 44 // LD B,IXH
a(ldrr('b', 'xl', $cpc?1:4));                               // 45 // LD B,IXL
a(ldrpi('b', 'x'));                                         // 46 // LD B,(IX+d)
c('o47');                                                   // 47 // LD B,A
c('o48');                                                   // 48 // LD C,B
c('o00');                                                   // 49 // LD C,C
c('o4a');                                                   // 4a // LD C,D
c('o4b');                                                   // 4b // LD C,E
a(ldrr('c', 'xh', $cpc?1:4));                               // 4c // LD C,IXH
a(ldrr('c', 'xl', $cpc?1:4));                               // 4d // LD C,IXL
a(ldrpi('c', 'x'));                                         // 4e // LD C,(IX+d)
c('o4f');                                                   // 4f // LD C,A
c('o50');                                                   // 50 // LD D,B
c('o51');                                                   // 51 // LD D,C
c('o00');                                                   // 52 // LD D,D
c('o53');                                                   // 53 // LD D,E
a(ldrr('d', 'xh', $cpc?1:4));                               // 54 // LD D,IXH
a(ldrr('d', 'xl', $cpc?1:4));                               // 55 // LD D,IXL
a(ldrpi('d', 'x'));                                         // 56 // LD D,(IX+d)
c('o57');                                                   // 57 // LD D,A
c('o58');                                                   // 58 // LD E,B
c('o59');                                                   // 59 // LD E,C
c('o5a');                                                   // 5a // LD E,D
c('o00');                                                   // 5b // LD E,E
a(ldrr('e', 'xh', $cpc?1:4));                               // 5c // LD E,IXH
a(ldrr('e', 'xl', $cpc?1:4));                               // 5d // LD E,IXL
a(ldrpi('e', 'x'));                                         // 5e // LD E,(IX+d)
c('o5f');                                                   // 5f // LD E,A
a(ldrr('xh', 'b', $cpc?1:4));                               // 60 // LD IXH,B
a(ldrr('xh', 'c', $cpc?1:4));                               // 61 // LD IXH,C
a(ldrr('xh', 'd', $cpc?1:4));                               // 62 // LD IXH,D
a(ldrr('xh', 'e', $cpc?1:4));                               // 63 // LD IXH,E
c('o00');                                                   // 64 // LD IXH,IXH
a(ldrr('xh', 'xl', $cpc?1:4));                              // 65 // LD IXH,IXL
a(ldrpi('h', 'x'));                                         // 66 // LD H,(IX+d)
a(ldrr('xh', 'a', $cpc?1:4));                               // 67 // LD IXH,A
a(ldrr('xl', 'b', $cpc?1:4));                               // 68 // LD IXL,B
a(ldrr('xl', 'c', $cpc?1:4));                               // 69 // LD IXL,C
a(ldrr('xl', 'd', $cpc?1:4));                               // 6a // LD IXL,D
a(ldrr('xl', 'e', $cpc?1:4));                               // 6b // LD IXL,E
a(ldrr('xl', 'xh', $cpc?1:4));                              // 6c // LD IXL,IXH
c('o00');                                                   // 6d // LD IXL,IXL
a(ldrpi('l', 'x'));                                         // 6e // LD L,(IX+d)
a(ldrr('xl', 'a', $cpc?1:4));                               // 6f // LD IXL,A
a(ldpri('b', 'x'));                                         // 70 // LD (IX+d),B
a(ldpri('c', 'x'));                                         // 71 // LD (IX+d),C
a(ldpri('d', 'x'));                                         // 72 // LD (IX+d),D
a(ldpri('e', 'x'));                                         // 73 // LD (IX+d),E
a(ldpri('h', 'x'));                                         // 74 // LD (IX+d),H
a(ldpri('l', 'x'));                                         // 75 // LD (IX+d),L
c('o76');                                                   // 76 // HALT
a(ldpri('a', 'x'));                                         // 77 // LD (IX+d),A
c('o78');                                                   // 78 // LD A,B
c('o79');                                                   // 79 // LD A,C
c('o7a');                                                   // 7a // LD A,D
c('o7b');                                                   // 7b // LD A,E
a(ldrr('a', 'xh', $cpc?1:4));                               // 7c // LD A,IXH
a(ldrr('a', 'xl', $cpc?1:4));                               // 7d // LD A,IXL
a(ldrpi('a', 'x'));                                         // 7e // LD A,(IX+d)
c('o00');                                                   // 7f // LD A,A
c('o80');                                                   // 80 // ADD A,B
c('o81');                                                   // 81 // ADD A,C
c('o82');                                                   // 82 // ADD A,D
c('o83');                                                   // 83 // ADD A,E
a(add('xh', $cpc?1:4));                                     // 84 // ADD A,IXH
a(add('xl', $cpc?1:4));                                     // 85 // ADD A,IXL
a(add($pag                                                  // 86 // ADD A,(IX+d)
  ? 'm[(t=(m[pc>>14&3][pc++&16383]^128)-128+(xl|xh<<8))>>14&3][t&16383]'
  : 'm[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', $cpc?4:15));
c('o87');                                                   // 87 // ADD A,A
c('o88');                                                   // 88 // ADC A,B
c('o89');                                                   // 89 // ADC A,C
c('o8a');                                                   // 8a // ADC A,D
c('o8b');                                                   // 8b // ADC A,E
a(adc('xh', $cpc?1:4));                                     // 8c // ADC A,IXH
a(adc('xl', $cpc?1:4));                                     // 8d // ADC A,IXL
a(adc($pag                                                  // 8e // ADC A,(IX+d)
  ? 'm[(t=(m[pc>>14&3][pc++&16383]^128)-128+(xl|xh<<8))>>14&3][t&16383]'
  : 'm[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', $cpc?4:15));
c('o8f');                                                   // 8f // ADC A,A
c('o90');                                                   // 90 // SUB A,B
c('o91');                                                   // 91 // SUB A,C
c('o92');                                                   // 92 // SUB A,D
c('o93');                                                   // 93 // SUB A,E
a(sub('xh', $cpc?1:4));                                     // 94 // SUB A,IXH
a(sub('xl', $cpc?1:4));                                     // 95 // SUB A,IXL
a(sub($pag                                                  // 96 // SUB A,(IX+d)
  ? 'm[(t=(m[pc>>14&3][pc++&16383]^128)-128+(xl|xh<<8))>>14&3][t&16383]'
  : 'm[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', $cpc?4:15));
c('o97');                                                   // 97 // SUB A,A
c('o98');                                                   // 98 // SBC A,B
c('o99');                                                   // 99 // SBC A,C
c('o9a');                                                   // 9a // SBC A,D
c('o9b');                                                   // 9b // SBC A,E
a(sbc('xh', $cpc?1:4));                                     // 9c // SBC A,IXH
a(sbc('xl', $cpc?1:4));                                     // 9d // SBC A,IXL
a(sbc($pag                                                  // 9e // SBC A,(IX+d)
  ? 'm[(t=(m[pc>>14&3][pc++&16383]^128)-128+(xl|xh<<8))>>14&3][t&16383]'
  : 'm[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', $cpc?4:15));
c('o9f');                                                   // 9f // SBC A,A
c('oa0');                                                   // a0 // AND B
c('oa1');                                                   // a1 // AND C
c('oa2');                                                   // a2 // AND D
c('oa3');                                                   // a3 // AND E
a(anda('xh', $cpc?1:4));                                    // a4 // AND IXH
a(anda('xl', $cpc?1:4));                                    // a5 // AND IXL
a(anda($pag                                                 // a6 // AND (IX+d)
  ? 'm[(t=(m[pc>>14&3][pc++&16383]^128)-128+(xl|xh<<8))>>14&3][t&16383]'
  : 'm[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', $cpc?4:15));
c('oa7');                                                   // a7 // AND A
c('oa8');                                                   // a8 // XOR B
c('oa9');                                                   // a9 // XOR C
c('oaa');                                                   // aa // XOR D
c('oab');                                                   // ab // XOR E
a(xoror('^=xh', $cpc?1:4));                                 // ac // XOR IXH
a(xoror('^=xl', $cpc?1:4));                                 // ad // XOR IXL
a(xoror($pag                                                // ae // XOR (IX+d)
  ? '^=m[(t=(m[pc>>14&3][pc++&16383]^128)-128+(xl|xh<<8))>>14&3][t&16383]'
  : '^=m[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', $cpc?4:15));
c('oaf');                                                   // af // XOR A
c('ob0');                                                   // b0 // OR B
c('ob1');                                                   // b1 // OR C
c('ob2');                                                   // b2 // OR D
c('ob3');                                                   // b3 // OR E
a(xoror('|=xh', $cpc?1:4));                                 // b4 // OR IXH
a(xoror('|=xl', $cpc?1:4));                                 // b5 // OR IXL
a(xoror($pag                                                // b6 // OR (IX+d)
  ? '|=m[(t=(m[pc>>14&3][pc++&16383]^128)-128+(xl|xh<<8))>>14&3][t&16383]'
  : '|=m[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535]', $cpc?4:15));
c('ob7');                                                   // b7 // OR A
c('ob8');                                                   // b8 // CP B
c('ob9');                                                   // b9 // CP C
c('oba');                                                   // ba // CP D
c('obb');                                                   // bb // CP E
a(cp('xh', $cpc?1:4));                                      // bc // CP IXH
a(cp('xl', $cpc?1:4));                                      // bd // CP IXL
a(($pag                                                     // be // CP (IX+d)
  ? 't=m[(t=(m[pc>>14&3][pc++&16383]^128)-128+(xl|xh<<8))>>14&3][t&16383];'
  : 't=m[((m[pc++&65535]^128)-128+(xl|xh<<8))&65535];').cp('t', $cpc?4:15));
c('obf');                                                   // bf // CP A
c('oc0');                                                   // c0 // RET NZ
c('oc1');                                                   // c1 // POP BC
c('oc2');                                                   // c2 // JP NZ
c('oc3');                                                   // c3 // JP nn
c('oc4');                                                   // c4 // CALL NZ
c('oc5');                                                   // c5 // PUSH BC
c('oc6');                                                   // c6 // ADD A,n
c('oc7');                                                   // c7 // RST 0x00
c('oc8');                                                   // c8 // RET Z
c('oc9');                                                   // c9 // RET
c('oca');                                                   // ca // JP Z
a('st+='.($cpc?3:11).';'.                                   // cb // op ddcb
($pag
  ? 't=m[(mp=((m[pc>>14&3][pc++&16383]^128)-128+(xl|xh<<8))&65535)>>14][mp&16383];'.
    'g[1024+m[pc>>14&3][pc++&16383]]()'
  : 't=m[mp=((m[pc++&65535]^128)-128+(xl|xh<<8))&65535];'.
    'g[1024+m[pc++&65535]]()'));
c('occ');                                                   // cc // CALL Z
c('ocd');                                                   // cd // CALL NN
c('oce');                                                   // ce // ADC A,n
c('ocf');                                                   // cf // RST 0x08
c('od0');                                                   // d0 // RET NC
c('od1');                                                   // d1 // POP DE
c('od2');                                                   // d2 // JP NC
c('od3');                                                   // d3 // OUT (n),A
c('od4');                                                   // d4 // CALL NC
c('od5');                                                   // d5 // PUSH DE
c('od6');                                                   // d6 // SUB A,n
c('od7');                                                   // d7 // RST 0x10
c('od8');                                                   // d8 // RET C
c('od9');                                                   // d9 // EXX
c('oda');                                                   // da // JP C
c('odb');                                                   // db // IN A,(n)
c('odc');                                                   // dc // CALL C
c('odd');                                                   // dd // op dd
c('ode');                                                   // de // SBC A,n
c('odf');                                                   // df // RST 0x18
c('oe0');                                                   // e0 // RET PO
a(pop('xh', 'xl'));                                         // e1 // POP IX
c('oe2');                                                   // e2 // JP PO
a(exspi('x'));                                              // e3 // EX (SP),IX
c('oe4');                                                   // e4 // CALL PO
a(push('xh', 'xl'));                                        // e5 // PUSH IX
c('oe6');                                                   // e6 // AND A,n
c('oe7');                                                   // e7 // RST 0x20
c('oe8');                                                   // e8 // RET PE
a(ldsppci('pc', 'x'));                                      // e9 // JP (IX)
c('oea');                                                   // ea // JP PE
c('oeb');                                                   // eb // EX DE,HL
c('oec');                                                   // ec // CALL PE
c('oed');                                                   // ed // op ed
c('oee');                                                   // ee // XOR A,n
c('oef');                                                   // ef // RST 0x28
c('of0');                                                   // f0 // RET P
c('of1');                                                   // f1 // POP AF
c('of2');                                                   // f2 // JP P
c('of3');                                                   // f3 // DI
c('of4');                                                   // f4 // CALL P
c('of5');                                                   // f5 // PUSH AF
c('of6');                                                   // f6 // OR A,n
c('of7');                                                   // f7 // RST 0x30
c('of8');                                                   // f8 // RET M
a(ldsppci('sp', 'x'));                                      // f9 // LD SP,IX
c('ofa');                                                   // fa // JP M
c('ofb');                                                   // fb // EI
c('ofc');                                                   // fc // CALL M
c('ofd');                                                   // fd // op fd
a('ofe');                                                   // fe // CP A,n
a('off');                                                   // ff // RST 0x38

c('o00');                                                   // 00 // NOP
c('o01');                                                   // 01 // LD BC,nn
c('o02');                                                   // 02 // LD (BC),A
c('o03');                                                   // 03 // INC BC
c('o04');                                                   // 04 // INC B
c('o05');                                                   // 05 // DEC B
c('o06');                                                   // 06 // LD B,n
c('o07');                                                   // 07 // RLCA
c('o08');                                                   // 08 // EX AF,AF'
a(addrrrr('yh', 'yl', 'b', 'c'));                           // 09 // ADD IY,BC
c('o0a');                                                   // 0A // LD A,(BC)
c('o0b');                                                   // 0B // DEC BC
c('o0c');                                                   // 0C // INC C
c('o0d');                                                   // 0D // DEC C
c('o0e');                                                   // 0E // LD C,n
c('o0f');                                                   // 0F // RRCA
c('o10');                                                   // 10 // DJNZ
c('o11');                                                   // 11 // LD DE,nn
c('o12');                                                   // 12 // LD (DE),A
c('o13');                                                   // 13 // INC DE
c('o14');                                                   // 14 // INC D
c('o15');                                                   // 15 // DEC D
c('o16');                                                   // 16 // LD D,n
c('o17');                                                   // 17 // RLA
c('o18');                                                   // 18 // JR
a(addrrrr('yh', 'yl', 'd', 'e'));                           // 19 // ADD IY,DE
c('o1a');                                                   // 1A // LD A,(DE)
c('o1b');                                                   // 1B // DEC DE
c('o1c');                                                   // 1C // INC E
c('o1d');                                                   // 1D // DEC E
c('o1e');                                                   // 1E // LD E,n
c('o1f');                                                   // 1F // RRA
c('o20');                                                   // 20 // JR NZ,s8
a(ldrrim('yh', 'yl'));                                      // 21 // LD IY,nn
a(ldpnnrr('yh', 'yl', $cpc?5:16));                          // 22 // LD (nn),IY
a(incw('yh', 'yl'));                                        // 23 // INC IY
a(inc('yh'));                                               // 24 // INC IYH
a(dec('yh'));                                               // 25 // DEC IYH
a(ldrim('yh'));                                             // 26 // LD IYH,n
c('o27');                                                   // 27 // DAA
c('o28');                                                   // 28 // JR Z,s8
a(addrrrr('yh', 'yl', 'yh', 'yl'));                         // 29 // ADD IY,IY
a(ldrrpnn('yh', 'yl', $cpc?5:16));                          // 2a // LD IY,(nn)
a(decw('yh', 'yl'));                                        // 2b // DEC IY
a(inc('yl'));                                               // 2c // INC IYL
a(dec('yl'));                                               // 2d // DEC IYL
a(ldrim('yl'));                                             // 2e // LD IYL,n
c('o2f');                                                   // 2f // CPL
c('o30');                                                   // 30 // JR NC,s8
c('o31');                                                   // 31 // LD SP,nn
c('o32');                                                   // 32 // LD (nn),A
c('o33');                                                   // 33 // INC SP
a(incdecpi('y', '+'));                                      // 34 // INC (IY+d)
a(incdecpi('y', '-'));                                      // 35 // DEC (IY+d)
a(ldpin('y'));                                              // 36 // LD (IY+d),n
c('o37');                                                   // 37 // SCF
c('o38');                                                   // 38 // JR C,s8
a(addisp('y'));                                             // 39 // ADD IY,SP
c('o3a');                                                   // 3a // LD A,(nn)
c('o3b');                                                   // 3b // DEC SP
c('o3c');                                                   // 3c // INC A
c('o3d');                                                   // 3d // DEC A
c('o3e');                                                   // 3e // LD A,n
c('o3f');                                                   // 3f // CCF
c('o00');                                                   // 40 // LD B,B
c('o41');                                                   // 41 // LD B,C
c('o42');                                                   // 42 // LD B,D
c('o43');                                                   // 43 // LD B,E
a(ldrr('b', 'yh', $cpc?1:4));                               // 44 // LD B,IYH
a(ldrr('b', 'yl', $cpc?1:4));                               // 45 // LD B,IYL
a(ldrpi('b', 'y'));                                         // 46 // LD B,(IY+d)
c('o47');                                                   // 47 // LD B,A
c('o48');                                                   // 48 // LD C,B
c('o00');                                                   // 49 // LD C,C
c('o4a');                                                   // 4a // LD C,D
c('o4b');                                                   // 4b // LD C,E
a(ldrr('c', 'yh', $cpc?1:4));                               // 4c // LD C,IYH
a(ldrr('c', 'yl', $cpc?1:4));                               // 4d // LD C,IYL
a(ldrpi('c', 'y'));                                         // 4e // LD C,(IY+d)
c('o4f');                                                   // 4f // LD C,A
c('o50');                                                   // 50 // LD D,B
c('o51');                                                   // 51 // LD D,C
c('o00');                                                   // 52 // LD D,D
c('o53');                                                   // 53 // LD D,E
a(ldrr('d', 'yh', $cpc?1:4));                               // 54 // LD D,IYH
a(ldrr('d', 'yl', $cpc?1:4));                               // 55 // LD D,IYL
a(ldrpi('d', 'y'));                                         // 56 // LD D,(IY+d)
c('o57');                                                   // 57 // LD D,A
c('o58');                                                   // 58 // LD E,B
c('o59');                                                   // 59 // LD E,C
c('o5a');                                                   // 5a // LD E,D
c('o00');                                                   // 5b // LD E,E
a(ldrr('e', 'yh', $cpc?1:4));                               // 5c // LD E,IYH
a(ldrr('e', 'yl', $cpc?1:4));                               // 5d // LD E,IYL
a(ldrpi('e', 'y'));                                         // 5e // LD E,(IY+d)
c('o5f');                                                   // 5f // LD E,A
a(ldrr('yh', 'b', $cpc?1:4));                               // 60 // LD IYH,B
a(ldrr('yh', 'c', $cpc?1:4));                               // 61 // LD IYH,C
a(ldrr('yh', 'd', $cpc?1:4));                               // 62 // LD IYH,D
a(ldrr('yh', 'e', $cpc?1:4));                               // 63 // LD IYH,E
c('o00');                                                   // 64 // LD IYH,IYH
a(ldrr('yh', 'yl', $cpc?1:4));                              // 65 // LD IYH,IYL
a(ldrpi('h', 'y'));                                         // 66 // LD H,(IY+d)
a(ldrr('yh', 'a', $cpc?1:4));                               // 67 // LD IYH,A
a(ldrr('yl', 'b', $cpc?1:4));                               // 68 // LD IYL,B
a(ldrr('yl', 'c', $cpc?1:4));                               // 69 // LD IYL,C
a(ldrr('yl', 'd', $cpc?1:4));                               // 6a // LD IYL,D
a(ldrr('yl', 'e', $cpc?1:4));                               // 6b // LD IYL,E
a(ldrr('yl', 'yh', $cpc?1:4));                              // 6c // LD IYL,IYH
c('o00');                                                   // 6d // LD IYL,IYL
a(ldrpi('l', 'y'));                                         // 6e // LD L,(IY+d)
a(ldrr('yl', 'a', $cpc?1:4));                               // 6f // LD IYL,A
a(ldpri('b', 'y'));                                         // 70 // LD (IY+d),B
a(ldpri('c', 'y'));                                         // 71 // LD (IY+d),C
a(ldpri('d', 'y'));                                         // 72 // LD (IY+d),D
a(ldpri('e', 'y'));                                         // 73 // LD (IY+d),E
a(ldpri('h', 'y'));                                         // 74 // LD (IY+d),H
a(ldpri('l', 'y'));                                         // 75 // LD (IY+d),L
c('o76');                                                   // 76 // HALT
a(ldpri('a', 'y'));                                         // 77 // LD (IY+d),A
c('o78');                                                   // 78 // LD A,B
c('o79');                                                   // 79 // LD A,C
c('o7a');                                                   // 7a // LD A,D
c('o7b');                                                   // 7b // LD A,E
a(ldrr('a', 'yh', $cpc?1:4));                               // 7c // LD A,IYH
a(ldrr('a', 'yl', $cpc?1:4));                               // 7d // LD A,IYL
a(ldrpi('a', 'y'));                                         // 7e // LD A,(IY+d)
c('o00');                                                   // 7f // LD A,A
c('o80');                                                   // 80 // ADD A,B
c('o81');                                                   // 81 // ADD A,C
c('o82');                                                   // 82 // ADD A,D
c('o83');                                                   // 83 // ADD A,E
a(add('yh', $cpc?1:4));                                     // 84 // ADD A,IYH
a(add('yl', $cpc?1:4));                                     // 85 // ADD A,IYL
a(add($pag                                                  // 86 // ADD A,(IY+d)
  ? 'm[(t=(m[pc>>14&3][pc++&16383]^128)-128+(yl|yh<<8))>>14&3][t&16383]'
  : 'm[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', $cpc?4:15));
c('o87');                                                   // 87 // ADD A,A
c('o88');                                                   // 88 // ADC A,B
c('o89');                                                   // 89 // ADC A,C
c('o8a');                                                   // 8a // ADC A,D
c('o8b');                                                   // 8b // ADC A,E
a(adc('yh', $cpc?1:4));                                     // 8c // ADC A,IYH
a(adc('yl', $cpc?1:4));                                     // 8d // ADC A,IYL
a(adc($pag                                                  // 8e // ADC A,(IY+d)
  ? 'm[(t=(m[pc>>14&3][pc++&16383]^128)-128+(yl|yh<<8))>>14&3][t&16383]'
  : 'm[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', $cpc?4:15));
c('o8f');                                                   // 8f // ADC A,A
c('o90');                                                   // 90 // SUB A,B
c('o91');                                                   // 91 // SUB A,C
c('o92');                                                   // 92 // SUB A,D
c('o93');                                                   // 93 // SUB A,E
a(sub('yh', $cpc?1:4));                                     // 94 // SUB A,IYH
a(sub('yl', $cpc?1:4));                                     // 95 // SUB A,IYL
a(sub($pag                                                  // 96 // SUB A,(IY+d)
  ? 'm[(t=(m[pc>>14&3][pc++&16383]^128)-128+(yl|yh<<8))>>14&3][t&16383]'
  : 'm[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', $cpc?4:15));
c('o97');                                                   // 97 // SUB A,A
c('o98');                                                   // 98 // SBC A,B
c('o99');                                                   // 99 // SBC A,C
c('o9a');                                                   // 9a // SBC A,D
c('o9b');                                                   // 9b // SBC A,E
a(sbc('yh', $cpc?1:4));                                     // 9c // SBC A,IYH
a(sbc('yl', $cpc?1:4));                                     // 9d // SBC A,IYL
a(sbc($pag                                                  // 9e // SBC A,(IY+d)
  ? 'm[(t=(m[pc>>14&3][pc++&16383]^128)-128+(yl|yh<<8))>>14&3][t&16383]'
  : 'm[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', $cpc?4:15));
c('o9f');                                                   // 9f // SBC A,A
c('oa0');                                                   // a0 // AND B
c('oa1');                                                   // a1 // AND C
c('oa2');                                                   // a2 // AND D
c('oa3');                                                   // a3 // AND E
a(anda('yh', $cpc?1:4));                                    // a4 // AND IYH
a(anda('yl', $cpc?1:4));                                    // a5 // AND IYL
a(anda($pag                                                 // a6 // AND (IY+d)
  ? 'm[(t=(m[pc>>14&3][pc++&16383]^128)-128+(yl|yh<<8))>>14&3][t&16383]'
  : 'm[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', $cpc?4:15));
c('oa7');                                                   // a7 // AND A
c('oa8');                                                   // a8 // XOR B
c('oa9');                                                   // a9 // XOR C
c('oaa');                                                   // aa // XOR D
c('oab');                                                   // ab // XOR E
a(xoror('^=yh', $cpc?1:4));                                 // ac // XOR IYH
a(xoror('^=yl', $cpc?1:4));                                 // ad // XOR IYL
a(xoror($pag                                                // ae // XOR (IY+d)
  ? '^=m[(t=(m[pc>>14&3][pc++&16383]^128)-128+(yl|yh<<8))>>14&3][t&16383]'
  : '^=m[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', $cpc?4:15));
c('oaf');                                                   // af // XOR A
c('ob0');                                                   // b0 // OR B
c('ob1');                                                   // b1 // OR C
c('ob2');                                                   // b2 // OR D
c('ob3');                                                   // b3 // OR E
a(xoror('|=yh', $cpc?1:4));                                 // b4 // OR IYH
a(xoror('|=yl', $cpc?1:4));                                 // b5 // OR IYL
a(xoror($pag                                                // b6 // OR (IY+d)
  ? '|=m[(t=(m[pc>>14&3][pc++&16383]^128)-128+(yl|yh<<8))>>14&3][t&16383]'
  : '|=m[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535]', $cpc?4:15));
c('ob7');                                                   // b7 // OR A
c('ob8');                                                   // b8 // CP B
c('ob9');                                                   // b9 // CP C
c('oba');                                                   // ba // CP D
c('obb');                                                   // bb // CP E
a(cp('yh', $cpc?1:4));                                      // bc // CP IYH
a(cp('yl', $cpc?1:4));                                      // bd // CP IYL
a(($pag                                                     // be // CP (IY+d)
  ? 't=m[(t=(m[pc>>14&3][pc++&16383]^128)-128+(yl|yh<<8))>>14&3][t&16383];'
  : 't=m[((m[pc++&65535]^128)-128+(yl|yh<<8))&65535];').cp('t', $cpc?4:15));
c('obf');                                                   // bf // CP A
c('oc0');                                                   // c0 // RET NZ
c('oc1');                                                   // c1 // POP BC
c('oc2');                                                   // c2 // JP NZ
c('oc3');                                                   // c3 // JP nn
c('oc4');                                                   // c4 // CALL NZ
c('oc5');                                                   // c5 // PUSH BC
c('oc6');                                                   // c6 // ADD A,n
c('oc7');                                                   // c7 // RST 0x00
c('oc8');                                                   // c8 // RET Z
c('oc9');                                                   // c9 // RET
c('oca');                                                   // ca // JP Z
a('st+='.($cpc?3:11).';'.                                   // cb // op fdcb
($pag
  ? 't=m[(mp=((m[pc>>14&3][pc++&16383]^128)-128+(yl|yh<<8))&65535)>>14][mp&16383];'.
    'g[1024+m[pc>>14&3][pc++&16383]]()'
  : 't=m[mp=((m[pc++&65535]^128)-128+(yl|yh<<8))&65535];'.
    'g[1024+m[pc++&65535]]()'));
c('occ');                                                   // cc // CALL Z
c('ocd');                                                   // cd // CALL NN
c('oce');                                                   // ce // ADC A,n
c('ocf');                                                   // cf // RST 0x08
c('od0');                                                   // d0 // RET NC
c('od1');                                                   // d1 // POP DE
c('od2');                                                   // d2 // JP NC
c('od3');                                                   // d3 // OUT (n),A
c('od4');                                                   // d4 // CALL NC
c('od5');                                                   // d5 // PUSH DE
c('od6');                                                   // d6 // SUB A,n
c('od7');                                                   // d7 // RST 0x10
c('od8');                                                   // d8 // RET C
c('od9');                                                   // d9 // EXX
c('oda');                                                   // da // JP C
c('odb');                                                   // db // IN A,(n)
c('odc');                                                   // dc // CALL C
c('odd');                                                   // dd // op dd
c('ode');                                                   // de // SBC A,n
c('odf');                                                   // df // RST 0x18
c('oe0');                                                   // e0 // RET PO
a(pop('yh', 'yl'));                                         // e1 // POP IY
c('oe2');                                                   // e2 // JP PO
a(exspi('y'));                                              // e3 // EX (SP),IY
c('oe4');                                                   // e4 // CALL PO
a(push('yh', 'yl'));                                        // e5 // PUSH IY
c('oe6');                                                   // e6 // AND A,n
c('oe7');                                                   // e7 // RST 0x20
c('oe8');                                                   // e8 // RET PE
a(ldsppci('pc', 'y'));                                      // e9 // JP (IY)
c('oea');                                                   // ea // JP PE
c('oeb');                                                   // eb // EX DE,HL
c('oec');                                                   // ec // CALL PE
c('oed');                                                   // ed // op ed
c('oee');                                                   // ee // XOR A,n
c('oef');                                                   // ef // RST 0x28
c('of0');                                                   // f0 // RET P
c('of1');                                                   // f1 // POP AF
c('of2');                                                   // f2 // JP P
c('of3');                                                   // f3 // DI
c('of4');                                                   // f4 // CALL P
c('of5');                                                   // f5 // PUSH AF
c('of6');                                                   // f6 // OR A,n
c('of7');                                                   // f7 // RST 0x30
c('of8');                                                   // f8 // RET M
a(ldsppci('sp', 'y'));                                      // f9 // LD SP,IY
c('ofa');                                                   // fa // JP M
c('ofb');                                                   // fb // EI
c('ofc');                                                   // fc // CALL M
c('ofd');                                                   // fd // op fd
a('ofe');                                                   // fe // CP A,n
a('off');                                                   // ff // RST 0x38

a(rlc('b'));                                                // 00 // RLC B
a(rlc('c'));                                                // 01 // RLC C
a(rlc('d'));                                                // 02 // RLC D
a(rlc('e'));                                                // 03 // RLC E
a(rlc('h'));                                                // 04 // RLC H
a(rlc('l'));                                                // 05 // RLC L
a('st+='.($cpc?4:15).';'.                                   // 06 // RLC (HL)
($pag
  ? 'v=m[t=h>>6][u=l|h<<8&16383];'.rlc('v').';mw[t][u]=v'
  : 't=l|h<<8;u=m[t];'.rlc('u').';wb(t,u)'));
a(rlc('a'));                                                // 07 // RLC A
a(rrc('b'));                                                // 08 // RRC B
a(rrc('c'));                                                // 09 // RRC C
a(rrc('d'));                                                // 0a // RRC D
a(rrc('e'));                                                // 0b // RRC E
a(rrc('h'));                                                // 0c // RRC H
a(rrc('l'));                                                // 0d // RRC L
a('st+='.($cpc?4:15).';'.                                   // 0e // RRC (HL)
($pag
  ? 'v=m[t=h>>6][u=l|h<<8&16383];'.rrc('v').';mw[t][u]=v'
  : 't=l|h<<8;u=m[t];'.rrc('u').';wb(t,u)'));
a(rrc('a'));                                                // 0f // RRC A
a(rl('b'));                                                 // 10 // RL B
a(rl('c'));                                                 // 11 // RL C
a(rl('d'));                                                 // 12 // RL D
a(rl('e'));                                                 // 13 // RL E
a(rl('h'));                                                 // 14 // RL H
a(rl('l'));                                                 // 15 // RL L
a('st+='.($cpc?4:15).';'.                                   // 16 // RL (HL)
($pag
  ? 'v=m[t=h>>6][u=l|h<<8&16383];'.rl('v').';mw[t][u]=v'
  : 't=l|h<<8;u=m[t];'.rl('u').';wb(t,u)'));
a(rl('a'));                                                 // 17 // RL A
a(rr('b'));                                                 // 18 // RR B
a(rr('c'));                                                 // 19 // RR C
a(rr('d'));                                                 // 1a // RR D
a(rr('e'));                                                 // 1b // RR E
a(rr('h'));                                                 // 1c // RR H
a(rr('l'));                                                 // 1d // RR L
a('st+='.($cpc?4:15).';'.                                   // 1e // RR (HL)
($pag
  ? 'v=m[t=h>>6][u=l|h<<8&16383];'.rr('v').';mw[t][u]=v'
  : 't=l|h<<8;u=m[t];'.rr('u').';wb(t,u)'));
a(rr('a'));                                                 // 1f // RR A
a(sla('b'));                                                // 20 // SLA B
a(sla('c'));                                                // 21 // SLA C
a(sla('d'));                                                // 22 // SLA D
a(sla('e'));                                                // 23 // SLA E
a(sla('h'));                                                // 24 // SLA H
a(sla('l'));                                                // 25 // SLA L
a('st+='.($cpc?4:15).';'.                                   // 26 // SLA (HL)
($pag
  ? 'v=m[t=h>>6][u=l|h<<8&16383];'.sla('v').';mw[t][u]=v'
  : 't=l|h<<8;u=m[t];'.sla('u').';wb(t,u)'));
a(sla('a'));                                                // 27 // SLA A
a(sra('b'));                                                // 28 // SRA B
a(sra('c'));                                                // 29 // SRA C
a(sra('d'));                                                // 2a // SRA D
a(sra('e'));                                                // 2b // SRA E
a(sra('h'));                                                // 2c // SRA H
a(sra('l'));                                                // 2d // SRA L
a('st+='.($cpc?4:15).';'.                                   // 2e // SRA (HL)
($pag
  ? 'v=m[t=h>>6][u=l|h<<8&16383];'.sra('v').';mw[t][u]=v'
  : 't=l|h<<8;u=m[t];'.sra('u').';wb(t,u)'));
a(sra('a'));                                                // 2f // SRA A
a(sll('b'));                                                // 30 // SLL B
a(sll('c'));                                                // 31 // SLL C
a(sll('d'));                                                // 32 // SLL D
a(sll('e'));                                                // 33 // SLL E
a(sll('h'));                                                // 34 // SLL H
a(sll('l'));                                                // 35 // SLL L
a('st+='.($cpc?4:15).';'.                                   // 36 // SLL (HL)
($pag
  ? 'v=m[t=h>>6][u=l|h<<8&16383];'.sll('v').';mw[t][u]=v'
  : 't=l|h<<8;u=m[t];'.sll('u').';wb(t,u)'));
a(sll('a'));                                                // 37 // SLL A
a(srl('b'));                                                // 38 // SRL B
a(srl('c'));                                                // 39 // SRL C
a(srl('d'));                                                // 3a // SRL D
a(srl('e'));                                                // 3b // SRL E
a(srl('h'));                                                // 3c // SRL H
a(srl('l'));                                                // 3d // SRL L
a('st+='.($cpc?4:15).';'.                                   // 3e // SRL (HL)
($pag
  ? 'v=m[t=h>>6][u=l|h<<8&16383];'.srl('v').';mw[t][u]=v'
  : 't=l|h<<8;u=m[t];'.srl('u').';wb(t,u)'));
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

a(rlc('t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//00 // LD B,RLC(IY+d)
a(rlc('t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//01 // LD C,RLC(IY+d)
a(rlc('t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//02 // LD D,RLC(IY+d)
a(rlc('t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//03 // LD E,RLC(IY+d)
a(rlc('t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//04 // LD H,RLC(IY+d)
a(rlc('t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//05 // LD L,RLC(IY+d)
a(rlc('t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));   // 06 // RLC(IY+d)
a(rlc('t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//07 // LD A,RLC(IY+d)
a(rrc('t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//08 // LD B,RRC(IY+d)
a(rrc('t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//09 // LD C,RRC(IY+d)
a(rrc('t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//0a // LD D,RRC(IY+d)
a(rrc('t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//0b // LD E,RRC(IY+d)
a(rrc('t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//0c // LD H,RRC(IY+d)
a(rrc('t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//0d // LD L,RRC(IY+d)
a(rrc('t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));   // 0e // RRC(IY+d)
a(rrc('t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//0f // LD A,RRC(IY+d)
a(rl('t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));// 10 // LD B,RL(IY+d)
a(rl('t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));// 11 // LD C,RL(IY+d)
a(rl('t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));// 12 // LD D,RL(IY+d)
a(rl('t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));// 13 // LD E,RL(IY+d)
a(rl('t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));// 14 // LD H,RL(IY+d)
a(rl('t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));// 15 // LD L,RL(IY+d)
a(rl('t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));    // 16 // RL(IY+d)
a(rl('t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));// 17 // LD A,RL(IY+d)
a(rr('t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));// 18 // LD B,RR(IY+d)
a(rr('t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));// 19 // LD C,RR(IY+d)
a(rr('t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));// 1a // LD D,RR(IY+d)
a(rr('t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));// 1b // LD E,RR(IY+d)
a(rr('t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));// 1c // LD H,RR(IY+d)
a(rr('t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));// 1d // LD L,RR(IY+d)
a(rr('t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));    // 1e // RR(IY+d)
a(rr('t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));// 1f // LD A,RR(IY+d)
a(sla('t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//20 // LD B,SLA(IY+d)
a(sla('t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//21 // LD C,SLA(IY+d)
a(sla('t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//22 // LD D,SLA(IY+d)
a(sla('t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//23 // LD E,SLA(IY+d)
a(sla('t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//24 // LD H,SLA(IY+d)
a(sla('t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//25 // LD L,SLA(IY+d)
a(sla('t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));   // 26 // SLA(IY+d)
a(sla('t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//27 // LD A,SLA(IY+d)
a(sra('t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//28 // LD B,SRA(IY+d)
a(sra('t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//29 // LD C,SRA(IY+d)
a(sra('t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//2a // LD D,SRA(IY+d)
a(sra('t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//2b // LD E,SRA(IY+d)
a(sra('t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//2c // LD H,SRA(IY+d)
a(sra('t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//2d // LD L,SRA(IY+d)
a(sra('t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));   // 2e // SRA(IY+d)
a(sra('t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//2f // LD A,SRA(IY+d)
a(sll('t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//30 // LD B,SLL(IY+d)
a(sll('t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//31 // LD C,SLL(IY+d)
a(sll('t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//32 // LD D,SLL(IY+d)
a(sll('t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//33 // LD E,SLL(IY+d)
a(sll('t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//34 // LD H,SLL(IY+d)
a(sll('t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//35 // LD L,SLL(IY+d)
a(sll('t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));   // 36 // SLL(IY+d)
a(sll('t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//37 // LD A,SLL(IY+d)
a(srl('t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//38 // LD B,SRL(IY+d)
a(srl('t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//39 // LD C,SRL(IY+d)
a(srl('t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//3a // LD D,SRL(IY+d)
a(srl('t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//3b // LD E,SRL(IY+d)
a(srl('t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//3c // LD H,SRL(IY+d)
a(srl('t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//3d // LD L,SRL(IY+d)
a(srl('t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));   // 3e // SRL(IY+d)
a(srl('t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//3f // LD A,SRL(IY+d)
b('p40', biti(1));                                          // 40 // BIT 0,(IY+d)
c('p40');                                                   // 41 // BIT 0,(IY+d)
c('p40');                                                   // 42 // BIT 0,(IY+d)
c('p40');                                                   // 43 // BIT 0,(IY+d)
c('p40');                                                   // 44 // BIT 0,(IY+d)
c('p40');                                                   // 45 // BIT 0,(IY+d)
c('p40');                                                   // 46 // BIT 0,(IY+d)
c('p40');                                                   // 47 // BIT 0,(IY+d)
b('p48', biti(2));                                          // 48 // BIT 1,(IY+d)
c('p48');                                                   // 49 // BIT 1,(IY+d)
c('p48');                                                   // 4a // BIT 1,(IY+d)
c('p48');                                                   // 4b // BIT 1,(IY+d)
c('p48');                                                   // 4c // BIT 1,(IY+d)
c('p48');                                                   // 4d // BIT 1,(IY+d)
c('p48');                                                   // 4e // BIT 1,(IY+d)
c('p48');                                                   // 4f // BIT 1,(IY+d)
b('p50', biti(4));                                          // 50 // BIT 2,(IY+d)
c('p50');                                                   // 51 // BIT 2,(IY+d)
c('p50');                                                   // 52 // BIT 2,(IY+d)
c('p50');                                                   // 53 // BIT 2,(IY+d)
c('p50');                                                   // 54 // BIT 2,(IY+d)
c('p50');                                                   // 55 // BIT 2,(IY+d)
c('p50');                                                   // 56 // BIT 2,(IY+d)
c('p50');                                                   // 57 // BIT 2,(IY+d)
b('p58', biti(8));                                          // 58 // BIT 3,(IY+d)
c('p58');                                                   // 59 // BIT 3,(IY+d)
c('p58');                                                   // 5a // BIT 3,(IY+d)
c('p58');                                                   // 5b // BIT 3,(IY+d)
c('p58');                                                   // 5c // BIT 3,(IY+d)
c('p58');                                                   // 5d // BIT 3,(IY+d)
c('p58');                                                   // 5e // BIT 3,(IY+d)
c('p58');                                                   // 5f // BIT 3,(IY+d)
b('p60', biti(16));                                         // 60 // BIT 4,(IY+d)
c('p60');                                                   // 61 // BIT 4,(IY+d)
c('p60');                                                   // 62 // BIT 4,(IY+d)
c('p60');                                                   // 63 // BIT 4,(IY+d)
c('p60');                                                   // 64 // BIT 4,(IY+d)
c('p60');                                                   // 65 // BIT 4,(IY+d)
c('p60');                                                   // 66 // BIT 4,(IY+d)
c('p60');                                                   // 67 // BIT 4,(IY+d)
b('p68', biti(32));                                         // 68 // BIT 5,(IY+d)
c('p68');                                                   // 69 // BIT 5,(IY+d)
c('p68');                                                   // 6a // BIT 5,(IY+d)
c('p68');                                                   // 6b // BIT 5,(IY+d)
c('p68');                                                   // 6c // BIT 5,(IY+d)
c('p68');                                                   // 6d // BIT 5,(IY+d)
c('p68');                                                   // 6e // BIT 5,(IY+d)
c('p68');                                                   // 7f // BIT 5,(IY+d)
b('p70', biti(64));                                         // 70 // BIT 6,(IY+d)
c('p70');                                                   // 71 // BIT 6,(IY+d)
c('p70');                                                   // 72 // BIT 6,(IY+d)
c('p70');                                                   // 73 // BIT 6,(IY+d)
c('p70');                                                   // 74 // BIT 6,(IY+d)
c('p70');                                                   // 75 // BIT 6,(IY+d)
c('p70');                                                   // 76 // BIT 6,(IY+d)
c('p70');                                                   // 77 // BIT 6,(IY+d)
b('p78', biti(128));                                        // 78 // BIT 7,(IY+d)
c('p78');                                                   // 79 // BIT 7,(IY+d)
c('p78');                                                   // 7a // BIT 7,(IY+d)
c('p78');                                                   // 7b // BIT 7,(IY+d)
c('p78');                                                   // 7c // BIT 7,(IY+d)
c('p78');                                                   // 7d // BIT 7,(IY+d)
c('p78');                                                   // 7e // BIT 7,(IY+d)
c('p78');                                                   // 7f // BIT 7,(IY+d)
a(res(254,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//80//LD B,RES 0,(IY+d)
a(res(254,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//81//LD C,RES 0,(IY+d)
a(res(254,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//82//LD D,RES 0,(IY+d)
a(res(254,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//83//LD E,RES 0,(IY+d)
a(res(254,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//84//LD H,RES 0,(IY+d)
a(res(254,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//85//LD L,RES 0,(IY+d)
a(res(254,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));//86 // RES 0,(IY+d)
a(res(254,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//87//LD A,RES 0,(IY+d)
a(res(253,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//88//LD B,RES 1,(IY+d)
a(res(253,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//89//LD C,RES 1,(IY+d)
a(res(253,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//8a//LD D,RES 1,(IY+d)
a(res(253,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//8b//LD E,RES 1,(IY+d)
a(res(253,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//8c//LD H,RES 1,(IY+d)
a(res(253,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//8d//LD L,RES 1,(IY+d)
a(res(253,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));//8e // RES 1,(IY+d)
a(res(253,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//8f//LD A,RES 1,(IY+d)
a(res(251,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//90//LD B,RES 2,(IY+d)
a(res(251,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//91//LD C,RES 2,(IY+d)
a(res(251,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//92//LD D,RES 2,(IY+d)
a(res(251,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//93//LD E,RES 2,(IY+d)
a(res(251,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//94//LD H,RES 2,(IY+d)
a(res(251,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//95//LD L,RES 2,(IY+d)
a(res(251,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));//96 // RES 2,(IY+d)
a(res(251,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//97//LD A,RES 2,(IY+d)
a(res(247,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//98//LD B,RES 3,(IY+d)
a(res(247,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//99//LD C,RES 3,(IY+d)
a(res(247,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//9a//LD D,RES 3,(IY+d)
a(res(247,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//9b//LD E,RES 3,(IY+d)
a(res(247,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//9c//LD H,RES 3,(IY+d)
a(res(247,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//9d//LD L,RES 3,(IY+d)
a(res(247,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));//9e // RES 3,(IY+d)
a(res(247,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//9f//LD A,RES 3,(IY+d)
a(res(239,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//a0//LD B,RES 4,(IY+d)
a(res(239,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//a1//LD C,RES 4,(IY+d)
a(res(239,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//a2//LD D,RES 4,(IY+d)
a(res(239,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//a3//LD E,RES 4,(IY+d)
a(res(239,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//a4//LD H,RES 4,(IY+d)
a(res(239,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//a5//LD L,RES 4,(IY+d)
a(res(239,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));//a6 // RES 4,(IY+d)
a(res(239,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//a7//LD A,RES 4,(IY+d)
a(res(223,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//a8//LD B,RES 5,(IY+d)
a(res(223,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//a9//LD C,RES 5,(IY+d)
a(res(223,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//aa//LD D,RES 5,(IY+d)
a(res(223,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//ab//LD E,RES 5,(IY+d)
a(res(223,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//ac//LD H,RES 5,(IY+d)
a(res(223,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//ad//LD L,RES 5,(IY+d)
a(res(223,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));//ae // RES 5,(IY+d)
a(res(223,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//af//LD A,RES 5,(IY+d)
a(res(191,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//a0//LD B,RES 6,(IY+d)
a(res(191,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//b1//LD C,RES 6,(IY+d)
a(res(191,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//b2//LD D,RES 6,(IY+d)
a(res(191,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//b3//LD E,RES 6,(IY+d)
a(res(191,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//b4//LD H,RES 6,(IY+d)
a(res(191,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//b5//LD L,RES 6,(IY+d)
a(res(191,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));//b6 // RES 6,(IY+d)
a(res(191,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//b7//LD A,RES 6,(IY+d)
a(res(127,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//b8//LD B,RES 7,(IY+d)
a(res(127,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//b9//LD C,RES 7,(IY+d)
a(res(127,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//ba//LD D,RES 7,(IY+d)
a(res(127,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//bb//LD E,RES 7,(IY+d)
a(res(127,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//bc//LD H,RES 7,(IY+d)
a(res(127,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//bd//LD L,RES 7,(IY+d)
a(res(127,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));//be // RES 7,(IY+d)
a(res(127,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//bf//LD A,RES 7,(IY+d)
a(set(1,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//c0//LD B,SET 0,(IY+d)
a(set(1,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//c1//LD C,SET 0,(IY+d)
a(set(1,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//c2//LD D,SET 0,(IY+d)
a(set(1,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//c3//LD E,SET 0,(IY+d)
a(set(1,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//c4//LD H,SET 0,(IY+d)
a(set(1,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//c5//LD L,SET 0,(IY+d)
a(set(1,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)')); // c6 // SET 0,(IY+d)
a(set(1,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//c7//LD A,SET 0,(IY+d)
a(set(2,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//c8//LD B,SET 1,(IY+d)
a(set(2,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//c9//LD C,SET 1,(IY+d)
a(set(2,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//ca//LD D,SET 1,(IY+d)
a(set(2,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//cb//LD E,SET 1,(IY+d)
a(set(2,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//cc//LD H,SET 1,(IY+d)
a(set(2,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//cd//LD L,SET 1,(IY+d)
a(set(2,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)')); // ce // SET 1,(IY+d)
a(set(2,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//cf//LD A,SET 1,(IY+d)
a(set(4,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//d0//LD B,SET 2,(IY+d)
a(set(4,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//d1//LD C,SET 2,(IY+d)
a(set(4,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//d2//LD D,SET 2,(IY+d)
a(set(4,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//d3//LD E,SET 2,(IY+d)
a(set(4,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//d4//LD H,SET 2,(IY+d)
a(set(4,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//d5//LD L,SET 2,(IY+d)
a(set(4,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)')); // d6 // SET 2,(IY+d)
a(set(4,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//d7//LD A,SET 2,(IY+d)
a(set(8,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//d8//LD B,SET 3,(IY+d)
a(set(8,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//d9//LD C,SET 3,(IY+d)
a(set(8,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//da//LD D,SET 3,(IY+d)
a(set(8,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//db//LD E,SET 3,(IY+d)
a(set(8,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//dc//LD H,SET 3,(IY+d)
a(set(8,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//dd//LD L,SET 3,(IY+d)
a(set(8,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)')); // de // SET 3,(IY+d)
a(set(8,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//df//LD A,SET 3,(IY+d)
a(set(16,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//e0//LD B,SET 4,(IY+d)
a(set(16,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//e1//LD C,SET 4,(IY+d)
a(set(16,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//e2//LD D,SET 4,(IY+d)
a(set(16,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//e3//LD E,SET 4,(IY+d)
a(set(16,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//e4//LD H,SET 4,(IY+d)
a(set(16,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//e5//LD L,SET 4,(IY+d)
a(set(16,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));// e6 // SET 4,(IY+d)
a(set(16,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//e7//LD A,SET 4,(IY+d)
a(set(32,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//e8//LD B,SET 5,(IY+d)
a(set(32,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//e9//LD C,SET 5,(IY+d)
a(set(32,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//ea//LD D,SET 5,(IY+d)
a(set(32,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//eb//LD E,SET 5,(IY+d)
a(set(32,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//ec//LD H,SET 5,(IY+d)
a(set(32,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//ed//LD L,SET 5,(IY+d)
a(set(32,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));// ee // SET 5,(IY+d)
a(set(32,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//ef//LD A,SET 5,(IY+d)
a(set(64,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//f0//LD B,SET 6,(IY+d)
a(set(64,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//f1//LD C,SET 6,(IY+d)
a(set(64,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//f2//LD D,SET 6,(IY+d)
a(set(64,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//f3//LD E,SET 6,(IY+d)
a(set(64,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//f4//LD H,SET 6,(IY+d)
a(set(64,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//f5//LD L,SET 6,(IY+d)
a(set(64,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));// f6 // SET 6,(IY+d)
a(set(64,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//f7//LD A,SET 6,(IY+d)
a(set(128,'t').($pag?';b=mw[mp>>14][mp&16383]=t':';wb(mp,b=t)'));//f8//LD B,SET 7,(IY+d)
a(set(128,'t').($pag?';c=mw[mp>>14][mp&16383]=t':';wb(mp,c=t)'));//f9//LD C,SET 7,(IY+d)
a(set(128,'t').($pag?';d=mw[mp>>14][mp&16383]=t':';wb(mp,d=t)'));//fa//LD D,SET 7,(IY+d)
a(set(128,'t').($pag?';e=mw[mp>>14][mp&16383]=t':';wb(mp,e=t)'));//fb//LD E,SET 7,(IY+d)
a(set(128,'t').($pag?';h=mw[mp>>14][mp&16383]=t':';wb(mp,h=t)'));//fc//LD H,SET 7,(IY+d)
a(set(128,'t').($pag?';l=mw[mp>>14][mp&16383]=t':';wb(mp,l=t)'));//fd//LD L,SET 7,(IY+d)
a(set(128,'t').($pag?';mw[mp>>14][mp&16383]=t':';wb(mp,t)'));//fe // SET 7,(IY+d)
a(set(128,'t').($pag?';a=mw[mp>>14][mp&16383]=t':';wb(mp,a=t)'));//ff//LD A,SET 7,(IY+d)

b('p00', nop($cpc?2:8));                                    // 00 // NOP
c('p00');                                                   // 01 // NOP
c('p00');                                                   // 02 // NOP
c('p00');                                                   // 03 // NOP
c('p00');                                                   // 04 // NOP
c('p00');                                                   // 05 // NOP
c('p00');                                                   // 06 // NOP
c('p00');                                                   // 07 // NOP
c('p00');                                                   // 08 // NOP
c('p00');                                                   // 09 // NOP
c('p00');                                                   // 0a // NOP
c('p00');                                                   // 0b // NOP
c('p00');                                                   // 0c // NOP
c('p00');                                                   // 0d // NOP
c('p00');                                                   // 0e // NOP
c('p00');                                                   // 0f // NOP
c('p00');                                                   // 10 // NOP
c('p00');                                                   // 11 // NOP
c('p00');                                                   // 12 // NOP
c('p00');                                                   // 13 // NOP
c('p00');                                                   // 14 // NOP
c('p00');                                                   // 15 // NOP
c('p00');                                                   // 16 // NOP
c('p00');                                                   // 17 // NOP
c('p00');                                                   // 18 // NOP
c('p00');                                                   // 19 // NOP
c('p00');                                                   // 1a // NOP
c('p00');                                                   // 1b // NOP
c('p00');                                                   // 1c // NOP
c('p00');                                                   // 1d // NOP
c('p00');                                                   // 1e // NOP
c('p00');                                                   // 1f // NOP
c('p00');                                                   // 20 // NOP
c('p00');                                                   // 21 // NOP
c('p00');                                                   // 22 // NOP
c('p00');                                                   // 23 // NOP
c('p00');                                                   // 24 // NOP
c('p00');                                                   // 25 // NOP
c('p00');                                                   // 26 // NOP
c('p00');                                                   // 27 // NOP
c('p00');                                                   // 28 // NOP
c('p00');                                                   // 29 // NOP
c('p00');                                                   // 2a // NOP
c('p00');                                                   // 2b // NOP
c('p00');                                                   // 2c // NOP
c('p00');                                                   // 2d // NOP
c('p00');                                                   // 2e // NOP
c('p00');                                                   // 2f // NOP
c('p00');                                                   // 30 // NOP
c('p00');                                                   // 31 // NOP
c('p00');                                                   // 32 // NOP
c('p00');                                                   // 33 // NOP
c('p00');                                                   // 34 // NOP
c('p00');                                                   // 35 // NOP
c('p00');                                                   // 36 // NOP
c('p00');                                                   // 37 // NOP
c('p00');                                                   // 38 // NOP
c('p00');                                                   // 39 // NOP
c('p00');                                                   // 3a // NOP
c('p00');                                                   // 3b // NOP
c('p00');                                                   // 3c // NOP
c('p00');                                                   // 3d // NOP
c('p00');                                                   // 3e // NOP
c('p00');                                                   // 3f // NOP
a(inr('b'));                                                // 40 // IN B,(C)
a(outr('b'));                                               // 41 // OUT (C),B
a(sbchlrr('b', 'c'));                                       // 42 // SBC HL,BC
a(ldpnnrr('b', 'c', $cpc?6:20));                            // 43 // LD (NN),BC
b('o44', neg());                                            // 44 // NEG
b('o45', ret($cpc?4:14));                                   // 45 // RETN
b('o46', 'st+='.($cpc?2:8).';im=0');                        // 46 // IM 0
a(ldrr('i', 'a', $cpc?3:9));                                // 47 // LD I,A
a(inr('c'));                                                // 48 // IN C,(C)
a(outr('c'));                                               // 49 // OUT (C),C
a(adchlrr('b', 'c'));                                       // 4a // ADC HL,BC
a(ldrrpnn('b', 'c', $cpc?6:20));                            // 4b // LD BC,(NN)
c('o44');                                                   // 4c // NEG
c('o45');                                                   // 4d // RETI
c('o46');                                                   // 4e // IM 0
a(ldrr('r=r7', 'a', $cpc?3:9));                             // 4f // LD R,A
a(inr('d'));                                                // 50 // IN D,(C)
a(outr('d'));                                               // 51 // OUT (C),D
a(sbchlrr('d', 'e'));                                       // 52 // SBC HL,DE
a(ldpnnrr('d', 'e', $cpc?6:20));                            // 53 // LD (NN),DE
c('o44');                                                   // 54 // NEG
c('o45');                                                   // 55 // RETN
b('o56', 'st+='.($cpc?2:8).';im=1');                        // 56 // IM 1
a(ldair('i'));                                              // 57 // LD A,I
a(inr('e'));                                                // 58 // IN E,(C)
a(outr('e'));                                               // 59 // OUT (C),E
a(adchlrr('d', 'e'));                                       // 5a // ADC HL,DE
a(ldrrpnn('d', 'e', $cpc?6:20));                            // 5b // LD DE,(NN)
c('o44');                                                   // 5c // NEG
c('o45');                                                   // 5d // RETI
b('o5e', 'st+='.($cpc?2:8).';im=2');                        // 5e // IM 2
a(ldair('(r&127|r7&128)'));                                 // 5f // LD A,R
a(inr('h'));                                                // 60 // IN H,(C)
a(outr('h'));                                               // 61 // OUT (C),H
a(sbchlrr('h', 'l'));                                       // 62 // SBC HL,HL
a(ldpnnrr('h', 'l', $cpc?6:20));                            // 63 // LD (NN),HL
c('o44');                                                   // 64 // NEG
c('o45');                                                   // 65 // RETN
c('o46');                                                   // 66 // IM 0
a('st+='.($cpc?5:18).';'.                                   // 67 // RRD
($pag
  ? 't=m[u='.($mp?'(mp=l|h<<8)>>14][v=mp':'h>>6][v=l|h<<8').'&16383]|a<<8;'.
    'a=a&240|t&15;'.
    'ff=ff&-256|(fr=a);'.
    'fa=a|256;'.
    'fb=0;'.
    'mw[u][v]=t>>4&255'
  : 't=m[mp=l|h<<8]|a<<8;'.
    'a=a&240|t&15;'.
    'ff=ff&-256|(fr=a);'.
    'fa=a|256;'.
    'fb=0;'.
    'wb(mp,t>>4&255)').
  ($mp?';++mp':''));
a(inr('l'));                                                // 68 // IN L,(C)
a(outr('l'));                                               // 69 // OUT (C),L
a(adchlrr('h', 'l'));                                       // 6a // ADC HL,HL
a(ldrrpnn('h', 'l', $cpc?6:20));                            // 6b // LD HL,(NN)
c('o44');                                                   // 6c // NEG
c('o45');                                                   // 6d // RETI
c('o46');                                                   // 6e // IM 0
a('st+='.($cpc?5:18).';'.                                   // 6f // RLD
($pag
  ? 't=m[u='.($mp?'(mp=l|h<<8)>>14][v=mp':'h>>6][v=l|h<<8').'&16383]<<4|a&15;'.
    'a=a&240|t>>8;'.
    'ff=ff&-256|(fr=a);'.
    'fa=a|256;'.
    'fb=0;'.
    'mw[u][v]=t&255'
  : 't=m[mp=l|h<<8]<<4|a&15;'.
    'a=a&240|t>>8;'.
    'ff=ff&-256|(fr=a);'.
    'fa=a|256;'.
    'fb=0;'.
    'wb(mp,t&255)').
  ($mp?';++mp':''));
a(inr('t'));                                                // 70 // IN X,(C)
a(outr('0'));                                               // 71 // OUT (C),X
a('st+='.($cpc?4:15).';'.                                   // 72 // SBC HL,SP
  't=('.($mp?'mp=':'').'l|h<<8)-sp-(ff>>8&1);'.
  ($mp?'++mp;':'').
  'ff=t>>8;'.
  'fa=h;'.
  'fb=~sp>>8;'.
  'h=t>>8&255;'.
  'l=t&255;'.
  'fr=t>>8|t<<8');
a('st+='.($cpc?6:20).';'.                                   // 73 // LD (NN),SP
($pag
  ? 'mw[(mp=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][mp&16383]=sp&255;'.
    'mw[++mp>>14][mp&16383]=sp>>8'
  : 'wb('.($mp?'mp':'t').'=m[pc++&65535]|m[pc++&65535]<<8,sp&255);'.
    'wb('.($mp?'mp=mp':'t').'+1&65535,sp>>8)'));
c('o44');                                                   // 74 // NEG
c('o45');                                                   // 75 // RETN
c('o56');                                                   // 76 // IM 1
c('p00');                                                   // 77 // NOP
a(inr('a'));                                                // 78 // IN A,(C)
a(outr('a'));                                               // 79 // OUT (C),A
a('st+='.($cpc?4:15).';'.                                   // 7a // ADC HL,SP
  't=('.($mp?'mp=':'').'l|h<<8)+sp+(ff>>8&1);'.
  ($mp?'++mp;':'').
  'ff=t>>8;'.
  'fa=h;'.
  'fb=sp>>8;'.
  'h=t>>8&255;'.
  'l=t&255;'.
  'fr=h|l<<8');
a('st+='.($cpc?6:20).';'.                                   // 7b // LD SP,(NN)
($pag
  ? 'sp=m[(mp=m[pc>>14&3][pc++&16383]|m[pc>>14&3][pc++&16383]<<8)>>14][mp&16383]|m[++mp>>14][mp&16383]<<8'
  : 'sp=m[t=m[pc++&65535]|m[pc++&65535]<<8]|m['.($mp?'mp=':'').'t+1&65535]<<8'));
c('o44');                                                   // 7c // NEG
c('o45');                                                   // 7d // RETI
c('o5e');                                                   // 7e // IM 2
c('p00');                                                   // 7f // NOP
c('p00');                                                   // 80 // NOP
c('p00');                                                   // 81 // NOP
c('p00');                                                   // 82 // NOP
c('p00');                                                   // 83 // NOP
c('p00');                                                   // 84 // NOP
c('p00');                                                   // 85 // NOP
c('p00');                                                   // 86 // NOP
c('p00');                                                   // 87 // NOP
c('p00');                                                   // 88 // NOP
c('p00');                                                   // 89 // NOP
c('p00');                                                   // 8a // NOP
c('p00');                                                   // 8b // NOP
c('p00');                                                   // 8c // NOP
c('p00');                                                   // 8d // NOP
c('p00');                                                   // 8e // NOP
c('p00');                                                   // 8f // NOP
c('p00');                                                   // 90 // NOP
c('p00');                                                   // 91 // NOP
c('p00');                                                   // 92 // NOP
c('p00');                                                   // 93 // NOP
c('p00');                                                   // 94 // NOP
c('p00');                                                   // 95 // NOP
c('p00');                                                   // 96 // NOP
c('p00');                                                   // 97 // NOP
c('p00');                                                   // 98 // NOP
c('p00');                                                   // 99 // NOP
c('p00');                                                   // 9a // NOP
c('p00');                                                   // 9b // NOP
c('p00');                                                   // 9c // NOP
c('p00');                                                   // 9d // NOP
c('p00');                                                   // 9e // NOP
c('p00');                                                   // 9f // NOP
a(ldid(1, 0));                                              // a0 // LDI
a(cpid(1, 0));                                              // a1 // CPI
a(inid(1, 0));                                              // a2 // INI
a(otid(1, 0));                                              // a3 // OUTI
c('p00');                                                   // a4 // NOP
c('p00');                                                   // a5 // NOP
c('p00');                                                   // a6 // NOP
c('p00');                                                   // a7 // NOP
a(ldid(0, 0));                                              // a8 // LDD
a(cpid(0, 0));                                              // a9 // CPD
a(inid(0, 0));                                              // aa // IND
a(otid(0, 0));                                              // ab // OUTD
c('p00');                                                   // ac // NOP
c('p00');                                                   // ad // NOP
c('p00');                                                   // ae // NOP
c('p00');                                                   // af // NOP
a(ldid(1, 1));                                              // b0 // LDIR
a(cpid(1, 1));                                              // b1 // CPIR
a(inid(1, 1));                                              // b2 // INIR
a(otid(1, 1));                                              // b3 // OTIR
c('p00');                                                   // b4 // NOP
c('p00');                                                   // b5 // NOP
c('p00');                                                   // b6 // NOP
c('p00');                                                   // b7 // NOP
a(ldid(0, 1));                                              // b8 // LDDR
a(cpid(0, 1));                                              // b9 // CPDR
a(inid(0, 1));                                              // ba // INDR
a(otid(0, 1));                                              // bb // OTDR
c('p00');                                                   // bc // NOP
c('p00');                                                   // bd // NOP
c('p00');                                                   // be // NOP
c('p00');                                                   // bf // NOP
c('p00');                                                   // c0 // NOP
c('p00');                                                   // c1 // NOP
c('p00');                                                   // c2 // NOP
c('p00');                                                   // c3 // NOP
c('p00');                                                   // c4 // NOP
c('p00');                                                   // c5 // NOP
c('p00');                                                   // c6 // NOP
c('p00');                                                   // c7 // NOP
c('p00');                                                   // c8 // NOP
c('p00');                                                   // c9 // NOP
c('p00');                                                   // ca // NOP
c('p00');                                                   // cb // NOP
c('p00');                                                   // cc // NOP
c('p00');                                                   // cd // NOP
c('p00');                                                   // ce // NOP
c('p00');                                                   // cf // NOP
c('p00');                                                   // d0 // NOP
c('p00');                                                   // d1 // NOP
c('p00');                                                   // d2 // NOP
c('p00');                                                   // d3 // NOP
c('p00');                                                   // d4 // NOP
c('p00');                                                   // d5 // NOP
c('p00');                                                   // d6 // NOP
c('p00');                                                   // d7 // NOP
c('p00');                                                   // d8 // NOP
c('p00');                                                   // d9 // NOP
c('p00');                                                   // da // NOP
c('p00');                                                   // db // NOP
c('p00');                                                   // dc // NOP
c('p00');                                                   // dd // NOP
c('p00');                                                   // de // NOP
c('p00');                                                   // df // NOP
c('p00');                                                   // e0 // NOP
c('p00');                                                   // e1 // NOP
c('p00');                                                   // e2 // NOP
c('p00');                                                   // e3 // NOP
c('p00');                                                   // e4 // NOP
c('p00');                                                   // e5 // NOP
c('p00');                                                   // e6 // NOP
c('p00');                                                   // e7 // NOP
c('p00');                                                   // e8 // NOP
c('p00');                                                   // e9 // NOP
c('p00');                                                   // ea // NOP
c('p00');                                                   // eb // NOP
c('p00');                                                   // ec // NOP
c('p00');                                                   // ed // NOP
c('p00');                                                   // ee // NOP
c('p00');                                                   // ef // NOP
c('p00');                                                   // f0 // NOP
c('p00');                                                   // f1 // NOP
c('p00');                                                   // f2 // NOP
c('p00');                                                   // f3 // NOP
c('p00');                                                   // f4 // NOP
c('p00');                                                   // f5 // NOP
c('p00');                                                   // f6 // NOP
c('p00');                                                   // f7 // NOP
c('p00');                                                   // f8 // NOP
c('p00');                                                   // f9 // NOP
c('p00');                                                   // fa // NOP
c('p00');                                                   // fb // NOP
a('loadblock()');                                           // fc // tape loader trap
c('p00');                                                   // fd // NOP
c('p00');                                                   // fe // NOP
c('p00');                                                   // ff // NOP
?>
];