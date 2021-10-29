library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	port(
	clk : in std_logic;
	rs1_index : in std_logic_vector(4 downto 0);	-- MIGHT NEED TO MULTIPLEX RD FROM IF/ID BUFFER READ BELOW!!
	rs2_index : in std_logic_vector(4 downto 0);	-- comes from the instruction straight from the register buffer
	rs3_index : in std_logic_vector(4 downto 0);	-- comes from the instruction straight from the register buffer	   
	
	rd : in std_logic_vector(127 downto 0);			-- value to write to the register
	rd_index : in std_logic_vector(4 downto 0);		-- comes from the instruction that just came out of the ALU/write decode shit
	register_write : in std_logic;					-- signal generated in register_file_control.vhd which reads the instruction from the EX/WB register to determine if a write is being done
	
	rs1 : out std_logic_vector(127 downto 0);		-- output of register file for contents of rs1
	rs2 : out std_logic_vector(127 downto 0);		-- output of register file for contents of rs2
	rs3 : out std_logic_vector(127 downto 0)		-- output of register file for contents of rs3
	);
end register_file;

architecture behavioral of register_file is
type register_set is array (31 downto 0) of std_logic_vector(127 downto 0);
signal registers : register_set;
begin
	-- Combinational read process
	register_file_read_process : process (rs1_index, rs2_index, rs3_index)
	begin
		rs1 <= registers(to_integer(unsigned(rs1_index)));
		rs2 <= registers(to_integer(unsigned(rs2_index)));
		rs3 <= registers(to_integer(unsigned(rs3_index)));	-- I don't think I need to surround this with an if statement. Loading the register value should be fine even if it isn't an R4 instruction
															-- because if it isn't an r4 instruction the garbage value will not be used by the ALU
	end process register_file_read_process;	
	
	-- Clocked write process. Writes on RISING EDGE. If the context wants to write on the FALLING EDGE, it must INVERT THE CLOCK
	register_file_write_process: process (clk)
	begin
		if rising_edge(clk) and register_write = '1' then
			registers(to_integer(unsigned(rd_index))) <= rd;
		end if;
	end process register_file_write_process;
end behavioral;
