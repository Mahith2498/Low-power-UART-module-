`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/17/2026 09:12:38 PM
// Designer Name: KOTHAPALLI MAHITH VATHSAV 
// Module Name: tb_uart9_standard
//////////////////////////////////////////////////////////////////////////////////
module tb_uart9_standard;

    reg        clk;
    reg        rst;
    reg        tx_start;
    reg  [8:0] tx_data;
    wire       tx;
    wire       tx_busy;

    // Instantiate Standard UART
    uart9_standard #(
        .CLK_FREQ(125000000),
        .BAUD_RATE(115200)
    ) dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // 125 MHz Clock
    always #4 clk = ~clk;

    initial begin
        clk      = 0;
        rst      = 1;
        tx_start = 0;
        tx_data  = 0;

        #100;
        rst = 0;
        #40;

        // Transmit Frame 1: 9'b1_1010_0101 (A5 hex + 9th bit = 1)
        @(posedge clk);
        tx_data  = 9'b1_1010_0101;
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;

        wait(tx_busy == 0);
        #1000;

        $display("Standard UART Transmission Complete!");
        $finish;
    end

endmodule
