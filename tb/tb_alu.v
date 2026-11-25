`timescale 1ns/1ps

module tb_alu;
    // Inputs we drive are regs; outputs we watch are wires.
    reg  [7:0] a, b;
    reg  [2:0] op;
    wire [7:0] y;
    wire       zero;

    // Device under test
    alu dut (.a(a), .b(b), .op(op), .y(y), .zero(zero));

    integer   i;
    integer   errors = 0;
    integer   seed   = 1;      // change this to try a different random sequence
    reg [7:0] expected;        // 8 bits, so it wraps around exactly like y does

    // Apply one set of inputs, compute the expected answer, and compare.
    task check(input [7:0] ta, input [7:0] tb, input [2:0] top);
        begin
            a = ta; b = tb; op = top;
            #1;                                 // let the combinational logic settle

            // Reference model: the same operations, written independently.
            case (op)
                3'd0: expected = a + b;
                3'd1: expected = a - b;
                3'd2: expected = a & b;
                3'd3: expected = a | b;
                3'd4: expected = a ^ b;
                3'd5: expected = (a < b) ? 8'd1 : 8'd0;
                3'd6: expected = a << b[2:0];
                default: expected = 8'd0;
            endcase

            if (y !== expected || zero !== (expected == 0)) begin
                $display("FAIL: op=%0d a=%0d b=%0d -> y=%0d zero=%b, expected y=%0d zero=%b",
                         op, a, b, y, zero, expected, (expected == 0));
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // ---- 1. Corner cases, written by hand ----
        check(8'd255, 8'd1,   3'd0);   // add overflow: wraps to 0, zero should be 1
        check(8'd200, 8'd100, 3'd0);   // add overflow: 300 wraps to 44
        check(8'd0,   8'd1,   3'd1);   // subtract underflow: wraps to 255
        check(8'd42,  8'd42,  3'd1);   // a == b: subtract gives 0
        check(8'd42,  8'd42,  3'd5);   // a == b: not less-than, so 0
        check(8'd1,   8'd2,   3'd5);   // less-than true
        check(8'd200, 8'd100, 3'd5);   // unsigned: 200 is NOT less than 100
        check(8'hFF,  8'h0F,  3'd2);   // AND
        check(8'hF0,  8'h0F,  3'd3);   // OR
        check(8'hFF,  8'hFF,  3'd4);   // XOR of equal values gives 0
        check(8'd1,   8'd0,   3'd6);   // shift by 0: unchanged
        check(8'd1,   8'd7,   3'd6);   // shift by 7: 128
        check(8'd1,   8'd9,   3'd6);   // only b[2:0] counts: 9 acts like 1, so 2
        check(8'd123, 8'd45,  3'd7);   // unused opcode gives 0

        // ---- 2. Random tests ----
        for (i = 0; i < 2000; i = i + 1) begin
            a  = $random(seed);
            b  = $random(seed);
            op = $random(seed);
            if (($random(seed) % 8) == 0) b = a;   // sometimes force a == b
            check(a, b, op);
        end

        // ---- 3. Report ----
        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d error(s)", errors);
        $finish;
    end
endmodule