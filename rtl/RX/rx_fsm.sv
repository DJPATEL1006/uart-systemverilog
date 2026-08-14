/******************************************************************************
 * File        : rx_fsm.sv
 * Author      : Divyam Patel and Foram Patel
 * Date        : 08-07-2026
 *
 * Description :
 * Finite state machine controller for the UART receiver. Detects the
 * falling edge of rx to start a frame, verifies the start bit at its
 * center, deserializes the data bits, checks parity, and validates the
 * stop bit before asserting rx_valid.
 *
 * States :
 *  - IDLE   : Waiting for rx to fall low (start bit edge)
 *  - START  : Confirms rx is still low at the bit center; false starts
 *             (rx already high) return to IDLE
 *  - DATA   : Samples and shifts in data bits at the center of each bit
 *  - PARITY : Latches the parity comparison result
 *  - STOP   : Validates the stop bit and asserts rx_valid if parity
 *             passed and the stop bit is high
 *
 ******************************************************************************/

module rx_fsm #(parameter int unsigned WIDTH = 8) (
   // Inputs
    input  logic clk,
    input  logic rst,
    input  logic rx,
    input  logic baud_tick,
    input  logic bit_done,
    input  logic parity_error,

    // Outputs
    output logic baud_enable,
    output logic baud_clear,
    output logic shift_en,
    output logic count_en,
    output logic count_clear,
    output logic rx_valid,
    output logic rx_busy,
    output logic parity_check
);
typedef enum logic [2:0]{
    IDLE,
    START,
    DATA,
    PARITY,
    STOP
}state_r;

state_r current_state,next_state;

always_ff @ (posedge clk or posedge rst) begin
    if(rst)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

always_comb  begin 
    next_state = current_state;
    case(current_state)
    IDLE : begin
        if (!rx)
            next_state = START;
    end
    START : begin 
        if (baud_tick) begin
            if(!rx)
                next_state = DATA ;
            else 
                next_state = IDLE;
        end
    end
    DATA : begin
        if (baud_tick && bit_done)
            next_state = PARITY;
    end
    PARITY : begin
        if(baud_tick)
            next_state = STOP;
    end
    STOP : begin
        if(baud_tick)
            next_state = IDLE;
    end
    default: next_state = IDLE;
    endcase
end

always_comb begin
    case(current_state)
    IDLE : begin
        baud_enable = 1'b0;
        shift_en = 1'b0;
        count_en = 1'b0;
        rx_busy = 1'b0;
        baud_clear = 1'b1;
        count_clear = 1'b1;
        rx_valid = 1'b0;
        parity_check = 1'b0;
    end
    START : begin
        baud_enable = 1'b1;
        shift_en = 1'b0;
        count_en = 1'b0;
        rx_busy = 1'b1;
        baud_clear = 1'b0;
        count_clear = 1'b0;
        rx_valid = 1'b0;
        parity_check = 1'b0;
    end
    DATA : begin
        baud_enable = 1'b1;
        shift_en = baud_tick;
        count_en = baud_tick;
        rx_busy = 1'b1;
        baud_clear = 1'b0;
        count_clear = 1'b0;
        rx_valid = 1'b0;
        parity_check = 1'b0;
    end
    PARITY : begin
        baud_enable = 1'b1;
        shift_en = 1'b0;
        count_en = 1'b0;
        rx_busy = 1'b1;
        baud_clear = 1'b0;
        count_clear = 1'b0;
        rx_valid = 1'b0;
        parity_check = baud_tick;
    end
    STOP : begin
        baud_enable = 1'b1;
        shift_en = 1'b0;
        count_en = 1'b0;
        rx_busy = 1'b1;
        baud_clear = 1'b0;
        count_clear = 1'b0;
        rx_valid = baud_tick && rx && !parity_error;
        parity_check = 1'b0;
    end
    default: begin
        baud_enable = 1'b0;
        baud_clear  = 1'b1;
        shift_en    = 1'b0;
        count_en    = 1'b0;
        count_clear = 1'b1;
        rx_busy     = 1'b0;
        rx_valid    = 1'b0;
        parity_check = 1'b0;
    end
    endcase
end

endmodule
