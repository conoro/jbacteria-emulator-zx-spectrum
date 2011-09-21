//debug_mode= 0;

function fdcinit(){;
  current_time= fdc_status_delay= fdc_st0= fdc_motor= head_sector_pos= head_track_pos= fdd_ft= fdd_dsk_loaded= 0;
  fdd_ts= fdd_wp= 1;
  fdd_dsk_loaded= game && dsk_loader();
  fdc_change_state(FDC_INACTIVE);
  fdc_irq_status= FDC_CMD_RESET;
}

function dsk_loader(){
  if( game.substr(0, 11)=='MV - CPCEMU' || game.substr(0, 18)=='MV - CPC Disk-File' )
    extended_dsk= 0;
  else if( game.substr(0, 34)=='EXTENDED CPC DSK File\r\nDisk-Info\r\n' )
    extended_dsk= 1;
  else
    return alert('Error: Invalid dsk file');
  dsk_trackcount= game.charCodeAt(48);
  dsk_sidecount= game.charCodeAt(49);
  dsk_track_data= [];
  track_info_start= 256;
  extended_dsk || (dsk_tracksize= game.charCodeAt(50) | game.charCodeAt(51) << 8);
  for ( t= 0; t < dsk_trackcount; t++ )
    for ( dsk_track_data[t]= [], u= 0; u < dsk_sidecount && track_info_start<game.length; u++ )
      extended_dsk && (dsk_tracksize= game.charCodeAt(t*dsk_sidecount + u + 52) << 8),
      dsk_track_data[t][u]= parse_track(track_info_start),
      track_info_start += dsk_tracksize;
  return 1;
}

function parse_track(c) {
  var gt= [];
  gt= [];
  sector_data_start= (gt.length > 29 ? 512 : 256) + c;
  for ( var d = 0; d < game.charCodeAt(21 + c); d++ )
    sector_info_start= 24 + c + d*8,
    gt[d]= parse_sector(sector_info_start, sector_data_start),
    sector_data_start+= extended_dsk
                        ? gt[d].data[0].length * gt[d].data.length
                        : 1 << (7 + game.charCodeAt(20 + c) & 7);
  return gt;
}

function parse_sector(c, d) {
  generated_sector= {};
  generated_sector.weak_idx= 1;
  generated_sector.track= game.charCodeAt(c);
  generated_sector.side= game.charCodeAt(1 + c);
  generated_sector.id= game.charCodeAt(2 + c);
  generated_sector.size= game.charCodeAt(3 + c);
  generated_sector.st1= game.charCodeAt(4 + c);
  generated_sector.st2= game.charCodeAt(5 + c);
  weak_copycount= 1;
  fdc_bytesize = Math.pow(2, 7 + (generated_sector.size & 0x07));
  if (extended_dsk)
    sector_datasize= game.charCodeAt(0x06 + c) | game.charCodeAt(7 + c)<<8,
    sector_datasize%fdc_bytesize || ( weak_copycount= sector_datasize / fdc_bytesize,
                                      sector_datasize= fdc_bytesize );
  else
    sector_datasize= fdc_bytesize;
  generated_sector.data= [];
  for (var f= 0; f < weak_copycount; f++){
    generated_sector.data[f]= [];
    for (var g= 0; g < sector_datasize; g++)
      generated_sector.data[f][g]= game.charCodeAt(g + d + f*fdc_bytesize);
  }
  return generated_sector;
}

fdc_params = [],
fdc_results = [];

