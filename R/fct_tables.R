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

simple_list <- function(x){
  !is.null(x) && is.list(x) && length(x) > 0L
}

simple_df <- function(x){
  !is.null(x) && is.data.frame(x) && nrow(x) > 0L
}

simple_character <- function(x){
  !is.null(x) && is.character(x) && length(x) == 1L && !is.na(x) && nchar(x) > 0L
}

merge_tags <- function(x, sep){
  split_cols <- lapply(x, stringi::stri_split_fixed, sep)

  if ("PERFORMER" %in% names(x)){
    split_cols[["PERFORMER"]] <- lapply(split_cols[["PERFORMER"]], function(str){
      stringi::stri_trim(stringi::stri_replace_all_regex(str, "\\([^()]*\\)$", ""))
    })
  }

  split_rows <- data.table::transpose(split_cols)

  out <- sapply(split_rows, function(row_list){
    artists <- unique(stringi::stri_trim(unlist(row_list)))
    artists <- artists[!is.na(artists)]
    artists <- artists[artists!=""]
    paste0(artists, collapse=sep)
  })

  out
}


create_album_tags <- function(r, input){
  album_tags <- c(r$album_tags, r$tracklists[[input$tracklist_language]][["album_tags"]])

  if (simple_list(album_tags)){
    tbl_album_tags <- data.table::data.table(
      "Tag" = names(album_tags),
      "Value" = sapply(album_tags, paste0, collapse=input$sep_multi_value)
    )
  }else{
    tbl_album_tags <- init_tbl_album_tags
  }

  # Format DATE field
  date_length <- switch(input$date_format, "ymd"=3L, "ym"=2L, "y"=1L)
  date <- tbl_album_tags$Value[tbl_album_tags$Tag=="DATE"]
  date <- stringi::stri_split_fixed(date, "-")[[1L]][seq_len(date_length)]
  date <- paste0(date[!cumsum(is.na(date))], collapse="-")

  tbl_album_tags[Tag=="DATE", Value:=date]
  tbl_album_tags[Tag=="ALBUM", Value:=fix_title(Value, case=input$case_album, halfwidth=input$halfwidth, various=input$various_text_fixes)]
  tbl_album_tags[Tag=="CONTENTGROUP", Value:=fix_title(Value, case=input$case_contentgroup, halfwidth=input$halfwidth, various=input$various_text_fixes)]
  data.table::setorderv(tbl_album_tags, "Tag")

  tbl_album_tags
}


create_disc_tags <- function(r, input){
  disc_tags <- r$tracklists[[input$tracklist_language]][["disc_tags"]]

  if (!simple_list(disc_tags)){
    return(init_tbl_disc_tags)
  }

  tbl_disc_tags <- data.table::as.data.table(lapply(disc_tags, function(x){
    if (is.list(x)){
      sapply(x, function(y){
        y <- y[!is.na(y)]
        paste0(y, collapse=input$sep_multi_value)
      })
    }else{
      x
    }
  }))

  data.table::setnames(x=tbl_disc_tags, old="Disc", new="DISCNUMBER")
  data.table::set(x=tbl_disc_tags, i=NULL, j="DISCSUBTITLE", value=NA_character_)

  if (simple_df(r$tbl_discs)){
    discsubtitles <- r$tbl_discs[, .(text = p(Disc_Title, collapse=" / ")),
                                 by=.(DISCNUMBER=Disc)]
    tbl_disc_tags[discsubtitles, DISCSUBTITLE:=i.text, on="DISCNUMBER"]
  }

  tbl_disc_tags[, DISCSUBTITLE:=fix_title(DISCSUBTITLE, case=input$case_discsubtitle, halfwidth=input$halfwidth, various=input$various_text_fixes)]

  tbl_tags <- data.table::copy(tbl_disc_tags)
  idx <- which(!r$tbl_album_tags[["Tag"]] %in% c("VGMDB_CREDITS", "VGMDB_NOTES"))
  data.table::set(x=tbl_tags, i=NULL, j=r$tbl_album_tags[["Tag"]][idx], value=as.list(r$tbl_album_tags[["Value"]][idx]))
  data.table::set(x=tbl_tags, i=NULL, j="DISCTOTAL", value=as.integer(tbl_tags[["DISCTOTAL"]]))

  formatted_discsubtitle <- apply_format_code(
    format_code = input$discsubtitle_format_code,
    tbl_tags = tbl_tags,
    min_width = list(),
    autopad = FALSE,
    filename = FALSE
  )

  tbl_disc_tags[, DISCSUBTITLE:=formatted_discsubtitle]
  data.table::setcolorder(tbl_disc_tags, c("DISCNUMBER", "TRACKTOTAL", "CATALOGNUMBER", "DISCSUBTITLE", "VGMDB_CLASSIFICATION"))
  tbl_disc_tags
}


