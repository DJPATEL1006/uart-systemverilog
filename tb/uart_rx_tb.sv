`timescale 1ns/1ps

module uart_rx_tb;

parameter int unsigned BITS_NUM   = 8;
parameter int unsigned BAUD_DIV   = 10;
parameter int unsigned CLK_PERIOD = 10;

localparam BAUD_PERIOD = BAUD_DIV * CLK_PERIOD;

//--------------------------------------------------
// Testbench Signals
//--------------------------------------------------
logic clk;
logic rst;
logic rx;

logic [BITS_NUM-1:0] rx_data;
logic rx_valid;
logic rx_busy;

//--------------------------------------------------
// DUT
//--------------------------------------------------
uart_rx #(
    .BITS_NUM(BITS_NUM),
    .BAUD_DIV(BAUD_DIV)
) DUT (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .rx_busy(rx_busy)
);

//--------------------------------------------------
// Clock Generation
//--------------------------------------------------
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

//--------------------------------------------------
// Dump File
//--------------------------------------------------
initial begin
    $dumpfile("uart_rx.vcd");
    $dumpvars(0, uart_rx_tb);
end

//--------------------------------------------------
// UART Frame Task
//--------------------------------------------------
task automatic send_frame(
    input logic [BITS_NUM-1:0] data,
    input logic parity_bit,
    input logic stop_bit
);

integer i;

begin

    //---------------- Idle ----------------
    rx = 1'b1;
    #(BAUD_PERIOD);

    //---------------- Start ----------------
    rx = 1'b0;
    #(BAUD_PERIOD);

    //---------------- Data -----------------
    for(i=0;i<BITS_NUM;i=i+1) begin
        rx = data[i];          // LSB First
        #(BAUD_PERIOD);
    end

    //---------------- Parity ---------------
    rx = parity_bit;
    #(BAUD_PERIOD);

    //---------------- Stop -----------------
    rx = stop_bit;
    #(BAUD_PERIOD);

    //---------------- Idle -----------------
    rx = 1'b1;
    #(BAUD_PERIOD);

end
endtask



//--------------------------------------------------
// Test Sequence
//--------------------------------------------------
initial begin

    rx  = 1'b1;
    rst = 1'b1;

    repeat(2)
        @(posedge clk);

    rst = 1'b0;

    //------------------------------------------------
    // Test 1
    //------------------------------------------------
    send_frame(8'hA5, ^8'hA5, 1'b1);
    

    //------------------------------------------------
    // Test 2
    //------------------------------------------------
    send_frame(8'h3C, ^8'h3C, 1'b1);
    

    //------------------------------------------------
    // Test 3
    //------------------------------------------------
    send_frame(8'hFF, ^8'hFF, 1'b1);
    

    //------------------------------------------------
    // Test 4
    //------------------------------------------------
    send_frame(8'h00, ^8'h00, 1'b1);
    

    //------------------------------------------------
    // Test 5
    //------------------------------------------------
    send_frame(8'h55, ^8'h55, 1'b1);
    

    //------------------------------------------------
    // Test 6
    //------------------------------------------------
    send_frame(8'hAA, ^8'hAA, 1'b1);
    

    //------------------------------------------------
    // Wrong Parity Test
    //------------------------------------------------
    $display("\n----- Wrong Parity Test -----");

    send_frame(8'h5A, ~(^8'h5A), 1'b1);

    repeat(20) @(posedge clk);

    if(!rx_valid)
        $display("[%0t] PASS : Wrong parity rejected", $time);
    else
        $display("[%0t] FAIL : Wrong parity accepted", $time);

    //------------------------------------------------
    // Wrong Stop Bit Test
    //------------------------------------------------
    $display("\n----- Wrong Stop Bit Test -----");

    send_frame(8'hA5, ^8'hA5, 1'b0);

    repeat(20) @(posedge clk);

    if(!rx_valid)
        $display("[%0t] PASS : Wrong stop bit rejected", $time);
    else
        $display("[%0t] FAIL : Wrong stop bit accepted", $time);

    $display("\n========== Simulation Finished ==========\n");

    $finish;

end

endmodule