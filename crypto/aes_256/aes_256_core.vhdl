library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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