library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is port(
    clk   : in  std_logic;
    sync  : out std_logic;
    r     : out std_logic_vector (2 downto 0);
    g     : out std_logic_vector (2 downto 0);
    b     : out std_logic_vector (2 downto 0));
end main;

architecture behavioral of main is

  signal  clk7    : std_logic;
  signal  hcount  : unsigned  (8 downto 0);
  signal  vcount  : unsigned  (8 downto 0);
  signal  color   : std_logic_vector (3 downto 0);
  signal  vid     : std_logic;
  signal  viddel  : std_logic;
  signal  at2clk  : std_logic;
  signal  al1     : std_logic;
  signal  al2     : std_logic;
  signal  ccount  : unsigned  (4 downto 0);
  signal  flash   : unsigned  (4 downto 0);
  signal  at1     : std_logic_vector (7 downto 0);
  signal  at2     : std_logic_vector (7 downto 0);
  signal  da1     : std_logic_vector (7 downto 0);
  signal  da2     : std_logic_vector (7 downto 0);
  signal  addrv   : std_logic_vector (12 downto 0);
  signal  datav   : std_logic_vector (7 downto 0);
  signal  gencol  : std_logic_vector (2 downto 0);
  signal  abus    : std_logic_vector (15 downto 0);
  signal  dbus    : std_logic_vector (7 downto 0);
  signal  mreq_n  : std_logic;
  signal  iorq_n  : std_logic;
  signal  wr_n    : std_logic;
  signal  rd_n    : std_logic;
  signal  rfsh_n  : std_logic;
  signal  int_n   : std_logic;
  signal  m1_n    : std_logic;

  component clock7 is port(
      clkin_in  : in  std_logic;
      clkfx_out : out std_logic);
  end component;

  component colenc is port(
      col_in  : in  std_logic_vector (3 downto 0);
      r_out   : out std_logic_vector (2 downto 0);
      g_out   : out std_logic_vector (2 downto 0);
      b_out   : out std_logic_vector (2 downto 0));
  end component;

  component vram is port(
      clk   : in  std_logic;
      rd    : in  std_logic;
      wr    : in  std_logic;
      addr  : in  std_logic_vector(13 downto 0);
      data  : inout std_logic_vector(7 downto 0));
  end component;

  component rom is port(
      clk     : in  std_logic;
      en      : in  std_logic;
      addr    : in  std_logic_vector(13 downto 0);
      dataout : out std_logic_vector(7 downto 0));
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

begin
  clock7_inst: clock7 port map (
    clkin_in  => clk,
    clkfx_out => clk7);

  colenc_inst: colenc port map (
    col_in => color,
    r_out  => r,
    g_out  => g,
    b_out  => b);

  vram_inst: vram port map (
    clk   => clk,
    rd    => rdv,
    wr    => wrv,
    addr  => addrv,
    data  => datav);

  rom_inst: rom port map (
    clk     => clk,
    en      => romcs,
    addr    => abus(13 downto 0),
    dataout => doutrom);

  T80a_inst: T80a port map (
    RESET_n => '1',
    CLK_n   => not clk7,
    WAIT_n  => '1',
    INT_n   => int_n,
    NMI_n   => '1',
    BUSRQ_n => '1',
    M1_n    => m1_n,
    MREQ_n  => mreq_n,
    IORQ_n  => iorq_n,
    RD_n    => rd_n,
    WR_n    => wr_n,
    RFSH_n  => rfsh_n,
--    HALT_n  =>
--    BUSAK_n =>
    A       => abus,
    D       => dbus);

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
      da2 <= da2(6 downto 0) & '0';
      if at2clk='0' then
        ccount <= hcount(7 downto 3);
        if viddel='0' then
          da2 <= da1;
        end if;
      end if;
    end if;
    if rising_edge( clk7 ) then
      if hcount(3)='1' then
        viddel <= vid;
      end if;
    end if;
  end process;

  process (al1)
  begin
    if rising_edge( al1 ) then
      da1 <= vd;
    end if;
  end process;

  process (al2)
  begin
    if rising_edge( al2 ) then
      at1 <= vd;
    end if;
  end process;

  process (at2clk)
  begin
    if rising_edge( at2clk ) then
      if( viddel='0' ) then
        at2 <= at1;
      else
        at2 <= "00000000";
      end if;
    end if;
  end process;

  process (hcount, vcount, gencol, at2(6))
  begin
    color <= "0000";
    vid   <= '1';
    if  (vcount>=248 and vcount<252) or
        (hcount>=344 and hcount<376) then
      sync <= '0';
    else
      sync <= '1';
      if hcount>=416 or hcount<320 then
        color <= at2(6) & gencol;
        if hcount<256 and vcount<192 then
          vid <= '0';
        end if;
      end if;
    end if;
  end process;

  process (hcount)
  begin
    al1 <= '1';
    al2 <= '1';
    if hcount(3 downto 1)=3 or hcount(3 downto 1)=5 then
      al1 <= '0';
    end if;
    if hcount(3 downto 1)=4 or hcount(3 downto 1)=6 then
      al2 <= '0';
    end if;
  end process;

  process (al1, vcount, ccount)
  begin
    if al1='0' then
      addrv <= std_logic_vector(vcount(7 downto 6) & vcount(2 downto 0)
                & vcount(5 downto 3) & ccount);
    else
      addrv <= "110" & std_logic_vector(vcount(7 downto 3) & ccount);
    end if;
  end process;

  process (flash(4), at2, da2(7))
  begin
    if (da2(7) xor (at2(7) and flash(4)))='0' then
      gencol <= at2(5 downto 3);
    else
      gencol <= at2(2 downto 0);
    end if;
  end process;

  process (clk7, hcount)
  begin
    at2clk <= not clk7 or hcount(0) or not hcount(1) or hcount(2);
  end process;
end behavioral;