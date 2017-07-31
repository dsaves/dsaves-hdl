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


-- ############################################################################
--  The official specifications of the SHA-256 algorithm can be found here:
--      http://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aes_256_pkg.all;

entity aes_256_core is
    generic(
        BLOCK_SIZE : natural := 128     --AES block size is 128 bits
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        data_in : in std_logic_vector(BLOCK_SIZE-1 downto 0);
        data_out : out std_logic_vector(BLOCK_SIZE-1 downto 0)
    );
end entity;

architecture aes_256_core_ARCH of aes_256_core is
    constant KEY_SIZE : natural := 256; -- AES-256 has a 256-bit key size
begin

    --TODO: fix dummy output
    data_out <= (others => '0');
    
end architecture;