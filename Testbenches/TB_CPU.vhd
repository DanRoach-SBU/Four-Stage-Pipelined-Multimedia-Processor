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
signal register_file_contents : register_set;				-- contents of the register file
begin
	CPU_UUT : entity CPU port map(clk => clk, clr => clr, PC_data => PC_data, PC_write_enable => PC_write_enable, IB_instruction => IB_instruction, IB_write_enable => IB_write_enable, IB_write_address => IB_write_address, register_file_contents => register_file_contents);
		
	TB_CPU_clk_process: process
	begin
		wait for period / 2.0;
		clk <= not clk;
	end process TB_CPU_clk_process;
		
	TB_CPU_process: process	 
	file input: text;
	variable L: line;
	variable instruction : std_logic_vector(24 downto 0);	-- variable to read the instruction into. read only allows to write to a variable, not a signal
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
			instruction_num := instruction_num + 1;
			IB_write_address <= std_logic_vector(to_unsigned(instruction_num, 6));		
			wait for period;	   
		end loop;
		IB_write_enable <= '0';	
			
		-- synchronous reset
		clr <= '1';
		wait for period;
		clr <= '0';
		
		for i in 0 to instruction_num + 3 loop	-- let the PC load through each instruction and let the last instruction go through the pipeline
			-- let the thing do the thing
			wait for period;
		end loop;
		
		std.env.finish;
	end process TB_CPU_process;
end testbench;