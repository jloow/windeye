# Windeye

Windeye is a light dynamic window manager for Windows 10. It aims to
improve the windows management capabilities of Windows --- primarily by
introducing automatic tiling and keyboard navigation --- without
altering Windows's own functionality.

## Features

- Move focus between windows using using only the keyboard

- Resize and move windows using only the keyboard

- Automatically tile windows

- Move windows between virtual desktops

## Installation

Either download the executable file and run it. Or download AutoHotkey
and run `src\Windeye.ahk` or compile into an executable by running
`tools\Build.ahk`.

Note that running the executable places `VirtualDesktopAccessor.dll` in
the executable folder.

## Usage

Use the direction keys
(<kbd>←</kbd><kbd>↓</kbd><kbd>↑</kbd><kbd>→</kbd> or
<kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd>) in combination with
the modifier keys to do the following:

- <kbd>Alt</kbd>: Move focus

- <kbd>Alt</kbd><kbd>Shift</kbd>: Move window

- <kbd>Alt</kbd><kbd>Ctrl</kbd> + Up/Down: Maximise/minimise window

- <kbd>Alt</kbd><kbd>Ctrl</kbd> + Right/Left: Tile window to the
  right/left

- <kbd>Alt</kbd><kbd>Shift</kbd><kbd>Ctrl</kbd>: Tile window to the
  right/left

Beyond this, use the following key combinations:

- <kbd>Alt</kbd><kbd>x</kbd>: Untile window (if a window is moved with
  the keybindings, this also untiles that window)

- <kbd>Alt</kbd><kbd>r</kbd>: Cascade all windows on the desktop

- <kbd>Alt</kbd><kbd>.</kbd>/<kbd>,</kbd>: Increase/decrease window
  transparency

- <kbd>Alt</kbd><kbd>n</kbd>/<kbd>b</kbd>: Next/previous desktop

- <kbd>Ctrl</kbd><kbd>Alt</kbd><kbd>n</kbd>/<kbd>b</kbd>: Move window to next/previous desktop

- <kbd>Shift</kbd><kbd>Alt</kbd><kbd>n</kbd>: Create new virtual desktop
  (identical to <kbd>Win</kbd><kbd>Ctrl</kbd><kbd>d</kbd>)

- <kbd>Alt</kbd><kbd>q</kbd>: Close window

- (<kbd>Shift</kbd>)<kbd>Alt</kbd><kbd>f</kbd>: Remove (restore) decoration from
  window

- <kbd>Alt</kbd><kbd>c</kbd>: Alternative keybinding for
  <kbd>Alt</kbd><kbd>Tab</kbd>

- <kbd>Shift</kbd><kbd>Alt</kbd><kbd>r</kbd>: Reload the script

- <kbd>Shift</kbd><kbd>Alt</kbd><kbd>x</kbd>: Exit script

## Configuration

The keybindings (and some behaviour, such as how far to move a window
after each command) can be modified by editing `Keybindings.ahk`. That
is, currently you cannot change the keybindings when using the
pre-compiled version.

## Limitations/know bugs/todo/untested

- So far I have only tested this on a single screen setup. Probably a
  multi-screen environment will not work without issues.

- Probably only supports Windows 10

## Notes, questions and answers

### Why?

I wrote this mainly to satisfy my own need for better and more intuitive
window management. Windows of course has its own (dynamic) window
management, but its functionality leaves some things to be desired (eg
why can I tile windows with keyboard shortcut but not quickly select
them?).

While there already are programs such as `bug.n` --- which is impressive
--- I found it a bit excessive; I would have preferred to have keyboard
navigation and the ability to quickly reposition windows without all the
options that `bug.n` comes with. (It is furthermore based in `dwm` which
is quite esoteric.) It also replaces Windows's own functionality with
its own. This, I think, leads to a slower program.

`Windeye` tries to do much less and tries to use, to the extent that it
is possible, Windows's own functionality.

### The code looks horrible

Yes, probably! I'm not a programmer and wrote this in my free time ---
I'm just learning as I go. Suggestions for improvement are welcome.

### The name?

The word "window" comes from the Old Norse word "vindauga", which
literally means "wind-eye".

### Why not use the Windows-key?

This was my original intention, but <kbd>Win</kbd><kbd>L</kbd> locks
Windows. It is possible to disable this functionally, but then Windows
cannot be locked at all. If you are fine using the arrow keys (instead
of the vi-like keybindings), then the keys can be rebound using the
Windows-key.

## Credits


## License

MIT License (see LICENSE for more information)
