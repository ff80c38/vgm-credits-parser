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

str_dist_slow <- function(x){
  dist <- stringdist::stringdist(vgmdb_roles[["alias"]], tolower(x), method="dl")
  as.integer(c(min(dist), which.min(dist)))
}

# Parse Simple Fields -----------------------------------------------------

encode_disctrack <- function(disc, track){
  disc * 100000L + track
}

decode_disctrack <- function(disctrack){
  list(
    "disc" = disctrack %/% 100000L,
    "track" = disctrack %% 100000L
  )
}

parse_artist <- function(x){
  out <- stringi::stri_split_regex(x, SEP["artist"], simplify=FALSE)
  lapply(out, stringi::stri_trim)
}

parse_role <- function(x){
  out <-  stringi::stri_split_regex(x, SEP["role"], simplify=FALSE)
  lapply(out, function(x) stringi::stri_trim(stringi::stri_replace_all_regex(x, " +by[ :]*$", "")))
}

parse_disc <- function(x){
  int_x <- as.integer(stringi::stri_replace_all_regex(
    str = x,
    pattern = c(paste0("(^|[^a-zA-Z])", NUMBERS, "([^a-zA-Z]|$)"), "[^0-9]"),
    replacement = c(seq_along(NUMBERS), ""),
    vectorize_all = FALSE,
    opts_regex = list(case_insensitive=TRUE)
  ))

  int_x[is.na(int_x)] <- 0L
  int_x
}

parse_track_ranges <- function(track_ranges, disc_ranges=0L, disc_notes=0L){
  d1 <- as.integer(track_ranges[, 2L])
  t1 <- as.integer(track_ranges[, 3L])
  d2 <- as.integer(track_ranges[, 4L])
  t2 <- as.integer(track_ranges[, 5L])

  # If range has no end point, use start point
  t2[t2==0L] <- t1[t2==0L]

  # If missing, get disc information from other side of range
  d2[d2==0L] <- d1[d2==0L]
  d1[d1==0L] <- d2[d1==0L]

  if (any(d1 != d2)){
    stop("different discs not supported")
  }

  # If disc was specified in any range earlier, continue to use that
  d1 <- locf0(d1)
  d2 <- locf0(d2)

  # If disc info was not specified in range, use disc_ranges value
  d1[d1==0L] <- disc_ranges
  d2[d2==0L] <- disc_ranges

  # If there was no disc_ranges value, use disc_notes value
  d1[d1==0L] <- disc_notes
  d2[d2==0L] <- disc_notes

  # If there was no disc_notes value, use disc = 1 as default
  d1[d1==0L] <- 1L
  d2[d2==0L] <- 1L

  disctracks <- lapply(seq_along(d1), function(i){
    encode_disctrack(
      disc = d1[i],
      track = seq.int(from=min(t1[i], t2[i]), to=max(t1[i], t2[i]), by=1L)
    )
  })

  # Might be redundant as we the same thing one level higher up
  sort(unique(unlist(disctracks)))
}

parse_track_line <- function(tracks_line, discs_line, disc_notes){
  if (length(tracks_line)==1L && is.na(tracks_line)){
    return(NA_integer_)
  }

  # Parse disc groups into a single integer vector
  disc_ranges <- parse_disc(c(NA, discs_line[, 2L]))
  # Extract matrices with track ranges from track groups
  track_ranges <- stringi::stri_match_all_regex(
    str = tracks_line,
    pattern = TRACK["track"],
    opts_regex = list(case_insensitive=TRUE),
    omit_no_match = TRUE,
    cg_missing = "0"
  )

  # Parse track range matrices and corresponding discs to disctrack IDs
  disctracks <- lapply(seq_along(track_ranges), function(i){
    parse_track_ranges(
      track_ranges = track_ranges[[i]],
      disc_ranges = disc_ranges[i],
      disc_notes = disc_notes
    )
  })

  disctracks <- sort(unique(unlist(disctracks)))
  if (is.null(disctracks)){
    disctracks <- NA_integer_
  }
  disctracks
}


# add disc_notes here and in every sub-function
parse_track <- function(track_notes, disc_notes=NULL){
  # Split every line into groups of discs, e.g. the line
  # "disc1: 1,3,5,9,10,13 / disc2: 1,2,13,14,20" would be split into two groups
  group_tracks <- stringi::stri_split_regex(track_notes, TRACK["disc"], opts_regex=list(case_insensitive=TRUE))
  group_discs_short <- stringi::stri_match_all_regex(track_notes, TRACK["disc"], omit_no_match=TRUE, opts_regex=list(case_insensitive=TRUE))

  # Iterate over all (grouped) lines
  lapply(seq_along(group_tracks), function(i){
    parse_track_line(
      tracks_line = group_tracks[[i]],
      discs_line = group_discs_short[[i]],
      disc_notes = disc_notes[i]
    )
  })
}


