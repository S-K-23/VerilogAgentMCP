module counter (input clk, rst, en, output reg [3:0] count);
    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
        end
        else begin
            if (en) begin
                if (count == 9) begin
                    count <= 0;
                end
                else begin
                    count <= count + 1;
                end
            end
        end
        
    end
endmodule