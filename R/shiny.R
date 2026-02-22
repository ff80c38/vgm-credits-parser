# -----------------------------------------------------------------------------
# Copyright (c) 2026 ff80c38
# Licensed under the MIT License. See LICENSE file for details.
# -----------------------------------------------------------------------------

shiny::addResourcePath("www", file.path(PATH, "www"))
shiny::shinyOptions(cache=cachem::cache_mem(max_size=100e6))

str_dist <- memoise::memoise(
  f = str_dist_slow,
  hash = function(x) rlang::hash(tolower(x)),
  cache = shiny::getShinyOption("cache")
)
