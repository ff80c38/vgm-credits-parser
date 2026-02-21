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

# Utils -------------------------------------------------------------------

get_html <- function(url){
  if (is_url(url)){
    response <- httr::GET(url, httr::user_agent(getOption("HTTPUserAgent", "Mozilla/5.0")))
    html <- xml2::read_html(response, encoding="UTF-8")
  }else{
    html <- xml2::read_html(url, encoding="UTF-8")
  }
}

get_cover_urls <- function(html){
  text <- xml2::xml_attr(xml2::xml_find_first(html, ".//div[@id='coverart']"), "style")
  cover_small <- stringi::stri_match_first_regex(text, "url\\('(.*)'\\)")[1L, 2L]
  if (cover_small == "/db/img/album-nocover-medium.gif"){
    cover_small <- "https://vgmdb.net/db/img/album-nocover-medium.gif"
  }
  cover_large <- stringi::stri_replace_first_regex(cover_small, "^https://medium-", "https://")
  c(small=cover_small, large=cover_large)
}

get_website <- function(html){
  xml2::xml_attr(xml2::xml_find_first(html, ".//meta[@property='og:url']"), "content")
}

get_notes <- function(html){
  children <- xml2::xml_contents(xml2::xml_find_first(html, ".//div[@id='notes']"))
  text <- xml2::xml_text(children)
  text[xml2::xml_name(children) == "br"] <- "\n"
  paste0(text, collapse="")
}

get_title <- function(html){
  xml2::xml_text(xml2::xml_find_first(html, ".//span[@class='albumtitle']"), trim=TRUE)
}

get_album_stats <- function(html, text, split=FALSE){
  children <- xml2::xml_parent(xml2::xml_find_all(html, paste0(".//b[text()='", text, "']")))
  info <- xml2::xml_text(xml2::xml_contents(children), trim=TRUE)
  info <- info[info != "" & info != text]
  if (split && length(info) == 1L){
    info <- stringi::stri_split_fixed(info, ", ")[[1L]]
  }
  info
}

get_event <- function(html){
  event <- xml2::xml_text(xml2::xml_find_first(html, ".//a[@class='link_event']"), trim=TRUE)
  if (is.na(event)){
    event <- character(0)
  }
  event
}

get_album_info_table <- function(html, event){
  children <- xml2::xml_find_all(html, ".//table[@id='album_infobit_large']")
  if (length(children) >= 1L){
    dt <- parse_table(children[[1L]])
    data.table::setnames(dt, c("Info", "Value"))

    # Parse Release Date
    if ("Release Date" %in% dt[["Info"]]){
      date_string <- dt[["Value"]][dt[["Info"]] == "Release Date"]
      # If album was released during an event, the event name is still at the end of the date string
      if (length(event) > 0L){
        date_string <- stringi::stri_trim(stringi::stri_replace_first_fixed(date_string, event, ""))
      }
      # Replace short English month names (e.g. "Oct") with numbers --> locale independent
      date_string <- stringi::stri_replace_all_fixed(date_string, month.abb, 1:12, vectorize_all=FALSE)
      # Not all date parts might be known --> use three different formats for parsing
      date <- format(strptime(date_string, "%m %d, %Y", tz="UTC"), "%Y-%m-%d")
      if (is.na(date)){
        date <- format(strptime(date_string, "%m %Y", tz="UTC"), "%Y-%m")
      }
      if (is.na(date)){
        date <- format(strptime(date_string, "%Y", tz="UTC"), "%Y")
      }
      data.table::set(x=dt, i=which(dt[["Info"]]=="Release Date"), j="Value", value=date)
    }
  }else{
    dt <- data.table::data.table(Info=character(0L), Value=character(0L))
  }
  dt
}

get_credits <- function(html){
  children <- xml2::xml_find_all(html, ".//table[@id='album_infobit_large']")
  if (length(children) >= 2L){
    dt <- parse_table(children[[2L]])
    data.table::setnames(dt, c("Role", "Artist"))
  }else{
    dt <- data.table::data.table(Role=character(0L), Artist=character(0L))
  }
  dt
}

