library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity ay8910 is port(
    clk   : in  std_logic;
    clc   : in  std_logic;
    reset : in  std_logic;
    bdir  : in  std_logic;
    cs    : in  std_logic;
    bc    : in  std_logic;
    di    : in  std_logic_vector(7 downto 0);
    do    : out std_logic_vector(7 downto 0);
    outa  : out std_logic_vector(7 downto 0);
    outb  : out std_logic_vector(7 downto 0);
    outc  : out std_logic_vector(7 downto 0));
end ay8910;
 
architecture behavioral of ay8910 is

  signal clockdiv  : unsigned (3 downto 0);
  signal periodA   : std_logic_vector (11 downto 0);
  signal periodB   : std_logic_vector (11 downto 0);
  signal periodC   : std_logic_vector (11 downto 0);
  signal periodN   : std_logic_vector (4 downto 0);
  signal enable    : std_logic_vector (7 downto 0);
  signal volumeA   : std_logic_vector (4 downto 0);
  signal volumeB   : std_logic_vector (4 downto 0);
  signal volumeC   : std_logic_vector (4 downto 0);
  signal periodE   : std_logic_vector (15 downto 0);
  signal shape     : std_logic_vector (3 downto 0);
  signal portA     : std_logic_vector (7 downto 0);
  signal portB     : std_logic_vector (7 downto 0);
  signal address   : std_logic_vector (3 downto 0);
  signal resetReq  : std_logic;
  signal resetAck  : std_logic;
  signal volumeE   : std_logic_vector (3 downto 0);
  signal freqA     : std_logic;
  signal freqB     : std_logic;
  signal freqC     : std_logic;
  signal freqN     : std_logic;
  alias  continue  : std_logic is shape(3);
  alias  attack    : std_logic is shape(2);
  alias  alternate : std_logic is shape(1);
  alias  hold      : std_logic is shape(0);

  function VolumeTable (value : std_logic_vector(3 downto 0)) return std_logic_vector is
    variable result : std_logic_vector (7 downto 0);
  begin
    case value is
       when "1111"  => result := "11111111";
       when "1110"  => result := "10110100";
       when "1101"  => result := "01111111";
       when "1100"  => result := "01011010";
       when "1011"  => result := "00111111";
       when "1010"  => result := "00101101";
       when "1001"  => result := "00011111";
       when "1000"  => result := "00010110";
       when "0111"  => result := "00001111";
       when "0110"  => result := "00001011";
       when "0101"  => result := "00000111";
       when "0100"  => result := "00000101";
       when "0011"  => result := "00000011";
       when "0010"  => result := "00000010";
       when "0001"  => result := "00000001";
       when "0000"  => result := "00000000";
       when others => null;
    end case;
  return result;
  end VolumeTable;

