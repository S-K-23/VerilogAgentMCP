`timescale 1ns/1ps

module tb_mux;
    // Inputs we drive are regs; the output we watch is a wire.
    reg  a, b, sel;
    wire out;

    // Device under test
    mux dut (.a(a), .b(b), .sel(sel), .out(out));

    integer i;
    integer errors = 0;
    reg expected;

    initial begin
        // Only 3 inputs, so test all 8 combinations.
        for (i = 0; i < 8; i = i + 1) begin
            {sel, b, a} = i[2:0];          // unpack the loop counter into the inputs
            #1;                            // let the combinational logic settle

            expected = sel ? b : a;        // what a correct mux should output
            if (out !== expected) begin    // !== also catches X and Z
                $display("FAIL: sel=%b a=%b b=%b -> out=%b, expected %b", sel, a, b, out, expected);
                errors = errors + 1;
            end
        end

        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d error(s)", errors);
        $finish;
    end
endmodule