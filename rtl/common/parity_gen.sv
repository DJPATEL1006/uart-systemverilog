/******************************************************************************
 * File        : parity_gen.sv
 * Author      : Divyam Patel and Foram Patel
 * Date        : 08-07-2026
 *
 * Description :
 * Combinational even/odd parity generator shared by both uart_tx and
 * uart_rx. On TX, generates the parity bit for the outgoing frame; on RX,
 * generates the expected parity from the received data so it can be
 * compared against the received parity bit.
 *
 * Parameters :
 *  - ODD_PARITY : 0 = Even parity, 1 = Odd parity
 *  - BITS_NUM   : Number of data bits
 *
 ******************************************************************************/

module parity_gen #(
    parameter bit ODD_PARITY = 0, // EVEN PARITY = 0 and ODD PARITY = 1
    parameter int unsigned BITS_NUM = 8 //number of bit 
    )(
        input logic [BITS_NUM-1:0]data,
        output logic parity_bit
    );

assign parity_bit = ODD_PARITY ? ~(^data) : ^data ;

endmodule