begin

  process (reset , clk)
  begin
    if reset = '0' then
      address  <= "0000";
      periodA  <= "000000000000";
      periodB  <= "000000000000";
      periodC  <= "000000000000";
      periodN  <= "00000";
      enable   <= "00000000";
      volumeA  <= "00000";
      volumeB  <= "00000";
      volumeC  <= "00000";
      periodE  <= "0000000000000000";
      shape    <= "0000";
      portA    <= "00000000";
      portB    <= "00000000";
      resetReq <= '0';
    elsif rising_edge(clk) then
      if cs = '0' and bdir = '1' then
        if bc = '1' then
          address <= di (3 downto 0);
        else
          case address is
            when "0000" =>  periodA (7 downto 0)  <= di;
            when "0001" =>  periodA (11 downto 8) <= di (3 downto 0);
            when "0010" =>  periodB (7 downto 0)  <= di;
            when "0011" =>  periodB (11 downto 8) <= di (3 downto 0);
            when "0100" =>  periodC (7 downto 0)  <= di;
            when "0101" =>  periodC (11 downto 8) <= di (3 downto 0);
            when "0110" =>  periodN               <= di (4 downto 0);
            when "0111" =>  enable                <= di;
            when "1000" =>  volumeA               <= di (4 downto 0);
            when "1001" =>  volumeB               <= di (4 downto 0);
            when "1010" =>  volumeC               <= di (4 downto 0);
            when "1011" =>  periodE (7 downto 0)  <= di;
            when "1100" =>  periodE (15 downto 8) <= di;
            when "1101" =>  shape                 <= di (3 downto 0);
                            resetReq              <= not resetAck;
            when "1110" =>  portA                 <= di;
            when "1111" =>  portB                 <= di;
            when others =>  null;
          end case;
        end if;
      end if;
    end if;
  end process;

  DO <=          periodA (7 downto 0)   when address = "0000" and cs = '0' and bdir = '0' and bc = '1' else
        "0000" & periodA (11 downto 8)  when address = "0001" and cs = '0' and bdir = '0' and bc = '1' else
                 periodB (7 downto 0)   when address = "0010" and cs = '0' and bdir = '0' and bc = '1' else
        "0000" & periodB (11 downto 8)  when address = "0011" and cs = '0' and bdir = '0' and bc = '1' else
                 periodC (7 downto 0)   when address = "0100" and cs = '0' and bdir = '0' and bc = '1' else
        "0000" & periodC (11 downto 8)  when address = "0101" and cs = '0' and bdir = '0' and bc = '1' else
        "000"  & periodN                when address = "0110" and cs = '0' and bdir = '0' and bc = '1' else
                 enable                 when address = "0111" and cs = '0' and bdir = '0' and bc = '1' else
        "000"  & volumeA                when address = "1000" and cs = '0' and bdir = '0' and bc = '1' else
        "000"  & volumeB                when address = "1001" and cs = '0' and bdir = '0' and bc = '1' else
        "000"  & volumeC                when address = "1010" and cs = '0' and bdir = '0' and bc = '1' else
                 periodE (7 downto 0)   when address = "1011" and cs = '0' and bdir = '0' and bc = '1' else
                 periodE (15 downto 8)  when address = "1100" and cs = '0' and bdir = '0' and bc = '1' else
        "0000" & shape                  when address = "1101" and cs = '0' and bdir = '0' and bc = '1' else
        "11111111";

  process (reset, clk)
  begin
    if reset = '0' then
      clockdiv <= "0000";
    elsif rising_edge(clk) then
      if clc = '1' then
        clockdiv <= clockdiv - 1;
      end if;
    end if;
  end process;

  process (reset, clk)
    variable counterA : unsigned (11 downto 0);
    variable counterB : unsigned (11 downto 0);
    variable counterC : unsigned (11 downto 0);
  begin
    if reset = '0' then
      counterA   := "000000000000";
      counterB   := "000000000000";
      counterC   := "000000000000";
      freqA      <= '0';
      freqB      <= '0';
      freqC      <= '0';
    elsif rising_edge(clk) then
      if clockdiv(2 downto 0) = "000" and clc = '1' then
        if (counterA /= X"000") then
          counterA := counterA - 1;
        elsif (periodA /= X"000") then
          counterA := unsigned(periodA) - 1;
        end if;
        if (counterA = X"000") then
          freqA <= not freqA;
        end if;
        if (counterB /= X"000") then
          counterB := counterB - 1;
        elsif (periodB /= X"000") then
          counterB := unsigned(periodB) - 1;
        end if;
        if (counterB = X"000") then
          freqB <= not freqB;
        end if;
        if (counterC /= X"000") then
          counterC := counterC - 1;
        elsif (periodC /= X"000") then
          counterC := unsigned(periodC) - 1;
        end if;
        if (counterC = X"000") then
          freqC <= not freqC;
        end if;
      end if;
    end if;
  end process;

  process (reset, clk)
    variable noiseShift : unsigned (16 downto 0);
    variable counterN   : unsigned (4 downto 0);
  begin
    if reset = '0' then
      counterN   := "00000";
      noiseShift := "00000000000000001";
    elsif rising_edge(clk) then
      if clockdiv(2 downto 0) = "000" and clc = '1' then
        if (counterN /= "00000") then
          counterN := counterN - 1;
        elsif (periodN /= "00000") then
          counterN := unsigned(periodN) - 1;
        end if;
        if counterN = "00000" then
          noiseShift := (noiseShift(0) xor noiseShift(2)) & noiseShift(16 downto 1);
        end if;
        freqN <= noiseShift(0);
      end if;
    end if;
  end process;

  process (reset, clk)
    variable envCounter : unsigned(15 downto 0);
    variable envWave    : unsigned(4 downto 0);
  begin
    if reset = '0' then
      envCounter  := "0000000000000000";
      envWave     := "11111";
      volumeE    <= "0000";
      resetAck   <= '0';
    elsif rising_edge(clk) then
      if clockdiv = "0000" and clc = '1' then
        if (envCounter /= X"0000" and resetReq = resetAck) then 
          envCounter := envCounter - 1;
        elsif (periodE /= X"0000") then
          envCounter := unsigned(periodE) - 1;
        end if;
        if (resetReq /= resetAck) then
          envWave := (others => '1');
        elsif (envCounter = X"0000" and (envWave(4) = '1' or (hold = '0' and continue = '1'))) then
          envWave := envWave - 1;
        end if;
        for I in 3 downto 0 loop
          if (envWave(4) = '0' and continue = '0') then
             volumeE(I) <= '0';
          elsif (envWave(4) = '1' or (alternate xor hold) = '0') then
             volumeE(I) <= envWave(I) xor attack;
          else
            volumeE(I) <= envWave(I) xor attack xor '1';
          end if;
        end loop;
        resetAck <= resetReq;
      end if;
    end if;
  end process;

  process (reset, clk)
  begin
    if reset = '0' then
      outa <= "00000000";
      outb <= "00000000";
      outc <= "00000000";
    elsif rising_edge(clk) then
      if clc = '1' then
        if (((enable(0) or freqA) and (enable(3) or freqN)) = '0') then
          outa <= "00000000";
        elsif (volumeA(4) = '0') then
          outa <= VolumeTable(volumeA(3 downto 0));
        else
          outa <= VolumeTable(volumeE);
        end if;
        if (((enable(1) or freqB) and (enable(4) or freqN)) = '0') then
          outb <= "00000000";
        elsif (volumeB(4) = '0') then
          outb <= VolumeTable(volumeB(3 downto 0));
        else
          outb <= VolumeTable(volumeE);
        end if;
        if (((enable(2) or freqC) and (enable(5) or freqN)) = '0') then
          outc <= "00000000";
        elsif (volumeC(4) = '0') then
          outc <= VolumeTable(volumeC(3 downto 0));
        else
          outc <= VolumeTable(volumeE);
        end if;
      end if;
    end if;
  end process;

end architecture;