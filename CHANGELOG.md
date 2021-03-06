# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Custom icon

### Fixed

- Limit the number of options available in the right-click menu of the tray icon


## [1.0.2] - 2020-02-05

### Fixed

- Keep the rest of the cascaded windows cascaded when tiling one of them

- Reposition tiled windows before moving them to make it harder to mistake
  them for tiled windows when they are re-opened

- Randomly position window when untiling it

- Actually select previously selected window with `selectPrevious()`

- Remove ability to select minimised windows when moving focus

- Minimising and maximising windows affects tiling as expected

## [1.0.1] - 2019-12-30

### Added

- Make build file create output folder if it does not exist

### Fixed

- Improve how windows are automatically tiled when resized and moved

- Retile windows when moving them to new virtual desktops

- Automatically go to desktop to which window was sent

- "Reset" window position when moving windows between virtual desktops

## [1.0.0] - 2019-12-28

- Initial release.
