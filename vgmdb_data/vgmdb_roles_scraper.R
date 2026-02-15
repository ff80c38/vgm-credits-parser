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

# Settings ------------------------------------------------------------------------------------

url <- "https://vgmdb.net"

# IDs of roles we also want to fetch all aliases from
rolesID <- c(
  29,  # Vocals
  35,  # Composer
  36,  # Sound Producer
  54,  # Arranger
  34,  # Music
  37,  # Recording Engineer
  38,  # Mixing Engineer
  43,  # Recording Studio
  44,  # Mixing Studio
  45,  # Mastering Engineer
  46,  # Mastering Studio
  47,  # Assistant Engineer
  50,  # Programmer
  53,  # Lyricist
  95,  # Performer
  187, # Conductor
  188, # Editor
  189, # Sound Designer
  190, # Sound Director
  191, # Sound Effects
  192, # Supervisor
  193, # Sound Engineer
  194, # Sound Production
  195, # Sound Support
  196, # Vocal Director
  197, # Scriptwriter
  198, # Music Producer
  199, # Music Director
  259, # Orchestra
  279, # Sound
  287, # Remixer
  361, # Assistant
  1726 # Narrator
)


# Start ---------------------------------------------------------------------------------------

unescape_html <- function(x){
  sep <- "\n\n\n\n\n\n\n\n\n\n"
  str <- paste0(x, collapse=sep)
  str_unescaped <- xml2::xml_text(xml2::read_html(charToRaw(str)))
  stringi::stri_split_fixed(str_unescaped, sep)[[1L]]
}

rolesID <- as.integer(rolesID)

# Get crawl delay from 'robots.txt'
robots <- tolower(readLines(file.path(url, "robots.txt"), encoding="UTF-8"))
crawl_delay <- as.numeric(stringi::stri_extract_first_regex(
  str = robots[startsWith(robots, "crawl-delay")],
  pattern = "[0-9]+"
))
# Manually set crawl delay to at least 10 seconds
crawl_delay <- max(10, crawl_delay, na.rm=TRUE)

# Create a login form
login_form_empty <- rvest::html_form(xml2::read_html(url))[[2L]]
if (interactive() && require("rstudioapi", include.only=character(), quietly=TRUE)){
  setwd(dirname(normalizePath(rstudioapi::documentPath())))
  login_form_filled <- rvest::html_form_set(
    form = login_form_empty,
    vb_login_username = rstudioapi::showPrompt(title="Login", message="VGMdb User Name:"),
    vb_login_password = rstudioapi::askForPassword(prompt="VGMdb Password:")
  )
}else{
  login_form_filled <- rvest::html_form_set(
    form = login_form_empty,
    vb_login_username = askpass::askpass(prompt="VGMdb User Name:"),
    vb_login_password = askpass::askpass(prompt="VGMdb Password:")
  )
}

session <- rvest::session(url)
session <- rvest::session_submit(session, login_form_filled)

login_response <- stringi::stri_trim(xml2::xml_text(
  xml2::xml_find_first(xml2::read_html(session), ".//td[@class='panelsurround']/*")
))

if (!startsWith(login_response, "Thank you for logging in")){
  stop("Login failed!")
}

# We should now be logged in

# Do not overwrite aliases list if it already exists
if (!exists("aliases")){
  aliases <- vector(mode="list", length(rolesID))
}

# Get all aliases from roles defined above
for (i in seq_along(rolesID)){
  # Skip if alias has already been queried
  if (!is.null(aliases[[i]])){
    next
  }

  r <- rolesID[i]
  print(r)

  # Append unused alias (?alias=) so we only get the alias list on the left and nothing more
  url_role <- file.path(url, "role", paste0(r, "?alias=999999999"))
  xpath_role <- paste0(".//a[contains(@href, '/role/", r, "')]")

  session <- rvest::session_jump_to(session, url_role)
  site_role <- xml2::read_html(session, encoding="UTF-8")
  alias_role <- xml2::xml_text(xml2::xml_find_all(x=site_role, xpath=xpath_role))

  aliases[[i]] <- list(id=r, role=alias_role[1L], alias=alias_role)
  Sys.sleep(crawl_delay)
}

table_aliases <- data.table::rbindlist(aliases)
table_aliases[, alias:=gsub(" \\(.*\\)$", "", alias, perl=TRUE)]
table_aliases <- unique(table_aliases)

# Get the names of all roles (without aliases)
session <- rvest::session_jump_to(session, file.path(url, "db", "role.php"))
role_list <- xml2::read_html(session$response$content, encoding="UTF-8")

roles <- as.character(xml2::xml_find_all(role_list, ".//a[contains(@href, '/role/')]"))
roles_clean <- stringi::stri_match_all_regex(roles, "^<a *href=\"/role/([0-9]+)\">(.+)</a>$")
table_roles <- data.table::setDT(data.table::transpose(lapply(roles_clean, function(x){
  x[1L, -1L]
})))

names(table_roles) <- c("id", "role")
table_roles[, id:=as.integer(id)]
table_roles[, role:=unescape_html(role)]
table_roles[, alias:=role]

# Combine everything
table_all <- rbind(table_roles, table_aliases)
table_all[, role:=stringi::stri_trim(unescape_html(role))]
table_all[, alias:=tolower(stringi::stri_trim(alias))]
table_all <- unique(table_all)
table_all <- table_all[id>=28, ] # Remove "(LEGACY)" entries
table_all <- table_all[!(duplicated(alias, fromLast=FALSE) | duplicated(alias, fromLast=TRUE)), ]

# Assign Tag Mapping
table_all[, tag:="PERFORMER"]
table_all[role=="Composer", tag:="COMPOSER"]
table_all[role=="Arranger", tag:="ARRANGER"]
table_all[role=="Music", tag:="COMPOSER"]
table_all[role=="Remixer", tag:="REMIXER"]
table_all[role=="Lyricist", tag:="LYRICIST"]
table_all[role=="Vocals", tag:="VOCALIST"]
table_all[role=="Sound Effects", tag:="COMPOSER"]
table_all[role=="Conductor", tag:="CONDUCTOR"]

table_all[id %in% c(7041), tag:="COMPOSER"]
table_all[id %in% c(1330, 1801, 3377, 4862, 6872, 7031, 7186, 7653, 8965, 9059, 10117, 10395), tag:="REMIXER"]
table_all[tag=="PERFORMER" & endsWith(alias, "narrator"), tag:="VOCALIST"]
table_all[tag=="PERFORMER" & endsWith(alias, "vocals"), tag:="VOCALIST"]
table_all[tag=="PERFORMER" & endsWith(alias, "vocalist"), tag:="VOCALIST"]
table_all[tag=="PERFORMER" & endsWith(alias, "voice"), tag:="VOCALIST"]
table_all[tag=="PERFORMER" & endsWith(alias, "voices"), tag:="VOCALIST"]
table_all[tag=="PERFORMER" & endsWith(alias, "lyrics"), tag:="LYRICIST"]
table_all[tag=="PERFORMER" & endsWith(alias, "lyricist"), tag:="LYRICIST"]
table_all[tag=="PERFORMER" & endsWith(alias, "conductor"), tag:="CONDUCTOR"]
table_all[tag=="PERFORMER" & endsWith(alias, "composer"), tag:="COMPOSER"]
table_all[tag=="PERFORMER" & endsWith(alias, "composition"), tag:="COMPOSER"]
table_all[tag=="PERFORMER" & endsWith(alias, "arranger"), tag:="ARRANGER"]

# Save
data.table::fwrite(table_all, "./VGMdb_roles.tsv", sep="\t")
