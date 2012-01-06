<?php require 'zx.inc.php';
  file_put_contents('patron.tap', data(substr(file_get_contents('patron.scr'),0,6144)))?>