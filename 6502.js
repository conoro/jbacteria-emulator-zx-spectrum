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
  return 'st+=2;'+
  'if('+c+')'+
    'pc++;'+
  'else '+
    't=pc,'
    'pc+=se[m[pc&65535]]+1,'
    'st+=(t^pc)&65280?2:1'+ //0xff00
}

function ora(n, a, b){
  return 'st+='+n+a
    ';f=f&125|sz[a|='+b+']';
}

function and(n, a, b){
  return 'st+='+n+a
    ';f=f&125|sz[a&='+b+']';
}

function eor(n, a, b){
  return 'st+='+n+a
    ';f=f&125|sz[a^='+b+']';
}

function adc(n, a){ // Ricoh 2A03
  return 'st+='+n+
    ';t='+a+
    ';u=t+a+f&1;'+
    'f=f&60|u>>8|((u^a)&(u^t)&128)>>1|sz[a=u&255]';
}

function aslm(n, a, b){
  return 'st+='+n+';'+
    't='+a+';'+
    'f=t>>7|f&124|sz[t=t<<1&255];'+
    'wb(u,t)';
}

function rolm(n, a, b){
  return 'st+='+n+';'+
    't='+a+';'+
    'f=t>>7|f&124|sz[t=t<<1&255|f&1];'+
    'wb(u,t)';
}

function lsrm(n, a, b){
  return 'st+='+n+';'+
    't='+a+';'+
    'f=t&1|f&124|sz[t>>=1];'+
    'wb(u,t)';
}

function rorm(n, a, b){
  return 'st+='+n+';'+
    't='+a+';'+
    'f=t&1|f&124|sz[t=t>>1|f<<7&128];'+
    'wb(u,t)';
}

function bit(n, a){
  return 'st+='+n+';'+
    't='+a+';'+
    'f&=61|t&192|a&t';
}

function sta(n, a, b){
  return 'st+='+n+a+
    ';wb('+b+',a)';
}

