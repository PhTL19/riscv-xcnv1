-- The Potato Processor - A simple processor for FPGAs
-- (c) Kristian Klomsten Skordal 2014-2021 <kristian.skordal@wafflemail.net>
-- Report bugs and issues on <https://github.com/skordal/potato/issues>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.types.all;

entity tb_processor is
	generic(
	    PROCESSOR_ID     : std_logic_vector(31 downto 0) := x"00000000";
		IMEM_SIZE : natural := 4096; --! Size of the instruction memory in bytes.
		DMEM_SIZE : natural := 16384; --! Size of the data memory in bytes.
		RESET_ADDRESS   : std_logic_vector := x"00000200"; --! Processor reset address
		IMEM_START_ADDR : std_logic_vector := x"00000200"; --! Instruction memory start address
		IMEM_FILENAME   : string := "inst.mem";   --! File containing the contents of instruction memory.
		DMEM_FILENAME   : string := "data.mem";    --! File containing the contents of data memory.
		DMEM_OUTFILE	: string := "res.mem"
	);
end entity tb_processor;

architecture testbench of tb_processor is

	-- Clock signal:
	signal clk : std_logic := '0';
	constant clk_period : time := 10 ns;

	-- Common inputs:
	signal reset  : std_logic := '1';

	-- Instruction memory interface:
	signal imem_address : std_logic_vector(31 downto 0) := (others => '0');
	signal imem_data_in : std_logic_vector(31 downto 0) := (others => '0');
	signal imem_req     : std_logic;
	signal imem_ack     : std_logic := '0';

	-- Data memory interface:
	signal dmem_address   : std_logic_vector(31 downto 0) := (others => '0');
	signal dmem_data_in   : std_logic_vector(31 downto 0) := (others => '0');
	signal dmem_data_out  : std_logic_vector(31 downto 0) := (others => '0');
	signal dmem_data_size : std_logic_vector( 1 downto 0) := (others => '0');
	signal dmem_read_req, dmem_write_req : std_logic := '0';
	signal dmem_read_ack, dmem_write_ack : std_logic := '1';

	-- Simulation initialized:
	signal imem_initialized, dmem_initialized, initialized : boolean := false;
	signal done : boolean := false;
	signal done_exporting : boolean := FALSE;

	-- Memory array type:
	type memory_array is array(natural range <>) of std_logic_vector(7 downto 0);
	constant IMEM_BASE : natural := 0;
	constant IMEM_END  : natural := IMEM_BASE + IMEM_SIZE - 1;
	constant DMEM_BASE : natural := 0;
	constant DMEM_END  : natural := DMEM_SIZE - 1;
	constant DMEM_BASE_RES : natural := 800;

	constant RES_IMAGE_SIZE : natural := 676;
	

	-- Memories:
	signal imem_memory : memory_array(IMEM_BASE to IMEM_END) := (others => (others => '0'));
	signal dmem_memory : memory_array(DMEM_BASE to DMEM_END) := (others => (others => '0'));

	

