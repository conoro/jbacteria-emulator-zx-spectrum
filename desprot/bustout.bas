      BORDER NOT PI:\
      INK NOT PI:\
      PAPER NOT PI:\
      CLS:\
      BRIGHT SGN PI:\
      LET c$= "1441229400\{0}\{60}\{126}\{126}\{126}\{126}\{60}\{0}\{255}\{129}\{189}\{189}\{189}\{189}\{129}\{255}":\
      FOR i= CODE"\{11}" TO CODE"\{26}":\
        POKE 0|65357+i, CODE c$(i):\
      NEXT i:\
      LET s$="                                ":\
      FOR i= SGN PI TO VAL"5" STEP 2:\
        PRINT AT 5+i, 9; INK VAL c$(i); "\b"; INK 7; " = "; 5*VAL c$(i+3) ;" puntos":\
      NEXT i:\
      PRINT INK 4; AT 14, NOT PI; "Pulse ESPACIO o DISP para ceder"'\
                             "una vida a cambio de una"'\
                             "pantalla nueva.";\
          FLASH 1; AT INT PI, 12; INK 7; "FRONTON":\
      PAUSE 200:\
      LET maximo= 0

# La partida empieza aqui
@ini: LET tpuntos= 0:\
      LET vidas= 6

# Si nos hacemos 1100 puntos del tiron o pulsamos 0/Esp
@rei: LET puntos= 0:\
      CLS:\
      INK 7:\
      PLOT 12, 13:\
      DRAW 0, 160:\
      DRAW 230, 0:\
      DRAW 0, -160:\
      FOR r= 1 TO 6:\
        IF r<3 OR r>4 THEN\
          FOR i= 2 TO 29:\
            PRINT AT r, i; INK VAL c$(r); "\b":\
          NEXT i
      NEXT r:\
      LET bx= 9:\
      PRINT INK 6; AT 17, 4;   "Mueva raqueta con < y >";\
                   AT 19, 2; "CUALQUIER TECLA PARA EMPEZAR":\
      PAUSE 0:\
      PRINT INK 0; AT 17, 4; s$(TO 24);\
                   AT 19, 2; s$(TO 28);\
                   AT 20, 0; s$(TO 32):\
      PRINT AT 21, 0; INK 0; s$(TO 32):\

# Pierde vida
@pvi: LET vidas= vidas-1:\
      GO SUB @ima:\
      IF vidas=0 THEN\
        PRINT INK 7; AT 10, 9;      "FIN DEL JUEGO";\
                     AT 12, 4; "Puntos conseguidos : "; tpuntos:\
        PAUSE 100:\
        GO TO @ini

# Sale la pelota
@pel: LET xa= 1:\
      LET ya= 1:\
      IF INT (RND*2)=1 THEN\
        LET xa= -xa
      GO SUB @ira:\
      LET xc= bx+4:\
      LET yc= 11:\

# Bucle principal

#     Si llego a 1100 puntos con una pelota, restaura tablero
@buc: LET x= xc:\
      LET y= yc:\
      IF puntos>1100 THEN\
        GO TO @rei

#     Si pulso espacio o 0 restauro tablero y pierde vida
      IF INKEY$=" " OR INKEY$="0" THEN\
        IF vidas>1 THEN\
          LET vidas= vidas-1:\
          GO TO @rei

#     Actualizo posicion de la pelota y exploro teclado
      LET xc= x+xa:\
      LET yc= y+ya:\
      GO SUB @ete:\

#     Si estoy en la linea 20, compruebo si hay raqueta
      IF yc=20 THEN\
        IF ATTR(yc, xc)=69 THEN\
          BEEP 0.12, 6:\
          LET ya= -ya:\
          LET yc= 18:\
          IF xc=bx+1 OR xc=bx+4 THEN\
            LET xa= -xa:\
            LET xc= x+xa
      IF yc=21 THEN\
        BEEP 1, -9:\
        PRINT AT y, x; " ":\
        GO TO @pvi
      GO SUB @ete:\
      IF yc=20 THEN\
        GO TO @ape

# Bucle color    
@bco: LET t= ATTR(yc, xc):\
      IF t=71 THEN\
        GO TO @bla
#     Si color leido es negro, comprobar borde superior
      IF t=64 THEN\
        GO TO @bsu
#     Si otro color, es ladrillo. Borrar ladrillo y rebotar
      LET ya= -ya:\
      PRINT AT yc, xc; INK 0; " ":\
      LET yc= yc+ya:\
      FOR i= 65 TO 68:\
        IF t=i THEN\
          LET b= 5*VAL c$(i-62):\
          BEEP 0.12, VAL c$(i-58):\
          LET puntos= puntos+b:\
          LET tpuntos= tpuntos+b:\
          GO SUB @ima:\
          GO TO  @bco
      NEXT i

# Borde lateral
@bla: LET xa= -xa:\
      LET xc= xc+2*xa:\
      BEEP 0.12, 5

# Borde superior
@bsu: IF yc=1 THEN\
        LET ya= 1

# Actualiza pelota y vuelve a bucle
@ape: PRINT AT y,  x;  INK 0; " ";\
            AT yc, xc; INK 3; "\a":\
      GO TO @buc

# Explora teclado
@ete: LET a$= INKEY$:\
      IF bx>1 THEN\
        IF a$=CHR$(8) OR a$="6" THEN\
          LET bx= bx-1
      IF bx<25 THEN\
        IF a$=CHR$(9) OR a$="7" THEN\
          LET bx= bx+1

# Imprime raqueta
@ira: PRINT AT 20, bx; INK 0; " "; INK 5; "\''\''\''\''"; INK 0; " ":\
      RETURN

# Imprime marcador
@ima: IF tpuntos>maximo THEN\
        LET maximo= tpuntos
      PRINT INK 6; AT 21,  1; "PUNTOS "; tpuntos;\
                   AT 21, 14; "MAX. "; maximo;\
                   AT 21, 24; "VIDAS "; vidas:\
      RETURN
