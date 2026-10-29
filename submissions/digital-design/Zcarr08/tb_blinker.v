// Testbench for the warm-up blinker. You don't edit this either.
`default_nettype none
`timescale 1ns / 1ns

module tb_blinker;

    reg clk = 0;
    reg rst_n = 0;
    wire [7:0] uo_out, uio_out, uio_oe;

    always #5 clk = ~clk;      // a clock: flips every 5ns, so one tick = 10ns

    tt_um_blinker dut (
        .ui_in(8'h00), .uo_out(uo_out),
        .uio_in(8'h00), .uio_out(uio_out), .uio_oe(uio_oe),
        .ena(1'b1), .clk(clk), .rst_n(rst_n)
    );

    wire led = uo_out[0];
    integer i;

    initial begin
        $dumpfile("blinker.vcd");
        $dumpvars(0, tb_blinker);

        $display("tick   led");
        $display("==========");
        repeat (3) @(negedge clk);
        rst_n = 1;

        for (i = 0; i < 40; i = i + 1) begin
            @(posedge clk);
            #1 $display("%4d    %b", i, led);
        end

        $display("");
        $display("Done. Open the waveform with:  gtkwave blinker.vcd &");
        $finish;
    end

endmodule
