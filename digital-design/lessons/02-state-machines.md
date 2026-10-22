# Lesson 2: State machines

One idea, and then you draw your design on paper before you write any code.

---

## The idea

A **state machine** is hardware that is always in exactly one of a small number of
situations, and moves between them when something happens.

You already know plenty of them. A microwave is off, cooking, or paused. A vending machine is
waiting for money, holding part of a payment, or giving you your snack. A traffic light is
green, yellow, or red.

A state machine has three parts:

- **States:** the situations it can be in. It's in exactly one at a time.
- **Transitions:** what makes it move from one state to another.
- **Outputs:** what it does while it's in each state.

## What it looks like in hardware

In hardware, a state machine is a register that remembers which state you're in, some
logic that decides the next state, and some logic that drives the outputs. Nearly every
control circuit ever built looks like this, including the ones in the chip we're taping
out.

In Verilog:

```verilog
localparam GREEN  = 2'b00;      // give each state a name
localparam YELLOW = 2'b01;
localparam RED    = 2'b10;

reg [1:0] current_light;                  // the register that remembers the current state

always @(posedge clk) begin
    if (!rst_n) begin
        current_light <= RED;           // reset always lands in a known state
    end else begin
        case (current_light)
            GREEN:  if (something) current_light <= YELLOW;
            YELLOW: if (something) current_light <= RED;
            RED:    if (something) current_light <= GREEN;
            default:                 current_light <= RED;
        endcase
    end
end

assign uo_out[2] = (current_light == GREEN);   // outputs come FROM the state
```

Look at the last line. **The outputs come from the state; they aren't stored separately.**
If you kept a separate `green` register and updated it by hand in each branch, sooner or
later you'd miss one and end up with two lights on at once.

## The timer

A traffic light doesn't change because something happened. It changes after a certain
amount of time. So you need a counter running next to the state:

```verilog
reg [4:0] ticks_in_light;
```

The pattern: on every tick, either the timer goes up by one, or you change state and set
the timer back to zero.

```verilog
YELLOW: begin
    if (ticks_in_light == YELLOW_TICKS - 1) begin
        current_light <= RED;
        ticks_in_light <= 5'd0;          // reset the timer on the way out
    end else begin
        ticks_in_light <= ticks_in_light + 5'd1;
    end
end
```

**Every path that changes state has to clear the timer too.** If you miss one, the light
behaves for one cycle and then goes haywire. This is the most common bug in the project.

Why `YELLOW_TICKS - 1`? Because the timer starts at 0. Counting 0, 1, 2, 3 is four ticks.
If you compare against `YELLOW_TICKS` itself, you get five. Off-by-one mistakes here are
normal, and the waveform shows them right away.

## Remembering something that only lasts an instant

This is the part of the project that takes real thought.

The pedestrian button is a **one-tick pulse**. Someone presses it, it's 1 for one clock
tick, and then it's gone. It could arrive while the light is yellow, or red, or on the very
first tick of green.

So this doesn't work:

```verilog
GREEN: begin
    if (button_pressed) ...      // WRONG
end
```

By the time the light is ready to act on the press, the pulse is long over. This code only
catches a press if it happens on the exact tick you're checking.

You have to **remember** the press:

```verilog
reg walk_requested;                       // "somebody pressed, and we owe them a walk"

always @(posedge clk) begin        // your ONE always block, the same one as the state machine
    if (!rst_n) begin
        ...
    end else begin
        if (button_pressed) walk_requested <= 1'b1;    // catch the press whenever it arrives
        // ... and clear it somewhere, once you've given them their walk
        case (current_light)
            ...
        endcase
    end
end
```

Keep this inside the same `always` block as your state machine, not in a second one. If two
`always` blocks both assign `walk_requested`, the simulator picks one of them unpredictably, and
the synthesis tool that builds the chip rejects it outright.

Now the state machine checks `walk_requested`, which stays 1 until you clear it, instead of
`button_pressed`, which disappears after one tick.

This is the main lesson of the project. Catching a brief event and holding onto it until
you can deal with it comes up in almost every design you'll ever build. It's called
**request latching**, and after this project you'll have done it once.

The question left over is *where* to clear `walk_requested`. That one is yours to figure out.

---

## Now draw yours

Get a piece of paper and a pen.

1. Draw three circles and label them GREEN, YELLOW, and RED.
2. Draw arrows between them for each transition.
3. On each arrow, write what causes that transition.
4. Inside each circle, write which outputs are on.

Then answer these four questions on the same page:

1. **What makes GREEN go to YELLOW?** There are two separate reasons. Write both.
2. **Where does `walk_requested` get cleared?** Mark the spot.
3. **Which state does reset go to?**
4. **What is `walk` doing in each state?**

Take a photo of it and save it as `state-diagram.jpg` in your submission folder. It's a
required deliverable, and it's the first thing a lead looks at when reviewing your work.

It can feel like busywork. It isn't. People who skip the drawing and go straight to typing
usually end up writing their state machine twice. Ten minutes with a pen saves an hour at
the keyboard.

---

**Next:** [Lesson 3: Build the traffic light](03-build-it.md). Now you write code.
