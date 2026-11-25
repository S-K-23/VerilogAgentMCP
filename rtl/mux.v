module mux(input a, b, sel, output reg out);
    always @(*) begin
        if (sel) begin
            out = b;
        end
        else begin
            out = a;
        end
    end

endmodule
