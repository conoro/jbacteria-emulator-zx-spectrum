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

begin
  clock7_inst: clock7 port map (
    clkin_in  => clk,
    clkfx_out => clk7);

  colenc_inst: colenc port map (
    col_in => color,
    r_out  => r,
    g_out  => g,
    b_out  => b);

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
      if vcount=312 then
        vcount <= (others => '0');
      else
        vcount <= vcount + 1;
      end if;
    end if;
  end process;

  process (hcount, vcount)
  begin
    if  (vcount>=248 and vcount<252) or
        (hcount>=344 and hcount<376) then
      sync <= '0';
      color <= "0000";
    else
      sync <= '1';
      if hcount>=320 and hcount<416 then
        color <= "0000";
      elsif hcount<256 and vcount<192 then
        color <=  std_logic_vector(hcount(7 downto 4));
      else
        color <= "0111";
      end if;
    end if;
  end process;
end behavioral;