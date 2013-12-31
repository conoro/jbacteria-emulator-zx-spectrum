TmxCompress map.tmx map_compressed.bin
\_Downloads\dm\bin\dmc GfxBu.c lodepng.c
GfxBu tiles.png sprites.png tiles.bin sprites.bin 0 dummy
rem echo  org     $fe80           >  deforg.asm
rem echo  output  dzx7b_rcs_0.bin >> deforg.asm
rem \emuscriptoria\sjasmplus dzx7b_rcs.asm
rem echo  org     $fc20           >  deforg.asm
rem echo  output  dzx7b_rcs_1.bin >> deforg.asm
rem \emuscriptoria\sjasmplus dzx7b_rcs.asm
\emuscriptoria\sjasmplus engine48.asm
rem \emuscriptoria\sjasmplus engine128.asm
\emuscriptoria\sjasmplus main.asm
AllocBu dummy
rem \emuscriptoria\desprot\gentape engine48.tap basic 'engine48' 0 engine48.bin
rem engine48.tap