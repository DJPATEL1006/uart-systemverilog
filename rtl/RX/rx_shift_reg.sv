/******************************************************************************
 * File        : rx_shift_reg.sv
 * Author      : Divyam Patel and Foram Patel
 * Date        : 08-07-2026
 *
 * Description :
 * Serial-in, parallel-out shift register used by uart_rx to deserialize
 * the incoming data bits, LSB first, into rx_data. Shifts one bit in per
 * `shift_en` pulse (driven at the center of each data bit by the RX baud
 * tick). `clear` resets the register at the start of each new frame.
 *
 * Parameters :
 *  - WIDTH : Register width in bits
 *
 ******************************************************************************/

module rx_shift_reg #(parameter int unsigned WIDTH = 8)(
    input logic clk,
    input logic rst,
    input logic serial_in,
    input logic clear,
    input logic shift_en,
    output logic [WIDTH-1:0] parallel_out
);

always_ff @(posedge clk or posedge rst)begin
    if (rst || clear) begin
        parallel_out <= 'b0;
    end
    else if (shift_en)begin
        parallel_out <= {serial_in,parallel_out[WIDTH - 1:1]};
    end
end

endmodule