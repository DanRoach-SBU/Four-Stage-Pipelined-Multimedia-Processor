#include <iostream>
#include <fstream>
#include <map>
#include <bitset>

#define MAX_LEN 128
#define SYNTAX_ERROR 1
#define RANGE_ERROR 2

enum instruction_type {LI, R4, R3, ERROR};
typedef struct _instruction
{
	instruction_type type;
	std::string opcode;
} instruction;

std::string itoab(int x, unsigned int n_bits);

int main(int argc, char** argv)
{
	std::string filename;
	std::cout << "Enter the assembly filename\n";
	std::cin >> filename;
	std::ifstream input{ filename, std::ios_base::in };
	std::ofstream output{ "instructions.txt", std::ios_base::out };
	int line = 1;

	// Stroustrup page 910
	std::map<std::string, std::pair<instruction_type, std::string>> instruction_hash
	{
		{ "li", {instruction_type::LI, "0"} },
		{ "simal", {instruction_type::R4, "000"} },
		{ "simah", {instruction_type::R4, "001"} },
		{ "simsl", {instruction_type::R4, "010"} },
		{ "simsh", {instruction_type::R4, "011"} },
		{ "slmal", {instruction_type::R4, "100"} },
		{ "slmah", {instruction_type::R4, "101"} },
		{ "slmsl", {instruction_type::R4, "110"} },
		{ "slmsh", {instruction_type::R4, "111"} },
		{ "nop", {instruction_type::R3, "0000"} },
		{ "ah", {instruction_type::R3, "0001"} },
		{ "ahs", {instruction_type::R3, "0010"} },
		{ "bcw", {instruction_type::R3, "0011"} },
		{ "cgh", {instruction_type::R3, "0100"} },
		{ "clz", {instruction_type::R3, "0101"} },
		{ "max", {instruction_type::R3, "0110"} },
		{ "min", {instruction_type::R3, "0111"} },
		{ "msgn", {instruction_type::R3, "1000"} },
		{ "popcnth", {instruction_type::R3, "1001"} },
		{ "rot", {instruction_type::R3, "1010"} },
		{ "rotw", {instruction_type::R3, "1011"} },
		{ "shlhi", {instruction_type::R3, "1100"} },
		{ "sfh", {instruction_type::R3, "1101"} },
		{ "sfhs", {instruction_type::R3, "1110"} },
		{ "xor", {instruction_type::R3, "1111"} }
	};

	std::map<std::string, std::string> binary_register_hash
	{
		{ "r0", "00000" },
		{ "r1", "00001" },
		{ "r2", "00010" },
		{ "r3", "00011" },
		{ "r4", "00100" },
		{ "r5", "00101" },
		{ "r6", "00110" },
		{ "r7", "00111" },
		{ "r8", "01000" },
		{ "r9", "01001" },
		{ "r10", "01010" },
		{ "r11", "01011" },
		{ "r12", "01100" },
		{ "r13", "01101" },
		{ "r14", "01110" },
		{ "r15", "01111" },
		{ "r16", "10000" },
		{ "r17", "10001" },
		{ "r18", "10010" },
		{ "r19", "10011" },
		{ "r20", "10100" },
		{ "r21", "10101" },
		{ "r22", "10110" },
		{ "r23", "10111" },
		{ "r24", "11000" },
		{ "r25", "11001" },
		{ "r26", "11010" },
		{ "r27", "11011" },
		{ "r28", "11100" },
		{ "r29", "11101" },
		{ "r30", "11110" },
		{ "r31", "11111" }
	};

	while (!input.eof())
	{
		std::string str{};
		input >> str;

		std::pair<instruction_type, std::string> idk_what_to_name_this = instruction_hash.at(str);
		instruction_type type = idk_what_to_name_this.first;
		std::string opcode = idk_what_to_name_this.second;

		if (type == instruction_type::LI)
		{
			int index, immediate;
			std::string rd{};
			input >> rd >> index >> immediate;
			rd = binary_register_hash[rd];
			if (index < 0 || index > 7)
			{
				std::cerr << "Line " << line << ": Index out of range.\n";
				exit(RANGE_ERROR);
			}
			output << "0" << itoab(index, 3) << itoab(immediate, 16) << rd << std::endl;
		}
		else if (type == instruction_type::R4)
		{
			std::string rs1{}, rs2{}, rs3{}, rd{};
			input >> rd >> rs2 >> rs3 >> rs1;				// instruction rd rs2 rs3 rs1
			rs1 = binary_register_hash[rs1];
			rs2 = binary_register_hash[rs2];
			rs3 = binary_register_hash[rs3];
			rd = binary_register_hash[rd];
			output << "10" << opcode << rs3 << rs2 << rs1 << rd << std::endl;
		}
		else // type == instruction_type::R3
		{
			std::string rs1{}, rs2{}, rd{};
			if (str == "nop")
				rs1 = rs2 = rd = "00000";
			else
			{
				input >> rd >> rs1;				// instruction rd rs1 [rs2]
				rs1 = binary_register_hash[rs1];
				rd = binary_register_hash[rd];
				if (str == "bcw" || str == "popcnth" || str == "clz")
				{
					rs2 = "00000";
				}
				else if (str == "shlhi")
				{
					unsigned int shift_amount;
					input >> shift_amount;
					rs2 = itoab(shift_amount, 5);
				}
				else
				{
					input >> rs2;
					rs2 = binary_register_hash[rs2];
				}
			}
			output << "11" << "0000" << opcode << rs2 << rs1 << rd << std::endl;
		}

		line++;
	}
	return 0;
}

std::string itoab(int x, unsigned int n_bits)
{
	std::string s = std::bitset<64>(x).to_string();
	return s.substr(64 - n_bits, 64);
}
