/////////////
    time= flash= 0;
    put= top==self ? document : parent.document;
    titul= function(){
      put.title= 'na'+parseInt(32000/((nt= new Date().getTime())-time))+'%';
    }
/////////////
function Spectrum() {
    function bx(a, b) {
        var c = Array(a);
        do c[--a] = b;
        while (a > 0);
        return c
    }
    function ay_tick() {
        var a = 0;
        --bs.acnt & bs.aper || (bs.acnt = -1,
                                a ^= 1),
        --bs.bcnt & bs.bper || (bs.bcnt = -1,
                                a ^= 2),
        --bs.ccnt & bs.cper || (bs.ccnt = -1,
                                a ^= 4);
        return  (bs.div16 ^= 1)
                    ? ( bs.gen ^= a,
                        a & bs.mix)
                    : ( --bs.ncnt & bs.nper || (bs.ncnt = -1,
                                                bs.noise & 1 && ( a ^= 56,
                                                                  bs.noise ^= 163840),
                                                bs.noise >>= 1),
                        --bs.ecnt & bs.eper || (bs.ecnt = -1,
                                                bs.ekeep && ( bs.estep ||(bs.eattack ^= bs.ealt,
                                                                          bs.ekeep >>= 1,
                                                                          bs.estep = 16),
                                                              bs.estep--,
                                                              bs.ech && ( bs.echanged(),
                                                                          a |= 256))),
                        bs.gen ^= a,
                        a & bs.mix)
    }
    function ay_echanged() {
        var a = bs.volt[bs.estep ^ bs.eattack],
            b = ay_ech;
        b & 1 && (bs.avol = a),
        b & 2 && (bs.bvol = a),
        b & 4 && (bs.cvol = a)
    }
    function ay_eshape(a) {
        a < 8 && (a = a < 4 ? 1 : 7),
        bs.ekeep = a & 1 ? 1 : -1,
        bs.ealt = a + 1 & 2 ? 15 : 0,
        bs.eattack = a & 4 ? 15 : 0,
        bs.estep = 15,
        bs.ecnt = -1,
        ay_echanged()
    }
    function ay_write(a, b) {
        switch (a) {
            case 0:
                bs.aper = bs.aper & 3840 | b;
                break;
            case 1:
                bs.aper = bs.aper & 255 | (b &= 15) << 8;
                break;
            case 2:
                bs.bper = bs.bper & 3840 | b;
                break;
            case 3:
                bs.bper = bs.bper & 255 | (b &= 15) << 8;
                break;
            case 4:
                bs.cper = bs.cper & 3840 | b;
                break;
            case 5:
                bs.cper = bs.cper & 255 | (b &= 15) << 8;
                break;
            case 6:
                bs.nper = b &= 31;
                break;
            case 7:
                bs.mix = ~ (b | bs.dis);
                break;
            case 8:
            case 9:
            case 10:
                var c = b &= 31,
                    d = 9 << a - 8;
                b   ? b < 16
                        ? ( bs.dis &= d = ~d,
                            bs.ech &= d)
                        : ( bs.dis &= ~d,
                            bs.ech |= d,
                            c = bs.estep ^ bs.eattack)
                    : ( bs.dis |= d,
                        bs.ech &= ~d),
                bs.mix = ~ (bs.reg[7] | bs.dis),
                c = bs.volt[c];
                switch (a) {
                    case 8:
                        bs.avol = c;
                        break;
                    case 9:
                        bs.bvol = c;
                        break;
                    case 10:
                        bs.cvol = c
                }
                break;
            case 11:
                bs.eper = bs.eper & 65280 | b;
                break;
            case 12:
                bs.eper = bs.eper & 255 | b << 8;
                break;
            case 13:
                ay_eshape(b &= 15)
        }
        bs.reg[a] = b
    }
    function br(a) {
        var b = pFE,
            c = b & 16  // EAR
                    ? b & 8 ? mic1 : mic0
                    : 0;
        bq(0, c - bn),
        bq(a - bm, 0),
        bm = a,
        bn = c
    }
    function bq(a, b) {
        a = bj - frec * a;
        while (a < 0)
            a += bh,
            bl++;
        bj = a,
        v = a * b / bh,
        bk[bl] += v,
        bk[bl + 1] += b - v
    }
    function paint_screen(a) {
//  console.log(X);
        function h(a) {
            var b = 0;
            a > 65535 && (a >>= b = 16),
            a > 255 && (a >>= 8, b += 8),
            a > 15 && (a >>= 4, b += 4);
            return b + (-21936 >> 2 * a & 3)
        }
        var b = V,
            c = b.canvas,
            d = c.width - width >> 1,
            e = c.height - X * height >> 1;
        I = 0;
        if (a < 0)
            return b.putImageData(W, d, e);
        var f = h(a),
            g = h(a ^ a - 1);
//console.log(f, g);
        b.putImageData(W, d, e, borderchar * 8, X * (8 * g + borderlines), 256, X * 8 * (f - g + 1))
    }
    function update_screen() {
//  console.log(1);
      W || createimage();
        var a, b,
            c = 0,
            d = 0;
        for (b = 0; b < 192 + 2 * borderlines; b++) {
            for (a = 0; a < 32 + 2 * borderchar; a++, c++)
                Z(c, d, J[c]);
            d += $
        }
        paint_screen(-1)
    }
    function renderinter(a, b, c) {
        J[a] = c,
        b += a * 32;
        var d = W.data,
            e, f, g,
            h = c >> 11;
        f = h & 15,
        h = c >> 8 & 7 | h & 8,
        e = Y[f],
        g = Y[h] ^ e,
        f = Y[f + 16],
        h = Y[h + 16] ^ f,
        c ^= c >> 1 & 127;
        do  c & 128 && (e ^= g,
                        f ^= h),
            c <<= 1,
            d[b] = e >> 16,
            d[b + 1] = e >> 8 & 255,
            d[b + 2] = e & 255,
            d[b + 4 * width] = f >> 16,
            d[b + 4 * width + 1] = f >> 8 & 255,
            d[b + 4 * width + 2] = f & 255;
        while ((b += 4) & 31)
    }
    function rendernormal(a, b, c) {
        J[a] = c,
        a *= 32;
        var d = W.data,
            e,
            f = c >> 11;
        e = Y[f & 15],
        f = Y[c >> 8 & 7 | f & 8] ^ e,
        c ^= c >> 1 & 127;
        do  c & 128 && (e ^= f),
            c <<= 1,
            d[a] = e >> 16,
            d[a + 1] = e >> 8 & 255,
            d[a + 2] = e & 255;
        while ((a += 4) & 31)
    }
    function createimage() {
        var a = V,
            b = X * height;
        a.createImageData
            ? W = a.createImageData(width, b)
            : window.ImageData
                ? W = new ImageData(width, b)
                : W = a.getImageData(0, 0, width, b);
        for (var c = 3; c < W.data.length; c += 4)
            W.data[c] = 255;
        Y = pal[+(X > 1)],
        Z = X < 2 ? rendernormal : renderinter,
        $ = (X - 1) * 4 * width
    }
    function refresh_border(a) {
        var b = P;
        if (!(a < b)) {
            T = -1;
            var c = Q,
                d = R,
                e = $ * (d + borderlines),
                f = borderchar + (borderchar + 32 + borderchar) * borderlines + (borderchar + 32 + borderchar) * d + c,
                h = border << 11;
            do {
                J[f] !== h && ( Z(f, e, h),
                                I = -1),
                f++,
                b += 4;
                if (!++c && d >= 0 && d < 192) {
                    f += c = 32,
                    b += 128;
                    continue
                }
                if (c < 32 + borderchar)
                    continue;
                c = -borderchar;
                if (++d == 8 * (24 + borderlines)) {
                    b = 99999;
                    break
                }
                b += cyclesline - 4 * (borderchar + 32 + borderchar),
                e += $
            } while (b <= a);
            Q = c,
            R = d,
            P = b
        }
    }
    function refresh_screen(a) {
//console.log(3);
        if (!(a < K)) {
            var b = L,
                c = b & 255 | b >> 3 & 768 | 6144,
                d = K,
                e = M,
                f = N,
                h = 1 << (c >> 5);
            do {
                var i = s[c++] << 8 | s[b++];
                i > 32767 && (i ^= H),
                J[e] !== i && ( Z(e, f, i),
                                I |= h),
                e++;
                var i = s[c++] << 8 | s[b++];
                i > 32767 && (i ^= H),
                J[e] !== i && ( Z(e, f, i),
                                I |= h),
                e++,
                d += 8;
                if (c & 31)
                    continue;
                d += cyclesline - 128,
                e += 2 * borderchar,
                f += $,
                c -= 32,
                b += 224;
                if (b & 1792)
                    continue;
                c += 32,
                b -= 2016,
                h <<= 1;
                if (b & 224)
                    continue;
                b += 1792;
                if (b >= 6144) {
                    d = 99999;
                    break
                }
            } while (a >= d);
            L = b,
            K = d,
            M = e,
            N = f
        }
    }
    function cont_port(b) {
        var c = a.time - ctime;
        c > 0 && cont(c),
        r & 1 << (b >> 14)
            ? ( ctime = a.time,
                cont(2 + ((b & 1) << 1)),
                ctime = a.time + 4)
            : ( b & 1 || cont1(1),
                ctime = nocont)
    }
    function cont(b) {
        var c, d,
            e = ctime;
        if (!(e + b <= 0)) {
            c = screndt - e;
            if (c < 0)
                return;
            c %= cyclesline;
            if (c > 126) {
                b -= c - 126;
                if (b <= 0)
                    return;
                e = 6,
                d = 15
            }
            else {
                d = c >> 3,
                c &= 7;
                if (c == 7) {
                    c--;
                    if (!--b)
                        return
                }
                e = c
            }
            b = b - 1 >> 1,
            d < b && (b = d),
            a.time += e + 6 * b
        }
    }
    function cont1(b) {
        b += a.time;
        b < 0 || b >= screndt || (b %= cyclesline,
                                  b < 126 && (b = 6 - (b & 7)) > 0 && (a.time += b))
    }
    function w(b) {
        u = b,
        ramu = ram[b & 7],
        r = 226 | b << 3 & 8,
        s = ram[5 | b >> 2 & 2],
        k = b & 16 ? q || p : a.rom128[0]
    }
    function frame(b) {
        W || createimage(),
        L = 0,
        K = 0,
        N = borderlines * $,
        M = borderlines * (borderchar + 32 + borderchar) + borderchar,
        Q = -borderchar,
        R = -borderlines,
        P = -cyclesline * borderlines - 4 * borderchar + 4,
        h = -cyclesline * borderlines - 4 * borderchar + 4,
//console.log(b),
        b ? ( a.int = 255,
              a.time_limit = f + 32,
              a.cpu.execute(),
              a.int = -1,
              a.time_limit = f + e,
              a.cpu.execute())
          : a.time += e,
            refresh_screen(a.time),
            refresh_border(a.time),
            a.time -= e,
            I && paint_screen(I)
    }
    function d(a, b, c, d, e) {
        do a[b++] = c[d++] | 0;
        while (--e)
    }
    function c(c) {
        p = a.rom48k,
        e = 69888,
        f = -14335,
        cyclesline = 224;
        if (b = !! c)
            p = a.rom128[1],
            e = 70908,
            f = -14361,
            cyclesline = 228;
        screndt = 191 * cyclesline + 126
    }
    var a = this;
    a.cpu = new Z80(a),
    a.keyboard = [255, 255, 255, 255, 255, 255, 255, 255];
    var b = !1;
    a.init = function () {
        ram = [];
        for (var b = 0; b < 8; b++)
            ram[b] = bytes(16384);
        c(!1),
        k = rom = p,
        ram5 = ram[5],
        ram2 = ram[2],
        ramu = ram[0],
        r = 226,
        s = ram5,
        a.time = f,
        J = bx(width * height / 8, 0),
//  console.log(V);
        V && update_screen()
    },
    a.reset = function () {
        var c = a.time;
        a.cpu.reset(),
        border = 0,
        w(b ? 0 : 48)
    },
    a.canvas = function (a, b) {
        W = null,
        V = a.getContext("2d"),
        X = b || 1,
//  console.log(1);
        J && update_screen()
    },
    a.getState = function (c) {
        var e = a.cpu.getState(),
            f = ram;
        e.pFE = pFE,
        e.border = border,
        c && (f = bytes(49152),
              d(f, 0, ram5, 0, 16384),
              d(f, 16384, ram2, 0, 16384),
              d(f, 32768, ramu, 0, 16384)),
        e.ram = f,
        q && (e.rom = q),
        e.p7FFD = u,
        e.model = +b;
        return e
    },
    a.setState = function (b) {
        var e = b.pFE,
            f, g, h;
        e != null && (pFE = e),
        e = b.border,
        e != null && (pFE = pFE & 248 | e),
        border = pFE & 7;
        if (e = b.ram) {
            h = e.length;
            if (h > 8)
                d(ram5, 0, e, 0, 16384),
                d(ram2, 0, e, 16384, 16384),
                d(ramu, 0, e, 32768, 16384);
            else
                while (h)
                    (g = e[--h]) && d(ram[h], 0, g, 0, 16384)
        }
        "rom" in b && (q = b.rom),
        e = b.model,
        f = b.p7FFD,
        f != +f && (f = u),
        e != null && (c(e),
                      e || (g = ramu,
                            ram5 != g && ram2 != g && ( ramu = ram[0],
                                                        ram[0] = g),
                            f = 48)),
        w(f),
        V && frame(0),
        a.cpu.setState(b)
    };
    var e, f, cyclesline, h, screndt;
    a.frame = function (b) {
/////////////
  if( !(++flash & 15) )
    titul(),
    time= nt;
/////////////
        if (!ram && b)
            throw "not initialized";
        --G || (G = 16,
                H ^= 255);
        var c = a.time;
        if (bg) {
            var i = bk,
                k = new Float32Array(frec / 50 + 16 | 0);
            i && (br(e + c),
                  bg.play(i.subarray(0, bl)),
                  k[0] = i[bl],
                  k[1] = i[bl + 1]),
            bk = k,
            bh = 50 * e,
            bm = c,
            bl = 0
        }
        frame(b)
    };
    var k, ram5, ram2, ramu, ram, p, q, r, s;
    a.time = a.time_limit = 0,
    a.m1 = function (b, c) {
        var d, e;
        b < 32768
            ? b < 16384
                ? ( d = k,
                    e = 1)
                : ( d = ram5,
                    e = 2)
            : b < 49152
                ? ( d = ram2,
                    e = 4)
                : ( d = ramu,
                    e = 8);
        var f = a.time - ctime;
        f > 0 && cont(f),
        ctime = nocont,
        r & e && cont1(0),
        r & 1 << (c >> 14) && (ctime = a.time + 4);
        return d[b & 16383]
    },
    a.get = function (b) {
        var c, d;
        b < 32768
            ? b < 16384
                ? ( c = k,
                    d = 1)
                : ( c = ram5,
                    d = 2)
            : b < 49152
                ? ( c = ram2,
                    d = 4)
                : ( c = ramu,
                    d = 8);
        var e = a.time - ctime;
        e > 0 && cont(e),
        ctime = nocont,
        r & d && (cont1(0),
                  ctime = a.time + 3);
        return c[b & 16383]
    },
    a.put = function (b, c) {
        var d,
            e = r;
        b < 32768
            ? b < 16384
                ? ( d = k,
                    e &= 17)
                : ( d = ram5,
                    e &= 34)
            : b < 49152
                ? ( d = ram2,
                    e &= 68)
                : ( d = ramu,
                    e &= 136);
        var f = a.time - ctime;
        f > 0 && cont(f),
        ctime = nocont;
        if ( !! e) {
            e & 15 && ( cont1(0),
                        ctime = a.time + 3),
            b &= 16383;
            if (d[b] === c)
                return;
//console.log(b < 6912 && d === s);
            b < 6912 && d === s && refresh_screen(a.time),
            d[b] = c
        }
    },
    a.get16 = function (b) {
        var c = b & 16383;
        if (c == 16383) {
            var d = a.get(b);
            a.time += 3,
            d |= a.get(b + 1 & 65535) << 8,
            a.time -= 3;
            return d
        }
        var e, f;
        b < 32768
            ? b < 16384
                ? ( e = k,
                    f = 1)
                : ( e = ram5,
                    f = 2)
            : b < 49152
                ? ( e = ram2,
                    f = 4)
                : ( e = ramu,
                    f = 8);
        var g = a.time - ctime;
        g > 0 && cont(g),
        ctime = nocont,
        r & f && (cont1(0),
                  cont1(3),
                  ctime = a.time + 6);
        return e[c] | e[c + 1] << 8
    };
    var pFE,
        u = 48;
    a.inp = function (b) {
        cont_port(b);
        var c = 65535,
            d = a.time,
            h, i, j;
        if (c < 256)
            return c;
        h = 255;
        if (!(b & 1)) {
            h = pFE << 2 | 191;
            if (i = b >> 8 ^ 255)
                for (j = 0;; j++) {
                    i & 1 && (h &= a.keyboard[j]);
                    if (!(i >>= 1))
                        break
                }
        }
        else if (bs && (b & 32770) == 32768)
            h = bs.reg[bs.idx];
        else if (d >= 0) {
            var l,
                m = d / cyclesline;
            d %= cyclesline,
            m < 192 && d < 124 && !(d & 4) && ( l = d >> 1 & 1 | d >> 2,
                                                d & 1
                                                    ? l += 6144 | m << 2 & 992
                                                    : l += m & 6144 | m << 2 & 224 | m << 8 & 1792,
                                                      h = s[l])
        }
        return c & (h | c >> 8 ^ 255)
    },
    a.out = function (b, c) {
        cont_port(b);
        var d = a.time;
        if (!(b & 1)) {
            var i = c & 7;
            i != border && (refresh_border(d),
                            border = i),
            (pFE ^ c) & 24 && bk && br(d),
            pFE = c
        }
        if (!(b & 2))
            if (b < 32768) {
                if (u & 32)
                    return;
                (u ^ c) & 8 && refresh_screen(d),
                w(c)
            }
            else
                bs && ( b & 16384
                            ? ay_idx = c & 15
                            : ay_write(ay_idx, c))
    },
    a.halt = function (a, b) {
        return a
    };
    const nocont = 99999;
    var ctime;
    const borderchar = 4,
          borderlines = 28,
          width = 8 * (borderchar + 32 + borderchar),
          height = borderlines + 192 + borderlines;
    a.dim = [width, height];
    var G = 16,
        H = 0,
        I = 0,
        J,
        K = 0,
        L = 0,
        M = 0,
        N = 0,
        P = 0,
        Q = 0,
        R = 0,
        border = 0,
        T = -1,
        V, W, X, Y, Z, $,
        pal = [
            [ 0, 1381833, 13246753, 13313739, 2935596, 3132620, 13487413, 13487565,
              0, 1776635, 16525609, 16527356, 3669303, 3931902, 16777025, 16777215],
            [ 65793, 1513424, 13706019, 13773010, 3068718, 3331027, 13947959, 13948116,
              65793, 1842431, 16722731, 16724479, 3800889, 4128767, 16777028, 16777215,
              0, 1316034, 12787487, 12788675, 2737193, 2999749, 12961074, 13027014,
              0, 1645044, 16197158, 16264440, 3471924, 3734523, 16645438, 16711422]],
        bg, bh, frec,
        bj = 0,
        bk, bl, bm,
        bn = 0,
        mic0, mic1;
//console.log(pal[1]);
    a.audio = function (a) {
        bg = a,
        frec = a.hz
    },
    (a.volume = function (a) {
        a *= a,
        mic1 = a,
        mic0 = .94 * a
    })(.5);
    var bs;
    a.command = function (b) {
        function f(a, b, c, e) {
            while (e-- > 0)
                d(a++, b[c++])
        }
        function e(a, b) {
            d(a, b & 255),
            d(a + 1, b >> 8)
        }
        function d(a, b) {
            [, ram5, ram2, ramu][a >> 14][a & 16383] = b
        }
        var c = a.rom48k;
        w(u | 16);
        var g = { i: 63,
                  border: 7,
                  rom: null},
            h = 16384;
        do d(h++, 0);
        while (h < 22528);
        do d(h++, 56);
        while (h < 23296);
        do d(h++, 0);
        while (h < 65536);
        e(23732, --h),
        h -= 167,
        f(h, c, 15880, 168),
        e(23675, h--),
        d(23608, 64),
        e(23730, h),
        e(23606, 15360),
        d(h--, 62),
        g.sp = h,
        e(23613, h - 2),
        g.iy = 23610,
        g.im = 1,
        g.iff = 3,
        e(23631, 23734),
        f(23734, c, 5551, 21),
        h = 23754,
        e(23639, h++),
        e(23635, h),
        e(23627, h),
        d(h++, 128),
        e(23641, h);
        for (var i = 0; i < b.length; i++)
            d(h++, b.charCodeAt(i));
        e(h, 32781),
        h += 2,
        e(23649, h),
        e(23651, h),
        e(23653, h),
        d(23693, 56),
        d(23695, 56),
        d(23624, 56),
        e(23561, 1315),
        d(23552, 255),
        d(23556, 255),
        f(23568, c, 5574, 14),
        e(23688, 6177),
        d(23659, 2),
        e(23656, 23698),
        d(23611, 12),
        g.pc = 4788,
        a.setState(g)
    }
}