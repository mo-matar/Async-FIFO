module async_fifo_tb;
  parameter DATA_WIDTH = 8;
  parameter QUEUE_SIZE = 8;
  
  logic write_clk = 0;
  logic read_clk = 0;
  logic reset_read;
  logic reset_write;
  logic write_en;
  logic read_en;
  logic [DATA_WIDTH-1:0] write_data;
  logic [DATA_WIDTH-1:0] read_data;
  logic full;
  logic empty;
  
  logic [DATA_WIDTH-1:0] data_queue[$];
  logic [DATA_WIDTH-1:0] expected_data;
  
  async_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .QUEUE_SIZE(QUEUE_SIZE)
  ) dut (
    .write_clk(write_clk),
    .read_clk(read_clk),
    .reset_read(reset_read),
    .reset_write(reset_write),
    .write_en(write_en),
    .read_en(read_en),
    .write_data(write_data),
    .read_data(read_data),
    .full(full),
    .empty(empty)
  );
  

  always #5 write_clk = ~write_clk;
  always #7.5 read_clk = ~read_clk;
  

  initial begin
    reset_read = 0;  
    reset_write = 0; 
    write_en = 0;
    read_en = 0;
    write_data = 0;
    
    #50;
    
    reset_read = 1;
    reset_write = 1;
    #20;
    
    //assert initial state
    $display("Testing initial state...");
    assert(empty === 1'b1) else $error("FIFO should be empty after reset");
    assert(full === 1'b0) else $error("FIFO should not be full after reset");
    $display("Initial state verified: FIFO is empty and not full");
    
    //write until FIFO is full
    $display("\nStarting write phase...");
    for(int i = 1; i <= QUEUE_SIZE*2; i++) begin
      if(!full) begin
        // Add data to tracking queue when write is successful
        data_queue.push_back(i);
        $display("Writing data: %d, Queue size: %0d", i, data_queue.size());
      end else begin
        $display("FIFO is full, can't write data: %d", i);
      end
      write_en = 1;
      @(posedge write_clk);
      write_data = i;
      #1
      write_en = 0;
      @(posedge write_clk);
      
      
      
    end
    
    write_en = 0;
    
    //assert FIFO is full
    #20;
    assert(full === 1'b1) else $error("FIFO should be full after writes");
    $display("Write phase complete: FIFO is full with %0d elements", data_queue.size());
    
    #50;
    
    //read until FIFO is empty
    $display("\nStarting read phase...");
    #5;
    read_en = 1;
    
    for(int i = 0; i < QUEUE_SIZE*2; i++) begin
      read_en = 1;
      @(posedge read_clk);
      
      if(!empty) begin
        expected_data = data_queue.pop_front();
        assert(read_data === expected_data) else 
          $error("Data mismatch: Expected %d, Got %d", expected_data, read_data);
        $display("Reading data: %d, Remaining items: %0d", read_data, data_queue.size());
        read_en = 0;
        @(posedge read_clk);

      end else begin
        $display("FIFO is empty, can't read more data");
        break;
      end
    end
    
    read_en = 0;
    
    //assert FIFO is empty
    #20;
    assert(empty === 1'b1) else $error("FIFO should be empty after reads");
    assert(data_queue.size() === 0) else $error("Test queue should be empty");
    $display("Read phase complete: FIFO is empty");
    
    $display("\nTest completed successfully!");
    #20 $finish;
  end
  
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end

endmodule