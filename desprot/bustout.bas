      BORDER 0:\
      INK 0:\
      PAPER 0:\
      CLS:\
      BRIGHT 1:\
      GO SUB @560:\
      LET b$= "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b":\
      LET s$="                                ":\
      PRINT FLASH 1; AT 3, 12; INK 7; "FRONTON";\
            FLASH 0; AT 6,  9; INK 1; "\b"; INK 7; " = 20 puntos";\
                     AT 8,  9; INK 4; "\b"; INK 7; " = 10 puntos";\
                     AT 10, 9; INK 2; "\b"; INK 7; " =  5 puntos":\
      PRINT INK 4; AT 14, 1; "Pulse ESPACIO o DISP para ceder";\
                   AT 15, 1; "una vida a cambio de una";\
                   AT 16, 1; "pantalla nueva.":\
      PAUSE 200:\
      LET maximo= 0
@90:  LET tpuntos= 0:\
      LET vidas= 5
@110: LET puntos= 0:\
      CLS:\
      INK 7:\
      PLOT 12, 13:\
      DRAW 0, 160:\
      DRAW 230, 0:\
      DRAW 0, -160:\
      INK 0:\
      PRINT AT 1, 2; INK 1; b$;\
            AT 2, 2; INK 4; b$:\
      FOR r= 5 TO 6:\
        PRINT AT r, 2; INK 2; b$:\
      NEXT r:\
      LET bx= 9:\
      PRINT INK 6; AT 17, 4;   "Mueva raqueta con < y >";\
                   AT 19, 2; "CUALQUIER TECLA PARA EMPEZAR":\
      PAUSE 0:\
      PRINT INK 0; AT 17, 4; s$(TO 24);\
                   AT 19, 2; s$(TO 28);\
                   AT 20, 0; s$(TO 32):\
      PRINT AT 21, 0; INK 0; s$(TO 32):\
      GO SUB @540:\
      GO TO  @220
@210: PRINT AT 20, bx; INK 0; " "; INK 5; "\''\''\''\''"; INK 0; " ":\
      RETURN
@220: LET xa= 1:\
      LET ya= 1:\
      IF INT (RND*2)=1 THEN\
        LET xa= -xa
@221: GO SUB @210:\
      LET x= bx+4:\
      LET y= 11:\
      LET xc= x:\
      LET yc= y
#bucle principal
@250: IF puntos>1100 THEN\
        GO TO @110
@251: IF INKEY$=" " OR INKEY$="0" THEN\
        IF vidas>1 THEN\
          LET vidas= vidas-1:\
          GO TO @110
#explorar teclado
@252: LET xc= x+xa:\
      LET yc= y+ya:\
      GO SUB @470:\
      IF yc=20 THEN\
        IF ATTR (yc,xc)=69 THEN\
          BEEP 0.12, 6:\
          LET ya= -ya:\
          LET yc= yc-2:\
          IF xc=bx+1 OR xc=bx+4 THEN\
            LET xa=-xa:\
            LET xc=x+xa
@253: IF yc=21 THEN\
        BEEP 1, -9:\
        PRINT AT y, x; " ":\
        GO TO @450
@254: GO SUB @470:\
      IF yc=20 THEN\
        GO TO @430
@350: LET t= ATTR (yc,xc):\
      IF t=71 THEN\
        GO TO @410
@351: IF t=64 THEN\
        GO TO @420
@352: LET ya= -ya:\
      LET xz= xc:\
      LET yz= yc:\
      LET yc= yc+ya:\
      GO SUB @510:\
      IF t=66 THEN\
        BEEP 0.12, 4:\
        LET puntos= puntos+5:\
        LET tpuntos= tpuntos+5:\
        GO SUB @540:\
        GO TO  @350
@353: IF t=68 THEN\
        BEEP 0.12, 0:\
        LET puntos= puntos+10:\
        LET tpuntos= tpuntos+10:\
        GO SUB @540:\
        GO TO  @350
@354: IF t=65 THEN\
        BEEP 0.12, 9:\
        LET puntos= puntos+20:\
        LET tpuntos= tpuntos+20:\
        GO SUB @540:\
        GO TO  @350
@410: LET xa= -xa:\
      LET xc= xc+2*xa:\
      BEEP 0.12, 5
@420: IF yc=1 THEN\
        LET ya= 1
@430: PRINT AT y,  x;  INK 0; " ";\
            AT yc, xc; INK 3; "\a":\
      LET x= xc:\
      LET y= yc:\
      GO TO @250
@450: LET vidas= vidas-1:\
      IF vidas=0 THEN\
        GO TO @530
@451: GO SUB @540:\
      GO TO  @220
@470: LET a$= INKEY$:\
      IF (a$=CHR$(8) OR a$="6") AND bx>1 THEN\
        LET bx= bx-1:\
        GO SUB @210:\
        RETURN
@471: IF (a$=CHR$(9) OR a$="7") AND bx<25 THEN\
        LET bx= bx+1:\
        GO SUB @210
@472: RETURN
@510: IF yz=20 THEN\
        RETURN
@511: PRINT AT yz, xz; INK 0; " ":\
      RETURN
@530: GO SUB @540:\
      PRINT INK 7; AT 10, 9;      "FIN DEL JUEGO";\
                   AT 12, 4; "Puntos conseguidos : "; tpuntos:\
      FOR i= 1 TO 300:\
      NEXT i:\
      GO TO @90
@540: IF tpuntos>maximo THEN\
        LET maximo= tpuntos
@541: PRINT INK 6; AT 21, 14; "MAX. "; maximo;\
                   AT 21,  1; "PUNTOS "; tpuntos;\
                   AT 21, 24; "VIDAS "; vidas:\
      RETURN
@560: FOR i= USR "a" TO USR "b"+7:\
        READ b:\
        POKE i, b:\
      NEXT i:\
      RETURN
#pelota
@620: DATA 0, 60, 126, 126, 126, 126, 60, 0:\
#ladrillo
      DATA BIN 11111111:\
      DATA BIN 10000001:\
      DATA BIN 10111101:\
      DATA BIN 10111101:\
      DATA BIN 10111101:\
      DATA BIN 10111101:\
      DATA BIN 10000001:\
      DATA BIN 11111111
