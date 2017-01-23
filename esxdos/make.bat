sjasmplus esxdos.asm
fcut esxdos.rom 0000 2000 esxdos.bin
fcut esxdos.rom 2000 0de4 esxdos.sys
fc /b esxdos.bin esxmmc.bin
fc /b esxdos.sys esxmmc.sys
