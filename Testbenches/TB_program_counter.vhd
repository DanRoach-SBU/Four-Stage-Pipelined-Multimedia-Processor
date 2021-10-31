library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library cpu;
use cpu.all;

entity TB_program_counter is
end TB_program_counter;

architecture testbench of TB_program_counter is
constant period : time := 1us;
signal clk : std_logic := '0';
signal clr : std_logic;
signal d : std_logic_vector(5 downto 0);
signal write_enable : std_logic := '0';
signal PC : std_logic_vector(5 downto 0);
begin
	TB_PC : entity program_counter port map(clk => clk, clr => clr, d => d, write_enable => write_enable, PC => PC);
	TB_clk_process: process
	begin
		wait for period / 2.0;
		clk <= not clk;
	end process TB_clk_process;	
	
	TB_PC_process: process
	begin
		clr <= '1';	-- initialize the counter to 0
		wait for period;
		clr <= '0';	-- clear the clear signal (that could be phrased better)
		wait for period * 16;	-- wait for 16 clock cycles to allow the program counter to count naturally
		d <= "000101";	-- assign a value to the parallel load input
		write_enable <= '1';	-- enable parallel load
		wait for period;
		write_enable <= '0';	-- disable parallel load
		wait for period * 20;	-- allow loaded value to continue counting
		std.env.finish;
	end process TB_PC_process;
end testbench;