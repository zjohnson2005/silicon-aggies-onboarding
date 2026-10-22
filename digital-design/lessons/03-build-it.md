# Lesson 3: Build the traffic light

This is the project. You build it in four rounds, running the tests after each one.

Before you start, have your state diagram from Lesson 2 next to you.

---

## The spec

A spec (short for specification) is the exact description of what the design must do. Read
it carefully. The tests check every sentence.

**Normal cycle**, measured in clock ticks:

```
GREEN (12 ticks) → YELLOW (4 ticks) → RED (10 ticks) → back to GREEN
```

**Reset.** `rst_n` is active low and synchronous (it takes effect on a clock edge). On
reset, the light goes to RED, the timer goes to 0, and the pedestrian request is cleared.

**Walk.** The `walk` output is on for the whole time the light is RED, whether or not anyone
pressed the button, and off the rest of the time.

**Exactly one light.** Exactly one of red, yellow, and green is on at every tick. Never zero,
never two.

**The pedestrian button** is a one-tick pulse on `ui_in[0]`, and it can come at any time:

- Pressed during GREEN, at tick `MIN_GREEN_TICKS` (4) or later: end green early and go to YELLOW.
- Pressed during GREEN before tick 4: **remember it**, and act on it as soon as tick 4
  arrives. Cars always get at least 4 ticks of green.
- Pressed during YELLOW or RED: nothing happens, because a walk is already on its way.
- The request clears while the light is RED. That way, a press during red doesn't carry
  over and cut the next green short.

## Pin map

This table says which pin does what:

```
ui_in[0]     pedestrian button
ui_in[7:1]   not used

uo_out[0]    car_red
uo_out[1]    car_yellow
uo_out[2]    car_green
uo_out[3]    walk
uo_out[7:4]  not used, set to 0

uio_*        not used this block, set to 0
clk, rst_n, ena   the usual
```

This is the real Tiny Tapeout pin layout. You're using it now so it's familiar by the time
we tape out.

---

## The starter file

Open `tt_um_traffic_light.v` in your submission folder. It already has the port list, the
timing constants, the state names, and the registers. You fill in four TODOs.

```verilog
    localparam GREEN_TICKS  = 12;
    localparam YELLOW_TICKS = 4;
    localparam RED_TICKS    = 10;
    localparam MIN_GREEN_TICKS   = 4;

    localparam GREEN  = 2'b00;
    localparam YELLOW = 2'b01;
    localparam RED    = 2'b10;

    wire button_pressed = ui_in[0];

    reg [1:0] current_light;
    reg [4:0] ticks_in_light;
    reg       walk_requested;
```

- **TODO 1: reset.** Set `current_light <= RED`, `ticks_in_light <= 0`, and `walk_requested <= 0`.
- **TODO 2: remember the button press.** Set `walk_requested` when the button pulses. Clear it
  while the light is RED.
- **TODO 3: the state machine and the timer.** One `case` on `current_light`. On each tick, either
  add one to the timer, or change state and set the timer to 0. Include a `default` that
  goes back to RED.
- **TODO 4: the outputs.** Drive them from `current_light`.

TODOs 1 to 3 all go in **one** `always @(posedge clk)` block, and you use `<=` for every
assignment in it. TODO 4 is the four output lines (`car_red` through `walk_light`) near the bottom of the file.

---

## Build it in rounds

Don't write all four TODOs and then run it. Write one piece, run the tests, and look at the
result. This order works well.

### Round 1: turn on a light

Do TODO 1 and TODO 4 only. Skip the state machine for now. Reset the state to RED, and
drive the outputs from `current_light`.

```bash
make
```

TEST 1 should pass: the light is red after reset and walk is on. Then TEST 2 waits for a
green light that never comes, and the run ends with a `TIMEOUT` message. That's expected at this point. You have a light that
turns on, which is real progress.

### Round 2: make it cycle

Add TODO 3, but only the plain timing. Ignore the button for now:

- GREEN goes to YELLOW when `ticks_in_light == GREEN_TICKS - 1`
- YELLOW goes to RED when `ticks_in_light == YELLOW_TICKS - 1`
- RED goes to GREEN when `ticks_in_light == RED_TICKS - 1`

Run `make` again. TEST 2 should now pass, with 12, 4, and 10 ticks.

If a number is off by one, check the `- 1`. If the light flickers between two states, you
forgot to clear the timer on one of the transitions.

### Round 3: the button

Add TODO 2. Then give GREEN a second way out. Green now goes to yellow when **either** the
timer runs out, **or** `walk_requested` is set and `ticks_in_light >= MIN_GREEN_TICKS - 1`.

Run `make`. TESTS 3 through 7 should pass. TESTS 5, 6, and 7 press the button during red,
during yellow, and on the very last tick of red. All three check that the next green still
gets its full 12 ticks.

If TEST 4 fails and says green lasted 12 ticks when it should have been 4, the button press
is getting forgotten. Go back to the "remembering something" section of Lesson 2. Working
this out yourself is the point of the exercise, so it's worth the effort.

### Round 4: everything passes

```bash
make
```

The test prints nine numbered tests, which together make fifteen checks. You're done when
the end of the output says:

```
  ALL 15 CHECKS PASSED
```

---

## When a test fails, look at the waveform

The test output tells you *what* is wrong. The waveform tells you *why*.

```bash
make wave
```

In GTKWave, click `tb_traffic_light`, then `dut`, and add `clk`, `rst_n`, `ui_in`, `current_light`,
`ticks_in_light`, and `uo_out`. Find the moment the test complained about, and look at what `current_light`
and `ticks_in_light` are doing right there. (On a Mac, see the [Surfer quick guide](../../setup/README.md#surfer-quick-guide-mac).)

Most of the time, the bug is obvious within a few seconds once you're looking at the right
tick.

---

## Take your screenshot

Once all fifteen checks pass, you still need `waveform.png`.

In GTKWave, set up a view that shows at least one full green-yellow-red cycle and one
pedestrian button press, with `current_light`, `ticks_in_light`, and the light outputs visible. Make sure
the signal names are readable. Take a screenshot and save it in your submission folder as
`waveform.png`.

> **How to screenshot:** on Windows, press Windows+Shift+S and drag a box. On a Mac, press
> Cmd+Shift+4 and drag a box. Then save the image into your submission folder. On Windows,
> your Ubuntu files show up in File Explorer under **Linux** in the left sidebar. On a Mac,
> the screenshot lands on your Desktop. Move it into your folder with
> `mv ~/Desktop/Screenshot*.png waveform.png`.

---

## Write it up

Copy the template into your folder:

```bash
cp ../../../digital-design/submission-template/WRITEUP.md .
```

Open it and answer the questions in your own words, 300 to 500 words total. The most
important question is **"what broke, and how did you figure out what was wrong?"**

Be honest and specific there. "Nothing broke" is a weak answer. Being able to describe how
you tracked down a bug matters more in this club than getting it right the first time.

---

## Check yourself before you submit

```bash
make check
```

This runs the same checks a lead does: all your files are there, the design compiles, all
fifteen checks pass, and the write-up is long enough with no template text left in it.

Keep fixing things until it says `READY TO SUBMIT`.

---

## If you finish early

These are optional and don't earn extra credit, but they're the natural next questions:

1. **Add a second road.** Two lights that must never both be green at the same time. Every
   real traffic controller has to solve this.
2. **Night mode** on `ui_in[1]`: red blinks on and off, and nothing cycles.
3. **Make the timing adjustable** from `uio_in` instead of fixed `localparam`s. Then think
   about how many more gates that costs.

---

**Next:** [Lesson 4: Turn in your work](04-submit.md).
