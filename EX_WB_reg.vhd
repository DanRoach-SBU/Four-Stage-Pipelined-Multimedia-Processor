library ieee;
use ieee.std_logic_1164.all;

entity EX_WB_reg is
	port(
	clk : in std_logic;
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
			instruction_out <= instruction_in;
			ALU_result_out <= ALU_result_in;
		end if;
	end process EX_WB_reg_process;
end behavioral;