library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity main is port(
    clk       : in  std_logic
  ; sync      : out std_logic
  ; lowc      : out std_logic_vector (2 downto 0)
  ; color     : out std_logic_vector (5 downto 0)
);
end main;

architecture Behavioral of main is

  component clock7 is port(
      CLKIN_IN  : in  std_logic
    ; CLKFX_OUT : out std_logic
  );
  end component;
 
  signal  clk7      : std_logic;
  signal  hcount    : unsigned  (8 downto 0);
  signal  vcount    : unsigned  (8 downto 0);
  
begin

  clock7_inst: clock7 port map (
    clkin_in=>clk,
    clkfx_out=>clk7
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
      color <= "000000";
    else
      sync <= '1';
      if hcount>=320 and hcount<416 then
        color <= "000000";
      elsif hcount<256 and vcount<192 then
        color <=  std_logic_vector(hcount(7 downto 7))
                & std_logic_vector(hcount(6 downto 6))
                & std_logic_vector(hcount(7 downto 7))
                & std_logic_vector(hcount(5 downto 5))
                & std_logic_vector(hcount(7 downto 7))
                & std_logic_vector(hcount(4 downto 4));
      else
        color <= "010101";
      end if;
    end if;
  end process;

  lowc <= "000";

end Behavioral;