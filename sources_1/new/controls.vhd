----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2024 05:51:29 PM
-- Design Name: 
-- Module Name: controls - Behavioral
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

entity controls is
    port (
        -- Timing Signals
        clk , en , rst : in std_logic ;
        -- Register File IO
        rID1 , rID2 : out std_logic_vector (4 downto 0);
        wr_enR1 , wr_enR2 : out std_logic ;
        regrD1 , regrD2 : in std_logic_vector (15 downto 0);
        regwD1 , regwD2 : out std_logic_vector (15 downto 0);
        -- Framebuffer IO
        fbRST : out std_logic ;
        fbWr_en: out std_logic;
        fbAddr1 : out std_logic_vector (11 downto 0);
        fbDin1 : in std_logic_vector (15 downto 0);
        fbDout1 : out std_logic_vector (15 downto 0);
        -- Instruction Memory IO
        irAddr : out std_logic_vector (13 downto 0);
        irWord : in std_logic_vector (31 downto 0);
        -- Data Memory IO
        dAddr : out std_logic_vector (14 downto 0);
        d_wr_en : out std_logic ;
        dOut : out std_logic_vector (15 downto 0);
        dIn : in std_logic_vector (15 downto 0);
        -- ALU IO
        aluA , aluB : out std_logic_vector (15 downto 0);
        aluOp : out std_logic_vector (3 downto 0);
        aluResult : in std_logic_vector (15 downto 0);
        -- UART IO
        ready , newChar : in std_logic ;
        send : out std_logic ;
        charRec : in std_logic_vector (7 downto 0);
        charSend : out std_logic_vector (7 downto 0)
        );
end controls;


architecture Behavioral of controls is
type state_type is (fetch, fetch1, decode, decode1, decodestall, Rops, Rops2, Iops, Iops2, 
Jops, calc, calc2, calc3, store, jr, jr1, recv, rpix, rpix1, rpix2, wpix, sendS, sendS1, equals, nequal, 
ori, ori1, ori2, lw, lw1, lw2, lw3, lw4, sw, sw1, sw2, jmp, jal, jal1, clrscr, finish);

signal pc: unsigned (13 downto 0):= (others => '0');
signal curr : state_type:= fetch;
signal full: std_logic_vector(31 downto 0);

signal op: std_logic_vector(4 downto 0);
signal reg1, reg2, reg3: std_logic_vector(4 downto 0);
signal reg1d, reg2d, reg3d: std_logic_vector(15 downto 0);

signal imm  : std_logic_vector(15 downto 0);			

