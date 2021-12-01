library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library cpu;
use cpu.all;

entity TB_data_forwarding is
end TB_data_forwarding;

architecture testbench of TB_data_forwarding is
constant period : time := 1us;
signal rs1_in, rs2_in, rs3_in : std_logic_vector(127 downto 0) := "00001111000011110000111100001111000011110000111100001111000011110000111100001111000011110000111100001111000011110000111100001111";
signal rs1_out, rs2_out, rs3_out : std_logic_vector(127 downto 0);
signal rd : std_logic_vector(127 downto 0) := "11110000111100001111000011110000111100001111000011110000111100001111000011110000111100001111000011110000111100001111000011110000";
signal rs1_select, rs2_select, rs3_select : std_logic;
signal instruction_WB, instruction_EX : std_logic_vector(24 downto 0);
begin
	TB_data_forwarding_control : entity data_forwarding_control port map(instruction_WB => instruction_WB, instruction_EX => instruction_EX,
		rs1_select => rs1_select, rs2_select => rs2_select, rs3_select => rs3_select);
		
	TB_data_forwarding_mux : entity data_forwarding_mux port map(rs1_reg => rs1_in, rs1_forward => rd, rs2_reg => rs2_in, rs2_forward => rd,
		rs3_reg => rs3_in, rs3_forward => rd, rs1_select => rs1_select, rs2_select => rs2_select, rs3_select => rs3_select, rs1 => rs1_out,
		rs2 => rs2_out, rs3 => rs3_out);
	
	TB_process: process
	begin
		-- use an r4 instruction on instruction_EX
		instruction_EX <= "1000010001010000001101100";	-- rs1 = 3, rs2 = 8, rs3 = 17, rd = 12
		-- use an r4 instruction on instruction_WB to ensure the data is forwarded to all registers
		instruction_WB <= "1000000000000000000000000";
		for i in 0 to 31 loop
			instruction_WB(4 downto 0) <= std_logic_vector(to_unsigned(i, 5));
			wait for period;
		end loop;
		-- use a nop on instruction_WB to ensure data is NOT forwarded								
		instruction_WB <= "1100000000000000000000000";
		for i in 0 to 31 loop
			instruction_WB(4 downto 0) <= std_logic_vector(to_unsigned(i, 5));
			wait for period;
		end loop;
		-- use a li on instruction_EX to verify that data is forwarded based on the rd field rather than rs1
		-- for one value rs2 and rs3 will get forwarded, which is fine cause the ALU doesn't use them
		instruction_WB <= "1000000000000000000000000";
		instruction_EX <= "0000000000000000000001100";	--li instruction, rd = 12
		for i in 0 to 31 loop
			instruction_WB(4 downto 0) <= std_logic_vector(to_unsigned(i, 5));
			wait for period;
		end loop;
		std.env.finish;
	end process TB_process;
end testbench;