library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity ps_core is
    generic (
        PROCESSOR_ID     : std_logic_vector(31 downto 0) := x"00000000"; --! Processor ID.
		RESET_ADDRESS    : std_logic_vector(31 downto 0) := x"00000200" --! Address of the first instruction to execute.
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;

        -- Instruction memory interface:
		imem_address : out std_logic_vector(31 downto 0); --! Address of the next instruction
		imem_data_in : in  std_logic_vector(31 downto 0); --! Instruction input
		imem_req     : out std_logic;
		imem_ack     : in  std_logic;

        -- Data memory interface:
		dmem_address   : out std_logic_vector(31 downto 0); --! Data address
		dmem_data_in   : in  std_logic_vector(31 downto 0); --! Input from the data memory
		dmem_data_out  : out std_logic_vector(31 downto 0); --! Ouptut to the data memory
		dmem_data_size : out std_logic_vector( 1 downto 0); --! Size of the data, 1 = 8 bits, 2 = 16 bits, 0 = 32 bits. 
		dmem_read_req  : out std_logic;                     --! Data memory read request
		dmem_read_ack  : in  std_logic;                     --! Data memory read acknowledge
		dmem_write_req : out std_logic;                     --! Data memory write request
		dmem_write_ack : in  std_logic 
    );
end entity ps_core;

