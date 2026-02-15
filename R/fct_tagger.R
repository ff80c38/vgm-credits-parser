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

metaflac <- function(..., stdout=TRUE){
  cmd <- unname(Sys.which("metaflac"))

  if (cmd != ""){
    system2(cmd, args=c(...), stdout=stdout)
  }else if (.Platform$OS.type == "windows"){
    system2(command=file.path(PATH, "tools", "metaflac.exe"), args=c(...), stdout=stdout)
  }else{
    stop("System not supported.")
  }
}


file_length <- function(files){
  res <- metaflac("--show-total-samples", "--show-sample-rate", shQuote(files))
  num <- as.numeric(sub("^.+:([0-9]+)$", "\\1", res, perl=TRUE))

  total_samples <- num[seq.int(from=1L, to=length(num), by=2L)]
  sample_rate   <- num[seq.int(from=2L, to=length(num), by=2L)]
  total_samples / sample_rate
}


apply_format_code <- function(format_code, tbl_tags, min_width, autopad, filename=TRUE, extension=".flac"){
  regular_expression <- '%\\{(?:"([^"]*)")?([^{}]+?)(?:\\.([0-9]+))?(?:"([^"]*)")?\\}'
  available_tags <- toupper(colnames(tbl_tags))

  variables <- stringi::stri_extract_all_regex(format_code, pattern=regular_expression)[[1L]]
  variable_parts <- stringi::stri_match_all_regex(variables, pattern=regular_expression, cg_missing="")

  data <- lapply(variable_parts, function(x){
    x <- x[1L, -1L]
    tag <- toupper(x[2L])
    idx <- match(tag, available_tags, nomatch=0L)

    if (idx == 0L){
      col <- character(nrow(tbl_tags))
    }else{
      col <- tbl_tags[[idx]]
    }

    if (is.numeric(col)){
      col <- num_pad(col, width=as.integer(x[3L]), min_width=min_width[[tag]], autopad=autopad)
    }

    if (filename){
      col <- fix_filename_chars(col)
    }

    ifelse(is_clean(col), paste0(x[1L], col, x[4L]), "")
  })

  text_between <- stringi::stri_split_regex(format_code, regular_expression)[[1L]]
  output <- do.call(paste0, interleave(text_between, data))

  if (filename){
    raw_paths <- stringi::stri_split_regex(output, "/|\\\\")
    clean_paths <- unlist(lapply(raw_paths, function(x){
      x[length(x)] <- paste0(x[length(x)], extension)
      x <- fix_filename(x)
      x <- x[is_clean(x)]
      do.call(file.path, as.list(x))
    }))
    output <- unlist(clean_paths)
  }

  output
}


resize_cover <- function(path, cover_small, method="min", size=700L, quality=80L){
  file_out <- file.path(dirname(path), "cover_small.jpg")

  if (method == "min"){
    resize_flag <- "^"
  }else{
    resize_flag <- ""
  }

  identify <- Sys.which("identify")
  magick <- Sys.which("magick")

  if (identify != "" && magick != ""){
    arg_in <- shQuote(path)
    arg_resize <- NULL
    arg_quality <- paste0("-quality ", quality)
    arg_out <- paste0("jpg:", shQuote(file_out))

    dims <- system2(identify, args=c("-format", '"%w\t%h"', arg_in), stdout=TRUE)
    dims <- as.integer(strsplit(dims, "\t", fixed=TRUE)[[1L]])

    if (size > 0L && min(dims) > size){
      arg_resize <- paste0("-resize ", size, "x", size, resize_flag)
    }

    system2(magick, args=c(arg_in, arg_resize, arg_quality, arg_out))
  }else if (require("magick", include.only=character(), quietly=TRUE)){
    # Depend on CRAN magick package
    img <- magick::image_read(path)
    dims <- as.integer(magick::image_info(img)[c("width", "height")])

    if (size > 0L && min(dims) > size){
      img <- magick::image_resize(img, paste0(size, "x", size, resize_flag))
    }

    magick::image_write(img, path=file_out, format="jpeg", quality=quality)
  }else{
    # Image Magick is installed neither locally nor via CRAN --> Use small cover from VGMdb
    utils::download.file(url=cover_small, destfile=file_out, method="auto", quiet=TRUE, mode="wb")
  }

  file_out
}


metaflac_args <- function(tag, value){
  tag <- stringi::stri_trim(tag)
  value <- stringi::stri_trim(value)

  idx <- which(!is.na(value) & value!="")
  if (length(idx) > 0L){
    c(paste0("--remove-tag=", tag[idx]),
      paste0("--set-tag=", tag[idx], "=", shQuote(value[idx])))
  }else{
    character()
  }
}


