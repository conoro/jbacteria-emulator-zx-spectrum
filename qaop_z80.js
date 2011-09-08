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
        c = Fr = (Ff = (Fb = ~c) + 1) & 255,
        Fa = 0
    }
    function ini_outi(c) {
        var h = c >> 2,
            k, l, n;
        l = hl + h & 65535,
        k = i << 8 | j,
        t.time++,
        c & 1
            ? ( n = t.get(hl),
                t.time += 3,
                k = k - 256 & 65535,
                E = k + h,
                t.out(k, n),
                t.time += 4,
                h = l)
            : ( n = t.inp(k),
                t.time += 4,
                E = k + h,
                k = k - 256 & 65535,
                t.put(hl, n),
                t.time += 3,
                h += k),
        h = (h & 255) + n,
        hl = l,
        i = k >>= 8,
        c & 2 && k && ( t.time += 5,
                        pc = pc - 2 & 65535);
        var o = h & 7 ^ k;
        Ff = k | (h &= 256),
        Fa = (Fr = k) ^ 128,
        o = 4928640 >> ((o ^ o >> 4) & 15),
        Fb = (o ^ k) & 128 | h >> 4 | (n & 128) << 2
    }
    function cpi(h, k) {
        var l, n, o;
        o = c - (n = t.get(l = hl)) & 255,
        E += h,
        hl = l + h & 65535,
        t.time += 8,
        Fr = o & 127 | o >> 7,
        Fb = ~ (n | 128),
        Fa = c & 127,
        --j < 0 && (i = i - 1 & (j = 255)),
        i | j && (Fa |= 128,
                  Fb |= 128,
                  k && o && ( E = (pc = pc - 2 & 65535) + 1,
                              t.time += 5)),
        Ff = Ff & -256 | o & -41,
        (o ^ n ^ c) & 16 && o--,
        Ff |= o << 4 & 32 | o & 8
    }
    function ldi(h, n) {
        var o, p;
        p = t.get(o = hl),
        hl = o + h & 65535,
        t.time += 3,
        t.put(o = k << 8 | l, p),
        de(o + h & 65535),
        t.time += 5,
        Fr && (Fr = 1),
        p += c,
        Ff = Ff & -41 | p & 8 | p << 4 & 32,
        p = 0,
        --j < 0 && (i = i - 1 & (j = 255)),
        i | j && (n && (t.time += 5,
                        E = (pc = pc - 2 & 65535) + 1),
                        p = 128),
        Fa = Fb = p
    }
    function out(b) {
        var c = i << 8 | j;
        E = c + 1,
        t.out(c, b),
        t.time += 4
    }
    function in_() {
        var b = i << 8 | j,
            c = t.inp(b);
        E = b + 1,
        f_szh0n0p(c),
        t.time += 4;
        return c
    }
    function ldax(b) {
        Ff = Ff & -256 | (c = b),
        Fr = + !! b,
        Fa = Fb = iff << 6 & 128,
        t.time++
    }
    function rld() {
        var b = t.get(hl) << 4 | c & 15;
        t.time += 7,
        f_szh0n0p(c = c & 240 | b >> 8),
        t.put(hl, b & 255),
        E = hl + 1,
        t.time += 3
    }
    function rrd() {
        var b = t.get(hl) | c << 8;
        t.time += 7,
        f_szh0n0p(c = c & 240 | b & 15),
        t.put(hl, b >> 4 & 255),
        E = hl + 1,
        t.time += 3
    }
    function adc_sbc_hl(b, c) {
        var h = hl + b + (Ff >> 8 & 1 ^ c);
        E = hl + 1,
        Ff = h >> 8,
        Fa = hl >> 8,
        Fb = b >> 8,
        hl = h = h & 65535,
        Fr = h >> 8 | h << 8,
        t.time += 7
    }
    function getd3(c) {
        var d = t.get(pc);
        pc = pc + 1 & 65535,
        t.time += 8,
        d = t.get(E = c + (d ^ 128) - 128 & 65535),
        t.time += 3;
        return d
    }
    function getd(c) {
        var d = t.get(pc);
        pc = pc + 1 & 65535,
        t.time += 8;
        return E = c + (d ^ 128) - 128 & 65535
    }
    function interrupt() {
        var c = t.int,
            d;
        iff = 0,
        halted = 0,
        t.time += 6,
        im  ? ( push(pc),
                d = 56,
                im > 1 && (d = t.get16(ir & 65280 | c),
                          t.time += 6),
                E = pc = d)
            : op[c]()
    }
    function xdcb(e) {
        var f, g, h, n;
        f = E = e + (t.get(pc) ^ 128) - 128 & 65535,
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
                i = h;
                break;
            case 1:
                j = h;
                break;
            case 2:
                k = h;
                break;
            case 3:
                l = h;
                break;
            case 4:
                hl = hl & 255 | h << 8;
                break;
            case 5:
                hl = hl & 65280 | h;
                break;
            case 7:
                c = h
        }
    }
    function cb() {
        var c, d;
        c = t.m1(pc, ir | (A = A + 1 & 127)),
        pc = pc + 1 & 65535,
        t.time += 4,
        d = c >> 3 & 7;
        switch (c & 192) {
            case 0:
                shift[c & 7](d);
                break;
            case 64:
                bita[c & 7](d);
                break;
            case 128:
                res[c & 7](1 << d);
                break;
            case 192:
                set[c & 7](1 << d)
        }
    }
    function ed() {
        var c = ed[t.m1(pc, ir | (A = A + 1 & 127))];
        pc = pc + 1 & 65535,
        t.time += 4,
        c && c()
    }
    function dd_fd(c) {
        var d, e, f;
        g: for (;;) {
            switch (c) {
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
                    op[c]();
                    break g
            }
            e = c,
            c = t.m1(pc, ir | (A = A + 1 & 127)),
            pc = pc + 1 & 65535,
            t.time += 4;
            if (e & 4 && (d = pref[c])) {
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
        b > 0 && (b = t.halt(b, ir | A),
                  A = A + b & 127,
                  t.time += 4 * b)
    }
    function ret() {
        E = pc = t.get16(sp),
        sp = sp + 2 & 65535,
        t.time += 6
    }
    function callc(a) {
        var c = E = imm16();
        a && (push(pc),
              pc = c)
    }
    function jr() {
        E = pc = pc + (t.get(pc) ^ 128) - 127 & 65535,
        t.time += 8
    }
    function jp(a) {
        var c = E = imm16();
        a && (pc = c)
    }
    function daa() {
        var d = (Fr ^ Fa ^ Fb ^ Fb >> 8) & 16,
            b = 0;
        (c | Ff & 256) > 153 && (b = 352),
        (c & 15 | d) > 9 && (b += 6),
        Fa = c | 256,
        Fb & 512
            ? (c -= b,
              Fb = ~b)
            : c += Fb = b,
              Ff = (Fr = c &= 255) | b & 256
    }
    function cpl() {
        Ff = Ff & -41 | (c ^= 255) & 40,
        Fb |= -129,
        Fa = Fa & -17 | ~Fr & 16
    }
    function scf_ccf(b) {
        Fa &= -17,
        Fb = Fb & 128 | (b >> 4 ^ Fr) & 16,
        Ff = 256 ^ b | Ff & 128 | c & 40
    }
    function imm16() {
        var c = t.get16(pc);
        pc = pc + 2 & 65535,
        t.time += 6;
        return c
    }
    function imm8() {
        var c = t.get(pc);
        pc = pc + 1 & 65535,
        t.time += 3;
        return c
    }
    function add16(b, c) {
        var h = b + c;
        Ff = Ff & 128 | h >> 8 & 296,
        Fa &= -17,
        Fb = Fb & 128 | ((h ^ b ^ c) >> 8 ^ Fr) & 16,
        E = b + 1,
        t.time += 7;
        return h & 65535
    }
    function rot(b) {
        Ff = Ff & 215 | b & 296,
        Fb &= 128,
        Fa = Fa & -17 | Fr & 16,
        c = b & 255
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
        var b = (Fa = c) - d;
        Fb = ~d,
        Ff = b & -41 | d & 40,
        Fr = b & 255
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
        var tmp = a_; a_ = c, c = tmp,
        tmp = Ff_, Ff_ = Ff, Ff = tmp,
        tmp = Fr_, Fr_ = Fr, Fr = tmp,
        tmp = Fa_, Fa_ = Fa, Fa = tmp,
        a = Fb_, Fb_ = Fb, Fb = a
    }
    function exx() {
        var a = u; u = i, i = a,
        a = v, v = j, j = a,
        a = w, w = k, k = a,
        a = x, x = l, l = a,
        a = hl_, hl_ = hl, hl = a
    }
    function de(a) {
        k = a >> 8,
        l = a & 255
    }
    function bc(a) {
        i = a >> 8,
        j = a & 255
    }
    function ldrx(a) {
        ir = ir & 65280 | a,
        A = a & 127
    }
    function r7() {
        return ir & 128 | A
    }
    function af(b) {
        flags(b & 255),
        c = b >> 8
    }
    function flags(a) {
        Fr = ~a & 64,
        Ff = a |= a << 8,
        Fa = 255 & (Fb = a & -129 | (a & 4) << 5)
    }
    function F() {
        var a = Ff & 168 | Ff >> 8 & 1,
            b = Fa,
            c = Fb,
            h = c >> 8;
        Fr || (a |= 64);
        var i = Fr ^ b;
        a |= h & 2,
        a |= (i ^ c ^ h) & 16,
        Fa & -256
            ? b = 154020 >> ((Fr ^ Fr >> 4) & 15)
            : b = (i & (c ^ Fr)) >> 5;
        return a | b & 4
    }
    var pc, c, Ff, Fr, Fa, Fb, sp, i, j, k, l, hl, ix, iy,
        a_, Ff_, Fr_, Fa_, Fb_, u, v, w, x, hl_, ir, A, im, iff, halted, E;
    pc = ir = A = im = iff = 0,
    sp = ix = iy = hl = hl_ = 65535,
    c = i = j = k = l = a_ = u = v = w = x = 255,
    Ff = Fr = Fa = Fb = Ff_ = Fr_Fa_ = Fb_ == 0,
    halted = 0,
    this.getState = function () {
        var t = {
            pc: pc,
            a: c,
            f: F(),
            sp: sp,
            bc: i << 8 | j,
            de: k << 8 | l,
            hl: hl,
            ix: ix,
            iy: iy,
            bc_: u << 8 | v,
            de_: w << 8 | x,
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
        "a" in t && (c = t.a),
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
        "a_" in t && (c = t.a_),
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
                var c = t.m1(pc, ir | (A = A + 1 & 127));
                pc = pc + 1 & 65535,
                t.time += 4,
                op[c]()
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
        pc = ir = A = im = iff = 0
    };
    var op = [
        nop,          // 00 // NOP
        function () { // 01 // LD BC, nn
            var a = imm16();
            i = a >> 8,
            j = a & 255
        },
        function () { // 02 // LD (BC), A
            var b = i << 8 | j;
            E = b + 1 & 255 | c << 8,
            t.put(b, c),
            t.time += 3
        },
        function () { // 03 // INC BC
            ++j === 256 && (i = i + 1 & 255,
                            j = 0),
            t.time += 2
        },
        function () { // 04 // INC B
            i = inc(i)
        },
        function () { // 05 // DEC B
            i = dec(i)
        },
        function () { // 06 // LD B, n
            i = imm8()
        },
        function () { // 07 // RLCA
            rot(c * 257 >> 7)
        },
        ex_af,        // 08 // EX AF, AF'
        function () { // 09 // ADD HL, BC
            hl = add16(hl, i << 8 | j)
        },
        function () { // 0A // LD A, (BC)
            var b = i << 8 | j;
            E = b + 1,
            c = t.get(b),
            t.time += 3
        },
        function () { // 0B // DEC BC
            --j < 0 && (i = i - 1 & (j = 255)),
            t.time += 2
        },
        function () { // 0C // INC C
            j = inc(j)
        },
        function () { // 0D // DEC C
            j = dec(j)
        },
        function () { // 0E // LD C, n
            j = imm8()
        },
        function () { // 0F // RRCA
            rot(c >> 1 | ((c & 1) + 1 ^ 1) << 7)
        },
        function () { // 10 // DJNZ
            var c, d;
            t.time++,
            d = t.get(c = pc),
            c++,
            t.time += 3;
            if (i = i - 1 & 255)
                t.time += 5,
                E = c += (d ^ 128) - 128;
            pc = c & 65535
        },
        function () { // 11 // LD DE, nn
            var a = imm16();
            k = a >> 8,
            l = a & 255
        },
        function () { // 12 // LD DE, (A)
            var b = k << 8 | l;
            E = b + 1 & 255 | c << 8,
            t.put(b, c),
            t.time += 3
        },
        function () { // 13 // INC DE
            ++l === 256 && (k = k + 1 & 255,
                            l = 0),
            t.time += 2
        },
        function () { // 14 // INC D
            k = inc(k)
        },
        function () { // 15 // DEC D
            k = dec(k)
        },
        function () { // 16 // LD D, n
            k = imm8()
        },
        function () { // 17 // RLA
            rot(c << 1 | Ff >> 8 & 1)
        },
        jr,           // 18 // JR
        function () { // 19 // ADD HL, DE
            hl = add16(hl, k << 8 | l)
        },
        function () { // 1A // LD DE, nn
            var b = k << 8 | l;
            E = b + 1,
            c = t.get(b),
            t.time += 3
        },
        function () { // 1B // INC DE
            --l < 0 && (k = k - 1 & (l = 255)),
            t.time += 2
        },
        function () { // 1C // INC E
            l = inc(l)
        },
        function () { // 1D // DEC E
            l = dec(l)
        },
        function () { // 1E // LD E, n
            l = imm8()
        },
        function () { // 1F // RRA
            rot((c * 513 | Ff & 256) >> 1)
        },
        function () { // 20 // JR NZ
            Fr ? jr() : imm8()
        },
        function () { // 21 // LD HL, nn
            hl = imm16()
        },
        function () { // 22 // LD (nn), HL
            var b = imm16();
            t.put(b, hl & 255),
            t.time += 3,
            t.put(E = b + 1 & 65535, hl >> 8),
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
            E = b + 1,
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
            E = b + 1 & 255 | c << 8,
            t.put(b, c),
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
            scf_ccf(0)
        },
        function () { // 38 // JR C
            Ff & 256 ? jr() : imm8()
        },
        function () { // 39 // ADD HL, SP
            hl = add16(hl, sp)
        },
        function () { // 3A // LD A, (nn)
            var b = imm16();
            E = b + 1,
            c = t.get(b),
            t.time += 3
        },
        function () { // 3B // DEC SP
            sp = sp - 1 & 65535,
            t.time += 2
        },
        function () { // 3C // INC A
            c = inc(c)
        },
        function () { // 3D // DEC A
            c = dec(c)
        },
        function () { // 3E // LD A, n
            c = imm8()
        },
        function () { // 3F // CCF
            scf_ccf(Ff & 256)
        },
        nop,          // 40 // LD B, B
        function () { // 41 // LD B, C
            i = j
        },
        function () { // 42 // LD B, D
            i = k
        },
        function () { // 43 // LD B, E
            i = l
        },
        function () { // 44 // LD B, H
            i = hl >> 8
        },
        function () { // 45 // LD B, L
            i = hl & 255
        },
        function () { // 46 // LD B, (HL)
            i = t.get(hl),
            t.time += 3
        },
        function () { // 47 // LD B, A
            i = c
        },
        function () { // 48 // LD C, B
            j = i
        },
        nop,          // 49 // LD C, C
        function () { // 4A // LD C, D
            j = k
        },
        function () { // 4B // LD C, E
            j = l
        },
        function () { // 4C // LD C, H
            j = hl >> 8
        },
        function () { // 4D // LD C, L
            j = hl & 255
        },
        function () { // 4E // LD C, (HL)
            j = t.get(hl),
            t.time += 3
        },
        function () { // 4F // LD C, A
            j = c
        },
        function () { // 50 // LD D, B
            k = i
        },
        function () { // 51 // LD D, C
            k = j
        },
        nop,          // 52 // LD D, D
        function () { // 53 // LD D, E
            k = l
        },
        function () { // 54 // LD D, H
            k = hl >> 8
        },
        function () { // 55 // LD D, L
            k = hl & 255
        },
        function () { // 56 // LD D, (HL)
            k = t.get(hl),
            t.time += 3
        },
        function () { // 57 // LD D, A
            k = c
        },
        function () { // 58 // LD E, B
            l = i
        },
        function () { // 59 // LD E, C
            l = j
        },
        function () { // 5A // LD E, D
            l = k
        },
        nop,          // 5B // LD E, E
        function () { // 5C // LD E, H
            l = hl >> 8
        },
        function () { // 5D // LD E, L
            l = hl & 255
        },
        function () { // 5E // LD E, (HL)
            l = t.get(hl),
            t.time += 3
        },
        function () { // 5F // LD E, A
            l = c
        },
        function () { // 60 // LD H, B
            hl = hl & 255 | i << 8
        },
        function () { // 61 // LD H, C
            hl = hl & 255 | j << 8
        },
        function () { // 62 // LD H, D
            hl = hl & 255 | k << 8
        },
        function () { // 63 // LD H, E
            hl = hl & 255 | l << 8
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
            hl = hl & 255 | c << 8
        },
        function () { // 68 // LD L, B
            hl = hl & -256 | i
        },
        function () { // 69 // LD L, C
            hl = hl & -256 | j
        },
        function () { // 6A // LD L, D
            hl = hl & -256 | k
        },
        function () { // 6B // LD L, E
            hl = hl & -256 | l
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
            hl = hl & -256 | c
        },
        function () { // 70 // LD (HL), B
            t.put(hl, i),
            t.time += 3
        },
        function () { // 71 // LD (HL), C
            t.put(hl, j),
            t.time += 3
        },
        function () { // 72 // LD (HL), D
            t.put(hl, k),
            t.time += 3
        },
        function () { // 73 // LD (HL), E
            t.put(hl, l),
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
            t.put(hl, c),
            t.time += 3
        },
        function () { // 78 // LD A, B
            c = i
        },
        function () { // 79 // LD A, C
            c = j
        },
        function () { // 7A // LD A, D
            c = k
        },
        function () { // 7B // LD A, E
            c = l
        },
        function () { // 7C // LD A, H
            c = hl >> 8
        },
        function () { // 7D // LD A, L
            c = hl & 255
        },
        function () { // 7E // LD A, (HL)
            c = t.get(hl),
            t.time += 3
        },
        nop,          // 7F // LD A, A
        function () { // 80 // ADD A, B
            c = Fr = (Ff = (Fa = c) + (Fb = i)) & 255
        },
        function () { // 81 // ADD A, C
            c = Fr = (Ff = (Fa = c) + (Fb = j)) & 255
        },
        function () { // 82 // ADD A, D
            c = Fr = (Ff = (Fa = c) + (Fb = k)) & 255
        },
        function () { // 83 // ADD A, E
            c = Fr = (Ff = (Fa = c) + (Fb = l)) & 255
        },
        function () { // 84 // ADD A, H
            c = Fr = (Ff = (Fa = c) + (Fb = hl >> 8)) & 255
        },
        function () { // 85 // ADD A, L
            c = Fr = (Ff = (Fa = c) + (Fb = hl & 255)) & 255
        },
        function () { // 86 // ADD A, (HL)
            c = Fr = (Ff = (Fa = c) + (Fb = t.get(hl))) & 255,
            t.time += 3
        },
        function () { // 87 // ADD A, A
            c = Fr = (Ff = 2 * (Fa = Fb = c)) & 255
        },
        function () { // 88 // ADC A, B
            c = Fr = (Ff = (Fa = c) + (Fb = i) + (Ff >> 8 & 1)) & 255
        },
        function () { // 89 // ADC A, C
            c = Fr = (Ff = (Fa = c) + (Fb = j) + (Ff >> 8 & 1)) & 255
        },
        function () { // 8A // ADC A, D
            c = Fr = (Ff = (Fa = c) + (Fb = k) + (Ff >> 8 & 1)) & 255
        },
        function () { // 8B // ADC A, E
            c = Fr = (Ff = (Fa = c) + (Fb = l) + (Ff >> 8 & 1)) & 255
        },
        function () { // 8C // ADC A, H
            c = Fr = (Ff = (Fa = c) + (Fb = hl >> 8) + (Ff >> 8 & 1)) & 255
        },
        function () { // 8D // ADC A, L
            c = Fr = (Ff = (Fa = c) + (Fb = hl & 255) + (Ff >> 8 & 1)) & 255
        },
        function () { // 8E // ADC A, (HL)
            c = Fr = (Ff = (Fa = c) + (Fb = t.get(hl)) + (Ff >> 8 & 1)) & 255,
            t.time += 3
        },
        function () { // 8F // ADC A, A
            c = Fr = (Ff = 2 * (Fa = Fb = c) + (Ff >> 8 & 1)) & 255
        },
        function () { // 90 // SUB A, B
            c = Fr = (Ff = (Fa = c) + (Fb = ~i) + 1) & 255
        },
        function () { // 91 // SUB A, C
            c = Fr = (Ff = (Fa = c) + (Fb = ~j) + 1) & 255
        },
        function () { // 92 // SUB A, D
            c = Fr = (Ff = (Fa = c) + (Fb = ~k) + 1) & 255
        },
        function () { // 93 // SUB A, E
            c = Fr = (Ff = (Fa = c) + (Fb = ~l) + 1) & 255
        },
        function () { // 94 // SUB A, H
            c = Fr = (Ff = (Fa = c) + (Fb = ~ (hl >> 8)) + 1) & 255
        },
        function () { // 95 // SUB A, L
            c = Fr = (Ff = (Fa = c) + (Fb = ~ (hl & 255)) + 1) & 255
        },
        function () { // 96 // SUB A, (HL)
            c = Fr = (Ff = (Fa = c) + (Fb = ~t.get(hl)) + 1) & 255,
            t.time += 3
        },
        function () { // 97 // SUB A, A
            Fb = ~ (Fa = c), c = Fr = Ff = 0
        },
        function () { // 98 // SBC A, B
            c = Fr = (Ff = (Fa = c) + (Fb = ~i) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 99 // SBC A, C
            c = Fr = (Ff = (Fa = c) + (Fb = ~j) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 9A // SBC A, D
            c = Fr = (Ff = (Fa = c) + (Fb = ~k) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 9B // SBC A, E
            c = Fr = (Ff = (Fa = c) + (Fb = ~l) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 9C // SBC A, H
            c = Fr = (Ff = (Fa = c) + (Fb = ~ (hl >> 8)) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 9D // SBC A, L
            c = Fr = (Ff = (Fa = c) + (Fb = ~ (hl & 255)) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // 9E // SBC A, (HL)
            c = Fr = (Ff = (Fa = c) + (Fb = ~t.get(hl)) + (Ff >> 8 & 1 ^ 1)) & 255,
            t.time += 3
        },
        function () { // 9F // SBC A, A
            Fb = ~ (Fa = c), c = Fr = (Ff = (Ff >> 8 & 1 ^ 1) - 1) & 255
        },
        function () { // A0 // AND B
            Fa = ~ (c = Ff = Fr = c & i),
            Fb = 0
        },
        function () { // A1 // AND C
            Fa = ~ (c = Ff = Fr = c & j),
            Fb = 0
        },
        function () { // A2 // AND D
            Fa = ~ (c = Ff = Fr = c & k),
            Fb = 0
        },
        function () { // A3 // AND E
            Fa = ~ (c = Ff = Fr = c & l),
            Fb = 0
        },
        function () { // A4 // AND H
            Fa = ~ (c = Ff = Fr = c & hl >> 8),
            Fb = 0
        },
        function () { // A5 // AND L
            Fa = ~ (c = Ff = Fr = c & hl & 255),
            Fb = 0
        },
        function () { // A6 // AND (HL)
            Fa = ~ (c = Ff = Fr = c & t.get(hl)),
            Fb = 0,
            t.time += 3
        },
        function () { // A7 // AND A
            Fa = ~ (Ff = Fr = c),
            Fb = 0
        },
        function () { // A8 // XOR B
            Fa = (c = Ff = Fr = c ^ i) | 256,
            Fb = 0
        },
        function () { // A9 // XOR C
            Fa = (c = Ff = Fr = c ^ j) | 256,
            Fb = 0
        },
        function () { // AA // XOR D
            Fa = (c = Ff = Fr = c ^ k) | 256,
            Fb = 0
        },
        function () { // AB // XOR E
            Fa = (c = Ff = Fr = c ^ l) | 256,
            Fb = 0
        },
        function () { // AC // XOR H
            Fa = (c = Ff = Fr = c ^ hl >> 8) | 256,
            Fb = 0
        },
        function () { // AD // XOR L
            Fa = (c = Ff = Fr = c ^ hl & 255) | 256,
            Fb = 0
        },
        function () { // AE // XOR (HL)
            Fa = (c = Ff = Fr = c ^ t.get(hl)) | 256,
            Fb = 0,
            t.time += 3
        },
        function () { // AF // XOR A
            c = Ff = Fr = Fb = 0,
            Fa = 256
        },
        function () { // B0 // OR B
            Fa = (c = Ff = Fr = c | i) | 256,
            Fb = 0
        },
        function () { // B1 // OR C
            Fa = (c = Ff = Fr = c | j) | 256,
            Fb = 0
        },
        function () { // B2 // OR D
            Fa = (c = Ff = Fr = c | k) | 256,
            Fb = 0
        },
        function () { // B3 // OR E
            Fa = (c = Ff = Fr = c | l) | 256,
            Fb = 0
        },
        function () { // B4 // OR H
            Fa = (c = Ff = Fr = c | hl >> 8) | 256,
            Fb = 0
        },
        function () { // B5 // OR L
            Fa = (c = Ff = Fr = c | hl & 255) | 256,
            Fb = 0
        },
        function () { // B6 // OR (HL)
            Fa = (c = Ff = Fr = c | t.get(hl)) | 256,
            Fb = 0,
            t.time += 3
        },
        function () { // B7 // OR A
            Fa = (Ff = Fr = c) | 256,
            Fb = 0
        },
        function () { // B8 // CP B
            cp(i)
        },
        function () { // B9 // CP C
            cp(j)
        },
        function () { // BA // CP D
            cp(k)
        },
        function () { // BB // CP E
            cp(l)
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
            cp(c)
        },
        function () { // C0 // RET NZ
            t.time++,
            Fr && ret()
        },
        function () { // C1 // POP BC
            var a = pop();
            i = a >> 8,
            j = a & 255
        },
        function () { // C2 // JP NZ
            jp(Fr)
        },
        function () { // C3 // JP nn
            E = pc = imm16()
        },
        function () { // C4 // CALL NZ
            callc(Fr)
        },
        function () { // C5 // PUSH BC
            push(i << 8 | j)
        },
        function () { // C6 // ADD A, n
            c = Fr = (Ff = (Fa = c) + (Fb = imm8())) & 255
        },
        function () { // C7 // RST 00
            push(pc),
            E = pc = 0
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
            E = pc = a
        },
        function () { // CE // ADC A, n
            c = Fr = (Ff = (Fa = c) + (Fb = imm8()) + (Ff >> 8 & 1)) & 255
        },
        function () { // CF // RST 08
            push(pc),
            E = pc = 8
        },
        function () { // D0 // RET NC
            t.time++,
            Ff & 256 || ret()
        },
        function () { // D1 // POP DE
            var a = pop();
            k = a >> 8,
            l = a & 255
        },
        function () { // D2 // JP NC
            jp(!(Ff & 256))
        },
        function () { // D3 // OUT (n), A
            var b = imm8() | c << 8;
            t.out(b, c),
            E = b + 1 & 255 | b & 65280,
            t.time += 4
        },
        function () { // D4 // CALL NC
            callc(!(Ff & 256))
        },
        function () { // D5 // PUSH DE
            push(k << 8 | l)
        },
        function () { // D6 // ADC A, n
            c = Fr = (Ff = (Fa = c) + (Fb = ~imm8()) + 1) & 255
        },
        function () { // D7 // RST 10
            push(pc),
            E = pc = 16
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
            var b = imm8() | c << 8;
            E = b + 1,
            c = t.inp(b),
            t.time += 4
        },
        function () { // DC // CALL C
            callc(Ff & 256)
        },
        function () { // DD // OP DD
            dd_fd(221)
        },
        function () { // DE // SBC A, n
            c = Fr = (Ff = (Fa = c) + (Fb = ~imm8()) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function () { // DF // RST 18
            push(pc),
            E = pc = 24
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
            E = pop(),
            push(hl),
            hl = E,
            t.time += 2
        },
        function () { // E4 // CALL PO
            callc(F() & 4 ^ 4)
        },
        function () { // E5 // PUSH HL
            push(hl)
        },
        function () { // E6 // AND A, n
            Fa = ~ (c = Ff = Fr = c & imm8()),
            Fb = 0
        },
        function () { // E7 // RST 20
            push(pc),
            E = pc = 32
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
            hl = k << 8 | l,
            k = a >> 8,
            l = a & 255
        },
        function () { // EC // CALL PE
            callc(F() & 4)
        },
        ed,           // ED // OP ED
        function () { // EE // XOR A, n
            Fa = (c = Ff = Fr = c ^ imm8()) | 256,
            Fb = 0
        },
        function () { // EF // RST 28
            push(pc),
            E = pc = 40
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
            push(c << 8 | F())
        },
        function () { // F6 // OR A, n
            Fa = (c = Ff = Fr = c | imm8()) | 256,
            Fb = 0
        },
        function () { // F7 // RST 30
            push(pc),
            E = pc = 48
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
            E = pc = 56
        }
    ],
    pref = [
        , , , , , , , , ,
        function (a) { // 09 // ADD XY, BC
            return add16(a, i << 8 | j)
        }, , , , , , , , , , , , , , , ,
        function (a) { // 19 // ADD XY, DE
            return add16(a, k << 8 | l)
        }, , , , , , , ,
        imm16,         // 21 // LDD XY, nn
        function (b) { // 22 // LD (nn), XY
            var c = imm16();
            t.put(c, b & 255),
            t.time += 3,
            t.put(E = c + 1 & 65535, b >> 8),
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
            var c = imm16();
            E = c + 1,
            b = t.get16(c),
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
            var c = getd(b),
                d = inc(t.get(c));
            t.time += 4,
            t.put(c, d),
            t.time += 3
        },
        function (b) { // 35 // DEC (XY+d)
            var c = getd(b),
                d = dec(t.get(c));
            t.time += 4,
            t.put(c, d),
            t.time += 3
        },
        function (b) { // 36 // LD (XY+d), n
            var c, d = getd(b);
            t.time += -5,
            c = imm8(),
            t.time += 2,
            t.put(d, c),
            t.time += 3
        }, , ,
        function (a) { // 39 // ADD XY, SP
            return add16(a, sp)
        }, , , , , , , , , , ,
        function (a) { // 44 // LD B, XYh
            i = a >> 8
        },
        function (a) { // 45 // LD B, XYl
            i = a & 255
        },
        function (a) { // 46 // LD B, (XY+d)
            i = getd3(a)
        }, , , , , ,
        function (a) { // 4C // LD C, XYh
            j = a >> 8
        },
        function (a) { // 4D // LD C, XYl
            j = a & 255
        },
        function (a) { // 4E // LD C, (XY+d)
            j = getd3(a)
        }, , , , , ,
        function (a) { // 54 // LD D, XYh
            k = a >> 8
        },
        function (a) { // 55 // LD D, XYl
            k = a & 255
        },
        function (a) { // 56 // LD D, (XY+d)
            k = getd3(a)
        }, , , , , ,
        function (a) { // 5C // LD E, XYh
            l = a >> 8
        },
        function (a) { // 5D // LD E, XYl
            l = a & 255
        },
        function (a) { // 5E // LD E, (XY+d)
            l = getd3(a)
        }, ,
        function (a) { // 60 // LD XYh, B
            return a & 255 | i << 8
        },
        function (a) { // 61 // LD XYh, C
            return a & 255 | j << 8
        },
        function (a) { // 62 // LD XYh, D
            return a & 255 | k << 8
        },
        function (a) { // 63 // LD XYh, E
            return a & 255 | l << 8
        }, ,
        function (a) { // 65 // LD XYh, XYl
            return a & 255 | (a & 255) << 8
        },
        function (a) { // 66 // LD H, (XY+d)
            hl = hl & 255 | getd3(a) << 8
        },
        function (b) { // 67 // LD XYh, A
            return b & 255 | c << 8
        },
        function (a) { // 68 // LD XYl, B
            return a & -256 | i
        },
        function (a) { // 69 // LD XYl, C
            return a & -256 | j
        },
        function (a) { // 6A // LD XYl, D
            return a & -256 | k
        },
        function (a) { // 6B // LD XYl, E
            return a & -256 | l
        },
        function (a) { // 6C // LD XYl, XYh
            return a & -256 | a >> 8
        }, ,
        function (a) { // 6E // LD L, (XY+d)
            hl = hl & -256 | getd3(a)
        },
        function (b) { // 6F // LD XYl, A
            return b & -256 | c
        },
        function (b) { // 70 // LD (XY+d), B
            t.put(getd(b), i),
            t.time += 3
        },
        function (b) { // 71 // LD (XY+d), C
            t.put(getd(b), j),
            t.time += 3
        },
        function (b) { // 72 // LD (XY+d), D
            t.put(getd(b), k),
            t.time += 3
        },
        function (b) { // 73 // LD (XY+d), E
            t.put(getd(b), l),
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
            t.put(getd(b), c),
            t.time += 3
        }, , , , ,
        function (b) { // 7C // LD A, XYh
            c = b >> 8
        },
        function (b) { // 7D // LD A, XYl
            c = b & 255
        },
        function (b) { // 7E // LD A, (XY+d)
            c = getd3(b)
        }, , , , , ,
        function (b) { // 84 // ADD A, XYh
            c = Fr = (Ff = (Fa = c) + (Fb = b >> 8)) & 255
        },
        function (b) { // 85 // ADD A, XYl
            c = Fr = (Ff = (Fa = c) + (Fb = b & 255)) & 255
        },
        function (b) { // 86 // ADD A, (XY+d)
            c = Fr = (Ff = (Fa = c) + (Fb = getd3(b))) & 255
        }, , , , , ,
        function (b) { // 8C // ADC A, XYh
            c = Fr = (Ff = (Fa = c) + (Fb = b >> 8) + (Ff >> 8 & 1)) & 255
        },
        function (b) { // 8D // ADC A, XYl
            c = Fr = (Ff = (Fa = c) + (Fb = b & 255) + (Ff >> 8 & 1)) & 255
        },
        function (b) { // 8E // ADC A, (XY+d)
            c = Fr = (Ff = (Fa = c) + (Fb = getd3(b)) + (Ff >> 8 & 1)) & 255
        }, , , , , ,
        function (b) { // 94 // SUB A, XYh
            c = Fr = (Ff = (Fa = c) + (Fb = ~ (b >> 8)) + 1) & 255
        },
        function (b) { // 95 // SUB A, XYl
            c = Fr = (Ff = (Fa = c) + (Fb = ~ (b & 255)) + 1) & 255
        },
        function (b) { // 96 // SUB A, (XY+d)
            c = Fr = (Ff = (Fa = c) + (Fb = ~getd3(b)) + 1) & 255
        }, , , , , ,
        function (b) { // 9C // SBC A, XYh
            c = Fr = (Ff = (Fa = c) + (Fb = ~ (b >> 8)) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function (b) { // 9D // SBC A, XYl
            c = Fr = (Ff = (Fa = c) + (Fb = ~ (b & 255)) + (Ff >> 8 & 1 ^ 1)) & 255
        },
        function (b) { // 9E // SBC A, (XY+d)
            c = Fr = (Ff = (Fa = c) + (Fb = ~getd3(b)) + (Ff >> 8 & 1 ^ 1)) & 255
        }, , , , , ,
        function (b) { // A4 // AND XYh
            Fa = ~ (c = Ff = Fr = c & b >> 8),
            Fb = 0
        },
        function (b) { // A5 // AND XYl
            Fa = ~ (c = Ff = Fr = c & b & 255),
            Fb = 0
        },
        function (b) { // A6 // AND (XY+d)
            Fa = ~ (c = Ff = Fr = c & getd3(b)),
            Fb = 0
        }, , , , , ,
        function (b) { // AC // XOR XYh
            Fa = (c = Ff = Fr = c ^ b >> 8) | 256,
            Fb = 0
        },
        function (b) { // AD // XOR XYl
            Fa = (c = Ff = Fr = c ^ b & 255) | 256,
            Fb = 0
        },
        function (b) { // AE // XOR (XY+d)
            Fa = (c = Ff = Fr = c ^ getd3(b)) | 256,
            Fb = 0
        }, , , , , ,
        function (b) { // B4 // OR XYh
            Fa = (c = Ff = Fr = c | b >> 8) | 256,
            Fb = 0
        },
        function (b) { // B5 // OR XYl
            Fa = (c = Ff = Fr = c | b & 255) | 256,
            Fb = 0
        },
        function (b) { // B6 // OR (XY+d)
            Fa = (c = Ff = Fr = c | getd3(b)) | 256,
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
            return  E = pop(),
                    push(b),
                    t.time += 2,
                    E
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
            i = in_()
        },
        function () { // 41 // OUT (C), B
            out(i)
        },
        function () { // 42 // SBC HL, BC
            adc_sbc_hl(~ (i << 8 | j), 1)
        },
        function () { // 43 // LD (nn), BC
            var b = imm16();
            t.put(b, j),
            t.time += 3,
            t.put(E = b + 1 & 65535, i),
            t.time += 3
        },            
        neg,          // 44 // NEG
        reti,         // 45 // RETN
        im0,          // 46 // IM 0
        function () { // 47 // LD I, A
            ir = ir & 255 | c << 8,
            t.time++
        },
        function () { // 48 // IN C, (C)
            j = in_()
        },
        function () { // 49 // OUT (C), C
            out(j)
        },
        function () { // 4A // ADC HL, BC
            adc_sbc_hl(i << 8 | j, 0)
        },
        function () { // 4B // LD BC, (nn)
            var b = imm16();
            E = b + 1,
            b = t.get16(b),
            i = b >> 8,
            j = b & 255,
            t.time += 6
        },
        neg,          // 4C // NEG
        reti,         // 4D // RETI
        im0,          // 4E // IM 0
        function () { // 4F // LD R, A
            ldrx(c),
            t.time++
        },
        function () { // 50 // IN D, (C)
            k = in_()
        },
        function () { // 51 // OUT (C), D
            out(k)
        },
        function () { // 52 // SBC HL, DE
            adc_sbc_hl(~ (k << 8 | l), 1)
        },
        function () { // 53 // LD (nn), DE
            var b = imm16();
            t.put(b, l),
            t.time += 3,
            t.put(E = b + 1 & 65535, k),
            t.time += 3
        },
        neg,          // 54 // NEG
        reti,         // 55 // RETN
        im1,          // 56 // IM 1
        function () { // 57 // LD A, I
            ldax(ir >> 8)
        },
        function () { // 58 // IN E, (C)
            l = in_()
        },
        function () { // 59 // OUT (C), E
            out(l)
        },
        function () { // 5A // ADC HL, DE
            adc_sbc_hl(k << 8 | l, 0)
        },
        function () { // 5B // LD DE, (nn)
            var b = imm16();
            E = b + 1,
            b = t.get16(b),
            k = b >> 8,
            l = b & 255,
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
            t.put(E = b + 1 & 65535, hl >> 8),
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
            E = b + 1,
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
            t.put(E = b + 1 & 65535, sp >> 8),
            t.time += 3
        },
        neg,          // 74 // NEG
        reti,         // 75 // RETN
        im1, ,        // 76 // IM 1
        function () { // 78 // IN A, (C)
            c = in_()
        },
        function () { // 79 // OUT (C), A
            out(c)
        },
        function () { // 7A // ADC HL, SP
            adc_sbc_hl(sp, 0)
        },
        function () { // 7B // LD SP, (nn)
            var b = imm16();
            E = b + 1,
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
            i = shifter(a, i)
        },
        function (a) {
            j = shifter(a, j)
        },
        function (a) {
            k = shifter(a, k)
        },
        function (a) {
            l = shifter(a, l)
        },
        function (a) {
            hl = hl & 255 | shifter(a, hl >> 8) << 8
        },
        function (a) {
            hl = hl & -256 | shifter(a, hl & 255)
        },
        function (b) {
            var c = shifter(b, t.get(hl));
            t.time += 4,
            t.put(hl, c),
            t.time += 3
        },
        function (b) {
            c = shifter(b, c)
        }
    ],
    bita = [
        function (a) {
            bit(a, i)
        },
        function (a) {
            bit(a, j)
        },
        function (a) {
            bit(a, k)
        },
        function (a) {
            bit(a, l)
        },
        function (a) {
            bit(a, hl >> 8)
        },
        function (a) {
            bit(a, hl & 255)
        },
        function (b) {
            bit(b, t.get(hl)),
            Ff = Ff & -41 | E >> 8 & 40,
            t.time += 4
        },
        function (b) {
            bit(b, c)
        }
    ],
    res = [
        function (a) {
            i &= ~a
        },
        function (a) {
            j &= ~a
        },
        function (a) {
            k &= ~a
        },
        function (a) {
            l &= ~a
        },
        function (a) {
            hl &= ~ (a << 8)
        },
        function (a) {
            hl &= ~a
        },
        function (b) {
            var c = t.get(hl) & ~b;
            t.time += 4,
            t.put(hl, c),
            t.time += 3
        },
        function (b) {
            c &= ~b
        }
    ],
    set = [
        function (a) {
            i |= a
        },
        function (a) {
            j |= a
        },
        function (a) {
            k |= a
        },
        function (a) {
            l |= a
        },
        function (a) {
            hl |= a << 8
        },
        function (a) {
            hl |= a
        },
        function (b) {
            var c = t.get(hl) | b;
            t.time += 4,
            t.put(hl, c),
            t.time += 3
        },
        function (b) {
            c |= b
        }
    ]
}