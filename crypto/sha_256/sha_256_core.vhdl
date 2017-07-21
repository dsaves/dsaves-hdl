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


-- ##################################################################
--     This SHA_256_CORE module reads in PADDED message blocks (from
--      an external source) and hashes the resulting message
-- ##################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sha_256_pkg.all;

entity sha_256_core is
    generic(
        RESET_VALUE : std_logic := '0';    --reset enable value
        IDLE_VALUE : std_logic := '0';    --idle enable value
        WORD_WIDTH : NATURAL    := 32    --sha256 uses 32-bit words
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        idle : in std_logic;
        n_blocks : in natural; --N, the number of (padded) message blocks
        msg_block_in : in std_logic_vector((16 * WORD_WIDTH)-1 downto 0);
        --mode_in : in std_logic;
        finished : out std_logic;
        data_out : out std_logic_vector((WORD_WIDTH * 8)-1 downto 0) --SHA-256 results in a 256-bit hash value
    );
end entity;

architecture sha_256_core_ARCH of sha_256_core is
    signal HASH_ROUND_COUNTER : natural := 0;
    signal MSG_BLOCK_COUNTER : natural := 0;
    signal HASH_02_COUNTER : natural := 0;
    constant HASH_02_COUNT_LIMIT : natural := 64;
    
    --Temporary words
    signal T1 : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
    signal T2 : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

    --Working variables, 8 32-bit words
    signal a : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
    signal b : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
    signal c : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
    signal d : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
    signal e : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
    signal f : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
    signal g : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
    signal h : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
    
    --Hash values w/ initial hash values; 8 32-bit words
    signal HV : H_DATA;
    
    --intermediate Message block values; for use with a for-generate loop;
    signal M_INT : M_DATA;
    
    --intermediate Message Schedule values; for use with a for-generate loop;
    signal W_INT : K_DATA;
    
    --TODO: get rid of this
    signal debug_word : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal debug_word_01 : std_logic_vector(WORD_WIDTH-1 downto 0);
    
    
    type SHA_256_HASH_CORE_STATE is ( RESET, IDLE_STATE, READ_MSG_BLOCK, HASH_00, HASH_01, HASH_02, HASH_02b, HASH_03, DONE );
    signal CURRENT_STATE, NEXT_STATE : SHA_256_HASH_CORE_STATE;
    signal PREVIOUS_STATE : SHA_256_HASH_CORE_STATE;
