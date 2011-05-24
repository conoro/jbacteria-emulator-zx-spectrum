function fdcinit(){
  fdcint= fdctrack= st0= st1= st2= st3= params= readp= command= 0;
  endsector= startsector= 1;
  paramdat= [];
  fdcs= 0x80;
  tra= [];
  sect= [];
  sects= [];
  o= 0x100;
  if(!game)
    return;
  if(game.substr(0, 8) == 'MV - CPC'){
    x= game.charCodeAt(0x32) & 255 | game.charCodeAt(0x33) << 8 & 65535;
    for (t= 0; t < game.charCodeAt(0x30); t++){
      for (u= 0, v= o+0x100, sect[t]= [], sects[t]= []; u < game.charCodeAt(o+0x15); u++)
        sect[t][w= game.charCodeAt(o+(u+3<<3)+2)&15]= v,
        v+= sects[t][w]= 0x80<<game.charCodeAt(o+0x14);
      tra[t]= o;
      o+= x;
    }
  }
  else if(game.substr(0, 8) == 'EXTENDED'){
    for (t= 0; t < game.charCodeAt(0x30); t++)
      if(x= game.charCodeAt(t*game.charCodeAt(0x31)+0x34) << 8){
        for (u= 0, v= o+0x100, sect[t]= [], sects[t]= []; u < game.charCodeAt(o+0x15); u++)
          sect[t][w= game.charCodeAt(o+(u+3<<3)+2)&15]= v,
          v+= sects[t][w]= game.charCodeAt(o+(u+3<<3)+6) | game.charCodeAt(o+(u+3<<3)+7) << 8;
        tra[t]= o;
        o+= x;
      }
  }
  else
    alert('Invalid DSK file');
}

function fdcmw(val){
  mon= val&1;
//  console.log('fdc_motor_write', val, hex(pc));
}

function fdcdr(){
  if (!readp)
    alert('Reading but no params in '+hex(command)+', pc='+hex(pc));
 switch (command){
    case 0x04: /*Sense drive status*/
      readp= 0;
      fdcs= 0x80;
      return st3;

    case 0x06: /*Read sectors*/
    case 0x0C: /*Read deleted sectors*/
      if (reading){
        temp= game.charCodeAt(posinsector+sect[fdctrack][startsector]) & 255;
//if(caca++<20)
//  console.log(temp, hex(pc));
        posinsector++;
        if (posinsector==sects[fdctrack][startsector]){

//console.log(posinsector, m[pc>>14][pc&16383], hex(pc), hex(l|h<<8), fdctrack, fdctrack, startsector-1, endsector-1);
          if ((startsector&15)==(endsector&15)){
// console.log(fdctrack, startsector, hex(game.charCodeAt(1+sect[fdctrack][0][startsector-1]) & 255 |
//                                        game.charCodeAt(0+sect[fdctrack][0][startsector-1])<<8 & 65535));
            reading= 0;
            readp= 7;
            fdcs= 0xD0;
            fdcint= 1;
          }
          else{
            posinsector= 0;
            startsector++;
// alert('fdc error');
            if ((startsector&15)>game.charCodeAt(0x15+tra[fdctrack])){
              if (command&0x80)
                fdctrack++;
              startsector= 0xC1;
            }
          }
        }
        return temp;
      }
      readp--;
      switch (readp){
        case 6: st0=0x40; st1=0x80; st2=0; return st0;
        case 5: return st1;
        case 4: return st2;
        case 3: return fdctrack;
        case 2: return 0;
        case 1: return startsector;
        case 0: fdcs=0x80; return 2;
      }
      break;

    case 0x86: /*Read sector fail*/
      readp--;
      switch (readp){
        case 6: st0=0x40; st1=0x84; st2=0; return st0;
        case 5: return st1;
        case 4: return st2;
        case 3: return fdctrack;
        case 2: return 0;
        case 1: return startsector;
        case 0: fdcs= 0x80; return 2;
      }
      break;

    case 0x08: /*Sense interrupt state*/
      readp--;
      if (readp==1)
        return st0;
      fdcs= 0x80;
      return fdctrack;

    case 0x0A: /*Read sector ID*/
      st0= 0;
      readp--;
      switch (readp){
        case 6: return st0;
        case 5: return st1;
        case 4: return st2;
        case 3: return game.charCodeAt(  tra[fdctrack]|startsector+3<<3) & 255;
        case 2: return game.charCodeAt(1|tra[fdctrack]|startsector+3<<3) & 255;
        case 1: return game.charCodeAt(2|tra[fdctrack]|startsector+3<<3) & 255;
        case 0: fdcs= 0x80;
console.log('ReadIdResult', hex(pc),game.charCodeAt(  tra[fdctrack]|startsector+3<<3) & 255,
                                    game.charCodeAt(1|tra[fdctrack]|startsector+3<<3) & 255,
                                    game.charCodeAt(2|tra[fdctrack]|startsector+3<<3) & 255,
                                    game.charCodeAt(3|tra[fdctrack]|startsector+3<<3) & 255);
                return game.charCodeAt(3|tra[fdctrack]|startsector+3<<3) & 255;
      }
      break;

    default:
      alert('Reading command '+hex(command)+', pc='+hex(pc));
  }
}

