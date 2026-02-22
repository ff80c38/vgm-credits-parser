# -----------------------------------------------------------------------------
# Copyright (c) 2026 ff80c38
# Licensed under the MIT License. See LICENSE file for details.
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

source(file.path(PATH, "R", "shiny.R"))
source(file.path(PATH, "R", "ui.R"))
source(file.path(PATH, "R", "server.R"))

shiny::shinyApp(ui, server, options=list(launch.browser=TRUE))
