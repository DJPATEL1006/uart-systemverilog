/******************************************************************************
 * File        : rx_baud_counter.sv
 * Author      : Divyam Patel and Foram Patel
 * Date        : 08-07-2026
 *
 * Description :
 * Baud tick generator for the UART receiver. Unlike the TX baud_gen, this
 * counter produces its first tick after only half a baud period, so the
 * RX FSM samples the START bit at its center, then ticks once every full
 * BAUD_DIV cycles afterward, landing on the center of every following bit.
 * `count_clear` restarts the half/full period sequence at the start of
 * each new frame.
 *
 * Parameters :
 *  - BAUD_DIV : Number of clock cycles per baud period
 *
 ******************************************************************************/

module rx_baud_counter #(
    parameter int unsigned BAUD_DIV = 10
)(
    input  logic clk,
    input  logic rst,
    input  logic enable,
    input  logic count_clear,
    output logic baud_tick
);

logic [$clog2(BAUD_DIV)-1:0] count;
logic half_done;

always_ff @(posedge clk or posedge rst) begin

    if (rst || count_clear) begin
        count      <= '0;
        half_done  <= 1'b0;
        baud_tick  <= 1'b0;
    end
    else begin

        baud_tick <= 1'b0;

        if (enable) begin

            if (!half_done) begin

                if (count == (BAUD_DIV/2)-1) begin
                    count     <= '0;
                    half_done <= 1'b1;
                    baud_tick <= 1'b1;
                end
                else begin
                    count <= count + 1;
                end

            end
            else begin

                if (count == BAUD_DIV-1) begin
                    count <= '0;
                    baud_tick <= 1'b1;
                end
                else begin
                    count <= count + 1;
                end

            end

        end

    end

end

endmodule