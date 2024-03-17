LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity debounce is
port(clk, btn : in std_logic;
 dbnc : out std_logic := '0');
 end debounce;
architecture Behavioral of debounce is

  signal output_shift : std_logic;
  signal counter : std_logic_vector(23 downto 0);
begin
process(clk)
begin
if rising_edge(clk) then
    if (btn = '1') then
            counter <= std_logic_vector(unsigned(counter) + 1);
            if (unsigned(counter) > 2499999) then
                dbnc <= '1';
            end if;
    else
    counter <= (others => '0');
    dbnc <= '0';
    end if;
end if;
end process;
end Behavioral;