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

  -- output wiring
  signal red_disp_to_vga, green_disp_to_vga, blue_disp_to_vga : std_logic_vector(7 downto 0);
  signal pixel_row, pixel_col                                 : std_logic_vector(9 downto 0);

  --flappy bird logic
  signal sig_bird_on  : std_logic;
  signal sig_rgb_bird : std_logic_vector(23 downto 0);

  component pll_25MHz_exact
    port (
      refclk   : in std_logic;
      rst      : in std_logic;
      outclk_0 : out std_logic;
      locked   : out std_logic
    );
  end component;
begin
  u_pll : pll_25MHz_exact
  port map
  (
    refclk   => CLOCK_50,
    rst      => '0',
    outclk_0 => clk_25MHz,
    locked   => pll_locked
  );

  VGA_CLK <= clk_25MHz;

  vga_output : entity work.vga_sync
    port map
    (
      clock_25Mhz    => clk_25MHz,
      red_in         => red_disp_to_vga,
      green_in       => green_disp_to_vga,
      blue_in        => blue_disp_to_vga,
      horiz_sync_out => VGA_HS,
      vert_sync_out  => VGA_VS,
      pixel_row      => pixel_row,
      pixel_column   => pixel_col,
      VGA_R          => VGA_R,
      VGA_G          => VGA_G,
      VGA_B          => VGA_B
    );

  disp_controller : entity work.display_controller
    port map
    (
      clk          => clk_25MHz,
      bird_on      => sig_bird_on,
      rgb_bird     => sig_rgb_bird,
      pixel_row    => pixel_row,
      pixel_column => pixel_col,
      red_out      => red_disp_to_vga,
      green_out    => green_disp_to_vga,
      blue_out     => blue_disp_to_vga
    );

  flappy_bird : entity work.bird
    port map
    (
      clk          => clk_25MHz,
      click        => not KEY(3),
      pixel_row    => pixel_row,
      pixel_column => pixel_col,
      bird_on      => sig_bird_on,
      rgb_bird     => sig_rgb_bird
    );

  LEDR <= "00000001" when KEY(0) = '0' else
    "00000000"; -- To make sure everything is working fine
end architecture;
