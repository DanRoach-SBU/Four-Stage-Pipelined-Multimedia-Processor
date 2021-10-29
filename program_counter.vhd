library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 6 bit register to iterate through the instruction buffer
-- if write_enable = 1, PC = d, else PC = PC + 1
entity program_counter is
	port(
	clk : in std_logic;						-- clock
	clr : in std_logic;						-- synchronous clear
	d : in std_logic_vector(5 downto 0);	-- data, use if forcing pc to a new value
	write_enable : std_logic;				-- write enable
	PC : out std_logic_vector(5 downto 0)	-- program counter
	);
end program_counter;

architecture behavioral of program_counter is
signal counter : std_logic_vector(5 downto 0);
begin
	program_counter_process: process (clk)
	begin
		if rising_edge(clk) then
			if clr = '1' then										-- if the clear signal is set
				counter <= std_logic_vector(to_unsigned(0, 6));		-- set the contents of the register to 0
			elsif write_enable = '1' then							-- else if writing to the register
				counter <= d;										-- write the value on d to the register
			else													-- not clearing or writing new data
				counter <= std_logic_vector(unsigned(counter) + 1);	-- increment the counter to point to the next instruction
			end if;
			PC <= counter;											-- assign the new value to the output signal PC
		end if;
	end process program_counter_process;
end behavioral;