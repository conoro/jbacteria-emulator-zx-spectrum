library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2k is port (
    clk     : in  std_logic;
    ps2clk  : in  std_logic;
    ps2data : in  std_logic;
    rows    : in  std_logic_vector(7 downto 0);
    keyb    : out std_logic_vector(4 downto 0));
end ps2k;

architecture behavioral of ps2k is

  type    key_matrix  is array (7 downto 0) of std_logic_vector(4 downto 0);
  signal  keys      : key_matrix;
  signal  release   : std_logic;
  signal  extended  : std_logic;
  signal  lastclk   : std_logic;
  signal  bit_count : unsigned (3 downto 0);
  signal  shiftreg  : std_logic_vector(8 downto 0);
  signal  parity    : std_logic;

begin

  process (clk)
  begin
    if rising_edge(clk) then
      lastclk <= ps2clk;
      if ps2clk='0' and lastclk='1' then
        if bit_count=0 then
          parity <= '0';
          if ps2data='0' then
            bit_count <= bit_count + 1;
          end if;
        else
          if bit_count<10 then
            bit_count <= bit_count + 1;
            shiftreg  <= ps2data & shiftreg(8 downto 1);
            parity    <= parity xor ps2data;
          elsif ps2data='1' then
            bit_count <= (others => '0');
            if parity = '1' then
              release  <= '1';
              extended <= '0';
              case shiftreg(7 downto 0) is
                when X"e0" => extended   <= '1';
                when X"f0" => release    <= '0';
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
                when X"6B" => keys(0)(0) <= release; -- Left (Caps 5)
                              keys(3)(4) <= release;
                when X"72" => keys(0)(0) <= release; -- Down (Caps 6)
                              keys(4)(4) <= release;
                when X"75" => keys(0)(0) <= release; -- Up (Caps 7)
                              keys(4)(3) <= release;
                when X"74" => keys(0)(0) <= release; -- Right (Caps 8)
                              keys(4)(2) <= release;
                when X"66" => keys(0)(0) <= release; -- Backspace (Caps 0)
                              keys(4)(0) <= release;
                when X"58" => keys(0)(0) <= release; -- Caps lock (Caps 2)
                              keys(3)(1) <= release;
                when X"76" => keys(0)(0) <= release; -- Break (Caps Space)
                              keys(7)(0) <= release;
                when others=> null;
              end case;
            end if;
          else
            bit_count <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process;

  process (keys, rows)
  variable tmp: std_logic;
  begin
    for i in 0 to 4 loop
      tmp:= '0';
      for j in 0 to 7 loop
        tmp:= tmp or (keys(j)(i) and not rows(j));
      end loop;
      keyb(i) <=  not tmp;
    end loop;
  end process;

end architecture;
