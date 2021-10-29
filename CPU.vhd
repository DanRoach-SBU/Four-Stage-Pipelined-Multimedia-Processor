library ieee;
use ieee.std_logic_1164.all;

library cpu;
use cpu.all;

entity CPU is
	port(
	clk : in std_logic;									-- clock signal
	clr : in std_logic;									-- synchronous clear for supported elements
	PC_data : in std_logic_vector(5 downto 0);			-- data to write to the program counter
	PC_write_enable : in std_logic;						-- control signal to write PC_data to the program counter
	IB_instruction : in std_logic_vector(24 downto 0);	-- instruction to write to instruction buffer (IB)
	IB_write_enable : in std_logic;						-- enable writing IB_instruction to the instruction buffer
	IB_write_address : in std_logic_vector(5 downto 0)	-- address to write IB_instruction to
	);
end CPU;

architecture structural of CPU is
-- signal naming: [STAGE]_[COMPONENT]_[SIGNAL]
signal IF_instruction, ID_instruction, EX_instruction, WB_instruction : std_logic_vector(24 downto 0);	-- instruction signals that exist throughout the pipeline
signal ID_rs1, EX_mux_rs1_in, EX_ALU_rs1_in : std_logic_vector(127 downto 0);							-- rs1 signals that exist throughout the pipeline
signal ID_rs2, EX_mux_rs2_in, EX_ALU_rs2_in : std_logic_vector(127 downto 0);							-- rs2 signals that exist throughout the pipeline
signal ID_rs3, EX_mux_rs3_in, EX_ALU_rs3_in : std_logic_vector(127 downto 0);							-- rs3 signals that exist throughout the pipeline
signal EX_rd, WB_rd : std_logic_vector(127 downto 0);													-- rd signals that exist throughout the pipeline
signal EX_mux_rs1_select, EX_mux_rs2_select, EX_mux_rs3_select : std_logic;								-- select signals for the data forwarding multiplexers
signal ID_register_write, ID_not_clk : std_logic;														-- control and inverted clock signals for the register file
signal ID_rs1_index : std_logic_vector(4 downto 0);														-- register index for value to be read to rs1 datapath		
signal IF_PC : std_logic_vector(5 downto 0);															-- program counter value										 
begin 																				
	IF_program_counter : entity program_counter port map(clk => clk, clr => clr, d => PC_data, write_enable => PC_write_enable, PC => IF_PC);
		
	IF_instruction_buffer : entity instruction_buffer port map(clk => clk, PC => IF_PC, instruction_in => IB_instruction, write_enable => IB_write_enable,
		write_address => IB_write_address, instruction_out => IF_instruction);
	
	IF_ID_pipeline_register : entity IF_ID_reg port map(clk => clk, instruction_in => IF_instruction, instruction_out => ID_instruction);
	
	ID_register_file_control : entity register_file_control port map(clk => clk, instruction_ID => ID_instruction, instruction_WB => WB_instruction,
		not_clk => ID_not_clk, rs1_index => ID_rs1_index, register_write => ID_register_write);
		
	ID_register_file : entity register_file port map(clk => ID_not_clk, rs1_index => ID_rs1_index, rs2_index => ID_instruction(14 downto 10),
		rs3_index => ID_instruction(19 downto 15), rd => WB_rd, rd_index => WB_instruction(4 downto 0), register_write => ID_register_write,
		rs1 => ID_rs1, rs2 => ID_rs2, rs3 => ID_rs3);
		
	ID_EX_pipeline_register : entity ID_EX_reg port map(clk => clk, instruction_in => ID_instruction, rs1_in => ID_rs1, rs2_in => ID_rs2,
		rs3_in => ID_rs3, instruction_out => EX_instruction, rs1_out => EX_mux_rs1_in, rs2_out => EX_mux_rs2_in, rs3_out => EX_mux_rs3_in);
		
	EX_data_forwarding_mux : entity data_forwarding_mux port map(rs1_reg => EX_mux_rs1_in, rs1_forward => WB_rd, rs2_reg => EX_mux_rs2_in,
		rs2_forward => WB_rd, rs3_reg => EX_mux_rs3_in, rs3_forward => WB_rd, rs1_select => EX_mux_rs1_select, rs2_select => EX_mux_rs2_select,
		rs3_select => EX_mux_rs3_select, rs1 => EX_ALU_rs1_in, rs2 => EX_ALU_rs2_in, rs3 => EX_ALU_rs3_in);
		
	EX_ALU : entity ALU port map(rs1 => EX_ALU_rs1_in, rs2 => EX_ALU_rs2_in, rs3 => EX_ALU_rs3_in, instruction => EX_instruction, rd => EX_rd);
		
	EX_WB_pipeline_register : entity EX_WB_reg port map(clk => clk, instruction_in => EX_instruction, ALU_result_in => EX_rd,
		instruction_out => WB_instruction, ALU_result_out => WB_rd);
		
	EX_WB_data_forwarding_control : entity data_forwarding_control port map(instruction_WB => WB_instruction, instruction_EX => EX_instruction,
		rs1_select => EX_mux_rs1_select, rs2_select => EX_mux_rs2_select, rs3_select => EX_mux_rs3_select);
end structural;