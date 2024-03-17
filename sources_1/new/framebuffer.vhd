----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2024 04:16:15 PM
-- Design Name: 
-- Module Name: framebuffer - Behavioral
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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity framebuffer is port (
        clk1, en1, en2, ld   : in std_logic;
        addr1, addr2        : in std_logic_vector(11 downto 0);
        wr_en1              : in std_logic;
        din1                : in std_logic_vector(15 downto 0);
        dout1, dout2        : out std_logic_vector(15 downto 0)
 );
end framebuffer;
architecture Behavioral of framebuffer is
type frame_memory is array(4095 downto 0) of STD_LOGIC_VECTOR(15 downto 0);

signal framebuffer_memory : frame_memory := (others=>(others => '0')); 

begin

process(clk1) begin

    if rising_edge(clk1) and en1 = '1' then
        if wr_en1 = '1' then
            framebuffer_memory(to_integer(unsigned(addr1))) <= din1;
        end if;
        dout1  <= framebuffer_memory(to_integer(unsigned(addr1)));
    end if;
end process;

process(clk1) begin
    if rising_edge(clk1) and (en2 = '1') then
        dout2  <= framebuffer_memory(to_integer(unsigned(addr2)));
    end if;
end process;



end Behavioral;
