// Testbench for enhanced 16-bit ALU
module alu_tb;
    reg [15:0] a, b, imm;
    reg imm_sel;
    reg [3:0] opcode;
    wire [15:0] result;
    wire parity, zero, overflow, carry, negative, invalid_op;

    // Instantiate ALU
    alu uut (
        .a(a),
        .b(b),
        .imm(imm),
        .imm_sel(imm_sel),
        .opcode(opcode),
        .result(result),
        .parity(parity),
        .zero(zero),
        .overflow(overflow),
        .carry(carry),
        .negative(negative),
        .invalid_op(invalid_op)
    );

    initial begin
        // Monitor output
        $monitor("Time=%0t opcode=%b imm_sel=%b a=%h b=%h imm=%h result=%h parity=%b zero=%b overflow=%b carry=%b negative=%b invalid_op=%b",
                 $time, opcode, imm_sel, a, b, imm, result, parity, zero, overflow, carry, negative, invalid_op);

        // Initialize
        imm_sel = 0;
        imm = 16'h0000;

        // Test ADD
        opcode = 4'b0000;
        a = 16'h1234; b = 16'h5678; #10;
        a = 16'h7FFF; b = 16'h7FFF; #10;  // Overflow
        imm_sel = 1; a = 16'h1234; imm = 16'h5678; #10;  // Immediate

        // Test SUB
        opcode = 4'b0001;
        imm_sel = 0;
        a = 16'h5678; b = 16'h1234; #10;
        a = 16'h8000; b = 16'h7FFF; #10;  // Negative result
        imm_sel = 1; a = 16'h5678; imm = 16'h1234; #10;

        // Test AND
        opcode = 4'b0010;
        imm_sel = 0;
        a = 16'hFF00; b = 16'h0F0F; #10;

        // Test OR
        opcode = 4'b0011;
        a = 16'hFF00; b = 16'h0F0F; #10;

        // Test XOR
        opcode = 4'b0100;
        a = 16'hFF00; b = 16'h0F0F; #10;

        // Test SLL
        opcode = 4'b0101;
        a = 16'h0001; b = 16'h0004; #10;

        // Test SRL
        opcode = 4'b0110;
        a = 16'h8000; b = 16'h0004; #10;

        // Test SRA
        opcode = 4'b0111;
        a = 16'h8000; b = 16'h0004; #10;  // Negative, check sign

        // Test SLT
        opcode = 4'b1000;
        a = 16'h8000; b = 16'h7FFF; #10;

        // Test SLTU
        opcode = 4'b1001;
        a = 16'h8000; b = 16'h7FFF; #10;

        // Test NOT
        opcode = 4'b1010;
        a = 16'hFFFF; b = 16'h0000; #10;  // Expect 16’h0000
        a = 16'h5555; #10;

        // Test MUL
        opcode = 4'b1011;
        a = 16'h0002; b = 16'h0003; #10;  // 6
        a = 16'hFFFF; b = 16'h0001; #10;  // 0xFFFF
        a = 16'h1000; b = 16'h1000; #10;  // Overflow
        imm_sel = 1; a = 16'h0002; imm = 16'h0003; #10;

        // Test invalid opcode
        opcode = 4'b1111;
        imm_sel = 0;
        a = 16'h1234; b = 16'h5678; #10;

        $finish;
    end
endmodule