function fdcdw(val){
//  console.log('fdc_data_write', hex(val), hex(pc));
  if (params){
    paramdat[params-1]= val;
    params--;
    if (!params){
      switch (command){
        case 0x03: /*Specify*/
console.log('Specify', hex(pc), paramdat[1], paramdat[0]);
          fdcs= 0x80;
          break;
        case 0x04: /*Sense drive status*/
          st3= 0x41;
          if (!fdctrack)
            st3|= 0x10;
          fdcs= 0xd0;
          readp= 1;
console.log('Sense', hex(pc), hex(st3));
          break;

        case 0x06: /*Read sectors*/
        case 0x0C: /*Read deleted sectors*/
          fdctrack= paramdat[6];
          startsector= paramdat[4] & 15;
          endsector= paramdat[2] & 15;
console.log(endsector, hex(m[3][0x240b]), paramdat);
console.log('Read', hex(pc), hex(command), fdctrack, startsector, endsector);
          posinsector= 0;
          readp= 1;
          reading= 1;
          fdcs= 0xf0;
          break;

        case 0x07: /*Recalibrate*/
console.log('Recalibrate', hex(pc), paramdat[0]);
          fdcs= 0x80;
          fdctrack= 0;
          fdcint= 1;
          break;

        case 0x0A: /*Read sector ID*/
console.log('ReadId', hex(pc), paramdat[0], fdctrack, startsector, endsector);
          fdcs= 0xd0;//0x60;
          readp= 7;
          break;

        case 0x0F: /*Seek*/
          fdcs= 0x80;
          fdctrack= paramdat[0];
console.log('Seek', hex(pc), paramdat[1], fdctrack);
          fdcint= 1;
          break;

        default:
          alert('Executing bad command '+hex(command)+', pc='+hex(pc));
      }
    }
  }
  else{
    command= val & 0x1F;
    switch (command){
      case 0: case 0x1F: return; /*Invalid*/
      case 0x03: /*Specify*/
        params= 2;
        fdcs= 0x80;
        break;

      case 0x04: /*Sense drive status*/
        params= 1;
        fdcs= 0x80;
        break;

      case 0x06: /*Read sectors*/
      case 0x0C: /*Read deleted sectors*/
        params= 8;
        fdcs= 0x80;
        break;

      case 0x07: /*Recalibrate*/
        params= 1;
        fdcs= 0x80;
        break;

      case 0x08: /*Sense interrupt state*/
        st0= 0x20;
        if (!fdcint)
          st0|= 0x80;
        else
          fdcint= 0;
        fdcs= 0xD0;
        readp= 2;
        break;

      case 0x0A: /*Read sector ID*/
        params= 1;
        fdcs= 0x80;
        break;

      case 0x0F: /*Seek*/
        params= 2;
        fdcs= 0x80;
        break;

      default:
        alert('Starting bad command: '+hex(command)+', pc='+hex(pc));
    }
  }
}