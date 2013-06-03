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
  signal  bordern : std_logic;
  signal  viden   : std_logic;
  signal  at2clk  : std_logic;
  signal  outl    : std_logic;
  signal  al1     : std_logic;
  signal  al2     : std_logic;
  signal  hcount  : unsigned  (8 downto 0):= "000000000";
  signal  vcount  : unsigned  (8 downto 0):= "000000000";
  signal  ccount  : unsigned  (6 downto 0):= "0000000";
  signal  flash   : unsigned  (4 downto 0):= "00000";
  signal  at1     : std_logic_vector (7 downto 0);
  signal  at2     : std_logic_vector (7 downto 0);
  signal  da1     : std_logic_vector (7 downto 0);
  signal  da2     : std_logic_vector (7 downto 0);
  signal  addrv   : std_logic_vector(13 downto 0);
  signal  vd      : std_logic_vector (7 downto 0);
  signal  color   : std_logic_vector (3 downto 0);
  signal  gencol  : std_logic_vector (3 downto 0);

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
      clk     : in  std_logic
    ; rd      : in  std_logic
    ; wr      : in  std_logic
    ; addr    : in  std_logic_vector(13 downto 0)
    ; dataout : out std_logic_vector( 7 downto 0)
  );
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

  video_ram: vram port map (
      clk => clk
    , rd  => '1'
    , wr  => '0'
    , addr    => addrv
    , dataout => vd
  );

  process (clk7)
  begin
    if falling_edge( clk7 ) then
      if hcount=447 then
        hcount <= (others => '0');
      else
        hcount <= hcount + 1;
      end if;
    end if;
    if falling_edge( clk7 ) and hcount=447 then
      if vcount=311 then
        vcount <= (others => '0');
        flash <= flash + 1;
      else
        vcount <= vcount + 1;
      end if;
    end if;
    if falling_edge( clk7 ) then
      if outl='0' then
        da2 <= da1;
      else
        da2 <= da2(6 downto 0) & '1';
      end if;
    end if;
    if rising_edge( clk7 ) then
      if hcount(3)='1' then
        viden <= not bordern;
      end if;
    end if;
  end process;

  process (hcount, vcount, gencol)
  begin
    color   <= "0000";
    bordern <= '0';
    if  (vcount>=248 and vcount<252) or
        (hcount>=344 and hcount<376) then
      sync <= '0';
    else
      sync <= '1';
      if hcount>=416 or hcount<310 then
        color <= gencol;
        if hcount<256 and vcount<192 then
          bordern <= '1';
        end if;
      end if;
    end if;
  end process;

  process (clk7, hcount)
  begin
    at2clk <= not clk7 or hcount(0) or not hcount(1) or hcount(2);
  end process;

  process (at2clk, viden)
  begin
    outl <= at2clk or viden;
  end process;

  process (at2clk)
  begin
    if falling_edge( at2clk ) then
      ccount <= vcount(1 downto 0) & hcount(7 downto 3);
    end if;
  end process;

  process (hcount)
  begin
    if hcount(3 downto 1)=3 or hcount(3 downto 1)=5 then
      al1 <= '0';
    else
      al1 <= '1';
    end if;
    if hcount(3 downto 1)=4 or hcount(3 downto 1)=6 then
      al2 <= '0';
    else
      al2 <= '1';
    end if;
  end process;

  process (al1, vcount, ccount)
  begin
    if al1='0' then
      addrv <= '0' & std_logic_vector(vcount(7 downto 6) & vcount(2) & ccount(6 downto 5)
                & vcount(5 downto 3) & ccount(4 downto 0));
    else
      addrv <= "0110" & std_logic_vector(vcount(7 downto 3) & ccount(4 downto 0));
    end if;
  end process;

  process (al1, vd)
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
      if( viden='0' ) then
        at2 <= at1;
      else
        at2 <= "00111000";
--        at2 <= "00" & border & "000";
      end if;
    end if;
  end process;

  process (flash(4), at2, da2(7))
  begin
    if (da2(7) xor (at2(7) and flash(4)))='0' then
      gencol <= at2(6 downto 3);
    else
      gencol <= at2(6) & at2(2 downto 0);
    end if;
  end process;


end behavioral;