create_track_tags <- function(r, input){
  if (!simple_df(r$tbl_tracklist)){
    return(init_tbl_track_tags)
  }

  artist_tags <- unique(c(getOption("vgm_main_tags"), getOption("vgm_performer_tags")))
  order_track_tags <- c("DISCNUMBER", "TRACKNUMBER", "TITLE", "COMMENT", "ARTIST", artist_tags)

  # Prepare tag table
  tbl_track_tags <- data.table::copy(r$tbl_tracklist)
  data.table::set(x=tbl_track_tags, i=NULL, j="Length", value=NULL)
  data.table::set(x=tbl_track_tags, i=NULL, j="IDX", value=seq_len(nrow(tbl_track_tags)))
  data.table::setnames(tbl_track_tags, c("Disc", "Track", "Title"), c("DISCNUMBER", "TRACKNUMBER", "TITLE"))

  # Initialize missing columns
  missing_tags <- order_track_tags[!order_track_tags %in% colnames(tbl_track_tags)]
  data.table::set(x=tbl_track_tags, i=NULL, j=missing_tags, value=NA_character_)

  # Add COMMENT tag
  if (simple_df(r$tbl_comments)){
    comments <- r$tbl_comments[, .(text = p(unique(Comment), collapse=input$sep_multi_value)),
                               by = .(DISCNUMBER=Disc, TRACKNUMBER=Track)]
    tbl_track_tags[comments, COMMENT:=i.text, on=c("DISCNUMBER", "TRACKNUMBER")]
  }

  # Add artist tags
  if (simple_df(r$tbl_credits)){
    credits_main <- r$tbl_credits[
      i = Tag %in% getOption("vgm_main_tags"),
      j = .(text = p(unique(fix_artist(Artist, remove_suffix=input$remove_artist_suffix, case=input$case_artist)), collapse=input$sep_multi_value)),
      by = .(Tag, DISCNUMBER=Disc, TRACKNUMBER=Track)
    ]

    credits_performer <- r$tbl_credits[
      Tag %in% getOption("vgm_performer_tags"),
      .(text = p(fix_artist(Artist, remove_suffix=input$remove_artist_suffix, case=input$case_artist), " (", p(unique(Role), collapse = "/"), ")")),
      by = .(Artist = fix_artist(Artist, remove_suffix=input$remove_artist_suffix, case=input$case_artist), DISCNUMBER = Disc, TRACKNUMBER = Track)
    ][,
      .(Tag = "PERFORMER", text = p(unique(text), collapse = input$sep_multi_value)),
      by = .(DISCNUMBER, TRACKNUMBER)
    ]

    credits <- data.table::rbindlist(list(credits_main, credits_performer), use.names=TRUE)
    credits[tbl_track_tags, IDX:=i.IDX, on=c("DISCNUMBER", "TRACKNUMBER")]

    for (tag in artist_tags){
      idx <- which(credits[["Tag"]] == tag)
      data.table::set(x = tbl_track_tags, i = credits[["IDX"]][idx], j = tag, value = credits[["text"]][idx])
    }
  }

  # Use default values of artist tags
  for (tag in artist_tags){
    default_value <- input[[p("default_", tag)]]

    if (simple_character(default_value)){
      idx <- which(is.na(tbl_track_tags[[tag]]) | stringi::stri_trim(tbl_track_tags[[tag]]) == "")
      data.table::set(x=tbl_track_tags, i=idx, j=tag, value=default_value)
    }
  }

  #TODO: Calculate ARTIST tag --> Own function
  artist_bucket_tags <- input$buckets_ARTIST[c("ba_prio1", "ba_prio2", "ba_prio3")]
  for (tags in artist_bucket_tags){
    idx <- which(is.na(tbl_track_tags[["ARTIST"]]) | stringi::stri_trim(tbl_track_tags[["ARTIST"]]) == "")

    artist <- merge_tags(.subset(tbl_track_tags, tags), sep=input$sep_multi_value)

    data.table::set(x=tbl_track_tags, i=idx, j="ARTIST", value=artist[idx])
  }

  default_value <- input[["default_ARTIST"]]
  if (simple_character(default_value)){

    tbl_track_tags[is.na(ARTIST) | stringi::stri_trim(ARTIST)=="", ARTIST:=default_value]
  }

  tbl_track_tags[stringi::stri_trim(ARTIST)=="", ARTIST:=NA_character_]

  # Fix TITLE here?
  tbl_track_tags[, TITLE:=fix_title(TITLE, case=input$case_title, halfwidth=input$halfwidth, various=input$various_text_fixes)]

  if ("IDX" %in% colnames(tbl_track_tags)){
    data.table::set(x=tbl_track_tags, i=NULL, j="IDX", value=NULL)
  }

  data.table::setcolorder(tbl_track_tags, order_track_tags)
  tbl_track_tags
}