p=[                           
'st+=7;wb(--sp&255|256,pc>>8&255);'+                // 00 BRK
'wb(--sp&255|256,pc&255);'+
'wb((sp=sp-1&255)|256,f|16);'+
'f=f&247|4;'+// f&0xf7|0x04 set i, reset d
'pc=m[65534]|m[65535]<<8',
ora(6, ';t=m[pc++&65535]+x&255',                    // 01 ORA X, ind
    'm[m[t]|m[t+1&255]<<8]'),
nop(2),                                             // 02 illegal
nop(8),                                             // 03 illegal
nop(3),                                             // 04 illegal
ora(3, '', 'm[m[pc++&65535]]'),                     // 05 ORA zpg
aslm(5, 'm[u=m[pc++&65535]]'),                      // 06 ASL zpg
nop(5),                                             // 07 illegal
'st+=3;wb(sp++|256,f);'+                            // 08 PHP
'sp&=255',
ora(2, '', 'm[pc++&65535]'),                        // 09 ORA imm
'st+=2;f=a>>7|f&124|sz[a=a<<1&255]',                // 0A ASLA
nop(2),                                             // 0B illegal
nop(4),                                             // 0C illegal
ora(4, '', 'm[m[pc++&65535]|m[pc++&65535]<<8]'),    // 0D ORA abs
aslm(6, 'm[u=m[pc++&65535]|m[pc++&65535]<<8]'),     // 0E ASL abs
nop(6),                                             // 0F illegal
jrc(~f&128),                                        // 10 BPL rel
ora(5, ';t=m[pc++&65535];st+=(u=m[t]+y)>255',       // 11 ORA ind, Y
    'm[u+(m[t+1&255]<<8)&65535]'),
nop(2),                                             // 12 illegal
nop(8),                                             // 13 illegal
nop(4),                                             // 14 illegal
ora(4, '', 'm[x+m[pc++&65535]&255]'),               // 15 ORA zpg, X
aslm(6, 'm[u=x+m[pc++&65535]&255]'),                // 16 ASL zpg, X
nop(6),                                             // 17 illegal
'st+=2;f&=254',                                     // 18 CLC
ora(4, 't=m[pc++&65535];st+=(t=m[t]+y)>255;',       // 19 ORA abs, Y
    'm[t+(m[pc++&65535]<<8)&65535]'),
nop(2),                                             // 1A illegal
nop(7),                                             // 1B illegal
nop(5),                                             // 1C illegal
ora(5, 't=m[pc++&65535];st+=(t=m[t]+x)>255;',       // 1D ORA abs, X
    'm[t+(m[pc++&65535]<<8)&65535]'),
aslm(7,                                             // 1E ASL abs, X
  'm[u=x+m[pc++&65535]+(m[pc++&65535]<<8)&65535]'),
nop(7),                                             // 1F illegal
'st+=6;t=pc+1&65535;'+                              // 20 JSR abs
'pc=m[pc&65535]|m[t]<<8;'+
'wb(--sp&255|256,t>>8);'+
'wb((sp=sp-1&255)|256,t&255)',
and(6, ';t=m[pc++&65535]+x&255',                    // 21 AND X, ind
    'm[m[t]|m[t+1&255]<<8]'),
nop(2),                                             // 22 illegal
nop(8),                                             // 23 illegal
bit(3, 'm[m[pc++&65535]]'),                         // 24 BIT zpg
and(3, '', 'm[m[pc++&65535]]'),                     // 25 AND zpg
rolm(5, 'm[u=m[pc++&65535]]'),                      // 26 ROL zpg
nop(5),                                             // 27 illegal
'st+=4;f=m[(sp=sp+1&255)|256]'+                     // 28 PLP
and(2, '', 'm[pc++&65535]'),                        // 29 AND imm
'st+=2;f=a>>7|f&124|sz[a=a<<1&255|f&1]',            // 2A ROLA
nop(2),                                             // 2B illegal
bit(4, 'm[m[pc++&65535]|m[pc++&65535]<<8]'),        // 2C BIT abs
and(4, '', 'm[m[pc++&65535]|m[pc++&65535]<<8]'),    // 2D AND abs
rolm(6, 'm[u=m[pc++&65535]|m[pc++&65535]<<8]'),     // 2E ROL abs
nop(6),                                             // 2F illegal
jrc(f&128),                                         // 30 BMI rel
and(5, ';t=m[pc++&65535];st+=(u=m[t]+y)>255',       // 31 AND ind, Y
    'm[u+(m[t+1&255]<<8)&65535]'),
nop(2),                                             // 32 illegal
nop(8),                                             // 33 illegal
nop(4),                                             // 34 illegal
and(4, '', 'm[x+m[pc++&65535]&255]'),               // 35 AND zpg, X
rolm(6, 'm[u=x+m[pc++&65535]&255]'),                // 36 ROL zpg, X
nop(6),                                             // 37 illegal
'st+=2;f|=1',                                       // 38 SEC
and(4, ';t=m[pc++&65535];st+=(t=m[t]+y)>255',       // 39 AND abs, Y
    'm[t+(m[pc++&65535]<<8)&65535]'),
nop(2),                                             // 3A illegal
nop(7),                                             // 3B illegal
nop(5),                                             // 3C illegal
and(5, ';t=m[pc++&65535];st+=(t=m[t]+x)>255',       // 3D AND abs, X
    'm[t+(m[pc++&65535]<<8)&65535]'),
rolm(7,                                             // 3E ROL abs, X
  'm[u=x+m[pc++&65535]+(m[pc++&65535]<<8)&65535]'),
nop(7),                                             // 3F illegal
'st+=6;f=m[sp+1&255|256];'+                         // 40 RTI
'pc=m[sp+2&255|256]|m[(sp=sp+3&255)|256]<<8'+
eor(6, ';t=m[pc++&65535]+x&255',                    // 41 EOR X, ind
    'm[m[t]|m[t+1&255]<<8]'),
nop(2),                                             // 42 illegal
nop(8),                                             // 43 illegal
nop(3),                                             // 44 illegal
eor(3, '', 'm[m[pc++&65535]]'),                     // 45 EOR zpg
lsrm(5, 'm[u=m[pc++&65535]]'),                      // 46 LSR zpg
nop(5),                                             // 47 illegal
'st+=3;wb(sp++|256,a);'+                            // 48 PHA
'sp&=255',
eor(2, '', 'm[pc++&65535]'),                        // 49 EOR imm
'st+=2;f=a&1|f&124|sz[a>>=1]',                      // 4A LSRA
nop(2),                                             // 4B illegal
'st+=3;pc=m[pc&65535]|m[pc+1&65535]<<8',            // 4C JMP abs
eor(4, '', 'm[m[pc++&65535]|m[pc++&65535]<<8]'),    // 4D EOR abs
lsrm(6, 'm[u=m[pc++&65535]|m[pc++&65535]<<8]'),     // 4E LSR abs
nop(6),                                             // 4F illegal
jrc(~f&64),                                         // 50 BVC rel
eor(5, ';t=m[pc++&65535];st+=(u=m[t]+y)>255',       // 51 EOR ind, Y
    'm[u+(m[t+1&255]<<8)&65535]'),
nop(2),                                             // 52 illegal
nop(8),                                             // 53 illegal
nop(4),                                             // 54 illegal
eor(4, '', 'm[x+m[pc++&65535]&255]'),               // 55 EOR zpg, X
lsrm(6, 'm[u=x+m[pc++&65535]&255]'),                // 56 LSR zpg, X
nop(6),                                             // 57 illegal
'st+=2;f&=251',                                     // 58 CLI
eor(4, ';t=m[pc++&65535];st+=(t=m[t]+y)>255',       // 59 EOR abs, Y
    'm[t+(m[pc++&65535]<<8)&65535]'),
nop(2),                                             // 5A illegal
nop(7),                                             // 5B illegal
nop(5),                                             // 5C illegal
eor(5, ';t=m[pc++&65535];st+=(t=m[t]+x)>255',       // 5D EOR abs, X
    'm[t+(m[pc++&65535]<<8)&65535]'),
lsrm(7,                                             // 5E LSR abs, X
  'm[u=x+m[pc++&65535]+(m[pc++&65535]<<8)&65535]'),
nop(7),                                             // 5F illegal
'st+=6;'+                                           // 60 RTS
'pc=1+m[sp+1&255|256]+(m[(sp=sp+2&255)|256]<<8)'+
adc(6,'m[pc++&65535]+x&255;t=m[m[t]|m[t+1&255]<<8]')// 61 ADC X, ind
,nop(2),                                            // 62 illegal
nop(8),                                             // 63 illegal
bit(3, 'm[m[pc++&65535]]'),                         // 64 illegal
adc(3, 'm[m[pc++&65535]]'),                         // 65 ADC zpg
rorm(5, 'm[u=m[pc++&65535]]'),                      // 66 ROR zpg
nop(5),                                             // 67 illegal
'st+=4;a=m[(sp=sp+1&255)|256]'+                     // 68 PLA
adc(2, 'm[pc++&65535]'),                            // 69 ADC imm
'st+=2;f=a&1|f&124|sz[a=a>>1|f<<7&128]',            // 6A RORA
nop(2),                                             // 6B illegal
'st+=5;t=m[pc&65535];u=m[pc+1&65535]<<8;'+          // 6C JMP ind (bug)
'pc=m[t|u]|m[t+1&255|u]<<8',
adc(4, 'm[m[pc++&65535]|m[pc++&65535]<<8]'),        // 6D ADC abs
rorm(6, 'm[u=m[pc++&65535]|m[pc++&65535]<<8]'),     // 6E ROR abs
nop(6),                                             // 6F illegal
jrc(f&64),                                          // 70 BVS rel
adc(5, 'm[pc++&65535];st+=(u=m[t]+y)>255;'+         // 71 ADC ind, Y
    't=m[u+(m[t+1&255]<<8)&65535]'),
nop(2),                                             // 72 illegal
nop(8),                                             // 73 illegal
nop(4),                                             // 74 illegal
adc(4, 'm[x+m[pc++&65535]&255]'),                   // 75 ADC zpg, X
rorm(6, 'm[u=x+m[pc++&65535]&255]'),                // 76 ROR zpg, X
nop(6),                                             // 77 illegal
'st+=2;f|=4',                                       // 78 SEI
adc(4, 'm[pc++&65535];st+=(t=m[t]+y)>255;'+         // 79 ADC abs, Y
    't=m[t+(m[pc++&65535]<<8)&65535]'),
nop(2),                                             // 7A illegal
nop(7),                                             // 7B illegal
nop(5),                                             // 7C illegal
adc(5, 'm[pc++&65535];st+=(t=m[t]+x)>255;'+         // 7D ADC abs, X
    't=m[t+(m[pc++&65535]<<8)&65535]'),
rorm(7,                                             // 7E ROR abs, X
  'm[u=x+m[pc++&65535]+(m[pc++&65535]<<8)&65535]'),
nop(7),                                             // 7F illegal



nop(2),                                             // 80 illegal
sta(6, ';t=m[pc++&65535]+x&255',                    // 81 STA X, ind
    'm[t]|m[t+1&255]<<8'),
nop(2),                                             // 82 illegal
nop(8),                                             // 83 illegal
nop(3),                                             // 84 illegal
ora(3, '', 'm[m[pc++&65535]]'),                     // 85 STA zpg
aslm(5, 'm[u=m[pc++&65535]]'),                      // 06 ASL zpg
nop(5),                                             // 07 illegal
'st+=3;wb(sp++|256,f);'+                            // 08 PHP
'sp&=255',
ora(2, '', 'm[pc++&65535]'),                        // 09 ORA imm
'st+=2;f=a>>7|f&124|sz[a=a<<1&255]',                // 0A ASLA
nop(2),                                             // 0B illegal
nop(4),                                             // 0C illegal
ora(4, '', 'm[m[pc++&65535]|m[pc++&65535]<<8]'),    // 0D ORA abs
aslm(6, 'm[u=m[pc++&65535]|m[pc++&65535]<<8]'),     // 0E ASL abs
nop(6),                                             // 0F illegal
jrc(~f&128),                                        // 10 BPL rel
ora(5, ';t=m[pc++&65535];st+=(u=m[t]+y)>255',       // 11 ORA ind, Y
    'm[u+(m[t+1&255]<<8)&65535]'),
nop(2),                                             // 12 illegal
nop(8),                                             // 13 illegal
nop(4),                                             // 14 illegal
ora(4, '', 'm[x+m[pc++&65535]&255]'),               // 15 ORA zpg, X
aslm(6, 'm[u=x+m[pc++&65535]&255]'),                // 16 ASL zpg, X
nop(6),                                             // 17 illegal
'st+=2;f&=254',                                     // 18 CLC
ora(4, 't=m[pc++&65535];st+=(t=m[t]+y)>255;',       // 19 ORA abs, Y
    'm[t+(m[pc++&65535]<<8)&65535]'),
nop(2),                                             // 1A illegal
nop(7),                                             // 1B illegal
nop(5),                                             // 1C illegal
ora(5, 't=m[pc++&65535];st+=(t=m[t]+x)>255;',       // 1D ORA abs, X
    'm[t+(m[pc++&65535]<<8)&65535]'),
aslm(7,                                             // 1E ASL abs, X
  'm[u=x+m[pc++&65535]+(m[pc++&65535]<<8)&65535]'),
nop(7),                                             // 1F illegal
'st+=6;t=pc+1&65535;'+                              // 20 JSR abs
'pc=m[pc&65535]|m[t]<<8;'+
'wb(--sp&255|256,t>>8);'+
'wb((sp=sp-1&255)|256,t&255)',
and(6, ';t=m[pc++&65535]+x&255',                    // 21 AND X, ind
    'm[m[t]|m[t+1&255]<<8]'),
nop(2),                                             // 22 illegal
nop(8),                                             // 23 illegal
bit(3, 'm[m[pc++&65535]]'),                         // 24 BIT zpg
and(3, '', 'm[m[pc++&65535]]'),                     // 25 AND zpg
rolm(5, 'm[u=m[pc++&65535]]'),                      // 26 ROL zpg
nop(5),                                             // 27 illegal
'st+=4;f=m[(sp=sp+1&255)|256]'+                     // 28 PLP
and(2, '', 'm[pc++&65535]'),                        // 29 AND imm
'st+=2;f=a>>7|f&124|sz[a=a<<1&255|f&1]',            // 2A ROLA
nop(2),                                             // 2B illegal
bit(4, 'm[m[pc++&65535]|m[pc++&65535]<<8]'),        // 2C BIT abs
and(4, '', 'm[m[pc++&65535]|m[pc++&65535]<<8]'),    // 2D AND abs
rolm(6, 'm[u=m[pc++&65535]|m[pc++&65535]<<8]'),     // 2E ROL abs
nop(6),                                             // 2F illegal
jrc(f&128),                                         // 30 BMI rel
and(5, ';t=m[pc++&65535];st+=(u=m[t]+y)>255',       // 31 AND ind, Y
    'm[u+(m[t+1&255]<<8)&65535]'),
nop(2),                                             // 32 illegal
nop(8),                                             // 33 illegal
nop(4),                                             // 34 illegal
and(4, '', 'm[x+m[pc++&65535]&255]'),               // 35 AND zpg, X
rolm(6, 'm[u=x+m[pc++&65535]&255]'),                // 36 ROL zpg, X
nop(6),                                             // 37 illegal
'st+=2;f|=1',                                       // 38 SEC
and(4, ';t=m[pc++&65535];st+=(t=m[t]+y)>255',       // 39 AND abs, Y
    'm[t+(m[pc++&65535]<<8)&65535]'),
nop(2),                                             // 3A illegal
nop(7),                                             // 3B illegal
nop(5),                                             // 3C illegal
and(5, ';t=m[pc++&65535];st+=(t=m[t]+x)>255',       // 3D AND abs, X
    'm[t+(m[pc++&65535]<<8)&65535]'),
rolm(7,                                             // 3E ROL abs, X
  'm[u=x+m[pc++&65535]+(m[pc++&65535]<<8)&65535]'),
nop(7),                                             // 3F illegal
'st+=6;f=m[sp+1&255|256];'+                         // 40 RTI
'pc=m[sp+2&255|256]|m[(sp=sp+3&255)|256]<<8'+
eor(6, ';t=m[pc++&65535]+x&255',                    // 41 EOR X, ind
    'm[m[t]|m[t+1&255]<<8]'),
nop(2),                                             // 42 illegal
nop(8),                                             // 43 illegal
nop(3),                                             // 44 illegal
eor(3, '', 'm[m[pc++&65535]]'),                     // 45 EOR zpg
lsrm(5, 'm[u=m[pc++&65535]]'),                      // 46 LSR zpg
nop(5),                                             // 47 illegal
'st+=3;wb(sp++|256,a);'+                            // 48 PHA
'sp&=255',
eor(2, '', 'm[pc++&65535]'),                        // 49 EOR imm
'st+=2;f=a&1|f&124|sz[a>>=1]',                      // 4A LSRA
nop(2),                                             // 4B illegal
'st+=3;pc=m[pc&65535]|m[pc+1&65535]<<8',            // 4C JMP abs
eor(4, '', 'm[m[pc++&65535]|m[pc++&65535]<<8]'),    // 4D EOR abs
lsrm(6, 'm[u=m[pc++&65535]|m[pc++&65535]<<8]'),     // 4E LSR abs
nop(6),                                             // 4F illegal
jrc(~f&64),                                         // 50 BVC rel
eor(5, ';t=m[pc++&65535];st+=(u=m[t]+y)>255',       // 51 EOR ind, Y
    'm[u+(m[t+1&255]<<8)&65535]'),
nop(2),                                             // 52 illegal
nop(8),                                             // 53 illegal
nop(4),                                             // 54 illegal
eor(4, '', 'm[x+m[pc++&65535]&255]'),               // 55 EOR zpg, X
lsrm(6, 'm[u=x+m[pc++&65535]&255]'),                // 56 LSR zpg, X
nop(6),                                             // 57 illegal
'st+=2;f&=251',                                     // 58 CLI
eor(4, ';t=m[pc++&65535];st+=(t=m[t]+y)>255',       // 59 EOR abs, Y
    'm[t+(m[pc++&65535]<<8)&65535]'),
nop(2),                                             // 5A illegal
nop(7),                                             // 5B illegal
nop(5),                                             // 5C illegal
eor(5, ';t=m[pc++&65535];st+=(t=m[t]+x)>255',       // 5D EOR abs, X
    'm[t+(m[pc++&65535]<<8)&65535]'),
lsrm(7,                                             // 5E LSR abs, X
  'm[u=x+m[pc++&65535]+(m[pc++&65535]<<8)&65535]'),
nop(7),                                             // 5F illegal
'st+=6;'+                                           // 60 RTS
'pc=1+m[sp+1&255|256]+(m[(sp=sp+2&255)|256]<<8)'+
adc(6,'m[pc++&65535]+x&255;t=m[m[t]|m[t+1&255]<<8]')// 61 ADC X, ind
,nop(2),                                            // 62 illegal
nop(8),                                             // 63 illegal
bit(3, 'm[m[pc++&65535]]'),                         // 64 illegal
adc(3, 'm[m[pc++&65535]]'),                         // 65 ADC zpg
rorm(5, 'm[u=m[pc++&65535]]'),                      // 66 ROR zpg
nop(5),                                             // 67 illegal
'st+=4;a=m[(sp=sp+1&255)|256]'+                     // 68 PLA
adc(2, 'm[pc++&65535]'),                            // 69 ADC imm
'st+=2;f=a&1|f&124|sz[a=a>>1|f<<7&128]',            // 6A RORA
nop(2),                                             // 6B illegal
'st+=5;t=m[pc&65535];u=m[pc+1&65535]<<8;'+          // 6C JMP ind (bug)
'pc=m[t|u]|m[t+1&255|u]<<8',
adc(4, 'm[m[pc++&65535]|m[pc++&65535]<<8]'),        // 6D ADC abs
rorm(6, 'm[u=m[pc++&65535]|m[pc++&65535]<<8]'),     // 6E ROR abs
nop(6),                                             // 6F illegal
jrc(f&64),                                          // 70 BVS rel
adc(5, 'm[pc++&65535];st+=(u=m[t]+y)>255;'+         // 71 ADC ind, Y
't=m[u+(m[t+1&255]<<8)&65535]'),
nop(2),                                             // 72 illegal
nop(8),                                             // 73 illegal
nop(4),                                             // 74 illegal
adc(4, 'm[x+m[pc++&65535]&255]'),                   // 75 ADC zpg, X
rorm(6, 'm[u=x+m[pc++&65535]&255]'),                // 76 ROR zpg, X
nop(6),                                             // 77 illegal
'st+=2;f|=4',                                       // 78 SEI
adc(4, 'm[pc++&65535];st+=(t=m[t]+y)>255;'+         // 79 ADC abs, Y
't=m[t+(m[pc++&65535]<<8)&65535]'),
nop(2),                                             // 7A illegal
nop(7),                                             // 7B illegal
nop(5),                                             // 7C illegal
adc(5, 'm[pc++&65535];st+=(t=m[t]+x)>255;'+         // 7D ADC abs, X
't=m[t+(m[pc++&65535]<<8)&65535]'),
rorm(7,                                             // 7E ROR abs, X
  'm[u=x+m[pc++&65535]+(m[pc++&65535]<<8)&65535]'),
nop(7),                                             // 7F illegal



];

g= [];
for (j=0; j<256; j++)
  g[j]= new Function(p[j]);