match_files <- function(files, f_structure, f_length, tbl_files, seconds){
  f_tracks <- sapply(f_structure, length)

  t_structure <- unname(split(seq_along(tbl_files[["Disc"]]), tbl_files[["Disc"]]))
  t_tracks <- sapply(t_structure, length)
  t_length <- tbl_files[["Length"]]

  disc_matches <- lapply(f_tracks, function(x) which(x == t_tracks))
  n_disc_matches <- sapply(disc_matches, length)

  map <- integer(length(f_tracks))

  if (any(n_disc_matches == 0L)){
    # There is at least one disc of flac files that does not have a corresponding disc in our tracklist
  }else if (all(n_disc_matches == 1L)){
    # Every f_disc matches exactly one t_disc --> We can uniquely map them
    map <- unlist(disc_matches)
  }else{
    # Try to whittle down the number of disc matches via track length
    for (i in seq_along(map)){
      f_length_i <- f_length[f_structure[[i]]]
      idx_match <- c()
      for (j in disc_matches[[i]]){
        t_length_j <- t_length[t_structure[[j]]]
        if (any(is.na(t_length_j))) next
        if (all(abs(f_length_i - t_length_j) <= seconds)){
          idx_match <- c(idx_match, j)
        }
      }
      disc_matches[[i]] <- idx_match
    }

    # Use first matching t_disc in (previously) sorted order
    for (i in seq_along(map)){
      map[i] <- setdiff(disc_matches[[i]], map[seq_len(i-1L)])[1L]
    }
  }

  map
}


create_tbl_files <- function(r, input){
  folder <- normalizePath(input$folder)

  if (!dir.exists(folder)){
    return(init_tbl_files)
  }

  folder_tagged <- normalizePath(file.path(folder, "_tagged"), mustWork=FALSE)

  # Get all flac files, exclude files located in "_tagged" output folder and sort by numeric part
  files <- list.files(folder, full.names=TRUE, pattern="\\.flac$", ignore.case=TRUE, recursive=TRUE)
  files <- files[!startsWith(files, folder_tagged)]
  files <- files[stringi::stri_order(files, opts_collator=list(locale="en", numeric=TRUE))]


  if (!input$all_tags_keep_disc && r$disctotal <= 1L){
    tbl_files <- r$tbl_all_tags[, .(Disc=1L, Track=TRACKNUMBER)]
  }else{
    tbl_files <- r$tbl_all_tags[, .(Disc=DISCNUMBER, Track=TRACKNUMBER)]
  }

  tbl_files[r$tbl_tracklist, Length:=round(hms_to_secs(i.Length), 1L), on=c("Disc", "Track")]
  tbl_files[r$tbl_filenames, Filename:=i.Filename, on=c("Disc", "Track")]

  files_length <- file_length(files)

  if (input$file_matching_method == "auto"){
    files_structure <- unname(split(seq_along(files), dirname(files)))

    map <- match_files(f_structure=files_structure, f_length=files_length,
                       tbl_files=tbl_files, seconds=input$file_matching_time_diff)
    if (length(unique(map)) != length(map) || any(map == 0L)){
      return(init_tbl_files) # Matching did not work as expected
    }

    for (i in seq_along(map)){
      idx <- files_structure[[i]]
      tbl_files[Disc == map[i], ':='(File_Length=round(files_length[idx], 1L), File_In=files[idx])]
    }
  }else{
    idx <- seq_len(max(nrow(tbl_files), length(files)))
    tbl_files[idx, ':='(File_Length=round(files_length[idx], 1L), File_In=files[idx])]
  }

  tbl_files[, File_Out:=normalizePath(file.path(folder_tagged, Filename), mustWork=FALSE)]
  tbl_files[, Filename:=NULL]
  tbl_files <- tbl_files[!is.na(File_In), ]

  if (!input$all_tags_keep_disc && r$disctotal <= 1L){
    tbl_files[, Disc:=NULL]
  }

  tbl_files
}


create_tbl_filenames <- function(r, input){
  if (!simple_df(r$tbl_all_tags)){
    return(init_tbl_filenames)
  }

  vec_filename <- apply_format_code(
    format_code = input$filename_format_code,
    tbl_tags = r$tbl_all_tags,
    min_width = list(
      "DISCNUMBER" = input$filename_min_width_disc,
      "DISCTOTAL" = input$filename_min_width_disc,
      "TRACKNUMBER" = input$filename_min_width_track,
      "TRACKTOTAL" = input$filename_min_width_track
    ),
    filename = TRUE,
    autopad = input$filename_min_width_auto,
    extension = ".flac"
  )

  if (!input$all_tags_keep_disc && r$disctotal <= 1L){
    tbl_filenames <- data.table::copy(r$tbl_all_tags[, .(Disc=1L, Track=TRACKNUMBER)])
  }else{
    tbl_filenames <- data.table::copy(r$tbl_all_tags[, .(Disc=DISCNUMBER, Track=TRACKNUMBER)])
  }

  data.table::set(x=tbl_filenames, i=NULL, j="Filename", value=vec_filename)
  tbl_filenames
}


