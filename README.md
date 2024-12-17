# lizard
`lizard` is a sandbox-like "game" (some may call it a screen saver) of
procedurally animated creatures.
With a built-in editor, it's simple to make new critters to run around your
screen.

## Actually running this thing
`lizard` is built using the Löve game framework, so you'll need to install that
first (https://love2d.org/)
For Linux you just need to run `love .` from the source directory, for Windows
follow the steps on https://love2d.org/wiki/Game_Distribution
I currently only tested it on Linux, so if you encounter problems when running
it please tell me

## What can you do though?
### The main menu screen
This is the first thing you'll see after running, it's just there to get you to
the other options (there's a little creature running around already though)

### Start
Clicking this will create 10 random creatures on the screen and make them run
around like dummies, it's probably the simplest part right now.
Press `escape` for options

### Options
As of now the only options are to either disable certain creatures from
spawning, or to toggle fullscreen view.
Disabling creatures will not delete the already existing creatures, it will only
prevent more from being created.

### Editor
This is the place to create new creatures.
There are 2 main modes, and 1 sub-mode.
The main modes are part, and leg.
Part will let add more body-parts to the current creature, while Leg will
add legs.
The sub-mode - size, will determine how large the added part/leg will be.
You can switch between part and leg mode by clicking the `Change mode` button
(this will only let you switch if you are not in `size` submode).
Be warned though, the legs are attached to the last created body part.

Next you can rename your creature, by clicking the `Rename` button - by
default, all newly made creatures are named default.

When you're done creating your creature, you can `Save` it - if another
creature of that name exists, you will be asked if you want to overwrite it.

If you're not happy with what you've created, you can just start over by
pressing the `New` button.
