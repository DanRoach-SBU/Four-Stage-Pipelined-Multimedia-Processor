library ieee;
use ieee.std_logic_1164.all;

entity data_forwarding_mux is
	port(
	rs1_reg : in std_logic_vector(127 downto 0);		-- rs1 obtained from the register
	rs1_forward : in std_logic_vector(127 downto 0);	-- rs1 obtained from EX-WB pipeline register
	rs2_reg : in std_logic_vector(127 downto 0);		-- rs2 obtained from the register
	rs2_forward : in std_logic_vector(127 downto 0);	-- rs2 obtained from EX-WB pipeline register
	rs3_reg : in std_logic_vector(127 downto 0);		-- rs3 obtained from the register
	rs3_forward : in std_logic_vector(127 downto 0);	-- rs3 obtained from EX-WB pipeline register
	rs1_select : in std_logic;							-- select signal for rs1 obtained from the data forwarding control unit
	rs2_select : in std_logic;							-- select signal for rs2 obtained from the data forwarding control unit
	rs3_select : in std_logic;							-- select signal for rs3 obtained from the data forwarding control unit
	rs1 : out std_logic_vector(127 downto 0);			-- final output for rs1 
	rs2 : out std_logic_vector(127 downto 0);			-- final output for rs2
	rs3 : out std_logic_vector(127 downto 0)			-- final output for rs3
	);
end data_forwarding_mux;

architecture behavioral of data_forwarding_mux is
begin 
	data_forwarding_mux_process: process (all)
	begin
		if rs1_select = '1' then
			rs1 <= rs1_forward;
		else
			rs1 <= rs1_reg;
		end if;
	
		if rs2_select = '1' then
			rs2 <= rs2_forward;
		else
			rs2 <= rs2_reg;
		end if;
	
		if rs3_select = '1' then
			rs3 <= rs3_forward;
		else
			rs3 <= rs3_reg;
		end if;
	end process data_forwarding_mux_process;
end behavioral;