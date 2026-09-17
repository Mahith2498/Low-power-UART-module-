`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Create Date: 08/17/2026 09:09:51 PM
// Designer Name: KOTHAPALLI MAHITH VATHSAV 
// Module Name: uart9_standard
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////

// Standard 9-Bit UART Transmitter
module uart9_standard (
    input  wire       clk,        // 125 MHz Zybo Z7 Clock
    input  wire       rst,        // Active-High Reset
    input  wire       tx_start,   // Pulse high to transmit
    input  wire [8:0] tx_data,    // 9-bit data payload
    output reg        tx,         // Serial Output line
    output reg        tx_busy     // High while transmitting
);

    parameter CLK_FREQ  = 125000000;
    parameter BAUD_RATE = 115200;
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;

    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    reg [1:0]  state        = IDLE;
    reg [15:0] baud_counter = 0;
    reg        baud_tick    = 0;
    reg [3:0]  bit_index    = 0;
    reg [8:0]  data_buffer  = 0;

    // Baud Rate Generator
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_counter <= 0;
            baud_tick    <= 1'b0;
        end else begin
            if (baud_counter == BAUD_DIV - 1) begin
                baud_counter <= 0;
                baud_tick    <= 1'b1;
            end else begin
                baud_counter <= baud_counter + 1'b1;
                baud_tick    <= 1'b0;
            end
        end
    end

    // FSM State Machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            tx          <= 1'b1;
            tx_busy     <= 1'b0;
            bit_index   <= 0;
            data_buffer <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        data_buffer <= tx_data;
                        tx_busy     <= 1'b1;
                        state       <= START;
                    end
                end

                START: begin
                    if (baud_tick) begin
                        tx        <= 1'b0; // Start Bit
                        bit_index <= 0;
                        state     <= DATA;
                    end
                end

                DATA: begin
                    if (baud_tick) begin
                        tx <= data_buffer[bit_index];
                        if (bit_index == 8) begin // 9 bits transmitted
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end
                end

                STOP: begin
                    if (baud_tick) begin
                        tx    <= 1'b1; // Stop Bit
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule