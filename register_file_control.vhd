library ieee;
use ieee.std_logic_1164.all;

-- This literally just inverts the clock signal and computes whether the ALU result should be written to the register file
entity register_file_control is
	port(
	clk : in std_logic;									-- clock signal
	instruction_ID : in std_logic_vector(24 downto 0);	-- instruction from the decode stage
	instruction_WB : in std_logic_vector(24 downto 0);	-- instruction received from the writeback stage
	not_clk : out std_logic;							-- inverted clock signal to be sent to the register file
	rs1_index : out std_logic_vector(4 downto 0);		-- rd if instruction is li, rs1 if not
	register_write : out std_logic						-- enable signal for the write to the register file
	);
end register_file_control;

architecture behavioral of register_file_control is
begin
	not_clk <= not clk;																			-- invert clk to make register file write on a falling edge
	register_file_control_process: process (instruction_WB)
	begin
		if instruction_WB(24 downto 23) = "11" and instruction_WB(18 downto 15) = "0000" then	-- if instruction is nop
			register_write <= '0';																-- don't write to rd on a nop
		else																					-- if instruction wants to write to rd
			register_write <= '1';																-- enable write
		end if;
		
		if instruction_ID(24) = '0' then														-- instruction_ID is li
			rs1_index <= instruction_ID(4 downto 0);											-- load rd index into rs1_index
		else																					-- instruction_ID is not li
			rs1_index <= instruction_ID(9 downto 5);											-- load normal rs1 index field
		end if;
	end process register_file_control_process;
end;											  
