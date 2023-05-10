library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity ctrl_unit is
	port(
		-- Inputs, indices correspond to instruction word indices:
		opcode  : in std_logic_vector( 4 downto 0); --! Instruction opcode field.
		funct3  : in std_logic_vector( 2 downto 0); --! Instruction @c funct3 field.
		funct7  : in std_logic_vector( 6 downto 0); --! Instruction @c funct7 field.

		-- Control signals:
		rd_write            : out std_logic;   --! Signals that the instruction writes to a destination register.
		branch              : out branch_type; --! Signals that the instruction is a branch.

		-- Sources of operands to the ALU:
		alu_x_src, alu_y_src : out alu_operand_source; --! ALU operand source.

		-- ALU operation:
		alu_op : out alu_operation; --! ALU operation to perform for the instruction.
		-- conv_op : out conv_operation;

		-- Memory transaction parameters:
		mem_op   : out memory_operation_type; --! Memory operation to perform for the instruction.
		mem_size : out memory_operation_size  --! Size of the memory operation to perform.
	);
end entity ctrl_unit;

architecture rtl of ctrl_unit is
	signal alu_op_temp     : alu_operation;
begin

	alu_op <= alu_op_temp;

	--! @brief   ALU control unit.
	--! @details Decodes arithmetic and logic instructions and sets the
	--!          control signals relating to the ALU.
	alu_control: entity work.alu_ctrl_unit
		port map(
			opcode => opcode,
			funct3 => funct3,
			funct7 => funct7,
			alu_x_src => alu_x_src,
			alu_y_src => alu_y_src,
			alu_op => alu_op_temp
		);
		
	-- conv_alu_ctrl: entity work.conv_alu_control_unit
	-- 	port map(
	-- 		opcode => opcode,
	-- 		funct3 => funct3,
	-- 		funct7 => funct7,
	-- 		conv_op => conv_op
	-- 	);

	decode_ctrl: process(opcode, funct3)
	begin
		case opcode is
			when b"01101" => -- Load upper immediate
				rd_write <= '1';
				branch <= BRANCH_NONE;
			when b"00101" => -- Add upper immediate to PC
				rd_write <= '1';
				branch <= BRANCH_NONE;
			when b"11011" => -- Jump and link
				rd_write <= '1';
				branch <= BRANCH_JUMP;
			when b"11001" => -- Jump and link register
				rd_write <= '1';
				branch <= BRANCH_JUMP_INDIRECT;
			when b"11000" => -- Branch operations
				rd_write <= '0';
				branch <= BRANCH_CONDITIONAL;
			when b"00000" => -- Load instructions
				rd_write <= '1';
				branch <= BRANCH_NONE;
			when b"01000" => -- Store instructions
				rd_write <= '0';
				branch <= BRANCH_NONE;
			when b"00100" => -- Register-immediate operations
				rd_write <= '1';
				branch <= BRANCH_NONE;
			when b"01100" => -- Register-register operations
				rd_write <= '1';
				branch <= BRANCH_NONE;
			when b"00011" => -- Fence instructions, ignored
				rd_write <= '0';
				branch <= BRANCH_NONE;
			
			when b"01010" => -- custom instructions
			    rd_write <= '0';
			    branch <= BRANCH_NONE;

			when others =>
				rd_write <= '0';
				branch <= BRANCH_NONE;
		end case;
	end process decode_ctrl;

	decode_mem: process(opcode, funct3)
	begin
		case opcode is
			when b"00000" => -- Load instructions
				case funct3 is
					when b"000" => -- lb
						mem_size <= MEMOP_SIZE_BYTE;
						mem_op <= MEMOP_TYPE_LOAD;
					when b"001" => -- lh
						mem_size <= MEMOP_SIZE_HALFWORD;
						mem_op <= MEMOP_TYPE_LOAD;
					when b"010" | b"110" => -- lw
						mem_size <= MEMOP_SIZE_WORD;
						mem_op <= MEMOP_TYPE_LOAD;
					when b"100" => -- lbu
						mem_size <= MEMOP_SIZE_BYTE;
						mem_op <= MEMOP_TYPE_LOAD_UNSIGNED;
					when b"101" => -- lhu
						mem_size <= MEMOP_SIZE_HALFWORD;
						mem_op <= MEMOP_TYPE_LOAD_UNSIGNED;
					when others => 
						mem_size <= MEMOP_SIZE_WORD;
						mem_op <= MEMOP_TYPE_INVALID;
				end case;
			when b"01000" => -- Store instructions
				case funct3 is
					when b"000" =>
						mem_op <= MEMOP_TYPE_STORE;
						mem_size <= MEMOP_SIZE_BYTE;
					when b"001" =>
						mem_op <= MEMOP_TYPE_STORE;
						mem_size <= MEMOP_SIZE_HALFWORD;
					when b"010" =>
						mem_op <= MEMOP_TYPE_STORE;
						mem_size <= MEMOP_SIZE_WORD;
					when others =>
						mem_op <= MEMOP_TYPE_INVALID;
						mem_size <= MEMOP_SIZE_WORD;
				end case;
			
			-- Custom
	      	when b"00010" => -- Load/Store custom instructions
				case funct3 is
					when b"000"=> -- LBIMG
						mem_op <= MEMOP_TYPE_LOAD_UNSIGNED;
						mem_size <= MEMOP_SIZE_BYTE;
					when b"001"=> -- LBKN
						mem_op <= MEMOP_TYPE_LOAD;
						mem_size <= MEMOP_SIZE_BYTE;
					when b"110" =>	-- LVIMG
						mem_op <= MEMOP_TYPE_LOAD_UNSIGNED;
						mem_size <= MEMOP_SIZE_BYTE;
					when b"111" => --LVKN
						mem_op <= MEMOP_TYPE_LOAD;
						mem_size <= MEMOP_SIZE_BYTE;
					when b"010" => -- LHIMG
						mem_op <= MEMOP_TYPE_LOAD_UNSIGNED;
						mem_size <= MEMOP_SIZE_HALFWORD;
					when b"011"=> -- LHKN
						mem_op <= MEMOP_TYPE_LOAD;
						mem_size <= MEMOP_SIZE_HALFWORD;
					when b"100" => -- SW
						mem_op <= MEMOP_TYPE_STORE;
						mem_size <= MEMOP_SIZE_WORD;
					when b"101" => --SH
						mem_op <= MEMOP_TYPE_STORE;
						mem_size <= MEMOP_SIZE_HALFWORD;
					when others =>
						mem_op <= MEMOP_TYPE_NONE;
						mem_size <= MEMOP_SIZE_WORD;
				end case;


			when others =>
				mem_op <= MEMOP_TYPE_NONE;
				mem_size <= MEMOP_SIZE_WORD;
		end case;
	end process decode_mem;

end architecture rtl;