`timescale 1ns/1ps
module rx_buad_counter_tb;

logic clk;
logic rst;
logic enable;
logic count_clear;
logic baud_tick;

rx_baud_counter #(
    .BAUD_DIV(10)
) dut (
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .count_clear(count_clear),
    .baud_tick(baud_tick)
);

initial begin
    clk = 0;
    forever begin
        #5 clk = ~clk;
    end
end

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,rx_buad_tb);

end

initial begin
    rst = 0;
    enable = 0;
    count_clear = 0;
    @(posedge clk);
     rst = 1;
    @(posedge clk);
    rst = 0;
    @(posedge clk);
    enable = 1;
    #100 ;
    count_clear = 1;
    @(posedge clk);
    count_clear = 0;
    #50;
    $finish;
end



endmodule