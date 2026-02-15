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

init_tbl_found_info <- data.table::data.table(
  none = character()
)

init_tbl_tracklist <- data.table::data.table(
  Disc = character(),
  Track = character(),
  Title = character(),
  Length = character()
)

init_tbl_credits <- data.table::data.table(
  Disc = integer(),
  Track = integer(),
  Role = character(),
  Artist = character(),
  Tag = character(),
  Role_Text = character()
)

init_tbl_comments <- data.table::data.table(
  Disc = integer(),
  Track = integer(),
  Comment = character()
)

init_tbl_discs <- data.table::data.table(
  Disc = integer(),
  Disc_Title = character()
)

init_tbl_album_info <- data.table::data.table(
  Info = character(),
  Value = character()
)

init_tbl_album_tags <- data.table::data.table(
  Tag = character(),
  Value = character()
)

init_tbl_disc_tags <- data.table::data.table(
  DISCNUMBER = integer(),
  TRACKTOTAL = integer(),
  CATALOGNUMBER = character(),
  DISCSUBTITLE = character(),
  VGMDB_CLASSIFICATION = character()
)

init_tbl_track_tags <- data.table::data.table(
  DISCNUMBER = integer(),
  TRACKNUMBER = integer(),
  TITLE = character(),
  COMMENT = character(),
  ARTIST = character(),
  COMPOSER = character(),
  ARRANGER = character(),
  REMIXER = character(),
  LYRICIST = character(),
  CONDUCTOR = character(),
  VOCALIST = character(),
  PERFORMER = character()
)

init_artist_scores <- list(
  "tbl_tracks" = data.table::data.table(
    Artist = character(),
    Total = numeric(),
    ARTIST = numeric(),
    COMPOSER = numeric(),
    ARRANGER = numeric(),
    REMIXER = numeric(),
    VOCALIST = numeric(),
    LYRICIST = numeric(),
    PERFORMER = numeric()
  ),
  "tbl_length" = data.table::data.table(
    Artist = character(),
    Total = numeric(),
    ARTIST = numeric(),
    COMPOSER = numeric(),
    ARRANGER = numeric(),
    REMIXER = numeric(),
    VOCALIST = numeric(),
    LYRICIST = numeric(),
    PERFORMER = numeric()
  )
)

init_tbl_filenames <- data.table::data.table(
  Disc = integer(),
  Track = integer(),
  Filename = character()
)

init_tbl_files <- data.table::data.table(
  Disc = integer(),
  Track = integer(),
  Length = numeric(),
  File_Length = numeric(),
  File_Out = character()
)
