module alu (input [7:0] a, b, input [2:0] op, output reg [7:0] y, output zero);

    always @(*) begin
        case (op)
            3'b000: y = a + b;
            3'b001: y = a - b;
            3'b010: y = a & b;
            3'b011: y = a | b;
            3'b100: y = a ^ b;
            3'b101: y = (a < b) ? 1 : 0;
            3'b110: y = a << b[2:0];
            3'b111: y = 0;
        default: y = 0;
        endcase

    end

    assign zero = (y==0) ? 1 : 0;
    
endmodule