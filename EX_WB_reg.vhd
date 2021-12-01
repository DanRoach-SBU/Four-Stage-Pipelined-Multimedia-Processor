library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;

entity EX_WB_reg is
	port(
	clk : in std_logic;
	clr : in std_logic;
	instruction_in : in std_logic_vector(24 downto 0);
	ALU_result_in : in std_logic_vector(127 downto 0);
	instruction_out : out std_logic_vector(24 downto 0);
	ALU_result_out : out std_logic_vector(127 downto 0)
	);
end EX_WB_reg;

architecture behavioral of EX_WB_reg is
begin
	EX_WB_reg_process: process (clk)
	begin
		if rising_edge(clk) then
			if clr = '1' then
				instruction_out <= "1100000000000000000000000";
				ALU_result_out <= std_logic_vector(to_unsigned(0, 128));
			else
				instruction_out <= instruction_in;
				ALU_result_out <= ALU_result_in;
			end if;
		end if;
	end process EX_WB_reg_process;
end behavioral;