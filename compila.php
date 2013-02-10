<?
$slow= 0;
///*
function stderr($value){
  file_put_contents('php://stderr', $value."\n");
}
function yui($value){
  stderr($value);
  exec("\java yui $value");
}
function comp($out, $in){
  global $slow;
  if( $slow ){
    file_put_contents('aa.rom', $in);
    exec('kzip -y temp.zip aa.rom');
    file_put_contents('_'.$out.'.rom.deflate', substr(file_get_contents('temp.zip'), 36, -75));
  }
  else
    file_put_contents('_'.$out.'.rom.deflate', gzdeflate($in));
}
function compg($out){
  global $slow;
  if( $slow ){
    file_put_contents('aa.rom', ob_get_contents());
    exec('kzip -y temp.zip aa.rom');
    file_put_contents($out.'.html.deflate', substr(file_get_contents('temp.zip'), 36, -75));
  }
  else
    file_put_contents($out.'.html.deflate', gzdeflate(ob_get_contents()));
}
  ob_start();
  $m=0;$p=2;$c=0;require 'z80.php';
  file_put_contents('z80elite.js', ob_get_contents());
  ob_start();
  $m=0;$p=0;$c=0;require 'z80.php';
  file_put_contents('z80.js', ob_get_contents());
  ob_start();
  $m=1;$p=0;$c=0;require 'z80.php';
  file_put_contents('z80m.js', ob_get_contents());
  ob_start();
  $m=0;$p=1;$c=0;require 'z80.php';
  file_put_contents('z80p.js', ob_get_contents());
  ob_start();
  $m=1;$p=1;$c=0;require 'z80.php';
  file_put_contents('z80mp.js', ob_get_contents());
  ob_start();
  $m=0;$p=1;$c=1;require 'z80.php';
  file_put_contents('z80pc.js', ob_get_contents());
  ob_start();
  $m=1;$p=1;$c=1;require 'z80.php';
  file_put_contents('z80mpc.js', ob_get_contents());
//
/*
  stderr('list_wos.php');
  ob_start();
  require'list_wos.php';
  compg('noframes');
///*
  stderr('list_woscat.php');
  ob_start();
  require'list_woscat.php';
  compg('noframes_cat');
///*
  stderr('list_wos.php');
  ob_start();$vra=1;
  require'list_wos.php';
  compg('noframess');
///*
  stderr('list_woscat.php');
  ob_start();$vra=1;
  require'list_woscat.php';
  compg('noframes_cats');
///*
  stderr('list_cpc.php');
  ob_start();
  require'list_cpc.php';
  compg('noframes');
///*
  stderr('list_cpc.phpS');
  ob_start();$vra=1;
  require'list_cpc.php';
  compg('noframess');
///*
  stderr('list_trs.php');
  ob_start();
  require'list_trs.php';
  compg('noframes');
///*
  stderr('list_ace.php');
  ob_start();
  require'list_ace.php';
  compg('noframes');
///*
  stderr('list_ace.phpS');
  ob_start();$vra=1;
  require'list_ace.php';
  compg('noframess');
///*/
  yui('48');
  $rom= file_get_contents('rom/48.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  comp( '48',
        file_get_contents('rom/todo-spectrum.pal').
        file_get_contents('rom/todo-spectrum.bin').
        $rom.
        file_get_contents('rom/48.mem').
        file_get_contents('48.js'));
  $rom= file_get_contents('rom/tk90.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  comp( 'tk90',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/48.mem').
        file_get_contents('48.js'));
  unlink('48.js');
  yui('48s');
  $rom= file_get_contents('rom/48.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  comp( '48s',
        file_get_contents('rom/todo-spectrum.pal').
        file_get_contents('rom/todo-spectrum.bin').
        $rom.
        file_get_contents('rom/48.mem').
        file_get_contents('48s.js'));
  $rom= file_get_contents('rom/tk90.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  $rom= file_get_contents('rom/tk90.rom');
  comp( 'tk90s',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/48.mem').
        file_get_contents('48s.js'));
  unlink('48s.js');
///*
  yui('128');
  $rom= file_get_contents('rom/128.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  comp( '128',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/128.mem').
        file_get_contents('128.js'));
  $rom= file_get_contents('rom/128i.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  comp( '128i',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/128.mem').
        file_get_contents('128.js'));
