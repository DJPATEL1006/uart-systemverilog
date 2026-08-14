/******************************************************************************
 * File        : bit_counter.sv
 * Author      : Divyam Patel and Foram Patel
 * Date        : 08-07-2026
 *
 * Description :
 * Generic bit counter shared by both uart_tx and uart_rx. Increments once
 * per `enable` pulse and asserts `done` once BITS_NUM bits have been
 * counted, signalling the FSM to move from the DATA state to PARITY.
 * `clear` resets the count back to 0 synchronously.
 *
 * Parameters :
 *  - BITS_NUM : Number of data bits per frame (must be >= 2)
 *
 ******************************************************************************/

module bit_counter #(parameter int unsigned BITS_NUM = 8)(
    input logic clk,
    input logic rst,
    input logic enable,
    input logic clear,
    output logic done,
    output logic [$clog2(BITS_NUM)-1:0]count
); 

initial begin
    assert (BITS_NUM >= 2)
        else $error("BITS_NUM must be >= 2"); //BITS_NUM should be greater than or equal to 2
end 

always_ff @ (posedge clk or posedge rst)begin
    if (rst)begin
        count <= '0;
    end
    

    else if (clear)begin
        count <= '0;
    end

    else if (enable )begin
        if (count != BITS_NUM - 1)
            count <= count + 1; 
    end

end
assign done = (count == BITS_NUM - 1);
endmodule