begin

	uut: entity work.ps_core
		port map(
			clk => clk,
			reset => reset,
			imem_address => imem_address,
			imem_data_in => imem_data_in,
			imem_req => imem_req,
			imem_ack => imem_ack,
			dmem_address => dmem_address,
			dmem_data_in => dmem_data_in,
			dmem_data_out => dmem_data_out,
			dmem_data_size => dmem_data_size,
			dmem_read_req => dmem_read_req,
			dmem_read_ack => dmem_read_ack,
			dmem_write_req => dmem_write_req,
			dmem_write_ack => dmem_write_ack
		);

	clock: process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clock;

	--! Initializes the instruction memory from file.
	imem_init: process
		file imem_file : text open READ_MODE is IMEM_FILENAME;
		variable input_line  : line;
		variable input_index : natural;
		variable input_value : std_logic_vector(31 downto 0);
	begin
		for i in to_integer(unsigned(IMEM_START_ADDR)) / 4 to IMEM_END / 4 loop
		--for i in IMEM_BASE / 4 to IMEM_END / 4 loop
			if not endfile(imem_file) then
				readline(imem_file, input_line);
				hread(input_line, input_value);
				imem_memory(i * 4 + 0) <= input_value( 7 downto  0);
				imem_memory(i * 4 + 1) <= input_value(15 downto  8);
				imem_memory(i * 4 + 2) <= input_value(23 downto 16);
				imem_memory(i * 4 + 3) <= input_value(31 downto 24);
			else
				imem_memory(i * 4 + 0) <= RISCV_NOP( 7 downto 0);
				imem_memory(i * 4 + 1) <= RISCV_NOP(15 downto 8);
				imem_memory(i * 4 + 2) <= RISCV_NOP(23 downto 16);
				imem_memory(i * 4 + 3) <= RISCV_NOP(31 downto 24);
			end if;
		end loop;

		imem_initialized <= true;
		wait;
	end process imem_init;

	--! Initializes and handles writes to the data memory.
	dmem_init_and_write: process(clk)
		file dmem_file : text open READ_MODE is DMEM_FILENAME;
		variable input_line  : line;
		variable input_index : natural;
		variable input_value : std_logic_vector(31 downto 0);
	begin
		if not dmem_initialized then
			for i in DMEM_BASE / 4 to (DMEM_BASE / 4) + RES_IMAGE_SIZE + 1  loop
				if not endfile(dmem_file) then
					readline(dmem_file, input_line);
					hread(input_line, input_value);

					-- Read from a big-endian file:
					dmem_memory(i * 4 + 3) <= input_value( 7 downto  0);
					dmem_memory(i * 4 + 2) <= input_value(15 downto  8);
					dmem_memory(i * 4 + 1) <= input_value(23 downto 16);
					dmem_memory(i * 4 + 0) <= input_value(31 downto 24);
				else
					dmem_memory(i * 4 + 0) <= (others => '0');
					dmem_memory(i * 4 + 1) <= (others => '0');
					dmem_memory(i * 4 + 2) <= (others => '0');
					dmem_memory(i * 4 + 3) <= (others => '0');
				end if;
			end loop;
			
			dmem_initialized <= true;
		end if;

		if rising_edge(clk) then
			if dmem_write_ack = '1' then
				dmem_write_ack <= '0';
			elsif dmem_write_req = '1' then
				case dmem_data_size is
					when b"00" => -- 32 bits
						dmem_memory(to_integer(unsigned(dmem_address)) + 0) <= dmem_data_out(7 downto 0);
						dmem_memory(to_integer(unsigned(dmem_address)) + 1) <= dmem_data_out(15 downto 8);
						dmem_memory(to_integer(unsigned(dmem_address)) + 2) <= dmem_data_out(23 downto 16);
						dmem_memory(to_integer(unsigned(dmem_address)) + 3) <= dmem_data_out(31 downto 24);
					when b"01" => -- 8 bits
						dmem_memory(to_integer(unsigned(dmem_address))) <= dmem_data_out(7 downto 0);
					when b"10" => -- 16 bits
						dmem_memory(to_integer(unsigned(dmem_address)) + 0) <= dmem_data_out( 7 downto 0);
						dmem_memory(to_integer(unsigned(dmem_address)) + 1) <= dmem_data_out(15 downto 8);
					when others =>
				end case;
				dmem_write_ack <= '1';
			end if;
		end if;
	end process dmem_init_and_write;

	initialized <= imem_initialized and dmem_initialized;
	done <= TRUE when initialized = true and reset = '0' and unsigned(imem_address) > 716 else FALSE;

	--! Instruction memory read process.
	imem_read: process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				imem_ack <= '0';
			else
				if to_integer(unsigned(imem_address)) > IMEM_END then
					imem_data_in <= (others => 'X');
				else
					imem_data_in <= imem_memory(to_integer(unsigned(imem_address)) + 3)
						& imem_memory(to_integer(unsigned(imem_address)) + 2)
						& imem_memory(to_integer(unsigned(imem_address)) + 1)
						& imem_memory(to_integer(unsigned(imem_address)) + 0);
				end if;
	
				imem_ack <= '1';
			end if;
		end if;
	end process imem_read;

	--! Data memory read process.
	dmem_read: process(clk)
	begin
		if rising_edge(clk) then
			if dmem_read_ack = '1' then
				dmem_read_ack <= '0';
			elsif dmem_read_req = '1' then
				case dmem_data_size is
					when b"00" => -- 32 bits
						dmem_data_in <= dmem_memory(to_integer(unsigned(dmem_address) + 3))
							& dmem_memory(to_integer(unsigned(dmem_address) + 2))
							& dmem_memory(to_integer(unsigned(dmem_address) + 1))
							& dmem_memory(to_integer(unsigned(dmem_address) + 0));
					when b"10" => -- 16 bits
						dmem_data_in(15 downto 8) <= dmem_memory(to_integer(unsigned(dmem_address)) + 1);
						dmem_data_in( 7 downto 0) <= dmem_memory(to_integer(unsigned(dmem_address)) + 0);
					when b"01" => -- 8  bits
						dmem_data_in(7 downto 0) <= dmem_memory(to_integer(unsigned(dmem_address)));
					when others =>
				end case;
				dmem_read_ack <= '1';
			end if;
		end if;
	end process dmem_read;

	dmem_read_out : process(clk, done)
		file dmem_file_out : text open WRITE_MODE is DMEM_OUTFILE;
		variable output_line  : line;
		variable output_index : natural;
		variable output_value : std_logic_vector(31 downto 0);
	begin
		if rising_edge(clk) then
			if done = TRUE and done_exporting = FALSE then
				for i in DMEM_BASE_RES / 4 to DMEM_END / 4 loop
						-- Read from a big-endian file:
						output_value( 7 downto  0) := dmem_memory(i * 4 + 0);
						output_value(15 downto  8) := dmem_memory(i * 4 + 1);
						output_value(23 downto 16) := dmem_memory(i * 4 + 2);
						output_value(31 downto 24) := dmem_memory(i * 4 + 3);
						hwrite(output_line, output_value, right, 8);
						writeline(dmem_file_out, output_line); 
				end loop;
				file_close(dmem_file_out);
				done_exporting <= TRUE;	
			end if;
		end if;
	end process;

	stimulus: process
	begin
		wait until initialized = true;
		report "Testbench initialized, starting behavioural simulation..." severity NOTE;
		wait for clk_period * 10;

		-- Release the processor from reset:
		reset <= '0';
		wait for clk_period;

		wait until done = TRUE;

		wait until done_exporting = TRUE;
		report "Done exporting" severity NOTE;

		wait;
	end process stimulus;

end architecture testbench;
