library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity uart_tx is
port (
clk , en , send , rst : in std_logic ;
char : in std_logic_vector (7 downto 0) ;
ready, tx : out std_logic) ;
end uart_tx ;

architecture Behavioral of uart_tx is

type state_type is (idle, start, data);
signal curr : state_type := idle;
signal count : std_logic_vector(3 downto 0) := (others => '0');
signal datareg: std_logic_vector(7 downto 0):= (others => '0');
begin

 process(clk) begin
   if rising_edge(clk) then
       -- resets the state machine and its outputs
       if rst = '1' then
           tx <= '1';
           ready <= '1';
           datareg <= (others => '0');
           count <= (others => '0');
           curr <= idle;
           end if;
       -- usual operation
        if en = '1' then
            case curr is

                when idle =>
                    ready <= '1';
                    tx <= '1';
                    if send = '1' then
                        curr <= start;
                        datareg <= char;
                    end if;

                when start =>
                    
                    tx <= '0';
                    ready <= '0';
                    count <= (others => '0');
                    curr <= data;
                    
                when data =>
                    
                     if unsigned(count) <8 then
                     datareg <= '0' & datareg(7 downto 1);
                     tx <= datareg(0);

                     count <= std_logic_vector(unsigned(count) + 1);
                     elsif unsigned(count) = 8 then
                     curr <= idle;
                     end if;
                
                when others =>
                    
                     curr <= idle;

            end case;
        end if;
        end if;
   end process;

end Behavioral;