architecture rtl of ps_core is
    ------- Flush signals -------
	signal flush_if, flush_id, flush_ex : std_logic := '0';

	------- Stall signals -------
	signal stall_if, stall_id, stall_ex, stall_mem : std_logic := '0';

    -- Signals used to determine if an instruction should be counted
	-- -- by the instret counter:
	-- signal st_fetch_count_instruction, st_decode_count_instruction  : std_logic := '0';
	-- signal st_execute_count_instruction, st_memory_count_instruction : std_logic := '0';
	-- signal st_writeback_count_instruction : std_logic := '0';

    -- Load hazard detected in the execute stage:
	signal load_hazard_detected : std_logic := '0';

    -- Branch targets:
	signal branch_target    : std_logic_vector(31 downto 0) := (others => '0');
	signal branch_taken     : std_logic := '0';
	signal branch_condition : std_logic := '0';

    -- Register file read ports:
	signal rs1_addr_p, rs2_addr_p : register_address := (others => '0');
	signal rs1_addr, rs2_addr     : register_address := (others => '0');
	signal rs1_data, rs2_data     : std_logic_vector(31 downto 0) := (others => '0');

    -- Data memory signals:
    signal dmem_address_p   : std_logic_vector(31 downto 0) := (others => '0');
	signal dmem_data_size_p : std_logic_vector(1 downto 0) := (others => '0');
	signal dmem_data_out_p  : std_logic_vector(31 downto 0) := (others => '0');
	signal dmem_read_req_p  : std_logic := '0';
	signal dmem_write_req_p : std_logic := '0';

    -- Fetch stage signals:
    signal st_fetch_instruction : std_logic_vector(31 downto 0) := (others => '0');
	signal st_fetch_pc          : std_logic_vector(31 downto 0) := (others => '0');
	signal st_fetch_instruction_ready : std_logic := '0';
	signal st_fetch_pc_next         : std_logic_vector(31 downto 0);
	signal st_fetch_cancel_fetch    : std_logic;
    signal st_fetch_instruction_address  : std_logic_vector(31 downto 0);

	-- Decode stage signals:
	signal st_decode_pc          : std_logic_vector(31 downto 0) := (others => '0');
    signal st_decode_instruction     : std_logic_vector(31 downto 0);
	signal st_decode_immediate   : std_logic_vector(31 downto 0);
	signal st_decode_funct3      : std_logic_vector(2 downto 0) := (others => '0');
	signal st_decode_rd_addr     : register_address := (others => '0');
	signal st_decode_rd_write    : std_logic := '0';
	signal st_decode_rs1_addr    : register_address := (others => '0');
	signal st_decode_rs1_data    : std_logic_vector(31 downto 0) := (others => '0');
	signal st_decode_rs1_data_p  : std_logic_vector(31 downto 0) := (others => '0');
	signal st_decode_rs2_addr    : register_address := (others => '0');
	signal st_decode_rs2_data  : std_logic_vector(31 downto 0) := (others => '0');
	signal st_decode_rs2_data_p  : std_logic_vector(31 downto 0) := (others => '0');
	signal st_decode_shamt       : std_logic_vector(4 downto 0) := (others => '0');
	signal st_decode_branch_type : branch_type;
	signal st_decode_alu_x_src   : alu_operand_source;
	signal st_decode_alu_y_src   : alu_operand_source;
	signal st_decode_alu_op      : alu_operation;
	signal st_decode_mem_op      : memory_operation_type;
	signal st_decode_mem_size    : memory_operation_size;

    signal st_decode_conv_op     : conv_operation;
    signal st_decode_conv_rd_write  : std_logic := '0';
    signal st_decode_is_conv_opr : std_logic := '0';
    
	-- Execute stage signals:
	signal st_execute_dmem_address   : std_logic_vector(31 downto 0) := (others => '0');
	signal st_execute_dmem_data_size : std_logic_vector(1 downto 0) := (others => '0');
	signal st_execute_dmem_data_out  : std_logic_vector(31 downto 0) := (others => '0');
	signal st_execute_dmem_read_req  : std_logic := '0';
	signal st_execute_dmem_write_req : std_logic := '0';
    signal st_execute_rs1_addr  : register_address;
    signal st_execute_rs2_addr  : register_address;
	signal st_execute_rs1_data_in  : std_logic_vector(31 downto 0);
	signal st_execute_rs2_data_in  : std_logic_vector(31 downto 0);
    signal st_execute_rs1_data  : std_logic_vector(31 downto 0);
	signal st_execute_rs2_data  : std_logic_vector(31 downto 0);
	signal st_execute_rd_addr   : register_address := (others => '0');
	signal st_execute_rd_data   : std_logic_vector(31 downto 0) := (others => '0');
	signal st_execute_rd_write  : std_logic := '0';
    signal st_execute_alu_op    : alu_operation;
	signal st_execute_alu_x_src : alu_operand_source;
	signal st_execute_alu_y_src : alu_operand_source;
	signal alu_x, alu_y, alu_result : std_logic_vector(31 downto 0);

	signal st_execute_pc        : std_logic_vector(31 downto 0) := (others => '0');
	signal st_execute_branch_type   : branch_type;
	signal st_execute_mem_op    : memory_operation_type;
	signal st_execute_mem_size  : memory_operation_size;

    signal st_execute_immediate : std_logic_vector(31 downto 0);
	signal st_execute_shamt     : std_logic_vector( 4 downto 0);
	signal st_execute_funct3    : std_logic_vector( 2 downto 0);

	signal st_execute_conv_op   	: conv_operation;
    signal st_execute_conv_reg_img	: std_logic_vector(783 downto 0) := (others => '0');
	signal st_execute_conv_reg_kn	: std_logic_vector(783 downto 0) := (others => '0');
    signal st_execute_conv_res_reg	: std_logic_vector(31 downto 0) := (others => '0');
    signal st_execute_conv_res_reg_fwd	: std_logic_vector(31 downto 0) := (others => '0');
    signal st_execute_conv_rd_data 	: std_logic_vector(31 downto 0) := (others => '0');
    signal st_execute_conv_rd_addr 	: conv_register_address := (others => '0');
    signal st_execute_conv_rd_write	: std_logic := '0';
    signal st_execute_is_conv_opr	: std_logic := '0';
    signal st_execute_conv_clear	: std_logic := '0';

	-- Memory stage signals:
	signal st_memory_dmem_data      : std_logic_vector(31 downto 0) := (others => '0');
	
    signal st_memory_rd_write       : std_logic := '0';
	signal st_memory_rd_addr        : register_address := (others => '0');
	signal st_memory_rd_data        : std_logic_vector(31 downto 0) := (others => '0');
	signal st_memory_mem_op         : memory_operation_type;
	signal st_memory_mem_size       : memory_operation_size;

    signal st_memory_is_conv_opr    : std_logic := '0';
    signal st_memory_conv_rd_addr	: conv_register_address := (others => '0');
    signal st_memory_conv_rd_data	: std_logic_vector(31 downto 0) := (others => '0');
    signal st_memory_conv_rd_write	: std_logic := '0';
    signal st_memory_conv_clear	    : std_logic := '0';

	-- Writeback signals:
	signal st_writeback_dmem_data   : std_logic_vector(31 downto 0) := (others => '0');
    
    signal st_writeback_mem_op      : memory_operation_type;
    signal st_writeback_rd_addr     : register_address := (others => '0');
	signal st_writeback_rd_data_in  : std_logic_vector(31 downto 0) := (others => '0');
	signal st_writeback_rd_data     : std_logic_vector(31 downto 0) := (others => '0');
	signal st_writeback_rd_write    : std_logic := '0';

    signal st_writeback_is_conv_opr     : std_logic := '0';
    signal st_writeback_conv_rd_data_in	: std_logic_vector(31 downto 0) := (others => '0');
    signal st_writeback_conv_rd_data	: std_logic_vector(31 downto 0) := (others => '0');
    signal st_writeback_conv_rd_write	: std_logic := '0';
    signal st_writeback_conv_rd_addr 	: conv_register_address := (others => '0');
    signal st_writeback_conv_clear	    : std_logic := '0';

