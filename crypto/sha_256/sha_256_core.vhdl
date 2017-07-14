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
    signal T1 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal T2 : std_logic_vector(WORD_WIDTH-1 downto 0);

    --Working variables, 8 32-bit words
    signal a : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal b : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal c : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal d : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal e : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal f : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal g : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal h : std_logic_vector(WORD_WIDTH-1 downto 0);
    
    --Hash values w/ initial hash values; 8 32-bit words
    signal H0 : std_logic_vector(WORD_WIDTH-1 downto 0) := X"6a09e667";
    signal H1 : std_logic_vector(WORD_WIDTH-1 downto 0) := X"bb67ae85";
    signal H2 : std_logic_vector(WORD_WIDTH-1 downto 0) := X"3c6ef372";
    signal H3 : std_logic_vector(WORD_WIDTH-1 downto 0) := X"a54ff53a";
    signal H4 : std_logic_vector(WORD_WIDTH-1 downto 0) := X"510e527f";
    signal H5 : std_logic_vector(WORD_WIDTH-1 downto 0) := X"9b05688c";
    signal H6 : std_logic_vector(WORD_WIDTH-1 downto 0) := X"1f83d9ab";
    signal H7 : std_logic_vector(WORD_WIDTH-1 downto 0) := X"5be0cd19";
    
    
    --Message blocks, the padded message should be a multiple of 512 bits,
    signal M00 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M01 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M02 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M03 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M04 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M05 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M06 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M07 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M08 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M09 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M10 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M11 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M12 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M13 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M14 : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal M15 : std_logic_vector(WORD_WIDTH-1 downto 0);
    
    type SHA_256_HASH_CORE_STATE is ( RESET, IDLE_STATE, READ_MSG_BLOCK, HASH_00, HASH_01, HASH_02, HASH_03, DONE );
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
    
    --next state logic, and hash logic
    process(clk, rst, idle)
    begin
        if(rst=RESET_VALUE) then
            HASH_ROUND_COUNTER <= 0;
            MSG_BLOCK_COUNTER <= 0;
            NEXT_STATE <= RESET;
        elsif(idle=IDLE_VALUE) then
            NEXT_STATE <= IDLE_STATE;
        elsif(clk'event and clk='1') then
            case CURRENT_STATE is
                when RESET =>
                    H0 <= X"6a09e667";
                    H1 <= X"bb67ae85";
                    H2 <= X"3c6ef372";
                    H3 <= X"a54ff53a";
                    H4 <= X"510e527f";
                    H5 <= X"9b05688c";
                    H6 <= X"1f83d9ab";
                    H7 <= X"5be0cd19";
                    
                    NEXT_STATE <= READ_MSG_BLOCK;
                when IDLE_STATE =>    --the IDLE_STATE stage is a stall stage, perhaps waiting for new message block to arrive.
                    NEXT_STATE <= PREVIOUS_STATE;
                when READ_MSG_BLOCK =>
                    M00 <= msg_block_in(WORD_WIDTH-1 downto 0);
                    M01 <= msg_block_in((WORD_WIDTH * 2)-1 downto WORD_WIDTH * 1);
                    M02 <= msg_block_in((WORD_WIDTH * 3)-1 downto WORD_WIDTH * 2);
                    M03 <= msg_block_in((WORD_WIDTH * 4)-1 downto WORD_WIDTH * 3);
                    M04 <= msg_block_in((WORD_WIDTH * 5)-1 downto WORD_WIDTH * 4);
                    M05 <= msg_block_in((WORD_WIDTH * 6)-1 downto WORD_WIDTH * 5);
                    M06 <= msg_block_in((WORD_WIDTH * 7)-1 downto WORD_WIDTH * 6);
                    M07 <= msg_block_in((WORD_WIDTH * 8)-1 downto WORD_WIDTH * 7);
                    M08 <= msg_block_in((WORD_WIDTH * 9)-1 downto WORD_WIDTH * 8);
                    M09 <= msg_block_in((WORD_WIDTH * 10)-1 downto WORD_WIDTH * 9);
                    M10 <= msg_block_in((WORD_WIDTH * 11)-1 downto WORD_WIDTH * 10);
                    M11 <= msg_block_in((WORD_WIDTH * 12)-1 downto WORD_WIDTH * 11);
                    M12 <= msg_block_in((WORD_WIDTH * 13)-1 downto WORD_WIDTH * 12);
                    M13 <= msg_block_in((WORD_WIDTH * 14)-1 downto WORD_WIDTH * 13);
                    M14 <= msg_block_in((WORD_WIDTH * 15)-1 downto WORD_WIDTH * 14);
                    M15 <= msg_block_in((WORD_WIDTH * 16)-1 downto WORD_WIDTH * 15);
                    
                    NEXT_STATE <= HASH_00;
                when HASH_00 =>
                    W(0) <= M00;
                    W(1) <= M01;
                    W(2) <= M02;
                    W(3) <= M03;
                    W(4) <= M04;
                    W(5) <= M05;
                    W(6) <= M06;
                    W(7) <= M07;
                    W(8) <= M08;
                    W(9) <= M09;
                    W(10) <= M10;
                    W(11) <= M11;
                    W(12) <= M12;
                    W(13) <= M13;
                    W(14) <= M14;
                    W(15) <= M15;
                    W(16) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(14))) + unsigned(W(09)) + unsigned(SIGMA_LCASE_0(W(01))) + unsigned(W(00)));
                    W(17) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(15))) + unsigned(W(10)) + unsigned(SIGMA_LCASE_0(W(02))) + unsigned(W(01)));
                    W(18) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(16))) + unsigned(W(11)) + unsigned(SIGMA_LCASE_0(W(03))) + unsigned(W(02)));
                    W(19) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(17))) + unsigned(W(12)) + unsigned(SIGMA_LCASE_0(W(04))) + unsigned(W(03)));
                    
                    W(20) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(18))) + unsigned(W(13)) + unsigned(SIGMA_LCASE_0(W(05))) + unsigned(W(04)));
                    W(21) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(19))) + unsigned(W(14)) + unsigned(SIGMA_LCASE_0(W(06))) + unsigned(W(05)));
                    W(22) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(20))) + unsigned(W(15)) + unsigned(SIGMA_LCASE_0(W(07))) + unsigned(W(06)));
                    W(23) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(21))) + unsigned(W(16)) + unsigned(SIGMA_LCASE_0(W(08))) + unsigned(W(07)));
                    W(24) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(22))) + unsigned(W(17)) + unsigned(SIGMA_LCASE_0(W(09))) + unsigned(W(08)));
                    W(25) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(23))) + unsigned(W(18)) + unsigned(SIGMA_LCASE_0(W(10))) + unsigned(W(09)));
                    W(26) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(24))) + unsigned(W(19)) + unsigned(SIGMA_LCASE_0(W(11))) + unsigned(W(10)));
                    W(27) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(25))) + unsigned(W(20)) + unsigned(SIGMA_LCASE_0(W(12))) + unsigned(W(11)));
                    W(28) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(26))) + unsigned(W(21)) + unsigned(SIGMA_LCASE_0(W(13))) + unsigned(W(12)));
                    W(29) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(27))) + unsigned(W(22)) + unsigned(SIGMA_LCASE_0(W(14))) + unsigned(W(13)));
                    
                    W(30) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(28))) + unsigned(W(23)) + unsigned(SIGMA_LCASE_0(W(15))) + unsigned(W(14)));
                    W(31) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(29))) + unsigned(W(24)) + unsigned(SIGMA_LCASE_0(W(16))) + unsigned(W(15)));
                    W(32) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(30))) + unsigned(W(25)) + unsigned(SIGMA_LCASE_0(W(17))) + unsigned(W(16)));
                    W(33) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(31))) + unsigned(W(26)) + unsigned(SIGMA_LCASE_0(W(18))) + unsigned(W(17)));
                    W(34) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(32))) + unsigned(W(27)) + unsigned(SIGMA_LCASE_0(W(19))) + unsigned(W(18)));
                    W(35) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(33))) + unsigned(W(28)) + unsigned(SIGMA_LCASE_0(W(20))) + unsigned(W(19)));
                    W(36) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(34))) + unsigned(W(29)) + unsigned(SIGMA_LCASE_0(W(21))) + unsigned(W(20)));
                    W(37) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(35))) + unsigned(W(30)) + unsigned(SIGMA_LCASE_0(W(22))) + unsigned(W(21)));
                    W(38) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(36))) + unsigned(W(31)) + unsigned(SIGMA_LCASE_0(W(23))) + unsigned(W(22)));
                    W(39) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(37))) + unsigned(W(32)) + unsigned(SIGMA_LCASE_0(W(24))) + unsigned(W(23)));
                    
                    W(40) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(38))) + unsigned(W(33)) + unsigned(SIGMA_LCASE_0(W(25))) + unsigned(W(24)));
                    W(41) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(39))) + unsigned(W(34)) + unsigned(SIGMA_LCASE_0(W(26))) + unsigned(W(25)));
                    W(42) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(40))) + unsigned(W(35)) + unsigned(SIGMA_LCASE_0(W(27))) + unsigned(W(26)));
                    W(43) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(41))) + unsigned(W(36)) + unsigned(SIGMA_LCASE_0(W(28))) + unsigned(W(27)));
                    W(44) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(42))) + unsigned(W(37)) + unsigned(SIGMA_LCASE_0(W(29))) + unsigned(W(28)));
                    W(45) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(43))) + unsigned(W(38)) + unsigned(SIGMA_LCASE_0(W(30))) + unsigned(W(29)));
                    W(46) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(44))) + unsigned(W(39)) + unsigned(SIGMA_LCASE_0(W(31))) + unsigned(W(30)));
                    W(47) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(45))) + unsigned(W(40)) + unsigned(SIGMA_LCASE_0(W(32))) + unsigned(W(31)));
                    W(48) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(46))) + unsigned(W(41)) + unsigned(SIGMA_LCASE_0(W(33))) + unsigned(W(32)));
                    W(49) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(47))) + unsigned(W(42)) + unsigned(SIGMA_LCASE_0(W(34))) + unsigned(W(33)));
                    
                    W(50) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(48))) + unsigned(W(43)) + unsigned(SIGMA_LCASE_0(W(35))) + unsigned(W(34)));
                    W(51) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(49))) + unsigned(W(44)) + unsigned(SIGMA_LCASE_0(W(36))) + unsigned(W(35)));
                    W(52) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(50))) + unsigned(W(45)) + unsigned(SIGMA_LCASE_0(W(37))) + unsigned(W(36)));
                    W(53) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(51))) + unsigned(W(46)) + unsigned(SIGMA_LCASE_0(W(38))) + unsigned(W(37)));
                    W(54) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(52))) + unsigned(W(47)) + unsigned(SIGMA_LCASE_0(W(39))) + unsigned(W(38)));
                    W(55) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(53))) + unsigned(W(48)) + unsigned(SIGMA_LCASE_0(W(40))) + unsigned(W(39)));
                    W(56) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(54))) + unsigned(W(49)) + unsigned(SIGMA_LCASE_0(W(41))) + unsigned(W(40)));
                    W(57) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(55))) + unsigned(W(50)) + unsigned(SIGMA_LCASE_0(W(42))) + unsigned(W(41)));
                    W(58) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(56))) + unsigned(W(51)) + unsigned(SIGMA_LCASE_0(W(43))) + unsigned(W(42)));
                    W(59) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(57))) + unsigned(W(52)) + unsigned(SIGMA_LCASE_0(W(44))) + unsigned(W(43)));
                    
                    W(60) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(58))) + unsigned(W(53)) + unsigned(SIGMA_LCASE_0(W(45))) + unsigned(W(44)));
                    W(61) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(59))) + unsigned(W(54)) + unsigned(SIGMA_LCASE_0(W(46))) + unsigned(W(45)));
                    W(62) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(60))) + unsigned(W(55)) + unsigned(SIGMA_LCASE_0(W(47))) + unsigned(W(46)));
                    W(63) <= std_logic_vector(unsigned(SIGMA_LCASE_1(W(61))) + unsigned(W(56)) + unsigned(SIGMA_LCASE_0(W(48))) + unsigned(W(47)));
                    
                    NEXT_STATE <= HASH_01;
                when HASH_01 =>
                    a <= H0;
                    b <= H1;
                    c <= H2;
                    d <= H3;
                    e <= H4;
                    f <= H5;
                    g <= H6;
                    h <= H7;
                    NEXT_STATE <= HASH_02;
                when HASH_02 =>
                    if(HASH_02_COUNTER = HASH_02_COUNT_LIMIT) then
                        HASH_02_COUNTER <= 0;
                        NEXT_STATE <= HASH_03;
                    else
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
                    end if;
                when HASH_03 =>
                    H0 <= std_logic_vector(unsigned(a) + unsigned(H0));
                    H1 <= std_logic_vector(unsigned(b) + unsigned(H1));
                    H2 <= std_logic_vector(unsigned(c) + unsigned(H2));
                    H3 <= std_logic_vector(unsigned(d) + unsigned(H3));
                    H4 <= std_logic_vector(unsigned(e) + unsigned(H4));
                    H5 <= std_logic_vector(unsigned(f) + unsigned(H5));
                    H6 <= std_logic_vector(unsigned(g) + unsigned(H6));
                    H7 <= std_logic_vector(unsigned(h) + unsigned(H7));
                    if(HASH_ROUND_COUNTER = n_blocks) then
                        HASH_ROUND_COUNTER <= 0;
                        NEXT_STATE <= DONE;
                    else
                        HASH_ROUND_COUNTER <= HASH_ROUND_COUNTER + 1;    --increment counter, read in next message block
                        NEXT_STATE <= READ_MSG_BLOCK;
                    end if;
                when DONE =>
                    NEXT_STATE <= DONE; --stay in done state unless reset
            end case;
        end if;
    end process;
    
    --FINISHED signal asserts when hashing is done
    finished <= '1' when CURRENT_STATE = DONE else
                '0';
                
    data_out <= H0 & H1 & H2 & H3 & H4 & H5 & H6 & H7;
end architecture;










