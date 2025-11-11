library ieee;
use ieee.std_logic_1164.all;

entity FPGA_Console is
  port (
    CLOCK_50            : in std_logic;
    KEY                 : in std_logic_vector(3 downto 0); -- active-low
    LEDR                : out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS      : out std_logic;
    VGA_CLK             : out std_logic;
    VGA_R, VGA_G, VGA_B : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of FPGA_Console is
  signal clk_25MHz  : std_logic;
  signal pll_locked : std_logic;

  component pll_25MHz
    port (
      refclk   : in std_logic;
      rst      : in std_logic;
      outclk_0 : out std_logic;
      locked   : out std_logic
    );
  end component;
begin
  u_pll : pll_25MHz
  port map
  (
    refclk   => CLOCK_50,
    rst      => '0',
    outclk_0 => clk_25MHz,
    locked   => pll_locked
  );

  VGA_CLK <= clk_25MHz;

  vga_sync_i : entity work.vga_sync
    port map
    (
      clock_25Mhz    => clk_25MHz,
      horiz_sync_out => VGA_HS, -- active-low
      vert_sync_out  => VGA_VS, -- active-low
      VGA_R          => VGA_R, -- we drive red here
      VGA_G          => VGA_G,
      VGA_B          => VGA_B
    );

  -- Buttons are active-low
  LEDR <= "00000001" when KEY(0) = '0' else
  "00000000";
--   VGA_R <= (others => '1') when KEY(1) = '0' else
--   (others          => '0');

  -- optional: show PLL lock on LEDR(7)
  -- LEDR(7) <= pll_locked;
end architecture;
