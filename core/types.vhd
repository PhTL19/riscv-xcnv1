-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <https://github.com/skordal/potato/issues>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
    
    --! No-operation instruction, addi x0, x0, 0.
	constant RISCV_NOP : std_logic_vector(31 downto 0) := (31 downto 5 => '0') & b"10011"; --! ADDI x0, x0, 0.


	--! Type used for register addresses.
	subtype register_address is std_logic_vector(4 downto 0);
    subtype conv_register_address is std_logic_vector(6 downto 0);

	--! The available ALU operations.
	type alu_operation is (
			ALU_AND, ALU_OR, ALU_XOR,
			ALU_SLT, ALU_SLTU,
			ALU_ADD, ALU_SUB,
			ALU_SRL, ALU_SLL, ALU_SRA,
			ALU_NOP, ALU_INVALID
		);
    
    --! Custom convolution ALU operations
    type conv_operation is (
        MX_CONV, MX_MAX_POOL, MX_AVG_POOL, MX_RELU, MX_FC, MX_NOP, MX_CLEAR
    );
    
	constant RES_REG_ADDR : conv_register_address := b"1100010";

	--! Types of branches.
	type branch_type is (
			BRANCH_NONE, BRANCH_JUMP, BRANCH_JUMP_INDIRECT, BRANCH_CONDITIONAL
		);

	--! Source of an ALU operand.
	type alu_operand_source is (
			ALU_SRC_REG, ALU_SRC_IMM, ALU_SRC_SHAMT, ALU_SRC_PC, ALU_SRC_PC_NEXT, ALU_SRC_NULL
		);

	--! Type of memory operation:
	type memory_operation_type is (
			MEMOP_TYPE_NONE, MEMOP_TYPE_INVALID, MEMOP_TYPE_LOAD, MEMOP_TYPE_LOAD_UNSIGNED, MEMOP_TYPE_STORE
		);

	--! Size of a memory operation:
	type memory_operation_size is (
		MEMOP_SIZE_BYTE, MEMOP_SIZE_HALFWORD, MEMOP_SIZE_WORD
	);

	-- Determines if a memory operation is a load:
	function memop_is_load(input : in memory_operation_type) return boolean;

	--! Converts a boolean to an std_logic.
	function to_std_logic(input : in boolean) return std_logic;
	
	--! Calculates log2 with integers.
	function log2(input : in natural) return natural;

	-- Gets the value of the sel signals to the wishbone interconnect for the specified operand size and address.
	function wb_get_data_sel(size : in std_logic_vector(1 downto 0); address : in std_logic_vector)
		return std_logic_vector;
	
	--! Wishbone master output signals:
	type wishbone_master_outputs is record	
		adr : std_logic_vector(31 downto 0);
		sel : std_logic_vector( 3 downto 0);
		cyc : std_logic;
		stb : std_logic;
		we  : std_logic;
		dat : std_logic_vector(31 downto 0);
	end record; 
	
	--! Wishbone master input signals:
	type wishbone_master_inputs is record
		dat : std_logic_vector(31 downto 0);
		ack : std_logic;
	end record;

end package types;

package body types is

	function memop_is_load(input : in memory_operation_type) return boolean is
	begin
		return (input = MEMOP_TYPE_LOAD or input = MEMOP_TYPE_LOAD_UNSIGNED);
	end function memop_is_load;

	function to_std_logic(input : in boolean) return std_logic is
	begin
		if input then
			return '1';
		else
			return '0';
		end if;
	end function to_std_logic;
	
	function log2(input : in natural) return natural is
		variable retval : natural := 0;
		variable temp   : natural := input;
	begin
		while temp > 1 loop
			retval := retval + 1;
			temp := temp / 2;
		end loop;

		return retval;
	end function log2;

	function wb_get_data_sel(size : in std_logic_vector(1 downto 0); address : in std_logic_vector)
		return std_logic_vector is
	begin
		case size is
			when b"01" =>
				case address(1 downto 0) is
					when b"00" => return b"0001";
					when b"01" => return b"0010";
					when b"10" => return b"0100";
					when b"11" => return b"1000";
					when others => return b"0001";
				end case;
			when b"10" =>
				if address(1) = '1' then return b"1100";
				else return b"0011";
				end if;
			when others => return b"1111";
		end case;
	end function wb_get_data_sel;
end package body types;
