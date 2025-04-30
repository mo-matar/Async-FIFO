module read_ptr_generator #(
    PTR_SIZE = 3
) (
    input logic read_clk,
    input logic read_reset, read_en,
    input logic [PTR_SIZE:0] write_ptr_grey,
    output logic empty,
    output logic [PTR_SIZE:0] read_ptr,
    output logic [PTR_SIZE:0] read_ptr_grey
);
    //synchronizer process signals
    logic [PTR_SIZE:0] write_ptr_unsafe_grey;//likely to have metastability issues
    logic [PTR_SIZE:0] write_ptr_safe_grey;//almost garanteed to be safe of metastability
    //read pointer signals
    logic [PTR_SIZE:0] read_ptr_next;//use next read ptr in empty condition to enhance performance
    logic [PTR_SIZE:0] read_ptr_next_grey;
    logic empty_condition;

    assign read_ptr_next = (read_en && !empty) ? read_ptr + 1 : read_ptr;
    assign read_ptr_next_grey = (read_ptr_next >> 1) ^ read_ptr_next; //generate grey from binary, example: 1110 ==> 0111 ==> 1001
    assign empty_condition = (write_ptr_safe_grey == read_ptr_next_grey);
    
    always_ff @( posedge read_clk, negedge read_reset ) begin : synchronizer_process
        if (!read_reset) begin
            write_ptr_unsafe_grey <= 0;
            write_ptr_safe_grey <= 0;
        end else
        begin
            write_ptr_unsafe_grey <= write_ptr_grey;
            write_ptr_safe_grey <= write_ptr_unsafe_grey;
        end
    end

    always_ff @( posedge read_clk, negedge read_reset ) begin : empty_flag_process
        if (!read_reset) begin
            empty <= 1;
        end else
        begin
            empty <= empty_condition;
        end
        
    end


    always_ff @( posedge read_clk, negedge read_reset ) begin : read_ptr_process
        if (!read_reset) begin
            read_ptr <= 0;
            read_ptr_grey <= 0;
        end else
        begin
            read_ptr <= read_ptr_next;
            read_ptr_grey <= read_ptr_next_grey;
        end
        
    end
endmodule
