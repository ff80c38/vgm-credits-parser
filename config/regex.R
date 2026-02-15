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

# Idea
# """"
# 1. Define regexes for FIELDs and SEPs
# 2. Use FIELDs and SEPs to construct LINEs
# 3. Use LINEs to construct BLOCKs


# Short alias
p <- paste0


# Disc number strings that will be parsed
# Needs to start at one and increase in steps of one
NUMBERS <- c("ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN")


# Separators inside fields
# Example: The " & " in "Noriko Matsueda & Takahito Eguchi"
SEP <- c(
  "artist"   = "(?: +& +|, +| +and +|; +| +/ +| +\\+ +| +x +| +× +| +feat\\. +| +featuring +)",
  "role"     = "(?: +& +|, +| +and +|; +| +/ +)",
  "track"    = "(?: +& +|, +|,|/)"
)


# Delimiters between fields inside a line
# Example: The ": " in "Composer: Junpei Fujita"
DELIM <- c(
  "info"     = "(?: +: +|: +| +- +|\\. | {2,})",
  "info_by"  = "(?: +: +|: +| +- +|\\. | {2,}| +by +)",
  "info_all" = "(?: +: +|: +| +- +|\\. | {2,}| +)"
)


# Permitted characters
CHARS <- c(
  "role" = "[^\\:\\?\\_\\=\\~\\(\\)\\[\\]\\{\\}\\%\\$\\§\\\\]"
)


FIELD <- c(
  "artist" = "(.+?)",
  "artist_g" = "(.+)",
  "comment" = "(.+)",
  "disc" = "[^a-z0-9]*disc *(.*?(?:[0-9]+|ONE|TWO|THREE|FOUR|FIVE|SIX|SEVEN|EIGHT|NINE|TEN).*?)",
  "disc_g" = "[^a-z0-9]*disc *(.*(?:[0-9]+|ONE|TWO|THREE|FOUR|FIVE|SIX|SEVEN|EIGHT|NINE|TEN).*)",
  "discsubtitle" = "(.+)",
  "role" = p("(", CHARS["role"], "+?)"),
  "role_g" = p("(", CHARS["role"], "+)"),
  "track" = "(.*?[0-9].*?)",
  "track_g" = "(.*[0-9].*)",
  "all" = "(all)",
  "COMMENT" = "(comments?)",
  "none" = "(.*)"
)


LINE <- list(
  "role" = list(
    info  = c("role"),
    regex = p("^", FIELD["role_g"], "$")
  ),
  "comment" = list(
    info  = c("comment"),
    regex = p("^", FIELD["comment"], "$")
  ),
  "artist_track" = list(
    info  = c("artist", "track"),
    regex = p("^", FIELD["artist_g"], DELIM["info"], FIELD["track"], "$")
  ),
  "artist_(track)" = list(
    info  = c("artist", "track"),
    regex = p("^", FIELD["artist_g"], " +\\(", FIELD["track"], "\\)$")
  ),
  "artist_[track]" = list(
    info  = c("artist", "track"),
    regex = p("^", FIELD["artist_g"], " +\\[", FIELD["track"], "\\]$")
  ),
  "track_artist" = list(
    info  = c("track", "artist"),
    regex = p("^", FIELD["track"], DELIM["info_by"], FIELD["artist_g"], "$")
  ),
  "role_artist" = list(
    info  = c("role", "artist"),
    regex = p("^", FIELD["role"], DELIM["info_by"], FIELD["artist_g"], "$")
  ),
  "all_role_artist" = list(
    info  = c("all", "role", "artist"),
    regex = p("^", FIELD["all"], DELIM["info_all"], FIELD["role"], DELIM["info_by"], FIELD["artist_g"], "$")
  ),
  "artist_role" = list(
    info  = c("artist", "role"),
    regex = p("^", FIELD["artist"], DELIM["info"], FIELD["role_g"], "$")
  ),
  "comment_track" = list(
    info  = c("comment", "track"),
    regex = p("^", FIELD["comment"], DELIM["info"], FIELD["track"], "$")
  ),
  "comment_(track)" = list(
    info  = c("comment", "track"),
    regex = p("^", FIELD["comment"], " +\\(", FIELD["track"], "\\)$")
  ),
  "comment_[track]" = list(
    info  = c("comment", "track"),
    regex = p("^", FIELD["comment"], " +\\[", FIELD["track"], "\\]$")
  ),
  "track_comment" = list(
    info  = c("track", "comment"),
    regex = p("^", FIELD["track"], DELIM["info"], FIELD["comment"], "$")
  ),
  "track_(comment)" = list(
    info  = c("track", "comment"),
    regex = p("^", FIELD["track"]," +\\(", FIELD["comment"], "\\)$")
  ),
  "track" = list(
    info  = c("track"),
    regex = p("^", FIELD["track_g"], "$")
  ),
  "disc" = list(
    info  = c("disc"),
    regex = p("^", FIELD["disc_g"], "$")
  ),
  "disc_discsubtitle" = list(
    info  = c("disc", "discsubtitle"),
    regex = p("^", FIELD["disc"], DELIM["info"], FIELD["discsubtitle"], "$")
  ),
  "disc_track" = list(
    info  = c("disc", "track"),
    regex = p("^", FIELD["disc"], DELIM["info"], FIELD["track"], "$")
  ),
  "disc_track_comment" = list(
    info  = c("disc", "track", "comment"),
    regex = p("^", FIELD["disc"], DELIM["info"], FIELD["track"], DELIM["info"], FIELD["commnent"], "$")
  ),
  "all" = list(
    info  = c("all"),
    regex = p("^", FIELD["all"], "(?: tracks)?(?: by| :|:)?", "$")
  ),
  "COMMENT" = list(
    info  = c("none"),
    regex = p("^", FIELD["COMMENT"], "$")
  ),
  "none" = list( # Fallback
    info  = c("none"),
    regex = p("^", FIELD["none"], "$")
  )
)


