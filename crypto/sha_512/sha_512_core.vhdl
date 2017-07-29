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
--     This SHA_512_CORE module reads in PADDED message blocks (from
--      an external source) and hashes the resulting message
-- ##################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sha_512_pkg.all;

entity sha_512_core is
    generic(
        RESET_VALUE : std_logic := '0'    --reset enable value
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        data_ready : in std_logic;  --the edge of this signal triggers the capturing of input data and hashing it.
        n_blocks : in natural; --N, the number of (padded) message blocks
        msg_block_in : in std_logic_vector(0 to (16 * WORD_SIZE)-1);
        --mode_in : in std_logic;
        finished : out std_logic;
        data_out : out std_logic_vector((WORD_SIZE * 8)-1 downto 0) --SHA-512 results in a 512-bit hash value
    );
end entity;

architecture sha_512_core_ARCH of sha_512_core is
    signal HASH_ROUND_COUNTER : natural := 0;
    signal MSG_BLOCK_COUNTER : natural := 0;
    signal HASH_02_COUNTER : natural := 0;
    constant HASH_02_COUNT_LIMIT : natural := 80;
    
    --Temporary words
    signal T1 : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal T2 : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');

    --Working variables, 8 64-bit words
    signal a : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal b : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal c : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal d : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal e : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal f : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal g : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal h : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    
    constant K : K_DATA := (
        --address 0
        X"428a2f98d728ae22", X"7137449123ef65cd", X"b5c0fbcfec4d3b2f", X"e9b5dba58189dbbc",
        X"3956c25bf348b538", X"59f111f1b605d019", X"923f82a4af194f9b", X"ab1c5ed5da6d8118",
        X"d807aa98a3030242", X"12835b0145706fbe", X"243185be4ee4b28c", X"550c7dc3d5ffb4e2",
        X"72be5d74f27b896f", X"80deb1fe3b1696b1", X"9bdc06a725c71235", X"c19bf174cf692694",
        X"e49b69c19ef14ad2", X"efbe4786384f25e3", X"0fc19dc68b8cd5b5", X"240ca1cc77ac9c65",
        X"2de92c6f592b0275", X"4a7484aa6ea6e483", X"5cb0a9dcbd41fbd4", X"76f988da831153b5",
        X"983e5152ee66dfab", X"a831c66d2db43210", X"b00327c898fb213f", X"bf597fc7beef0ee4",
        X"c6e00bf33da88fc2", X"d5a79147930aa725", X"06ca6351e003826f", X"142929670a0e6e70",
        X"27b70a8546d22ffc", X"2e1b21385c26c926", X"4d2c6dfc5ac42aed", X"53380d139d95b3df",
        X"650a73548baf63de", X"766a0abb3c77b2a8", X"81c2c92e47edaee6", X"92722c851482353b",
        X"a2bfe8a14cf10364", X"a81a664bbc423001", X"c24b8b70d0f89791", X"c76c51a30654be30",
        X"d192e819d6ef5218", X"d69906245565a910", X"f40e35855771202a", X"106aa07032bbd1b8",
        X"19a4c116b8d2d0c8", X"1e376c085141ab53", X"2748774cdf8eeb99", X"34b0bcb5e19b48a8",
        X"391c0cb3c5c95a63", X"4ed8aa4ae3418acb", X"5b9cca4f7763e373", X"682e6ff3d6b2b8a3",
        X"748f82ee5defb2fc", X"78a5636f43172f60", X"84c87814a1f0ab72", X"8cc702081a6439ec",
        X"90befffa23631e28", X"a4506cebde82bde9", X"bef9a3f7b2c67915", X"c67178f2e372532b",
        X"ca273eceea26619c", X"d186b8c721c0c207", X"eada7dd6cde0eb1e", X"f57d4f7fee6ed178",
        X"06f067aa72176fba", X"0a637dc5a2c898a6", X"113f9804bef90dae", X"1b710b35131c471b",
        X"28db77f523047d84", X"32caab7b40c72493", X"3c9ebe0a15c9bebc", X"431d67c49c100d4c",
        X"4cc5d4becb3e42b6", X"597f299cfc657e2a", X"5fcb6fab3ad6faec", X"6c44198c4a475817"
    );
    
    --Message schedule, W(00), W(01), ...W(63) (80 64-bit words)
    signal W : K_DATA := (
        --address 0
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000",
        X"0000000000000000", X"0000000000000000", X"0000000000000000", X"0000000000000000"
    );
    
    --Hash values w/ initial hash values; 8 64-bit words
    signal HV : H_DATA;
    signal HV_INITIAL_VALUES : H_DATA := ( X"6a09e667f3bcc908", X"bb67ae8584caa73b",
                                        X"3c6ef372fe94f82b", X"a54ff53a5f1d36f1",
                                        X"510e527fade682d1", X"9b05688c2b3e6c1f",
                                        X"1f83d9abfb41bd6b", X"5be0cd19137e2179");
    
    --intermediate Message block values; for use with a for-generate loop;
    signal M_INT : M_DATA;
    
    --intermediate Message Schedule values; for use with a for-generate loop;
    signal W_INT : K_DATA;
    
    
    type SHA_512_HASH_CORE_STATE is ( RESET, IDLE, READ_MSG_BLOCK, PREP_MSG_SCHEDULE_00, PREP_MSG_SCHEDULE_01, PREP_MSG_SCHEDULE_02, PREP_MSG_SCHEDULE_03, PREP_MSG_SCHEDULE_04, HASH_01, HASH_02, HASH_02b, HASH_02c, HASH_03, DONE );
    signal CURRENT_STATE, NEXT_STATE : SHA_512_HASH_CORE_STATE;
    signal PREVIOUS_STATE : SHA_512_HASH_CORE_STATE := READ_MSG_BLOCK;