parse_table <- function(child){
  nrows <- length(xml2::xml_find_all(child, ".//tr"))
  data <- xml2::xml_text(xml2::xml_find_all(child, ".//td|.//th"), trim=TRUE)
  data.table::as.data.table(matrix(data=data, nrow=nrows, byrow=TRUE))
}

parse_tracklist <- function(child, album_catalognumber, album_classification){
  # Tracklist
  data <- xml2::xml_text(xml2::xml_find_all(child, ".//td[@class='smallfont']|.//th[@class='smallfont']"), trim=TRUE)
  tl <- data.table::as.data.table(matrix(data=data, ncol=3L, byrow=TRUE, dimnames=list(NULL, c("Track", "Title", "Length"))))
  data.table::set(x=tl, i=NULL, j="Track", value=as.integer(tl[["Track"]]))
  data.table::set(x=tl, i=NULL, j="Disc", value=cumsum(tl[["Track"]]==1L))
  data.table::setcolorder(tl, c("Disc", "Track", "Title", "Length"))

  # Extract disc headers like "Disc 1 [SQEX-10646]" or "Disc 3"
  disc_headings <- xml2::xml_text(xml2::xml_find_all(child, "./span[@style='font-size:8pt']/b"), trim=TRUE)
  n_discs <- length(disc_headings)

  if (max(tl$Disc) != n_discs){
    warning("Disc discrepancy!")
  }

  # If available, the catalog number is in brackets
  catalognumbers <- stringi::stri_match_last_regex(disc_headings, "\\[(.*)\\]")[, 2]
  if (anyNA(catalognumbers)){ # If incomplete, use album catalog number
    # Remove other prints info
    album_catalognumber <- stringi::stri_replace_first_regex(
      str = album_catalognumber,
      pattern = " *\\([^()]*print[^()]*\\) *$",
      replacement = "",
      opts_regex = list(case_insensitive=TRUE)
    )
    catalognumbers <- rep(album_catalognumber, n_discs)
  }

  classifications <- xml2::xml_text(xml2::xml_find_all(child, ".//span[@style='font-size:8pt' and @class='label']"), trim=TRUE)
  if (length(classifications) != n_discs){ # If incomplete, use album classification
    classifications <- rep(list(album_classification), n_discs)
  }

  classifications <- stringi::stri_split_fixed(classifications, ", ")

  album_tags <- list(
    "DISCTOTAL" = n_discs
  )

  disc_tags <- list(
    "Disc" = 1:n_discs,
    "CATALOGNUMBER" = catalognumbers,
    "VGMDB_CLASSIFICATION" = classifications,
    "TRACKTOTAL" = rle(tl[["Disc"]])[["lengths"]]
  )

  list(
    table = tl,
    album_tags = album_tags,
    disc_tags = disc_tags
  )
}

get_tracklists <- function(html, catalognumber, classification){
  languages <- xml2::xml_text(xml2::xml_find_all(html, ".//ul[@id='tlnav']/*"), trim=TRUE)
  children <- xml2::xml_find_all(html, ".//span[@class='tl']")

  tracklists <- list()
  for (i in seq_along(children)){
    tracklists[[languages[i]]] <- parse_tracklist(children[i], catalognumber, classification)
  }

  tracklists
}


get_dummy_tracklists <- function(txt){
  discs <- as.integer(stringi::stri_extract_all_regex(txt, "[0-9]+")[[1L]])

  discnumber <- rep(seq_along(discs), discs)
  tracknumber <- unlist(lapply(discs, seq_len))
  title <- paste("Track", num_pad(tracknumber, min_width=2L, autopad=TRUE))

  tl <- data.table::data.table(
    "Disc" = discnumber,
    "Track" = tracknumber,
    "Title" = title,
    "Length" = NA_character_
  )

  album_tags <- list(
    "DISCTOTAL" = length(discs)
  )

  disc_tags <- list(
    "Disc" = seq_along(discs),
    "CATALOGNUMBER" = NA_character_,
    "VGMDB_CLASSIFICATION" = NA_character_,
    "TRACKTOTAL" = discs
  )

  list(
    "Dummy" = list(
      table = tl,
      album_tags = album_tags,
      disc_tags = disc_tags
    )
  )
}





