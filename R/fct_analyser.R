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

check_BLOCK <- function(BLOCK, LINE){
  info_fields <- lapply(BLOCK, function(b){
    unname(sapply(LINE[b$lines], function(l) l$info))
  })

  has_dupes <- sapply(info_fields, function(x){
    anyDuplicated(x) > 0L
  })

  if (any(has_dupes)){
    stop("Block definitons cannot contain the same information (field) in different lines")
  }
}


analyse_line <- function(text, line){
  match <- stringi::stri_match_first_regex(text, pattern=line[["regex"]], opts_regex=list(case_insensitive=TRUE))
  if (all(is.na(match))){ # Do not save matches if they only contain NAs
    logical(0L)
  }else{
    match <- lapply(seq_along(line[["info"]]), function(i){
      stringi::stri_trim(match[, i+1L])
    })
    data.table::setattr(match, "names", line[["info"]])
    match
  }
}

get_blocks <- function(x){
  r <- rle(x != "")
  r$start <- cumsum(r$lengths) - r$lengths + 1L
  lapply(which(r$values), function(i) seq.int(from=r$start[i], length.out=r$lengths[i]))
}

# Identifies a single block and extracts the defined info groups/fields of each line
# This function acts more like a classifier even though the output is organized
# The single info groups/fields still need to be properly parsed and made sense of
analyse_block <- function(block_ids, potential_matches, has_matches){
  len_block <- length(block_ids)

  # Iterate over block definitions in BLOCK and use first matching one
  for (block_def in BLOCK){
    block_def_lines <- block_def[["lines"]]
    block_def_multi <- block_def[["multi"]]
    len_block_def <- length(block_def_lines)

    if (len_block_def > len_block){
      # Block is shorter than block_def --> not possible
      next
    }else if (len_block > len_block_def && sum(block_def_multi) == 0L){
      # Block is larger than block_def BUT we cannot extend block_def --> not possible
      next
    }else{
      # We need to extend block_def to the length of our block
      block_def_size <- (len_block - len_block_def) * block_def_multi + 1L
      # Use a list which maps each line in block_def to the corresponding block_ids
      map_block_def_to_notes <- partition(block_ids, sizes=block_def_size)

      valid_block_def <- TRUE
      # Iterate over lines in block_def and check if all have matches
      for (i in seq_len(len_block_def)){
        line_def_name <- block_def_lines[i]
        idx_notes <- map_block_def_to_notes[[i]]

        if (!all(has_matches[[line_def_name]][idx_notes])){
          valid_block_def <- FALSE
          break
        }
      }

      if (!valid_block_def){
        next
      }

      out <- list()
      max_size <- max(block_def_size)
      # Iterate over lines in block_def and extract matched info
      for (i in seq_len(len_block_def)){
        line_def_name <- block_def_lines[i]
        idx_notes <- map_block_def_to_notes[[i]]
        line_def_info <- LINE[[line_def_name]][["info"]]

        # Iterate over info groups in current line definition
        for (j in seq_along(line_def_info)){
          matches <- potential_matches[[line_def_name]][[j]][idx_notes]
          out[[line_def_info[j]]] <- rep_len(matches, max_size)
        }
      }

      return(data.table::as.data.table(out))
    }
  }

  data.table::data.table()
}


analyse_notes <- function(notes, ra_ar){
  notes <- stringi::stri_trim(notes)

  if (stringi::stri_length(notes) == 0L){
    return(data.table::data.table())
  }

  # Store each line in a separate string and then do the following:
  # 1. tabs --> 4 normal spaces (no special case for tabs, use multiple spaces)
  # 2. whitespaces --> normal spaces (simpler regexes)
  # 3. Remove spaces at beginning (no info)
  # 4. Remove spaces and colons at end (useless punctuation)
  notes_vec <- stringi::stri_split_fixed(notes, "\n")[[1L]]
  notes_vec <- fix_notes_lines(notes_vec)

  NOTES <<- notes_vec

  potential_matches <- lapply(LINE, function(line){
    analyse_line(notes_vec, line)
  })
  has_matches <- data.table::as.data.table(lapply(potential_matches, function(line_def){
    r_avail_n(line_def, length(notes_vec))
  }))


  # If a line matches both "role_artist" and "artist_role", make the decision via option op_ra_ar
  if (ra_ar == "role_artist"){
    idx <- which(has_matches[["role_artist"]] & has_matches[["artist_role"]])
    data.table::set(x=has_matches, i=idx, j="artist_role", value=FALSE)
  }else if (ra_ar == "artist_role"){
    idx <- which(has_matches[["role_artist"]] & has_matches[["artist_role"]])
    data.table::set(x=has_matches, i=idx, j="role_artist", value=FALSE)
  }

  found_info <- data.table::rbindlist(lapply(get_blocks(notes_vec), function(ids){
    analyse_block(ids, potential_matches, has_matches)
  }), fill=TRUE)

  # Carry disc information forward, as discs can define whole sections
  if ("disc" %in% colnames(found_info)){
    data.table::set(x=found_info, i=NULL, j="disc", value=locf(found_info[["disc"]]))
  }

  # Special handling of "all" groups/fields (subject to change)
  if ("all" %in% colnames(found_info)){
    data.table::set(x=found_info, i=which(!is.na(found_info[["all"]])), j="all", value="all")
  }

  # Remove empty lines or lines with only disc info, as we already carried disc info forward
  is_empty <- rep(TRUE, nrow(found_info))
  for (col in setdiff(colnames(found_info), "disc")){
    is_empty <- is_empty & is.na(found_info[[col]])
  }

  # Also remove duplicate info
  unique(found_info[!is_empty, ])
}