//  unlink('128.js');
///*
  yui('128s');
  $rom= file_get_contents('rom/128.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  comp( '128s',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/128.mem').
        file_get_contents('128s.js'));
  $rom= file_get_contents('rom/128i.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  comp( '128is',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/128.mem').
        file_get_contents('128s.js'));
  unlink('128s.js');
///*
  yui('16');
  $rom= file_get_contents('rom/16.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  comp( '16',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/16.mem').
        file_get_contents('16.js'));
  unlink('16.js');
///*
  yui('16s');
  $rom= file_get_contents('rom/16.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  comp( '16s',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/16.mem').
        file_get_contents('16s.js'));
  unlink('16s.js');
///*
  yui('+2');
  $rom= file_get_contents('rom/+2.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  comp( '+2',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/+2.mem').
        file_get_contents('+2.js'));
  unlink('+2.js');
///*
  yui('+2s');
  $rom= file_get_contents('rom/+2.rom');
  $rom[0x456c]= chr(0xed);
  $rom[0x456d]= chr(0xfc);
  comp( '+2s',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/+2.mem').
        file_get_contents('+2s.js'));
  unlink('+2s.js');
///*
  yui('+2A');
  $rom= file_get_contents('rom/+2A.rom');
  $rom[0xc56c]= chr(0xed);
  $rom[0xc56d]= chr(0xfc);
  comp( '+2A',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/+2A.mem').
        file_get_contents('+2A.js'));
  unlink('+2A.js');
///*
  yui('+2As');
  $rom= file_get_contents('rom/+2A.rom');
  $rom[0xc56c]= chr(0xed);
  $rom[0xc56d]= chr(0xfc);
  comp( '+2As',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/+2A.mem').
        file_get_contents('+2As.js'));
  unlink('+2As.js');
///*
  yui('+3');
  comp( '+3',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        file_get_contents('rom/+2A.rom').
        file_get_contents('+3.js'));
  unlink('+3.js');
///*
  yui('+3s');
  comp( '+3s',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        file_get_contents('rom/+2A.rom').
        file_get_contents('+3s.js'));
  unlink('+3s.js');
///*
  yui('SE');
  $rom= file_get_contents('rom/SE.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  comp( 'SE',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/SE.mem').
        file_get_contents('SE.js'));
  unlink('SE.js');
///*
  yui('SEs');
  $rom= file_get_contents('rom/SE.rom');
  $rom[0x56c]= chr(0xed);
  $rom[0x56d]= chr(0xfc);
  comp( 'SEs',
        file_get_contents('rom/k-spectrum.pal').
        file_get_contents('rom/k-spectrum.bin').
        $rom.
        file_get_contents('rom/SE.mem').
        file_get_contents('SEs.js'));
  unlink('SEs.js');
///*
  yui('464');
  comp( '464',
        file_get_contents('rom/k-cpc.pal').
        file_get_contents('rom/k-cpc.bin').
        file_get_contents('rom/464.rom').
        file_get_contents('rom/464.mem').
        file_get_contents('464.js'));
  unlink('464.js');
///*
  yui('464s');
  comp( '464s',
        file_get_contents('rom/k-cpc.pal').
        file_get_contents('rom/k-cpc.bin').
        file_get_contents('rom/464.rom').
        file_get_contents('rom/464.mem').
        file_get_contents('464s.js'));
  unlink('464s.js');
///*
  yui('664');
  comp( '664',
        file_get_contents('rom/k-cpc.pal').
        file_get_contents('rom/k-cpc.bin').
        file_get_contents('rom/664.rom').
        file_get_contents('rom/664.mem').
        file_get_contents('664.js'));
  unlink('664.js');
