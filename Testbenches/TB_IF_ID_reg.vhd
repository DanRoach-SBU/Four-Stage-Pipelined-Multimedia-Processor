library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library cpu;
use cpu.all;

entity TB_IF_ID_reg is
end TB_IF_ID_reg;

architecture testbench of TB_IF_ID_reg is
	signal TB_clk : std_logic := '1';
	signal TB_clr : std_logic := '0';
	signal TB_instruction_in, TB_instruction_out : std_logic_vector (24 downto 0);
	constant period : time := 1us;
begin						 
	
	UUT : entity IF_ID_reg port map(clk => TB_clk, clr => TB_clr, instruction_in => TB_instruction_in, instruction_out => TB_instruction_out);
		
	clk_process: process
	begin
		TB_clk <= not TB_clk;
		wait for period / 2.0;
	end process clk_process;
	
	TB_process: process
	begin
	TB_clr <= '1';
	wait for period;
	TB_clr <= '0';
		for i in 0 to 24 loop
			TB_instruction_in <= std_logic_vector(to_unsigned(i, 25));
			wait for period;
		end loop;
	std.env.finish;
	end process TB_process;
end testbench;