library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync is
  port (
    clock_25MHz               : in std_logic;
    red_in, green_in, blue_in : in std_logic_vector(7 downto 0);
    horiz_sync_out            : out std_logic;
    vert_sync_out             : out std_logic;
    pixel_row, pixel_column   : out std_logic_vector(9 downto 0);
    VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of vga_sync is
  constant H_VISIBLE : integer := 640;
  constant H_FRONT   : integer := 16;
  constant H_SYNC    : integer := 96;
  constant H_BACK    : integer := 48;
  constant H_TOTAL   : integer := 800;

  constant V_VISIBLE : integer := 480;
  constant V_FRONT   : integer := 10;
  constant V_SYNC    : integer := 2;
  constant V_BACK    : integer := 33;
  constant V_TOTAL   : integer := 525;

  constant HS_START : integer := H_VISIBLE + H_FRONT; -- 656
  constant HS_END   : integer := HS_START + H_SYNC - 1; -- 751
  constant VS_START : integer := V_VISIBLE + V_FRONT; -- 490
  constant VS_END   : integer := VS_START + V_SYNC - 1; -- 491

  signal h_count                          : unsigned(9 downto 0) := (others => '0'); -- 0..799
  signal v_count                          : unsigned(9 downto 0) := (others => '0'); -- 0..524
  signal video_on_h, video_on_v, video_on : std_logic;
  signal hsync_n, vsync_n                 : std_logic;
begin
  -- horizontal/vertical counters
  process (clock_25MHz)
  begin
    if rising_edge(clock_25MHz) then
      if h_count = to_unsigned(H_TOTAL - 1, h_count'length) then
        h_count <= (others => '0');
        if v_count = to_unsigned(V_TOTAL - 1, v_count'length) then
          v_count <= (others => '0');
        else
          v_count <= v_count + 1;
        end if;
      else
        h_count <= h_count + 1;
      end if;
    end if;
  end process;

  -- syncs (active low)
  hsync_n <= '0' when (to_integer(h_count) >= HS_START and to_integer(h_count) <= HS_END) else
    '1';
  vsync_n <= '0' when (to_integer(v_count) >= VS_START and to_integer(v_count) <= VS_END) else
    '1';

  horiz_sync_out <= hsync_n;
  vert_sync_out  <= vsync_n;

  pixel_column <= std_logic_vector(v_count) when video_on = '1' else
    (others => '0');
  pixel_row <= std_logic_vector(h_count) when video_on = '1' else
    (others => '0');

  -- video enable
  video_on_h <= '1' when to_integer(h_count) < H_VISIBLE else
    '0';
  video_on_v <= '1' when to_integer(v_count) < V_VISIBLE else
    '0';
  video_on <= video_on_h and video_on_v;

  -- simple test pattern; black during blanking
  VGA_R <= red_in when video_on = '1' else
    (others => '0'); -- white image
  VGA_G <= green_in when video_on = '1' else
    (others => '0');
  VGA_B <= blue_in when video_on = '1' else
    (others => '0');
end architecture;
