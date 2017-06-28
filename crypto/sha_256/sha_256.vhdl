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

entity sha_256 is
	generic(
		MSG_L : NATURAL;	--message length in bits
		DATA_WIDTH : NATURAL	:= 32;	--message IN length in bits
		WORD_WIDTH : NATURAL	:= 32	--sha256 uses 32-bit words
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
		data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
		--mode_in : in std_logic;
		data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end entity;

architecture sha_256_ARCH of sha_256 is

--H values (initial hash values)
---------------
--H0 = 6a09e667
--H1 = bb67ae85
--H2 = 3c6ef372
--H3 = a54ff53a
--H4 = 510e527f
--H5 = 9b05688c
--H6 = 1f83d9ab
--H7 = 5be0cd19	
	--Working variables w/ initial hash values
	signal w0 : std_logic_vector(31 downto 0) := X"6a09e667";
	signal w1 : std_logic_vector(31 downto 0) := X"bb67ae85";
	signal w2 : std_logic_vector(31 downto 0) := X"3c6ef372";
	signal w3 : std_logic_vector(31 downto 0) := X"a54ff53a";
	signal w4 : std_logic_vector(31 downto 0) := X"510e527f";
	signal w5 : std_logic_vector(31 downto 0) := X"9b05688c";
	signal w6 : std_logic_vector(31 downto 0) := X"1f83d9ab";
	signal w7 : std_logic_vector(31 downto 0) := X"5be0cd19";
	
	type SHA_256_STATE is ( RESET, IDLE, CRUNCH );
    signal CURRENT_STATE, NEXT_STATE : SHA_256_STATE;
begin

	data_out <= X"FFFFFFFF";
end architecture;

--K values (message schedule)
---------------
--428a2f98 71374491 b5c0fbcf e9b5dba5 3956c25b 59f111f1 923f82a4 ab1c5ed5
--d807aa98 12835b01 243185be 550c7dc3 72be5d74 80deb1fe 9bdc06a7 c19bf174
--e49b69c1 efbe4786 0fc19dc6 240ca1cc 2de92c6f 4a7484aa 5cb0a9dc 76f988da
--983e5152 a831c66d b00327c8 bf597fc7 c6e00bf3 d5a79147 06ca6351 14292967
--27b70a85 2e1b2138 4d2c6dfc 53380d13 650a7354 766a0abb 81c2c92e 92722c85
--a2bfe8a1 a81a664b c24b8b70 c76c51a3 d192e819 d6990624 f40e3585 106aa070
--19a4c116 1e376c08 2748774c 34b0bcb5 391c0cb3 4ed8aa4a 5b9cca4f 682e6ff3
--748f82ee 78a5636f 84c87814 8cc70208 90befffa a4506ceb bef9a3f7 c67178f2







