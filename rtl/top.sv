module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter QUEUE_SIZE = 8) 
    ( 
    input logic write_clk,
    input logic read_clk,
    input logic reset_read,
    input logic reset_write,
    input logic write_en,
    input logic read_en,
    input logic [DATA_WIDTH-1:0] write_data,
    output logic [DATA_WIDTH-1:0] read_data,
    output logic full, empty
    );


    // Pointer size is log2(QUEUE_SIZE)
    parameter PTR_SIZE = $clog2(QUEUE_SIZE);

    logic [PTR_SIZE:0] read_ptr;
    logic [PTR_SIZE:0] read_ptr_grey;
    logic [PTR_SIZE:0] write_ptr;
    logic [PTR_SIZE:0] write_ptr_grey;

    write_ptr_generator #(
        .PTR_SIZE(PTR_SIZE)
    ) write_ptr_gen (
        .write_clk(write_clk),
        .write_reset(reset_write),
        .write_en(write_en),
        .read_ptr_grey(read_ptr_grey),
        .write_ptr(write_ptr),
        .write_ptr_grey(write_ptr_grey),
        .full(full)
    );

    read_ptr_generator #(
        .PTR_SIZE(PTR_SIZE)
    ) read_ptr_gen (
        .read_clk(read_clk),
        .read_reset(reset_read),
        .read_en(read_en),
        .write_ptr_grey(write_ptr_grey),
        .empty(empty),
        .read_ptr(read_ptr),
        .read_ptr_grey(read_ptr_grey)
    );

    queue #(
        .DATA_WIDTH(DATA_WIDTH),
        .QUEUE_SIZE(QUEUE_SIZE),
        .PTR_SIZE(PTR_SIZE)
    ) queue_mem_inst (
        .write_clk(write_clk),//
        .read_clk(read_clk),//
        .write_en(write_en),//
        .read_en(read_en),//
        .write_data(write_data),//
        .read_data(read_data),//
        .full(full),//
        .empty(empty),//
        .write_ptr(write_ptr),//
        .read_ptr(read_ptr)//
    );

endmodule