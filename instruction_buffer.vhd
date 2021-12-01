library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_buffer is
	port(	 
	clk : in std_logic;									-- clock signal to control synchronous writing
	PC : in std_logic_vector(5 downto 0);				-- input for the program counter value
	instruction_in : in std_logic_vector(24 downto 0);	-- signal to write a value into the buffer at write_address
	write_enable : in std_logic;						-- control signal to enable writing to write_address
	write_address : in std_logic_vector(5 downto 0);	-- address to write data to
	instruction_out : out std_logic_vector(24 downto 0)	-- instruction fetched from the buffer at location PC
	);
end instruction_buffer;

architecture behavioral of instruction_buffer is
type buf is array (63 downto 0) of std_logic_vector(24 downto 0);
signal inst_buffer : buf;
begin
	instruction_out <= inst_buffer(to_integer(unsigned(PC)));					-- combinational instruction read at location PC
	
	-- synchronous write process
	instruction_buffer_write_process: process (clk)
	begin
		if rising_edge(clk) and write_enable = '1' then						-- only write data on the FALLING EDGE of the clock
			inst_buffer(to_integer(unsigned(write_address))) <= instruction_in;	-- write the data to the specified address
		end if;
	end process instruction_buffer_write_process;
end behavioral;