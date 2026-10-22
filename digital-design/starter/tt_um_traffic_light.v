// ASIC Block 1 starter.
// Copy this into submissions/digital-design/YOUR-GITHUB-USERNAME/ and fill in the TODOs.
// Do not change the port list. It is the Tiny Tapeout pin layout, and we use it
// everywhere, including on the tile you tape out.

`default_nettype none

module tt_um_traffic_light (
    input  wire [7:0] ui_in,    // ui_in[0] = pedestrian button
    output wire [7:0] uo_out,   // uo_out[3:0] = walk, green, yellow, red
    input  wire [7:0] uio_in,   // not used this block
    output wire [7:0] uio_out,  // not used this block
    output wire [7:0] uio_oe,   // not used this block
    input  wire       ena,      // not used this block
    input  wire       clk,
    input  wire       rst_n     // reset when 0 (active low), synchronous
);

    // ---------- how long each light stays on, in clock ticks ----------
    localparam GREEN_TICKS     = 12;
    localparam YELLOW_TICKS    = 4;
    localparam RED_TICKS       = 10;
    localparam MIN_GREEN_TICKS = 4;    // cars always get at least this much green

    // ---------- the three states, and the 2-bit code for each ----------
    localparam GREEN  = 2'b00;
    localparam YELLOW = 2'b01;
    localparam RED    = 2'b10;

    // ---------- inputs, renamed so the code reads clearly ----------
    wire button_pressed = ui_in[0];    // high for ONE tick when someone presses

    // ---------- what the design remembers (flip-flops) ----------
    reg [1:0] current_light;           // which light is on right now
    reg [4:0] ticks_in_light;          // how many ticks we've been in this light
    reg       walk_requested;          // someone pressed the button and is waiting


    // ==========================================================
    // ================ YOUR WORK STARTS HERE ===================
    // ==========================================================
    //
    // Write ONE always @(posedge clk) block. Use <= (nonblocking), never =.
    //
    // TODO 1: reset.
    //     When rst_n is 0: current_light <= RED, ticks_in_light <= 0,
    //     walk_requested <= 0.
    //
    // TODO 2: remember the button press.
    //     walk_requested goes to 1 when button_pressed pulses.
    //     walk_requested is cleared while the light is RED.
    //     (Think about why you can't just check button_pressed inside GREEN.)
    //
    // TODO 3: the state machine and the tick counter.
    //     Each tick, either add 1 to ticks_in_light, or change current_light
    //     and set ticks_in_light back to 0.
    //
    //       GREEN  -> YELLOW  when ticks_in_light == GREEN_TICKS - 1
    //                         OR (walk_requested && ticks_in_light >= MIN_GREEN_TICKS - 1)
    //       YELLOW -> RED     when ticks_in_light == YELLOW_TICKS - 1
    //       RED    -> GREEN   when ticks_in_light == RED_TICKS - 1
    //
    //     Include a `default:` case that goes back to RED. Real silicon can
    //     glitch into the unused code 2'b11, and you want a way out.
    //
    // ==========================================================
    // ================= YOUR WORK ENDS HERE ====================
    // ==========================================================


    // ---------- outputs ----------
    // TODO 4: drive these from current_light. Exactly one of red/yellow/green, always.
    //         walk_light is on for all of RED, and off in GREEN and YELLOW.
    wire car_red    = 1'b0;
    wire car_yellow = 1'b0;
    wire car_green  = 1'b0;
    wire walk_light = 1'b0;

    assign uo_out[0]   = car_red;
    assign uo_out[1]   = car_yellow;
    assign uo_out[2]   = car_green;
    assign uo_out[3]   = walk_light;
    assign uo_out[7:4] = 4'b0000;

    // ---------- unused pins ----------
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Tells the tools "yes, I know these are unconnected, that is on purpose."
    wire _unused = &{ena, uio_in, ui_in[7:1], 1'b0};

endmodule
