library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lec9 is port(
    clk7    : in  std_logic;
    sync    : inout std_logic;
    grb     : out std_logic_vector (2 downto 0);
    i       : out std_logic;
    flashcs : inout std_logic;
    flashsi : out std_logic;
    clkps2  : inout std_logic;
    dataps2 : in  std_logic;
    audio   : out std_logic;
    ear     : in  std_logic;
    sa      : out std_logic_vector (17 downto 0);
    sd      : inout std_logic_vector (7 downto 0);
    scs     : out std_logic;
    soe     : out std_logic;
    swe     : out std_logic);
end lec9;

architecture behavioral of lec9 is

  signal  spiadr :            unsigned (18 downto 0);
  signal  hcount, vcount :    unsigned (8 downto 0);
  signal  ccount, flash :     unsigned (4 downto 0);
  signal  abus :              std_logic_vector (15 downto 0);
  signal  addrv :             std_logic_vector (14 downto 0);
  signal  spiwr :             std_logic_vector (12 downto 0);
  signal  at1, at2, da1, da2, spird, spirdd,
          dbus, vram, scrl:   std_logic_vector (7 downto 0);
  signal  kbcol :             std_logic_vector (4 downto 0);
  signal  p7FFD :             std_logic_vector (5 downto 0);
  signal  border :            std_logic_vector (2 downto 0);
  signal  vid, cbis1, cbis2, wrv_n, clkcpu,
          mreq_n, iorq_n, wr_n, rd_n, int_n, mcon : std_logic;

  component ram is port(
      clk   : in  std_logic;
      wr_n  : in  std_logic;
      addr  : in  std_logic_vector(14 downto 0);
      din   : in  std_logic_vector( 7 downto 0);
      dout  : out std_logic_vector( 7 downto 0));
  end component;

  component T80a is port(
      RESET_n : in std_logic;
      CLK_n   : in std_logic;
      WAIT_n  : in std_logic;
      INT_n   : in std_logic;
      NMI_n   : in std_logic;
      BUSRQ_n : in std_logic;
      M1_n    : out std_logic;
      MREQ_n  : out std_logic;
      IORQ_n  : out std_logic;
      RD_n    : out std_logic;
      WR_n    : out std_logic;
      RFSH_n  : out std_logic;
      HALT_n  : out std_logic;
      BUSAK_n : out std_logic;
      A       : out std_logic_vector(15 downto 0);
      D       : inout std_logic_vector(7 downto 0));
  end component;

  component ps2k is port(
      clk     : in  std_logic;
      ps2clk  : in  std_logic;
      ps2data : in  std_logic;
      rows    : in  std_logic_vector(7 downto 0);
      keyb    : out std_logic_vector(4 downto 0));
  end component;

