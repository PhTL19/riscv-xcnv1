library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity conv_alu is
    port (
        conv_opr    : conv_operation;
        -- input_size  : in std_logic_vector(2 downto 0);
        input_img   : in std_logic_vector(783 downto 0);
        input_kn    : in std_logic_vector(783 downto 0);
        output      : out std_logic_vector(31 downto 0)
        
    );
end entity conv_alu;

architecture rtl of conv_alu is
    type conv_array_img is array(0 to 48) of signed(16 downto 0);
    type conv_array_kn is array(0 to 48) of signed(15 downto 0);
    type conv_array_mul is array(0 to 48) of signed(31 downto 0);
    type conv_array_add is array(0 to 48) of signed(31 downto 0);

    signal conv_img: conv_array_img := (others => (others => '0')); 
    signal conv_kn : conv_array_kn := (others => (others => '0'));
    
    signal mult : conv_array_mul := (others => (others => '0'));
    signal added : conv_array_add := (others => (others => '0'));
    -- signal r_out : std_logic_vector(31 downto 0);
    
    -- signal pool_input : std_logic_vector(511 downto 0);
    -- signal sel_hi : std_logic_vector(16 downto 0) ;
    -- signal max_pool : std_logic_vector(543 downto 0);
    -- signal avg_pool : std_logic_vector(543 downto 0);
    
    -- signal actv_input, relu_output, sfmx_output : std_logic_vector(31 downto 0) := (others => '0');  
begin
    conv_input : for i in 0 to 48 generate
        conv_img(i) <=  signed('0' & input_img(16 * i + 15 downto 16*i));
        conv_kn(i) <= signed(input_kn(16 * i + 15 downto 16*i));
    end generate;
    
    -- pool_input <= input(3135 downto 2624);
    -- actv_input <= input(3135 downto 3104);
    
    -- relu_output <= actv_input when signed(actv_input) > 0 else (others => '0');    
    
    alu_mul : for i in 0 to 48 generate
        mult(i) <= resize(conv_img(i)* conv_kn(i), 32);
    end generate;

    alu_add_1 : for i in 0 to 23 generate
        added(i) <= mult(2*i) + mult(2*i+1);
    end generate;

    alu_add_2 : for i in 0 to 11 generate
        added(24+i) <= added(2*i) + added(2*i+1);
    end generate;
    
    alu_add_3 : for i in 0 to 5 generate
        added(36+i) <= added(2*i+24) + added(2*i+25);
    end generate;

    added(42) <= added(36) + added(37);
    added(43) <= added(38) + added(39);
    added(44) <= added(40) + added(41);
    added(45) <= added(42) + added(43);
    added(46) <= added(44) + mult(48);
    added(47) <= added(45) + added(46);
    
    -- alu : for i in 1 to 48 generate
    --     mult(i) <= conv_img(i)* conv_kn(i);
    --     added(i) <= resize(signed(mult(i)), 32) + added(i-1);
    -- end generate;
    
    -- pooling : for i in 0 to 15 generate
    --     avg_pool(32*i+63 downto 32*i+32) <= std_logic_vector(
    --         signed(pool_input(32*i+31 downto 32*i)) + signed(avg_pool(32*i+31 downto 32*i)));
    --     sel_hi(i) <= '1' when signed(pool_input(32*i+31 downto 32*i)) > signed(max_pool(32*i+31 downto 32*i)) else '0';
    --     with sel_hi(i) select
    --         max_pool(32*i+63 downto 32*i+32) <= pool_input(32*i+31 downto 32*i) when '1',
    --                                         max_pool(32*i+31 downto 32*i) when others;
    -- end generate;

    with conv_opr select
        output <= std_logic_vector(added(47)) when MX_CONV, 
                -- added(1599 downto 1568) when MX_FC,
                -- max_pool(543 downto 512) when MX_MAX_POOL,
                -- std_logic_vector(shift_right(signed(avg_pool(543 downto 512)), 4)) when MX_AVG_POOL,
                -- relu_output when MX_RELU,
                (others => '0') when others;


end architecture;