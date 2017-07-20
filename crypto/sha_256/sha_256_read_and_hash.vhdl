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

entity sha_256_read_and_hash is
	generic(
        CLK_VALUE : std_logic := '1'; --clock trigger value
		RESET_VALUE : std_logic := '0';	--reset enable value
		--MSG_L : NATURAL;	--message length in bits
		WORD_WIDTH : NATURAL	:= 32;	--sha256 uses 32-bit words
        CHUNK_SIZE : NATURAL    := 16   --sha256 uses 16 message blocks (words) at a time for a round of hashing
	);
	port(
		clk : in std_logic;
		rst : in std_logic;
        n_blocks : in natural; --N, the number of (padded) message blocks
		data_in : in std_logic_vector(WORD_WIDTH-1 downto 0);
		--mode_in : in std_logic;
		finished : out std_logic;
        data_out : out std_logic_vector((WORD_WIDTH * 8)-1 downto 0) --SHA-256 results in a 256-bit hash value
	);
end entity;

architecture sha_256_read_and_hash_ARCH of sha_256_read_and_hash is
    signal HASH_ROUND_COUNTER : natural := 0;
    signal MSG_BLOCK_COUNTER : natural := 0;

    --block reader signals
    signal message_chunk_512 : std_logic_vector((CHUNK_SIZE*WORD_WIDTH)-1 downto 0);
    signal input_reader_en : std_logic := '0';
    signal input_reader_valid : std_logic;
    
    --sha-256 core signals
    signal sha_256_core_idle : std_logic;
    signal sha_256_core_finished : std_logic;
    
	type SHA_256_RH_STATE is ( RESET, IDLE_STATE, READ_IN, HASHING, DONE );
    signal CURRENT_STATE, NEXT_STATE : SHA_256_RH_STATE;
begin

    input_block_reader_INST : entity work.block_reader
        port map(
            clk => clk,
            rst => rst,
            en => input_reader_en,
            valid => input_reader_valid,
            data_in => data_in,
            data_out => message_chunk_512
        );

    sha_256_core_INST : entity work.sha_256_core
        port map(
            clk => clk,
            rst => rst,
            idle => sha_256_core_idle,
            n_blocks => n_blocks,
            msg_block_in => message_chunk_512,
            finished => sha_256_core_finished,
            data_out => data_out
        );
    
    --current state assignment logic
    process(clk, rst)
    begin
        if(rst = RESET_VALUE) then
            CURRENT_STATE <= RESET;
        elsif(clk'event and clk = CLK_VALUE) then
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end process;
    
    --next state logic
    process(clk, rst, CURRENT_STATE)
    begin
        if(rst = RESET_VALUE) then
            NEXT_STATE <= RESET;
        elsif(clk'event and clk = CLK_VALUE) then
            case CURRENT_STATE is
                when RESET =>
                    NEXT_STATE <= READ_IN;
                when IDLE_STATE =>
                when READ_IN =>
                    if(input_reader_valid = '1') then
                        NEXT_STATE <= HASHING;
                    else
                        NEXT_STATE <= READ_IN;
                    end if;
                when HASHING =>
                    if(sha_256_core_finished = '1') then
                        NEXT_STATE <= DONE;
                    else
                        NEXT_STATE <= HASHING;
                    end if;
                when DONE =>
                    NEXT_STATE <= DONE;
            end case;
        end if;
    end process;
    
    sha_256_core_idle <= '1' when (CURRENT_STATE = HASHING or CURRENT_STATE = DONE)
                                else '0';
    input_reader_en <= '1' when CURRENT_STATE = READ_IN else '0';
    finished <= sha_256_core_finished;
    
end architecture;