///*
  yui('664s');
  comp( '664s',
        file_get_contents('rom/k-cpc.pal').
        file_get_contents('rom/k-cpc.bin').
        file_get_contents('rom/664.rom').
        file_get_contents('rom/664.mem').
        file_get_contents('664s.js'));
  unlink('664s.js');
///*
  yui('6128');
  comp( '6128',
        file_get_contents('rom/k-cpc.pal').
        file_get_contents('rom/k-cpc.bin').
        file_get_contents('rom/6128.rom').
        file_get_contents('rom/6128.mem').
        file_get_contents('6128.js'));
  unlink('6128.js');
///*
  yui('6128s');
  comp( '6128s',
        file_get_contents('rom/k-cpc.pal').
        file_get_contents('rom/k-cpc.bin').
        file_get_contents('rom/6128.rom').
        file_get_contents('rom/6128.mem').
        file_get_contents('6128s.js'));
  unlink('6128s.js');
///*
  yui('3');
  comp( '3',
        file_get_contents('rom/k-trs.pal').
        file_get_contents('rom/k-trs.bin').
        file_get_contents('rom/trs80-3.rom').
        file_get_contents('rom/trs80-char.bin').
        file_get_contents('3.js'));
  unlink('3.js');
///*
  yui('ace');
  exec("sjasmplus bascolace.asm");
  $rom= substr(file_get_contents('bascolace.rom'), 0x4300-18, 0x2000).
        substr(file_get_contents('bascolace.rom'), 0, 0x2000);
  $rom[0x250a]= chr(0xed);
  $rom[0x250b]= chr(0xfc);
  comp( 'ace',
        file_get_contents('rom/k-ace.pal').
        file_get_contents('rom/k-ace.bin').
        $rom.
        file_get_contents('ace.js'));
  file_put_contents('bascol1.rom', substr(file_get_contents('bascolace.rom'), 0x4300-18, 0x2000));
  file_put_contents('bascol2.rom', substr(file_get_contents('bascolace.rom'), 0, 0x2000));
  file_put_contents('bascol.raw.ace', file_get_contents('bascol.bin').
                                  str_pad('', 0x400, "\0").
                                  substr(file_get_contents('bascolace.rom'), 0x5f00-18, 0x400).
                                  substr(file_get_contents('bascolace.rom'), 0x5f00-18, 0x400).
                                  str_pad('', 0x1300, "\0").
                                  substr(file_get_contents('bascolace.rom'), 0x4300, 0x1900).
                                  str_pad('', 0xa358, "\0").
                                  substr(file_get_contents('bascolace.rom'), 0x6108-18, 0xa8));
  unlink('ace.js');
///*
  yui('jupace');
  $rom= file_get_contents('rom/ace.rom');
  $rom[0x18b6]= chr(0xed);
  $rom[0x18b7]= chr(0xfc);
  comp( 'JA',
        file_get_contents('rom/k-ace.pal').
        file_get_contents('rom/k-ace.bin').
        $rom.
        file_get_contents('jupace.js'));
  unlink('jupace.js');
///*
  yui('jupaces');
  $rom= file_get_contents('rom/ace.rom');
  $rom[0x18b6]= chr(0xed);
  $rom[0x18b7]= chr(0xfc);
  comp( 'JAs',
        file_get_contents('rom/k-ace.pal').
        file_get_contents('rom/k-ace.bin').
        $rom.
        file_get_contents('jupaces.js'));
  unlink('jupaces.js');
///*
  stderr('48.html');
  ob_start();$x=48;$y=0x10000;$title='jBacteria';
  require'emu.php';
  compg('48');
///*
  stderr('48s.html');
  ob_start();$x='48s';$y=0x10000;$title='jBacteria';
  require'emu.php';
  compg('48s');
///*
  stderr('tk90.html');
  ob_start();$x='tk90';$y=0x10000;$title='jBacteria';
  require'emu.php';
  compg('tk90');
///*
  stderr('tk90s.html');
  ob_start();$x='tk90s';$y=0x10000;$title='jBacteria';
  require'emu.php';
  compg('tk90s');
