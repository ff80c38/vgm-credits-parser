source("../../config/regex.R", local=TRUE)
source("../../R/utils_strings.R", local=TRUE)

check_block <- function(block, output=c("logical", "definition", "match")){
  output <- output[1L]
  block <- stringi::stri_trim(block)
  block <- stringi::stri_split_fixed(block, "\n")[[1L]]
  block <- fix_notes_lines(block)
  match <- data.table::setDT(lapply(LINE, function(line) stringi::stri_detect_regex(block, pattern=line[["regex"]], opts_regex=list(case_insensitive=TRUE))))

  result <- lapply(BLOCK, function(block_def){
    def_lines <- block_def[["lines"]]
    def_multi <- block_def[["multi"]]

    if (length(def_lines) > length(block) || (length(block) > length(def_lines) && sum(def_multi) == 0L)){
      # Block is shorter than block_def --> not possible     OR
      # Block is larger than block_def BUT we cannot extend block_def --> not possible
      if (startsWith(output, "log")) return(FALSE)
      if (startsWith(output, "def")) return()
      stop("'match' not implemented yet")
    }else{
      # We need to extend block_def to the length of our block
      block_def_size <- (length(block) - length(def_lines)) * def_multi + 1L
      vec_j <- rep(def_lines, block_def_size)
      vec_i <- seq_along(block)

      for (k in seq_along(def_lines)){
        if (!.subset2(.subset2(match, vec_j[k]), vec_i[k])){
          if (startsWith(output, "log")) return(FALSE)
          if (startsWith(output, "def")) return()
          stop("'match' not implemented yet")
        }
      }
    }

    if (startsWith(output, "log")) return(TRUE)
    if (startsWith(output, "def")) return(vec_j)
    stop("'match' not implemented yet")
  })

  if (startsWith(output, "log")) result <- unlist(result)
  if (startsWith(output, "def")){
    result <- data.table::setDT(c(list(block), result[!sapply(result, is.null)]))
  }
  result
}
