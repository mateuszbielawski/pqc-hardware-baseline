module top_benchmark (
    input wire clk,
    input wire uart_rx,
    output wire uart_tx,
    output wire led
);
    wire [7:0] rx_data;
    wire rx_ready;
    reg [7:0] tx_data;
    reg tx_start;
    wire tx_busy;

    reg [31:0] a;
    reg [31:0] iter_cnt;
    reg [1:0] state;

    // Benchmark parameters
    parameter MAX_ITER = 5000000;

    wire [31:0] next_a;
    // PQC Montgomery unit instantiation
    montgomery_unit pqc_inst (.clk(clk), .a_in(a), .a_out(next_a));

    always @(posedge clk) begin
        case(state)
            0: begin // IDLE: Wait for trigger signal from Host (Python)
                tx_start <= 0;
                if (rx_ready) begin 
                    a <= {24'b0, rx_data}; // Seed 'a' with incoming UART data
                    iter_cnt <= 0;
                    state <= 1;
                end
            end
            1: begin // COMPUTATION: LEDs active during processing (approx. 0.18s)
                if (iter_cnt < MAX_ITER) begin
                    a <= next_a + 1'b1;
                    iter_cnt <= iter_cnt + 1'b1;
                end else begin
                    state <= 2;
                end
            end
            2: begin // TRANSMIT: Send lower byte of result back to Host
                if (!tx_busy) begin
                    tx_data <= a[7:0];
                    tx_start <= 1;
                    state <= 3;
                end
            end
            3: begin // CLEANUP: Reset UART start signal and return to IDLE
                tx_start <= 0;
                if (!tx_busy) state <= 0;
            end
        endcase
    end

    // Visual feedback: LED is OFF only during active computation state
    assign led = (state == 1); 

    // UART modules (Baud rate divisor for 27MHz clock)
    uart_rx_simple #(.DIV(234)) rx_inst (.clk(clk), .rx(uart_rx), .data(rx_data), .ready(rx_ready));
    uart_tx_simple #(.DIV(234)) tx_inst (.clk(clk), .tx(uart_tx), .data(tx_data), .start(tx_start), .busy(tx_busy));
endmodule