///*
  stderr('128.html');
  ob_start();$x=128;$y=0x14000;$title='jAmeba';
  require'emu.php';
  compg('128');
///*
  stderr('128i.html');
  ob_start();$x='128i';$y=0x14000;$title='jAmeba';
  require'emu.php';
  compg('128i');
///*
  stderr('128s.html');
  ob_start();$x='128s';$y=0x14000;$title='jAmeba';
  require'emu.php';
  compg('128s');
///*
  stderr('128is.html');
  ob_start();$x='128is';$y=0x14000;$title='jAmeba';
  require'emu.php';
  compg('128is');
///*
  stderr('16.html');
  ob_start();$x=16;$y=0x8000;$title='jBacteria';
  require'emu.php';
  compg('16');
///*
  stderr('16s.html');
  ob_start();$x='16s';$y=0x8000;$title='jBacteria';
  require'emu.php';
  compg('16s');
///*
  stderr('+2.html');
  ob_start();$x='+2';$y=0x14000;$title='jAmeba';
  require'emu.php';
  compg('+2');
///*
  stderr('+2s.html');
  ob_start();$x='+2s';$y=0x14000;$title='jAmeba';
  require'emu.php';
  compg('+2s');
///*
  stderr('+2A.html');
  ob_start();$x='+2A';$y=0x1C000;$title='jAmeba';
  require'emu.php';
  compg('+2A');
///*
  stderr('+2As.html');
  ob_start();$x='+2As';$y=0x1C000;$title='jAmeba';
  require'emu.php';
  compg('+2As');
///*
  stderr('+3.html');
  ob_start();$x='+3';$y=0x10000;$title='jAmeba';
  require'emu.php';
  compg('+3');
///*
  stderr('+3s.html');
  ob_start();$x='+3s';$y=0x10000;$title='jAmeba';
  require'emu.php';
  compg('+3s');
///*
  stderr('SE.html');
  ob_start();$x='SE';$y=0x10000;$title='jBacteria';
  require'emu.php';
  compg('SE');
///*
  stderr('SEs.html');
  ob_start();$x='SEs';$y=0x10000;$title='jBacteria';
  require'emu.php';
  compg('SEs');
///*
  stderr('464.html');
  error_log("464.html");
  ob_start();$x='464';$y=0x18000;$title='Roland464';
  require'emu_cpc.php';
  compg('464');
///*
  stderr('464s.html');
  ob_start();$x='464s';$y=0x18000;$title='Roland464';
  require'emu_cpc.php';
  compg('464s');
///*
  stderr('664.html');
  ob_start();$x='664';$y=0x1c000;$title='Roland664';
  require'emu_cpc_disk.php';
  compg('664');
///*
  stderr('664s.html');
  ob_start();$x='664s';$y=0x1c000;$title='Roland664';
  require'emu_cpc_disk.php';
  compg('664s');
///*
  stderr('6128.html');
  ob_start();$x='6128';$y=0x1c000;$title='Roland6128';
  require'emu_cpc_disk.php';
  compg('6128');
///*
  stderr('6128s.html');
  ob_start();$x='6128s';$y=0x1c000;$title='Roland6128';
  require'emu_cpc_disk.php';
  compg('6128s');
///*
  stderr('3.html');
  ob_start();$x=3;$y=0x3800+0xf00;$title='jTandyIII';
  require'emu_trs.php';
  compg('3');
///*
  stderr('ace.html');
  ob_start();$x='ace';$y=0x4000;$title='jupiler';
  require'emu_ace.php';
  compg('ace');
///*
  stderr('JA.html');
  ob_start();$x='JA';$y=0x2000;$title='jupiler';
  require'emu_ace.php';
  compg('JA');
///*
  stderr('JAs.html');
  ob_start();$x='JAs';$y=0x2000;$title='jupiler';
  require'emu_ace.php';
  compg('JAs');
//*/
  if( $slow ){
    unlink('aa.rom');
    unlink('temp.zip');
  }
?>