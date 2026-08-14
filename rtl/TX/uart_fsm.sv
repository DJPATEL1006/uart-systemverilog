/******************************************************************************
 * File        : uart_fsm.sv
 * Author      : Divyam Patel and Foram Patel
 * Date        : 08-07-2026
 *
 * Description :
 * Finite state machine controller for the UART transmitter. Sequences the
 * frame through IDLE -> START -> DATA -> PARITY -> STOP -> IDLE, driving
 * the shift register, bit counter, and baud counter, and generating the
 * serial tx output and tx_busy status flag.
 *
 * tx_start is sampled active-low: pulsing tx_start to 0 for one clock
 * cycle while in IDLE begins a new frame.
 *
 * States :
 *  - IDLE   : Line held high, waiting for tx_start
 *  - START  : Drives tx low for one full baud period (start bit)
 *  - DATA   : Shifts out data bits, LSB first, one per baud tick
 *  - PARITY : Drives the computed parity bit for one baud period
 *  - STOP   : Drives tx high for one baud period (stop bit)
 *
 ******************************************************************************/

module uart_fsm(
    // input ports
    input logic clk,
    input logic rst,
    input logic baud_tick,
    input logic tx_start,
    input logic bit_done,
    input logic serial_out,
    input logic parity_bit,
    //output ports
    output logic tx,
    output logic tx_busy,
    output logic load,
    output logic shift_en,
    output logic count_en,
    output logic count_clear,
    output logic baud_clear
);
// states of a finite satet machine for UART 
typedef enum logic[2:0] { 
        IDLE,
        START,
        DATA,
        PARITY,
        STOP
 } states_t;

states_t current_state,next_state;

always_ff @(posedge clk or posedge rst) begin
    if (rst)begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end  
end

//state transition
always_comb begin
    next_state = current_state;

    case(current_state)
        IDLE: begin 
            if(~tx_start)
                next_state = START;
        end
        START: begin
            if(baud_tick)
                next_state = DATA;
        end
        DATA: begin
            if (bit_done && baud_tick)
                next_state = PARITY;  
        end
        PARITY: begin
            if(baud_tick)
                next_state = STOP;
        end
        STOP: begin
            if(baud_tick)
                next_state = IDLE;      
        end
        default: next_state = IDLE;
    endcase
end
// state output 
always_comb begin
    case(current_state)
    IDLE:begin
        tx = 1'b1;
        count_clear = 1'b0;
        count_en = 1'b0;
        load = 1'b0;
        shift_en = 1'b0;
        tx_busy =1'b0;
        baud_clear = 1'b1;
    end

    START:begin
        tx = 1'b0;
        count_clear = 1'b1;
        count_en = 1'b0;
        load = 1'b1;
        shift_en = 1'b0;
        tx_busy =1'b1;
        baud_clear = 1'b0;
    end

    DATA:begin
        tx = serial_out;
        count_clear = 1'b0;
        count_en = baud_tick;
        load = 1'b0;
        shift_en = baud_tick;
        tx_busy =1'b1;  
        baud_clear = 1'b0;
    end
    PARITY: begin
        tx = parity_bit;
        count_clear = 1'b0;
        count_en = 1'b0;
        load = 1'b0;
        shift_en = 1'b0;
        tx_busy =1'b1; 
        baud_clear = 1'b0;  
    end
    STOP:begin
        tx = 1'b1;
        count_clear = 1'b0;
        count_en = 1'b0;
        load = 1'b0;
        shift_en = 1'b0;
        tx_busy =1'b1;   
        baud_clear = 1'b0;  
    end
    default: begin
        tx = 1'b1;
        count_clear = 1'b0;
        count_en = 1'b0;
        load = 1'b0;
        shift_en = 1'b0;
        tx_busy =1'b0;
        baud_clear = 1'b1;
    end
    endcase
end
endmodule