create_all_tags <- function(r, input){
  if (!simple_df(r$tbl_track_tags)){
    return(data.table::data.table())
  }

  all_tags <- data.table::copy(r$tbl_track_tags)

  # Add Albumartist
  data.table::set(x=all_tags, i=NULL, j="ALBUMARTIST", value=input$albumartist)
  data.table::setcolorder(x=all_tags, neworder="ALBUMARTIST", before="ARTIST")

  # Combine track and disc tags
  all_tags <- data.table::merge.data.table(x=all_tags, y=r$tbl_disc_tags, by="DISCNUMBER", all.x=TRUE, all.y=FALSE, sort=FALSE)

  # Add album tags
  data.table::set(x=all_tags, i=NULL, j=r$tbl_album_tags[["Tag"]], value=as.list(r$tbl_album_tags[["Value"]]))
  data.table::set(x=all_tags, i=NULL, j="DISCTOTAL", value=as.integer(all_tags[["DISCTOTAL"]]))

  # Delete discs not selected
  all_tags <- all_tags[as.character(DISCNUMBER) %in% input$all_tags_disc_selection, ]

  # Delete columns without any info
  cols <- which(sapply(all_tags, function(x) all(is.na(x) | stringi::stri_trim(x)=="")))
  data.table::set(x=all_tags, i=NULL, j=cols, value=NULL)

  # Delete DISCNUMBER if checked
  if (r$disctotal <= 1L && !input$all_tags_keep_disc && "DISCNUMBER" %in% colnames(all_tags)){
    data.table::set(x=all_tags, i=NULL, j="DISCNUMBER", value=NULL)
  }

  # Delete VGMDB_CREDITS if checked
  if (!input$all_tags_keep_credits && "VGMDB_CREDITS" %in% colnames(all_tags)){
    data.table::set(x=all_tags, i=NULL, j="VGMDB_CREDITS", value=NULL)
  }

  # Delete VGMDB_NOTES if checked
  if (!input$all_tags_keep_notes && "VGMDB_NOTES" %in% colnames(all_tags)){
    data.table::set(x=all_tags, i=NULL, j="VGMDB_NOTES", value=NULL)
  }

  all_tags
}

get_char_3pp <- function(tbl){
  if (simple_df(tbl)){
    txt <- paste0(c(colnames(tbl), unique(unlist(.subset(tbl, sapply(tbl, is.character))))), collapse="")
  }else{
    txt <- ""
  }

  uncommon_chars <- c("|", "¦", "†", "‡", "¶", "•", "§", "¬", "¤", "×", "÷", "±")
  idx <- which(!stringi::stri_detect_fixed(txt, uncommon_chars))
  uncommon_chars[idx[1L]]
}
