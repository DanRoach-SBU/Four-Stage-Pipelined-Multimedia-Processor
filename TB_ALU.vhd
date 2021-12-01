library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library cpu;
use cpu.all;

entity ALU_testbench is
end ALU_testbench;		

architecture testbench of ALU_testbench is
	signal rs1, rs2, rs3, rd : std_logic_vector(127 downto 0);
	signal instruction : std_logic_vector(24 downto 0);
	constant period : time := 1us;
begin
	UUT : entity ALU
		port map (rs1 => rs1, rs2 => rs2, rs3 => rs3,
		instruction => instruction, rd => rd);	 
													 
		
	process begin
		rs1 <= std_logic_vector(to_unsigned(15, 128));
		rs2 <= std_logic_vector(to_unsigned(0, 128));
		rs3 <= std_logic_vector(to_unsigned(0, 128)); 
		--instruction <= std_logic_vector(to_unsigned(0, 25));
		-- load immediate
		instruction <= "0000100101101010011100000"; -- loads 1001011010100111 (0x96A7) at index 0
		wait for period;	-- 1us
		instruction <= "0010111100101000111000000"; -- loads 1111001010001110 = (0xF28E) at index 2
		wait for period;	-- 2us
		instruction <= "0111111111111111111100000"; -- loads 1111111111111111 = (0xFFFF) at index 7 
		wait for period;	-- 3us
		
		-- 3us have elapsed
		
		-- R4 INSTRUCTIONS 
		rs1 <= "00000000000000000000000000000001000000000000000000000000000011110000000000011100111111111111111110000000000000000000000000000000"; -- 0x0000 0001 0000 000F 001C FFFF 8000 0000
		rs2 <= "00000000000000110000000000001000000001000000010001111111111111110000000000000000000000000000011010000000000000000001001001000101"; -- 0x0003 0008 0404 7FFF 0000 0006 8000 1245
		rs3 <= "00000000000001000000000000001000000000000010001001111111111111110000000000000001000000000000011001111111111111110000010001000100"; -- 0x0004 0008 0022 7FFF 0001 0006 7FFF 0444
		instruction <= "1000000000000000000000000";	-- signed int multiply-add low	
		wait for period;	-- 4us
		instruction <= "1000100000000000000000000";	-- signed int multiply-add high	
		wait for period;	-- 5us
		instruction <= "1001000000000000000000000";	-- signed int multiply-subtract low	
		wait for period;	-- 6us
		instruction <= "1001100000000000000000000";	-- signed int multiply-subtract high	
		wait for period;	-- 7us
		instruction <= "1010000000000000000000000";	-- signed long multiply-add low	
		wait for period;	-- 8us
		instruction <= "1010100000000000000000000";	-- signed long multiply-add high 	
		wait for period;	-- 9us
		instruction <= "1011000000000000000000000";	-- signed long multiply-subtract low	
		wait for period;	-- 10us
		instruction <= "1011100000000000000000000";	-- signed long multiply-subtract high	
		wait for period;	-- 11us
		
		-- 11us have elapsed	  
		
		-- R3 INSTRUCTIONS	  		 
		rs1 <= "00000000000000000111111111111111100000000000000000000000000000000011101010010111000000000000000010101010101010101111111111111111"; -- 0x0000 7FFF 8000 0000 3A97 0000 AAAA FFFF
		rs2 <= "00000000000000000000000000000001111111111111111100000000000000000001001110011111000000000000000001010101010101011111111111111111"; -- 0x0000 0001 FFFF 0000 139F 0000 5555 FFFF
		rs3 <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"; -- 0x0000 0000 0000 0000 0000 0000 0000 0000
		instruction <= "1100000000000000000000000";		-- nop
		wait for period;	-- 12us
		instruction <= "1100000001000000000000000";		-- add halfword (unsaturated)
		wait for period;	-- 13us
		instruction <= "1100000010000000000000000";		-- add halfword (saturated)
		wait for period;	-- 14us
		instruction <= "1100000011000000000000000";		-- broadcast word
		wait for period;	-- 15us
		instruction <= "1100000100000000000000000";		-- carry generate halfword
		wait for period;	-- 16us
		instruction <= "1100000101000000000000000";		-- count leading zeros
		wait for period;	-- 17us
		instruction <= "1100000110000000000000000";		-- max signed word
		wait for period;	-- 18us	
		instruction <= "1100000111000000000000000";		-- min signed word
		wait for period;	-- 19us	
		instruction <= "1100001000000000000000000";		-- multiply sign
		wait for period;	-- 20us
		instruction <= "1100001001000000000000000";		-- count ones in halfwords
		wait for period;	-- 21us
		rs2 <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111";																												   
		instruction <= "1100001010000000000000000";		-- rotate bits right																	  
		wait for period;	-- 22us, here they should be rotated 127 bits to the right, aka 1 bit to the left	
		rs2 <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
		wait for period;	-- 23us, here they should be rotated 0 bits, rd = rs1
		rs2 <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011";
		wait for period;	-- 24us, here they should be rotated 3 bits to the right
		rs2 <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
		instruction <= "1100001011000000000000000";		-- rotate bits in word
		wait for period;	-- 25us, no rotation
		rs2 <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";										
		wait for period;	-- 26us, rotate 1 bit right
		rs2 <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100";								  
		wait for period;	-- 27us, rotate 4 bits right 
		rs2 <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
		instruction <= "1100001100000000000000000";		-- shift left halfword immediate
		wait for period;	-- 28us, no shift
		instruction <= "1100001100000010000000000";		-- shift left halfword immediate part 2
		wait for period;	-- 29us, shift 1 bit left
		instruction <= "1100001100001000000000000";		-- shift left halfword immediate part 3
		wait for period;	-- 30us, shift 4 bits left
		rs2 <= "00000000000000000000000000000001111111111111111100000000000000000001001110011111000000000000000001010101010101011111111111111111"; -- 0x0000 0001 FFFF 0000 139F 0000 5555 FFFF
		instruction <= "1100001101000000000000000";
		wait for period;	-- 31us, subtract from halfword
		instruction <= "1100001110000000000000000";
		wait for period;	-- 32us, subtract from halfword saturated
		instruction <= "1100001111000000000000000";
		wait for period;	-- 33us, xor  
		
		std.env.finish;
		
	end process;	  
	
end testbench;