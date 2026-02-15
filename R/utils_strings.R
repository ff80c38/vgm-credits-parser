# -----------------------------------------------------------------------------
# This file is part of VGM Credits Parser.
#
# VGM Credits Parser is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation
#
# VGM Credits Parser is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with VGM Credits Parser. If not, see <https://www.gnu.org/licenses/>.
# -----------------------------------------------------------------------------

# Replace Latin fullwidth characters with their halfwidth equivalents
# Most listed characters are from these UTF8 codepoints:
# intToUtf8(65281:65374, multiple=TRUE)
# intToUtf8(33:126, multiple=TRUE)
fix_fullwidth_chars <- function(str){
  replacements <- c(
    "\uff01", "!",
    "\uff02", "\"",
    "\uff03", "#",
    "\uff04", "$",
    "\uff05", "%",
    "\uff06", "&",
    "\uff07", "\'",
    "\uff08", "(",
    "\uff09", ")",
    "\uff0a", "*",
    "\uff0b", "+",
    "\uff0c", ",",
    "\uff0d", "-",
    "\uff0e", ".",
    "\uff0f", "/",
    "\uff10", "0",
    "\uff11", "1",
    "\uff12", "2",
    "\uff13", "3",
    "\uff14", "4",
    "\uff15", "5",
    "\uff16", "6",
    "\uff17", "7",
    "\uff18", "8",
    "\uff19", "9",
    "\uff1a", ":",
    "\uff1b", ";",
    "\uff1c", "<",
    "\uff1d", "=",
    "\uff1e", ">",
    "\uff1f", "?",
    "\uff20", "@",
    "\uff21", "A",
    "\uff22", "B",
    "\uff23", "C",
    "\uff24", "D",
    "\uff25", "E",
    "\uff26", "F",
    "\uff27", "G",
    "\uff28", "H",
    "\uff29", "I",
    "\uff2a", "J",
    "\uff2b", "K",
    "\uff2c", "L",
    "\uff2d", "M",
    "\uff2e", "N",
    "\uff2f", "O",
    "\uff30", "P",
    "\uff31", "Q",
    "\uff32", "R",
    "\uff33", "S",
    "\uff34", "T",
    "\uff35", "U",
    "\uff36", "V",
    "\uff37", "W",
    "\uff38", "X",
    "\uff39", "Y",
    "\uff3a", "Z",
    "\uff3b", "[",
    "\uff3c", "\\",
    "\uff3d", "]",
    "\uff3e", "^",
    "\uff3f", "_",
    "\uff40", "`",
    "\uff41", "a",
    "\uff42", "b",
    "\uff43", "c",
    "\uff44", "d",
    "\uff45", "e",
    "\uff46", "f",
    "\uff47", "g",
    "\uff48", "h",
    "\uff49", "i",
    "\uff4a", "j",
    "\uff4b", "k",
    "\uff4c", "l",
    "\uff4d", "m",
    "\uff4e", "n",
    "\uff4f", "o",
    "\uff50", "p",
    "\uff51", "q",
    "\uff52", "r",
    "\uff53", "s",
    "\uff54", "t",
    "\uff55", "u",
    "\uff56", "v",
    "\uff57", "w",
    "\uff58", "x",
    "\uff59", "y",
    "\uff5a", "z",
    "\uff5b", "{",
    "\uff5c", "|",
    "\uff5d", "}",
    "\uff5e", "~",
    "\u301c", "~",
    "\uffe4", "\u00a6",
    "\uff5f", "\u2e28",
    "\uff60", "\u2e29",
    "\u300c", "\uff62",
    "\u300d", "\uff63",
    "\uffe1", "\u00a3",
    "\uffe0", "\u00a2",
    "\uffe6", "\u20a9",
    "\uffe5", "\u00a5",
    "\uffe2", "\u00ac",
    "\uffe3", "\u00af"
  )

  idx <- seq.int(from=1L, to=length(replacements), by=2L)
  stringi::stri_replace_all_fixed(
    str = str,
    pattern = replacements[idx],
    replacement = replacements[-idx],
    vectorize_all = FALSE
  )
}

# Remove all control characters except some whitespace ones, which are converted to a regular space
fix_control_chars <- function(str){
  replacements <- c(
    "\u0001", "",
    "\u0002", "",
    "\u0003", "",
    "\u0004", "",
    "\u0005", "",
    "\u0006", "",
    "\u0007", "",  # "\a"
    "\u0008", "",  # "\b"
    "\u0009", " ", # "\t"
    "\u000a", " ", # "\n"
    "\u000b", "",  # "\v"
    "\u000c", "",  # "\f"
    "\u000d", "",  # "\r"
    "\u000e", "",
    "\u000f", "",
    "\u0010", "",
    "\u0011", "",
    "\u0012", "",
    "\u0013", "",
    "\u0014", "",
    "\u0015", "",
    "\u0016", "",
    "\u0017", "",
    "\u0018", "",
    "\u0019", "",
    "\u001a", "",
    "\u001b", "",
    "\u001c", "",
    "\u001d", "",
    "\u001e", "",
    "\u001f", "",
    "\u007f", "",
    "\u0080", "",
    "\u0081", "",
    "\u0082", "",
    "\u0083", "",
    "\u0084", "",
    "\u0085", "",
    "\u0086", "",
    "\u0087", "",
    "\u0088", "",
    "\u0089", "",
    "\u008a", "",
    "\u008b", "",
    "\u008c", "",
    "\u008d", "",
    "\u008e", "",
    "\u008f", "",
    "\u0090", "",
    "\u0091", "",
    "\u0092", "",
    "\u0093", "",
    "\u0094", "",
    "\u0095", "",
    "\u0096", "",
    "\u0097", "",
    "\u0098", "",
    "\u0099", "",
    "\u009a", "",
    "\u009b", "",
    "\u009c", "",
    "\u009d", "",
    "\u009e", "",
    "\u009f", ""
  )

  idx <- seq.int(from=1L, to=length(replacements), by=2L)
  stringi::stri_replace_all_fixed(
    str = str,
    pattern = replacements[idx],
    replacement = replacements[-idx],
    vectorize_all = FALSE
  )
}

