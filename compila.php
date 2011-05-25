<?
/*
  ob_start();
  require'list_wos.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('noframes.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();
  require'list_woscat.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('noframes_cat.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();
  require'list_cpc.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('noframes.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$vesionra='s';
  require'list_cpc.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('noframess.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui 48");
  $rom= file_get_contents('48.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('k-spectrum.pal').
                              file_get_contents('k-spectrum.bin').
                              $rom.
                              file_get_contents('48.mem').
                              file_get_contents('48.js'));
  unlink('48.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_48.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui 48s");
  $rom= file_get_contents('48.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('k-spectrum.pal').
                              file_get_contents('k-spectrum.bin').
                              $rom.
                              file_get_contents('48.mem').
                              file_get_contents('48.js'));
  unlink('48.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_48s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui 128");
  $rom= file_get_contents('128.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('k-spectrum.pal').
                              file_get_contents('k-spectrum.bin').
                              $rom.
                              file_get_contents('128.mem').
                              file_get_contents('128.js'));
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_128.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
  $rom= file_get_contents('128i.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('k-spectrum.pal').
                              file_get_contents('k-spectrum.bin').
                              $rom.
                              file_get_contents('128.mem').
                              file_get_contents('128.js'));
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_128i.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
  unlink('128.js');
///*
  exec("java yui 16");
  $rom= file_get_contents('16.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('k-spectrum.pal').
                              file_get_contents('k-spectrum.bin').
                              $rom.
                              file_get_contents('16.mem').
                              file_get_contents('16.js'));
  unlink('16.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_16.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui +2");
  $rom= file_get_contents('+2.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('k-spectrum.pal').
                              file_get_contents('k-spectrum.bin').
                              $rom.
                              file_get_contents('+2.mem').
                              file_get_contents('+2.js'));
  unlink('+2.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_+2.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui +2A");
  $rom= file_get_contents('+2A.rom');
  $rom[0xc56c]= chr(0xed);
  $rom[0xc56d]= chr(0xfc);
  file_put_contents('aa.rom', file_get_contents('k-spectrum.pal').
                              file_get_contents('k-spectrum.bin').
                              $rom.
                              file_get_contents('+2A.mem').
                              file_get_contents('+2A.js'));
  unlink('+2A.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_+2A.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui SE");
  file_put_contents('aa.rom', file_get_contents('k-spectrum.pal').
                              file_get_contents('k-spectrum.bin').
                              file_get_contents('SE.rom').
                              file_get_contents('SE.js'));
  unlink('SE.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_SE.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui 464");
  file_put_contents('aa.rom', file_get_contents('k-cpc.pal').
                              file_get_contents('k-cpc.bin').
                              file_get_contents('464.rom').
                              file_get_contents('464.mem').
                              file_get_contents('464.js'));
  unlink('464.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_464.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui 464s");
  file_put_contents('aa.rom', file_get_contents('k-cpc.pal').
                              file_get_contents('k-cpc.bin').
                              file_get_contents('464.rom').
                              file_get_contents('464.mem').
                              file_get_contents('464s.js'));
  unlink('464s.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_464s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui 664");
  file_put_contents('aa.rom', file_get_contents('k-cpc.pal').
                              file_get_contents('k-cpc.bin').
                              file_get_contents('664.rom').
                              file_get_contents('664.mem').
                              file_get_contents('664.js'));
  unlink('664.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_664.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui 664s");
  file_put_contents('aa.rom', file_get_contents('k-cpc.pal').
                              file_get_contents('k-cpc.bin').
                              file_get_contents('664.rom').
                              file_get_contents('664.mem').
                              file_get_contents('664s.js'));
  unlink('664s.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_664s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui 6128");
  file_put_contents('aa.rom', file_get_contents('k-cpc.pal').
                              file_get_contents('k-cpc.bin').
                              file_get_contents('6128.rom').
                              file_get_contents('6128.mem').
                              file_get_contents('6128.js'));
  unlink('6128.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_6128.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  exec("java yui 6128s");
  file_put_contents('aa.rom', file_get_contents('k-cpc.pal').
                              file_get_contents('k-cpc.bin').
                              file_get_contents('6128.rom').
                              file_get_contents('6128.mem').
                              file_get_contents('6128s.js'));
  unlink('6128s.js');
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('_6128s.tap.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x=48;$y=0x10000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('48.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x='48s';$y=0x10000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('48s.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x=128;$y=0x14000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('128.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x='128i';$y=0x14000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('128i.xhtml.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x=16;$y=0x8000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('16.xhtml.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x='+2';$y=0x14000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('+2.xhtml.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x='+2A';$y=0x1C000;
  require'emu.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('+2A.xhtml.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();
  require'emu_se.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('SE.xhtml.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x='464';$y=0x18000;$title='Roland464';
  require'emu_cpc.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('464.xhtml.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x='464s';$y=0x18000;$title='Roland464';
  require'emu_cpc.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('464s.xhtml.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x='664';$y=0x1c000;$title='Roland664';
  require'emu_cpc_disk.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('664.xhtml.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x='664s';$y=0x1c000;$title='Roland664';
  require'emu_cpc_disk.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('664s.xhtml.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x='6128';$y=0x1c000;$title='Roland6128';
  require'emu_cpc_disk.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('6128.xhtml.deflate', substr(file_get_contents('temp.zip'), 36, -75));
///*
  ob_start();$x='6128s';$y=0x1c000;$title='Roland6128';
  require'emu_cpc_disk.php';
  file_put_contents('aa.rom', ob_get_contents());
  exec('kzip -y temp.zip aa.rom');
  file_put_contents('6128s.xhtml.deflate', substr(file_get_contents('temp.zip'), 36, -75));
//*/
  unlink('aa.rom');
  unlink('temp.zip');
?>