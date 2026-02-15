# Configuration Files

The files inside the `config` folder determine the appearance and parsing functionalities of `VGM Credits Parser`.

## Files

* `regex.R` - Regular expressions responsible for info detection
* `settings.R` - Default values of application
* `themes.R` - Graphical options

## settings.R

Contains the default values used throughout the app, e.g. the multi field separator. Modify the values to suit your personal tag preferences.

## themes.R

Contains the most important settings related to the appearance of the app. Use this file to switch between predefined themes or change the look and feel for both the app and the editor.

Setting the option `vgm_live_theme` to `TRUE` will enable a developer mode that lets you interactively switch between different themes and try various options. Please note that changing CSS during the live session has its issues, so it is advised to only use this mode to get an idea of what each option and theme looks like and then disable it afterwards again.

## regex.R

Contains every regular expression pattern that is used when parsing track credits. This file defines the entire logic of the detector and can easily be modified to add support for new blocks or macro like structures.

The general idea is to define signatures for many different lines using regex. A line that contains information formatted like `'artist: track'` has a different signature than a line with only disc information like `"Disc 2"`. Since we do not want to exclude common credit formats, these regular expressions need to be broad. This leads to false positives and makes the detection not that reliable anymore.

To mitigate this issue we make use of blocks. A block is a group of consecutive lines, while multiple blocks are separated by at least one empty line. Each block is determined by the order of its lines and their defined signatures and represents one logical entity commonly used in album credits.

Blocks reduces the number of false positives to some extent but sadly not completely. In case of multiple matches, the first block definition is simply used. Therefore the order of the block definitions is important and directly influences the perceived quality of the detector. In general, we want to place special cases at the top and common cases at the bottom of the list.

Blocks have a local scope, i.e. the lines and information inside a block are only used to parse that single block. The only exception are `disc` information, which are used as fallback values for all blocks below that information.

The used regex flavour throughout this application is [ICU](https://unicode-org.github.io/icu/userguide/strings/regexp.html).

### NUMBERS

English number names that are used for parsing `disc` information. The index of each number must correspond with its value.

### SEP

Separators that are used for splitting information inside a field. This controls for example whether "Noriko Matsueda & Takahito Eguchi" is treated as one artist or two artists.

### DELIM

Delimiters between fields in a single line. Only defines building blocks that can be reused inside the definition of `LINE`.

### CHARS

Permitted characters that can be reused inside the definition of `FIELD`.

### FIELD

Reusable building blocks for line definitions.

### LINE

The line definitions and their regex signatures. Each line definition consists of a vector specifying the found information inside the line and the regular expression to extract these information. Regex matching groups are used to map the extracted info to the specified info vector. 

The following information are currently implemented inside the application:

* `artist`: Credited persons or organisations.
* `role`: The roles the persons or organisations had.
* `disc`: Disc information. Specifies the disc the credits refer to and needs to start with the string "disc". This information is carried forward and used as default value for all following blocks until the next disc field is encountered.
* `discsubtitle`: Title of the disc.
* `track`: The actual track credits. Can contain ranges ('~' and '-') and even disc information (either via '1.01' or 'Disc 1: 1, 3 / Disc 2: 10').
* `comment`: General information about a track.
* `none`: Information is not used for anything.

Macro-like keywords:

* `all`: A special keyword that is internally replaced with track credits for all tracks from all discs. A disc specific `all` keyword has not been implemented.
* `COMMENT`: Tells the parser the following lines should all be interpreted as track comments. Useful for track origin listings.

The parser automatically removes whitespaces and colons at the end of all lines before matching against line definitions so there is no need to consider these cases here.

### BLOCK

The block definitions and their signatures. Each block definition consists of multiple lines (must match names used in `LINE`) and a specifier whether that line can repeat multiple times. Only one line is allowed to repeat inside a block to fill the block size. The order of the defined blocks is important and influences the results.

### TRACK

Regular expressions used to extract information from inside the `track` info field. Makes sure the following features are implemented:

* Track ranges via "1~3" or "2-11"
* Disc specifications via "2.01"
* A combination of both
* Additional disc specification via "Disc 1: 3, 5 / Disc 2: 4"
* Ignore any other characters that are not needed such as "M-" in "M-01"
