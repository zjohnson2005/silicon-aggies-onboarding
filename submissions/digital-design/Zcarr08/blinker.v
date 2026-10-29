// Warm-up design. This one is complete and working, so you don't edit it.
// Your only job in Lesson 1 is to compile it, run it, and look at the waveform.
//
// What it does: counts clock ticks, and flips an LED on and off every 8 ticks.

`default_nettype none

module tt_um_blinker (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    reg [2:0] counter;   // counts 0,1,2,...,7 then wraps back to 0 on its own
    reg       led;

    always @(posedge clk) begin
        if (!rst_n) begin
            counter <= 3'd0;
            led     <= 1'b0;
        end else begin
            counter <= counter + 3'd1;
            if (counter == 3'd7)
                led <= ~led;      // flip the LED every 8th tick
        end
    end

    assign uo_out[0]   = led;
    assign uo_out[7:1] = 7'b0;

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;
    wire _unused = &{ena, ui_in, uio_in, 1'b0};

endmodule
