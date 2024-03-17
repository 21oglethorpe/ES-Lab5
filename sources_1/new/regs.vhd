----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2024 03:58:11 PM
-- Design Name: 
-- Module Name: regs - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity regs is port (
    clk, en, rst    : in std_logic;
    id1, id2        : in std_logic_vector(4 downto 0);
    wr_en1, wr_en2  : in std_logic;
    din1, din2      : in std_logic_vector(15 downto 0);
    dout1, dout2    : out std_logic_vector(15 downto 0)
);
end regs;

architecture Behavioral of regs is
type fullmemory is array (0 to 31) of std_logic_vector (15 downto 0);
signal regs: fullmemory := (others => x"0000");

begin
dout1 <= regs (to_integer(unsigned(id1)));
dout2 <= regs(to_integer(unsigned(id2)));
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                regs <= (others => x"0000");
            elsif en = '1' then
                if wr_en1 = '1' then
                    regs (to_integer(unsigned(id1))) <= din1;
                end if;
                if wr_en2 = '1' then
                    regs (to_integer(unsigned(id2))) <= din2;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
