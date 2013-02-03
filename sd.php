<?
  $str= file_get_contents('php://input');
  $cad= explode( ',', $str );
  $fi= fopen('\emuscriptoria\andros\disco.bin', 'r');
  if( $cad[0]==0x52 || $cad[0]==0x51 ){
    $num= $cad[4] | $cad[3]<<8 | $cad[2]<<16 | $cad[1]<<24;
    fseek($fi, $num);
    echo fread($fi, 512);
    fclose($fi);
  }
  else{
    echo 'error';
  }
?>