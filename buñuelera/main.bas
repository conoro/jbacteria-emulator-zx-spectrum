#include "fase.bas"

  DisableInt

  DIM datos(31) as UBYTE = { _
    $00, $42, $11, 0, _
    $08, $60, $60, 2, _
    $09, $a8, $48, 3, _
    $0a, $22, $02, 1, _
    $0b, $d0, $6e, 2, _
    $0c, $b6, $34, 3, _
    $0d, $32, $32, 1, _
    $04, $52, $5e, 0 }

  DIM i, x, y AS UBYTE

  FOR i = 0 TO 31
    SETSPRITE(i>>2, i&3, datos(i))
  NEXT i

  INIT
  SETSCREEN(0)
  WHILE 1
    FRAME
    FOR i = 1 TO 8
      IF GETSPRITE(i, 3) & 1 THEN
        IF GETSPRITE(i, 2) > 0 THEN
          SETSPRITE(i, 2, GETSPRITE(i, 2)-1)
        ELSE
          SETSPRITE(i, 3, GETSPRITE(i, 3) bXOR 1)
        END IF
      ELSE
        IF GETSPRITE(i, 2) < $90 THEN
          SETSPRITE(i, 2, GETSPRITE(i, 2)+1)
        ELSE
          SETSPRITE(i, 3, GETSPRITE(i, 3) bXOR 1)
        END IF
      END IF
      IF GETSPRITE(i, 3) & 2 THEN
        IF GETSPRITE(i, 1) > $08 THEN
          SETSPRITE(i, 1, GETSPRITE(i, 1)-1)
        ELSE
          SETSPRITE(i, 3, GETSPRITE(i, 3) bXOR 2)
        END IF
      ELSE
        IF GETSPRITE(i, 1) < $e8 THEN
          SETSPRITE(i, 1, GETSPRITE(i, 1)+1)
        ELSE
          SETSPRITE(i, 3, GETSPRITE(i, 3) bXOR 2)
        END IF
      END IF
    NEXT i
  END WHILE

