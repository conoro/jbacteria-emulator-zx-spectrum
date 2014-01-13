Fucking Awesome Spectrum Engine (FASE) v0.12
--------------------------------------------

There are 3 ways of generate game.tap. Just execute fase.bat with zero or one
of these parameters:

1) fase gfx
Will compile all files. Type this if you modify map.tmx or any png file or
tmode constant in config.def. You can modify the png files with any image
editor (I use GIMP) and map.tmx with Tiled (www.mapeditor.org/). To ensure
legal ZX Spectrum colors filter it with PosterizeZX:
http://retrolandia.net/foro/showthread.php?tid=78&pid=452#pid452

2) fase config
If you change one of the options into config.def (except tmode)

3) fase
Without parameters just compile main.c (or main.bas) and generate game.tap

The parameters of config.def are:
-tmode
  Tile mode, a number between 0 and 3 with this correspondence:
  0=no index, 1=index bitmap, 2=index attr, 3=full index
  Observe the output of step1.exe and choose the tile mode that employs
  less tile storage
-smooth
  0 or 1. With 0 the sprite movement is each 2 pixels. Only 4 rotations per
  sprite are stored. The 1 value is for fine 1 pixel movement and 8
  rotations per sprite. Normally sprites storage is 5K with 0 and 10K with 1
-clipup
  0 or 1. 1 enabled and 0 disabled. This is for clipping the sprites in the
  upper bound of the screen. Sprite clipping require many lines of code, so
  you must disable if you don't really need
-clipdn
  0 or 1. Same of last parameter but for the lower bound
-safeco
  0 or 1. Safe coordinates. Avoid crashing if the Y coordinate of the sprite
  has an illegal value. Disable it if you ensure legal values from your
  program and you'll save some bytes

The engine works at this version with ZX Basic:
http://www.boriel.com/software/the-zx-basic-compiler/
and with SDCC compiler:
http://sdcc.sourceforge.net/

Default compiler is SDCC. Just change "set _lang=c" to "set _lang=basic" to
use ZX Basic in the file fase.bat