begin
    stall_if <= stall_id;
	stall_id <= stall_ex;
	stall_ex <= load_hazard_detected or stall_mem;
	stall_mem <= to_std_logic(memop_is_load(st_memory_mem_op) and dmem_read_ack = '0')
		or to_std_logic(st_memory_mem_op = MEMOP_TYPE_STORE and dmem_write_ack = '0');

	flush_if <= branch_taken and not stall_if;
	flush_id <= branch_taken and not stall_id;
	flush_ex <= branch_taken and not stall_ex;

    regfile: entity work.register_file
    port map(
        clk => clk,
        rs1_addr => rs1_addr,
        rs2_addr => rs2_addr,
        rs1_data => rs1_data,
        rs2_data => rs2_data,
        rd_addr => st_writeback_rd_addr,
        rd_data => st_writeback_rd_data,
        rd_write => st_writeback_rd_write
    );

    conv_reg_file : entity work.conv_register_file
    port map (
        clk => clk,
        reset => st_writeback_conv_clear,
        rs_parallel_data_img => st_execute_conv_reg_img,
        rs_parallel_data_kn  => st_execute_conv_reg_kn,
        res_out => st_execute_conv_res_reg,
        rd_addr => st_writeback_conv_rd_addr,
        rd_data => st_writeback_conv_rd_data,
        rd_write => st_writeback_conv_rd_write
    );

    ------- Instruction Fetch (IF) Stage -------
    pc_reg: process (clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				st_fetch_pc <= RESET_ADDRESS;
				st_fetch_cancel_fetch <= '0';
			else
				if (branch_taken = '1') and imem_ack = '0' then
					st_fetch_cancel_fetch <= '1';
					st_fetch_pc <= st_fetch_pc_next;
				elsif st_fetch_cancel_fetch = '1' and imem_ack = '1' then
					st_fetch_cancel_fetch <= '0';
				else
					st_fetch_pc <= st_fetch_pc_next;
				end if;
			end if;
		end if;
	end process;
    
    next_pc: process(reset, stall_if, branch_taken, imem_ack, branch_target, st_fetch_pc, st_fetch_cancel_fetch)
	begin
		if branch_taken= '1' then
			st_fetch_pc_next <= branch_target;
		elsif imem_ack = '1' and stall_if = '0' and st_fetch_cancel_fetch = '0' then
			st_fetch_pc_next <= std_logic_vector(unsigned(st_fetch_pc) + 4);
		else
			st_fetch_pc_next <= st_fetch_pc;
		end if;
	end process next_pc;

    imem_address <= st_fetch_pc_next when st_fetch_cancel_fetch = '0' else st_fetch_pc;
    imem_req <= '1' when reset = '0' else '0';

    st_fetch_instruction <= imem_data_in;
    st_fetch_instruction_ready <= imem_ack and (not stall_if) and (not st_fetch_cancel_fetch);

    ------- IF-ID pipeline register -------
    if_id : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				st_decode_instruction <= RISCV_NOP;
				st_decode_pc <= RESET_ADDRESS;
				-- count_instruction <= '0';
			-- elsif stall_id = '1' then
			-- 	count_instruction <= '0';
			elsif flush_id = '1' or st_fetch_instruction_ready = '0' then
				st_decode_instruction <= RISCV_NOP;
				-- count_instruction <= '0';
			else
				st_decode_instruction <= st_fetch_instruction;
				-- count_instruction <= instruction_count;
				st_decode_pc <= st_fetch_pc;
			end if;
		end if;
	end process if_id;

    ------- Instruction Decode (ID) Stage -------
    st_decode_rs1_addr <= st_decode_instruction(19 downto 15);
	st_decode_rs2_addr <= st_decode_instruction(24 downto 20);
	st_decode_rd_addr  <= st_decode_instruction(11 downto 7);

    -- Extract the shamt value from the instruction word:
	st_decode_shamt <= st_decode_instruction(24 downto 20);

	-- Extract the value specifying which comparison to do in branch instructions:
	st_decode_funct3 <= st_decode_instruction(14 downto 12);

    -- Extract the immediate value from the instruction word:
    immediate_decoder: entity work.imm_decoder
		port map(
			instruction => st_decode_instruction(31 downto 2),
			immediate => st_decode_immediate
		);
    
    -- Control Unit
    control_unit: entity work.ctrl_unit
    port map (
        opcode => st_decode_instruction(6 downto 2),
        funct3 => st_decode_instruction(14 downto 12),
        funct7 => st_decode_instruction(31 downto 25),
        rd_write => st_decode_rd_write,
        branch => st_decode_branch_type,
        alu_x_src => st_decode_alu_x_src,
        alu_y_src => st_decode_alu_y_src,
        alu_op => st_decode_alu_op,
        mem_op => st_decode_mem_op,
        mem_size => st_decode_mem_size
    );

	-- Convolution Control Unit 
    conv_ctrl_unit: entity work.conv_control_unit
    port map (
        opcode => st_decode_instruction(6 downto 2),
        funct3 => st_decode_instruction(14 downto 12),
--        funct7 => st_decode_instruction(31 downto 25),
        conv_op => st_decode_conv_op,
        conv_rd_write => st_decode_conv_rd_write,
        is_conv_opr => st_decode_is_conv_opr
    );

    rs1_addr <= st_decode_rs1_addr;
    rs2_addr <= st_decode_rs2_addr;

    -- Source register MUX with forwared signal from WB
    rs1_decode_mux: process(st_writeback_rd_write, st_writeback_rd_addr, st_writeback_rd_data, stall_id,
        rs1_data, st_decode_rs1_addr, stall_ex, st_decode_rs1_data_p)
    begin
        if st_writeback_rd_write = '1' and st_writeback_rd_addr = st_decode_rs1_addr and st_writeback_rd_addr /= b"00000" then
			st_decode_rs1_data <= st_writeback_rd_data;
        elsif stall_ex = '0' then
            st_decode_rs1_data <= rs1_data;
        else
            st_decode_rs1_data <= st_decode_rs1_data_p; 
        end if;
    end process;
    
    rs2_decode_mux: process(st_writeback_rd_write, st_writeback_rd_addr, st_writeback_rd_data, stall_id,
        rs2_data, st_decode_rs2_addr, stall_ex, st_decode_rs2_data_p)
    begin
        if st_writeback_rd_write = '1' and st_writeback_rd_addr = st_decode_rs2_addr and st_writeback_rd_addr /= b"00000" then
			st_decode_rs2_data <= st_writeback_rd_data;
        elsif stall_ex = '0' then
            st_decode_rs2_data <= rs2_data;
        else
            st_decode_rs2_data <= st_decode_rs2_data_p; 
        end if;
    end process;
    
    store_rs_data_p: process(clk, stall_id)
    begin
        if rising_edge(clk) and stall_id = '0' then
            st_decode_rs1_data_p <= st_decode_rs1_data;
            st_decode_rs2_data_p <= st_decode_rs2_data;
        end if;
    end process store_rs_data_p;

    ------- ID-EX pipeline register -------
    id_ex: process (clk)
    begin
        if rising_edge(clk) then
			if reset = '1' or flush_ex = '1' then
				st_execute_rd_write <= '0';
				st_execute_branch_type <= BRANCH_NONE;
				st_execute_mem_op <= MEMOP_TYPE_NONE;

				st_execute_rs1_addr <= (others => '0');
				st_execute_rs2_addr <= (others => '0');
                st_execute_immediate <= (others => '0');
                st_execute_shamt <= (others => '0');
                st_execute_funct3 <= (others => '0');

			elsif stall_ex = '0' then
				-- Register signals:
				st_execute_rd_write <= st_decode_rd_write;
				st_execute_rd_addr <= st_decode_rd_addr;
				st_execute_rs1_addr <= st_decode_rs1_addr;
				st_execute_rs2_addr <= st_decode_rs2_addr;
				st_execute_rs1_data_in <= st_decode_rs1_data;
				st_execute_rs2_data_in <= st_decode_rs2_data;

				-- ALU signals:
				st_execute_alu_op <= st_decode_alu_op;
				st_execute_alu_x_src <= st_decode_alu_x_src;
				st_execute_alu_y_src <= st_decode_alu_y_src;

				-- Control signals:
				st_execute_branch_type <= st_decode_branch_type;
				st_execute_mem_op <= st_decode_mem_op;
				st_execute_mem_size <= st_decode_mem_size;

				-- Constant values:
                st_execute_pc <= st_decode_pc;
				st_execute_immediate <= st_decode_immediate;
				st_execute_shamt <= st_decode_shamt;
				st_execute_funct3 <= st_decode_funct3;

                -- Convolution
                st_execute_conv_op <= st_decode_conv_op;
				st_execute_conv_rd_write <= st_decode_conv_rd_write;
				st_execute_is_conv_opr <= st_decode_is_conv_opr;
            
			end if;
        end if;
    end process;

    ------- Execute (EX) Stage -------
    
    -- Source register multiplexer with forwared signal from WB and MEM
    rs1_mux: process(st_memory_rd_write, st_memory_rd_data, st_memory_rd_addr, st_execute_rs1_addr,
        st_execute_rs1_data_in, st_writeback_rd_write, st_writeback_rd_addr, st_writeback_rd_data) 
    begin
        if st_memory_rd_write = '1' and st_memory_rd_addr = st_execute_rs1_addr and st_memory_rd_addr /= b"00000" then
			st_execute_rs1_data <= st_memory_rd_data;
		elsif st_writeback_rd_write = '1' and st_writeback_rd_addr = st_execute_rs1_addr and st_writeback_rd_addr /= b"00000" then
			st_execute_rs1_data <= st_writeback_rd_data;
		else
			st_execute_rs1_data <= st_execute_rs1_data_in;
		end if;
    end process;

    rs2_mux: process(st_memory_rd_write, st_memory_rd_data, st_memory_rd_addr, st_execute_rs2_addr,
        st_execute_rs2_data_in, st_writeback_rd_write, st_writeback_rd_addr, st_writeback_rd_data) 
    begin
        if st_memory_rd_write = '1' and st_memory_rd_addr = st_execute_rs2_addr and st_memory_rd_addr /= b"00000" then
			st_execute_rs2_data <= st_memory_rd_data;
		elsif st_writeback_rd_write = '1' and st_writeback_rd_addr = st_execute_rs2_addr and st_writeback_rd_addr /= b"00000" then
			st_execute_rs2_data <= st_writeback_rd_data;
		else
			st_execute_rs2_data <= st_execute_rs2_data_in;
		end if;
    end process;

    -- ALU input multiplexer
    x_mux: entity work.alu_mux
    port map (
        source => st_execute_alu_x_src,
        register_value => st_execute_rs1_data,
        immediate_value => st_execute_immediate,
        shamt_value => st_execute_shamt,
        pc_value => st_execute_pc,
        output => alu_x
    );

    y_mux: entity work.alu_mux
    port map (
        source => st_execute_alu_y_src,
        register_value => st_execute_rs2_data,
        immediate_value => st_execute_immediate,
        shamt_value => st_execute_shamt,
        pc_value => st_execute_pc,
        output => alu_y
    );

    -- ALU unit
    alu_unit: entity work.alu
    port map (
        result => alu_result,
        x => alu_x,
        y => alu_y,
        operation => st_execute_alu_op
    );

    -- Convolution ALU
    conv_alu_unit: entity work.conv_alu
	port map(
		conv_opr => st_execute_conv_op,
        input_img => st_execute_conv_reg_img,
        input_kn => st_execute_conv_reg_kn,
        output => st_execute_conv_rd_data
	); 

    st_execute_conv_clear <= '1' when st_execute_conv_op = MX_CLEAR else '0'; 
	st_execute_conv_rd_addr <= st_execute_rs2_data(st_execute_conv_rd_addr'length-1 downto 0) when st_execute_is_conv_opr = '1' 
			and memop_is_load(st_execute_mem_op)
		else RES_REG_ADDR;

    conv_res_reg_mux: process (st_memory_conv_rd_addr, st_memory_conv_rd_data, st_memory_conv_rd_write,
        st_writeback_conv_rd_addr, st_writeback_conv_rd_data, st_writeback_conv_rd_write, 
        st_execute_is_conv_opr, st_execute_conv_res_reg)
    begin
        st_execute_conv_res_reg_fwd <= st_execute_conv_res_reg;
        if st_execute_is_conv_opr = '1' then
            if st_memory_conv_rd_write = '1' and st_memory_conv_rd_addr = RES_REG_ADDR then
                st_execute_conv_res_reg_fwd <= st_memory_conv_rd_data;
            elsif st_writeback_conv_rd_write = '1' and st_writeback_conv_rd_addr = RES_REG_ADDR then
                st_execute_conv_res_reg_fwd <= st_writeback_conv_rd_data;
            end if;            
        end if;
    end process;
    
    st_execute_rd_data <= alu_result;
    st_execute_dmem_address <= alu_result when (st_execute_mem_op /= MEMOP_TYPE_NONE and st_execute_mem_op /= MEMOP_TYPE_INVALID)
		else (others => '0');
    st_execute_dmem_data_out <= st_execute_rs2_data when st_execute_is_conv_opr = '0' else st_execute_conv_res_reg_fwd;
    st_execute_dmem_write_req <= '1' when st_execute_mem_op = MEMOP_TYPE_STORE else '0';
    st_execute_dmem_read_req <= '1' when memop_is_load(st_execute_mem_op) else '0';

    
    -- Branch target MUX
    branch_comparator: entity work.comparator
		port map(
			funct3 => st_execute_funct3,
			rs1 => st_execute_rs1_data,
			rs2 => st_execute_rs2_data,
			result => branch_condition
		);

    calc_jump_target: process(st_execute_branch_type, st_execute_pc, st_execute_rs1_data, st_execute_immediate)
	begin
		case st_execute_branch_type is
			when BRANCH_JUMP | BRANCH_CONDITIONAL =>
				branch_target <= std_logic_vector(unsigned(st_execute_pc) + unsigned(st_execute_immediate));
			when BRANCH_JUMP_INDIRECT =>
				branch_target <= std_logic_vector(unsigned(st_execute_rs1_data) + unsigned(st_execute_immediate));
			when others =>
				branch_target <= (others => '0');
		end case;
	end process calc_jump_target;

    branch_taken <= (to_std_logic(st_execute_branch_type = BRANCH_JUMP or st_execute_branch_type = BRANCH_JUMP_INDIRECT)
    or (to_std_logic(st_execute_branch_type = BRANCH_CONDITIONAL) and branch_condition)) and not stall_ex;

    -- Hazard detection unit
    detect_load_hazard: process(st_memory_mem_op, st_memory_rd_addr, st_execute_rs1_addr, st_execute_rs2_addr,
		st_execute_alu_x_src, st_execute_alu_y_src)
	begin
		if (st_memory_mem_op = MEMOP_TYPE_LOAD or st_memory_mem_op = MEMOP_TYPE_LOAD_UNSIGNED) and
				((st_execute_alu_x_src = ALU_SRC_REG and st_memory_rd_addr = st_execute_rs1_addr 
                    and st_execute_rs1_addr /= b"00000")
			or
				(st_execute_alu_y_src = ALU_SRC_REG and st_memory_rd_addr = st_execute_rs2_addr 
                    and st_execute_rs2_addr /= b"00000"))
		then
			load_hazard_detected <= '1';
		else
			load_hazard_detected <= '0';
		end if;
	end process detect_load_hazard;

    set_data_size: process(st_execute_mem_size)
	begin
		case st_execute_mem_size is
			when MEMOP_SIZE_BYTE =>
                st_execute_dmem_data_size <= b"01";
			when MEMOP_SIZE_HALFWORD =>
                st_execute_dmem_data_size <= b"10";
			when MEMOP_SIZE_WORD =>
                st_execute_dmem_data_size <= b"00";
			when others =>
                st_execute_dmem_data_size <= b"11";
		end case;
	end process set_data_size;

    ------- EX_MEM pipeline register -------
    ex_mem : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                st_memory_rd_write <= '0';
                st_memory_conv_rd_write <= '0';
				st_memory_mem_op <= MEMOP_TYPE_NONE;
				st_memory_rd_data <= (others => '0') ;
				st_memory_rd_addr <= (others => '0');
				st_memory_conv_rd_addr <= (others => '0'); 
				st_memory_conv_rd_data <= (others => '0');
            elsif stall_mem = '0' then
                st_memory_mem_size <= st_execute_mem_size;
				st_memory_rd_data <= st_execute_rd_data;
				st_memory_rd_addr <= st_execute_rd_addr;
                st_memory_mem_op <= st_execute_mem_op;
                st_memory_rd_write <= st_execute_rd_write;
				
                st_memory_is_conv_opr <= st_execute_is_conv_opr;
                st_memory_conv_rd_data <= st_execute_conv_rd_data;
				st_memory_conv_rd_addr <= st_execute_conv_rd_addr; 
				st_memory_conv_rd_write <= st_execute_conv_rd_write;
                st_memory_conv_clear <= st_execute_conv_clear;
            end if;
        end if;
    end process;

    ------- Memory (MEM) Stage -------
    dmem_address <= st_execute_dmem_address when stall_mem = '0' else dmem_address_p;
    dmem_data_size <= st_execute_dmem_data_size when stall_mem = '0' else dmem_data_size_p;
    dmem_read_req <= st_execute_dmem_read_req when stall_mem = '0' else dmem_read_req_p;
    dmem_write_req <= st_execute_dmem_write_req when stall_mem = '0' else dmem_write_req_p;
    dmem_data_out <= st_execute_dmem_data_out when stall_mem = '0' else dmem_data_out_p;

    store_previous_dmem_address: process(clk, stall_mem)
    begin
        if rising_edge(clk) and stall_mem = '0' then
            dmem_address_p <= st_execute_dmem_address;
            dmem_data_size_p <= st_execute_dmem_data_size;
            dmem_data_out_p <= st_execute_dmem_data_out;
            dmem_read_req_p <= st_execute_dmem_read_req;
            dmem_write_req_p <= st_execute_dmem_write_req;
        end if;
    end process store_previous_dmem_address;

    dmem_data_mux : process (dmem_data_in, st_memory_mem_op, st_memory_mem_size)
    begin
        if memop_is_load(st_memory_mem_op) then
            case st_memory_mem_size is
                when MEMOP_SIZE_BYTE =>
                    if st_memory_mem_op = MEMOP_TYPE_LOAD_UNSIGNED then
                        st_memory_dmem_data <= std_logic_vector(resize(unsigned(dmem_data_in(7 downto 0)), st_memory_dmem_data'length));
                    else
                        st_memory_dmem_data <= std_logic_vector(resize(signed(dmem_data_in(7 downto 0)), st_memory_dmem_data'length));
                    end if;
                when MEMOP_SIZE_HALFWORD =>
                    if st_memory_mem_op = MEMOP_TYPE_LOAD_UNSIGNED then
                        st_memory_dmem_data <= std_logic_vector(resize(unsigned(dmem_data_in(15 downto 0)), st_memory_dmem_data'length));
                    else
                        st_memory_dmem_data <= std_logic_vector(resize(signed(dmem_data_in(15 downto 0)), st_memory_dmem_data'length));
                    end if;
                when MEMOP_SIZE_WORD =>
                    st_memory_dmem_data <= dmem_data_in;
				end case;
        else  
            st_memory_dmem_data <= (others => '0');
        end if;
    end process;
    
    ------- MEM-WB pipeline register -------
    wb_register : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                st_writeback_dmem_data <= (others => '0');
                st_writeback_rd_write <= '0';
                st_writeback_conv_rd_write <= '0';
				st_writeback_mem_op <= MEMOP_TYPE_NONE;
                st_writeback_rd_data_in <= (others => '0');
                st_writeback_rd_addr <= (others => '0');  
                st_writeback_conv_rd_data_in <= (others => '0'); 
				st_writeback_conv_rd_addr <= (others => '0'); 
            else
                st_writeback_dmem_data <= st_memory_dmem_data;
                st_writeback_mem_op <= st_memory_mem_op;
                st_writeback_is_conv_opr <= st_memory_is_conv_opr;
                st_writeback_rd_data_in <= st_memory_rd_data;
                st_writeback_rd_write <= st_memory_rd_write;
				st_writeback_conv_rd_addr <= st_memory_conv_rd_addr; 
				st_writeback_conv_rd_data_in <= st_memory_conv_rd_data;
                st_writeback_rd_addr <= st_memory_rd_addr;           
                st_writeback_conv_rd_write <= st_memory_conv_rd_write; 
                st_writeback_conv_clear <= st_memory_conv_clear;
            end if;
        end if;
    end process;

    ------- Writeback (WB) Stage -------
    st_writeback_conv_rd_data <= st_writeback_dmem_data when memop_is_load(st_writeback_mem_op) 
    and st_writeback_is_conv_opr = '1' else st_writeback_conv_rd_data_in;
  
    st_writeback_rd_data <= st_writeback_dmem_data when memop_is_load(st_writeback_mem_op) 
    and st_writeback_is_conv_opr = '0' else st_writeback_rd_data_in;
end architecture;