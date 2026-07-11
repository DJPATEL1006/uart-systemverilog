module bit_counter #(parameter int unsigned BITS_NUM = 8)(
    input logic clk,
    input logic rst,
    input logic enable,
    input logic clear,
    output logic done,
    output logic [$clog2(BITS_NUM)-1:0]count
); 

initial begin
    assert (BITS_NUM >= 2)
        else $error("BITS_NUM must be >= 2"); //BITS_NUM should be greater than or equal to 2
end 

always_ff @ (posedge clk or posedge rst)begin
    if (rst)begin
        count <= '0;
    end
    

    else if (clear)begin
        count <= '0;
    end

    else if (enable )begin
        if (count != BITS_NUM - 1)
            count <= count + 1; 
    end

end
assign done = (count == BITS_NUM - 1);
endmodule