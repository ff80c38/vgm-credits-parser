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

Args <- commandArgs(trailingOnly=TRUE)

if (length(Args) > 0L){
  PATH <- Args[1L]
}else{
  rm(list=ls(all.names=TRUE))
  PATH <- dirname(dirname(normalizePath(rstudioapi::documentPath())))
}

library(shiny)

vgmdb_roles <- data.table::fread(file.path(PATH, "vgmdb_data", "vgmdb_roles.tsv"))

source(file.path(PATH, "config", "settings.R"))
source(file.path(PATH, "config", "themes.R"))
source(file.path(PATH, "config", "regex.R"))
source(file.path(PATH, "R", "utils_general.R"))
source(file.path(PATH, "R", "utils_strings.R"))
source(file.path(PATH, "R", "utils_server.R"))
source(file.path(PATH, "R", "utils_ui.R"))
source(file.path(PATH, "R", "utils_uitxt.R"))
source(file.path(PATH, "R", "fct_init.R"))
source(file.path(PATH, "R", "fct_scraper.R"))
source(file.path(PATH, "R", "fct_analyser.R"))
source(file.path(PATH, "R", "fct_parser.R"))
source(file.path(PATH, "R", "fct_tables.R"))
source(file.path(PATH, "R", "fct_albumartist.R"))
source(file.path(PATH, "R", "fct_tagger.R"))

check_BLOCK(BLOCK, LINE)
# cat("\014")

source(file.path(PATH, "R", "shiny.R"))
source(file.path(PATH, "R", "ui.R"))
source(file.path(PATH, "R", "server.R"))

# debug(create_all_tags)
# debug(tag_flac_files)
# options(shiny.reactlog=TRUE)
# debug(apply_format_code)
# debug(fix_title)
# debug(get_dummy_tracklists)
# debug(create_artist_scores)
# debug(create_disc_tags)
# debug(apply_format_code)
# debug(parse_tracklist)
# debug(create_artist_scores)
# debug(parse_found_info)

shiny::shinyApp(ui, server, options=list(launch.browser=TRUE))

# stringi::stri_escape_unicode(NOTES[9])
#
# N <- "Yasuaki Iwata: M1, M2, M5, M8, M15, M17, M20, M22, M25"
#
# stringi::stri_match_first_regex(
#   N,
#   pattern="^(.+)(?: +: +|: +| +- +| {2,})(.*?[0-9].*?)$",
#   opts_regex=list(case_insensitive=TRUE)
# )
#
# LINE$artist_track$regex
#
# analyse_line(NOTES[9], LINE$artist_track)
#
# potential_matches <- lapply(LINE, function(line){
#   analyse_line(NOTES[9], line)
# })
# has_matches <- data.table::as.data.table(lapply(potential_matches, function(line_def){
#   r_avail_n(line_def, length(NOTES[6:11]))
# }))
