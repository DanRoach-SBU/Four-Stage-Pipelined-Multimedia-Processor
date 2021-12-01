library ieee;
use ieee.std_logic_1164.all;

package register_file_data_types is
	type register_set is array (31 downto 0) of std_logic_vector(127 downto 0);
end package register_file_data_types;

package body register_file_data_types is
end package body register_file_data_types;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library cpu;
use cpu.register_file_data_types.all;

entity register_file is														  
	port(
	clk : in std_logic;
	clr : in std_logic;								-- asynchronous clear
	rs1_index : in std_logic_vector(4 downto 0);	-- multiplexed from register_file_control
	rs2_index : in std_logic_vector(4 downto 0);	-- comes from the instruction straight from the register buffer
	rs3_index : in std_logic_vector(4 downto 0);	-- comes from the instruction straight from the register buffer	   
	
	rd : in std_logic_vector(127 downto 0);			-- value to write to the register
	rd_index : in std_logic_vector(4 downto 0);		-- comes from the instruction that just came out of the ALU/write decode shit
	register_write : in std_logic;					-- signal generated in register_file_control.vhd which reads the instruction from the EX/WB register to determine if a write is being done
	
	rs1 : out std_logic_vector(127 downto 0);		-- output of register file for contents of rs1
	rs2 : out std_logic_vector(127 downto 0);		-- output of register file for contents of rs2
	rs3 : out std_logic_vector(127 downto 0);		-- output of register file for contents of rs3 
		
	register_file_contents: out register_set		-- array of registers for the CPU testbench to analyze
	); 																		   
end register_file;


architecture behavioral of register_file is									 
signal registers : register_set;
begin
	-- Combinational read
	rs1 <= registers(to_integer(unsigned(rs1_index)));
	rs2 <= registers(to_integer(unsigned(rs2_index)));
	rs3 <= registers(to_integer(unsigned(rs3_index)));
	register_file_contents <= registers;
	
	-- Clocked write process. Writes on RISING EDGE.
	register_file_write_process: process (clk, clr)
	begin 
		if clr = '1' then
			for i in 0 to 31 loop
				registers(i) <= std_logic_vector(to_unsigned(0, 128));
			end loop;
		elsif rising_edge(clk) and register_write = '1' then
			registers(to_integer(unsigned(rd_index))) <= rd;
		end if;
	end process register_file_write_process;
end behavioral;