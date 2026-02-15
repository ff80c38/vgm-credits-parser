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
