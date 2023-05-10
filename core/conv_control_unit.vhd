library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity conv_control_unit is
	port(
		opcode  : in std_logic_vector( 4 downto 0);
		funct3  : in std_logic_vector( 2 downto 0);
--		funct7  : in std_logic_vector( 6 downto 0);
        
		-- ALU operation:
		conv_op : out conv_operation;

        -- Control signal:
        conv_rd_write : out std_logic;
		is_conv_opr		: out std_logic


	);
end entity conv_control_unit;

architecture behaviour of conv_control_unit is
   	signal conv_opr : conv_operation;
begin
    decode_conv_op: process(opcode, funct3)
    begin
        case opcode is
            when b"01010" =>
                case funct3 is
                    when b"000" =>
                        conv_op <= MX_CONV;
                    -- when b"101" =>
                    -- when b"010" =>
                    -- when b"100" => 
                    when b"111" => 
                        conv_op <= MX_CLEAR;
                    when others =>
                        conv_op <= MX_NOP;
                end case;
            when others => 
                conv_op <= MX_NOP;
        end case;
    end process;
    
	decode_conv_ctrl: process(opcode, funct3)
    begin
        case opcode is
            when b"00010" =>
                is_conv_opr	<= '1';
                if ((funct3 = b"000") or (funct3 = b"001")
                        or (funct3 = b"010") or (funct3 = b"011")) then
                    conv_rd_write <= '1';
                else
                    conv_rd_write <= '0';
                end if;
            when b"01010" =>
                is_conv_opr	<= '1';
                if (funct3 = b"000") then
                    conv_rd_write <= '1';
                else 
                    conv_rd_write <= '0';
                end if;
            when others => 
                is_conv_opr	<= '0';
                conv_rd_write <= '0';
                
        end case;
    end process;

end architecture;

