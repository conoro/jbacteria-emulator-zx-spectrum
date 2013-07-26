library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pwm is port (
    clk   : in  std_logic;
    din   : in  std_logic_vector (8 downto 0);
    dout  : out std_logic);
end pwm;

architecture behavioral of pwm is

    signal  accum : std_logic_vector(9 downto 0);

begin

  process(clk, din)
  begin
    if rising_edge(clk) then      
      accum <=  ("0" & accum(8 downto 0)) + ("0" & din);
    end if;
  end process;

  dout <= accum(9);

end behavioral;