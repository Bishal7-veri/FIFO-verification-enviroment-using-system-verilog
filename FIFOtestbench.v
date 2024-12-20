`timescale 1ns / 1ps

module FIFO_tb();

    // Testbench signals
    reg clk;
    reg rst;
    reg wr;
    reg rd;
    reg [7:0] din;
    wire [7:0] dout;
    wire empty;
    wire full;

    // Instantiate the FIFO module
    FIFO uut (
        .clk(clk),
        .rst(rst),
        .wr(wr),
        .rd(rd),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz clock (10 ns period)

    // Test sequence
    initial begin
        // Initialize inputs
        rst = 1;
        wr = 0;
        rd = 0;
        din = 0;

        // Reset the FIFO
        #10 rst = 0;
        
        // Write data to the FIFO
        #10 wr = 1; din = 8'hA1; // Write 0xA1
        #10 din = 8'hB2;         // Write 0xB2
        #10 din = 8'hC3;         // Write 0xC3
        #10 wr = 0;              // Stop writing

        // Read data from the FIFO
        #10 rd = 1; // Read 0xA1
        #10;        // Read 0xB2
        #10;        // Read 0xC3
        #10 rd = 0; // Stop reading

        // Fill FIFO completely
        rst = 1; #10 rst = 0; // Reset
        wr = 1;
        repeat (16) begin
            #10 din = din + 1; // Write 16 values
        end
        wr = 0;

        // Attempt to write to a full FIFO
        #10 wr = 1; din = 8'hFF; // Should not be written
        #10 wr = 0;

        // Read all data from FIFO
        rd = 1;
        repeat (16) #10;
        rd = 0;

        // Attempt to read from an empty FIFO
        #10 rd = 1; // Should not read anything
        #10 rd = 0;

        // Finish simulation
        #20 $finish;
    end

endmodule
