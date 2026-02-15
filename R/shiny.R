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

shiny::addResourcePath("www", file.path(PATH, "www"))
shiny::shinyOptions(cache=cachem::cache_mem(max_size=100e6))

str_dist <- memoise::memoise(
  f = str_dist_slow,
  hash = function(x) rlang::hash(tolower(x)),
  cache = shiny::getShinyOption("cache")
)
