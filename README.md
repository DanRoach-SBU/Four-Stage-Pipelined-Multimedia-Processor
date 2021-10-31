# Four-Stage-Pipelined-Multimedia-Processor
ESE 345 Computer Architecture Final Project

This project is still in progress, but nearing completion. All required components of the processor are implemented, including the program counter, instruction buffer, register file, data forwarding control unit and multiplexers, ALU, and pipeline registers. Components are connected in the CPU.vhd file.

To do:
- Add synchronous clear signals to all synchronous components
- Write an assembler in C++
- Clarify behavior of the load immediate instruction (i.e. does it use an existing value from the register file, or are all other bits cleared?)