parse_found_info <- function(found_info, tracklist){
  found_fields <- colnames(found_info)

  if ("artist" %in% found_fields){
    artist_list <- parse_artist(found_info[["artist"]])
  }else{
    artist_list <- rep(list(NA_character_), nrow(found_info))
  }

  if ("role" %in% found_fields){
    role_list <- parse_role(found_info[["role"]])
  }else{
    role_list <- rep(list(NA_character_), nrow(found_info))
  }

  if ("disc" %in% found_fields){
    disc_vec <- parse_disc(found_info[["disc"]])
  }else{
    disc_vec <- integer(nrow(found_info))
  }

  if ("track" %in% found_fields){
    disctrack_list <- parse_track(track_notes = found_info[["track"]], disc_notes = disc_vec)
  }else{
    disctrack_list <- rep(list(NA_integer_), nrow(found_info))
  }

  if ("discsubtitle" %in% found_fields){
    discsubtitle_vec <- found_info[["discsubtitle"]]
    idx <- which(!is.na(discsubtitle_vec))

    table_disc <- unique(data.table::data.table(
      "Disc" = disc_vec[idx],
      "Disc_Title" = discsubtitle_vec[idx]
    ))
    data.table::setorderv(table_disc, c("Disc"), na.last=TRUE)
  }else{
    table_disc <- init_tbl_discs
  }

  if ("comment" %in% found_fields){
    comment_vec <- found_info[["comment"]]
    idx <- which(!is.na(comment_vec))

    disc_track <- decode_disctrack(unlist(disctrack_list[idx]))

    table_comment <- unique(data.table::data.table(
      "Disc" = disc_track[["disc"]],
      "Track" = disc_track[["track"]],
      "Comment" = rep(comment_vec[idx], sapply(disctrack_list[idx], length))
    ))

    data.table::setorderv(table_comment, c("Disc", "Track"), na.last=TRUE)
  }else{
    table_comment <- init_tbl_comments
  }

  disctrack_all <- encode_disctrack(tracklist[["Disc"]], tracklist[["Track"]])
  disc_all <- unique(tracklist[["Disc"]])

  if ("all" %in% found_fields){
    all_vec <- found_info[["all"]]
    idx <- which(!is.na(all_vec))

    table_credit_all <- data.table::rbindlist(lapply(idx, function(i){
      data.table::CJ(
        "Disc" = 0L,
        "Track" = 0L,
        "disctrack" = disctrack_all,
        "Role_Text" = role_list[[i]],
        "Artist" = artist_list[[i]],
        sorted = FALSE,
        unique = TRUE
      )
    }))

    disc_track <- decode_disctrack(table_credit_all[["disctrack"]])
    data.table::set(x=table_credit_all, i=NULL, j=c("Disc", "Track"), value=disc_track)
    data.table::set(x=table_credit_all, i=NULL, j="disctrack", value=NULL)

    print(table_credit_all)
  }else{
    table_credit_all <- data.table::data.table()
  }

  table_credit_track <- data.table::rbindlist(lapply(seq_along(role_list), function(i){
    data.table::CJ(
      "Disc" = 0L,
      "Track" = 0L,
      "disctrack" = disctrack_list[[i]],
      "Role_Text" = role_list[[i]],
      "Artist" = artist_list[[i]],
      sorted=FALSE, unique=TRUE
    )
  }))

  disc_track <- decode_disctrack(table_credit_track[["disctrack"]])
  data.table::set(x=table_credit_track, i=NULL, j=c("Disc", "Track"), value=disc_track)
  data.table::set(x=table_credit_track, i=NULL, j="disctrack", value=NULL)

  # Combine both credit tables
  table_credit <- data.table::rbindlist(list(table_credit_all, table_credit_track), fill=TRUE)
  data.table::setorderv(table_credit, c("Disc", "Track"), na.last=TRUE)
  table_credit <- unique(table_credit[!is.na(Disc) & !is.na(Track) & !is.na(Role_Text) & !is.na(Artist), ])

  # Infer clean role from vgmdb_roles
  unique_roles <- unique(table_credit[["Role_Text"]])

  if (length(unique_roles) > 0L){
    role_dist <- lapply(unique_roles, str_dist)
    idx <- sapply(role_dist, function(x) x[2L])

    matched_roles <- data.table::data.table(
      "Role_Text" = unique_roles,
      "Role" = vgmdb_roles[["role"]][idx],
      "Tag" = vgmdb_roles[["tag"]][idx]
    )

    table_credit[matched_roles, ':='(Role=i.Role, Tag=i.Tag), on="Role_Text"]
  }else{
    table_credit[, ':='(Role=NA_character_, Tag=NA_character_)]
  }

  table_credit <- table_credit[, .(Role_Text=p(unique(Role_Text), collapse=" / ")), by=.(Disc, Track, Role, Artist, Tag)]

  # Split into match and no-match tables
  table_nomatch_credit <- table_credit[!encode_disctrack(Disc, Track) %in% disctrack_all, ]
  table_credit <- table_credit[encode_disctrack(Disc, Track) %in% disctrack_all, ]
  table_nomatch_comment <- table_comment[!encode_disctrack(Disc, Track) %in% disctrack_all, ]
  table_comment <- table_comment[encode_disctrack(Disc, Track) %in% disctrack_all, ]
  table_nomatch_disc <- table_disc[!Disc %in% disc_all, ]
  table_disc <- table_disc[Disc %in% disc_all, ]

  list(
    table_credit = table_credit,
    table_comment = table_comment,
    table_disc = table_disc,
    table_nomatch_credit = table_nomatch_credit,
    table_nomatch_comment = table_nomatch_comment,
    table_nomatch_disc = table_nomatch_disc
  )
}
