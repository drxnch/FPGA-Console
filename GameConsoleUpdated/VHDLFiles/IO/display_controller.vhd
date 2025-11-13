library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity display_controller is
  port (
    clk                          : in std_logic;
    bird_on                      : in std_logic;
    rgb_bird                     : in std_logic_vector(23 downto 0);
    pixel_row, pixel_column      : in std_logic_vector(9 downto 0);
    red_out, green_out, blue_out : out std_logic_vector(7 downto 0)
  );
end entity display_controller;

architecture behaviour of display_controller is

begin
  process (clk)
  begin
    if (bird_on = '1') then
      red_out   <= rgb_bird(23 downto 16);
      green_out <= rgb_bird(15 downto 8);
      blue_out  <= rgb_bird(7 downto 0);
    else -- background
      red_out   <= "01100000";
      green_out <= "10110000";
      blue_out  <= "11110000";
    end if;
end process;

end architecture behaviour;