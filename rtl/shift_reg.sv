module shift_reg #(parameter int unsigned WIDTH = 8)(
    input logic clk,
    input logic rst,
    input logic load,
    input logic shift_en,
    input logic [WIDTH - 1 :0] parallel_data,
    output logic serial_out
);
logic [WIDTH-1:0] store_data; // temporary storage of a data

always_ff @ (posedge clk or posedge rst)begin
    if (rst)begin
        store_data <= '0;
    end
    else if (load)begin
        store_data <= parallel_data;
    end
    else if (shift_en)begin
        store_data <= {1'b0,store_data[WIDTH-1:1]};
    end
end

assign serial_out = store_data[0];

endmodule