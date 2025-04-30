module write_ptr_generator #(
    PTR_SIZE = 3
) (
    input logic write_clk,
    input logic write_reset,
    input logic write_en,
    input logic [PTR_SIZE:0] read_ptr_grey,
    output logic [PTR_SIZE:0] write_ptr,
    output logic [PTR_SIZE:0] write_ptr_grey,
    output logic full
);


//synchronizer process signals
    logic [PTR_SIZE:0] read_ptr_unsafe_grey;//likely to have metastability issues
    logic [PTR_SIZE:0] read_ptr_safe_grey;//almost garanteed to be safe of metastability
    //write pointer signals
    logic [PTR_SIZE:0] write_ptr_next;//use next write ptr in full condition to enhance performance
    logic [PTR_SIZE:0] write_ptr_next_grey;
    logic full_condition;

    assign write_ptr_next = (write_en && !full) ? write_ptr + 1 : write_ptr;
    assign write_ptr_next_grey = (write_ptr_next >> 1) ^ write_ptr_next; //generate grey from binary, example: 1110 ==> 0111 ==> 1001
    assign full_condition = (write_ptr_next_grey == {~read_ptr_safe_grey[PTR_SIZE:PTR_SIZE-1], read_ptr_safe_grey[PTR_SIZE-2:0]});
    // since the grey code acts like a mirror, we need to invert the MSB of the read pointer to compare it with the write pointer

    always_ff @(posedge write_clk, negedge write_reset) begin : synchronizer_process
        if (!write_reset) begin
            read_ptr_unsafe_grey <= 0;
            read_ptr_safe_grey <= 0;
        end else begin
            read_ptr_unsafe_grey <= read_ptr_grey;
            read_ptr_safe_grey <= read_ptr_unsafe_grey;
        end
    end

    always_ff @( posedge write_clk, negedge write_reset ) begin : full_flag_process
        if (!write_reset) begin
            full <= 0;
        end else begin
            full <= full_condition;
        end
        
    end


    always_ff @(posedge write_clk, negedge write_reset) begin : write_ptr_process
        if (!write_reset) begin
            write_ptr <= 0;
            write_ptr_grey <= 0;
        end else begin
            write_ptr <= write_ptr_next;
            write_ptr_grey <= write_ptr_next_grey;
        end
        
    end
endmodule