sz= [];                              // sign, zero, flag5, flag3 table
par= [];                             // parity table
szp= [];                             // sign, zero... parity table
szi= [];                             // sign, zero... increment table
szd= [];                             // sign, zero... decrement table
se= [];                              // sign extend

function init6502() {
  for(j= 0; j<256; j++)
    se[j]= j < 128 ? j : j-256,
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
    szp[j]= sz[j] | par[j],
    szi[j]= sz[j] | ( j == 128 ? 4 : 0 ) | ( j&15 ? 0 : 16 ),
    szd[j]= sz[j] | ( j == 127 ? 6 : 2 ) | ( j+1 & 15 ? 0 : 16 );
  szi[0] |= 64;
  szd[0] |= 64;
  sz[0] |= 2;
  szp[0] |= 64;
}

function interrupt6502() {
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

function jrc(c) {
  return 'if('+c+')'+
    'st+=2,'+
    'pc++;'+
  'else '+
    't=pc,'
    'pc+=se[m[pc&65535]]+1,'
    'st+=(t^pc)&65280?2:1'+ //0xff00
}

p=[                           
'st+=7;wb(--sp&255|256,pc>>8&255);'+  // 00 BRK
'wb(--sp&255|256,pc&255);'+
'wb((sp=sp-1&255)|256,f|16);'+
'f=f&247|4;'+                           // f&0xf7|0x04 set i, reset d
'pc=m[65534]|m[65535]<<8',
'st+=6;t=m[pc++&65535]+x&255;'+     // 01 ORA X, ind
'f=f&125|sz[a|=m[m[t]|m[t+1&255]<<8]]',
nop(2),                       // 02 illegal
nop(8),                       // 03 illegal
nop(3),                       // 04 illegal
'st+=3;f=f&125|sz[a|=m[m[pc++&65535]]]',// 05 ORA zpg
'st+=5;t=m[u=m[pc++&65535]];'+      // 06 ASL zpg
'f=t>>7|f&124|sz[t=t<<1&255];'+
'wb(u,t)',
nop(5),                       // 07 illegal
'st+=3;wb(sp++|256,f);'+      // 08 PHP
'sp&=255',
'st+=2;f=f&125|sz[a|=m[pc++&65535]]',   // 09 ORA imm
'st+=2;f=a>>7|f&124|sz[a=a<<1&255]',// 0A ASLA
nop(2),                       // 0B illegal
nop(4),                       // 0C illegal
'st+=4;f=f&125|sz[a|=m[m[pc++&65535]|m[pc++&65535]<<8]]', // 0D ORA abs
'st+=6;t=m[u=m[pc++&65535]|m[pc++&65535]<<8];', // 0E ASL abs
'f=t>>7|f&124|sz[t=t<<1&255];'+
'wb(u,t)',
nop(6),                       // 0F illegal
'pc+=se[m[pc&65535]]+1'
jrc(~f&128),                  // 10 BPL rel
'st+=5;t=m[pc++&65535];'+     // 11 ORA ind, Y
'f=f&125|sz[a|=m[m[t]+y+(m[t+1&255]<<8)&65535]]',
nop(2),                       // 12 illegal
nop(8),                       // 13 illegal
nop(3),                       // 14 illegal
'st+=3;f=f&125|sz[a|=m[m[pc++&65535]]]',// 15 ORA zpg,X


];

g= [];
for (j=0; j<256; j++)
  g[j]= new Function(p[j]);
