module baud_gen #(parameter int unsigned BAUD_DIV = 10)(
    input logic clk,
    input logic rst,
    output logic baud_tick
);

// this module is for generating baud tick 

logic [$clog2(BAUD_DIV)-1:0] count;

always_ff @(posedge clk or posedge rst)begin
    if (rst)begin 
        count <= 0;
    end
    else if (count == BAUD_DIV - 1) begin
        count <= 'b0 ; 
    end
    else begin
        count <= count + 1;
    end
end

assign baud_tick = (count == BAUD_DIV - 1);

endmodule