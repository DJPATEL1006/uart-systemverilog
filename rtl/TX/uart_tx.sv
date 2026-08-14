/******************************************************************************
 * File        : uart_tx.sv
 * Author      : Divyam Patel and Foram Patel
 * Date        : 08-07-2026
 *
 * Description :
 * Parameterized UART Transmitter written in SystemVerilog.
 * Supports configurable data width, baud rate divider,
 * and even/odd parity.
 *
 * Features :
 *  - Parameterized data width
 *  - Configurable baud rate
 *  - Even/Odd parity support
 *  - Modular architecture
 *
 * Parameters :
 *  - BITS_NUM   : Number of data bits
 *  - BAUD_DIV   : Clock cycles per baud
 *  - ODD_PARITY : 0 = Even parity
 *                 1 = Odd parity
 *
 * Dependencies :
 *  - baud_gen.sv
 *  - bit_counter.sv
 *  - shift_reg.sv
 *  - parity_gen.sv
 *  - uart_fsm.sv
 *
 ******************************************************************************/


module uart_tx #(parameter int unsigned  BITS_NUM  = 8,parameter int unsigned BAUD_DIV = 10,parameter bit ODD_PARITY = 1'b0)(
    input logic clk,
    input logic rst,
    input logic tx_start,
    input logic [BITS_NUM - 1:0] tx_data,
    output logic tx_busy,
    output logic tx 
);
//internal connection
logic bit_done;
logic baud_tick;
logic load;
logic shift_en;
logic count_en;
logic count_clear;
logic parity_bit;
logic serial_bit;
logic baud_clear;
logic [$clog2(BITS_NUM)-1:0]count; //I had added count for just verification purpose 

// instantiate each module to top/tx module
baud_gen #(.BAUD_DIV(BAUD_DIV)) u_baud (.clk(clk),.rst(rst),.baud_tick(baud_tick),.clear(baud_clear));
bit_counter #(.BITS_NUM(BITS_NUM)) u_counter (.clk(clk),.rst(rst),.enable(count_en),.clear(count_clear),.done(bit_done),.count(count));
shift_reg #(.WIDTH(BITS_NUM))u_reg (.clk(clk),.rst(rst),.load(load),.shift_en(shift_en),.parallel_data(tx_data),.serial_out(serial_bit));
parity_gen #(.BITS_NUM(BITS_NUM),.ODD_PARITY(ODD_PARITY)) u_parity (.data(tx_data),.parity_bit(parity_bit));
uart_fsm u_fsm(.clk(clk),.rst(rst),.baud_tick(baud_tick),.tx_start(tx_start),.bit_done(bit_done),.parity_bit(parity_bit),.serial_out(serial_bit),.tx(tx),.tx_busy(tx_busy),.load(load),.shift_en(shift_en),.count_en(count_en),.count_clear(count_clear),.baud_clear(baud_clear));

endmodule