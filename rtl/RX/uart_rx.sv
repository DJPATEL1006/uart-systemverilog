/******************************************************************************
 * File        : uart_rx.sv
 * Author      : Divyam Patel and Foram Patel
 * Date        : 08-07-2026
 *
 * Description :
 * Parameterized UART Receiver written in SystemVerilog.
 * Supports configurable data width, baud rate divider,
 * and even/odd parity, matching uart_tx's frame format.
 *
 * Features :
 *  - Parameterized data width
 *  - Configurable baud rate
 *  - Even/Odd parity checking
 *  - Center-of-bit sampling for robust start-bit detection
 *  - Modular architecture
 *
 * Parameters :
 *  - BITS_NUM   : Number of data bits
 *  - BAUD_DIV   : Clock cycles per baud
 *  - ODD_PARITY : 0 = Even parity
 *                 1 = Odd parity
 *
 * Dependencies :
 *  - rx_baud_counter.sv
 *  - bit_counter.sv
 *  - rx_shift_reg.sv
 *  - parity_gen.sv
 *  - rx_fsm.sv
 *
 ******************************************************************************/

module uart_rx #(
    parameter int unsigned BITS_NUM   = 8,
    parameter int unsigned BAUD_DIV   = 10,
    parameter bit ODD_PARITY          = 1'b0
)(
    input  logic clk,
    input  logic rst,
    input  logic rx,

    output logic [BITS_NUM-1:0] rx_data,
    output logic rx_valid,
    output logic rx_busy
);
// -----------------------------
// internal signals
// -----------------------------
logic baud_tick;
logic baud_enable;
logic baud_clear;   
logic shift_en;
logic count_en;
logic count_clear;
logic bit_done;
logic [$clog2(BITS_NUM)-1:0] count;
logic expected_parity;
logic parity_error;
logic parity_check;
//----------------------------------------
//instantiate each module to top/tx module
//----------------------------------------
rx_baud_counter #(.BAUD_DIV(BAUD_DIV)) u_rx_baud_counter (.clk(clk),.rst(rst),.enable(baud_enable),.count_clear(baud_clear),.baud_tick(baud_tick));
bit_counter #(.BITS_NUM(BITS_NUM)) u_bit_counter (.clk(clk),.rst(rst),.enable(count_en),.clear(count_clear),.done(bit_done),.count(count));
parity_gen #(.ODD_PARITY(ODD_PARITY),.BITS_NUM(BITS_NUM)) u_parity_gen (.data(rx_data),.parity_bit(expected_parity));
rx_fsm u_rx_fsm (.clk(clk),.rst(rst),.rx(rx),.parity_check(parity_check),.baud_tick(baud_tick),.bit_done(bit_done),.parity_error(parity_error),.baud_enable(baud_enable),.baud_clear(baud_clear),.shift_en(shift_en),.count_en(count_en),.count_clear(count_clear),.rx_valid(rx_valid),.rx_busy(rx_busy));
rx_shift_reg #(.WIDTH(BITS_NUM)) u_rx_shift_reg (.clk(clk),.rst(rst),.serial_in(rx),.clear(count_clear),.shift_en(shift_en),.parallel_out(rx_data));

// parity comparator
always_ff @(posedge clk or posedge rst)begin
  if(rst)
    parity_error <= 1'b0;
  else if(parity_check)
    parity_error <= (expected_parity != rx);
end

endmodule
