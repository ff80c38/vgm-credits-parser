# Block Format Reference

## About Blocks

The defined blocks directly determine how the program is used and into which standard formats the album credits need to be transformed. For a more in-depth explanation, see [CONFIG.md](CONFIG.md).

Blocks are composed from lines with a fixed structure of information layout. The following information are currently implemented inside the application:

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

## Blocks

The following blocks are currently implemented and are used with exactly this priority, i.e. the first block definition that matches will be used for a block. For display purposes we use the following notation here:

* Words refer to the info fields listed above with the exact spelling.
* Lines starting with a '[1]' can only be defined once, while lines starting with a '[…]' can repeat multiple times.
* The string ' - ' represents any separators defined in the line definition.
* Any other symbols are to be understood literally.

```
[1] disc - discsubtitle
```

```
[1] comment
[1] role - artist
[…] disc - track
```

```
[1] COMMENT
[…] track - comment
```

```
[1] role - artist
[…] disc - track
```

```
[…] disc - track
[1] role - artist
```

```
[1] disc
```

```
[1] track - comment
```

```
[1] comment - (track)
```

```
[1] comment - [track]
```

```
[1] comment - track
```

```
[1] all - role - artist
```

```
[1] disc - track - comment
[…] role - artist
```

```
[1] track - (comment)
[…] role - artist
```

```
[1] track - comment
[…] role - artist
```

```
[1] comment - track
[…] role - artist
```

```
[1] role
[…] artist - (track)
```

```
[1] role
[…] artist - [track]
```

```
[1] role
[…] artist - track
```

```
[1] all
[…] role - artist
```

```
[1] all
[…] artist - role
```

```
[1] track
[…] role - artist
```

```
[1] track
[…] artist - role
```

```
[1] role
[…] track - artist
```