begin
    process(clk) begin
        if rst = '1' then
            curr <= fetch;
            pc <= (others => '0');
            rID1 <= (others => '0');
            rID2 <= (others => '0');
            wr_enR1 <= '0';
            wr_enR2 <= '0';
            regwD1 <= (others => '0');
            regwD2 <= (others => '0');
            fbRST <= '0';
            fbWr_en <= '0';
            fbAddr1 <= (others => '0');
            fbDout1 <= (others => '0');
            irAddr <= (others => '0');
            dAddr <= (others => '0');
            d_wr_en <= '0';
            dOut <= (others => '0');
            aluA <= (others => '0');
            aluB <= (others => '0');
            aluOp <= x"0";
            send <= '0';
            charSend <= (others => '0');
            curr <= fetch;
        elsif en = '1' then
            case curr is 
                when fetch =>
                    rID1 <= "00001";
                    curr <= fetch1;
                when fetch1 => 
                    pc <= unsigned(regrD1(13 downto 0));
                    curr <= decodestall;
                when decodestall => 
                    pc <= pc + 1;
                    rID1 <= "00001";
                    irAddr <= std_logic_vector(pc);
                    curr <= decode;
                when decode =>
                    wr_enR1 <= '1';
                    full <= irWord;
                    op <= irWord(31 downto 27);
                    regwD1 <= "00" & std_logic_vector(pc);
                    curr <= decode1;
                when decode1 =>
                    wr_enR1 <= '0';
                    if op(4 downto 3) = "00" or op(4 downto 3) = "01" then
                        curr <= Rops;
                    elsif op(4 downto 3) = "10" then
                        curr <= Iops;
                    else
                        curr <= Jops;
                    end if;
                when Rops =>
                    op <= full(31 downto 27);
                    reg1 <= full(26 downto 22);
                    reg2 <= full(21 downto 17);
                    reg3 <= full(16 downto 12);
                    rID1 <= reg2;
                    rID2 <= reg3;
                    curr <= Rops2;

                when Rops2 => 
                    reg1d <= regrD1;
                    reg2d <= regrD2;
                    if op = "01101" then
                        curr <= jr;
                    elsif op = "01100" then
                        curr <= recv;
                    elsif op = "01111" then
                        curr <= rpix;
                    elsif op = "01110" then
                        curr <= wpix;
                    elsif op = "01011" then
                        curr <= sendS;
                    else
                        curr <= calc;
                    end if;
                when Iops =>
                    op <= full(31 downto 27);
                    reg1 <= full(26 downto 22);
                    reg2 <= full(21 downto 17);
                    imm <= full(16 downto 1);
                    rID1 <= reg2;
                    curr <= Iops2;
                when Iops2 =>
                    reg1d <= regrD1;
                    reg2d <= regrD2;
                    if op(2 downto 0) = "000" then
                        curr <= equals;
                    elsif op(2 downto 0) = "001" then
                        curr <= nequal;
                    elsif op(2 downto 0) = "010" then
                        curr <= ori;
                    elsif op(2 downto 0) = "011" then
                        curr <= lw;
                    else
                        curr <= calc;
                    end if;
                when Jops => 
                    op <= full(31 downto 27);
                    imm <= full(16 downto 1);
                    if op = "11000" then
                        curr <= jmp;
                    elsif op = "11001" then
                        curr <= jal;
                    else
                        curr <= clrscr;
                    end if;
                when calc => 
                    aluA <= reg2d;
                    aluB <= reg3d;
                    if op = "00000" then
                        aluOp <= x"0";
                    elsif op = "00001" then
                        aluOp <= x"1";
                    elsif op = "00010" then
                        aluOp <= x"5";
                    elsif op = "00011" then
                        aluOp <= x"6";
                    elsif op = "00100" then
                        aluOp <= x"7";
                    elsif op = "00101" then
                        aluOp <= x"8";
                    elsif op = "00110" then
                        aluOp <= x"9";
                    elsif op = "00111" then
                        aluOp <= x"A";
                    elsif op = "01000" then
                        aluOp <= x"B";
                    elsif op = "01001" then
                        aluOp <= x"C";
                    elsif op = "01010" then
                        aluOp <= x"D";
                    end if;
                    curr <= calc2;
                when calc2 => 
                    curr <= calc3;
                when calc3 =>
                    reg1d <= aluResult;
                    curr <= store;
                when store => 
                    wr_enR1 <= '1';
                    rID1 <= reg1;
                    regwD1 <= reg1d;
                    curr <= finish;
                when jr => 
                    
                    rID1 <= reg1;
                    curr <= jr1;
                when jr1 =>
                    reg1 <= "00001";
                    reg1d <= regrD1;
                    curr <= store;
                when recv => 
                    reg1d <= "00000000" & charRec;
                    if(newChar = '0') then
                         curr <= recv;
                    else
                         curr <= store;
                    end if;
                when rpix => 
                    rID1 <=reg2;
                     curr <= rpix1;
                when rpix1 => 
                    fbAddr1 <= regrD1(11 downto 0);
                    curr <= rpix2;
                when rpix2 => 
                    reg1d <=fbDin1;
                    curr <= store;
                when wpix => 
                    fbWr_en	    <= '1';
                    fbAddr1     <= regrD1(11 downto 0);
                    fbDout1     <= regrD2;
                    curr <= finish;
                when sendS => 
                    rID1 <=reg1;
                    curr <= sendS1;
                when SendS1 => 
                    reg1d <= regrD1;
                    send <= '1';
                    charSend <=reg1d(7 downto 0); 
                    if ready = '1' then
                        curr <= finish;
                    else
                        curr <= sendS;
                    end if;
                when equals => 
                    if (reg1d = reg2d) then
                        reg1 <= "00001";
                        reg1d <= imm;
                    end if;
                    curr <= store;
                when nequal => 
                    if (reg1d /= reg2d) then
                        reg1 <= "00001";
                        reg1d <= imm;
                    end if;
                    curr <= store;
                when ori => 
                    aluA <= reg2d;
                    aluB <= imm;
                    aluOp <= x"9";
                    curr <= ori1;
                when ori1 =>
                    curr <= ori2;
                when ori2 =>
                    reg1d <= aluResult;
                    curr <= store;
                when lw => 
                    aluA <= reg2d;
                    aluB <= imm;
                    aluOp <= x"0";
                    curr <= lw1;
                when lw1 => 
                    curr <= lw2;
                when lw2 =>
                    dAddr <=aluResult(14 downto 0);
                    curr <= lw3;
                when lw3 => 
                    curr <= lw4;
                when lw4 => 
                    reg1d <= dIn;
                    curr <= store;
                when sw => 
                    aluA <= reg2d;
                    aluB <= imm;
                    aluOp <= x"0";
                    curr <= sw1;
                when sw1 => 
                    curr <= sw2;
                when sw2 =>
                    d_wr_en <= '1';
                    dOut <= regrD1;
                    dAddr <=aluResult (14 downto 0);
                    curr <= finish;
                when jmp => 
                    wr_enR1 <='1' ;
                    rID1 <= "00001";
                    regwD1 <= imm;
                    curr <= finish;
                    
                when jal => 
                    rID1 <= "00010"; --ra register
                    rID2 <= "00001";
                    curr <= jal1;
                when jal1 => 
                    regwD1 <= regrD2;
                    regwD2 <= imm;
                    wr_enR1 <= '1';
                    wr_enR2 <= '1';
                    curr <= finish;
                when clrscr => 
                    fbRST <= '1';
                    curr <= finish;
                when finish =>
                     wr_enR1 <= '0';
                     wr_enR2 <= '0';
                     d_wr_en <= '0';
                     fbWr_en <= '0';
                     send <= '0';
                     curr <= fetch;
                
            end case;
        end if;
    end process;
end Behavioral;