tag_flac_files <- function(r, input, updateProgress=NULL){
  folder <- normalizePath(input$folder, mustWork=FALSE)
  folder_tagged <- file.path(folder, "_tagged")

  if (!dir.exists(folder_tagged)){
    dir.create(folder_tagged)
  }

  cover <- r$cover

  cover_ext <- c()
  cover_ext["large"] <- stringi::stri_extract_first_regex(cover["large"], "\\.[^.]+$")

  cover_path <- c()
  cover_path["large"] <- normalizePath(file.path(folder_tagged, paste0("cover", cover_ext["large"])), mustWork=FALSE)

  if (!file.exists(cover_path["large"])){
    utils::download.file(url=cover["large"], destfile=cover_path["large"], method="auto", quiet=TRUE, mode="wb")
  }

  cover_path["small"] <- resize_cover(
    path = cover_path["large"],
    cover_small = cover["small"],
    method = input$cover_resize_method,
    size = input$cover_resize_size,
    quality = 80L
  )
  on.exit(file.remove(cover_path["small"]))

  if (!input$all_tags_keep_disc && r$disctotal <= 1L){
    tbl <- data.table::merge.data.table(r$tbl_files, r$tbl_all_tags, by.x=c("Track"), by.y=c("TRACKNUMBER"), all.x=TRUE, sort=FALSE)
    data.table::setnames(x=tbl, old=c("Track"), new=c("TRACKNUMBER"))
  }else{
    tbl <- data.table::merge.data.table(r$tbl_files, r$tbl_all_tags, by.x=c("Disc", "Track"), by.y=c("DISCNUMBER", "TRACKNUMBER"), all.x=TRUE, sort=FALSE)
    data.table::setnames(x=tbl, old=c("Disc", "Track"), new=c("DISCNUMBER", "TRACKNUMBER"))
  }

  files_in <- tbl[["File_In"]]
  files_out <- tbl[["File_Out"]]
  data.table::set(x=tbl, i=NULL, j=c("Length", "File_Length", "File_In", "File_Out"), value=NULL)

  args_cover <- c(
    "--remove-tag=METADATA_BLOCK_PICTURE",
    "--remove-tag=COVERART",
    paste0("--import-picture-from=", shQuote(cover_path["small"]))
  )

  args_remove <- c(
    "--remove-tag=TOTALDISCS",
    "--remove-tag=TOTALTRACKS",
    "--remove-tag=TRACK"
  )

  if (input$remove_sort_tags){
    args_remove <- c(
      args_remove,
      "--remove-tag=ALBUMARTISTSORT",
      "--remove-tag=ALBUMSORT",
      "--remove-tag=ARTISTSORT",
      "--remove-tag=COMPOSERSORT",
      "--remove-tag=TITLESORT"
    )
  }

  if (input$remove_musicbrainz_tags){
    args_remove <- c(
      args_remove,
      "--remove-tag=MUSICBRAINZ_ALBUMARTISTID",
      "--remove-tag=MUSICBRAINZ_ALBUMID",
      "--remove-tag=MUSICBRAINZ_ARTISTID",
      "--remove-tag=MUSICBRAINZ_DISCID",
      "--remove-tag=MUSICBRAINZ_ORIGINALALBUMID",
      "--remove-tag=MUSICBRAINZ_ORIGINALARTISTID",
      "--remove-tag=MUSICBRAINZ_RELEASEGROUPID",
      "--remove-tag=MUSICBRAINZ_RELEASETRACKID",
      "--remove-tag=MUSICBRAINZ_TRACKID",
      "--remove-tag=MUSICBRAINZ_TRMID",
      "--remove-tag=MUSICBRAINZ_WORKID"
    )
  }

  tag_names <- colnames(tbl)
  data.table::setattr(tbl, "class", NULL)
  data <- data.table::transpose(tbl)

  for (i in seq_along(data)){
    if (is.function(updateProgress)){
      text <- paste0(i, "/", length(data), " files")
      updateProgress(detail = text)
    }else{
      cat("\r", i, "/", length(data), sep="")
    }

    args_file <- shQuote(files_out[i])
    args_tags <- metaflac_args(tag_names, data[[i]])

    file.copy(files_in[i], files_out[i], overwrite=FALSE, copy.mode=TRUE, copy.date=TRUE)

    # Separate function call for "--remove --block-type" as metaflac cannot mix major and minor parameters
    metaflac("--remove --block-type=PICTURE", args_file)
    metaflac(args_remove, args_cover, args_tags, args_file)
  }
}
