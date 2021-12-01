library ieee;
use ieee.std_logic_1164.all;

entity IF_ID_reg is
	port(
	clk : in std_logic;
	clr : in std_logic;
	instruction_in : in std_logic_vector(24 downto 0);
	instruction_out : out std_logic_vector(24 downto 0)
	);
end IF_ID_reg;

architecture behavioral of IF_ID_reg is
begin
	IF_ID_reg_process: process (clk)
	begin
		if rising_edge(clk) then
			if clr = '1' then
				instruction_out <= "1100000000000000000000000";
			else
				instruction_out <= instruction_in;
			end if;
		end if;
	end process IF_ID_reg_process;
end behavioral;