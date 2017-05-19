--#############################################################################
--#############################################################################
--#####  #########  #############   ######      ######  #####         #########
--####  ###########  ##########   #   ###   ##   ####   #####  #####  #########
--###  #####   #####  ########   ###   ##  ####  #####  ###########  ##########
--##  #####  #  #####  ############   ###  ####  #####  ##########  ###########
--##  #####  ########  ###########   ####  ####  #####  #########  ############
--##  #####  ########  ##########   #####  ####  #####  ########  #############
--###  ####  #  ####  ##########   ######  ####  #####  ########  #############
--####  ####   ####  ##########   #######   ##   #####  ########  #############
--#####  #########  ##########        ####      ####      ######  #############
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
--
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

--High assert reset, resets to '0'
entity FF is
    port(
        clk : in std_logic;
        d : in std_logic;
        en : in std_logic;
        rst : in std_logic;
        q : out std_logic
    );
end entity;

--POS EDGE FF is a neg latch followed by pos latch
architecture POS_EDGE_HI_EN of FF is
    signal middle : std_logic;
    signal enabled_data : std_logic;
    signal output_feedback : std_logic;
begin

    enabled_data <= d when en = '1'
        else output_feedback;

    neg_latch : entity dsaves.LATCH(LO_EN)
        port map(
            clk => clk,
            i => enabled_data,
            o => middle
        );
        
    pos_latch : entity dsaves.LATCH(HI_EN)
        port map(
            clk => clk,
            i => middle,
            o => output_feedback
        );
        
        output_feedback <= '0' when rst = '1';
        q <= output_feedback;
        
end architecture;

--NEG EDGE FF is a pos latch followed by a neg latch
architecture NEG_EDGE_HI_EN of FF is
    signal middle : std_logic;
    signal enabled_data : std_logic;
    signal output_feedback : std_logic;
begin

    enabled_data <= d when en = '1'
        else output_feedback;

    pos_latch : entity dsaves.LATCH(HI_EN)
        port map(
            clk => clk,
            i => enabled_data,
            o => middle
        );
        
    neg_latch : entity dsaves.LATCH(LO_EN)
        port map(
            clk => clk,
            i => middle,
            o => output_feedback
        );
        
        output_feedback <= '0' when rst = '1';
        q <= output_feedback;
        
end architecture;

--POS EDGE FF is a neg latch followed by pos latch
architecture POS_EDGE_LO_EN of FF is
    signal middle : std_logic;
    signal enabled_data : std_logic;
    signal output_feedback : std_logic;
begin

    enabled_data <= d when en = '0'
        else output_feedback;

    neg_latch : entity dsaves.LATCH(LO_EN)
        port map(
            clk => clk,
            i => enabled_data,
            o => middle
        );
        
    pos_latch : entity dsaves.LATCH(HI_EN)
        port map(
            clk => clk,
            i => middle,
            o => output_feedback
        );
        
        output_feedback <= '0' when rst = '1';
        q <= output_feedback;
        
end architecture;

--NEG EDGE FF is a pos latch followed by a neg latch
architecture NEG_EDGE_LO_EN of FF is
    signal middle : std_logic;
    signal enabled_data : std_logic;
    signal output_feedback : std_logic;
begin

    enabled_data <= d when en = '0'
        else output_feedback;

    pos_latch : entity dsaves.LATCH(HI_EN)
        port map(
            clk => clk,
            i => enabled_data,
            o => middle
        );
        
    neg_latch : entity dsaves.LATCH(LO_EN)
        port map(
            clk => clk,
            i => middle,
            o => output_feedback
        );
        
        output_feedback <= '0' when rst = '1';
        q <= output_feedback;
        
end architecture;