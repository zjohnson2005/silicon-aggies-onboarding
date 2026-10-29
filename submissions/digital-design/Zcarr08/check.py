#!/usr/bin/env python3
"""
ASIC Block 1 submission checker.

Run this before you open your pull request:

    make check

It checks the same things a lead checks, so you can fix problems before
anyone else sees them. It does not grade you and it does not send anything
anywhere. It just runs on your machine and prints a list.
"""

import glob
import os
import re
import subprocess
import sys

OK = "  [ok]     "
NO = "  [MISSING]"
BAD = "  [PROBLEM]"

problems = []


def ok(msg):
    print(OK + msg)


def missing(msg, why):
    print(NO + " " + msg)
    problems.append(why)


def bad(msg, why):
    print(BAD + " " + msg)
    problems.append(why)


def find(patterns):
    """Return the first file matching any of these glob patterns."""
    for p in patterns:
        hits = glob.glob(p)
        if hits:
            return hits[0]
    return None


def wrong_case(name):
    """If `name` is missing but a file with the same name in different capitals
    exists (writeup.md, Waveform.PNG), return that file's name."""
    stem = name.lower().split(".")[0]
    for f in os.listdir("."):
        if f != name and f.lower().split(".")[0] == stem:
            return f
    return None


def name_problem(expected, found):
    bad(
        f"found {found}, but it has to be named {expected}",
        f"Rename {found} to {expected}. Leads look for files by their exact names.",
    )


print()
print("=" * 55)
print("  Block 1 submission check")
print("=" * 55)
print()

# ================================================================ files
print("FILES")

design = find(["tt_um_traffic_light.v"])
if design:
    ok("tt_um_traffic_light.v")
else:
    missing("tt_um_traffic_light.v", "Your design file is not in this folder.")

diagram = find(["state-diagram.*", "state_diagram.*"])
if diagram and diagram.lower().endswith((".jpg", ".jpeg", ".png")):
    ok(f"state diagram ({diagram})")
elif diagram:
    bad(
        f"{diagram} isn't a .jpg or .png",
        f"GitHub can't show {diagram} in a pull request. Save the photo as .jpg or "
        ".png (on an iPhone: Settings, Camera, Formats, Most Compatible, or "
        "screenshot the photo).",
    )
elif wrong_case("state-diagram.jpg"):
    name_problem("state-diagram.jpg (or .png)", wrong_case("state-diagram.jpg"))
else:
    missing(
        "state-diagram.jpg / .png",
        "No state diagram. Photograph the one you drew and save it here.",
    )

wave = find(["waveform.*"])
if wave:
    ok(f"waveform screenshot ({wave})")
elif wrong_case("waveform.png"):
    name_problem("waveform.png", wrong_case("waveform.png"))
else:
    missing(
        "waveform.png",
        "No waveform screenshot. Run `make wave`, then screenshot GTKWave.",
    )

writeup = find(["WRITEUP.md"])
if writeup:
    words = len(open(writeup, encoding="utf-8", errors="ignore").read().split())
    if words < 250:
        bad(
            f"WRITEUP.md is only {words} words",
            f"Your write-up is {words} words. The target is 300-500.",
        )
    else:
        ok(f"WRITEUP.md ({words} words)")

    text = open(writeup, encoding="utf-8", errors="ignore").read()
    # Look for text that only exists in the template. (Don't look for "TODO": you
    # might fairly write about "TODO 2" from the starter file.)
    leftovers = []
    if "<your answer" in text.lower():
        leftovers.append("<your answer here>")
    flat = " ".join(text.split())
    if "*Delete these instructions" in flat:
        leftovers.append("the instructions at the top")
    template_phrases = [
        "Walk through your state diagram in words",
        "The button is only high for one clock tick",
        "Why is it there? What would go wrong without it?",
        "This is the most important section",
        "is a weak answer. If everything worked the first time",
        "Optional. Stretch goals you tried",
    ]
    if any(phrase in flat for phrase in template_phrases):
        leftovers.append("the italic instructions under the headings")
    if "YOUR NAME" in text:
        leftovers.append("YOUR NAME in the title")
    if leftovers:
        bad(
            "WRITEUP.md still has template text in it: " + ", ".join(leftovers),
            "Your write-up still has template text in it. Replace or delete it "
            "(including any optional section you skipped).",
        )
elif wrong_case("WRITEUP.md"):
    name_problem("WRITEUP.md", wrong_case("WRITEUP.md"))
else:
    missing("WRITEUP.md", "No write-up. Copy the template and fill it in.")

print()

# ================================================================ build
print("BUILD AND TEST")

if design:
    code = open(design, encoding="utf-8", errors="ignore").read()
    code = re.sub(r"//[^\n]*", "", code)                   # ignore comments
    code = re.sub(r"/\*.*?\*/", "", code, flags=re.DOTALL)
    n_always = len(re.findall(r"\balways\b", code))
    if n_always > 1:
        bad(
            f"your design has {n_always} always blocks",
            "Use ONE always @(posedge clk) block, like the starter file says. If two "
            "blocks assign the same register, the chip tools reject the design.",
        )

if not design:
    bad("cannot run tests without a design file", "Design file missing, skipped tests.")
else:
    build = subprocess.run(
        ["iverilog", "-g2012", "-o", "check.out", "tb_traffic_light.v", design],
        capture_output=True,
        text=True,
    )
    if build.returncode != 0:
        bad("design does not compile", "Your design does not compile. Run `make` to see the errors.")
        print()
        print(build.stderr.strip()[:800])
    else:
        ok("compiles with no errors")

        try:
            run = subprocess.run(["./check.out"], capture_output=True, text=True, timeout=120)
            out = run.stdout
        except subprocess.TimeoutExpired:
            out = "TIMEOUT"

        n_pass = out.count("[PASS]")
        n_fail = out.count("[FAIL]")

        if "TIMEOUT" in out:
            bad(
                "simulation timed out",
                "The simulation hung. Your design never reaches a state the test waits for.",
            )
        elif n_fail == 0 and n_pass >= 15:
            ok(f"all {n_pass} behavior checks pass")
        else:
            bad(
                f"{n_pass} checks pass, {n_fail} fail",
                f"{n_fail} behavior check(s) still failing. Run `make` for details.",
            )
            for line in out.splitlines():
                if "[FAIL]" in line:
                    print("           " + line.strip())

        if os.path.exists("check.out"):
            os.remove("check.out")

print()

# ================================================================ verdict
print("=" * 55)
if not problems:
    print("  READY TO SUBMIT")
    print()
    print("  Next: follow Lesson 4 (digital-design/lessons/04-submit.md)")
    print("  to make a branch, push, and open your pull request.")
else:
    print(f"  NOT READY: {len(problems)} thing(s) to fix")
    print()
    for i, p in enumerate(problems, 1):
        print(f"  {i}. {p}")
    print()
    print("  Stuck on one of these? Check digital-design/TROUBLESHOOTING.md, then ask in the GroupMe.")
print("=" * 55)
print()

sys.exit(1 if problems else 0)
