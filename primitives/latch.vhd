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


library ieee;
use ieee.std_logic_1164.all;

entity LATCH is
    port(
        clk : in std_logic;
        i : in std_logic;
        o : out std_logic
    );
end entity;

architecture HI_EN of LATCH is
    signal o2 : std_logic;
begin
    --assign output
    o <= o2;

    --LATCH logic
    process(clk, i)
    begin
        if(clk='1') then
            o2 <= i;
        else
            o2 <= o2;
        end if;
    end process;

end architecture;


architecture LO_EN of LATCH is
    signal o2 : std_logic;
begin
    --assign output
    o <= o2;

    --LATCH logic
    process(clk, i)
    begin
        if(clk='0') then
            o2 <= i;
        else
            o2 <= o2;
        end if;
    end process;

end architecture;




--#############################################################################
--#############################################################################
--#####  ######################################################################
--#####  ######################################################################
--#####  ######################################################################
--#####  ###   ###  #####  #####  #  ########   ####   ###  #  ###   ####   ###
--###    ##  #  ##     ##     ##  #  #######  #  ##  #  ##  #  ##  #  ##  #  ##
--##  #  #####  ##  #  ##  #  ###    ########  #######  ###   ###     ###  ####
--##  #  ###    ##  #  ##  #  #####  #########  ####    ###   ###  #######  ###
--##  #  ##  #  ##  #  ##  #  ##  #  #######  #  ##  #  #### ####  #  ##  #  ##
--###    ###    ##  #  ##  #  ###   #########   ####    #### #####   ####   ###
--#############################################################################
--#############################################################################
--#############################################################################
