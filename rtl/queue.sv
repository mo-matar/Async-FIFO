module queue #(
    parameter DATA_WIDTH = 8,
    parameter QUEUE_SIZE = 8,
    parameter PTR_SIZE = 3
)(
    input logic write_clk,
    input logic read_clk,
    input logic write_en,
    input logic read_en,
    input logic [DATA_WIDTH-1:0] write_data,
    output logic [DATA_WIDTH-1:0] read_data,
    input logic full,
    input logic empty,
    input logic [PTR_SIZE:0] write_ptr,
    input logic [PTR_SIZE:0] read_ptr
);

    reg [DATA_WIDTH-1:0] queue_mem [0:QUEUE_SIZE-1];

    always_ff @(posedge write_clk) begin : write_fifo_process
         if (write_en && !full) begin
            queue_mem[write_ptr[PTR_SIZE-1:0]] <= write_data;        
        end

    end

    always_comb begin : read_fifo_process
        if (read_en && !empty) begin
            read_data <= queue_mem[read_ptr[PTR_SIZE-1:0]];
        end
    end

endmodule