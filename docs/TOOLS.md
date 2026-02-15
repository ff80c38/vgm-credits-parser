# Tools

VGM Credits Parser can directly write all found information/tags into FLAC files, provided `metaflac` is installed.

## Installation

Since `metaflac` is part of `flac`, we need to get the latter.

**Windows:** Follow the download and installation instructions from <https://xiph.org/flac/download.html>. Place the two files `metaflac.exe` and `libFLAC.dll` inside the `./tools` directory, i.e. the final paths should look like `./tools/metaflac.exe` and `./tools/libFLAC.dll`. For most users on a 64-bit system the correct files are located inside the `Win64` folder.

**Linux:** Install `flac` via your package manager, no need to place any files anywhere.
