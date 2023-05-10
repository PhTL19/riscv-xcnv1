library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity tb_conv_alu is
end entity tb_conv_alu;

architecture rtl of tb_conv_alu is
    constant c_PERIOD   : time := 10 ns;
            
    signal clk, reset   : std_logic := '0';
    constant conv_opr   : conv_operation := MX_CONV;
    type array16 is array(0 to 97) of std_logic_vector(15 downto 0);
    signal img : std_logic_vector(1567 downto 0) := (others => '0') ;
    signal input    : array16 := (others => (others => '0'));
    signal output   : std_logic_vector(31 downto 0);

    begin
        UUT : entity work.conv_alu
        port map (
            conv_opr => conv_opr,
            input_img => img(783 downto 0),
            input_kn => img(1567 downto 784),
            output => output
        );
    
        p_clk_gen : process
        begin
            clk <= not clk;
            wait for c_PERIOD;
        end process;

        input1: for i in 0 to 97 generate
            img(16*i+15 downto 16*i) <= input(i)(15 downto 0);
        end generate;
            
        p_test : process
        begin
            input(0)(15 downto 0) <= std_logic_vector(to_signed(0, 16));
            input(1)(15 downto 0) <= std_logic_vector(to_signed(55, 16));
            input(2)(15 downto 0) <= std_logic_vector(to_signed(12, 16));
            input(3)(15 downto 0) <= std_logic_vector(to_signed(31, 16));
            input(4)(15 downto 0) <= std_logic_vector(to_signed(47, 16));

            input(5)(15 downto 0) <= std_logic_vector(to_signed(28, 16));
            input(6)(15 downto 0) <= std_logic_vector(to_signed(7, 16));
            input(7)(15 downto 0) <= std_logic_vector(to_signed(25, 16));
            input(8)(15 downto 0) <= std_logic_vector(to_signed(5, 16));
            input(9)(15 downto 0) <= std_logic_vector(to_signed(22, 16));
            
            input(10)(15 downto 0) <= std_logic_vector(to_signed(31, 16));
            input(11)(15 downto 0) <= std_logic_vector(to_signed(7, 16));
            input(12)(15 downto 0) <= std_logic_vector(to_signed(59, 16));
            input(13)(15 downto 0) <= std_logic_vector(to_signed(13, 16));
            input(14)(15 downto 0) <= std_logic_vector(to_signed(20, 16));
            
            input(15)(15 downto 0) <= std_logic_vector(to_signed(24, 16));
            input(16)(15 downto 0) <= std_logic_vector(to_signed(50, 16));
            input(17)(15 downto 0) <= std_logic_vector(to_signed(1, 16));
            input(18)(15 downto 0) <= std_logic_vector(to_signed(52, 16));
            input(19)(15 downto 0) <= std_logic_vector(to_signed(58, 16));
            
            input(20)(15 downto 0) <= std_logic_vector(to_signed(49, 16));
            input(21)(15 downto 0) <= std_logic_vector(to_signed(31, 16));
            input(22)(15 downto 0) <= std_logic_vector(to_signed(29, 16));
            input(23)(15 downto 0) <= std_logic_vector(to_signed(33, 16));
            input(24)(15 downto 0) <= std_logic_vector(to_signed(30, 16));

            input(49)(15 downto 0) <= std_logic_vector(to_signed(-4, 16));
            input(50)(15 downto 0) <= std_logic_vector(to_signed(5, 16));
            input(51)(15 downto 0) <= std_logic_vector(to_signed(-10, 16));
            input(52)(15 downto 0) <= std_logic_vector(to_signed(-2, 16));
            input(53)(15 downto 0) <= std_logic_vector(to_signed(-12, 16));
            
            input(54)(15 downto 0) <= std_logic_vector(to_signed(9, 16));
            input(55)(15 downto 0) <= std_logic_vector(to_signed(-12, 16));
            input(56)(15 downto 0) <= std_logic_vector(to_signed(9, 16));
            input(57)(15 downto 0) <= std_logic_vector(to_signed(-7, 16));
            input(58)(15 downto 0) <= std_logic_vector(to_signed(-4, 16));
            
            input(59)(15 downto 0) <= std_logic_vector(to_signed(2, 16));
            input(60)(15 downto 0) <= std_logic_vector(to_signed(-7, 16));
            input(61)(15 downto 0) <= std_logic_vector(to_signed(0, 16));
            input(62)(15 downto 0) <= std_logic_vector(to_signed(9, 16));
            input(63)(15 downto 0) <= std_logic_vector(to_signed(-4, 16));
            
            input(64)(15 downto 0) <= std_logic_vector(to_signed(4, 16));
            input(65)(15 downto 0) <= std_logic_vector(to_signed(9, 16));
            input(66)(15 downto 0) <= std_logic_vector(to_signed(-1, 16));
            input(67)(15 downto 0) <= std_logic_vector(to_signed(-7, 16));
            input(68)(15 downto 0) <= std_logic_vector(to_signed(-3, 16));
            
            input(69)(15 downto 0) <= std_logic_vector(to_signed(-12, 16));
            input(70)(15 downto 0) <= std_logic_vector(to_signed(-2, 16));
            input(71)(15 downto 0) <= std_logic_vector(to_signed(-9, 16));
            input(72)(15 downto 0) <= std_logic_vector(to_signed(-12, 16));
            input(73)(15 downto 0) <= std_logic_vector(to_signed(-12, 16));
    
            reset <= '1';
            wait for 50 ns;
            reset <= '0';
            wait;
    
        end process;
    end architecture;
    