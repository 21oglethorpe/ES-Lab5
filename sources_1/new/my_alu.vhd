----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2021 07:25:21 PM
-- Design Name: 
-- Module Name: my_alu - Behavioral
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
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity my_alu is
port ( clk, en : in std_logic;
        A, B   : in std_logic_vector(15 downto 0);
        x : in std_logic_vector(3 downto 0);
        led : out std_logic_vector(15 downto 0));
end my_alu;

architecture Behavioral of my_alu is
begin
    process(clk)
    begin 
    if rising_edge(clk) then
    if en = '1' then
    case (x) is
        when "0000"  => led <= std_logic_vector(unsigned(A)+unsigned(B));
        when "0001"  => led <= std_logic_vector(unsigned(A)-unsigned(B));
        when "0010"  => led <= std_logic_vector(unsigned(A)+1);
        when "0011"  => led <= std_logic_vector(unsigned(A)-1);
        when "0100"  => led <= std_logic_vector(0-unsigned(A));
        when "0101"  => led <= std_logic_vector(unsigned(A) sll 1);
        when "0110"  => led <= std_logic_vector(unsigned(A) srl 1);
        when "0111"  => led <= to_stdlogicvector(to_bitvector(std_logic_vector(A)) sra 1);
        when "1000"  => led <= A AND B;
        when "1001"  => led <= A OR B;
        when "1010"  => led <= A XOR B; 
        when "1011"  => if unsigned (A) < unsigned (B) then led <= "0000000000000001"; else led <= "0000000000000000"; end if;
        when "1100"  => if unsigned (A) > unsigned (B) then led <= "0000000000000001"; else led <= "0000000000000000"; end if;
        when "1101"  => if A = B then led <= "0000000000000001"; else led <= "0000000000000000"; end if;
        when "1110"  => if A < B then led <= "0000000000000001"; else led <= "0000000000000000"; end if;
        when "1111"  => if A > B then led <= "0000000000000001"; else led <= "0000000000000000"; end if;
        when others => led <= "0000";
        end case;
        end if;
    end if;
end process;

end Behavioral;