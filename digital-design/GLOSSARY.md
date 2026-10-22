# Glossary

Every term used in Block 1, in plain language.

---

**Active low:** a signal that means "do it" when it's 0, not 1. These usually end in `_n`,
like `rst_n`. Reset happens when `rst_n` is 0.

**`always @(posedge clk)`:** a block of Verilog that runs once on every rising edge of the
clock. Anything that needs to remember a value goes here.

**Blocking and nonblocking (`=` and `<=`):** two kinds of assignment. Inside a clocked block,
always use `<=`. See [Lesson 0](lessons/00-verilog-primer.md).

**Clock:** a signal that goes 0, 1, 0, 1 forever at a steady rate. Everything in a
synchronous design moves in step with it.

**Combinational logic:** logic with no memory. Its output depends only on its inputs right
now. An AND gate is combinational. `assign` describes combinational logic.

**Edge, rising edge, posedge:** the moment a signal goes from 0 to 1. Flip-flops grab their
input at that instant.

**Flip-flop:** the basic memory element. It holds one bit and updates on the clock edge.

**FSM (finite state machine):** hardware that is always in exactly one of a small set of
states and moves between them based on conditions. See
[Lesson 2](lessons/02-state-machines.md).

**GTKWave:** the program that shows waveforms from a `.vcd` file.

**Icarus Verilog (`iverilog`):** the simulator for Block 1. It compiles your Verilog and runs
it.

**Latch (as a verb):** to catch a brief signal and hold on to it until you can act on it.
It's what you do with the pedestrian button.

**`localparam`:** a named constant, like `localparam GREEN_TICKS = 12;`.

**One-hot:** a group of signals where exactly one is 1 at a time. Your three lights are
one-hot.

**PDK (process design kit):** the files a chip factory gives you describing what you're
allowed to build in their process. We use one called sky130. It comes up in Block 3.

**Pin contract:** the fixed list of ports every ASIC design uses (`ui_in`, `uo_out`,
`uio_*`, `clk`, `rst_n`, `ena`). It's the Tiny Tapeout interface.

**Pull request (PR):** how you turn in work on GitHub. It asks for your files to be added to
the main repo, and it's where a lead leaves review comments.

**Pulse:** a signal that goes to 1 for a short time (here, one clock tick) and then back to
0.

**`reg`:** a Verilog type for anything you assign inside an `always` block. It usually
becomes a flip-flop. The name is misleading, so don't read too much into it.

**Reset:** forcing the design into a known starting state. Ours is synchronous (it takes
effect on a clock edge) and active low.

**RTL (register transfer level):** the style of Verilog you're writing, which describes
hardware as registers and the logic between them.

**Sequential logic:** logic with memory, driven by a clock. The opposite of combinational
logic.

**Simulation:** running your design in software to see what it would do, before any real
hardware exists.

**Synchronous:** everything happens on clock edges. That's how our designs work.

**Synthesis:** turning your Verilog into real logic gates. That happens in Block 3.

**Testbench:** code that feeds inputs into your design and checks the outputs. It isn't part
of the chip. It only exists in simulation. We give you one in this block. You write your own
in Block 2.

**Tick:** one clock cycle. We measure the traffic light's timing in ticks.

**Tiny Tapeout:** a shared manufacturing run that puts many small designs on one chip. It's
what we submit to.

**`.vcd` (value change dump):** the file a simulation writes, recording every signal at every
moment. GTKWave reads it.

**Waveform:** a picture of signals changing over time. It's how you debug hardware.

**`wire`:** a Verilog type for a plain connection with no memory. You drive it with
`assign`.