begin

    --current state logic
    process(clk, rst, idle)
    begin
        if(rst=RESET_VALUE) then
            CURRENT_STATE <= RESET;
        elsif(idle=IDLE_VALUE) then
            CURRENT_STATE <= IDLE_STATE;
        elsif(clk'event and clk='1') then
            if(PREVIOUS_STATE /= CURRENT_STATE) then
                if(CURRENT_STATE /= NEXT_STATE) then
                    PREVIOUS_STATE <= CURRENT_STATE;
                end if;
            end if;
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end process;
    
    --next state logic
    process(CURRENT_STATE, HASH_ROUND_COUNTER, HASH_02_COUNTER, rst, idle)
    begin
        if(rst=RESET_VALUE) then
            NEXT_STATE <= RESET;
        elsif(idle=IDLE_VALUE) then
            NEXT_STATE <= IDLE_STATE;
        else
            case CURRENT_STATE is
                when RESET =>
                    NEXT_STATE <= READ_MSG_BLOCK;
                when IDLE_STATE =>
                    NEXT_STATE <= PREVIOUS_STATE;
                when READ_MSG_BLOCK =>
                    NEXT_STATE <= HASH_00;
                when HASH_00 =>
                    NEXT_STATE <= HASH_01;
                when HASH_01 =>
                    NEXT_STATE <= HASH_02;
                when HASH_02 =>
                    if(HASH_02_COUNTER = HASH_02_COUNT_LIMIT-1) then
                        NEXT_STATE <= HASH_03;
                    else
                        NEXT_STATE <= HASH_02b;
                    end if;
                when HASH_02b =>
                        NEXT_STATE <= HASH_02;
                when HASH_03 =>
                    if(HASH_ROUND_COUNTER = n_blocks-1) then
                        NEXT_STATE <= DONE;
                    else
                        NEXT_STATE <= READ_MSG_BLOCK;
                    end if;
                when DONE =>
                    NEXT_STATE <= DONE; --stay in done state unless reset
            end case;
        end if;
    end process;
    
    --hash logic
    process(clk, rst, idle, CURRENT_STATE)
    begin
        if(rst=RESET_VALUE) then
            HASH_ROUND_COUNTER <= 0;
            MSG_BLOCK_COUNTER <= 0;
        elsif(clk'event and clk='1') then
            debug_word <= debug_word;
            debug_word_01 <= debug_word_01;
            W <= W;
            a <= a;
            b <= b;
            c <= c;
            d <= d;
            e <= e;
            f <= f;
            g <= g;
            h <= h;
            T1 <= T1;
            T2 <= T2;
            M <= M;
            HV <= HV;
            HASH_02_COUNTER <= HASH_02_COUNTER;
            HASH_ROUND_COUNTER <= HASH_ROUND_COUNTER;
            case CURRENT_STATE is
                when RESET =>
                    HV(0) <= X"6a09e667";
                    HV(1) <= X"bb67ae85";
                    HV(2) <= X"3c6ef372";
                    HV(3) <= X"a54ff53a";
                    HV(4) <= X"510e527f";
                    HV(5) <= X"9b05688c";
                    HV(6) <= X"1f83d9ab";
                    HV(7) <= X"5be0cd19";
                    HASH_02_COUNTER <= 0;
                    HASH_ROUND_COUNTER <= 0;
                when IDLE_STATE =>    --the IDLE_STATE stage is a stall stage, perhaps waiting for new message block to arrive.
                when READ_MSG_BLOCK =>
                
                    HV(0) <= X"6a09e667";
                    HV(1) <= X"bb67ae85";
                    HV(2) <= X"3c6ef372";
                    HV(3) <= X"a54ff53a";
                    HV(4) <= X"510e527f";
                    HV(5) <= X"9b05688c";
                    HV(6) <= X"1f83d9ab";
                    HV(7) <= X"5be0cd19";
                    M <= M_INT;
                    
                when HASH_00 =>
                    W <= W_INT;
                when HASH_01 =>
                    a <= HV(0);
                    b <= HV(1);
                    c <= HV(2);
                    d <= HV(3);
                    e <= HV(4);
                    f <= HV(5);
                    g <= HV(6);
                    h <= HV(7);
                when HASH_02 =>
                    if(HASH_02_COUNTER = HASH_02_COUNT_LIMIT-1) then
                        HASH_02_COUNTER <= 0;
                    else
                        --you have to set T1 and T2 in a different state, due to how
                        --VHDL sequential/process statements are evaluated.
                        --T1 <= std_logic_vector(unsigned(h) + unsigned(SIGMA_UCASE_1(e)) + unsigned(CH(e, f, g)) + unsigned(K(HASH_02_COUNTER)) + unsigned(W(HASH_02_COUNTER)));
                        --T2 <= std_logic_vector(unsigned(SIGMA_UCASE_0(a)) + unsigned(MAJ(a, b, c)));
                    end if;
                when HASH_02b =>
                        debug_word <= K(HASH_02_COUNTER);
                        debug_word_01 <= W(HASH_02_COUNTER);
                        T1 <= std_logic_vector(unsigned(h) + unsigned(SIGMA_UCASE_1(e)) + unsigned(CH(e, f, g)) + unsigned(K(HASH_02_COUNTER)) + unsigned(W(HASH_02_COUNTER)));
                        T2 <= std_logic_vector(unsigned(SIGMA_UCASE_0(a)) + unsigned(MAJ(a, b, c)));
                        h <= g;
                        g <= f;
                        f <= e;
                        e <= std_logic_vector(unsigned(d) + unsigned(T1));
                        d <= c;
                        c <= b;
                        b <= a;
                        a <= std_logic_vector(unsigned(T1) + unsigned(T2));
                        HASH_02_COUNTER <= HASH_02_COUNTER + 1;    --increment counter
                when HASH_03 =>
                    HV(0) <= std_logic_vector(unsigned(a) + unsigned(HV(0)));
                    HV(1) <= std_logic_vector(unsigned(b) + unsigned(HV(1)));
                    HV(2) <= std_logic_vector(unsigned(c) + unsigned(HV(2)));
                    HV(3) <= std_logic_vector(unsigned(d) + unsigned(HV(3)));
                    HV(4) <= std_logic_vector(unsigned(e) + unsigned(HV(4)));
                    HV(5) <= std_logic_vector(unsigned(f) + unsigned(HV(5)));
                    HV(6) <= std_logic_vector(unsigned(g) + unsigned(HV(6)));
                    HV(7) <= std_logic_vector(unsigned(h) + unsigned(HV(7)));
                    if(HASH_ROUND_COUNTER = n_blocks-1) then
                        HASH_ROUND_COUNTER <= 0;
                    else
                        HASH_ROUND_COUNTER <= HASH_ROUND_COUNTER + 1;    --increment counter, read in next message block
                    end if;
                when DONE =>
            end case;
        end if;
    end process;
    
    
    MESSAGE_BLOCK_INTERMEDIATE :
    for i in 0 to 15 generate
    begin
        M_INT(i) <= msg_block_in((WORD_WIDTH * (i+1))-1 downto WORD_WIDTH * i);
    end generate;
    
    MESSAGE_SCHEDULE_INTERMEDIATE_00:
    for i in 0 to 15 generate
    begin
        W_INT(i) <= M(i);
    end generate;
    
    MESSAGE_SCHEDULE_INTERMEDIATE_01:
    for i in 16 to 63 generate
    begin
        W_INT(i) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(i-2))) + unsigned(W(i-7)) + unsigned(SIGMA_LCASE_0(W(i-15))) + unsigned(W(i-16)));
    end generate;
    
    
    --FINISHED signal asserts when hashing is done
    finished <= '1' when CURRENT_STATE = DONE else
                '0';
                
    data_out <= HV(0) & HV(1) & HV(2) & HV(3) & HV(4) & HV(5) & HV(6) & HV(7);
end architecture;










