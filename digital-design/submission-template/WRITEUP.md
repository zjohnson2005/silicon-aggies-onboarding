# Block 1 write-up: YOUR NAME

*Delete these instructions (the lines in italics) before you submit. Aim for 300 to 500
words total. Write it in your own words. A lead can tell when it's paraphrased from the
lesson, and a paraphrase doesn't teach you anything.*

## How my state machine works

*Walk through your state diagram in words. What are the states, what moves you between
them, and what does each one turn on? Two or three sentences per state is plenty.*

<your answer here>

## Handling the button press

*The button is only high for one clock tick. Why can't you just check `button_pressed` inside
the GREEN state? What did you do instead?*

<your answer here>

## What MIN_GREEN_TICKS protects against

*Why is it there? What would go wrong without it?*

<your answer here>

## What broke, and how I found it

*This is the most important section. Pick one specific bug you hit. What did you see go
wrong? How did you track it down: did a test message point at it, did you spot it in the
waveform, or did you just reread your code? What was the actual cause?*

*"Nothing broke" is a weak answer. If everything worked the first time, say what you would
have checked first if it hadn't.*

<your answer here>

## Anything else

*Optional. Stretch goals you tried, something you're unsure about, or something you'd do
differently next time. If you skip it, delete this whole section, heading included.*

<your answer here>
