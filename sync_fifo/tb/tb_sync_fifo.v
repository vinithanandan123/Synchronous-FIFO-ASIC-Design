`timescale 1ns/1ps

module tb_sync_fifo;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter DEPTH = (1 << ADDR_WIDTH);

    reg clk;
    reg rst_n;

    reg wr_en;
    reg rd_en;

    reg [DATA_WIDTH-1:0] din;

    wire [DATA_WIDTH-1:0] dout;
    wire full;
    wire empty;

    integer i;
    integer errors;

    reg [DATA_WIDTH-1:0] expected [0:DEPTH-1];

    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // 100 MHz simulation clock
    always #5 clk = ~clk;

    initial begin

        $dumpfile("results/sync_fifo.vcd");
        $dumpvars(0, tb_sync_fifo);

        clk = 1'b0;
        rst_n = 1'b0;

        wr_en = 1'b0;
        rd_en = 1'b0;

        din = 0;
        errors = 0;

        // Apply synchronous reset
        repeat (2) @(posedge clk);
        @(negedge clk);

        rst_n = 1'b1;

        // Confirm initial state
        if (!empty || full) begin
            $display("ERROR: Incorrect reset flags");
            errors = errors + 1;
        end

        // Write all 16 entries
        for (i = 0; i < DEPTH; i = i + 1) begin

            @(negedge clk);

            wr_en = 1'b1;
            rd_en = 1'b0;

            din = i + 8'h20;
            expected[i] = din;

            @(posedge clk);
            #1;

        end

        @(negedge clk);

        wr_en = 1'b0;
        rd_en = 1'b0;

        #1;

        if (!full) begin
            $display("ERROR: FIFO did not become full");
            errors = errors + 1;
        end

        $display("FIFO full test completed");

        // Read all 16 entries
        for (i = 0; i < DEPTH; i = i + 1) begin

            @(negedge clk);

            wr_en = 1'b0;
            rd_en = 1'b1;

            @(posedge clk);
            #1;

            if (dout !== expected[i]) begin

                $display(
                    "ERROR: index=%0d expected=%h actual=%h",
                    i, expected[i], dout
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS: index=%0d data=%h",
                    i, dout
                );

            end

        end

        @(negedge clk);

        rd_en = 1'b0;

        #1;

        if (!empty) begin
            $display("ERROR: FIFO did not become empty");
            errors = errors + 1;
        end

        if (errors == 0) begin
            $display("================================");
            $display("ALL FIFO TESTS PASSED");
            $display("================================");
        end
        else begin
            $display("================================");
            $display("FIFO TESTS FAILED: %0d errors", errors);
            $display("================================");
            $fatal(1);
        end

        $finish;

    end

endmodule
