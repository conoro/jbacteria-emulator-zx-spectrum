TmxCompress map.tmx map_compressed.bin
\_Downloads\dm\bin\dmc GfxBu.c lodepng.c
GfxBu tiles.png sprites.png tiles.bin sprites.bin 0 dummy
rem echo  org     $fe80           >  deforg.asm
rem echo  output  dzx7b_rcs_0.bin >> deforg.asm
rem \emuscriptoria\sjasmplus dzx7b_rcs.asm
rem echo  org     $fc20           >  deforg.asm
rem echo  output  dzx7b_rcs_1.bin >> deforg.asm
rem \emuscriptoria\sjasmplus dzx7b_rcs.asm
copy define.asm define1.asm
copy define.asm define2.asm
echo    DEFINE  machine 0 >> define.asm
echo    DEFINE  machine 1 >> define1.asm
echo    DEFINE  machine 2 >> define2.asm

\emuscriptoria\sjasmplus engine.asm

rem copy define1.asm define.asm
rem \emuscriptoria\sjasmplus engine.asm

rem copy define2.asm define.asm
rem \emuscriptoria\sjasmplus engine.asm

\emuscriptoria\sjasmplus main.asm
AllocBu dummy
rem \emuscriptoria\desprot\gentape engine48.tap basic 'engine48' 0 engine48.bin
rem engine48.tap