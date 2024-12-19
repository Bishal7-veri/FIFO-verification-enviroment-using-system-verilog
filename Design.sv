// Code your design here
module FIFO (input clk,rst, wr,rd, input [7:0] din,
             output reg [7:0] dout, output empty, full);
  // pointers for write and read operations
  reg [3:0] wptr, rptr;
  // counters for tracking number of elements in FIFO
  reg [4:0] cnt = 0;
  // memory array to store data
  reg [7:0] mem [15:0];
  always @(posedge clk)
  begin
      if(rst == 1'b1)
        // reset the pointers and counters when the reset signal is asserted
        begin
          wptr <= 0;
          rptr <= 0;
          cnt <= 0;
        end
  else if(wr && !full)
    // write the data to FIFO if the memory is not full
    begin
      mem[wptr] <= din;
      wptr <= wptr + 1;
      cnt <= cnt + 1;
    end
  else if(rd && !empty)
    // read the data if the memory is not full
    begin
      dout <= mem[rptr];
      rptr <= rptr + 1;
      cnt  <= cnt - 1;
    end
  end
  // assigning empty and full 
  assign empty = (cnt == 0) ? 1'b1 : 1'b0;
  assign full = (cnt == 16) ? 1'b1 : 1'b0;
  
endmodule

// Defining an interface outside the module so that we can access the data globally whenever needed

interface fifo_if;
  logic clk,rst, wr,rd;
  logic [7:0] din;
  logic [7:0] dout;
  logic full,empty;
endinterface
