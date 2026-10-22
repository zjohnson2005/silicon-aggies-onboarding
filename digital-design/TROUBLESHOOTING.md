# Troubleshooting (Block 1)

Look for your error here before you ask in the GroupMe. It's probably below.

If it isn't, post the command you ran, the full error text (copy and paste it, don't send a
photo), and your operating system.

**The most useful habit:** when you get a long list of errors, read only the **first** one.
The rest are usually side effects of it. Fix the first one and run again.

---

## Tools won't install or run

**`iverilog: command not found`**
Either it isn't installed, or you're in the wrong window. On Windows, every command goes
in the Ubuntu window, never PowerShell or Git Bash. See the [setup guide](../setup/README.md),
Part B.

**`make: command not found`**
On Ubuntu or WSL, run `sudo apt install make`. On a Mac, run `xcode-select --install`, which
installs Apple's developer tools, including `make`. (Don't use `brew install make`. Homebrew
installs it under the name `gmake`, so `make` still won't be found.)

**`make: *** No rule to make target`**
You're not in your submission folder, or the starter files didn't get copied. Run `ls`. If
you don't see `Makefile`, go back to Step 1 of [Lesson 1](lessons/01-first-simulation.md).

**GTKWave won't install or open on a Mac**
Homebrew no longer offers GTKWave for Mac. Use Surfer instead: `brew install surfer`, then
`surfer traffic.vcd &` (or `make wave`, which opens Surfer when GTKWave isn't there).

**GTKWave won't open (Windows 10)**
Windows 10 can't open Linux windows without extra setup. You can install VcXsrv, but the
easier fix is to skip GTKWave and open your `.vcd` file in [Surfer](https://surfer-project.org/) in
your browser. It shows the same waveform.

**Everything is very slow (Windows)**
You're probably working under `/mnt/c/`, which is your Windows drive. Move your work to the
Linux side, in `~/silicon-aggies-onboarding`. The tools run much slower across that
boundary, and some stop working.

---

## Compile errors

**`syntax error` on a line that looks fine**
The mistake is almost always on the line *before* the one it points to: a missing `;` at
the end of a statement, or a `begin` without a matching `end`. Look one or two lines up.
Also check that you're running `make`, not typing the `iverilog` command yourself, so you
get the same settings as everyone else.

**`Could not find variable` or `Unable to bind wire/reg/memory`**
There's a typo in a signal name, or you used a signal you never declared. Verilog cares about
capital letters: `walk_requested` and `walk_Requested` are two different signals.

**`Unknown module type: tt_um_traffic_light`**
The module name at the top of your design file changed. It has to be exactly
`module tt_um_traffic_light (`.

**`... is not a valid l-value`** or **`cannot perform procedural assignment to a net`**
You assigned to something declared as `wire` inside an `always` block. Declare it as `reg`
instead.

**`port not connected` warnings**
Usually harmless here. If it's a port you meant to use, check the spelling.

---

## Simulation problems

**`TIMEOUT: the light never reached a state the test was waiting for`**
Your light never turns green, or gets stuck in some state. If you just copied the starter
file, that's expected. Fill in the TODOs. If you've written code, the last `TEST` line
printed before the timeout is the one that got stuck. Open the waveform and check:

- Does `ticks_in_light` or `current_light` show `x`? Then your reset doesn't set it. `current_light`, `ticks_in_light`, and
  `walk_requested` all need a line in the `if (!rst_n)` branch.
- Does every state have a way out, and do you clear the timer on every transition?

**Everything shows as `x` in the waveform, forever**
A `reg` never gets a value, usually because it's missing from reset. Every `reg` needs a
line in the `if (!rst_n)` branch.

**TEST 2 fails with timing off by one** (green is 11 or 13 instead of 12)
Check the `- 1`. The timer starts at 0, so counting to `GREEN_TICKS - 1` gives exactly
`GREEN_TICKS` ticks. Comparing against `GREEN_TICKS` gives one tick too many.

**The light flickers quickly between two states**
Somewhere you changed state but didn't clear the timer. Every transition needs `ticks_in_light <= 0`.

**TEST 4 fails ("an early press is REMEMBERED...") and green lasted 12**
The button press is getting lost. Somewhere you're checking `button_pressed` directly instead of
`walk_requested`. The pulse only lasts one tick. Reread the "remembering something" section of
[Lesson 2](lessons/02-state-machines.md).

**TEST 3 fails: a press in the middle of green doesn't end green early**
Either it's the same problem as TEST 4, or your GREEN state only checks the timer. It needs
two ways out: the timer ran out, **or** a request is waiting and the minimum green time has
passed.

**TEST 5 or TEST 6 fails: a press during red or yellow shortens the next green**
`walk_requested` isn't being cleared during RED, so it's still set when green starts.

**TEST 7 fails: a press on the last tick of red shortens the next green**
Your clearing works, but on the last tick of red the press wins. Look at the order of the
two lines that set and clear `walk_requested`. When two `<=` assignments to the same signal happen
on the same clock edge, the one written **later** in the block wins. On that tick, the
press sets `walk_requested` and the RED state clears it. Which one do you want to win?

If the line that sets `walk_requested` is in a **different** `always` block from the line that clears
it, the order of the lines doesn't decide anything, and neither does anything else you can
control. Move both into your one `always` block.

**TEST 8 fails: a reset in the middle of a run**
Your reset only works at the very start. Check that `if (!rst_n)` is the first thing in your
`always` block, outside the `case`, so it wins no matter what state you're in. If red lasts
the wrong number of ticks after the reset, your reset isn't clearing `ticks_in_light`.

**TEST 9 fails: walk doesn't match red**
`walk` has to be on for every tick of RED and off for every tick of GREEN and YELLOW. Drive
it straight from `current_light`, the same way as the lights: `assign uo_out[3] = (current_light == RED);`

**TEST 9 fails: more or fewer than one light on**
Two lights are on at once, or none are. This almost always means the outputs are stored in
their own registers instead of coming from `current_light`. Drive them like
`assign uo_out[2] = (current_light == GREEN);` and this problem can't happen.

**Results change between runs**
That shouldn't happen here. If it does, you probably mixed `=` and `<=` in a clocked block.
Use `<=` everywhere inside `always @(posedge clk)`.

---

## Waveform problems

These fixes are written for GTKWave. On a Mac, the [Surfer quick guide](../setup/README.md#surfer-quick-guide-mac) has
the Surfer version of each one.

**The GTKWave window is empty**
You opened it but haven't added any signals yet. Click the module in the top-left panel,
select signals in the panel below, and click **Append**. Then press Shift+Alt+F to zoom so
everything fits.

**There's no `.vcd` file**
Run `make` first. The simulation has to run before there's a waveform to look at.

**The waveform is a solid block of color**
You're zoomed out too far. Press Shift+Alt+F, then zoom in with the magnifying glass
buttons.

**I changed my design but the waveform looks the same**
GTKWave doesn't notice new results on its own. Run `make` again, then press Ctrl+Shift+R in
GTKWave to reload.

---

## Git and GitHub

**`git push` asks for a password, then rejects it**
GitHub stopped accepting account passwords for this. Run `gh auth login` (see Part A4 of
the [setup guide](../setup/README.md)), then push again.

**`git push` says "rejected" or "does not appear to be a git repository"**
You might be pushing to the main repo instead of your fork. Run `git remote -v`. The
`origin` lines should have *your* username in them. If they don't, redo Part A6 of the
setup guide.

**`git status` shows thousands of files**
You're about to commit simulation output. Make sure you're running git from
`~/silicon-aggies-onboarding`, and that the `.gitignore` file is there (`ls -a` shows it).

**I committed to `main` by accident**
That's fixable. Ask in the GroupMe and a lead will walk you through moving it to a branch.
Don't try commands you found online. That's how small problems turn into big ones.

---

## Still stuck?

Ask in the GroupMe with the command you ran, the full error text, and your operating system.

Nobody here will think less of you for asking. Most of us hit every error on this page
when we started.
