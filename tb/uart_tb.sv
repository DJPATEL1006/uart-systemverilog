`timescale 1ns/1ps

module uart_tb #(parameter int unsigned BITS_NUM = 8);

//testbench signals
logic clk;
logic rst;
logic tx_start;
logic [BITS_NUM - 1:0]tx_data;
logic tx;
logic tx_busy;

// make task send_byte to send data to tx_data

task automatic send_byte(input logic [BITS_NUM-1:0]data);

    tx_data = data;
    @(posedge clk);
    tx_start = 1'b0;
    @(posedge clk);
    tx_start = 1'b1;
    @(negedge tx_busy);

endtask

//device under test
uart_tx #(.BITS_NUM(BITS_NUM)) dut (.clk(clk),.rst(rst),.tx_start(tx_start),.tx_data(tx_data),.tx(tx),.tx_busy(tx_busy));

//clk generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
// create dumpfile graph verification using gtkwave

initial begin
    $dumpfile("uart_tx.vcd");
    $dumpvars(0,uart_tb);
end

initial begin
    rst = 1'b1;

    repeat (2)
        @(posedge clk);

    rst = 1'b0;
end
initial begin

    tx_start = 1'b1;
    tx_data  = '0;

    wait(!rst);

    send_byte(8'hFF);
    send_byte(8'h3C);
    send_byte(8'hF0);
    send_byte(8'hAD);
    send_byte(8'h9F);
    

    $finish;

end

endmodule