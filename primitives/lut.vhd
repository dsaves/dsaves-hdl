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
use ieee.numeric_std.all;

entity LUT is
    generic(
        N : natural
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        d : in std_logic_vector((2**N)-1 downto 0);
        wen : in std_logic;
        s : in std_logic_vector(N-1 downto 0);
        o : out std_logic
    );
end entity;

architecture POS_EDGE of LUT is
    signal mem_bank : std_logic_vector((2**N)-1 downto 0);
begin

    MEM_GENERATE:
    for i in 0 to ((2**N)-1) generate
        FF : entity dsaves.FF(POS_EDGE_HI_EN)
            port map(
                clk => clk,
                d => d(i),
                en => wen,
                rst => rst,
                q => mem_bank(i)
            );
    end generate;

    o <= mem_bank(to_integer(unsigned(s)));
end architecture;


architecture NEG_EDGE of LUT is
    signal mem_bank : std_logic_vector((2**N)-1 downto 0);
begin

    MEM_GENERATE:
    for i in 0 to ((2**N)-1) generate
        FF : entity dsaves.FF(NEG_EDGE_HI_EN)
            port map(
                clk => clk,
                d => d(i),
                en => wen,
                rst => rst,
                q => mem_bank(i)
            );
    end generate;

    o <= mem_bank(to_integer(unsigned(s)));
end architecture;


