# RISC_ALU

A 16-bit RISC-V-inspired Arithmetic Logic Unit (ALU) implemented in Verilog, designed for simplicity and functionality. This ALU supports a variety of arithmetic, logical, shift, and comparison operations, with additional features like parity, zero, overflow, carry, negative, and invalid opcode flags, as well as immediate operand support. The repository includes a comprehensive testbench to verify all operations.

## Table of Contents
- [What is an ALU?](#what-is-an-alu)
- [Features](#features)
- [Operations and Opcodes](#operations-and-opcodes)
- [Input and Output Bits](#input-and-output-bits)
- [Directory Structure](#directory-structure)
- [Setup and Simulation](#setup-and-simulation)
- [Testbench Details](#testbench-details)
- [Design Notes](#design-notes)
- [Contributing](#contributing)
- [License](#license)

## What is an ALU?

An **Arithmetic Logic Unit (ALU)** is a critical component of a CPU or microcontroller, responsible for performing arithmetic (e.g., addition, subtraction) and logical (e.g., AND, OR) operations on binary data. It takes input operands and an operation code (opcode) to determine the operation, producing a result and status flags (e.g., zero, carry) that indicate properties of the result. ALUs are fundamental to executing instructions in processors, enabling computations for everything from simple arithmetic to complex algorithms.

This ALU is designed with a RISC-V-inspired instruction set, focusing on a reduced instruction set computing (RISC) philosophy for simplicity and efficiency. It operates on 16-bit operands and supports a variety of operations suitable for educational purposes, prototyping, or integration into larger digital systems.

## Features

- **16-bit Operands**: Processes two 16-bit inputs (A and B) or an immediate value, producing a 16-bit result.
- **RISC-V-Inspired Opcodes**: Supports 12 operations with 4-bit opcodes, mimicking RISC-V’s clean instruction set.
- **Status Flags**:
  - **Parity**: Indicates if the result has an even number of 1s.
  - **Zero**: Set if the result is all zeros.
  - **Overflow**: Detects signed overflow for arithmetic operations.
  - **Carry**: Indicates carry-out for addition or borrow for subtraction.
  - **Negative**: Set if the result’s most significant bit (MSB) is 1.
  - **Invalid Opcode**: Flags unrecognized opcodes for debugging.
- **Immediate Operand Support**: Allows one operand to be an immediate value, reducing register access for some instructions.
- **Comprehensive Testbench**: Verifies all operations with edge cases (e.g., overflow, zero, negative results).
- **Verilog Implementation**: Portable and synthesizable for FPGA or ASIC designs.

## Operations and Opcodes

The ALU supports the following operations, each selected by a 4-bit opcode:

| Opcode | Operation | Description | Flags Affected |
|--------|-----------|-------------|---------------|
| 0000   | ADD       | Addition (A + B or A + Imm) | Zero, Parity, Overflow, Carry, Negative |
| 0001   | SUB       | Subtraction (A - B or A - Imm) | Zero, Parity, Overflow, Carry, Negative |
| 0010   | AND       | Bitwise AND (A & B or A & Imm) | Zero, Parity, Negative |
| 0011   | OR        | Bitwise OR (A \| B or A \| Imm) | Zero, Parity, Negative |
| 0100   | XOR       | Bitwise XOR (A ^ B or A ^ Imm) | Zero, Parity, Negative |
| 0101   | SLL       | Shift Left Logical (A << B[3:0] or Imm[3:0]) | Zero, Parity, Negative |
| 0110   | SRL       | Shift Right Logical (A >> B[3:0] or Imm[3:0]) | Zero, Parity, Negative |
| 0111   | SRA       | Shift Right Arithmetic (A >>> B[3:0] or Imm[3:0]) | Zero, Parity, Negative |
| 1000   | SLT       | Set Less Than (signed, 1 if A < B/Imm, else 0) | Zero, Parity, Negative |
| 1001   | SLTU      | Set Less Than Unsigned (1 if A < B/Imm, else 0) | Zero, Parity, Negative |
| 1010   | NOT       | Bitwise NOT (~A) | Zero, Parity, Negative |
| 1011   | MUL       | Multiplication (lower 16 bits of A * B or A * Imm) | Zero, Parity, Overflow, Negative |

**Notes**:
- Shift operations use only the lower 4 bits of B or Imm (0 to 15 positions) to limit shift range.
- MUL returns the lower 16 bits of the product; overflow is set if the upper 16 bits are non-zero.
- Invalid opcodes (1100–1111) set the `invalid_op` flag and produce a result of 0.

## Input and Output Bits

The ALU module (`alu.v`) has the following inputs and outputs, with each bit’s purpose clearly defined:

### Inputs
- **a [15:0]** (16 bits): First operand (A), used in all operations. For NOT, it’s the only operand.
  - Bits 15:0 represent a 16-bit value, signed or unsigned depending on the operation.
- **b [15:0]** (16 bits): Second operand (B), used when `imm_sel = 0`.
  - Bits 15:0 represent a 16-bit value; for shifts, only bits 3:0 are used.
- **imm [15:0]** (16 bits): Immediate operand, used when `imm_sel = 1`.
  - Bits 15:0 represent a constant value; for shifts, only bits 3:0 are used.
- **imm_sel** (1 bit): Selects the second operand.
  - 0: Use B as the second operand.
  - 1: Use Imm as the second operand.
- **opcode [3:0]** (4 bits): Specifies the operation to perform.
  - Bits 3:0 select one of 12 operations (0000 to 1011) or trigger `invalid_op` for 1100–1111.

### Outputs
- **result [15:0]** (16 bits): Operation result.
  - Bits 15:0 hold the 16-bit result, interpreted as signed or unsigned based on the operation.
- **parity** (1 bit): Even parity of the result.
  - 1: Result has an even number of 1s (e.g., 16’h0000, 16’h0003).
  - 0: Result has an odd number of 1s (e.g., 16’h0001).
- **zero** (1 bit): Indicates if the result is zero.
  - 1: Result is 16’h0000.
  - 0: Result is non-zero.
- **overflow** (1 bit): Detects signed overflow for ADD, SUB, and MUL.
  - 1: Overflow occurred (e.g., ADD 16’h7FFF + 16’h7FFF).
  - 0: No overflow.
- **carry** (1 bit): Carry-out for ADD or borrow for SUB.
  - 1: Carry generated (ADD) or no borrow (SUB).
  - 0: No carry (ADD) or borrow occurred (SUB).
- **negative** (1 bit): Indicates if the result is negative (signed).
  - 1: Result’s MSB (bit 15) is 1.
  - 0: Result’s MSB is 0.
- **invalid_op** (1 bit): Flags invalid opcodes.
  - 1: Opcode is 1100–1111.
  - 0: Opcode is valid (0000–1011).

## Directory Structure

```
RISC_ALU/
├── alu.v          # ALU Verilog module
├── alu_tb.v       # Testbench for ALU
├── README.md      # This file
```

- **alu.v**: Contains the ALU module with all operations and flag logic.
- **alu_tb.v**: Testbench that exercises all operations, including edge cases and immediate operand tests.

## Setup and Simulation

### Prerequisites
- A Verilog simulator (e.g., Icarus Verilog, ModelSim, Vivado).
- For Icarus Verilog, install on Linux/Mac/Windows:
  ```bash
  sudo apt-get install iverilog  # Ubuntu/Debian
  brew install icarus-verilog   # macOS
  ```
- Optional: GTKWave for waveform viewing.

### Steps
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/<your-username>/RISC_ALU.git
   cd RISC_ALU
   ```

2. **Compile and Run the Testbench**:
   Using Icarus Verilog:
   ```bash
   iverilog -o alu_sim alu.v alu_tb.v
   vvp alu_sim
   ```
   This compiles the ALU and testbench, then runs the simulation, printing results to the console.

3. **View Waveforms** (Optional):
   - Modify `alu_tb.v` to add `$dumpfile("alu.vcd");` and `$dumpvars(0, alu_tb);` in the `initial` block.
   - Re-run the simulation:
     ```bash
     iverilog -o alu_sim alu.v alu_tb.v
     vvp alu_sim
     gtkwave alu.vcd
     ```

4. **Expected Output**:
   The testbench uses `$monitor` to display:
   - Time, opcode, imm_sel, inputs (A, B, Imm), result, and all flags.
   Example:
   ```
   Time=0 opcode=0000 imm_sel=0 a=1234 b=5678 imm=0000 result=68ac parity=1 zero=0 overflow=0 carry=0 negative=0 invalid_op=0
   ```

## Testbench Details

The testbench (`alu_tb.v`) verifies all ALU operations with a variety of test cases:
- **Arithmetic**: ADD, SUB, MUL with normal cases, overflow, and zero results.
- **Logical**: AND, OR, XOR, NOT with various bit patterns.
- **Shifts**: SLL, SRL, SRA with different shift amounts and sign preservation.
- **Comparisons**: SLT, SLTU with signed and unsigned inputs.
- **Immediate Mode**: Tests ADD, SUB, MUL with `imm_sel = 1`.
- **Invalid Opcodes**: Verifies `invalid_op` flag for opcode 4’b1111.
- **Edge Cases**: Includes maximum values (16’h7FFF, 16’hFFFF), negative numbers (16’h8000), and zero.

The testbench uses `$monitor` to log results, making it easy to verify correctness. To extend testing, modify the `initial` block in `alu_tb.v` with additional test cases.

## Design Notes

- **RISC-V Inspiration**: The opcode structure and operations (e.g., SLL, SRA, SLT) are inspired by RISC-V, a modern open-source ISA, ensuring a clean and extensible design.
- **Flag Logic**:
  - Overflow is computed for ADD/SUB using two’s complement rules and for MUL by checking upper product bits.
  - Parity is calculated by XORing all result bits.
  - Negative flag simplifies signed result checks.
- **Immediate Support**: Enhances flexibility by allowing constant operands, mimicking RISC-V’s immediate instructions.
- **Scalability**: The 4-bit opcode leaves room (1100–1111) for future operations like NOR or division.
- **Limitations**:
  - Multiplication returns only the lower 16 bits; upper bits are discarded (except for overflow detection).
  - Shifts are limited to 0–15 positions to keep logic simple.

## Contributing

Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a branch: `git checkout -b feature-name`.
3. Make changes (e.g., add new operations, optimize code, enhance testbench).
4. Test thoroughly with the testbench.
5. Submit a pull request with a clear description of changes.

Please ensure code follows Verilog best practices and includes comments for clarity.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

*Built with ❤️ for learning and experimentation. Happy coding!*