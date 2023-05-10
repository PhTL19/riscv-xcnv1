library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity soc is
	generic(
		PROCESSOR_ID           : std_logic_vector(31 downto 0) := x"00000000"; --! Processor ID.
		RESET_ADDRESS          : std_logic_vector(31 downto 0) := x"00000000"; --! Address of the first instruction to execute.
        IMEM_SIZE : natural := 4096; --! Size of the instruction memory in bytes.
		DMEM_SIZE : natural := 16384 --! Size of the data memory in bytes.
	);
	port(
		clk       : in std_logic;
		reset     : in std_logic;

		-- Wishbone interface:
		wb_adr_out : out std_logic_vector(31 downto 0);
		wb_sel_out : out std_logic_vector( 3 downto 0);
		-- wb_cyc_out : out std_logic;
		-- wb_stb_out : out std_logic;
		wb_we_out  : out std_logic;
		wb_dat_out : out std_logic_vector(31 downto 0)
--		wb_dat_in  : in  std_logic_vector(31 downto 0);
--		wb_ack_in  : in  std_logic
	);
end entity soc;

architecture behavior of soc is
    -- Instruction memory signals:
	signal imem_address : std_logic_vector(31 downto 0);
	signal imem_data    : std_logic_vector(31 downto 0);
	signal imem_req, imem_ack : std_logic;

	-- Data memory signals:
	signal dmem_address   : std_logic_vector(31 downto 0);
	signal dmem_data_in   : std_logic_vector(31 downto 0);
	signal dmem_data_out  : std_logic_vector(31 downto 0);
	signal dmem_data_size : std_logic_vector( 1 downto 0);
	signal dmem_read_req  : std_logic;
	signal dmem_read_ack  : std_logic;
	signal dmem_write_req : std_logic;
	signal dmem_write_ack : std_logic;
	
    -- Wishbone interface 1:
    signal dmem_inf_adr_out : std_logic_vector(31 downto 0);
    signal dmem_inf_sel_out : std_logic_vector( 3 downto 0);
    signal dmem_inf_cyc_out : std_logic;
    signal dmem_inf_stb_out : std_logic;
    signal dmem_inf_we_out  : std_logic;
    signal dmem_inf_dat_out : std_logic_vector(31 downto 0);
    signal dmem_inf_dat_in  : std_logic_vector(31 downto 0);
    signal dmem_inf_ack_in  : std_logic;

    -- Wishbone interface 2:
    signal imem_inf_adr_out : std_logic_vector(31 downto 0);
    signal imem_inf_sel_out : std_logic_vector( 3 downto 0);
    signal imem_inf_cyc_out : std_logic;
    signal imem_inf_stb_out : std_logic;
    signal imem_inf_we_out  : std_logic;
    signal imem_inf_dat_out : std_logic_vector(31 downto 0);
    signal imem_inf_dat_in  : std_logic_vector(31 downto 0);
    signal imem_inf_ack_in  : std_logic;
