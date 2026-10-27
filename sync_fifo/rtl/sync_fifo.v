`timescale 1ns/1ps

module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire                     clk,
    input  wire                     rst_n,

    input  wire                     wr_en,
    input  wire                     rd_en,

    input  wire [DATA_WIDTH-1:0]    din,

    output reg  [DATA_WIDTH-1:0]    dout,
    output reg                      full,
    output reg                      empty
);

    // FIFO depth = 2^ADDR_WIDTH
    localparam DEPTH = (1 << ADDR_WIDTH);

    // Memory storage
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointers include one extra wrap bit
    reg [ADDR_WIDTH:0] wr_ptr;
    reg [ADDR_WIDTH:0] rd_ptr;

    // Pointer values for the next accepted operations
    wire write_accept;
    wire read_accept;

    wire [ADDR_WIDTH:0] wr_ptr_next;
    wire [ADDR_WIDTH:0] rd_ptr_next;

    // A write is accepted only when the FIFO is not full
    assign write_accept = wr_en && !full;

    // A read is accepted only when the FIFO is not empty
    assign read_accept = rd_en && !empty;

    assign wr_ptr_next = wr_ptr + write_accept;
    assign rd_ptr_next = rd_ptr + read_accept;

    // Synchronous active-low reset
    always @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= {(ADDR_WIDTH+1){1'b0}};
            rd_ptr <= {(ADDR_WIDTH+1){1'b0}};

            full  <= 1'b0;
            empty <= 1'b1;

            dout <= {DATA_WIDTH{1'b0}};
        end
        else begin

            // Write operation
            if (write_accept) begin
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= din;
            end

            // Read operation
            if (read_accept) begin
                dout <= mem[rd_ptr[ADDR_WIDTH-1:0]];
            end

            // Update pointers
            wr_ptr <= wr_ptr_next;
            rd_ptr <= rd_ptr_next;

            // Empty when next pointers are equal
            empty <= (wr_ptr_next == rd_ptr_next);

            // Full when the next write pointer is one
            // complete buffer cycle ahead of the read pointer.
            full <=
                (wr_ptr_next[ADDR_WIDTH] != rd_ptr_next[ADDR_WIDTH]) &&
                (wr_ptr_next[ADDR_WIDTH-1:0] ==
                 rd_ptr_next[ADDR_WIDTH-1:0]);

        end
    end

endmodule
