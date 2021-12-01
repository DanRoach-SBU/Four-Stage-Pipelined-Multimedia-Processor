# Four-Stage-Pipelined-Multimedia-Processor
ESE 345 Computer Architecture Final Project

The goal of this project is to design a pipelined microprocessor that implements a small set of instructions similar to those in the Sony Cell SPU and Intel SSE architectures.

The pipelined microprocessor was implemented in VHDL as a structural model of subcomponents, found in Components/CPU.vhd. Each sub-component is implemented as a behavioral architecture, all of which can also be found in the Components folder. Each component has an associated testbench, all of which can be found in the Testbenches folder.

We were to implement a simple assembler to generate the machine code (represented as an ASCII text file to be read by the VHDL testbench). This can be found in the root folder as Assembler.cpp.
