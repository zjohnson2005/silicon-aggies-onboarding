# ASIC Block 1
#
#   make          compile and run the tests
#   make wave     open the waveform in GTKWave (or Surfer on a Mac)
#   make warmup   run the Lesson 1 blinker instead
#   make check    check that you have everything you need to turn in
#   make clean    delete generated files

DESIGN = tt_um_traffic_light.v
TB     = tb_traffic_light.v

.PHONY: all sim wave warmup check clean

all: sim

sim: $(DESIGN) $(TB)
	@iverilog -g2012 -o sim.out $(TB) $(DESIGN)
	@./sim.out

wave: traffic.vcd
	@if command -v gtkwave >/dev/null 2>&1; then gtkwave traffic.vcd & \
	elif command -v surfer >/dev/null 2>&1; then surfer traffic.vcd & \
	else echo "No waveform viewer found. Open traffic.vcd at https://surfer-project.org/"; fi

traffic.vcd: sim

warmup: blinker.v tb_blinker.v
	@iverilog -g2012 -o blink.out tb_blinker.v blinker.v
	@./blink.out

check:
	@python3 check.py

clean:
	@rm -f *.out *.vcd
	@echo "cleaned"
