

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity pixel_pusher is
Port (  clk, en, VS, vid: in std_logic;
	pixel : in std_logic_vector(15 downto 0);

	hcount : in std_logic_vector(9 downto 0);
        R, B: out std_logic_vector(4 downto 0) ;
	G : out std_logic_vector(5 downto 0);
        addr: out std_logic_vector(11 downto 0));
end pixel_pusher;

architecture Behavioral of pixel_pusher is
signal addrr : std_logic_vector(11 downto 0):= (others => '0');
begin
addr <= addrr;
process(clk)
begin

    if rising_edge(clk) then
    
    	if(en = '1') then
        	if VS = '0' then
                	addrr <= (others => '0');
            
        	elsif(vid = '1' AND unsigned(hcount) < 64) then
                	addrr <= std_logic_vector(unsigned(addrr)+1);
        	end if;
        	if(vid = '1' AND unsigned(hcount) < 64) then
                	R <= pixel(15 downto 11) ;
                	G <= pixel(10 downto 5) ;
                	B <= pixel (4 downto 0);
       		else
            	R <= (others => '0');         B <= (others => '0');        G <= (others => '0');
    		end if;
    end if;
    end if;
end process;
end Behavioral;