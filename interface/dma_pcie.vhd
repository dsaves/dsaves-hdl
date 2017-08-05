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

entity dma_pcie is
    generic(
        ADDR_WIDTH : natural := 32
    );
    port(
        ------------------------------------
        --PCIE SIGNALS
        ------------------------------------
        --system
        clk : in std_logic;
        rst : in std_logic;
        
        --address and data wires
        ad : inout std_logic_vector(ADDR_WIDTH-1 downto 0);
        c_be : inout std_logic_vector(3 downto 0);
        par : inout std_logic;
        
        --interface and control
        frame : inout std_logic;
        trdy : inout std_logic;
        irdy : inout std_logic;
        stop : inout std_logic;
        devsel : inout std_logic;
        idsel : inout std_logic;
        
        --error
        perr : inout std_logic;
        serr : inout std_logic;
        
        --arbitration
        req : out std_logic;
        gnt : in std_logic
    );
end entity;

architecture dma_pcie_ARCH of dma_pcie is
begin

end architecture;



