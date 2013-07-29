library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity zxmmc is port(
    clk     : in  std_logic;
    iorq_n  : in  std_logic;
    rd_n    : in  std_logic;
    wr_n    : in  std_logic;
    spidi   : in  std_logic;
    spics   : out std_logic;
    spiclk  : out std_logic;
    spido   : out std_logic;
    din     : in  std_logic_vector (7 downto 0);
    dout    : out std_logic_vector (7 downto 0);
    addr    : in  std_logic_vector (7 downto 0));
end zxmmc;

architecture behavioral of zxmmc is

  signal shift: std_logic_vector (7 downto 0);
  signal txreg: std_logic_vector (7 downto 0);
  signal txtmp: std_logic_vector (4 downto 0);
  signal count: std_logic_vector (1 downto 0);
  signal rxtmp: std_logic;

begin

  process(clk)
  begin
    if falling_edge(clk) then
      if wr_n = '1' or iorq_n = '1' then
        count <= "00";
      else
        count <= count+1;
        if count = 1 then
          if addr = X"1F" then
            spics <= din(0);
          elsif addr = X"3F" then
            txreg    <= din;
            txtmp(4) <= '1';
          end if;
        end if;
      end if;

      if rxtmp = '1' and txtmp = 0 then
        txtmp(4) <= '1';
      end if;

      if txtmp > 1 then
        if txtmp(0) = '0' then
          spido  <= txreg(7);
          spiclk <= '0';
          txreg  <= txreg(6 downto 0) & '1';
        else
          spiclk <= '1';
          shift (7 downto 0) <= (shift (6 downto 0) & spidi);
        end if;
        txtmp  <= txtmp-1;
      elsif txtmp = 1 then
        dout   <= shift (6 downto 0) & spidi;
        spiclk <= '1';
        txtmp  <= txtmp -1;
        rxtmp  <= '0';
      end if;   

      if iorq_n = '0' and rd_n = '0' and addr = X"3F" and rxtmp = '0' then
        rxtmp <= '1';
      end if;
    end if;
  end process;

end behavioral;
