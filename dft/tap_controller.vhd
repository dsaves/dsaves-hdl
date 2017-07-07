--MIT License
--
--Copyright (c) 2017  Danny Savory
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.


library ieee, dsaves;
use ieee.std_logic_1164.all;

entity TAP_CONTROLLER is
    port(
        tclk : in std_logic;
        tms : in std_logic;
        tdi : in std_logic;
        trst : in std_logic;
        tdo : out std_logic
    );
end entity;

architecture IEEE_STD_1149_1_2013 of TAP_CONTROLLER is
    type TAP_STATE is ( RESET, IDLE,
    SELECT_DR_SCAN, CAPTURE_DR, SHIFT_DR, EXIT1_DR, PAUSE_DR, EXIT2_DR, UPDATE_DR,
    SELECT_IR_SCAN, CAPTURE_IR, SHIFT_IR, EXIT1_IR, PAUSE_IR, EXIT2_IR, UPDATE_IR );
    signal CURRENT_STATE, NEXT_STATE : TAP_STATE;
begin

    --CURRENT_STATE assignment
    process(tclk, trst)
    begin
        if(trst = '1') then
            CURRENT_STATE <= RESET;
        end if;
        if(tclk'event and tclk='1') then
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end process;

    --NEXT STATE logic
    process(tclk, trst)
    begin
        if(trst = '1') then
            NEXT_STATE <= RESET;
        end if;
        if(tclk'event and tclk = '1') then
                case CURRENT_STATE is
                    when RESET =>
                        if(tms = '1') then
                            NEXT_STATE <= RESET;
                        else
                            NEXT_STATE <= IDLE;
                        end if;
                    when IDLE =>
                        if(tms = '1') then
                            NEXT_STATE <= SELECT_DR_SCAN;
                        else
                            NEXT_STATE <= IDLE;
                        end if;
                    when SELECT_DR_SCAN =>
                        if(tms = '1') then
                            NEXT_STATE <= SELECT_IR_SCAN;
                        else
                            NEXT_STATE <= CAPTURE_DR;
                        end if;
                    when CAPTURE_DR =>
                        if(tms = '1') then
                            NEXT_STATE <= EXIT1_DR;
                        else
                            NEXT_STATE <= SHIFT_DR;
                        end if;
                    when SHIFT_DR =>
                        if(tms = '1') then
                            NEXT_STATE <= EXIT1_DR;
                        else
                            NEXT_STATE <= SHIFT_DR;
                        end if;
                    when EXIT1_DR =>
                        if(tms = '1') then
                            NEXT_STATE <= UPDATE_DR;
                        else
                            NEXT_STATE <= PAUSE_DR;
                        end if;
                    when PAUSE_DR =>
                        if(tms = '1') then
                            NEXT_STATE <= EXIT2_DR;
                        else
                            NEXT_STATE <= PAUSE_DR;
                        end if;
                    when EXIT2_DR =>
                        if(tms = '1') then
                            NEXT_STATE <= UPDATE_DR;
                        else
                            NEXT_STATE <= SHIFT_DR;
                        end if;
                    when UPDATE_DR =>
                        if(tms = '1') then
                            NEXT_STATE <= SELECT_DR_SCAN;
                        else
                            NEXT_STATE <= IDLE;
                        end if;
                    when SELECT_IR_SCAN =>
                        if(tms = '1') then
                            NEXT_STATE <= RESET;
                        else
                            NEXT_STATE <= CAPTURE_IR;
                        end if;
                    when CAPTURE_IR =>
                        if(tms = '1') then
                            NEXT_STATE <= EXIT1_IR;
                        else
                            NEXT_STATE <= SHIFT_IR;
                        end if;
                    when SHIFT_IR =>
                        if(tms = '1') then
                            NEXT_STATE <= EXIT1_IR;
                        else
                            NEXT_STATE <= SHIFT_IR;
                        end if;
                    when EXIT1_IR =>
                        if(tms = '1') then
                            NEXT_STATE <= UPDATE_IR;
                        else
                            NEXT_STATE <= PAUSE_IR;
                        end if;
                    when PAUSE_IR =>
                        if(tms = '1') then
                            NEXT_STATE <= EXIT2_IR;
                        else
                            NEXT_STATE <= PAUSE_IR;
                        end if;
                    when EXIT2_IR =>
                        if(tms = '1') then
                            NEXT_STATE <= UPDATE_IR;
                        else
                            NEXT_STATE <= SHIFT_IR;
                        end if;
                    when UPDATE_IR =>
                        if(tms = '1') then
                            NEXT_STATE <= SELECT_DR_SCAN;
                        else
                            NEXT_STATE <= IDLE;
                        end if;
                end case;
        end if;
    end process;
    
end architecture;


