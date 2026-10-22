# Lesson 0: Verilog in 30 minutes

You need five ideas for this block. This lesson covers all of them. You don't run anything
yet; just read, and look closely at the code examples.

---

## The big idea first

Verilog looks like a programming language such as C or Python. It isn't one, and treating
it like one is where most beginner confusion comes from.

When you write Python, you write a list of steps that happen one after another. When you
write Verilog, you describe **hardware**: a circuit that already exists, where every part
runs at the same time. Each line you write becomes a piece of circuitry that is always
there, always doing its job, in parallel with every other line.

So there's no "do this, then do that." There's "this wire is connected to that gate" and
"this flip-flop does this on every clock tick." Keep that in mind as you read the rest.

---

## 1. A module is a box with wires

```verilog
module my_thing (
    input  wire       clk,
    input  wire       a,
    output wire       y
);
    // the insides go here
endmodule
```

A module has a name and a list of **ports**, which are the wires going in and out. That's
the box. Everything between `module` and `endmodule` is what's inside it.

In this block you don't choose the ports. Every ASIC design uses the same port list,
because it's the pin layout of the real chip we're taping out:

```verilog
module tt_um_traffic_light (
    input  wire [7:0] ui_in,     // 8 input pins
    output wire [7:0] uo_out,    // 8 output pins
    input  wire [7:0] uio_in,    // 8 more that can go either way (not used here)
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,       // "your design is switched on"
    input  wire       clk,       // the clock
    input  wire       rst_n      // reset, active LOW (see below)
);
```

`[7:0]` means "8 wires bundled together," numbered 7 down to 0. `ui_in[0]` is the lowest
one.

The `_n` at the end of `rst_n` means **active low**. The signal normally sits at 1, and
reset happens when it drops to **0**. This trips everyone up at least once. It's a common
hardware convention.

---

## 2. `wire` and `reg`

There are two ways to hold a value.

A **`wire`** is like a piece of metal. It doesn't remember anything. Its value is whatever
is driving it right now. You drive a wire with `assign`:

```verilog
wire alarm;
assign alarm = too_hot | too_loud;    // alarm always equals this
```

That `assign` isn't something that happens once. It's a permanent connection. If `too_hot`
changes, `alarm` changes right away, with no clock involved.

A **`reg`** can remember a value. Usually it becomes a flip-flop. You set a `reg` inside an
`always` block:

```verilog
reg [3:0] count;

always @(posedge clk) begin
    count <= count + 1;
end
```

`reg` is a confusing name, so don't read too much into it. The rule to remember: **if you
assign to something inside an `always` block, declare it as `reg`.**

---

## 3. `always @(posedge clk)` is where memory lives

```verilog
always @(posedge clk) begin
    // this happens once, on every rising edge of the clock
end
```

Read it as "every time the clock goes from 0 to 1, do this." It's how you build anything
that remembers what happened last tick, like a counter or a state machine.

Reset goes inside it like this:

```verilog
always @(posedge clk) begin
    if (!rst_n) begin
        count <= 0;              // reset: force it to a known value
    end else begin
        count <= count + 1;      // normal operation
    end
end
```

`!rst_n` means "rst_n is 0," which is when reset is happening. You can read the line as
"if we're being reset."

---

## 4. `<=` versus `=`

Inside `always @(posedge clk)`, **always use `<=`. Never use `=`.**

`<=` is called a nonblocking assignment. It means "at this clock edge, this becomes that."
Every `<=` in the block happens at the same moment, using the values from *before* the
edge.

Here's why that matters:

```verilog
always @(posedge clk) begin
    b <= a;
    c <= b;
end
```

With `<=`, `c` gets the **old** value of `b`, from before this clock edge. That builds two
flip-flops in a row, which is a shift register. That's what you'd draw, and it's correct.

If you used `=` instead, `c` would get the **new** `b`, which is just `a`. You'd get one
flip-flop, with `b` and `c` as copies of each other. That's not what you drew, and it can
even simulate differently from how the real chip behaves.

The rule is simple: `<=` inside `always @(posedge clk)`, every time.

---

## 5. `case` for state machines

A `case` statement picks one branch based on a value:

```verilog
case (current_light)
    GREEN: begin
        // what to do while green
    end
    YELLOW: begin
        // what to do while yellow
    end
    RED: begin
        // what to do while red
    end
    default: begin
        // anything not listed above
    end
endcase
```

**Always include a `default`.** In simulation it hardly matters. In a real chip, a glitch
can knock the circuit into a state you never planned for. Without a `default`, it can get
stuck there forever. Point `default` back to a safe state.

---

## Two more things you'll see

**`localparam`** is a named constant. Use them instead of typing the same number in many
places:

```verilog
localparam GREEN_TICKS = 12;
localparam GREEN    = 2'b00;
```

`2'b00` means "a 2-bit number, written in binary, with value 00." The format is width, then
`'`, then the base, then the value. So `8'd255` is 8 bits, decimal, 255, and `4'hF` is 4
bits, hexadecimal, F.

**Comparisons** work the way you'd expect: `==`, `!=`, `<`, `>=`. For single true/false
values, the logic operators are `&&` (and), `||` (or), and `!` (not). When you're working
on every bit of a bundle, use `&`, `|`, and `~` instead.

---

## That's all you need for now

There's a lot more Verilog out there, but these five ideas cover everything in this block
and most of what you'll write in the next two.

One habit worth starting now: when you write a line, ask yourself what hardware it builds.
`assign y = a & b;` is an AND gate, a physical thing on the chip with two inputs and one
output. `count <= count + 1;` is a register plus an adder. If you can't say what a line
builds, it's probably wrong.

---

**Next:** [Lesson 1: Your first simulation](01-first-simulation.md), where you run
something for real.
