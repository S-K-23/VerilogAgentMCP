`timescale 1ns/1ps

module tb_counter;
    // Inputs we drive are regs; the output we watch is a wire.
    reg        clk = 0;
    reg        rst, en;
    wire [3:0] count;

    // Device under test
    counter dut (.clk(clk), .rst(rst), .en(en), .count(count));

    // Clock: flips every 5 ns, forever, in the background (10 ns period).
    always #5 clk = ~clk;

    integer   i;
    integer   errors = 0;
    integer   seed   = 1;        // change this to try a different random sequence
    reg [3:0] expected;          // our reference model of what count should be

    initial begin
        // ---- 1. Reset ----
        rst = 1;
        en  = 0;
        @(negedge clk);
        expected = 0;

        // ---- 2. Run 300 cycles with random inputs ----
        for (i = 0; i < 300; i = i + 1) begin
            // Choose this cycle's inputs on the falling edge.
            rst = (($random(seed) % 30) == 0);   // reset about 1 cycle in 30
            en  = (($random(seed) % 4) != 0);    // enable about 3 cycles in 4

            // The counter updates on the rising edge...
            @(posedge clk);

            // ...so update our model with the same four rules.
            if (rst)
                expected = 0;
            else if (en && expected == 9)
                expected = 0;
            else if (en)
                expected = expected + 1;
            // otherwise: hold, expected stays the same

            // Check halfway through the cycle, after the counter has settled.
            @(negedge clk);
            if (count !== expected) begin
                $display("FAIL: cycle %0d rst=%b en=%b -> count=%0d, expected %0d",
                         i, rst, en, count, expected);
                errors = errors + 1;
            end
        end

        // ---- 3. Report ----
        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d error(s)", errors);
        $finish;
    end
endmodule