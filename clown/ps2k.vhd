library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2k is port (
    clk     : in  std_logic;
    nreset  : in  std_logic;
    ps2clk  : in  std_logic;
    ps2data : in  std_logic;
    a       : in  std_logic_vector(15 downto 0);
    keyb    : out std_logic_vector(4 downto 0));
end ps2k;

architecture rtl of ps2k is

  type key_matrix is array (7 downto 0) of std_logic_vector(4 downto 0);
  signal keyb_data  : std_logic_vector(7 downto 0);
  signal keyb_valid : std_logic;
  signal keyb_error : std_logic;
  signal keys       : key_matrix;
  signal release    : std_logic;
  signal extended   : std_logic;

  component ps2_intf is
  generic (filter_length : positive := 8);
  port(
      clk     : in  std_logic;
      nreset  : in  std_logic;
      ps2clk  : in  std_logic;
      ps2data : in  std_logic;
      data    : out std_logic_vector(7 downto 0);
      valid   : out std_logic;
      error   : out std_logic);
  end component;

begin

  ps2 : ps2_intf port map (
    clk         => clk,
    nreset      => nreset,
    ps2clk      => ps2clk,
    ps2data     => ps2data,
    data        => keyb_data,
    valid       => keyb_valid,
    error       => keyb_error);

  keyb <= keys(0) when A(8) = '0' else
          keys(1) when A(9) = '0' else
          keys(2) when A(10) = '0' else
          keys(3) when A(11) = '0' else
          keys(4) when A(12) = '0' else
          keys(5) when A(13) = '0' else
          keys(6) when A(14) = '0' else
          keys(7) when A(15) = '0' else
          (others => '1');

  process (nreset, clk)
  begin
    if nreset='0' then
      release  <= '0';
      extended <= '0';
      keys(0) <= (others => '1');
      keys(1) <= (others => '1');
      keys(2) <= (others => '1');
      keys(3) <= (others => '1');
      keys(4) <= (others => '1');
      keys(5) <= (others => '1');
      keys(6) <= (others => '1');
      keys(7) <= (others => '1');
    elsif rising_edge(CLK) then
      if keyb_valid = '1' then
        if keyb_data = X"e0" then
          extended <= '1';
        elsif keyb_data = X"f0" then
          release <= '1';
        else
          release  <= '0';
          extended <= '0';
          case keyb_data is
            when X"12" => keys(0)(0) <= release; -- Left shift (CAPS SHIFT)
            when X"59" => keys(0)(0) <= release; -- Right shift (CAPS SHIFT)
            when X"1a" => keys(0)(1) <= release; -- Z
            when X"22" => keys(0)(2) <= release; -- X
            when X"21" => keys(0)(3) <= release; -- C
            when X"2a" => keys(0)(4) <= release; -- V
            when X"1c" => keys(1)(0) <= release; -- A
            when X"1b" => keys(1)(1) <= release; -- S
            when X"23" => keys(1)(2) <= release; -- D
            when X"2b" => keys(1)(3) <= release; -- F
            when X"34" => keys(1)(4) <= release; -- G
            when X"15" => keys(2)(0) <= release; -- Q
            when X"1d" => keys(2)(1) <= release; -- W
            when X"24" => keys(2)(2) <= release; -- E
            when X"2d" => keys(2)(3) <= release; -- R
            when X"2c" => keys(2)(4) <= release; -- T
            when X"16" => keys(3)(0) <= release; -- 1
            when X"1e" => keys(3)(1) <= release; -- 2
            when X"26" => keys(3)(2) <= release; -- 3
            when X"25" => keys(3)(3) <= release; -- 4
            when X"2e" => keys(3)(4) <= release; -- 5			
            when X"45" => keys(4)(0) <= release; -- 0
            when X"46" => keys(4)(1) <= release; -- 9
            when X"3e" => keys(4)(2) <= release; -- 8
            when X"3d" => keys(4)(3) <= release; -- 7
            when X"36" => keys(4)(4) <= release; -- 6
            when X"4d" => keys(5)(0) <= release; -- P
            when X"44" => keys(5)(1) <= release; -- O
            when X"43" => keys(5)(2) <= release; -- I
            when X"3c" => keys(5)(3) <= release; -- U
            when X"35" => keys(5)(4) <= release; -- Y
            when X"5a" => keys(6)(0) <= release; -- ENTER
            when X"4b" => keys(6)(1) <= release; -- L
            when X"42" => keys(6)(2) <= release; -- K
            when X"3b" => keys(6)(3) <= release; -- J
            when X"33" => keys(6)(4) <= release; -- H
            when X"29" => keys(7)(0) <= release; -- SPACE
            when X"14" => keys(7)(1) <= release; -- CTRL (Symbol Shift)
            when X"3a" => keys(7)(2) <= release; -- M
            when X"31" => keys(7)(3) <= release; -- N
            when X"32" => keys(7)(4) <= release; -- B
            when X"6B" => keys(0)(0) <= release; -- Left (CAPS 5)
                          keys(3)(4) <= release;
            when X"72" => keys(0)(0) <= release; -- Down (CAPS 6)
                          keys(4)(4) <= release;
            when X"75" => keys(0)(0) <= release; -- Up (CAPS 7)
                          keys(4)(3) <= release;
            when X"74" => keys(0)(0) <= release; -- Right (CAPS 8)
                          keys(4)(2) <= release;
            when X"66" => keys(0)(0) <= release; -- Backspace (CAPS 0)
                          keys(4)(0) <= release;
            when X"58" => keys(0)(0) <= release; -- Caps lock (CAPS 2)
                          keys(3)(1) <= release;
            when X"76" => keys(0)(0) <= release; -- Escape (CAPS SPACE)
                          keys(7)(0) <= release;
            when others=> null;
          end case;
        end if;
      end if;
    end if;
  end process;
end architecture;
