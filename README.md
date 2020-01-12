# Windeye

Windeye is a "light" dynamic window manager for Windows 10. It aims to
improve the windows management capabilities of Windows — primarily by
introducing automatic tiling and keyboard navigation — without
altering Windows's own functionality.

## Features

- Move focus between windows using using only the keyboard

- Resize and move windows using only the keyboard

- Automatically tile windows

- Move windows between virtual desktops

- Vi-like keybindings for navigation

## Installation

Either download the executable file and run it. Or download
[AutoHotkey](http://autohotkey.com), install it, and run
`src\Windeye.ahk` — or compile into an executable by running
`tools\Build.ahk` (for now, right-clicking and pressing `Compile Script`
also works).

Note that running the executable places `VirtualDesktopAccessor.dll` in
the executable folder.

## Usage

Use the direction keys
(<kbd>←</kbd><kbd>↓</kbd><kbd>↑</kbd><kbd>→</kbd> or
<kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd>) in combination with
the modifier keys to do the following:

- <kbd>Alt</kbd>: Move focus

- <kbd>Alt</kbd><kbd>Shift</kbd>: Move window

- <kbd>Alt</kbd><kbd>Ctrl</kbd>: (Up/Down) Maximise/minimise window; 
  (Right/Left) Tile window to the right/left

- <kbd>Alt</kbd><kbd>Ctrl</kbd><kbd>Shift</kbd>: Resize window

Beyond this, use the following key combinations:

- <kbd>Alt</kbd><kbd>x</kbd>: Untile window (if a window is moved with
  the keybindings, this also untiles that window)

- <kbd>Alt</kbd><kbd>r</kbd>: Cascade all windows on the desktop

- <kbd>Alt</kbd><kbd>n</kbd>/<kbd>b</kbd>: Next/previous desktop

- <kbd>Ctrl</kbd><kbd>Alt</kbd><kbd>n</kbd>/<kbd>b</kbd>: Move window to next/previous desktop

- <kbd>Shift</kbd><kbd>Alt</kbd><kbd>n</kbd>: Create new virtual desktop
  (identical to <kbd>Win</kbd><kbd>Ctrl</kbd><kbd>d</kbd>)

- <kbd>Alt</kbd><kbd>,</kbd>/<kbd>.</kbd>: Increase/decrease width of
  tiling area

- <kbd>Alt</kbd><kbd>z</kbd>: Cycle through the windows

- <kbd>Shift</kbd><kbd>Alt</kbd><kbd>z</kbd>: Select previous window

- <kbd>Alt</kbd><kbd>q</kbd>: Close window

- <kbd>Alt</kbd><kbd>c</kbd>/<kbd>v</kbd>: Alternative keybinding for
  <kbd>Alt</kbd>(<kbd>Shift</kbd>)<kbd>Tab</kbd>

- <kbd>Shift</kbd><kbd>Alt</kbd><kbd>r</kbd>: Reload the script

- <kbd>Shift</kbd><kbd>Alt</kbd><kbd>x</kbd>: Exit script

## Configuration

The keybindings (and some behaviour, such as how far to move a window
with each command) can be modified by editing `src\Keybindings.ahk`. In
other words, the keybindings cannot be changed in the pre-compiled
version.

## Limitations/know bugs/todo/untested

- So far I have only tested this on a single screen setup. Probably a
  multi-screen environment will not work without issues.

- Probably only supports Windows 10

- Does not detect new windows, which means these have to be tiled
  manually etc.

## Notes, questions and answers

### Why?

I wrote this mainly to satisfy my own need for better and more intuitive
window management. Windows of course has its own (dynamic) window
management, but its functionality leaves some things to be desired (eg
why can I tile windows with keyboard shortcut but not quickly select
them?).

While there already are programs such as
[bug.n](https://github.com/fuhsjr00/bug.n) — which you should
definitely try out — I found myself only using some of its
functionality: the keyboard navigation and ability to quickly
reposition windows. The other functionality I rarely used, such as the
detailed control of parent and child areas.

Windeye tries to do much less and tries to use, to the extent that it
is possible, Windows's own functionality.

### The code looks horrible

Yes, probably! I'm not a programmer and wrote this in my free time —
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

## Credits/inspiration

- <https://github.com/fuhsjr00/bug.n>

- <https://github.com/Ciantic/VirtualDesktopAccessor> 

- <https://github.com/pmb6tz/windows-desktop-switcher>

- <https://github.com/sdias/win-10-virtual-desktop-enhancer>

- <https://autohotkey.com/board/topic/80580-how-to-programmatically-tile-cascade-windows/>

## License

MIT License (see LICENSE for more information)