# Replace characters not allowed in filenames with alternatives
fix_system_chars <- function(str){
  replacements <- c(
    " : ", " - ",
    ": ", " - ",
    ":", " - ",
    "/", "-",
    "?", "_",
    "*", "_",
    "<", "-",
    ">", "-",
    "|", "-",
    "\\", "-",
    "\"", "''"
  )

  idx <- seq.int(from=1L, to=length(replacements), by=2L)
  stringi::stri_replace_all_fixed(
    str = str,
    pattern = replacements[idx],
    replacement = replacements[-idx],
    vectorize_all = FALSE
  )
}

# Make sure filenames are valid on Linux and Windows
# This function needs to be applied to every part of the file/directory path
fix_system_names <- function(str){
  replacements <- c(
    # Windows
    " +$", "",
    "^ +", "",
    # Linux & Windows
    "^\\.$", "_",
    "^\\.\\.$", "__",
    # Windows
    "^(CON(?:IN|OUT)\\$)$", "_$1",
    "^(CON|PRN|AUX|NUL|(?:COM|LPT)[0123456789\u00b9\u00b2\u00b3])(\\..*)?$", "_$1$2",
    "\\.$", "_"
  )

  idx <- seq.int(from=1L, to=length(replacements), by=2L)
  stringi::stri_replace_all_regex(
    str = str,
    pattern = replacements[idx],
    replacement = replacements[-idx],
    vectorize_all = FALSE,
    opts_regex = stringi::stri_opts_regex(case_insensitive=TRUE)
  )
}

# Some string standardiszations
fix_various <- function(str){
  replacements <- c(
    # 1:1 character replacements
    "\u2014", "-", # em dash
    "\u2013", "-", # en dash
    "\uff61", ".",
    "\u3002", ".",
    "\uff64", ",",
    "\u3001", ",",
    "\uffe8", "|",
    # Multiple whitespaces -> one space
    "\\s+", " ",
    # Space at start and end of string
    "^ +", "",
    " +$", "",
    # Insert space between parentheses at end of string and last word
    "([^ ])(\\([^()]*\\))$", "$1 $2"
  )

  idx <- seq.int(from=1L, to=length(replacements), by=2L)
  stringi::stri_replace_all_regex(
    str = str,
    pattern = replacements[idx],
    replacement = replacements[-idx],
    vectorize_all = FALSE
  )
}

fix_filename_chars <- function(x){
  x <- fix_control_chars(x)
  x <- fix_system_chars(x)
  x
}

# This function needs to be applied to every part of the file/directory path
fix_filename <- function(x){
  x <- fix_control_chars(x)
  x <- fix_system_chars(x)
  x <- fix_system_names(x)
  x
}

# Option to remove artist suffixes
fix_artist <- function(x, remove_suffix){
  if (remove_suffix){
    stringi::stri_replace_first_regex(x, "^(.+?)( +)\\([^()]*\\)$", "$1")
  }else{
    x
  }
}

# Standardize track titles
fix_title <- function(x, case="default", halfwidth=TRUE, various=TRUE){
  x <- fix_control_chars(x)
  if (halfwidth){
    x <- fix_fullwidth_chars(x)
  }
  if (various){
    x <- fix_various(x)
  }

  x <- switch(
    tolower(case),
    "lower" = tolower(x),
    "upper" = toupper(x),
    "title" = tools::toTitleCase(x),
    "force_title" = tools::toTitleCase(tolower(x)),
    "proper" = stringi::stri_trans_totitle(x),
    "sentence" = stringi::stri_trans_totitle(x, opts_brkiter=list(type="sentence")),
    x
  )

  x
}

# Convert to character while replacing NAs with ""
as_character <- function(x){
  txt <- as.character(x)
  txt[is.na(x)] <- ""
  txt
}

# Pad numbers, using explicit width, minimum width and auto-width options
num_pad <- function(x, width=NULL, min_width=1L, autopad=TRUE){
  if (is1_R0p(width)){
    pad_width <- width
  }else if (is.numeric(x) && autopad){
    pad_width <- max(min_width, ndigits(max(x, na.rm=TRUE)), na.rm=TRUE)
  }else if (is1_R0p(min_width)){
    pad_width <- min_width
  }else{
    pad_width <- 0L
  }

  stringi::stri_pad_left(x, width=pad_width, pad="0")
}

fix_notes_lines <- function(str){
  replacements <- c(
    "\t", "    ",
    "\u0020", " ",
    "\u00a0", " ",
    "\u2000", " ",
    "\u2001", "  ",
    "\u2002", " ",
    "\u2003", "  ",
    "\u2004", " ",
    "\u2005", " ",
    "\u2006", " ",
    "\u2007", " ",
    "\u2008", " ",
    "\u2009", " ",
    "\u200a", " ",
    "\u202f", " ",
    "\u205f", " ",
    "\u3000", "  ",
    "\\s", " ",
    "^ ", "",
    "[ :]+$", ""
  )

  idx <- seq.int(from=1L, to=length(replacements), by=2L)
  stringi::stri_replace_all_regex(
    str = str,
    pattern = replacements[idx],
    replacement = replacements[-idx],
    vectorize_all = FALSE
  )
}
