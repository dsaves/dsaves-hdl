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


-- This block reader reads in a bunch of data sequentially, then outputs all the blocks
-- in parallel.  This simplifies the rest of the SHA-256 design.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity block_accumulator is
	generic(
        CLK_VALUE : std_logic := '1';    --clock enable value
        RESET_VALUE : std_logic := '0';    --reset enable value
        EN_VALUE : std_logic := '1';    --enable value
        BLOCK_SIZE : natural := 32;   --size of blocks, 
        NUM_BLOCKS : natural := 16
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
        en : in std_logic;
        valid : out std_logic;
        data_in : in std_logic_vector(BLOCK_SIZE-1 downto 0);
        data_out : out std_logic_vector((BLOCK_SIZE*NUM_BLOCKS)-1 downto 0)
	);
end entity;

architecture block_accumulator_ARCH of block_accumulator is
    signal BLOCK_COUNTER : natural := 0;
    signal data : std_logic_vector((BLOCK_SIZE*NUM_BLOCKS)-1 downto 0);

    --state definition
    type reader_state is (RESET, READ_IN, DONE);
    signal CURRENT_STATE, NEXT_STATE : reader_state;
    
begin

    --current state assignment
    process(clk, rst, en)
    begin
        if(rst'event and rst = RESET_VALUE) then
            CURRENT_STATE <= RESET;
        elsif(clk'event and clk = CLK_VALUE) then
            if(en = EN_VALUE) then  --only advance state if external enable is asserted
                CURRENT_STATE <= NEXT_STATE;
            end if;
        end if;
    end process;
    
    --next state logic
    process(CURRENT_STATE, BLOCK_COUNTER, rst)
    begin
        if(rst'event and rst = RESET_VALUE) then
            NEXT_STATE <= RESET;
        else
            case CURRENT_STATE is
                when RESET =>
                    NEXT_STATE <= READ_IN;
                when READ_IN =>
                    if(BLOCK_COUNTER >= NUM_BLOCKS) then
                        NEXT_STATE <= DONE;
                    else
                        NEXT_STATE <= READ_IN;
                    end if;
                when DONE =>
                    NEXT_STATE <= DONE;
            end case;
        end if;
    end process;
    
    --functional logic
    process(clk, rst, en)
    begin
        data <= data;
        if(rst'event and rst = RESET_VALUE) then
            BLOCK_COUNTER <= 0;
            data <= (others => '0');
        elsif(clk'event and clk = CLK_VALUE) then
            case CURRENT_STATE is
                when RESET =>
                when READ_IN =>
                    if(BLOCK_COUNTER >= NUM_BLOCKS) then
                    else
                        --capture logic
                        BLOCK_COUNTER <= BLOCK_COUNTER + 1;
                        data(BLOCK_SIZE-1 downto 0) <= data_in;
                        data((BLOCK_SIZE*NUM_BLOCKS)-1 downto BLOCK_SIZE) <= data(BLOCK_SIZE*(NUM_BLOCKS-1)-1 downto 0);
                    end if;
                when DONE =>
            end case;
        end if;
    end process;
    
    data_out <= data;
    valid <= '1' when CURRENT_STATE = DONE else '0';
    
end architecture;











