// ASIC Block 1 starter.
// Copy this into submissions/digital-design/YOUR-GITHUB-USERNAME/ and fill in the TODOs.
// Do not change the port list. It is the Tiny Tapeout pin contract, and we use it
// everywhere, including on the tile you tape out.

`default_nettype none

module tt_um_traffic_light (
    input  wire [7:0] ui_in,    // dedicated inputs: ui_in[0] is the ped button
    output wire [7:0] uo_out,   // dedicated outputs: the lights
    input  wire [7:0] uio_in,   // bidirectional, unused this block
    output wire [7:0] uio_out,  // bidirectional, unused this block
    output wire [7:0] uio_oe,   // bidirectional enable, unused this block
    input  wire       ena,      // always 1 when the design is selected
    input  wire       clk,
    input  wire       rst_n     // active LOW, synchronous
);

    // ================ timing, in clock ticks ================
    localparam GREEN_TIME  = 12;
    localparam YELLOW_TIME = 4;
    localparam RED_TIME    = 10;
    localparam MIN_GREEN   = 4;   // cars always get at least this much green

    // ================ state encoding ================
    localparam S_GREEN  = 2'b00;
    localparam S_YELLOW = 2'b01;
    localparam S_RED    = 2'b10;

    wire ped_button = ui_in[0];   // one-cycle pulse, can arrive any time

    reg [1:0] state;
    reg [4:0] timer;
    reg       ped_req;            // "somebody pressed the button and we owe them a walk"


    // ==========================================================
    // ================ YOUR WORK STARTS HERE ===================
    // ==========================================================
    //
    // Write ONE always @(posedge clk) block. Use <= (nonblocking), never =.
    //
    // TODO 1: reset.
    //     When rst_n is low: state <= S_RED, timer <= 0, ped_req <= 0.
    //
    // TODO 2: latch (remember) the pedestrian request.
    //     ped_req goes high when ped_button pulses.
    //     ped_req is cleared while the light is RED.
    //     (Think about why you cannot just test ped_button inside the GREEN state.)
    //
    // TODO 3: the state machine and the timer.
    //     Each tick, either increment timer, or change state and clear timer to 0.
    //
    //       S_GREEN  -> S_YELLOW  when timer == GREEN_TIME - 1
    //                             OR (ped_req && timer >= MIN_GREEN - 1)
    //       S_YELLOW -> S_RED     when timer == YELLOW_TIME - 1
    //       S_RED    -> S_GREEN   when timer == RED_TIME - 1
    //
    //     Include a `default:` case that sends you back to S_RED. Real silicon can
    //     land in an unused state on a glitch and you want a way out.
    //
    // ==========================================================
    // ================= YOUR WORK ENDS HERE ====================
    // ==========================================================


    // ================ outputs ================
    // TODO 4: drive these from `state`. Exactly one of red/yellow/green, always.
    //         walk is high for the whole RED state, and low in GREEN and YELLOW.
    assign uo_out[0]   = 1'b0;   // car_red
    assign uo_out[1]   = 1'b0;   // car_yellow
    assign uo_out[2]   = 1'b0;   // car_green
    assign uo_out[3]   = 1'b0;   // walk
    assign uo_out[7:4] = 4'b0000;

    // ================ unused ================
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Tells the tools "yes, I know these are unconnected, that is on purpose."
    wire _unused = &{ena, uio_in, ui_in[7:1], 1'b0};

endmodule
