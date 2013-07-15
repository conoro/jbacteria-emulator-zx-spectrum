library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is port(
    clk   : in  std_logic;
    wr_n  : in  std_logic;
    addr  : in  std_logic_vector(14 downto 0);
    din   : in  std_logic_vector( 7 downto 0);
    dout  : out std_logic_vector( 7 downto 0));
end ram;

architecture behavioral of ram is

  type ram_t is array (0 to 32767) of std_logic_vector(7 downto 0);
  signal ram : ram_t := (others => (others => '0'));

begin

  process (clk)
  begin
    if(rising_edge(clk)) then
      if wr_n='0' then
        ram(to_integer(unsigned(addr))) <= din;
      end if;
      dout <= ram(to_integer(unsigned(addr)));
    end if; 
  end process;

end architecture;
