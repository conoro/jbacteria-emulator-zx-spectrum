Png2Rcs loading.png loading.rcs
zx7b loading.rcs loading.zx7
TmxCompress map.tmx map_compressed.bin
\_Downloads\dm\bin\dmc GfxBu.c lodepng.c
GfxBu tiles.png sprites.png tiles.bin sprites.bin 0 dummy
rem echo  org     $fe80           >  deforg.asm
rem echo  output  dzx7b_rcs_0.bin >> deforg.asm
rem \emuscriptoria\sjasmplus dzx7b_rcs.asm
rem echo  org     $fc21           >  deforg.asm
rem echo  output  dzx7b_rcs_1.bin >> deforg.asm
rem \emuscriptoria\sjasmplus dzx7b_rcs.asm
copy define.asm define1.asm
copy define.asm define2.asm
echo    DEFINE  machine 0 >> define.asm
echo    DEFINE  machine 1 >> define1.asm
echo    DEFINE  machine 2 >> define2.asm
\emuscriptoria\sjasmplus engine.asm
copy engine.bin engine0.bin
copy define1.asm define.asm
\emuscriptoria\sjasmplus engine.asm
copy engine.bin engine1.bin
copy define2.asm define.asm
\emuscriptoria\sjasmplus engine.asm
copy engine.bin engine2.bin
\emuscriptoria\sjasmplus main.asm
AllocBu dummy
zx7b block1.bin block1.zx7
zx7b main.bin main.zx7
copy /b map_compressed.bin+main.zx7+block1.zx7 engine.zx7
for /f %%i in ("engine.zx7") do echo  define engcomp_size %%~zi >> defload.asm
for /f %%i in ("main.zx7") do echo  define maincomp_size %%~zi >> defload.asm
for /f %%i in ("main.bin") do echo  define main_size %%~zi >> defload.asm
\emuscriptoria\sjasmplus loader.asm
\emuscriptoria\desprot\gentape game.tap  ^
    basic 'game' 0  loader.bin           ^
     data           engine.zx7
rem engine48.tap