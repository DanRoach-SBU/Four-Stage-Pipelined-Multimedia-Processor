library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library cpu;
use cpu.all;

entity TB_instruction_buffer is
end TB_instruction_buffer;

architecture testbench of TB_instruction_buffer is
constant period : time := 1us;
signal clk : std_logic := '1';
signal PC : std_logic_vector (5 downto 0);
signal instruction_in : std_logic_vector(24 downto 0);
signal write_enable : std_logic;
signal write_address : std_logic_vector(5 downto 0);
signal instruction_out : std_logic_vector(24 downto 0);
begin
	TB_IB : entity instruction_buffer port map(clk => clk, PC => PC, instruction_in => instruction_in, write_enable => write_enable, write_address => write_address, instruction_out => instruction_out);
		
	TB_IB_clk_process: process
	begin
		wait for period / 2.0;
		clk <= not clk;
	end process TB_IB_clk_process;
	
	TB_IB_process: process
	begin					 
		write_enable <= '1';
		PC <= "000000";
		for i in 0 to 63 loop
			instruction_in <= std_logic_vector(rotate_left(to_unsigned(1, 25), i));
			write_address <= std_logic_vector(to_unsigned(i, 6));
			wait for period;
		end loop;		   		
		write_enable <= '0';
		
		for i in 0 to 63 loop
			PC <= std_logic_vector(to_unsigned(i, 6));
			wait for period;
		end loop;
		
		std.env.finish;
	end process;
end testbench;