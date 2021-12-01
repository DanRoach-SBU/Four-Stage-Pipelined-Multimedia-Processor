library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_EX_reg is
	port(
	clk : in std_logic;
	clr : in std_logic;										-- rather than resetting all bits, this actually just inserts a nop into the register, synchronous clear btw
	instruction_in : in std_logic_vector(24 downto 0);
	rs1_in : in std_logic_vector(127 downto 0);
	rs2_in : in std_logic_vector(127 downto 0);
	rs3_in : in std_logic_vector(127 downto 0);
	instruction_out : out std_logic_vector(24 downto 0);
	rs1_out : out std_logic_vector(127 downto 0);
	rs2_out : out std_logic_vector(127 downto 0);
	rs3_out : out std_logic_vector(127 downto 0)
	);
end ID_EX_reg;

architecture behavioral of ID_EX_reg is
begin
	ID_EX_reg_process: process (clk)
	begin
		if rising_edge(clk) then
			if clr = '1' then
				instruction_out <= "1100000000000000000000000";
				rs1_out <= std_logic_vector(to_unsigned(0, 128));
				rs2_out <= std_logic_vector(to_unsigned(0, 128));
				rs3_out <= std_logic_vector(to_unsigned(0, 128));
			else
				instruction_out <= instruction_in;
				rs1_out <= rs1_in;
				rs2_out <= rs2_in;
				rs3_out <= rs3_in;
			end if;
		end if;
	end process ID_EX_reg_process;
end behavioral;