# Main Function -----------------------------------------------------------

scrape_album <- function(url){
  html <- get_html(url)

  # Remove all non-displayed aliases (Japanese, Romaji, alternate titles, ...)
  xml2::xml_remove(xml2::xml_find_all(html, ".//span[@style='display:none']"))
  # Remove unneeded elements that mess with our parsing
  xml2::xml_remove(xml2::xml_find_all(html, ".//script[@type='text/javascript']"))
  xml2::xml_remove(xml2::xml_find_all(html, ".//div[@id='childbrowse_menu']"))

  # Event + Album Info
  event <- get_event(html)
  album_info_table <- get_album_info_table(html, event)
  album_info <- as.list(album_info_table[["Value"]])
  names(album_info) <- album_info_table[["Info"]]

  tracklists <- get_tracklists(html,
                               catalognumber = album_info[["Catalog Number"]],
                               classification = album_info[["Classification"]])

  # Credits table
  credits_table <- get_credits(html)
  credits_string <- paste0(paste(credits_table[["Role"]], credits_table[["Artist"]], sep=": "), collapse="\n")
  sourcemedia <- stringi::stri_replace_first_regex(album_info[["Media Format"]], "^[0-9]+ ", "")

  # Tag Mapping
  # Currently uses vorbis tag names as base
  album_tags <- list()
  album_tags[["ALBUM"]] <- get_title(html)
  album_tags[["DATE"]] <- unname(album_info[["Release Date"]])
  album_tags[["BARCODE"]] <- unname(album_info[["Barcode"]])
  album_tags[["WEBSITE"]] <- get_website(html)
  album_tags[["LABEL"]] <- data.table::first(stringi::stri_split_fixed(album_info[["Label"]], ", "))
  album_tags[["PUBLISHER"]] <- unname(album_info[["Publisher"]])
  album_tags[["SOURCEMEDIA"]] <- sourcemedia
  album_tags[["COPYRIGHT"]] <- unname(album_info[["Phonographic Copyright"]])
  album_tags[["RELEASESTATUS"]] <- data.table::first(stringi::stri_split_fixed(album_info[["Publish Format"]], ", "))
  album_tags[["CONTENTGROUP"]] <- get_album_stats(html, text="Products represented", split=FALSE)
  album_tags[["GENRE"]] <- get_album_stats(html, text="Category", split=TRUE)
  # Separate VGMdb tags for non-standard information
  album_tags[["VGMDB_CREDITS"]] <- credits_string
  album_tags[["VGMDB_MANUFACTURER"]] <- unname(album_info[["Manufacturer"]])
  album_tags[["VGMDB_DISTRIBUTOR"]] <- unname(album_info[["Distributor"]])
  album_tags[["VGMDB_EVENT"]] <- event
  album_tags[["VGMDB_NOTES"]] <- get_notes(html) # Album notes (one single string)
  album_tags[["VGMDB_PLATFORM"]] <- get_album_stats(html, text="Platforms represented", split=TRUE)
  album_tags[["VGMDB_PRICE"]] <- unname(album_info[["Release Price"]])

  # Clean up empty entries that do not exist on VGMdb for this release
  album_tags <- album_tags[sapply(album_tags, function(x) length(x)>1L || (length(x)==1L && !is.na(x) && x!=""))]

  list(
    # Album cover URLs (small and large version)
    cover = get_cover_urls(html),
    # Contains tracklists for each language plus album_tags and disc_tags
    tracklists = tracklists,
    # Used for showing a quick overview after scraping the album
    album_info = album_info_table,
    # Tags that apply to the full album (regardless of tracklist)
    album_tags = album_tags
  )
}
