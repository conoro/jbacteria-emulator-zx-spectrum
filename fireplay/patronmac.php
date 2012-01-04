<?php require 'zx.inc.php';
  file_put_contents('patronmac.tap',
    block("\3" . substr(str_pad('patronmac',10),0,10) . pack('vvv', 0x1b00, 0x4000, 0x8000), 0).
    data(file_get_contents('patron.scr')))?>