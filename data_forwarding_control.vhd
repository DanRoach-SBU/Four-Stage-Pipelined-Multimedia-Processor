library ieee;
use ieee.std_logic_1164.all;

entity data_forwarding_control is
	port (
	instruction_WB : in std_logic_vector(24 downto 0);	-- instruction at the writeback stage
	instruction_EX : in std_logic_vector(24 downto 0);	-- instruction at the execute stage
	rs1_select : out std_logic;							-- select for multiplexer on the ALU input rs1: 0 for register file output, 1 for forwarded data
	rs2_select : out std_logic;							-- select for multiplexer on the ALU input rs2: 0 for register file output, 1 for forwarded data
	rs3_select : out std_logic							-- select for multiplexer on the ALU input rs3: 0 for register file output, 1 for forwarded data
	);
end data_forwarding_control;

architecture pain of data_forwarding_control is
begin
	data_forwarding_control_process: process (all) -- use of all only compiles using VHDL 2008 or newer
	variable forward_enable : std_logic;
	begin
		-- if instruction_WB is nop, the writeback data is not getting written to a register so it should not be forwarded
		-- if instruction_EX is li, rs1 might be rd or 0, if it's rd then it should get forwarded, if 0 then no forward
		if instruction_WB(24 downto 23) = "11" and instruction_WB(18 downto 15) = "0000" then -- instruction for writeback is nop
			forward_enable := '0';	-- instruction_WB is nop so don't enable forwarding	
		elsif instruction_EX(24) = '0' then -- instruction_EX is li
			-- idk wtf to do here cause I'm unsure if rs1 will be the contents of rd currently or if it's 0 all the time. need to ask professor
		else	-- instruction_WB was not nop
			forward_enable := '1';	-- instruction_WB computed valuable data and it should be forwarded
		end if;
		
		-- compare registers from ID/EX buffer to the forwarded value and enable values
		-- compare rs1	
		if instruction_WB(4 downto 0) = instruction_EX(9 downto 5) and forward_enable = '1' then
			rs1_select <= '1';
		else
			rs1_select <= '0';
		end if;
		
		-- compare rs2	
		if instruction_WB(4 downto 0) = instruction_EX(14 downto 10) and forward_enable = '1' then
			rs2_select <= '1';
		else
			rs2_select <= '0';
		end if;
		
		-- compare rs3	
		if instruction_WB(4 downto 0) = instruction_EX(19 downto 15) and forward_enable = '1' then
			rs3_select <= '1';
		else
			rs3_select <= '0';
		end if;
		
		
	end process data_forwarding_control_process;	 
end pain; -- please										