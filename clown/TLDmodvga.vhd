library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity TLDmodvga is port(
    clk     : in  std_logic;
    sync    : inout std_logic;
    rout    : out std_logic_vector (2 downto 0);
    gout    : out std_logic_vector (2 downto 0);
    bout    : out std_logic_vector (2 downto 0);
    flashcs : inout std_logic;
    flashsi : out std_logic;
    clkps2  : inout std_logic;
    dataps2 : in  std_logic;
    audio   : out std_logic;
    ear     : in  std_logic;
    sa      : out std_logic_vector (17 downto 0);
    sd      : inout std_logic_vector (7 downto 0);
    scs     : out std_logic;
    soe     : out std_logic;
    swe     : out std_logic);
end TLDmodvga;

architecture behavioral of TLDmodvga is

  signal  clk7      : std_logic;
  signal  clkfb_in  : std_logic;
  signal  clkfx_buf : std_logic;
  signal  clk0_buf  : std_logic;
  signal  gnd_bit   : std_logic;
  signal  grb       : std_logic_vector (2 downto 0);
  signal  i         : std_logic;

  component lec9 is port(
      clk7    : in  std_logic;
      grb     : out std_logic_vector (2 downto 0);
      i       : out std_logic;
      sync    : inout std_logic;
      flashcs : inout std_logic;
      flashsi : out std_logic;
      clkps2  : inout  std_logic;
      dataps2 : in std_logic;
      audio   : out std_logic;
      ear     : in  std_logic;
      sa      : out std_logic_vector (17 downto 0);
      sd      : inout std_logic_vector (7 downto 0);
      scs     : out std_logic;
      soe     : out std_logic;
      swe     : out std_logic);
  end component;

begin

  lec9_inst: lec9 port map (
    clk7    => clk7,
    grb     => grb,
    i       => i,
    sync    => sync,
    flashcs => flashcs,
    flashsi => flashsi,
    clkps2  => clkps2,
    dataps2 => dataps2,
    audio   => audio,
    ear     => ear,
    sa      => sa,
    sd      => sd,
    scs     => scs,
    soe     => soe,
    swe     => swe);

  rout <= grb(1) & (i and grb(1)) & grb(1);
  gout <= grb(2) & (i and grb(2)) & grb(2);
  bout <= grb(0) & (i and grb(0)) & grb(0);

  gnd_bit <= '0';
  clkfx_bufg_inst : bufg
    port map( i => clkfx_buf,
              o => clk7);
  clk0_bufg_inst : bufg
    port map( i => clk0_buf,
              o => clkfb_in);
  dcm_sp_inst : dcm_sp generic map (
    clk_feedback          => "1X",
    clkdv_divide          => 2.0,
    clkfx_divide          => 25,
    clkfx_multiply        => 7,
    clkin_divide_by_2     => false,
    clkin_period          => 20.0,
    clkout_phase_shift    => "NONE",
    deskew_adjust         => "SYSTEM_SYNCHRONOUS",
    dfs_frequency_mode    => "LOW",
    dll_frequency_mode    => "LOW",
    duty_cycle_correction => true,
    factory_jf            => x"C080",
    phase_shift           => 0,
    startup_wait          => false)
  port map(
    clkfb   => clkfb_in,
    clkin   => clk,
    dssen   => gnd_bit,
    psclk   => gnd_bit,
    psen    => gnd_bit,
    psincdec=> gnd_bit,
    rst     => gnd_bit,
    clkdv   => open,
    clkfx   => clkfx_buf,
    clkfx180=> open,
    clk0    => clk0_buf,
    clk2x   => open,
    clk2x180=> open,
    clk90   => open,
    clk180  => open,
    clk270  => open,
    locked  => open,
    psdone  => open,
    status  => open);

end architecture;
