# Skywatcher

Tool to display and edit `.fezsky.json` files for the game FEZ.

![skywatcher_preview](https://github.com/kaprosdev/FEZ-Skywatcher/assets/7116426/4efbddd8-bc75-4202-9c4e-eafff5a19385)

My goal for this is to roughly document how skies are put together in the game, eventually integrating these tools into some larger "Swiss Army Knife" application for FEZ modding.  
Until then, this works pretty well standalone for editing FEZ skies - much better than reopening the game after every change.

## Features
- Modify `.fezsky.json` files using a graphical interface
- Preview (most) changes made in a live-updating preview window
- Load textures into a library and pick them directly - avoiding confusion from typos
- Saves to and loads from [FEZRepacker](https://github.com/FEZModding/FEZRepacker)'s sky folder structure, which can be loaded into the game as a [HAT](https://github.com/FEZModding/HAT) asset mod

## Todo
- Clouds aren't reflected in previews yet.
- Wind (including the kind that affects background layers) isn't implemented yet.
- Shadows aren't reflected in previews yet (and I'm taking suggestions on how to even do so).

## Known limitations
- The preview is inexact - it's *close* to how the sky will look in-game, but don't expect it to line up just right.

## Intentional limitations
- No texture editing in the app - import your textures and select them.
	- A "replace this texture" or "live-reload textures" option might happen, but making a pixel editor is a bit out of scope for this project.
- Effects hardcoded to skies with specific names aren't be implemented in the preview.
	- Includes:
		- `INDUS_CITY` glitchy flickering effect
		- `OBS_SKY` altered star opacity range
		- `OBS_SKY` "special background layer on only one side" hack
	- Ideally there's a helper mod that allows modded skies to use these features before implementing them in the editor