# Order of Definitions == Priority
BLOCK <- list(
  list( # 1 Line Block
    lines = c("disc_discsubtitle"),
    multi = c(FALSE)
  ),
  list(
    lines = c("comment", "role_artist", "disc_track"),
    multi = c(FALSE, FALSE, TRUE)
  ),
  list( # Custom macro for many comments
    lines = c("COMMENT", "track_comment"),
    multi = c(FALSE, TRUE)
  ),
  list( # https://vgmdb.net/album/113471
    lines = c("role_artist", "disc_track"),
    multi = c(FALSE, TRUE)
  ),
  list( # https://vgmdb.net/album/18946 / https://vgmdb.net/album/20831 (needs modification)
    lines = c("disc_track", "role_artist"),
    multi = c(TRUE, FALSE)
  ),
  list( # 1 Line Block
    lines = c("disc"),
    multi = c(FALSE)
  ),
  list( # 1 Line Block
    lines = c("track_comment"),
    multi = c(FALSE)
  ),
  list( # 1 Line Block
    lines = c("comment_(track)"),
    multi = c(FALSE)
  ),
  list( # 1 Line Block
    lines = c("comment_[track]"),
    multi = c(FALSE)
  ),
  list( # 1 Line Block
    lines = c("comment_track"),
    multi = c(FALSE)
  ),
  list( # 1 Line Block
    lines = c("all_role_artist"),
    multi = c(FALSE)
  ),
  list( # https://vgmdb.net/album/113471
    lines = c("disc_track_comment", "role_artist"),
    multi = c(FALSE, TRUE)
  ),
  list(
    lines = c("track_(comment)", "role_artist"),
    multi = c(FALSE, TRUE)
  ),
  list(
    lines = c("track_comment", "role_artist"),
    multi = c(FALSE, TRUE)
  ),
  list(
    lines = c("comment_track", "role_artist"),
    multi = c(FALSE, TRUE)
  ),
  list(
    lines = c("role", "artist_(track)"),
    multi = c(FALSE, TRUE)
  ),
  list(
    lines = c("role", "artist_[track]"),
    multi = c(FALSE, TRUE)
  ),
  list(
    lines = c("role", "artist_track"),
    multi = c(FALSE, TRUE)
  ),
  list(
    lines = c("all", "role_artist"),
    multi = c(FALSE, TRUE)
  ),
  list(
    lines = c("all", "artist_role"),
    multi = c(FALSE, TRUE)
  ),
  list( # https://vgmdb.net/album/65091
    lines = c("track", "role_artist"),
    multi = c(FALSE, TRUE)
  ),
  list(
    lines = c("track", "artist_role"),
    multi = c(FALSE, TRUE)
  ),
  list( # Weird case, low priority
    lines = c("role", "track_artist"),
    multi = c(FALSE, TRUE)
  ),
  list( # Fallback, will always match --> keep in last position!
    lines = c("none"),
    multi = c(TRUE)
  )
)


# Regex for extracting information from `track` credit fields
TRACK <- c(
  "track" = "(?:([0-9]+)\\.)?([0-9]+)(?:~|-)?(?:([0-9]+)\\.)?([0-9]+)?",
  "disc" = p("DISC( *[0-9]+[\\-:]?| +(?:", p(NUMBERS, collapse="|"), "))")
)
