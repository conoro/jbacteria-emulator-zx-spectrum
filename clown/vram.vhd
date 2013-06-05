library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity vram is port(
    clk   : in  std_logic;
    rd    : in  std_logic;
    wr    : in  std_logic;
    addr  : in  std_logic_vector(13 downto 0);
    data  : inout std_logic_vector( 7 downto 0));
end vram;

architecture Behavioral of vram is

  type arrena is array(7 downto 0) of std_logic;
  type arrdoa is array(7 downto 0) of std_logic_vector(7 downto 0);
  signal ena : arrena;
  signal doa : arrdoa;

begin
  process(addr, doa)
  variable i : integer;
  begin
    for i in 0 to 7 loop
      ena(i) <= '0';
      if (rd and wr)='1' and to_integer(unsigned(addr(13 downto 11))) = i then
        ena(i) <= '1';
        if rd='1' then
          data <= doa(i);
        elsif wr='1' then
          doa(i) <= data;
        end if;
      end if;
    end loop;
  end process;

  ramb : for i in 0 to 7 generate
    ramb16_s9_inst : RAMB16_S9
    generic map (
      write_mode => "READ_FIRST")
    port map (
      do    => doa(i),
      addr  => addr(10 downto 0),
      clk   => clk,
      en    => ena(i),
      we    => wr,
      ssr   => '0');
  end generate;
end Behavioral;
