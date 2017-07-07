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

entity bscan_cell is
    port(
        data_in : in std_logic;
        scan_in : in std_logic;
        shift_DR : in std_logic;
        capture_DR : in std_logic;
        update_DR : in std_logic;
        mode : in std_logic;
        trst : in std_logic;
        data_out : out std_logic
    );
end entity;

architecture POS_EDGE of BSCAN_CELL is
    signal capture_reg_in : std_logic;
    signal capture_reg_out : std_logic;
    signal update_latch_out : std_logic;
begin

    capture_reg_in <= data_in when shift_DR = '0' else
                        scan_in;
                        
    capture_reg_INST : entity dsaves.FF(POS_EDGE_HI_EN)
        port map(
            clk => capture_DR,
            d => capture_reg_in,
            en => '1',
            rst => trst,
            q => capture_reg_out
        );
        
    update_latch_INST : entity dsaves.LATCH(HI_EN)
        port map(
            clk => update_DR,
            i => capture_reg_out,
            o => update_latch_out
        );
                        
    data_out <= data_in when mode = '0' else
                update_latch_out;
                
end architecture;

