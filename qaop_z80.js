function Z80(t) {
    function bit(a, b) {
        Ff = Ff & -256 | b & 40 | (b &= 1 << a),
        Fa = ~ (Fr = b),
        Fb = 0
    }
    function shifter(a, b) {
        switch (a) {
            case 0:
                b = b * 257 >> 7;
                break;
            case 1:
                b = b >> 1 | ((b & 1) + 1 ^ 1) << 7;
                break;
            case 2:
                b = b << 1 | Ff >> 8 & 1;
                break;
            case 3:
                b = (b * 513 | Ff & 256) >> 1;
                break;
            case 4:
                b <<= 1;
                break;
            case 5:
                b = (b * 513 + 128 ^ 128) >> 1;
                break;
            case 6:
                b = b << 1 | 1;
                break;
            case 7:
                b = b * 513 >> 1
        }
        Fa = 256 | (Fr = b = 255 & (Ff = b)),
        Fb = 0;
        return b
    }
    function im2() {
        im = 2
    }
    function im1() {
        im = 1
    }
    function im0() {
        im = 0
    }
    function reti() {
        iff |= iff >> 1,
        ret()
    }
    function neg() {
        a = Fr = (Ff = (Fb = ~a) + 1) & 255,
        Fa = 0
    }
    function ini_outi(d) {
        var h = d >> 2,
            k, l, n;
        l = hl + h & 65535,
        k = b << 8 | c,
        t.time++,
        d & 1
            ? ( n = t.get(hl),
                t.time += 3,
                k = k - 256 & 65535,
                mp = k + h,
                t.out(k, n),
                t.time += 4,
                h = l)
            : ( n = t.inp(k),
                t.time += 4,
                mp = k + h,
                k = k - 256 & 65535,
                t.put(hl, n),
                t.time += 3,
                h += k),
        h = (h & 255) + n,
        hl = l,
        b = k >>= 8,
        d & 2 && k && ( t.time += 5,
                        pc = pc - 2 & 65535);
        var o = h & 7 ^ k;
        Ff = k | (h &= 256),
        Fa = (Fr = k) ^ 128,
        o = 4928640 >> ((o ^ o >> 4) & 15),
        Fb = (o ^ k) & 128 | h >> 4 | (n & 128) << 2
    }
    function cpi(h, k) {
        var l, n, o;
        o = a - (n = t.get(l = hl)) & 255,
        mp += h,
        hl = l + h & 65535,
        t.time += 8,
        Fr = o & 127 | o >> 7,
        Fb = ~ (n | 128),
        Fa = a & 127,
        --c < 0 && (b = b - 1 & (c = 255)),
        b | c && (Fa |= 128,
                  Fb |= 128,
                  k && o && ( mp = (pc = pc - 2 & 65535) + 1,
                              t.time += 5)),
        Ff = Ff & -256 | o & -41,
        (o ^ n ^ a) & 16 && o--,
        Ff |= o << 4 & 32 | o & 8
    }
    function ldi(h, n) {
        var o, p;
        p = t.get(o = hl),
        hl = o + h & 65535,
        t.time += 3,
        t.put(o = d << 8 | e, p),
        de(o + h & 65535),
        t.time += 5,
        Fr && (Fr = 1),
        p += a,
        Ff = Ff & -41 | p & 8 | p << 4 & 32,
        p = 0,
        --c < 0 && (b = b - 1 & (c = 255)),
        b | c && (n && (t.time += 5,
                        mp = (pc = pc - 2 & 65535) + 1),
                        p = 128),
        Fa = Fb = p
    }
    function out(a) {
        var d = b << 8 | c;
        mp = d + 1,
        t.out(d, a),
        t.time += 4
    }
    function in_() {
        var a = b << 8 | c,
            d = t.inp(a);
        mp = a + 1,
        f_szh0n0p(d),
        t.time += 4;
        return d
    }
    function ldax(b) {
        Ff = Ff & -256 | (a = b),
        Fr = + !! b,
        Fa = Fb = iff << 6 & 128,
        t.time++
    }
    function rld() {
        var b = t.get(hl) << 4 | a & 15;
        t.time += 7,
        f_szh0n0p(a = a & 240 | b >> 8),
        t.put(hl, b & 255),
        mp = hl + 1,
        t.time += 3
    }
    function rrd() {
        var b = t.get(hl) | a << 8;
        t.time += 7,
        f_szh0n0p(a = a & 240 | b & 15),
        t.put(hl, b >> 4 & 255),
        mp = hl + 1,
        t.time += 3
    }
    function adc_sbc_hl(b, d) {
        var h = hl + b + (Ff >> 8 & 1 ^ d);
        mp = hl + 1,
        Ff = h >> 8,
        Fa = hl >> 8,
        Fb = b >> 8,
        hl = h = h & 65535,
        Fr = h >> 8 | h << 8,
        t.time += 7
    }
    function getd3(b) {
        var d = t.get(pc);
        pc = pc + 1 & 65535,
        t.time += 8,
        d = t.get(mp = b + (d ^ 128) - 128 & 65535),
        t.time += 3;
        return d
    }
    function getd(b) {
        var d = t.get(pc);
        pc = pc + 1 & 65535,
        t.time += 8;
        return mp = b + (d ^ 128) - 128 & 65535
    }
    function interrupt() {
        var a = t.int,
            d;
        iff = 0,
        halted = 0,
        t.time += 6,
        im  ? ( push(pc),
                d = 56,
                im > 1 && (d = t.get16(ir & 65280 | a),
                          t.time += 6),
                mp = pc = d)
            : op[a]()
    }
    function xdcb(e) {
        var f, g, h, n;
        f = mp = e + (t.get(pc) ^ 128) - 128 & 65535,
        t.time += 3,
        g = t.get(pc + 1 & 65535),
        pc = pc + 2 & 65535,
        t.time += 5,
        h = t.get(f),
        t.time += 4,
        n = g >> 3 & 7;
        switch (g & 192) {
            case 0:
                h = shifter(n, h);
                break;
            case 64:
                bit(n, h),
                Ff = Ff & -41 | f >> 8 & 40;
                return;
            case 128:
                h &= ~ (1 << n);
                break;
            case 192:
                h |= 1 << n
        }
        t.put(f, h),
        t.time += 3;
        switch (g & 7) {
            case 0:
                b = h;
                break;
            case 1:
                c = h;
                break;
            case 2:
                d = h;
                break;
            case 3:
                e = h;
                break;
            case 4:
                hl = hl & 255 | h << 8;
                break;
            case 5:
                hl = hl & 65280 | h;
                break;
            case 7:
                a = h
        }
    }
    function cb() {
        var a, d;
        a = t.m1(pc, ir | (r = r + 1 & 127)),
        pc = pc + 1 & 65535,
        t.time += 4,
        d = a >> 3 & 7;
        switch (a & 192) {
            case 0:
                shift[a & 7](d);
                break;
            case 64:
                bita[a & 7](d);
                break;
            case 128:
                res[a & 7](1 << d);
                break;
            case 192:
                set[a & 7](1 << d)
        }
    }
    function ed() {
        var a = ed[t.m1(pc, ir | (r = r + 1 & 127))];
        pc = pc + 1 & 65535,
        t.time += 4,
        a && a()
    }
    function dd_fd(a) {
        var d, e, f;
        g: for (;;) {
            switch (a) {
                case 221:
                case 253:
                    break;
                case 243:
                    iff = 0;
                    break;
                case 251:
                    iff = 3;
                    break;
                default:
                    op[a]();
                    break g
            }
            e = a,
            a = t.m1(pc, ir | (r = r + 1 & 127)),
            pc = pc + 1 & 65535,
            t.time += 4;
            if (e & 4 && (d = pref[a])) {
                f = d(e == 221 ? ix : iy),
                f != null && (e == 221 ? ix = f : iy = f);
                break
            }
        }
        iff & 1 && t.int >= 0 && t.time < t.time_limit && interrupt()
    }
    function halt() {
        halted = 1;
        var b = t.time_limit - t.time + 3 >> 2;
        b > 0 && (b = t.halt(b, ir | r),
                  r = r + b & 127,
                  t.time += 4 * b)
    }
    function ret() {
        mp = pc = t.get16(sp),
        sp = sp + 2 & 65535,
        t.time += 6
    }
    function callc(a) {
        mp = imm16();
        a && (push(pc),
              pc = mp)
    }
    function jr() {
        mp = pc = pc + (t.get(pc) ^ 128) - 127 & 65535,
        t.time += 8
    }
    function jp(a) {
        mp = imm16();
        a && (pc = mp)
    }
    function daa() {
        var d = (Fr ^ Fa ^ Fb ^ Fb >> 8) & 16,
            b = 0;
        (a | Ff & 256) > 153 && (b = 352),
        (a & 15 | d) > 9 && (b += 6),
        Fa = a | 256,
        Fb & 512
            ? (a -= b,
              Fb = ~b)
            : a += Fb = b,
              Ff = (Fr = a &= 255) | b & 256
    }
    function cpl() {
        Ff = Ff & -41 | (a ^= 255) & 40,
        Fb |= -129,
        Fa = Fa & -17 | ~Fr & 16
    }
    function imm16() {
        var a = t.get16(pc);
        pc = pc + 2 & 65535,
        t.time += 6;
        return a
    }
    function imm8() {
        var a = t.get(pc);
        pc = pc + 1 & 65535,
        t.time += 3;
        return a
    }
    function add16(b, a) {
        var h = b + a;
        Ff = Ff & 128 | h >> 8 & 296,
//        Fa &= -17,
        Fb = Fb & 128 | ((h ^ b ^ a) >> 8 ^ Fr ^ Fa) & 16,
        mp = b + 1,
        t.time += 7;
        return h & 65535
    }
    function rot(b) {
        Ff = Ff & 215 | b & 296,
        Fb = Fb & 128 | ( Fa ^ Fr ) & 16,
//        Fa = Fa & -17 | Fr & 16,
        a = b & 255
    }
    function f_szh0n0p(a) {
        Ff = Ff & -256 | (Fr = a),
        Fa = a | 256,
        Fb = 0
    }
    function dec(a) {
        return  Ff = Ff & 256 | (Fr = a = (Fa = a) + (Fb = -1) & 255),
                a
    }
    function inc(a) {
        return  Ff = Ff & 256 | (Fr = a = (Fa = a) + (Fb = 1) & 255),
                a
    }
    function cp(d) {
        Fr = (Fa = a) - d;
        Fb = ~d,
        Ff = Fr & -41 | d & 40,
        Fr &= 255
    }
    function pop() {
        var b = t.get16(sp);
        sp = sp + 2 & 65535,
        t.time += 6;
        return b
    }
    function push(b) {
        t.time++,
        t.put(sp - 1 & 65535, b >> 8),
        t.time += 3,
        t.put(sp = sp - 2 & 65535, b & 255),
        t.time += 3
    }
    function nop() {}
    function ex_af() {
        var tmp = a_; a_ = a, a = tmp,
        tmp = Ff_, Ff_ = Ff, Ff = tmp,
        tmp = Fr_, Fr_ = Fr, Fr = tmp,
        tmp = Fa_, Fa_ = Fa, Fa = tmp,
        tmp  = Fb_, Fb_ = Fb, Fb = tmp
    }
    function exx() {
        var a = b_; b_ = b, b = a,
        a = c_, c_ = c, c = a,
        a = d_, d_ = d, d = a,
        a = e_, e_ = e, e = a,
        a = hl_, hl_ = hl, hl = a
    }
    function de(a) {
        d = a >> 8,
        e = a & 255
    }
    function bc(a) {
        b = a >> 8,
        c = a & 255
    }
    function ldrx(a) {
        ir = ir & 65280 | a,
        r = a & 127
    }
    function r7() {
        return ir & 128 | r
    }
    function af(b) {
        flags(b & 255),
        a = b >> 8
    }
    function flags(a) {
        Fr = ~a & 64,
        Ff = a |= a << 8,
        Fa = 255 & (Fb = a & -129 | (a & 4) << 5)
    }
    function F() {
        var a = Ff & 168 | Ff >> 8 & 1,
            b = Fa,
            d = Fb,
            h = d >> 8;
        Fr || (a |= 64);
        var c = Fr ^ b;
        a |= h & 2,
        a |= (c ^ d ^ h) & 16,
        Fa & 256
            ? b = 154020 >> ((Fr ^ Fr >> 4) & 15)
            : b = (c & (d ^ Fr)) >> 5;
        return a | b & 4
    }
    var a, b, c, d, e, hl, Ff, Fr, Fa, Fb, ix, sp, ir, im, mp, 
        a_,b_,c_,d_,e_,hl_,Ff_,Fr_,Fa_,Fb_,iy, pc, r, iff, halted;
    pc = ir = r = im = iff = 0,
    sp = ix = iy = hl = hl_ = 65535,
    a = b = c = d = e = a_ = b_ = c_ = d_ = e_ = 255,
    Ff = Fr = Fa = Fb = Ff_ = Fr_Fa_ = Fb_ == 0,
    halted = 0,
    this.getState = function () {
        var t = {
            pc: pc,
            a: a,
            f: F(),
            sp: sp,
            bc: b << 8 | c,
            de: d << 8 | e,
            hl: hl,
            ix: ix,
            iy: iy,
            bc_: b_ << 8 | c_,
            de_: d_ << 8 | e_,
            hl_: hl_,
            a_: a_,
            r: r7(),
            i: ir >> 8,
            im: im,
            iff: iff,
            halted: halted
        };
        ex_af(),
        t.f_ = F(),
        ex_af();
        return t
    },
    this.setState = function (t) {
        "pc" in t && (pc = t.pc),
        "a" in t && (a = t.a),
        "f" in t && flags(t.f),
        "sp" in t && (sp = t.sp),
        "bc" in t && bc(t.bc),
        "de" in t && de(t.de),
        "hl" in t && (hl = t.hl),
        "ix" in t && (ix = t.ix),
        "iy" in t && (iy = t.iy),
        exx(),
        ex_af(),
        "bc_" in t && bc(t.bc_),
        "de_" in t && de(t.de_),
        "hl_" in t && (hl = t.hl_),
        "a_" in t && (a = t.a_),
        "f_" in t && flags(t.f_),
        exx(),
        ex_af(),
        "r" in t && ldrx(t.r),
        "i" in t && (ir = ir & 255 | t.i << 8),
        "im" in t && (im = t.im & 3),
        "iff" in t && (iff = t.iff),
        "halted" in t && (halted = !! t.halted)
    },
    this.execute = function () {
        if (!(t.time >= t.time_limit)) {
            iff & 1 && t.int >= 0 && interrupt();
            if (halted)
                return halt();
            do {
                var b = t.m1(pc, ir | (r = r + 1 & 127));
                pc = pc + 1 & 65535,
                t.time += 4,
                op[b]()
            } while (t.time < t.time_limit)
        }
    },
    this.nmi = function () {
        iff &= 2,
        halted = 0,
        push(pc),
        t.time += 4,
        pc = 102
    },
    this.reset = function () {
        halted = 0,
        pc = ir = r = im = iff = 0
    };
    var op = [
        nop,          // 00 // NOP
        function () { // 01 // LD BC, nn
            var a = imm16();
            b = a >> 8,
            c = a & 255
        },
        function () { // 02 // LD (BC), A
            var d = b << 8 | c;
            mp = d + 1 & 255 | a << 8,
            t.put(d, a),
            t.time += 3
        },
        function () { // 03 // INC BC
            ++c === 256 && (b = b + 1 & 255,
                            c = 0),
            t.time += 2
        },
        function () { // 04 // INC B
            b = inc(b)
        },
        function () { // 05 // DEC B
            b = dec(b)
        },
        function () { // 06 // LD B, n
            b = imm8()
        },
        function () { // 07 // RLCA
            rot(a * 257 >> 7)
        },
        ex_af,        // 08 // EX AF, AF'
        function () { // 09 // ADD HL, BC
            hl = add16(hl, b << 8 | c)
        },
        function () { // 0A // LD A, (BC)
            var d = b << 8 | c;
            mp = d + 1,
            a = t.get(d),
            t.time += 3
        },
        function () { // 0B // DEC BC
            --c < 0 && (b = b - 1 & (c = 255)),
            t.time += 2
        },
        function () { // 0C // INC C
            c = inc(c)
        },
        function () { // 0D // DEC C
            c = dec(c)
        },
        function () { // 0E // LD C, n
            c = imm8()
        },
        function () { // 0F // RRCA
            rot(a >> 1 | ((a & 1) + 1 ^ 1) << 7)
        },
        function () { // 10 // DJNZ
            var a, d;
            t.time++,
            d = t.get(a = pc),
            a++,
            t.time += 3;
            if (b = b - 1 & 255)
                t.time += 5,
                mp = a += (d ^ 128) - 128;
            pc = a & 65535
        },
        function () { // 11 // LD DE, nn
            var a = imm16();
            d = a >> 8,
            e = a & 255
        },
        function () { // 12 // LD DE, (A)
            var b = d << 8 | e;
            mp = b + 1 & 255 | a << 8,
            t.put(b, a),
            t.time += 3
        },
        function () { // 13 // INC DE
            ++e === 256 && (d = d + 1 & 255,
                            e = 0),
            t.time += 2
        },
        function () { // 14 // INC D
            d = inc(d)
        },
        function () { // 15 // DEC D
            d = dec(d)
        },
        function () { // 16 // LD D, n
            d = imm8()
        },
        function () { // 17 // RLA
            rot(a << 1 | Ff >> 8 & 1)
        },
        jr,           // 18 // JR
        function () { // 19 // ADD HL, DE
            hl = add16(hl, d << 8 | e)
        },
        function () { // 1A // LD A, (DE)
            var b = d << 8 | e;
            mp = b + 1,
            a = t.get(b),
            t.time += 3
        },
        function () { // 1B // INC DE
            --e < 0 && (d = d - 1 & (e = 255)),
            t.time += 2
        },
        function () { // 1C // INC E
            e = inc(e)
        },
        function () { // 1D // DEC E
            e = dec(e)
        },
        function () { // 1E // LD E, n
            e = imm8()
        },
        function () { // 1F // RRA
            rot((a * 513 | Ff & 256) >> 1)
        },
        function () { // 20 // JR NZ
            Fr ? jr() : imm8()
        },
        function () { // 21 // LD HL, nn
            hl = imm16()
        },
        function () { // 22 // LD (nn), HL
            mp = imm16();
            t.put(mp, hl & 255),
            t.time += 3,
            t.put(mp = mp + 1 & 65535, hl >> 8),
            t.time += 3
        },
        function () { // 23 // INC HL
            hl = hl + 1 & 65535,
            t.time += 2
        },
        function () { // 24 // INC H
            hl = hl & 255 | inc(hl >> 8) << 8
        },
        function () { // 25 // DEC H
            hl = hl & 255 | dec(hl >> 8) << 8
        },
        function () { // 26 // LD H, n
            hl = hl & 255 | imm8() << 8
        },
        daa,          // 27 // DAA
        function () { // 28 // JR Z
            Fr ? imm8() : jr()
        },
        function () { // 29 // ADD HL, HL
            hl = add16(hl, hl)
        },
        function () { // 2A // LD HL, (nn)
            var b = imm16();
            mp = b + 1,
            hl = t.get16(b),
            t.time += 6
        },
        function () { // 2B // DEC HL
            hl = hl - 1 & 65535,
            t.time += 2
        },
        function () { // 2C // INC L
            hl = hl & -256 | inc(hl & 255)
        },
        function () { // 2D // DEC L
            hl = hl & -256 | dec(hl & 255)
        },
        function () { // 2E // LD L, n
            hl = hl & -256 | imm8()
        },
        cpl,          // 2F // CPL
        function () { // 30 // JR NC
            Ff & 256 ? imm8() : jr()
        },
        function () { // 31 // LD SP, nn
            sp = imm16()
        },
        function () { // 32 // LD (nn), A
            var b = imm16();
            mp = b + 1 & 255 | a << 8,
            t.put(b, a),
            t.time += 3
        },
        function () { // 33 // INC SP
            sp = sp + 1 & 65535,
            t.time += 2
        },
        function () { // 34 // INC (HL)
            var b = inc(t.get(hl));
            t.time += 4,
            t.put(hl, b),
            t.time += 3
        },
        function () { // 35 // DEC (HL)
            var b = dec(t.get(hl));
            t.time += 4,
            t.put(hl, b),
            t.time += 3
        },
        function () { // 36 // LD (HL), n
            t.put(hl, imm8()),
            t.time += 3
        },
        function () { // 37 // SCF
//            Fa &= -17,
            Fb = Fb & 128 | (Fa ^ Fr) & 16,
            Ff = 256 | Ff & 128 | a & 40
        },
        function () { // 38 // JR C
            Ff & 256 ? jr() : imm8()
        },
        function () { // 39 // ADD HL, SP
            hl = add16(hl, sp)
        },
        function () { // 3A // LD A, (nn)
            var b = imm16();
            mp = b + 1,
            a = t.get(b),
            t.time += 3
        },
        function () { // 3B // DEC SP
            sp = sp - 1 & 65535,
            t.time += 2
        },
        function () { // 3C // INC A
            a = inc(a)
        },
        function () { // 3D // DEC A
            a = dec(a)
        },
        function () { // 3E // LD A, n
            a = imm8()
        },
        function () { // 3F // CCF
            Fb = Fb & 128 | (Ff >> 4 ^ Fr ^ Fa) & 16,
            Ff = ~Ff & 256 | Ff & 128 | a & 40
        },
        nop,          // 40 // LD B, B
        function () { // 41 // LD B, C
            b = c
        },
        function () { // 42 // LD B, D
            b = d
        },
        function () { // 43 // LD B, E
            b = e
        },
        function () { // 44 // LD B, H
            b = hl >> 8
        },
        function () { // 45 // LD B, L
            b = hl & 255
        },
        function () { // 46 // LD B, (HL)
            b = t.get(hl),
            t.time += 3
        },
        function () { // 47 // LD B, A
            b = a
        },
        function () { // 48 // LD C, B
            c = b
        },
        nop,          // 49 // LD C, C
        function () { // 4A // LD C, D
            c = d
        },
        function () { // 4B // LD C, E
            c = e
        },
        function () { // 4C // LD C, H
            c = hl >> 8
        },
        function () { // 4D // LD C, L
            c = hl & 255
        },
        function () { // 4E // LD C, (HL)
            c = t.get(hl),
            t.time += 3
        },
        function () { // 4F // LD C, A
            c = a
        },
        function () { // 50 // LD D, B
            d = b
        },
        function () { // 51 // LD D, C
            d = c
        },
        nop,          // 52 // LD D, D
        function () { // 53 // LD D, E
            d = e
        },
        function () { // 54 // LD D, H
            d = hl >> 8
        },
        function () { // 55 // LD D, L
            d = hl & 255
        },
        function () { // 56 // LD D, (HL)
            d = t.get(hl),
            t.time += 3
        },
        function () { // 57 // LD D, A
            d = a
        },
        function () { // 58 // LD E, B
            e = b
        },
        function () { // 59 // LD E, C
            e = c
        },
        function () { // 5A // LD E, D
            e = d
        },
        nop,          // 5B // LD E, E
        function () { // 5C // LD E, H
            e = hl >> 8
        },
        function () { // 5D // LD E, L
            e = hl & 255
        },
        function () { // 5E // LD E, (HL)
            e = t.get(hl),
            t.time += 3
        },
        function () { // 5F // LD E, A
            e = a
        },
        function () { // 60 // LD H, B
            hl = hl & 255 | b << 8
        },
        function () { // 61 // LD H, C
            hl = hl & 255 | c << 8
        },
        function () { // 62 // LD H, D
            hl = hl & 255 | d << 8
        },
        function () { // 63 // LD H, E
            hl = hl & 255 | e << 8
        },
        nop,          // 64 // LD H, H
        function () { // 65 // LD H, L
            hl = hl & 255 | (hl & 255) << 8
        },
        function () { // 66 // LD H, (HL)
            hl = hl & 255 | t.get(hl) << 8,
            t.time += 3
        },
        function () { // 67 // LD H, A
            hl = hl & 255 | a << 8
        },
        function () { // 68 // LD L, B
            hl = hl & -256 | b
        },
        function () { // 69 // LD L, C
            hl = hl & -256 | c
        },
        function () { // 6A // LD L, D
            hl = hl & -256 | d
        },
        function () { // 6B // LD L, E
            hl = hl & -256 | e
        },
        function () { // 6C // LD L, H
            hl = hl & -256 | hl >> 8
        },
        nop,          // 6D // LD L, L
        function () { // 6E // LD L, (HL)
            hl = hl & -256 | t.get(hl),
            t.time += 3
        },
        function () { // 6F // LD L, A
            hl = hl & -256 | a
        },
        function () { // 70 // LD (HL), B
            t.put(hl, b),
            t.time += 3
        },
        function () { // 71 // LD (HL), C
            t.put(hl, c),
            t.time += 3
        },
        function () { // 72 // LD (HL), D
            t.put(hl, d),
            t.time += 3
        },
        function () { // 73 // LD (HL), E
            t.put(hl, e),
            t.time += 3
        },
        function () { // 74 // LD (HL), H
            t.put(hl, hl >> 8),
            t.time += 3
        },
        function () { // 75 // LD (HL), L
            t.put(hl, hl & 255),
            t.time += 3
        },
        halt,         // 76 // HALT
        function () { // 77 // LD (HL), A
            t.put(hl, a),
            t.time += 3
        },
        function () { // 78 // LD A, B
            a = b
        },
        function () { // 79 // LD A, C
            a = c
        },
        function () { // 7A // LD A, D
            a = d
        },
        function () { // 7B // LD A, E
            a = e
        },
        function () { // 7C // LD A, H
            a = hl >> 8
        },
        function () { // 7D // LD A, L
            a = hl & 255
        },
        function () { // 7E // LD A, (HL)
            a = t.get(hl),
            t.time += 3
        },
        nop,          // 7F // LD A, A
        function () { // 80 // ADD A, B
            a = Fr = (Ff = (Fa = a) + (Fb = b)) & 255
        },
        function () { // 81 // ADD A, C
            a = Fr = (Ff = (Fa = a) + (Fb = c)) & 255
        },
        function () { // 82 // ADD A, D
            a = Fr = (Ff = (Fa = a) + (Fb = d)) & 255
        },
        function () { // 83 // ADD A, E
            a = Fr = (Ff = (Fa = a) + (Fb = e)) & 255
        },
        function () { // 84 // ADD A, H
            a = Fr = (Ff = (Fa = a) + (Fb = hl >> 8)) & 255
        },
        function () { // 85 // ADD A, L
            a = Fr = (Ff = (Fa = a) + (Fb = hl & 255)) & 255
        },
        function () { // 86 // ADD A, (HL)
            a = Fr = (Ff = (Fa = a) + (Fb = t.get(hl))) & 255,
            t.time += 3
        },
        function () { // 87 // ADD A, A
            a = Fr = (Ff = 2 * (Fa = Fb = a)) & 255
        },
        function () { // 88 // ADC A, B
            a = Fr = (Ff = (Fa = a) + (Fb = b) + (Ff >> 8 & 1)) & 255
        },
        function () { // 89 // ADC A, C
            a = Fr = (Ff = (Fa = a) + (Fb = c) + (Ff >> 8 & 1)) & 255
        },
        function () { // 8A // ADC A, D
            a = Fr = (Ff = (Fa = a) + (Fb = d) + (Ff >> 8 & 1)) & 255
        },
        function () { // 8B // ADC A, E
            a = Fr = (Ff = (Fa = a) + (Fb = e) + (Ff >> 8 & 1)) & 255
        },
        function () { // 8C // ADC A, H
            a = Fr = (Ff = (Fa = a) + (Fb = hl >> 8) + (Ff >> 8 & 1)) & 255
        },
        function () { // 8D // ADC A, L
            a = Fr = (Ff = (Fa = a) + (Fb = hl & 255) + (Ff >> 8 & 1)) & 255
        },
        function () { // 8E // ADC A, (HL)
            a = Fr = (Ff = (Fa = a) + (Fb = t.get(hl)) + (Ff >> 8 & 1)) & 255,
            t.time += 3
        },
        function () { // 8F // ADC A, A
            a = Fr = (Ff = 2 * (Fa = Fb = a) + (Ff >> 8 & 1)) & 255
        },
        function () { // 90 // SUB A, B
            a = Fr = (Ff = (Fa = a) + (Fb = ~b) + 1) & 255
        },
        function () { // 91 // SUB A, C
            a = Fr = (Ff = (Fa = a) + (Fb = ~c) + 1) & 255
        },
        function () { // 92 // SUB A, D
            a = Fr = (Ff = (Fa = a) + (Fb = ~d) + 1) & 255
        },
        function () { // 93 // SUB A, E
            a = Fr = (Ff = (Fa = a) + (Fb = ~e) + 1) & 255
        },
        function () { // 94 // SUB A, H
            a = Fr = (Ff = (Fa = a) + (Fb = ~ (hl >> 8)) + 1) & 255
        },
        function () { // 95 // SUB A, L
            a = Fr = (Ff = (Fa = a) + (Fb = ~ (hl & 255)) + 1) & 255
        },
        function () { // 96 // SUB A, (HL)
            a = Fr = (Ff = (Fa = a) + (Fb = ~t.get(hl)) + 1) & 255,
            t.time += 3
        },
        function () { // 97 // SUB A, A
            Fb = ~ (Fa = a), a = Fr = Ff = 0
        },
        function () { // 98 // SBC A, B
            a = Fr = (Ff = (Fa = a) + (Fb = ~b) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 99 // SBC A, C
            a = Fr = (Ff = (Fa = a) + (Fb = ~c) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 9A // SBC A, D
            a = Fr = (Ff = (Fa = a) + (Fb = ~d) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 9B // SBC A, E
            a = Fr = (Ff = (Fa = a) + (Fb = ~e) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 9C // SBC A, H
            a = Fr = (Ff = (Fa = a) + (Fb = ~ (hl >> 8)) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 9D // SBC A, L
            a = Fr = (Ff = (Fa = a) + (Fb = ~ (hl & 255)) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 9E // SBC A, (HL)
            a = Fr = (Ff = (Fa = a) + (Fb = ~t.get(hl)) + (Ff >> 8 & 1 ^ 1)) & 255,
            t.time += 3
        },
        function () { // 9F // SBC A, A
            Fb = ~ (Fa = a), a = Fr = (Ff = Ff & 256 /-256) & 255;
        },
        function () { // A0 // AND B
            Fa = ~ (a = Ff = Fr = a & b),
            Fb = 0
        },
        function () { // A1 // AND C
            Fa = ~ (a = Ff = Fr = a & c),
            Fb = 0
        },
        function () { // A2 // AND D
            Fa = ~ (a = Ff = Fr = a & d),
            Fb = 0
        },
        function () { // A3 // AND E
            Fa = ~ (a = Ff = Fr = a & e),
            Fb = 0
        },
        function () { // A4 // AND H
            Fa = ~ (a = Ff = Fr = a & hl >> 8),
            Fb = 0
        },
        function () { // A5 // AND L
            Fa = ~ (a = Ff = Fr = a & hl & 255),
            Fb = 0
        },
        function () { // A6 // AND (HL)
            Fa = ~ (a = Ff = Fr = a & t.get(hl)),
            Fb = 0,
            t.time += 3
        },
        function () { // A7 // AND A
            Fa = ~ (Ff = Fr = a),
            Fb = 0
        },
        function () { // A8 // XOR B
            Fa = (a = Ff = Fr = a ^ b) | 256,
            Fb = 0
        },
        function () { // A9 // XOR C
            Fa = (a = Ff = Fr = a ^ c) | 256,
            Fb = 0
        },
        function () { // AA // XOR D
            Fa = (a = Ff = Fr = a ^ d) | 256,
            Fb = 0
        },
        function () { // AB // XOR E
            Fa = (a = Ff = Fr = a ^ e) | 256,
            Fb = 0
        },
        function () { // AC // XOR H
            Fa = (a = Ff = Fr = a ^ hl >> 8) | 256,
            Fb = 0
        },
        function () { // AD // XOR L
            Fa = (a = Ff = Fr = a ^ hl & 255) | 256,
            Fb = 0
        },
        function () { // AE // XOR (HL)
            Fa = (a = Ff = Fr = a ^ t.get(hl)) | 256,
            Fb = 0,
            t.time += 3
        },
        function () { // AF // XOR A
            a = Ff = Fr = Fb = 0,
            Fa = 256
        },
        function () { // B0 // OR B
            Fa = (a = Ff = Fr = a | b) | 256,
            Fb = 0
        },
        function () { // B1 // OR C
            Fa = (a = Ff = Fr = a | c) | 256,
            Fb = 0
        },
        function () { // B2 // OR D
            Fa = (a = Ff = Fr = a | d) | 256,
            Fb = 0
        },
        function () { // B3 // OR E
            Fa = (a = Ff = Fr = a | e) | 256,
            Fb = 0
        },
        function () { // B4 // OR H
            Fa = (a = Ff = Fr = a | hl >> 8) | 256,
            Fb = 0
        },
        function () { // B5 // OR L
            Fa = (a = Ff = Fr = a | hl & 255) | 256,
            Fb = 0
        },
        function () { // B6 // OR (HL)
            Fa = (a = Ff = Fr = a | t.get(hl)) | 256,
            Fb = 0,
            t.time += 3
        },
        function () { // B7 // OR A
            Fa = (Ff = Fr = a) | 256,
            Fb = 0
        },
        function () { // B8 // CP B
            cp(b)
        },
        function () { // B9 // CP C
            cp(c)
        },
        function () { // BA // CP D
            cp(d)
        },
        function () { // BB // CP E
            cp(e)
        },
        function () { // BC // CP H
            cp(hl >> 8)
        },
        function () { // BD // CP L
            cp(hl & 255)
        },
        function () { // BE // CP (HL)
            cp(t.get(hl)),
            t.time += 3
        },
        function () { // BF // CP A
            Fr = 0,
            Fb = ~(Fa = a),
            Ff = a & 40
        },
        function () { // C0 // RET NZ
            t.time++,
            Fr && ret()
        },
        function () { // C1 // POP BC
            var a = pop();
            b = a >> 8,
            c = a & 255
        },
        function () { // C2 // JP NZ
            jp(Fr)
        },
        function () { // C3 // JP nn
            mp = pc = imm16()
        },
        function () { // C4 // CALL NZ
            callc(Fr)
        },
        function () { // C5 // PUSH BC
            push(b << 8 | c)
        },
        function () { // C6 // ADD A, n
            a = Fr = (Ff = (Fa = a) + (Fb = imm8())) & 255
        },
        function () { // C7 // RST 00
            push(pc),
            mp = pc = 0
        },
        function () { // C8 // RET Z
            t.time++,
            Fr || ret()
        },
        ret,          // C9 // RET
        function () { // CA // JP Z
            jp(!Fr)
        },
        cb,           // CB // OP CB
        function () { // CC // CALL Z
            callc(!Fr)
        },
        function () { // CD // CALL nn
            var a = imm16();
            push(pc),
            mp = pc = a
        },
        function () { // CE // ADC A, n
            a = Fr = (Ff = (Fa = a) + (Fb = imm8()) + (Ff >> 8 & 1)) & 255
        },
        function () { // CF // RST 08
            push(pc),
            mp = pc = 8
        },
        function () { // D0 // RET NC
            t.time++,
            Ff & 256 || ret()
        },
        function () { // D1 // POP DE
            var a = pop();
            d = a >> 8,
            e = a & 255
        },
        function () { // D2 // JP NC
            jp(!(Ff & 256))
        },
        function () { // D3 // OUT (n), A
            var b = imm8() | a << 8;
            t.out(b, a),
            mp = b + 1 & 255 | b & 65280,
            t.time += 4
        },
        function () { // D4 // CALL NC
            callc(!(Ff & 256))
        },
        function () { // D5 // PUSH DE
            push(d << 8 | e)
        },
        function () { // D6 // ADC A, n
            a = Fr = (Ff = (Fa = a) + (Fb = ~imm8()) + 1) & 255
        },
        function () { // D7 // RST 10
            push(pc),
            mp = pc = 16
        },
        function () { // D8 // RET C
            t.time++,
            Ff & 256 && ret()
        },
        exx,          // D9 // EXX
        function () { // DA // JP C
            jp(Ff & 256)
        },
        function () { // DB // IN A, (n)
            var b = imm8() | a << 8;
            mp = b + 1,
            a = t.inp(b),
            t.time += 4
        },
        function () { // DC // CALL C
            callc(Ff & 256)
        },
        function () { // DD // OP DD
            dd_fd(221)
        },
        function () { // DE // SBC A, n
            a = Fr = (Ff = (Fa = a) + (Fb = ~imm8()) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // DF // RST 18
            push(pc),
            mp = pc = 24
        },
        function () { // E0 // RET PO
            t.time++,
            F() & 4 ^ 4 && ret()
        },
        function () { // E1 // POP HL
            hl = pop()
        },
        function () { // E2 // JP PO
            jp(F() & 4 ^ 4)
        },
        function () { // E3 // EX (SP), HL
            mp = pop(),
            push(hl),
            hl = mp,
            t.time += 2
        },
        function () { // E4 // CALL PO
            callc(F() & 4 ^ 4)
        },
        function () { // E5 // PUSH HL
            push(hl)
        },
        function () { // E6 // AND A, n
            Fa = ~ (a = Ff = Fr = a & imm8()),
            Fb = 0
        },
        function () { // E7 // RST 20
            push(pc),
            mp = pc = 32
        },
        function () { // E8 // RET PE
            t.time++,
            F() & 4 && ret()
        },
        function () { // E9 // JP (HL)
            pc = hl
        },
        function () { // EA // JP PE
            jp(F() & 4)
        },
        function () { // EB // EX DE, HL
            var a = hl;
            hl = d << 8 | e,
            d = a >> 8,
            e = a & 255
        },
        function () { // EC // CALL PE
            callc(F() & 4)
        },
        ed,           // ED // OP ED
        function () { // EE // XOR A, n
            Fa = (a = Ff = Fr = a ^ imm8()) | 256,
            Fb = 0
        },
        function () { // EF // RST 28
            push(pc),
            mp = pc = 40
        },
        function () { // F0 // RET P
            t.time++,
            Ff & 128 || ret()
        },
        function () { // F1 // POP AF
            af(pop())
        },
        function () { // F2 // JP P
            jp(!(Ff & 128))
        },
        function () { // F3 // DI
            dd_fd(243)
        },
        function () { // F4 // CALL P
            callc(!(Ff & 128))
        },
        function () { // F5 // PUSH AF
            push(a << 8 | F())
        },
        function () { // F6 // OR A, n
            Fa = (a = Ff = Fr = a | imm8()) | 256,
            Fb = 0
        },
        function () { // F7 // RST 30
            push(pc),
            mp = pc = 48
        },
        function () { // F8 // RET M
            t.time++,
            Ff & 128 && ret()
        },
        function () { // F9 // LD SP, HL
            sp = hl,
            t.time += 2
        },
        function () { // FA // JP M
            jp(Ff & 128)
        },
        function () { // FB // EI
            dd_fd(251)
        },
        function () { // FC // CALL M
            callc(Ff & 128)
        },
        function () { // FD // OP FD
            dd_fd(253)
        },
        function () { // FE // CP A, n
            cp(imm8())
        },
        function () { // FF // RST 38
            push(pc),
            mp = pc = 56
        }
    ],
    pref = [
        , , , , , , , , ,
        function (a) { // 09 // ADD XY, BC
            return add16(a, b << 8 | c)
        }, , , , , , , , , , , , , , , ,
        function (a) { // 19 // ADD XY, DE
            return add16(a, d << 8 | e)
        }, , , , , , , ,
        imm16,         // 21 // LDD XY, nn
        function (b) { // 22 // LD (nn), XY
            var a = imm16();
            t.put(a, b & 255),
            t.time += 3,
            t.put(mp = a + 1 & 65535, b >> 8),
            t.time += 3
        },
        function (b) { // 23 // INC XY
            return  b = b + 1 & 65535,
                    t.time += 2,
                    b
        },
        function (a) { // 24 // INC XYh
            return a & 255 | inc(a >> 8) << 8
        },
        function (a) { // 25 // DEC XYh
            return a & 255 | dec(a >> 8) << 8
        },
        function (a) { // 26 // LD XYh, n
            return a & 255 | imm8() << 8
        }, , ,
        function (a) { // 29 // ADD XY, XY
            return add16(a, a)
        },
        function (b) { // 2A // LD XY, (nn)
            var a = imm16();
            mp = a + 1,
            b = t.get16(a),
            t.time += 6;
            return b
        },
        function (b) { // 2B // DEC XY
            return  b = b - 1 & 65535,
                    t.time += 2,
                    b
        },
        function (a) { // 2C // INC XYl
            return a & -256 | inc(a & 255)
        },
        function (a) { // 2D // DEC XYl
            return a & -256 | dec(a & 255)
        },
        function (a) { // 2E // LD XYl, n
            return a & -256 | imm8()
        }, , , , , ,
        function (b) { // 34 // INC (XY+d)
            var a = getd(b),
                d = inc(t.get(a));
            t.time += 4,
            t.put(a, d),
            t.time += 3
        },
        function (b) { // 35 // DEC (XY+d)
            var a = getd(b),
                d = dec(t.get(a));
            t.time += 4,
            t.put(a, d),
            t.time += 3
        },
        function (b) { // 36 // LD (XY+d), n
            var a, d = getd(b);
            t.time += -5,
            a = imm8(),
            t.time += 2,
            t.put(d, a),
            t.time += 3
        }, , ,
        function (a) { // 39 // ADD XY, SP
            return add16(a, sp)
        }, , , , , , , , , , ,
        function (a) { // 44 // LD B, XYh
            b = a >> 8
        },
        function (a) { // 45 // LD B, XYl
            b = a & 255
        },
        function (a) { // 46 // LD B, (XY+d)
            b = getd3(a)
        }, , , , , ,
        function (a) { // 4C // LD C, XYh
            c = a >> 8
        },
        function (a) { // 4D // LD C, XYl
            c = a & 255
        },
        function (a) { // 4E // LD C, (XY+d)
            c = getd3(a)
        }, , , , , ,
        function (a) { // 54 // LD D, XYh
            d = a >> 8
        },
        function (a) { // 55 // LD D, XYl
            d = a & 255
        },
        function (a) { // 56 // LD D, (XY+d)
            d = getd3(a)
        }, , , , , ,
        function (a) { // 5C // LD E, XYh
            e = a >> 8
        },
        function (a) { // 5D // LD E, XYl
            e = a & 255
        },
        function (a) { // 5E // LD E, (XY+d)
            e = getd3(a)
        }, ,
        function (a) { // 60 // LD XYh, B
            return a & 255 | b << 8
        },
        function (a) { // 61 // LD XYh, C
            return a & 255 | c << 8
        },
        function (a) { // 62 // LD XYh, D
            return a & 255 | d << 8
        },
        function (a) { // 63 // LD XYh, E
            return a & 255 | e << 8
        }, ,
        function (a) { // 65 // LD XYh, XYl
            return a & 255 | (a & 255) << 8
        },
        function (a) { // 66 // LD H, (XY+d)
            hl = hl & 255 | getd3(a) << 8
        },
        function (b) { // 67 // LD XYh, A
            return b & 255 | a << 8
        },
        function (a) { // 68 // LD XYl, B
            return a & -256 | b
        },
        function (a) { // 69 // LD XYl, C
            return a & -256 | c
        },
        function (a) { // 6A // LD XYl, D
            return a & -256 | d
        },
        function (a) { // 6B // LD XYl, E
            return a & -256 | e
        },
        function (a) { // 6C // LD XYl, XYh
            return a & -256 | a >> 8
        }, ,
        function (a) { // 6E // LD L, (XY+d)
            hl = hl & -256 | getd3(a)
        },
        function (b) { // 6F // LD XYl, A
            return b & -256 | a
        },
        function (a) { // 70 // LD (XY+d), B
            t.put(getd(a), b),
            t.time += 3
        },
        function (b) { // 71 // LD (XY+d), C
            t.put(getd(b), c),
            t.time += 3
        },
        function (b) { // 72 // LD (XY+d), D
            t.put(getd(b), d),
            t.time += 3
        },
        function (b) { // 73 // LD (XY+d), E
            t.put(getd(b), e),
            t.time += 3
        },
        function (b) { // 74 // LD (XY+d), H
            t.put(getd(b), hl >> 8),
            t.time += 3
        },
        function (b) { // 75 // LD (XY+d), L
            t.put(getd(b), hl & 255),
            t.time += 3
        }, ,
        function (b) { // 77 // LD (XY+d), A
            t.put(getd(b), a),
            t.time += 3
        }, , , , ,
        function (b) { // 7C // LD A, XYh
            a = b >> 8
        },
        function (b) { // 7D // LD A, XYl
            a = b & 255
        },
        function (b) { // 7E // LD A, (XY+d)
            a = getd3(b)
        }, , , , , ,
        function (b) { // 84 // ADD A, XYh
            a = Fr = (Ff = (Fa = a) + (Fb = b >> 8)) & 255
        },
        function (b) { // 85 // ADD A, XYl
            a = Fr = (Ff = (Fa = a) + (Fb = b & 255)) & 255
        },
        function (b) { // 86 // ADD A, (XY+d)
            a = Fr = (Ff = (Fa = a) + (Fb = getd3(b))) & 255
        }, , , , , ,
        function (b) { // 8C // ADC A, XYh
            a = Fr = (Ff = (Fa = a) + (Fb = b >> 8) + (Ff >> 8 & 1)) & 255
        },
        function (b) { // 8D // ADC A, XYl
            a = Fr = (Ff = (Fa = a) + (Fb = b & 255) + (Ff >> 8 & 1)) & 255
        },
        function (b) { // 8E // ADC A, (XY+d)
            a = Fr = (Ff = (Fa = a) + (Fb = getd3(b)) + (Ff >> 8 & 1)) & 255
        }, , , , , ,
        function (b) { // 94 // SUB A, XYh
            a = Fr = (Ff = (Fa = a) + (Fb = ~ (b >> 8)) + 1) & 255
        },
        function (b) { // 95 // SUB A, XYl
            a = Fr = (Ff = (Fa = a) + (Fb = ~ (b & 255)) + 1) & 255
        },
        function (b) { // 96 // SUB A, (XY+d)
            a = Fr = (Ff = (Fa = a) + (Fb = ~getd3(b)) + 1) & 255
        }, , , , , ,
        function (b) { // 9C // SBC A, XYh
            a = Fr = (Ff = (Fa = a) + (Fb = ~ (b >> 8)) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function (b) { // 9D // SBC A, XYl
            a = Fr = (Ff = (Fa = a) + (Fb = ~ (b & 255)) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function (b) { // 9E // SBC A, (XY+d)
            a = Fr = (Ff = (Fa = a) + (Fb = ~getd3(b)) + (Ff >> 8 & 1 ^ 1)) & 255
        }, , , , , ,
        function (b) { // A4 // AND XYh
            Fa = ~ (a = Ff = Fr = a & b >> 8),
            Fb = 0
        },
        function (b) { // A5 // AND XYl
            Fa = ~ (a = Ff = Fr = a & b & 255),
            Fb = 0
        },
        function (b) { // A6 // AND (XY+d)
            Fa = ~ (a = Ff = Fr = a & getd3(b)),
            Fb = 0
        }, , , , , ,
        function (b) { // AC // XOR XYh
            Fa = (a = Ff = Fr = a ^ b >> 8) | 256,
            Fb = 0
        },
        function (b) { // AD // XOR XYl
            Fa = (a = Ff = Fr = a ^ b & 255) | 256,
            Fb = 0
        },
        function (b) { // AE // XOR (XY+d)
            Fa = (a = Ff = Fr = a ^ getd3(b)) | 256,
            Fb = 0
        }, , , , , ,
        function (b) { // B4 // OR XYh
            Fa = (a = Ff = Fr = a | b >> 8) | 256,
            Fb = 0
        },
        function (b) { // B5 // OR XYl
            Fa = (a = Ff = Fr = a | b & 255) | 256,
            Fb = 0
        },
        function (b) { // B6 // OR (XY+d)
            Fa = (a = Ff = Fr = a | getd3(b)) | 256,
            Fb = 0
        }, , , , , ,
        function (a) { // BC // CP XYh
            cp(a >> 8)
        },
        function (a) { // BD // CP XYl
            cp(a & 255)
        },
        function (a) { // BE // CP (XY+d)
            cp(getd3(a))
        }, , , , , , , , , , , , ,
        xdcb,          // CB // OP XDCB
        , , , , , , , , , , , , , , , , , , , , ,
        pop, ,         // E1 // POP XY
        function (b) { // E3 // EX (SP), XY
            return  mp = pop(),
                    push(b),
                    t.time += 2,
                    mp
        }, ,
        push, , , ,    // E5 // PUSH XY
        function (a) { // E9 // JP (XY)
            pc = a
        }, , , , , , , , , , , , , , , ,
        function (b) { // F9 // LD SP, XY
            sp = b,
            t.time += 2
        }
    ],
    ed = [, , , , , , , , , , , , , , , ,
        , , , , , , , , , , , , , , , ,
        , , , , , , , , , , , , , , , ,
        , , , , , , , , , , , , , , , ,
        function () { // 40 // IN B, (C)
            b = in_()
        },
        function () { // 41 // OUT (C), B
            out(b)
        },
        function () { // 42 // SBC HL, BC
            adc_sbc_hl(~ (b << 8 | c), 1)
        },
        function () { // 43 // LD (nn), BC
            mp = imm16();
            t.put(mp, c),
            t.time += 3,
            t.put(mp = mp + 1 & 65535, b),
            t.time += 3
        },            
        neg,          // 44 // NEG
        reti,         // 45 // RETN
        im0,          // 46 // IM 0
        function () { // 47 // LD I, A
            ir = ir & 255 | a << 8,
            t.time++
        },
        function () { // 48 // IN C, (C)
            c = in_()
        },
        function () { // 49 // OUT (C), C
            out(c)
        },
        function () { // 4A // ADC HL, BC
            adc_sbc_hl(b << 8 | c, 0)
        },
        function () { // 4B // LD BC, (nn)
            var a = imm16();
            mp = a + 1,
            a = t.get16(a),
            b = a >> 8,
            c = a & 255,
            t.time += 6
        },
        neg,          // 4C // NEG
        reti,         // 4D // RETI
        im0,          // 4E // IM 0
        function () { // 4F // LD R, A
            ldrx(a),
            t.time++
        },
        function () { // 50 // IN D, (C)
            d = in_()
        },
        function () { // 51 // OUT (C), D
            out(d)
        },
        function () { // 52 // SBC HL, DE
            adc_sbc_hl(~ (d << 8 | e), 1)
        },
        function () { // 53 // LD (nn), DE
            var b = imm16();
            t.put(b, e),
            t.time += 3,
            t.put(mp = b + 1 & 65535, d),
            t.time += 3
        },
        neg,          // 54 // NEG
        reti,         // 55 // RETN
        im1,          // 56 // IM 1
        function () { // 57 // LD A, I
            ldax(ir >> 8)
        },
        function () { // 58 // IN E, (C)
            e = in_()
        },
        function () { // 59 // OUT (C), E
            out(e)
        },
        function () { // 5A // ADC HL, DE
            adc_sbc_hl(d << 8 | e, 0)
        },
        function () { // 5B // LD DE, (nn)
            var b = imm16();
            mp = b + 1,
            b = t.get16(b),
            d = b >> 8,
            e = b & 255,
            t.time += 6
        },
        neg,          // 5C // NEG
        reti,         // 5D // RETI
        im2,          // 5E // IM 2
        function () { // 5F // LD A, R
            ldax(r7())
        },
        function () { // 60 // IN H, (C)
            hl = hl & 255 | in_() << 8
        },
        function () { // 61 // OUT (C), H
            out(hl >> 8)
        },
        function () { // 62 // SBC HL, HL
            adc_sbc_hl(~hl, 1)
        },
        function () { // 63 // LD (nn), HL
            var b = imm16();
            t.put(b, hl & 255),
            t.time += 3,
            t.put(mp = b + 1 & 65535, hl >> 8),
            t.time += 3
        },
        neg,          // 64 // NEG
        reti,         // 65 // RETN
        im0,          // 66 // IM 0
        rrd,          // 67 // RRD
        function () { // 68 // IN L, (C)
            hl = hl & -256 | in_()
        },
        function () { // 69 // OUT (C), L
            out(hl & 255)
        },
        function () { // 6A // ADC HL, HL
            adc_sbc_hl(hl, 0)
        },
        function () { // 6B // LD HL, (nn)
            var b = imm16();
            mp = b + 1,
            hl = t.get16(b),
            t.time += 6
        },
        neg,          // 6C // NEG
        reti,         // 6D // RETI
        im0,          // 6E // IM 0
        rld,          // 6F // RLD
        in_,          // 70 // IN X, (C)
        function () { // 71 // OUT (C), 0
            out(0)
        },
        function () { // 72 // SBC HL, SP
            adc_sbc_hl(~sp, 1)
        },
        function () { // 73 // LD (nn), SP
            var b = imm16();
            t.put(b, sp & 255),
            t.time += 3,
            t.put(mp = b + 1 & 65535, sp >> 8),
            t.time += 3
        },
        neg,          // 74 // NEG
        reti,         // 75 // RETN
        im1, ,        // 76 // IM 1
        function () { // 78 // IN A, (C)
            a = in_()
        },
        function () { // 79 // OUT (C), A
            out(a)
        },
        function () { // 7A // ADC HL, SP
            adc_sbc_hl(sp, 0)
        },
        function () { // 7B // LD SP, (nn)
            var b = imm16();
            mp = b + 1,
            sp = t.get16(b),
            t.time += 6
        },
        neg,          // 7C // NEG
        reti,         // 7D // RETI
        im2,          // 7E // IM 2
        , , , , , , , , , , , , , , , ,
        , , , , , , , , , , , , , , , , ,
        function () { // A0 // LDI
            ldi(1, 0)
        },
        function () { // A1 // CPI
            cpi(1, 0)
        },
        function () { // A2 // INI
            ini_outi(4)
        },
        function () { // A3 // OUTI
            ini_outi(5)
        }, , , , ,
        function () { // A8 // LDD
            ldi(-1, 0)
        },
        function () { // A9 // CPD
            cpi(-1, 0)
        },
        function () { // AA // IND
            ini_outi(-4)
        },
        function () { // AB // OUTD
            ini_outi(-3)
        }, , , , ,
        function () { // B0 // LDIR
            ldi(1, 1)
        },
        function () { // B1 // CPIR
            cpi(1, 1)
        },
        function () { // B2 // INIR
            ini_outi(6)
        },
        function () { // B3 // OTIR
            ini_outi(7)
        }, , , , ,
        function () { // B8 // LDDR
            ldi(-1, 1)
        },
        function () { // B9 // CPDR
            cpi(-1, 1)
        },
        function () { // BA // INDR
            ini_outi(-2)
        },
        function () { // BB // OTDR
            ini_outi(-1)
        }
    ],
    shift = [
        function (a) {
            b = shifter(a, b)
        },
        function (a) {
            c = shifter(a, c)
        },
        function (a) {
            d = shifter(a, d)
        },
        function (a) {
            e = shifter(a, e)
        },
        function (a) {
            hl = hl & 255 | shifter(a, hl >> 8) << 8
        },
        function (a) {
            hl = hl & -256 | shifter(a, hl & 255)
        },
        function (b) {
            var a = shifter(b, t.get(hl));
            t.time += 4,
            t.put(hl, a),
            t.time += 3
        },
        function (b) {
            a = shifter(b, a)
        }
    ],
    bita = [
        function (a) {
            bit(a, b)
        },
        function (a) {
            bit(a, c)
        },
        function (a) {
            bit(a, d)
        },
        function (a) {
            bit(a, e)
        },
        function (a) {
            bit(a, hl >> 8)
        },
        function (a) {
            bit(a, hl & 255)
        },
        function (b) {
            bit(b, t.get(hl)),
            Ff = Ff & -41 | mp >> 8 & 40,
            t.time += 4
        },
        function (b) {
            bit(b, a)
        }
    ],
    res = [
        function (a) {
            b &= ~a
        },
        function (a) {
            c &= ~a
        },
        function (a) {
            d &= ~a
        },
        function (a) {
            e &= ~a
        },
        function (a) {
            hl &= ~ (a << 8)
        },
        function (a) {
            hl &= ~a
        },
        function (b) {
            var a = t.get(hl) & ~b;
            t.time += 4,
            t.put(hl, a),
            t.time += 3
        },
        function (b) {
            a &= ~b
        }
    ],
    set = [
        function (a) {
            b |= a
        },
        function (a) {
            c |= a
        },
        function (a) {
            d |= a
        },
        function (a) {
            e |= a
        },
        function (a) {
            hl |= a << 8
        },
        function (a) {
            hl |= a
        },
        function (b) {
            var a = t.get(hl) | b;
            t.time += 4,
            t.put(hl, a),
            t.time += 3
        },
        function (b) {
            a |= b
        }
    ]
}