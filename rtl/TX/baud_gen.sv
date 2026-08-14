/******************************************************************************
 * File        : baud_gen.sv
 * Author      : Divyam Patel and Foram Patel
 * Date        : 08-07-2026
 *
 * Description :
 * Generates a periodic baud_tick pulse from the system clock, one clock
 * cycle wide, once every BAUD_DIV clock cycles. Used by uart_tx to time
 * each bit period of the transmitted frame.
 *
 * The counter is held at zero whenever `clear` is asserted, so the TX FSM
 * can force the counter to restart exactly when a new frame begins
 * (leaving IDLE). This guarantees every bit, including the START bit,
 * is a full BAUD_DIV cycles wide.
 *
 * Parameters :
 *  - BAUD_DIV : Number of clock cycles per baud period
 *
 * Ports :
 *  - clear : Synchronous clear; holds count at 0 while asserted
 *
 ******************************************************************************/

module baud_gen #(parameter int unsigned BAUD_DIV = 10)(
    input logic clk,
    input logic rst,
    input logic clear,
    output logic baud_tick
);

// this module is for generating baud tick 

logic [$clog2(BAUD_DIV)-1:0] count;

always_ff @(posedge clk or posedge rst)begin
    if (rst || clear)begin 
        count <= 0;
    end
    else if (count == BAUD_DIV - 1) begin
        count <= 'b0 ; 
    end
    else begin
        count <= count + 1;
    end
end

assign baud_tick = (count == BAUD_DIV - 1) && !clear;

endmodule