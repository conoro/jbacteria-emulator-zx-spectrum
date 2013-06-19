library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ps2_intf is
generic (filter_length : positive := 8);
port(
    clk     : in  std_logic;
    nreset  : in  std_logic;
    ps2clk  : in  std_logic;
    ps2data : in  std_logic;
    data    : out std_logic_vector(7 downto 0);
    valid   : out std_logic;
    error   : out std_logic);
end ps2_intf;

architecture behavioral of ps2_intf is

  subtype filter_t is std_logic_vector(filter_length-1 downto 0);
  signal  clkfilter  : filter_t;
  signal  ps2clkin  : std_logic;
  signal  ps2datin  : std_logic;
  signal  clk_edge  : std_logic;
  signal  bit_count : unsigned (3 downto 0);
  signal  shiftreg  : std_logic_vector(8 downto 0);
  signal  parity    : std_logic;

begin
  process (nreset, clk)
  begin
    if nreset='0' then
      bit_count <= (others => '0');
      shiftreg  <= (others => '0');
      parity    <= '0';
      data      <= (others => '0');
      valid     <= '0';
      error     <= '0';
      ps2clkin  <= '1';
      ps2datin  <= '1';
      clkfilter <= (others => '1');
      clk_edge  <= '0';
    elsif rising_edge(clk) then
      ps2datin  <= ps2data;
      clkfilter <= ps2clk & clkfilter(clkfilter'high downto 1);
      clk_edge  <= '0';
      valid     <= '0';
      error     <= '0';
      if clkfilter = filter_t'(filter_length-1 downto 0 => '1') then
        ps2clkin <= '1';
      elsif clkfilter=filter_t'(filter_length-1 downto 0 => '0') and ps2clkin = '1' then
        clk_edge <= '1';
        ps2clkin <= '0';
      end if;
      if clk_edge='1' then
        if bit_count=0 then
          parity <= '0';
          if ps2datin='0' then
            bit_count <= bit_count + 1;
          end if;
        else
          if bit_count<10 then
            bit_count <= bit_count + 1;
            shiftreg  <= ps2datin & shiftreg(shiftreg'high downto 1);
            parity    <= parity xor ps2datin;
          elsif ps2datin='1' then
            bit_count <= (others => '0');
            if parity = '1' then
              data  <= shiftreg(7 downto 0);
              valid <= '1';
            else
              error <= '1';
            end if;
          else
            bit_count <= (others => '0');
            error     <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;
end behavioral;
