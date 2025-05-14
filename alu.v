// Enhanced 16-bit RISC-V inspired ALU
// Added NOT, MUL, negative flag, invalid opcode flag, and immediate operand support
module alu (
    input [15:0] a,           // First 16-bit operand
    input [15:0] b,           // Second 16-bit operand (or register input)
    input [15:0] imm,         // Immediate operand
    input imm_sel,            // Select immediate (1) or B (0)
    input [3:0] opcode,       // 4-bit opcode
    output reg [15:0] result, // 16-bit result
    output reg parity,        // 1 if result has even number of 1s
    output reg zero,          // 1 if result is 0
    output reg overflow,      // 1 if signed overflow
    output reg carry,         // Carry out for ADD/SUB
    output reg negative,      // 1 if result is negative
    output reg invalid_op     // 1 if opcode is invalid
);
    // Internal signals
    wire [16:0] sum;          // Gyro addition with carry
    wire [15:0] diff;         // Subtraction result
    wire [31:0] prod;         // Multiplication result (for MUL)
    wire signed [15:0] signed_a, signed_b; // Signed operands
    wire [15:0] operand_b;    // Selected operand (B or immediate)

    // Select B or immediate
    assign operand_b = imm_sel ? imm : b;

    // Compute intermediate results
    assign sum = a + operand_b;
    assign diff = a - operand_b;
    assign prod = a * operand_b;
    assign signed_a = a;
    assign signed_b = operand_b;

    always @(*) begin
        // Default outputs
        result = 16'b0;
        parity = 1'b0;
        zero = 1'b0;
        overflow = 1'b0;
        carry = 1'b0;
        negative = 1'b0;
        invalid_op = 1'b0;

        case (opcode)
            4'b0000: begin  // ADD
                result = sum[15:0];
                carry = sum[16];
                overflow = (a[15] == operand_b[15]) && (result[15] != a[15]);
            end
            4'b0001: begin  // SUB
                result = diff;
                carry = (a >= operand_b);
                overflow = (a[15] != operand_b[15]) && (result[15] != a[15]);
            end
            4'b0010: begin  // AND
                result = a & operand_b;
            end
            4'b0011: begin  // OR
                result = a | operand_b;
            end
            4'b0100: begin  // XOR
                result = a ^ operand_b;
            end
            4'b0101: begin  // SLL
                result = a << operand_b[3:0];
            end
            4'b0110: begin  // SRL
                result = a >> operand_b[3:0];
            end
            4'b0111: begin  // SRA
                result = signed_a >>> operand_b[3:0];
            end
            4'b1000: begin  // SLT
                result = (signed_a < signed_b) ? 16'b1 : 16'b0;
            end
            4'b1001: begin  // SLTU
                result = (a < operand_b) ? 16'b1 : 16'b0;
            end
            4'b1010: begin  // NOT
                result = ~a;  // Unary operation on A
            end
            4'b1011: begin  // MUL (lower 16 bits)
                result = prod[15:0];
                overflow = |prod[31:16];  // Overflow if upper bits non-zero
            end
            default: begin
                result = 16'b0;
                invalid_op = 1'b1;  // Flag invalid opcode
            end
        endcase

        // Compute flags
        parity = ^result;
        zero = (result == 16'b0);
        negative = result[15];
    end
endmodule