begin

  ram_inst: ram port map (
    clk   => clk7,
    wr_n  => wrv_n,
    addr  => addrv,
    din   => dbus,
    dout  => vram);

  T80a_inst: T80a port map (
    RESET_n => flashcs,
    CLK_n   => clkcpu,
    WAIT_n  => '1',
    INT_n   => int_n,
    NMI_n   => '1',
    BUSRQ_n => '1',
    MREQ_n  => mreq_n,
    IORQ_n  => iorq_n,
    RD_n    => rd_n,
    WR_n    => wr_n,
    A       => abus,
    D       => dbus);

  ps2k_inst: ps2k port map (
    clk     => hcount(5),
    ps2clk  => clkps2,
    ps2data => dataps2,
    rows    => abus(15 downto 8),
    keyb    => kbcol);

  flashsi <= spiwr(12);

  process (clk7)
  begin
    if falling_edge( clk7 ) then
      if hcount=447 then
        hcount <= (others => '0');
        if vcount=311 then
          vcount <= (others => '0');
          flash <= flash + 1;
        else
          vcount <= vcount + 1;
        end if;
      else
        hcount <= hcount + 1;
      end if;

      int_n <= '1';
      if vcount=248 and hcount<32 then
        int_n <= '0';
      end if;

      da2 <= da2(6 downto 0) & '0';
      if hcount(2 downto 0)="010" then
        ccount <= hcount(7 downto 3);
        da2 <= da1;
      end if;

      if vid='0' then
        if (hcount(1) and (hcount(2) xor hcount(3)))='1' then
          da1 <= vram;
        end if;
        if (not hcount(1) and hcount(3))='1' then
          at1 <= vram;
        end if;
      end if;

      if hcount(2 downto 0)="010" then
        at2 <= at1;
      end if;

      if spiadr=X"8090" then
        spiwr <= "0000001100001";
      else
        spiwr <= spiwr(11 downto 0) & '0';
      end if;

      if spiadr(2 downto 0)="000" then
        spirdd <= spird;
      end if;

      cbis1 <= vid nor (hcount(3) and hcount(2));
    end if;

    if rising_edge( clk7 ) then
      flashcs <= '1';
      if spiadr < X"480B8" then
        spiadr <= spiadr + 1;
        spird  <= spird(6 downto 0) & dataps2;
        if spiadr > X"808B" then
          flashcs <= '0';
        end if;
      end if;

      clkcpu <= hcount(0) or (cbis1 and cbis2 and (mcon or not (iorq_n or abus(0))));
    end if;
  end process;

  process (hcount, vcount, scrl)
  begin
    sync <= '0';
    vid <= '1';
    if  (vcount-unsigned(scrl(6 downto 4))>=248 and vcount-unsigned(scrl(6 downto 4))<252) nor
        (hcount-unsigned(scrl(2 downto 0))>=344 and hcount-unsigned(scrl(2 downto 0))<376) then
      sync <= '1';
      if hcount<256 and vcount<192 then
        vid <= '0';
      end if;
    end if;
  end process;

  process (at2, da2(7), flash(4), sync, hcount)
  begin
    i <= '0';
    grb <= "000";
    if sync='1' and (hcount>=416 or hcount<320) then
      if    hcount>unsigned(scrl(2 downto 0))+unsigned'("01001")
        and vcount>unsigned(scrl(6 downto 4))
        and hcount+(scrl(3) & "000")-unsigned(scrl(2 downto 0))<268
        and vcount+(scrl(7) & "000")-unsigned(scrl(6 downto 4))<192 then
        i <= at2(6);
        if (da2(7) xor (at2(7) and flash(4)))='0' then
          grb <= at2(5 downto 3);
        else
          grb <= at2(2 downto 0);
        end if;
      else
        grb <= border;
      end if;
    end if;
  end process;

  process (hcount, vcount, ccount, abus, wr_n, mreq_n, p7FFD)
  begin
    if (vid or (hcount(3) xnor (hcount(2) and hcount(1))))='0' then
      wrv_n <= '1';
      if (hcount(1) and (hcount(2) xor hcount(3)))='1' then
        addrv <= p7FFD(3) & '0' & std_logic_vector(vcount(7 downto 6) & vcount(2 downto 0)
                  & vcount(5 downto 3) & ccount);
      else
        addrv <= p7FFD(3) & "0110" & std_logic_vector(vcount(7 downto 3) & ccount);
      end if;
    else
      wrv_n <= wr_n or mreq_n or not abus(14) or (abus(15) and not (p7FFD(2) and p7FFD(0)));
      addrv <= (abus(15) and p7FFD(2) and p7FFD(1) and p7FFD(0)) & abus(13 downto 0);
    end if;
  end process;

  process (rd_n, wr_n, mreq_n, iorq_n, abus, clk7, spiadr, p7FFD, mcon)
  begin
    dbus <= (others => 'Z');
    sd   <= (others => 'Z');
    scs  <= '1';
    soe  <= '1';
    swe  <= '1';
    if spiadr < X"480B8" then
      if spiadr(2 downto 1)="01" then
        scs <= '0';
        swe <= '0';
        sd <= spirdd;
      end if;
    else
      if rd_n='0' then
        if mreq_n='0' then
          if mcon='1' then
            dbus <= vram;
          else
            scs  <= '0';
            soe  <= '0';
            dbus <= sd;
          end if;
        elsif iorq_n='0' and abus(0)='0' then
          dbus <= '1' & ear & '1' & kbcol;
        end if;
      elsif wr_n='0' then
        if (mreq_n or not abus(15) or (abus(14) and p7FFD(2) and p7FFD(0)))='0' then
          scs <= '0';
          swe <= '0';
          sd  <= dbus;
        elsif rising_edge(clk7) and iorq_n='0' then
          if abus(0)='0' then
            border <= dbus(2 downto 0);
            audio  <= dbus(4);
          elsif (abus(1) or not abus(14) or abus(15) or p7FFD(5))='0' then
            p7FFD <= dbus(5 downto 0);
          elsif abus=X"7F3B" then
            scrl <= dbus;
          end if;
        end if;
      end if;
    end if;
  end process;

  process (clkcpu)
  begin
    if rising_edge( clkcpu ) then
      cbis2 <= (iorq_n or abus(0)) and mreq_n;
    end if;
  end process;

  process (clk7, spiadr)
  begin
    clkps2 <= 'Z';
    if spiadr>X"8064" and spiadr<X"8090" then
      clkps2 <= '1';
    elsif spiadr < X"480B8" then
      clkps2 <= clk7;
    end if;
  end process;

  process (abus(15), abus(14), spiadr, p7FFD)
  begin
    if spiadr < X"480B8" then
      sa <= "100" & std_logic_vector(spiadr(17 downto 3));
    else
      if abus(15)='0' then
        if abus(14)='0' then
          sa <= "100" & p7FFD(4) & abus(13 downto 0);
        end if;
      else
        if abus(14)='0' then
          sa <= "0010" & abus(13 downto 0);
        else
          sa <= '0' & p7FFD(2 downto 0) & abus(13 downto 0);
        end if;
      end if;
    end if;
  end process;

  process (abus, p7FFD)
  begin
    mcon <= abus(14) and (not abus(15) or (abus(15) and p7FFD(2) and p7FFD(0)));
  end process;

end architecture;
