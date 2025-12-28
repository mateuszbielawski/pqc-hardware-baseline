module uart_rx_simple #(parameter DIV = 234) (
    input wire clk,
    input wire rx,
    output reg [7:0] data,
    output reg ready
);
    reg [31:0] count = 0; // Increased width to prevent overflow errors
    reg [3:0] bit_idx = 0;
    reg active = 0;
    reg [7:0] shift_reg = 0;

    always @(posedge clk) begin
        ready <= 0;
        if (!active) begin
            if (rx == 0) begin // Start bit detected
                // Wait until the middle of the start bit to ensure stability
                if (count < DIV/2) count <= count + 1;
                else begin
                    count <= 0;
                    active <= 1;
                    bit_idx <= 0;
                end
            end else count <= 0;
        end else begin
            if (count < DIV) count <= count + 1;
            else begin
                count <= 0;
                if (bit_idx < 8) begin // Receiving 8 data bits
                    shift_reg[bit_idx] <= rx;
                    bit_idx <= bit_idx + 1;
                end else begin // Stop bit reached
                    data <= shift_reg;
                    ready <= 1;
                    active <= 0;
                end
            end
        end
    end
endmodule