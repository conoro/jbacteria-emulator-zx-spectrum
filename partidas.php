<!DOCTYPE HTML>
<html>
<head><title>Recorded games</title>
<style type="text/css">
.lim{
  display:block;
  height:20px;
  overflow:hidden;
}
</style></head>
<body>
<table style="width:960px;margin:40px auto;border-spacing:0px">
  <thead style="text-align:left;background:#CCC"><tr>
    <th width="200px">Name (click to view)</th>
    <th width="200px">Publisher (save Z80)</th>
    <th width="70px">Time</th>
    <th width="50px">F3</th>
    <th width="50px">F4</th>
    <th width="100px">User</th>
    <th>Comment</th></thead></tr>
  <tbody>
    <tr><td></td></tr>
<?
  require 'connect.php';
  $rs= $db->query('SELECT * FROM spectrum_record'.($_GET['user']?' WHERE nickname="'.$_GET['user'].'"':''));
  while( $row= $rs->fetch_assoc() ){?>
    <tr<?=$xx++&1?' style="background:#f0f0f0"':''?>>
      <td>
        <a class="lim" href="<?=$row['url'].'?'.$row['shortid'].'.rec'?>"><?=$row['name_year']?></a></td>
      <td>
        <a class="lim" href="<?='snaps/'.$row['shortid'].'.z80'?>"><?=$row['publisher']?></a></td>
      <td>
        <?=sprintf('%02d:%02d', floor($row['runtime']/3000), floor($row['runtime']/50)%60)?></td>
      <td>
        <?=$row['f3']?></td>
      <td>
        <?=$row['f4']?></td>
      <td>
        <a href="?user=<?=$row['nickname']?>"><?=$row['nickname']?></a></td>
      <td class="lim" title="<?=$row['comment']?>">
        <?=$row['comment']?></td></tr>
<?}?>
</tbody></table>
<?
/*create table spectrum_record(
  shortid     VARCHAR(6)
, url         ENUM('16', '48', '128', '16s', '48s', '128s')
, runtime     INT
, name_year   TEXT
, publisher   TEXT
, f3          SMALLINT
, f4          SMALLINT
, nickname    VARCHAR(20)
, comment     TEXT
, PRIMARY KEY (shortid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;*/
?>