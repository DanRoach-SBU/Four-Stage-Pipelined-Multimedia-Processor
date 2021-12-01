library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
	port (
	rs1 : in std_logic_vector(127 downto 0);	-- value read from rs1
	rs2 : in std_logic_vector(127 downto 0);	-- value read from rs2
	rs3 : in std_logic_vector(127 downto 0);	-- value read from rs3
	instruction : in std_logic_vector(24 downto 0);	-- the instruction to be executed
	rd : out std_logic_vector(127 downto 0)			-- value to be written to rd
	);
end ALU;

architecture behavioral of ALU is
begin			
	ALU_process: process (all)
	
		variable li_index : integer;							 			 
		variable r4_product_64, r4_sum_64 : signed(63 downto 0);
		variable r4_product_32, r4_sum_32 : signed(31 downto 0);
		variable r4_LH : integer;	-- variable used to keep track of whether low or high sections are being used. just exists to make expressions more readable
		variable r3_sum : integer;
		variable r3_sum_16 : signed(15 downto 0);
		variable r3_unsigned_sum_16b : unsigned(16 downto 0);	-- Despite the name saying 16b, there are 17 bits cause sum of n bit number requires n + 1 bits
		variable r3_product : integer;
		variable r3_sign : integer;
		variable rotate_amount, shift_amount : integer;				  
		
		function number_of_ones_16b(input : std_logic_vector(15 downto 0)) return integer is
			variable n : integer;
		begin
			n := 0;
			for i in 0 to 15 loop
				if input(i) = '1' then
					n := n + 1;	-- try to rewrite this without an if statement. determine how to cast std_logic to an integer
				end if;
			end loop;
			return n;
		end number_of_ones_16b;
	
		function count_leading_zeros_32b(input : std_logic_vector(31 downto 0)) return integer is
		variable n : integer;
		variable z : std_logic;
		begin																						 
			n := 0;
			z := '1';
			for i in 31 downto 0 loop
				if input(i) = '0' and z = '1' then
					n := n + 1;
				else
					z := '0';
				end if;
			end loop;
			return n;
		end count_leading_zeros_32b;
	
	begin										
		if instruction(24) = '0' then
			-- load immediate
			-- the immediate will be added from the instruction at the index specified by the instruction
			rd <= rs1;
			li_index := to_integer(unsigned(instruction(23 downto 21))) * 16;
			rd(li_index + 15 downto li_index) <= instruction(20 downto 5);
		elsif instruction(23) = '0' then							  
			-- r4 instruction	
			-- store the LH bit in an integer to be used in index computations. I would like to implement this assignment without using an if statement, but I really don't know my types very well
			if instruction(20) = '1' then
				r4_LH := 1;
			else
				r4_LH := 0;
			end if;
			
			if instruction(22) = '1' then		-- long
				for i in 0 to 1 loop																																							
					r4_product_64 := signed(rs2(31 + r4_LH * 32 + i * 64 downto r4_LH * 32 + i * 64)) * signed(rs3(31 + r4_LH * 32 + i * 64 downto r4_LH * 32 + i * 64));
					if instruction(21) = '1' then
						r4_product_64 := -r4_product_64;
					end if;   
					r4_sum_64 := signed(rs1(63 + i * 64 downto i * 64)) + r4_product_64;
					if r4_product_64 > 0 and signed(rs1(63 + i * 64 downto i * 64)) > 0 and r4_sum_64 < 0 then -- overflow
						r4_sum_64 := "0111111111111111111111111111111111111111111111111111111111111111";
					elsif r4_product_64 < 0 and signed(rs1(63 + i * 64 downto i * 64)) < 0 and r4_sum_64 > 0 then	-- underflow
						r4_sum_64 := "1000000000000000000000000000000000000000000000000000000000000000";
					end if;
					rd(63 + i * 64 downto i * 64) <= std_logic_vector(r4_sum_64);
				end loop;																																											
			else								-- normal sized int			
				for i in 0 to 3 loop
					r4_product_32 := signed(rs2(15 + r4_LH * 16 + i * 32 downto r4_LH * 16 + i * 32)) * signed(rs3(15 + r4_LH * 16 + i * 32 downto r4_LH * 16 + i * 32));
					if instruction(21) = '1' then
						r4_product_32 := -r4_product_32;
					end if;
					r4_sum_32 := signed(rs1(31 + i * 32 downto i * 32)) + r4_product_32;
					if r4_product_32 > 0 and signed(rs1(31 + i * 32 downto i * 32)) > 0 and r4_sum_32 < 0 then -- overflow
						r4_sum_32 := "01111111111111111111111111111111";
					elsif r4_product_32 < 0 and signed(rs1(31 + i * 32 downto i * 32)) < 0 and r4_sum_32 > 0 then	-- underflow
						r4_sum_32 := "10000000000000000000000000000000";										
					end if;
					rd(31 + i * 32 downto i * 32) <= std_logic_vector(r4_sum_32);
				end loop;																																												
			end if;
		else
			-- r3 instruction
			if instruction(18 downto 15) = "0000" then				-- nop
				rd <= std_logic_vector(to_unsigned(0, 128));
			elsif instruction (18 downto 15) = "0001" then			-- add halfword
				for i in 0 to 7 loop
					r3_sum := to_integer(signed(rs1(15 + i * 16 downto i * 16))) + to_integer(signed(rs2(15 + i * 16 downto i * 16)));
					rd(15 + i * 16 downto i * 16) <= std_logic_vector(to_signed(r3_sum, 16));
				end loop;
			elsif instruction (18 downto 15) = "0010" then			-- add halfword saturated
				for i in 0 to 7 loop															 
					r3_sum_16 := signed(rs1(15 + i * 16 downto i * 16)) + signed(rs2(15 + i * 16 downto i * 16));
					if rs1(15 + i * 16) = '0' and rs2(15 + i * 16) = '0' and r3_sum_16 < to_signed(0, 16) then	-- overflow
						r3_sum_16 := to_signed(32767, 16);														-- set to max value
					elsif rs1(15 + i * 16) = '1' and rs2(15 + i * 16) = '1' and r3_sum_16 > to_signed(0, 16) then	-- underflow
						r3_sum_16 := to_signed(-32768, 16);														-- set to min value
					end if;
					rd(15 + i * 16 downto i * 16) <= std_logic_vector(r3_sum_16);
				end loop;
			elsif instruction(18 downto 15) = "0011" then			-- broadcast word
				for i in 0 to 3 loop
					rd(31 + i * 32 downto i * 32) <= rs1(31 downto 0);
				end loop;
			elsif instruction(18 downto 15) = "0100" then			-- carry generate halfword
				for i in 0 to 7 loop
					r3_unsigned_sum_16b := resize(unsigned(rs1(15 + i * 16 downto i * 16)), 17) + resize(unsigned(rs2(15 + i * 16 downto i * 16)), 17);
					rd(i * 16) <= std_logic(r3_unsigned_sum_16b(16));
					rd(15 + i * 16 downto 1 + i * 16) <= std_logic_vector(to_unsigned(0, 15));
				end loop;
			elsif instruction(18 downto 15) = "0101" then			-- count leading zeros								
				for i in 0 to 3 loop  
					rd(31 + i * 32 downto i * 32) <= std_logic_vector(to_unsigned(count_leading_zeros_32b(rs1(31 + i * 32 downto i * 32)), 32));
				end loop;
			elsif instruction(18 downto 15) = "0110" then			-- max signed word
				for i in 0 to 3 loop
					if signed(rs1(31 + i * 32 downto i * 32)) >= signed(rs2(31 + i * 32 downto i * 32)) then
						rd(31 + i * 32 downto i * 32) <= rs1(31 + i * 32 downto i * 32);
					else
						rd(31 + i * 32 downto i * 32) <= rs2(31 + i * 32 downto i * 32);
					end if;
				end loop;
			elsif instruction(18 downto 15) = "0111" then			-- min signed word
				for i in 0 to 3 loop
					if signed(rs1(31 + i * 32 downto i * 32)) <= signed(rs2(31 + i * 32 downto i * 32)) then
						rd(31 + i * 32 downto i * 32) <= rs1(31 + i * 32 downto i * 32);
					else
						rd(31 + i * 32 downto i * 32) <= rs2(31 + i * 32 downto i * 32);
					end if;
				end loop;
			elsif instruction(18 downto 15) = "1000" then			-- multiply sign
				for i in 0 to 3 loop
					if to_integer(signed(rs2(31 + i * 32 downto i * 32))) > 0 then
						r3_sign := 1;
					elsif to_integer(signed(rs2(31 + i * 32 downto i * 32))) = 0 then
						r3_sign := 0;
					else
						r3_sign := -1;
					end if;	 
					r3_product := r3_sign * to_integer(signed(rs2(31 + i * 32 downto i * 32)));
					if r3_product = -2147483648 and r3_sign = -1 then		-- Saturation check, if max negative value and sign is negative then overflow happened
						r3_product := 2147483647;
					end if;
					rd(31 + i * 32 downto i * 32) <= std_logic_vector(to_signed(r3_product, 32));
				end loop;
			elsif instruction(18 downto 15) = "1001" then			-- count 1s in 16 bit values
				for i in 0 to 7 loop
					rd(15 + i * 16 downto i * 16) <= std_logic_vector(to_unsigned(number_of_ones_16b(rs1(15 + i * 16 downto i * 16)), 16));
				end loop;
			elsif instruction(18 downto 15) = "1010" then			-- rotate right						  
				rotate_amount := to_integer(unsigned(rs2(6 downto 0)));							   
				rd(127 - rotate_amount downto 0) <= rs1(127 downto rotate_amount);
				rd(127 downto 127 - (rotate_amount - 1)) <= rs1(rotate_amount - 1 downto 0);
			elsif instruction(18 downto 15) = "1011" then			-- rotate bits in word
				rotate_amount := to_integer(unsigned(rs2(4 downto 0)));
				for i in 0 to 7 loop
					rd(i * 16 + 15 - rotate_amount downto i * 16) <= rs1(i * 16 + 15 downto i * 16 + rotate_amount);
					rd(i * 16 + 15 downto i * 16 + 15 - (rotate_amount - 1)) <= rs1(i * 16 + rotate_amount - 1 downto i * 16);
				end loop;		
			elsif instruction(18 downto 15) = "1100" then			-- shift left halfword immediate
				shift_amount := to_integer(unsigned(instruction(13 downto 10)));																	   
				for i in 0 to 7 loop
					rd(i * 16 + 15 downto i * 16 + shift_amount) <= rs1(i * 16 + 15 - shift_amount downto i * 16);
					rd(i * 16 + shift_amount - 1 downto i * 16) <= std_logic_vector(to_unsigned(0, shift_amount));
				end loop;
			elsif instruction (18 downto 15) = "1101" then	-- subtract halfword
				for i in 0 to 7 loop
					r3_sum := to_integer(signed(rs1(15 + i * 16 downto i * 16))) - to_integer(signed(rs2(15 + i * 16 downto i * 16)));
					rd(15 + i * 16 downto i * 16) <= std_logic_vector(to_signed(r3_sum, 16));
				end loop;
			elsif instruction (18 downto 15) = "1110" then	-- subtract halfword saturated
				for i in 0 to 7 loop															 
					r3_sum_16 := signed(rs1(15 + i * 16 downto i * 16)) - signed(rs2(15 + i * 16 downto i * 16));
					if rs1(15 + i * 16) = '0' and rs2(15 + i * 16) = '1' and r3_sum_16 < to_signed(0, 16) then	-- overflow
						r3_sum_16 := to_signed(32767, 16);														-- set to max value
					elsif rs1(15 + i * 16) = '1' and rs2(15 + i * 16) = '0' and r3_sum_16 > to_signed(0, 16) then	-- underflow
						r3_sum_16 := to_signed(-32768, 16);														-- set to min value
					end if;
					rd(15 + i * 16 downto i * 16) <= std_logic_vector(r3_sum_16);	
				end loop;
			elsif instruction(18 downto 15) = "1111" then 			-- xor
				rd <= rs1 xor rs2;											  
			end if;
		end if;
	end process ALU_process;	
end behavioral;
