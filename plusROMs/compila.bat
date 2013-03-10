
rem Generates plus3-40, plus3-41 and plus3-sp.rom files

echo  output  plus3-40.rom >  define.asm
sjasmplus rom+2A+3.asm

echo  output  plus3-41.rom >  define.asm
echo  define  v41          >> define.asm
sjasmplus rom+2A+3.asm

echo  output  plus3-sp.rom >  define.asm
echo  define  v41          >> define.asm
echo  define  spanish      >> define.asm
sjasmplus rom+2A+3.asm
