// Code your testbench here
// or browse Examples
class transaction;
  // randmozied bit for operation control
  rand bit oper;
  bit rd, wr;
  bit [7:0] data_in;
  bit full, empty;
  bit [7:0] data_out;
  // constraint to randomize operation control with 50% probability of 1 and 0.
  constraint oper_ctrl {
    oper dist {1 :/ 50, 0 :/ 50};
  }
endclass

 class generator;
  
  transaction tr;           // Transaction object to generate and send
  mailbox #(transaction) mbx;  // Mailbox for communication
  int count = 0;            // Number of transactions to generate
  int i = 0;                // Iteration counter
  
  event next;               // Event to signal when to send the next transaction
  event done;               // Event to convey completion of requested number of transactions
   // creating a function to take new transaction whenever required
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    tr = new();
  endfunction 
 // run the task 
  task run(); 
    repeat (count) begin
      assert (tr.randomize) else $error("Randomization failed");
      i++;
      mbx.put(tr);
      $display("[GEN] : Oper : %0d iteration : %0d", tr.oper, i);
      @(next);
    end -> done;
  endtask
  
endclass

class driver;
  
   virtual fifo_if fif;     // Virtual interface to the FIFO
  mailbox #(transaction) mbx;  // Mailbox for communication
  transaction datac;       // Transaction object for communication
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
   // Reset the DUT
  task reset();
    fif.rst <= 1'b1;
    fif.rd <= 1'b0;
    fif.wr <= 1'b0;
    fif.din <= 0;
    repeat (5) @(posedge fif.clk);
    fif.rst <= 1'b0;
    $display("[DRV] : DUT Reset Done");
    $display("------------------------------------------");
  endtask
   
  // Write data to the FIFO
  task write();
    @(posedge fif.clk);
    fif.rst <= 1'b0;
    fif.rd <= 1'b0;
    fif.wr <= 1'b1;
    fif.din <= $urandom_range(1, 10);
    @(posedge fif.clk);
    fif.wr <= 1'b0;
    $display("[DRV] : DATA WRITE  data : %0d", fif.din);  
    @(posedge fif.clk);
  endtask
  
  // Read data from the FIFO
  task read();  
    @(posedge fif.clk);
    fif.rst <= 1'b0;
    fif.rd <= 1'b1;
    fif.wr <= 1'b0;
    @(posedge fif.clk);
    fif.rd <= 1'b0;      
    $display("[DRV] : DATA READ");  
    @(posedge fif.clk);
  endtask
  
  // Apply random stimulus to the DUT
  task run();
    forever begin
      mbx.get(datac);  
      if (datac.oper == 1'b1)
        write();
      else
        read();
    end
  endtask
  
endclass

class monitor;
 
  virtual fifo_if fif;     // Virtual interface to the FIFO
  mailbox #(transaction) mbx;  // Mailbox for communication
  transaction tr;          // Transaction object for monitoring
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;     
  endfunction
 
  task run();
    tr = new();
    
    forever begin
      repeat (2) @(posedge fif.clk);
      tr.wr = fif.wr;
      tr.rd = fif.rd;
      tr.data_in = fif.din;
      tr.full = fif.full;
      tr.empty = fif.empty; 
      @(posedge fif.clk);
      tr.data_out = fif.dout;
    
      mbx.put(tr);
      $display("[MON] : Wr:%0d rd:%0d din:%0d dout:%0d full:%0d empty:%0d", tr.wr, tr.rd, tr.data_in, tr.data_out, tr.full, tr.empty);
    end
    
  endtask
  
endclass

class scoreboard;
  
  mailbox #(transaction) mbx;  // Mailbox for communication
  transaction tr;          // Transaction object for monitoring
  event next;
  bit [7:0] din[$];       // Array to store written data
  bit [7:0] temp;         // Temporary data storage
  int err = 0;            // Error count
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;     
  endfunction
 
  task run();
    forever begin
      mbx.get(tr);
      $display("[SCO] : Wr:%0d rd:%0d din:%0d dout:%0d full:%0d empty:%0d", tr.wr, tr.rd, tr.data_in, tr.data_out, tr.full, tr.empty);
      
      if (tr.wr == 1'b1) begin
        if (tr.full == 1'b0) begin
          din.push_front(tr.data_in);
          $display("[SCO] : DATA STORED IN QUEUE :%0d", tr.data_in);
        end
        else begin
          $display("[SCO] : FIFO is full");
        end
        $display("--------------------------------------"); 
      end
    
      if (tr.rd == 1'b1) begin
        if (tr.empty == 1'b0) begin  
          temp = din.pop_back();
          
          if (tr.data_out == temp)
            $display("[SCO] : DATA MATCH");
          else begin
            $error("[SCO] : DATA MISMATCH");
            err++;
          end
        end
        else begin
          $display("[SCO] : FIFO IS EMPTY");
        end
        
        $display("--------------------------------------"); 
      end
      
      -> next;
    end
  endtask
  
endclass

class environment;
 
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  mailbox #(transaction) gdmbx;  // Generator + Driver mailbox
  mailbox #(transaction) msmbx;  // Monitor + Scoreboard mailbox
  event nextgs;
  virtual fifo_if fif;
  
  function new(virtual fifo_if fif);
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);
    this.fif = fif;
    drv.fif = this.fif;
    mon.fif = this.fif;
    gen.next = nextgs;
    sco.next = nextgs;
  endfunction
  
  task pre_test();
    drv.reset();
  endtask
  
  task test();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_any
  endtask
  
  task post_test();
    wait(gen.done.triggered);  
    $display("---------------------------------------------");
    $display("Error Count :%0d", sco.err);
    $display("---------------------------------------------");
    $finish();
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
  endtask
  
endclass

module tb;
    
  fifo_if fif();
  FIFO dut (fif.clk, fif.rst, fif.wr, fif.rd, fif.din, fif.dout, fif.empty, fif.full);
    
  initial begin
    fif.clk <= 0;
  end
    
  always #10 fif.clk <= ~fif.clk;
    
  environment env;
    
  initial begin
    env = new(fif);
    env.gen.count = 10;
    env.run();
  end
    
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
   
endmodule
