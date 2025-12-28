module uart_tx_simple #(parameter DIV = 234) (
    input wire clk,
    output reg tx = 1,
    input wire [7:0] data,
    input wire start,
    output reg busy = 0
);
    reg [3:0] bit_idx = 0;   // Index of the bit being transmitted
    reg [31:0] clk_cnt = 0;  // Clock divider counter
    reg [7:0] shift_reg;

    always @(posedge clk) begin
        if (!busy) begin
            if (start) begin
                busy <= 1;
                clk_cnt <= 0;
                bit_idx <= 0;
                shift_reg <= data;
                tx <= 0; // Start bit
            end
        end else begin
            if (clk_cnt < DIV) begin
                clk_cnt <= clk_cnt + 1;
            end else begin
                clk_cnt <= 0;
                if (bit_idx < 8) begin
                    // Transmit 8 data bits (LSB first)
                    tx <= shift_reg[bit_idx];
                    bit_idx <= bit_idx + 1;
                end else if (bit_idx == 8) begin
                    tx <= 1; // Stop bit
                    bit_idx <= bit_idx + 1;
                end else begin
                    busy <= 0; // Transmission finished
                end
            end
        end
    end
endmodule