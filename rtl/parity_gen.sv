module parity_gen #(
    parameter bit ODD_PARITY = 0, // EVEN PARITY = 0 and ODD PARITY = 1
    parameter int unsigned BITS_NUM = 8 //number of bit 
    )(
        input logic [BITS_NUM-1:0]data,
        output logic parity_bit
    );

assign parity_bit = ODD_PARITY ? ~(^data) : ^data ;

endmodule