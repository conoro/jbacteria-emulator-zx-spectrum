LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

-- entity declaration for your testbench.Dont declare any ports here
ENTITY test_tb IS 
END test_tb;

ARCHITECTURE behavior OF test_tb IS
   -- Component Declaration for the Unit Under Test (UUT)
  component lec4 is port(
      clk7    : in  std_logic;
      reset   : in  std_logic;
      r       : out std_logic;
      g       : out std_logic;
      b       : out std_logic;
      i       : out std_logic;
      sync    : out std_logic;
      clkps2  : in  std_logic;
      dataps2 : in  std_logic);
  end component;

  signal  clk     : std_logic := '0';
  signal  reset   : std_logic := '0';
  signal  r       : std_logic;
  signal  g       : std_logic;
  signal  b       : std_logic;
  signal  i       : std_logic;
  signal  sync    : std_logic;
  signal  clkps2  : std_logic;
  signal  dataps2 : std_logic;

   constant clk_period : time := 1 ns;
BEGIN

  lec4_inst: lec4 port map (
    clk7    => clk,
    reset   => reset,
    r       => r,
    g       => g,
    b       => b,
    i       => i,
    sync    => sync,
    clkps2  => clkps2,
    dataps2 => dataps2);

   -- Clock process definitions( clock with 50% duty cycle is generated here.
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;
   -- Stimulus process
  stim_proc: process
   begin         
        reset <='0';
        wait for 7 ns;
        reset <='1';
        wait;
  end process;

END;