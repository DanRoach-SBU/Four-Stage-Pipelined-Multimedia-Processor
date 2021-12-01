library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library cpu;
use cpu.all;
use cpu.register_file_data_types.all;

entity TB_register_file is
end TB_register_file;

architecture testbench of TB_register_file is
constant period : time := 1us;
signal clk : std_logic := '0';
signal clr : std_logic := '0';
signal not_clk : std_logic;
signal ID_instruction, WB_instruction : std_logic_vector(24 downto 0);
signal rs1, rs2, rs3, rd : std_logic_vector(127 downto 0);
signal rs1_index : std_logic_vector(4 downto 0);
signal register_write : std_logic;
signal register_file_contents : register_set;	-- contains all the current register values
begin
	TB_register_file_control : entity register_file_control port map(clk => clk, instruction_ID => ID_instruction, instruction_WB => WB_instruction,
		not_clk => not_clk, rs1_index => rs1_index, register_write => register_write);
		
	TB_register_file : entity register_file port map(clk => not_clk, clr => clr, rs1_index => rs1_index, rs2_index => ID_instruction(14 downto 10),
		rs3_index => ID_instruction(19 downto 15), rd => rd, rd_index => WB_Instruction(4 downto 0), register_write => register_write,
		rs1 => rs1, rs2 => rs2, rs3 => rs3, register_file_contents => register_file_contents);
	
	TB_clk: process
	begin
		wait for period / 2.0;
		clk <= not clk;
	end process TB_clk;
		
	TB_RF_process: process
	begin
		clr <= '0';
		wait for period;
		clr <= '1';
		wait for period;
		clr <= '0';
		ID_instruction <= "1100000000000000000000000";	-- nop on ID_instruction
		wait for period;
		
		-- load values into each register, should just load the number of each register into the register to make things easy
		for i in 0 to 31 loop
			WB_instruction <= "10000000000000000000" & std_logic_vector(to_unsigned(i, 5));
			rd <= std_logic_vector(to_unsigned(0, 123)) & std_logic_vector(to_unsigned(i, 5));
			wait for period;
		end loop;
		
		-- test read on normal r3 instruction
		WB_instruction <= "1100000000000000000000000";	-- put a nop instruction on WB so it doesn't continue writing to registers
		for i in 0 to 31 loop
			ID_instruction <= "100000000000000" & std_logic_vector(to_unsigned(i, 5)) & "00000"; -- rs1 = i, rs2 = 0, rs3 = 0
			wait for period;
		end loop;
		for i in 0 to 31 loop
			ID_instruction <= "1000000000" & std_logic_vector(to_unsigned(i, 5)) & "0000000000"; -- rs1 = 0, rs2 = i, rs3 = 0
			wait for period;
		end loop;
		for i in 0 to 31 loop
			ID_instruction <= "10000" & std_logic_vector(to_unsigned(i, 5)) & "000000000000000"; -- rs1 = 0, rs2 = 0, rs3 = i
			wait for period;
		end loop;
		
		-- test read for li instruction, rd field should be put to rs1
		for i in 0 to 31 loop
			ID_instruction <= "00000000000000000000" & std_logic_vector(to_unsigned(i, 5)); -- rd = i
			wait for period;
		end loop;
		
		std.env.finish;
		
	end process TB_RF_process;
end testbench;