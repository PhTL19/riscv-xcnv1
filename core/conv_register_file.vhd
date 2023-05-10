library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

--! Custom register file for convolution.
--! $0 - $48 : Registers for image in convolution
--! $49 - $97 : Registers for kernel in convolution
--! $98 : Output 
entity conv_register_file is
    port (
        clk : in std_logic;
        reset : in std_logic;
        -- Read port :
        -- rs_addr : in conv_register_address;
        rs_parallel_data_img : out std_logic_vector(783 downto 0);
        rs_parallel_data_kn  : out std_logic_vector(783 downto 0);
        res_out         : out std_logic_vector(31 downto 0);
--        pointer_out     : out std_logic_vector(31 downto 0);
        -- Write port:
        rd_addr : in conv_register_address;
        rd_data : in std_logic_vector(31 downto 0);
        
        -- rs_parallel_load : in std_logic_vector(2 downto 0);
        rd_write : in std_logic
    );
end entity conv_register_file;

architecture rtl of conv_register_file is
    --! Register array type.
    type regfile_array is array(0 to 98) of std_logic_vector(31 downto 0);
    signal registers : regfile_array := (others => (others => '0'));
    signal i : natural := 0;
begin
--    parallel_img : for i in 0 to 48 generate
--        rs_parallel_data_img(16*i+15 downto 16*i) <= registers(i)(15 downto 0);
--    end generate;

--    parallel_kn : for i in 0 to 48 generate
--        rs_parallel_data_kn(16*i+15 downto 16*i) <= registers(i+49)(15 downto 0);
--    end generate;
    
    regfile : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                registers(0 to 97) <= (others => (others => '0'));
            else         
                if rd_write = '1' then
                    registers(to_integer(unsigned(rd_addr))) <= rd_data;
                end if;
            
            end if;
            res_out <= registers(98);
            
            for i in 0 to 48 loop
                rs_parallel_data_img(16*i+15 downto 16*i) <= registers(i)(15 downto 0);
            end loop;
        
            for i in 0 to 48 loop
                rs_parallel_data_kn(16*i+15 downto 16*i) <= registers(i+49)(15 downto 0);
            end loop;            
        end if;
    end process regfile;
end architecture;