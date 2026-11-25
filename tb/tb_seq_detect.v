`timescale 1ns/1ps

module tb_seq_detect;
    reg  clk = 0;
    reg  rst, din;
    wire found;

    // Device under test
    seq_detect dut (.clk(clk), .rst(rst), .din(din), .found(found));

    // Clock: 10 ns period
    always #5 clk = ~clk;

    integer   i;
    integer   errors = 0;
    integer   seed   = 1;
    reg [3:0] history;          // reference model: the last 4 bits received

    initial begin
        // ---- 1. Reset ----
        rst = 1;
        din = 0;
        @(negedge clk);
        history = 0;

        // ---- 2. Run 2000 cycles ----
        for (i = 0; i < 2000; i = i + 1) begin
            // First 7 cycles: the overlap example 1 0 1 1 0 1 1. Then random bits.
            if (i < 7) begin
                din = (7'b1011011 >> (6 - i)) & 1;
                rst = 0;
            end
            else begin
                din = (($random(seed) % 3) != 0);     // about 2/3 ones
                rst = (($random(seed) % 100) == 0);   // reset about 1 cycle in 100
            end

            // The FSM updates on the rising edge; update our history the same way.
            @(posedge clk);
            if (rst) history = 0;
            else     history = {history[2:0], din};   // shift in the new bit

            // Check on the falling edge: found should be 1 exactly when we've just seen 1011.
            @(negedge clk);
            if (found !== (history == 4'b1011)) begin
                $display("FAIL: cycle %0d last bits=%b -> found=%b", i, history, found);
                errors = errors + 1;
            end
        end

        // ---- 3. Report ----
        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d error(s)", errors);
        $finish;
    end
endmodule