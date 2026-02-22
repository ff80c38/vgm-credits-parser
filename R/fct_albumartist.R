# -----------------------------------------------------------------------------
# Copyright (c) 2026 ff80c38
# Licensed under the MIT License. See LICENSE file for details.
# -----------------------------------------------------------------------------

hms_to_secs <- function(str){
  unlist(lapply(stringi::stri_split_fixed(str, ":"), function(x){
    sum(as.integer(x) * 60L^((length(x)-1L):0L))
  }))
}

create_artist_scores <- function(r, input){
  if (!simple_df(r$tbl_track_tags)){
    return(init_artist_scores)
  }

  container <- list()
  for (tag in c("ARTIST", "COMPOSER", "ARRANGER", "REMIXER", "VOCALIST", "LYRICIST", "CONDUCTOR", "PERFORMER")){
    artist_list <- stringi::stri_split_fixed(.subset2(r$tbl_track_tags, tag), input$sep_multi_value)
    times <- vapply(artist_list, length, 1L)

    container[[length(container)+1L]] <- data.table::data.table(
      IDX = rep(seq_len(nrow(r$tbl_track_tags)), times),
      Tag = tag,
      Artist = unlist(artist_list),
      Length = rep(hms_to_secs(r$tbl_tracklist[["Length"]]), times)
    )
  }

  artist_overview <- data.table::rbindlist(container)
  artist_overview <- artist_overview[!is.na(Artist) & Artist!="", ]

  artist_overview[Tag=="PERFORMER",
                  Artist:=stringi::stri_trim(stringi::stri_replace_all_regex(Artist, "\\([^()]*\\)$", ""))]

  artist_distinct <- unique(artist_overview[, .(IDX, Artist, Length)])
  scores_total <- artist_distinct[, .(Tag="Total", Tracks=.N, Length=sum(Length)), by="Artist"]
  scores_roles <- artist_overview[, .(Tracks=.N, Length=sum(Length)), by=c("Artist", "Tag")]

  scores <- rbind(scores_total, scores_roles)
  scores[, Tag:=factor(Tag, levels=unique(Tag))]
  scores[, Length:=round(Length/60, 1)]

  artist_scores <- list()
  artist_scores[["tbl_tracks"]] <- data.table::dcast(scores, Artist~Tag, value.var="Tracks", fill=0)
  artist_scores[["tbl_length"]] <- data.table::dcast(scores, Artist~Tag, value.var="Length", fill=0)

  # Sort tables by score
  for (tbl in artist_scores){
    if (!simple_df(tbl)){
      next
    }

    if (!"ARTIST" %in% colnames(tbl)){
      data.table::set(x=tbl, i=NULL, j="ARTIST", value=0)
      data.table::setcolorder(tbl, "ARTIST", after="Total")
    }

    cols <- c("ARTIST", intersect(unlist(input$buckets_ARTIST), colnames(tbl)), "Artist")
    order <- rep(-1L, length(cols))
    order[length(order)] <- 1L
    data.table::setorderv(tbl, cols=cols, order=order)
  }

  artist_scores
}

calculate_albumartist <- function(r, input){
  total_tracks <- nrow(r$tbl_tracklist)
  total_length <- round(sum(hms_to_secs(r$tbl_tracklist[["Length"]]))/60, 1)

  if (input$albumartist_method == "length"){
    unit <- "minutes"
    total <- total_length
    threshold <- round(total * input$albumartist_threshold/100, 1)
    tbl <- r$artist_scores[["tbl_length"]]
  }else{
    unit <- "tracks"
    total <- total_tracks
    threshold <- ceiling(total * input$albumartist_threshold/100)
    tbl <- r$artist_scores[["tbl_tracks"]]
  }

  blurb <- shiny::renderUI(shiny::HTML(paste0(
    "<em>Minimum of ", threshold, " / ", total, " ", unit, " credited as </em><code>ARTIST</code><em> needed</em>"
  )))

  if (simple_df(tbl)){
    albumartist <- paste0(tbl[["Artist"]][tbl[["ARTIST"]] >= threshold], collapse=input$sep_multi_value)
  }else{
    albumartist <- ""
  }

  list(
    ALBUMARTIST = albumartist,
    blurb = blurb
  )
}
