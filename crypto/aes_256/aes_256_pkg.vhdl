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

package aes_256_pkg is

    constant BYTE_SIZE : natural := 8;
    constant NB : natural := 4;
    
    --type BYTE_T is std_logic_vector(BYTE_SIZE-1 downto 0);
    --type ROW is array(natural range <>) of BYTE_T
    --type t_row_vector is array(natural range <>) of t_byte
    
    --subtype t_byte is std_logic_vector(BYTE_SIZE-1 downto 0);
    --type t_row_vector is array(natural range <>) of t_byte;
    --subtype t_dim2 is t_row_vector(0 to c1_r2);
    --type t_dim3_vector is array(natural range <>) of t_dim2;
    --subtype t_dim3 is t_dim3_vector(0 to r1);
    
    --function definitions
    function SUB_BYTES (xy : std_logic_vector(BYTE_SIZE-1 downto 0))
                    return std_logic_vector;
                    
    --function SHIFT_ROW (r : ROW; n : natural ) return ROW;
                    
end package;


package body aes_256_pkg is
    function SUB_BYTES (xy : std_logic_vector(BYTE_SIZE-1 downto 0))
                    return std_logic_vector is
    begin
        case xy is
            when X"00" => return X"63";     when X"01" => return X"7C";
            when X"02" => return X"77";     when X"03" => return X"7B";
            when X"04" => return X"F2";     when X"05" => return X"6B";
            when X"06" => return X"6F";     when X"07" => return X"C5";
            when X"08" => return X"30";     when X"09" => return X"01";
            when X"0A" => return X"67";     when X"0B" => return X"2B";
            when X"0C" => return X"FE";     when X"0D" => return X"D7";
            when X"0E" => return X"AB";     when X"0F" => return X"76";
            
            
            when X"10" => return X"CA";     when X"11" => return X"82";
            when X"12" => return X"C9";     when X"13" => return X"7D";
            when X"14" => return X"FA";     when X"15" => return X"59";
            when X"16" => return X"47";     when X"17" => return X"F0";
            when X"18" => return X"AD";     when X"19" => return X"D4";
            when X"1A" => return X"A2";     when X"1B" => return X"AF";
            when X"1C" => return X"9C";     when X"1D" => return X"A4";
            when X"1E" => return X"72";     when X"1F" => return X"C0";
            
            when X"20" => return X"B7";     when X"21" => return X"FD";
            when X"22" => return X"93";     when X"23" => return X"26";
            when X"24" => return X"36";     when X"25" => return X"3F";
            when X"26" => return X"F7";     when X"27" => return X"CC";
            when X"28" => return X"34";     when X"29" => return X"A5";
            when X"2A" => return X"E5";     when X"2B" => return X"F1";
            when X"2C" => return X"71";     when X"2D" => return X"D8";
            when X"2E" => return X"31";     when X"2F" => return X"15";
            
            when X"30" => return X"04";     when X"31" => return X"C7";
            when X"32" => return X"23";     when X"33" => return X"C3";
            when X"34" => return X"18";     when X"35" => return X"96";
            when X"36" => return X"05";     when X"37" => return X"9A";
            when X"38" => return X"07";     when X"39" => return X"12";
            when X"3A" => return X"80";     when X"3B" => return X"E2";
            when X"3C" => return X"EB";     when X"3D" => return X"27";
            when X"3E" => return X"B2";     when X"3F" => return X"75";
            
            when X"40" => return X"09";     when X"41" => return X"83";
            when X"42" => return X"2C";     when X"43" => return X"1A";
            when X"44" => return X"1B";     when X"45" => return X"6E";
            when X"46" => return X"5A";     when X"47" => return X"A0";
            when X"48" => return X"52";     when X"49" => return X"3B";
            when X"4A" => return X"D6";     when X"4B" => return X"B3";
            when X"4C" => return X"29";     when X"4D" => return X"E3";
            when X"4E" => return X"2F";     when X"4F" => return X"84";
            
            when X"50" => return X"53";     when X"51" => return X"D1";
            when X"52" => return X"00";     when X"53" => return X"ED";
            when X"54" => return X"20";     when X"55" => return X"FC";
            when X"56" => return X"B1";     when X"57" => return X"5B";
            when X"58" => return X"6A";     when X"59" => return X"CB";
            when X"5A" => return X"BE";     when X"5B" => return X"39";
            when X"5C" => return X"4A";     when X"5D" => return X"4C";
            when X"5E" => return X"58";     when X"5F" => return X"CF";
            
            when X"60" => return X"D0";     when X"61" => return X"EF";
            when X"62" => return X"AA";     when X"63" => return X"FB";
            when X"64" => return X"43";     when X"65" => return X"4D";
            when X"66" => return X"33";     when X"67" => return X"85";
            when X"68" => return X"45";     when X"69" => return X"F9";
            when X"6A" => return X"02";     when X"6B" => return X"7F";
            when X"6C" => return X"50";     when X"6D" => return X"3C";
            when X"6E" => return X"9F";     when X"6F" => return X"A8";
            
            when X"70" => return X"51";     when X"71" => return X"A3";
            when X"72" => return X"40";     when X"73" => return X"8F";
            when X"74" => return X"92";     when X"75" => return X"9D";
            when X"76" => return X"38";     when X"77" => return X"F5";
            when X"78" => return X"BC";     when X"79" => return X"B6";
            when X"7A" => return X"DA";     when X"7B" => return X"21";
            when X"7C" => return X"10";     when X"7D" => return X"FF";
            when X"7E" => return X"F3";     when X"7F" => return X"D2";
            
            when X"80" => return X"CD";     when X"81" => return X"0C";
            when X"82" => return X"13";     when X"83" => return X"EC";
            when X"84" => return X"5F";     when X"85" => return X"97";
            when X"86" => return X"44";     when X"87" => return X"17";
            when X"88" => return X"C4";     when X"89" => return X"A7";
            when X"8A" => return X"7E";     when X"8B" => return X"3D";
            when X"8C" => return X"64";     when X"8D" => return X"5D";
            when X"8E" => return X"19";     when X"8F" => return X"73";
            
            when X"90" => return X"60";     when X"91" => return X"81";
            when X"92" => return X"4F";     when X"93" => return X"DC";
            when X"94" => return X"22";     when X"95" => return X"2A";
            when X"96" => return X"90";     when X"97" => return X"88";
            when X"98" => return X"46";     when X"99" => return X"EE";
            when X"9A" => return X"B8";     when X"9B" => return X"14";
            when X"9C" => return X"DE";     when X"9D" => return X"5E";
            when X"9E" => return X"0B";     when X"9F" => return X"DB";
            
            when X"A0" => return X"E0";     when X"A1" => return X"32";
            when X"A2" => return X"3A";     when X"A3" => return X"0A";
            when X"A4" => return X"49";     when X"A5" => return X"06";
            when X"A6" => return X"24";     when X"A7" => return X"5C";
            when X"A8" => return X"C2";     when X"A9" => return X"D3";
            when X"AA" => return X"AC";     when X"AB" => return X"62";
            when X"AC" => return X"91";     when X"AD" => return X"95";
            when X"AE" => return X"E4";     when X"AF" => return X"79";
            
            when X"B0" => return X"E7";     when X"B1" => return X"C8";
            when X"B2" => return X"37";     when X"B3" => return X"6D";
            when X"B4" => return X"8D";     when X"B5" => return X"D5";
            when X"B6" => return X"4E";     when X"B7" => return X"A9";
            when X"B8" => return X"6C";     when X"B9" => return X"56";
            when X"BA" => return X"F4";     when X"BB" => return X"EA";
            when X"BC" => return X"65";     when X"BD" => return X"7A";
            when X"BE" => return X"AE";     when X"BF" => return X"08";
            
            when X"C0" => return X"BA";     when X"C1" => return X"78";
            when X"C2" => return X"25";     when X"C3" => return X"2E";
            when X"C4" => return X"1C";     when X"C5" => return X"A6";
            when X"C6" => return X"B4";     when X"C7" => return X"C6";
            when X"C8" => return X"E8";     when X"C9" => return X"DD";
            when X"CA" => return X"74";     when X"CB" => return X"1F";
            when X"CC" => return X"4B";     when X"CD" => return X"BD";
            when X"CE" => return X"8B";     when X"CF" => return X"8A";
            
            when X"D0" => return X"70";     when X"D1" => return X"3E";
            when X"D2" => return X"B5";     when X"D3" => return X"66";
            when X"D4" => return X"48";     when X"D5" => return X"03";
            when X"D6" => return X"F6";     when X"D7" => return X"0E";
            when X"D8" => return X"61";     when X"D9" => return X"35";
            when X"DA" => return X"57";     when X"DB" => return X"B9";
            when X"DC" => return X"86";     when X"DD" => return X"C1";
            when X"DE" => return X"1D";     when X"DF" => return X"9E";
            
            when X"E0" => return X"E1";     when X"E1" => return X"F8";
            when X"E2" => return X"98";     when X"E3" => return X"11";
            when X"E4" => return X"69";     when X"E5" => return X"D9";
            when X"E6" => return X"8E";     when X"E7" => return X"94";
            when X"E8" => return X"9B";     when X"E9" => return X"1E";
            when X"EA" => return X"87";     when X"EB" => return X"E9";
            when X"EC" => return X"CE";     when X"ED" => return X"55";
            when X"EE" => return X"28";     when X"EF" => return X"DF";
            
            when X"F0" => return X"8C";     when X"F1" => return X"A1";
            when X"F2" => return X"89";     when X"F3" => return X"0D";
            when X"F4" => return X"BF";     when X"F5" => return X"E6";
            when X"F6" => return X"42";     when X"F7" => return X"68";
            when X"F8" => return X"41";     when X"F9" => return X"99";
            when X"FA" => return X"2D";     when X"FB" => return X"0F";
            when X"FC" => return X"B0";     when X"FD" => return X"54";
            when X"FE" => return X"BB";     when X"FF" => return X"16";
            
            when others => return X"00";
        end case;
    end function;
    
    --function SHIFT_ROW (r : ROW; n : natural ) return ROW is
    --    variable temp_byte : std_logic_vector(BYTE_SIZE-1 downto 0);
    --begin
    --    return shift_left(unsigned(r), n*BYTE_SIZE);
    --end function;
    
end package body;