FDC_TO_CPU = 0,
CPU_TO_FDC = 1,
NO_TRANSFER = 2;
FDC_CMD_RESET = 0,
FDC_CMD_SUCCEED = 1,
FDC_CMD_FAILED_ATEC = 2,
FDC_CMD_FAILED_ATRY = 3;
FDC_INACTIVE = 0,
FDC_COMMAND = 1,
FDC_EXECUTE = 2,
FDC_RESULT = 3;
FDC_PARAM_CODE = 0,
FDC_PARAM_C = 1,
FDC_PARAM_H = 2,
FDC_PARAM_R = 3,
FDC_PARAM_N = 4,
FDC_PARAM_EOT = 5,
FDC_PARAM_GPL = 6,
FDC_PARAM_DTL = 7;
FDC_PARAM_NCN = 1;
FDC_RES_ST0 = 0,
FDC_RES_ST1 = 1,
FDC_RES_ST2 = 2,
FDC_RES_C = 3,
FDC_RES_H = 4,
FDC_RES_R = 5,
FDC_RES_N = 6;
FDC_RES_ST3 = 0,
FDC_RES_PCN = 1;
FDC_CMD_EXEC = 0,
FDC_CMD_MASK = 1,
FDC_CMD_PARAMS = 2,
FDC_CMD_WAY = 3,
FDC_CMD_RES = 4,
FDC_CMD_NAME = 5;
fdc_read_data = [exec_fdc_read_data, 0, 8, FDC_TO_CPU, 7, "read_data (0x06)"];
fdc_read_del_data = [exec_fdc_read_data, 0, 8, FDC_TO_CPU, 7, "read_del_data (0x0c)"];
fdc_write_data = [exec_fdc_write_data, 0x01, 8, CPU_TO_FDC, 7, "write_data (0x05)"];
fdc_write_del_data = [exec_fdc_write_data, 0x01, 8, CPU_TO_FDC, 7, "write_del_data (0x09)"];
fdc_read_track = [exec_fdc_read_track, 0x04, 8, FDC_TO_CPU, 7, "read_track (0x02)"];
fdc_read_id = [exec_fdc_read_id, 0x05, 1, NO_TRANSFER, 7, "read_id (0x0a)"];
fdc_format_track = [exec_fdc_format_track, 0x05, 5, CPU_TO_FDC, 7, "format_track (0x0d)"];
fdc_scan_eq = [exec_fdc_scan_eq, 0, 8, CPU_TO_FDC, 7, "scan_eq (0x11)"];
fdc_scan_low_or_eq = [exec_fdc_scan_low_or_eq, 0, 8, CPU_TO_FDC, 7, "scan_low_or_eq (0x19)"];
fdc_scan_high_or_eq = [exec_fdc_scan_high_or_eq, 0, 8, CPU_TO_FDC, 7, "scan_high_or_eq (0x1d)"];
fdc_recalib = [exec_fdc_recalib, 0x07, 1, NO_TRANSFER, 0, "recalib (0x07)"];
fdc_sense_int_status = [exec_fdc_sense_int_status, 0x07, 0, NO_TRANSFER, 2, "sense_int_status (0x08)"];
fdc_specify = [exec_fdc_specify, 0x07, 2, NO_TRANSFER, 0, "specify (0x03)"];
fdc_sense_drive_status = [exec_fdc_sense_drive_status, 0x07, 1, NO_TRANSFER, 1, "sense_drive_status (0x04)"];
fdc_seek = [exec_fdc_seek, 0x07, 2, NO_TRANSFER, 0, "seek (0x0f)"];
fdc_invalid_op = [exec_fdc_invalid_op, 0, 0, NO_TRANSFER, 1, "invalid_op"];
function fdcdr() {
  switch (fdc_state) {
  case FDC_EXECUTE:
    if (fdc_decoded[FDC_CMD_WAY] == FDC_TO_CPU) {
      fdc_overrun_timestamp = current_time;
      fdc_status_delay = true;
      return fdc_decoded[FDC_CMD_EXEC]();
    } else {
      alert("Error - data_read() - Invalid way for this FDC instruction");
      return 0xff;
    }
    break;
  case FDC_RESULT:
    var c = fdc_results[fdc_state_idx];
    fdc_state_idx++;
    if (fdc_state_idx == fdc_decoded[FDC_CMD_RES]) fdc_change_state(FDC_INACTIVE);
    return c;
    break;
  default:
    alert("Error - data_read() - Invalid FDC state");
    return 0xff;
  }
}
function fdcdw(c) {
  switch (fdc_state) {
  case FDC_INACTIVE:
    fdc_decode_cmd(c);
    fdc_calc_state();
    break;
  case FDC_COMMAND:
    fdc_params[fdc_state_idx] = c;
    fdc_state_idx++;
    fdc_calc_state();
    break;
  case FDC_EXECUTE:
    if (fdc_decoded[FDC_CMD_WAY] == CPU_TO_FDC) {
      fdc_overrun_timestamp = current_time;
      fdc_decoded[FDC_CMD_EXEC](c);
    } else alert("Error - data_write() - Invalid way for this FDC instruction");
    break;
  default:
    alert("Error - data_write() - Invalid FDC state: " + fdc_state);
  }
}
function fdc_calc_state() {
  if (fdc_state_idx == fdc_decoded[FDC_CMD_PARAMS]) {
    fdc_decoded[FDC_CMD_EXEC]();
    if (fdc_decoded[FDC_CMD_RES] == 0) fdc_change_state(FDC_INACTIVE);
    else if (fdc_state != FDC_RESULT) {
      if (fdc_decoded[FDC_CMD_WAY] == NO_TRANSFER) fdc_change_state(FDC_RESULT);
      else fdc_change_state(FDC_EXECUTE);
    }
  }
}
function fdcmsr() {
  var c = 0x80;
  switch (fdc_state) {
  case FDC_COMMAND:
    c |= 0x10;
    break;
  case FDC_EXECUTE:
    if (fdc_status_delay) {
      fdc_status_delay = false;
      c = 0x10;
    } else c |= 0x30;
    if (fdc_decoded[FDC_CMD_WAY] == FDC_TO_CPU) c |= 0x40;
    break;
  case FDC_RESULT:
    c |= 0x50;
  }
  return c;
}
function fdcmw(c) {
  if (c & 0x01) fdc_motor = true;
  else fdc_motor = false;
}
function fdc_decode_cmd(c) {
  switch (c & 31){
    case 0x02:
      fdc_decoded = fdc_read_track;
      break;
    case 0x03:
      fdc_decoded = fdc_specify;
      break;
    case 0x04:
      fdc_decoded = fdc_sense_drive_status;
      break;
    case 0x05:
      fdc_cmd_dam = false;
      fdc_decoded = fdc_write_data;
      break;
    case 0x06:
      fdc_cmd_dam = false;
      fdc_decoded = fdc_read_data;
      break;
    case 0x07:
      fdc_decoded = fdc_recalib;
      break;
    case 0x08:
      fdc_decoded = fdc_sense_int_status;
      break;
    case 0x09:
      fdc_cmd_dam = true;
      fdc_decoded = fdc_write_del_data;
      break;
    case 0x0a:
      fdc_decoded = fdc_read_id;
      break;
    case 0x0c:
      fdc_cmd_dam = true;
      fdc_decoded = fdc_read_del_data;
      break;
    case 0x0d:
      fdc_decoded = fdc_format_track;
      break;
    case 0x0f:
      fdc_decoded = fdc_seek;
      break;
    case 0x11:
      fdc_decoded = fdc_scan_eq;
      break;
    case 0x19:
      fdc_decoded = fdc_scan_low_or_eq;
      break;
    case 0x1d:
      fdc_decoded = fdc_scan_high_or_eq;
      break;
    default:
  // console.log('invalid '+hex(c));
      fdc_decoded = fdc_invalid_op;
  }
  var d = (c >>> 5) & fdc_decoded[FDC_CMD_MASK];
  if ((d != 0) || (fdc_decoded == fdc_invalid_op)) {
    fdc_decoded = fdc_invalid_op;
  } else {
    fdc_cmd_mt = d & 0x04;
    fdc_cmd_mf = d & 0x02;
    fdc_cmd_sk = d & 0x01;
  }
  fdc_state_idx = 0;
  fdc_change_state(FDC_COMMAND);
}
function fdc_find_sector() {
  var sectors_count = fdc_current_track.length;
  var c = head_sector_pos;
  do {
    var d = fdc_current_track[head_sector_pos];
    head_sector_pos = (head_sector_pos + 1) % sectors_count;
    if ((d.side == fdc_params[FDC_PARAM_H]) && (d.id == fdc_params[FDC_PARAM_R]) && (d.size == fdc_params[FDC_PARAM_N])) {
      d.weak_idx = (d.weak_idx + 1) % d.data.length;
      fdc_st1 = d.st1 & 0xa5;
      fdc_st2 = d.st2 & 0x61;
      if (fdc_cmd_dam) fdc_st2 ^= 0x40;
      return d;
    }
  } while (c != head_sector_pos);
  head_sector_pos = 0;
  return false;
}
function fdc_get_sector() {
  fdc_state_idx = 0;
  while (true) {
    fdc_current_sector = fdc_find_sector();
    if (fdc_cmd_sk == 0) break;
    if (fdc_current_sector == false) break;
    if (((fdc_st2 & 0x40) >>> 6) == 0) break;
    if (fdc_params[FDC_PARAM_R] == fdc_params[FDC_PARAM_EOT]) {
      fdc_current_sector = false;
      break;
    }
    fdc_params[FDC_PARAM_R] = (fdc_params[FDC_PARAM_R] + 1) & 0xff;
  }
  if (fdc_current_sector == false) {
    if (fdc_current_track.length == 0) push_full_result(0x05, 0x01);
    else push_full_result(0x04, 0);
    return;
  }
  if (fdc_current_sector.track != fdc_params[FDC_PARAM_C]) {
    if (fdc_params[FDC_PARAM_C] == 0xff) push_full_result(0x04, 0x02);
    else push_full_result(0x04, 0x10);
    return;
  }
  if (fdc_params[FDC_PARAM_N] == 0) fdc_dtl = fdc_params[FDC_PARAM_DTL];
  else fdc_dtl = fdc_current_sector.data[fdc_current_sector.weak_idx].length;
}
function exec_fdc_read_data() {
  switch (fdc_state) {
  case FDC_COMMAND:
    if (fdd_select_and_check()) {
      if (fdc_current_track == undefined) {
        push_full_result(0x05, 0x01);
      } else fdc_get_sector();
    } else {
      fdc_st0 |= 0x48;
      push_full_result(0, 0);
    }
    break;
  case FDC_EXECUTE:
    var c = fdc_current_sector.data[fdc_current_sector.weak_idx][fdc_state_idx];
    fdc_state_idx++;
    if (fdc_state_idx == fdc_dtl) {
      if ((fdc_params[FDC_PARAM_R] == fdc_params[FDC_PARAM_EOT]) && (fdc_st1 == 0)) fdc_st1 = 0x80;
      if ((fdc_st1 != 0) || (fdc_st2 != 0)) {
        push_full_result(fdc_st1, fdc_st2);
      } else {
        fdc_params[FDC_PARAM_R] = (fdc_params[FDC_PARAM_R] + 1) & 0xff;
        fdc_get_sector();
      }
    }
    return c;
  default:
    alert("Error - exec_cmd_read_data() - Invalid state");
  }
}
function exec_fdc_write_data() {
  alert("Error - exec_cmd_write_data() - Not implemented yet");
  fdd_select_and_check();
  push_full_result();
}
function exec_fdc_read_track() {
  alert("Error - exec_cmd_read_track() - Not implemented yet");
  fdd_select_and_check();
  push_full_result();
}
function exec_fdc_read_id() {
  if (fdd_select_and_check()) {
    if (fdc_current_track != undefined) var sectors_count = fdc_current_track.length;
    else var sectors_count = 0;
    if (sectors_count == 0) var st1 = 0x05;
    else {
      var c = fdc_current_track[head_sector_pos];
      head_sector_pos = (head_sector_pos + 1) % sectors_count;
      var st1 = 0;
      fdc_params[FDC_PARAM_C] = c.track;
      fdc_params[FDC_PARAM_H] = c.side;
      fdc_params[FDC_PARAM_R] = c.id;
      fdc_params[FDC_PARAM_N] = c.size;
    }
  } else {
    fdc_st0 |= 0x08;
    var st1 = 0x05;
  }
  push_full_result(st1, 0);
}
function exec_fdc_format_track() {
  alert("Error - exec_cmd_format_track() - Not implemented yet");
  fdd_select_and_check();
  push_full_result();
}
function exec_fdc_scan_eq() {
  alert("Error - exec_cmd_scan_eq() - Not implemented yet");
  fdd_select_and_check();
  push_full_result();
}
function exec_fdc_scan_low_or_eq() {
  alert("Error - exec_cmd_scan_low_or_eq() - Not implemented yet");
  fdd_select_and_check();
  push_full_result();
}
function exec_fdc_scan_high_or_eq() {
  alert("Error - exec_cmd_scan_high_or_eq() - Not implemented yet");
  fdd_select_and_check();
  push_full_result();
}
function exec_fdc_recalib() {
  if (fdd_select_and_check()) {
    if (head_track_pos - 77 > 0) fdc_irq_status = FDC_CMD_FAILED_ATEC;
    else fdc_irq_status = FDC_CMD_SUCCEED;
    if (head_track_pos != 0) head_sector_pos = 0;
  } else fdc_irq_status = FDC_CMD_FAILED_ATRY;
  head_track_pos = 0;
}
function exec_fdc_sense_int_status() {
  fdc_st0 = (fdc_current_hd << 2) | fdc_current_us;
  switch (fdc_irq_status) {
  case FDC_CMD_SUCCEED:
    fdc_st0 |= 0x20;
    break;
  case FDC_CMD_FAILED_ATEC:
    fdc_st0 |= 0x70;
    break;
  case FDC_CMD_FAILED_ATRY:
    fdc_st0 |= 0x68;
    break;
  case FDC_CMD_RESET:
    fdc_st0 = 0x80;
    break;
  default:
    alert("Error - exec_cmd_sense_int_status() - Invalid state");
  }
  fdc_irq_status = FDC_CMD_RESET;
  fdc_results[FDC_RES_ST0] = fdc_st0;
  fdc_results[FDC_RES_PCN] = head_track_pos;
}
function exec_fdc_specify() {
  fdc_setting_srt = (fdc_params[0] >>> 4) & 0x0f;
  fdc_setting_hut = fdc_params[0] & 0x0f;
  fdc_setting_hlt = (fdc_params[1] >>> 1) & 0x7f;
  fdc_setting_nd = fdc_params[1] & 0x01;
}
function exec_fdc_sense_drive_status() {
  if (fdd_select_and_check()) fdd_ry = 1;
  else fdd_ry = 0;
  var c = (fdd_ft << 7) | (fdd_wp << 6) | (fdd_ry << 5) | (head_track_pos == 0) | (fdd_ts << 3) | (fdc_current_hd << 2) | fdc_current_us;
  fdc_results[FDC_RES_ST3] = c;
}
function exec_fdc_seek() {
  if (fdd_select_and_check()) {
    if (head_track_pos != fdc_params[FDC_PARAM_NCN]) head_sector_pos = 0;
    fdc_irq_status = FDC_CMD_SUCCEED;
  } else fdc_irq_status = FDC_CMD_FAILED_ATRY;
  head_track_pos = Math.min(fdc_params[FDC_PARAM_NCN], dsk_trackcount - 1);
}
function exec_fdc_invalid_op() {
  fdc_results[FDC_RES_ST0] = 0x80;
}
function fdd_select_and_check() {
  fdc_current_hd = (fdc_params[FDC_PARAM_CODE] >>> 2) & 0x01;
  fdc_current_us = fdc_params[FDC_PARAM_CODE] & 0x03;
  fdc_st0 = fdc_params[FDC_PARAM_CODE] & 0x07;
  if (fdc_current_us == 0) if (((dsk_sidecount == 1) && (fdc_current_hd == 0)) || (dsk_sidecount > 1)) {
    fdc_current_track = dsk_track_data[head_track_pos][fdc_current_hd];
    return fdd_dsk_loaded && fdc_motor;
  } else return false;
}
function push_full_result(st1, c) {
  if ((st1 != 0) || (c != 0)) fdc_st0 |= 0x40;
  fdc_results[FDC_RES_ST0] = fdc_st0;
  fdc_results[FDC_RES_ST1] = st1;
  fdc_results[FDC_RES_ST2] = c;
  fdc_results[FDC_RES_C] = fdc_params[FDC_PARAM_C];
  fdc_results[FDC_RES_H] = fdc_params[FDC_PARAM_H];
  fdc_results[FDC_RES_R] = fdc_params[FDC_PARAM_R];
  fdc_results[FDC_RES_N] = fdc_params[FDC_PARAM_N];
  fdc_change_state(FDC_RESULT);
}
function fdc_change_state(c) {
/*  if (debug_mode) {
    if (c == FDC_COMMAND) fdc_debug_str = " Track:" + head_track_pos + " - Sector:" + head_sector_pos + " - PC:"+hex(pc)+" - Command: " + fdc_decoded[5];
    else if (fdc_state == FDC_COMMAND) {
      if (fdc_decoded[FDC_CMD_PARAMS] > 0) {
        var d = fdc_params.slice(0, fdc_decoded[FDC_CMD_PARAMS]);
        fdc_debug_str += " - Params: " + d;
      }
    }
    if (c == FDC_RESULT) {
      var d = fdc_results.slice(0, fdc_decoded[FDC_CMD_RES]);
      fdc_debug_str += " - Results: " + d;
    } else if ((c == FDC_INACTIVE) && (fdc_debug_str != undefined)) console.log(fdc_debug_str);
  }*/
  c == FDC_EXECUTE && (fdc_overrun_timestamp= -1);
  fdc_state= c;
  fdc_state_idx= 0;
}