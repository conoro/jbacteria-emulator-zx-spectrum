<?
///*
  error_log("list_wos.php");
  ob_start();
  require'list_wos.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('noframes.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("list_woscat.php");
  ob_start();
  require'list_woscat.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('noframes_cat.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("list_wos.php");
  ob_start();$vesionra='s';
  require'list_wos.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('noframess.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("list_woscat.php");
  ob_start();$vesionra='s';
  require'list_woscat.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('noframes_cats.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
//
/*
  error_log("list_cpc.php");
  ob_start();
  require'list_cpc.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('noframes.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("list_cpc.phpS");
  ob_start();$vesionra='s';
  require'list_cpc.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('noframess.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("48");
  exec("java yui 48");
  $rom= file_get_contents('rom/48.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/48.mem').
                              file_get_contents('48.js'));
  unlink('48.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_48.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("48s");
  exec("java yui 48s");
  $rom= file_get_contents('rom/48.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/48.mem').
                              file_get_contents('48s.js'));
  unlink('48s.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_48s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("128");
  exec("java yui 128");
  $rom= file_get_contents('rom/128.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/128.mem').
                              file_get_contents('128.js'));
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_128.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
  $rom= file_get_contents('rom/128i.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/128.mem').
                              file_get_contents('128.js'));
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_128i.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
  unlink('128.js');
///*
  error_log("128s");
  exec("java yui 128s");
  $rom= file_get_contents('rom/128.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/128.mem').
                              file_get_contents('128.js'));
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_128s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
  $rom= file_get_contents('rom/128i.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/128.mem').
                              file_get_contents('128s.js'));
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_128is.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
  unlink('128s.js');
///*
  error_log("16");
  exec("java yui 16");
  $rom= file_get_contents('rom/16.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/16.mem').
                              file_get_contents('16.js'));
  unlink('16.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_16.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("16s");
  exec("java yui 16s");
  $rom= file_get_contents('rom/16.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/16.mem').
                              file_get_contents('16s.js'));
  unlink('16s.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_16s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+2");
  exec("java yui +2");
  $rom= file_get_contents('rom/+2.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/+2.mem').
                              file_get_contents('+2.js'));
  unlink('+2.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_+2.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+2s");
  exec("java yui +2s");
  $rom= file_get_contents('rom/+2.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/+2.mem').
                              file_get_contents('+2s.js'));
  unlink('+2s.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_+2s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+2A");
  exec("java yui +2A");
  $rom= file_get_contents('rom/+2A.rom');
  $rom[0xc56c]= chr(0xed);
  $rom[0xc56d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/+2A.mem').
                              file_get_contents('+2A.js'));
  unlink('+2A.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_+2A.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+2As");
  exec("java yui +2As");
  $rom= file_get_contents('rom/+2A.rom');
  $rom[0xc56c]= chr(0xed);
  $rom[0xc56d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              $rom.
                              file_get_contents('rom/+2A.mem').
                              file_get_contents('+2As.js'));
  unlink('+2As.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_+2As.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+3");
  exec("java yui +3");
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              file_get_contents('rom/+2A.rom').
                              file_get_contents('rom/+2A.mem').
                              file_get_contents('+3.js'));
  unlink('+3.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_+3.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+3s");
  exec("java yui +3s");
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              file_get_contents('rom/+2A.rom').
                              file_get_contents('rom/+2A.mem').
                              file_get_contents('+3s.js'));
  unlink('+3s.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_+3s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("SE");
  exec("java yui SE");
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              file_get_contents('rom/SE.rom').
                              file_get_contents('SE.js'));
  unlink('SE.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_SE.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("SEs");
  exec("java yui SEs");
  file_put_contents('aa.rom', file_get_contents('rom/k-spectrum.pal').
                              file_get_contents('rom/k-spectrum.bin').
                              file_get_contents('rom/SE.rom').
                              file_get_contents('SEs.js'));
  unlink('SEs.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_SEs.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("464");
  exec("java yui 464");
  file_put_contents('aa.rom', file_get_contents('rom/k-cpc.pal').
                              file_get_contents('rom/k-cpc.bin').
                              file_get_contents('rom/464.rom').
                              file_get_contents('rom/464.mem').
                              file_get_contents('464.js'));
  unlink('464.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_464.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("464s");
  exec("java yui 464s");
  file_put_contents('aa.rom', file_get_contents('rom/k-cpc.pal').
                              file_get_contents('rom/k-cpc.bin').
                              file_get_contents('rom/464.rom').
                              file_get_contents('rom/464.mem').
                              file_get_contents('464s.js'));
  unlink('464s.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_464s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("664");
  exec("java yui 664");
  file_put_contents('aa.rom', file_get_contents('rom/k-cpc.pal').
                              file_get_contents('rom/k-cpc.bin').
                              file_get_contents('rom/664.rom').
                              file_get_contents('rom/664.mem').
                              file_get_contents('664.js'));
  unlink('664.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_664.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("664s");
  exec("java yui 664s");
  file_put_contents('aa.rom', file_get_contents('rom/k-cpc.pal').
                              file_get_contents('rom/k-cpc.bin').
                              file_get_contents('rom/664.rom').
                              file_get_contents('rom/664.mem').
                              file_get_contents('664s.js'));
  unlink('664s.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_664s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("6128");
  exec("java yui 6128");
  file_put_contents('aa.rom', file_get_contents('rom/k-cpc.pal').
                              file_get_contents('rom/k-cpc.bin').
                              file_get_contents('rom/6128.rom').
                              file_get_contents('rom/6128.mem').
                              file_get_contents('6128.js'));
  unlink('6128.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_6128.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("6128s");
  exec("java yui 6128s");
  file_put_contents('aa.rom', file_get_contents('rom/k-cpc.pal').
                              file_get_contents('rom/k-cpc.bin').
                              file_get_contents('rom/6128.rom').
                              file_get_contents('rom/6128.mem').
                              file_get_contents('6128s.js'));
  unlink('6128s.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_6128s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("48.html");
  ob_start();$x=48;$y=0x10000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('48.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("48s.html");
  ob_start();$x='48s';$y=0x10000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('48s.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("128.html");
  ob_start();$x=128;$y=0x14000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('128.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("128i.html");
  ob_start();$x='128i';$y=0x14000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('128i.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("128s.html");
  ob_start();$x='128s';$y=0x14000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('128s.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("128is.html");
  ob_start();$x='128is';$y=0x14000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('128is.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("16.html");
  ob_start();$x=16;$y=0x8000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('16.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("16s.html");
  ob_start();$x='16s';$y=0x8000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('16s.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+2.html");
  ob_start();$x='+2';$y=0x14000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('+2.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+2s.html");
  ob_start();$x='+2s';$y=0x14000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('+2s.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+2A.html");
  ob_start();$x='+2A';$y=0x1C000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('+2A.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+2As.html");
  ob_start();$x='+2As';$y=0x1C000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('+2As.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+3.html");
  ob_start();$x='+3';$y=0x1C000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('+3.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("+3s.html");
  ob_start();$x='+3s';$y=0x1C000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('+3s.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("SE.html");
  ob_start();$x='SE';
  require'emu_se.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('SE.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("SEs.html");
  ob_start();$x='SEs';
  require'emu_se.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('SEs.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("464.html");
  ob_start();$x='464';$y=0x18000;$title='Roland464';
  require'emu_cpc.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('464.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("464s.html");
  ob_start();$x='464s';$y=0x18000;$title='Roland464';
  require'emu_cpc.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('464s.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("664.html");
  ob_start();$x='664';$y=0x1c000;$title='Roland664';
  require'emu_cpc_disk.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('664.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("664s.html");
  ob_start();$x='664s';$y=0x1c000;$title='Roland664';
  require'emu_cpc_disk.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('664s.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("6128.html");
  ob_start();$x='6128';$y=0x1c000;$title='Roland6128';
  require'emu_cpc_disk.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('6128.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  error_log("6128s.html");
  ob_start();$x='6128s';$y=0x1c000;$title='Roland6128';
  require'emu_cpc_disk.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('6128s.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
//*/
  unlink('aa.rom');
  unlink('temp.zip');
?>