begin
    processor : entity work.ps_core
    generic map (
        PROCESSOR_ID => PROCESSOR_ID,
        RESET_ADDRESS => RESET_ADDRESS
    )
    port map (
        clk => clk,
        reset => reset,
        imem_address => imem_address,
        imem_data_in => imem_data,
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

    imem_if: entity work.wb_adapter
    port map(
        clk => clk,
        reset => reset,
        mem_address => imem_address,
        mem_data_in => (others => '0'),
        mem_data_out => imem_data,
        mem_data_size => (others => '0'),
        mem_read_req => imem_req,
        mem_read_ack => imem_ack,
        mem_write_req => '0',
        mem_write_ack => open,
        wb_inputs_dat => imem_inf_dat_in,
		wb_inputs_ack => imem_inf_ack_in,
		wb_outputs_adr => imem_inf_adr_out,
		wb_outputs_sel => imem_inf_sel_out,
		wb_outputs_cyc => imem_inf_cyc_out,
		wb_outputs_stb => imem_inf_stb_out,
		wb_outputs_we => imem_inf_we_out,
		wb_outputs_dat => imem_inf_dat_out
    );

    dmem_if: entity work.wb_adapter
    port map(
        clk => clk,
        reset => reset,
        mem_address => dmem_address,
        mem_data_in => dmem_data_out,
        mem_data_out => dmem_data_in,
        mem_data_size => dmem_data_size,
        mem_read_req => dmem_read_req,
        mem_read_ack => dmem_read_ack,
        mem_write_req => dmem_write_req,
        mem_write_ack => dmem_write_ack,
        wb_inputs_dat => dmem_inf_dat_in,
		wb_inputs_ack => dmem_inf_ack_in,
		wb_outputs_adr => dmem_inf_adr_out,
		wb_outputs_sel => dmem_inf_sel_out,
		wb_outputs_cyc => dmem_inf_cyc_out,
		wb_outputs_stb => dmem_inf_stb_out,
		wb_outputs_we => dmem_inf_we_out,
		wb_outputs_dat => dmem_inf_dat_out
    );

    imem: entity work.soc_memory
		generic map(
			MEMORY_SIZE => IMEM_SIZE
		) port map(
			clk => clk,
			reset => reset,
			wb_adr_in => imem_inf_adr_out,
			wb_dat_in => imem_inf_dat_out,
			wb_dat_out => imem_inf_dat_in,
			wb_cyc_in => imem_inf_cyc_out,
			wb_stb_in => imem_inf_stb_out,
			wb_sel_in => imem_inf_sel_out,
			wb_we_in => imem_inf_we_out,
			wb_ack_out => imem_inf_ack_in
		);

	dmem: entity work.soc_memory
		generic map(
			MEMORY_SIZE => DMEM_SIZE
		) port map(
			clk => clk,
			reset => reset,
			wb_adr_in => dmem_inf_adr_out,
			wb_dat_in => dmem_inf_dat_out,
			wb_dat_out => dmem_inf_dat_in,
			wb_cyc_in => dmem_inf_cyc_out,
			wb_stb_in => dmem_inf_stb_out,
			wb_sel_in => dmem_inf_sel_out,
			wb_we_in => dmem_inf_we_out,
			wb_ack_out => dmem_inf_ack_in
		);
    
    wb_adr_out <= dmem_inf_adr_out;
    wb_dat_out <= dmem_inf_dat_out;
    wb_we_out <= dmem_inf_we_out;
    wb_sel_out <= dmem_inf_sel_out;

    -- arbiter: entity work.wb_arbiter
    -- port map(
    --     clk => clk,
    --     reset => reset,
    --     m1_inputs_dat => dmem_inf_dat_in,
	-- 	m1_inputs_ack => dmem_inf_ack_in,
	-- 	m1_outputs_adr => dmem_inf_adr_out,
	-- 	m1_outputs_sel => dmem_inf_sel_out,
	-- 	m1_outputs_cyc  => dmem_inf_cyc_out,
	-- 	m1_outputs_stb => dmem_inf_stb_out,
	-- 	m1_outputs_we  => dmem_inf_we_out,
	-- 	m1_outputs_dat => dmem_inf_dat_out,
    --     m2_inputs_dat => imem_inf_dat_in,
	-- 	m2_inputs_ack => imem_inf_ack_in,
	-- 	m2_outputs_adr => imem_inf_adr_out,
	-- 	m2_outputs_sel => imem_inf_sel_out,
	-- 	m2_outputs_cyc => imem_inf_cyc_out,
	-- 	m2_outputs_stb => imem_inf_stb_out,
	-- 	m2_outputs_we => imem_inf_we_out,
	-- 	m2_outputs_dat => imem_inf_dat_out,
    --     wb_adr_out => wb_adr_out,
    --     wb_sel_out => wb_sel_out,
    --     wb_cyc_out => wb_cyc_out,
    --     wb_stb_out => wb_stb_out,
    --     wb_we_out => wb_we_oudat_out => wb_dat_out,
    --     wb_dat_in => wb_dat_in,
    --     wb_ack_in => wb_ack_in
    -- );

    
end architecture;
