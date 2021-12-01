library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
library cpu;
use cpu.all;
use register_file_data_types.all;

entity TB_CPU is
end TB_CPU;

architecture testbench of TB_CPU is
constant period : time := 1us;
signal clk, clr : std_logic := '0';							-- clock and synchronous clear signals 	   
signal PC_data : std_logic_vector(5 downto 0);				-- parallel load value for PC
signal PC_write_enable, IB_write_enable : std_logic := '0';	-- write enable inputs for the program counter and instruction buffer respectively
signal IB_instruction : std_logic_vector(24 downto 0);		-- instruction to be loaded into the instruction buffer
signal IB_write_address : std_logic_vector(5 downto 0);		-- address to write IB_instruction to  
signal PC : std_logic_vector(5 downto 0);										  
signal IF_instruction, ID_instruction, EX_instruction, WB_instruction : std_logic_vector(24 downto 0);
signal register_file_write_enable : std_logic;
signal data_forwarding_rs1, data_forwarding_rs2, data_forwarding_rs3 : std_logic;
signal ALU_out : std_logic_vector(127 downto 0);
signal register_file_contents : register_set;				-- contents of the register file
begin
	CPU_UUT : entity CPU port map(clk => clk, clr => clr,  PC_data => PC_data, PC_write_enable => PC_write_enable, IB_instruction => IB_instruction, IB_write_enable => IB_write_enable,
		IB_write_address => IB_write_address, PC => PC, IF_instruction_out => IF_instruction, ID_instruction_out => ID_instruction, EX_instruction_out => EX_instruction, 
		WB_instruction_out => WB_instruction, register_file_write_enable_out => register_file_write_enable, data_forwarding_rs1 => data_forwarding_rs1, data_forwarding_rs2 => data_forwarding_rs2,
		data_forwarding_rs3 => data_forwarding_rs3, ALU_out => ALU_out, register_file_contents => register_file_contents);
		
	TB_CPU_clk_process: process
	begin
		wait for period / 2.0;
		clk <= not clk;
	end process TB_CPU_clk_process;
		
	TB_CPU_process: process	 
	file input, output: text;
	variable L, reg_line: line;	 
	variable instruction : std_logic_vector(24 downto 0);	-- variable to read the instruction into. read only allows to write to a variable, not a signal
	variable reg : std_logic_vector(127 downto 0);
	variable instruction_num: integer := 0;
	variable errors: integer := 0;
	begin
		-- load instruction buffer contents
		FILE_OPEN(input, "instructions.txt", READ_MODE); 
		IB_write_enable <= '1';
		while not endfile(input) and instruction_num < 64 loop
			-- read the next instruction and put it in IB_instruction
			readline(input, L);
			read(L, instruction);
			IB_instruction <= instruction; 			  
			IB_write_address <= std_logic_vector(to_unsigned(instruction_num, 6));		
			wait for period;	   								 
			instruction_num := instruction_num + 1;
		end loop;
		IB_write_enable <= '0';	
			
		-- synchronous reset
		wait for period * 3;
		clr <= '1';
		wait for period;
		clr <= '0';
		
		for i in 0 to instruction_num + 3 loop	-- let the PC load through each instruction and let the last instruction go through the pipeline
			-- let the thing do the thing
			wait for period;
		end loop;
		
		FILE_OPEN(output, "register_file_results.txt", WRITE_MODE);
		for i in 0 to 31 loop
			reg := register_file_contents(i);
			write(reg_line, reg);
			writeline(output, reg_line);
		end loop;
		
		std.env.finish;
	end process TB_CPU_process;
end testbench;