begin


    --current state logic
    process(clk, rst)
    begin
        if(rst=RESET_VALUE) then
            CURRENT_STATE <= RESET;
        elsif(clk'event and clk='1') then
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end process;
    
    
    --next state logic
    process(CURRENT_STATE, HASH_ROUND_COUNTER, HASH_02_COUNTER, rst, data_ready)
    begin
        case CURRENT_STATE is
            when RESET =>
                if(rst=RESET_VALUE) then
                    NEXT_STATE <= RESET;
                else
                    NEXT_STATE <= IDLE;
                end if;
            when IDLE =>
                if(data_ready='1') then
                    NEXT_STATE <= READ_MSG_BLOCK;
                else
                    NEXT_STATE <= IDLE;
                end if;
            when READ_MSG_BLOCK =>
                NEXT_STATE <= PREP_MSG_SCHEDULE_00;
            when PREP_MSG_SCHEDULE_00 =>
                NEXT_STATE <= PREP_MSG_SCHEDULE_01;
            when PREP_MSG_SCHEDULE_01 =>
                NEXT_STATE <= PREP_MSG_SCHEDULE_02;
            when PREP_MSG_SCHEDULE_02 =>
                NEXT_STATE <= PREP_MSG_SCHEDULE_03;
            when PREP_MSG_SCHEDULE_03 =>
                NEXT_STATE <= PREP_MSG_SCHEDULE_04;
            when PREP_MSG_SCHEDULE_04 =>
                NEXT_STATE <= HASH_01;
            when HASH_01 =>
                NEXT_STATE <= HASH_02;
            when HASH_02 =>
                if(HASH_02_COUNTER = HASH_02_COUNT_LIMIT) then
                    NEXT_STATE <= HASH_03;
                else
                    NEXT_STATE <= HASH_02b;
                end if;
            when HASH_02b =>
                    NEXT_STATE <= HASH_02c;
            when HASH_02c =>
                    NEXT_STATE <= HASH_02;
            when HASH_03 =>
                if(HASH_ROUND_COUNTER = n_blocks-1) then
                    NEXT_STATE <= DONE;
                else
                    NEXT_STATE <= IDLE;
                end if;
            when DONE =>
                NEXT_STATE <= DONE; --stay in done state unless reset
        end case;
    end process;
    
    
    --hash logic
    process(clk, rst, CURRENT_STATE)
    begin
        if(rst=RESET_VALUE) then
            HASH_ROUND_COUNTER <= 0;
            MSG_BLOCK_COUNTER <= 0;
        elsif(clk'event and clk='1') then
            a <= a;     b <= b;     c <= c;     d <= d;
            e <= e;     f <= f;     g <= g;     h <= h;
            T1 <= T1;   T2 <= T2;
            W <= W;     M <= M;     HV <= HV;
            HASH_02_COUNTER <= HASH_02_COUNTER;
            HASH_ROUND_COUNTER <= HASH_ROUND_COUNTER;
            case CURRENT_STATE is
                when RESET =>
                    HV <= HV_INITIAL_VALUES;
                    HASH_02_COUNTER <= 0;
                    HASH_ROUND_COUNTER <= 0;
                when IDLE =>    --the IDLE stage is a stall stage, perhaps waiting for new message block to arrive.
                when READ_MSG_BLOCK =>
                    if(HASH_ROUND_COUNTER = 0) then
                        HV <= HV_INITIAL_VALUES;
                    end if;
                    M <= M_INT;
                when PREP_MSG_SCHEDULE_00 =>
                    W(0 to 15) <= W_INT(0 to 15);
                when PREP_MSG_SCHEDULE_01 =>
                    W(16 to 31) <= W_INT(16 to 31);
                when PREP_MSG_SCHEDULE_02 =>
                    W(32 to 47) <= W_INT(32 to 47);
                when PREP_MSG_SCHEDULE_03 =>
                    W(48 to 63) <= W_INT(48 to 63);
                when PREP_MSG_SCHEDULE_04 =>
                    W(64 to 79) <= W_INT(64 to 79);
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
                    if(HASH_02_COUNTER = HASH_02_COUNT_LIMIT) then
                        HASH_02_COUNTER <= 0;
                    else
                        --you have to set T1 and T2 in a different state, due to how
                        --VHDL sequential/process statements are evaluated.
                        T1 <= std_logic_vector(unsigned(h) + unsigned(SIGMA_UCASE_1(e)) + unsigned(CH(e, f, g)) + unsigned(K(HASH_02_COUNTER)) + unsigned(W(HASH_02_COUNTER)));
                        T2 <= std_logic_vector(unsigned(SIGMA_UCASE_0(a)) + unsigned(MAJ(a, b, c)));
                    end if;
                when HASH_02b =>
                    h <= g;
                    g <= f;
                    f <= e;
                    e <= std_logic_vector(unsigned(d) + unsigned(T1));
                    d <= c;
                    c <= b;
                    b <= a;
                    a <= std_logic_vector(unsigned(T1) + unsigned(T2));
                when HASH_02c =>
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
        --M_INT(i) <= msg_block_in((WORD_SIZE * (i+1))-1 downto WORD_SIZE * i);
        M_INT(i) <= msg_block_in((WORD_SIZE * i) to WORD_SIZE * (i+1)-1);
    end generate;
    
    MESSAGE_SCHEDULE_INTERMEDIATE_00:
    for i in 0 to 15 generate
    begin
        W_INT(i) <= M(i);
    end generate;
    
    MESSAGE_SCHEDULE_INTERMEDIATE_01:
    for i in 16 to 79 generate
    begin
        W_INT(i) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W_INT(i-2))) + unsigned(W_INT(i-7)) + unsigned(SIGMA_LCASE_0(W_INT(i-15))) + unsigned(W_INT(i-16)));
    end generate;
    
    --FINISHED signal asserts when hashing is done
    finished <= '1' when CURRENT_STATE = DONE else
                '0';
                
    data_out <= HV(0) & HV(1) & HV(2) & HV(3) & HV(4) & HV(5) & HV(6) & HV(7);
end architecture;










