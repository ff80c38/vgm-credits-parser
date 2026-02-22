# -----------------------------------------------------------------------------
# Copyright (c) 2026 ff80c38
# Licensed under the MIT License. See LICENSE file for details.
# -----------------------------------------------------------------------------

# Required Packages
pkgs <- c(
  "data.table",
  "bslib",
  "bsicons",
  "shiny",
  "sortable",
  "DT",
  "xml2",
  "httr",
  "stringi",
  "stringdist",
  "shinyAce",
  "memoise"
)

# Install 'rstudioapi' if called from inside RStudio
if (!is.na(Sys.getenv("RSTUDIO", unset=NA))){
  pkgs <- c(pkgs, "rstudioapi")
}

# Install 'magick' if called on Windows
if (.Platform$OS.type == "windows"){
  pkgs <- c(pkgs, "magick")
}

install_packages <- function(pkgs){
  for (pkg in pkgs){
    capture.output(is_installed <- require(pkg, include.only=character(), character.only=TRUE), type="message")
    if (!is_installed){
      utils::install.packages(
        pkgs = pkg,
        repos = "https://cloud.r-project.org/",
        dependencies = c("Depends", "Imports", "LinkingTo")
      )
    }else{
      detach(name=paste0("package:", pkg), character.only=TRUE)
    }
  }
}

install_packages(pkgs)
