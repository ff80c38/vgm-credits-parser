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

# Format Codes
# ============
# Syntax and usage inspired by: https://kid3.sourceforge.io/kid3_en.html#file
# Differences: Short forms of tags/fields are not supported yet, use full tag name inside braces


# 1. Get Album --------------------------------------------------------------------------------

options(vgm_album_url = file.path(PATH, "album.html"))

# 3. Adjust Tags ------------------------------------------------------------------------------

# 3.1 Options ----

options(vgm_sep_multi_value = "; ")
options(vgm_fullwidth_to_halfwidth = TRUE)
options(vgm_various_text_fixes = TRUE)
options(vgm_artist_calc_priority1 = list("COMPOSER", "ARRANGER", "REMIXER"))
options(vgm_artist_calc_priority2 = list("VOCALIST"))
options(vgm_artist_calc_priority3 = list("LYRICIST"))
options(vgm_artist_calc_unused = list("CONDUCTOR", "PERFORMER"))

# 3.2 Album ----

options(vgm_date_format = "ymd") # Possible values: "ymd", "ym", "y"
options(vgm_case_album = "") # Possible values: "", "lower", "upper", "title", "force_title", "proper", "sentence"
options(vgm_case_contentgroup = "") # Possible values: "", "lower", "upper", "title", "force_title", "proper", "sentence"

# 3.3 Discs ----

options(vgm_case_discsubtitle = "") # Possible values: "", "lower", "upper", "title", "force_title", "proper", "sentence"
options(vgm_discsubtitle_format_codes = list( # First entry is used as default
  '%discsubtitle' = '%{DISCSUBTITLE}',
  'Disc %disc - %discsubtitle' = 'Disc %{DISCNUMBER}%{" - "DISCSUBTITLE}'
))

# 3.4 Tracks ----

options(vgm_remove_artist_suffix = TRUE)
options(vgm_case_title = "") # Possible values: "", "lower", "upper", "title", "force_title", "proper", "sentence"

# 3.5 Album Artist ----

options(vgm_albumartist_percentage = 15) # Possible values: 0 - 100
options(vgm_albumartist_method = "tracks") # Possible values: "tracks", "length"

# 3.6 Tag Overview ----

options(vgm_all_tags_keep_disc = FALSE)
options(vgm_all_tags_keep_credits = FALSE)
options(vgm_all_tags_keep_notes = FALSE)

# 4. Tag Files --------------------------------------------------------------------------------

# 4.1 Filenames ----

options(vgm_filename_min_width_disc = 1)
options(vgm_filename_min_width_track = 2)
options(vgm_filename_min_width_auto = TRUE)
options(vgm_filename_format_codes = list( # First entry is used as default
  '%disc-%track - %title' = '%{DISCNUMBER"-"}%{TRACKNUMBER} - %{TITLE}',
  '%track - %title' = '%{TRACKNUMBER} - %{TITLE}',
  '%album/%disc-%track - %title' = '%{ALBUM}/%{DISCNUMBER"-"}%{TRACKNUMBER} - %{TITLE}',
  '%disc.%track. %title' = '%{DISCNUMBER"."}%{TRACKNUMBER}. %{TITLE}',
  '%track. %title' = '%{TRACKNUMBER}. %{TITLE}'
))

# 4.2 Match Files ----

options(vgm_file_matching_method = "auto") # Possible values: "auto", "manual"
options(vgm_file_matching_time_diff = 5) # Seconds
options(vgm_cover_size = 700) # Pixel
options(vgm_cover_dim = "min") # Possible values: "min", "max"
options(vgm_remove_sort_tags = TRUE)
options(vgm_remove_musicbrainz_tags = TRUE)

# Internal Settings ---------------------------------------------------------------------------

options(HTTPUserAgent = "VGM Credits Parser/1.0") # The user agent string that is used for all HTTP connections
options(vgm_main_tags = c("COMPOSER", "ARRANGER", "REMIXER", "LYRICIST", "CONDUCTOR", "VOCALIST")) # Which credits are "main" tags and get their own tag field? (VOCALIST is not a Vorbis standard but we use it anyway)
options(vgm_performer_tags = c("VOCALIST", "PERFORMER")) # Which credits are "performer" tags and should be listed in the PERFROMER tag, including their role in parentheses?
