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

'%||%' <- function(x, y){
  if (is.null(x)){
    y
  }else{
    x
  }
}

p <- function(..., sep="", collapse=NULL, recycle0=FALSE){
  paste(..., sep=sep, collapse=collapse, recycle0=recycle0)
}

partition <- function(x, sizes){
  if (sum(sizes) != length(x)){
    stop("Cannot divide 'x' into partitions of size 'sizes'")
  }

  out <- vector(mode="list", length=length(sizes))
  n <- 1L
  for (i in seq_along(sizes)){
    out[[i]] <- x[n:(n+sizes[i]-1L)]
    n <- n + sizes[i]
  }

  out
}

is_clean <- function(x){
  !is.null(x) &
    is.atomic(x) &
    length(x) > 0L &
    !is.na(x) &
    !is.nan(x) &
    !is.infinite(x) &
    if (is.character(x)) x != "" else TRUE
}

# Is single element part of \mathbb{R}_{0}^{+}?
is1_R0p <- function(x){
  !is.null(x) &&
    is.atomic(x) &&
    length(x)==1L &&
    is.numeric(x) &&
    !is.na(x) &&
    !is.nan(x) &&
    !is.infinite(x) &&
    x>=0L
}

locf <- function(x){
  value <- x[1L]
  for (i in seq_along(x)){
    if (is.na(x[i])){
      x[i] <- value
    }else{
      value <- x[i]
    }
  }
  x
}

locf0 <- function(x){
  value <- x[1L]
  for (i in seq_along(x)){
    if (!is.na(x[i]) && x[i]==0L){
      x[i] <- value
    }else{
      value <- x[i]
    }
  }
  x
}

ndigits <- function(x){
  x <- abs(x)
  idx <- which(is.finite(x) & x>0L)
  out <- integer(length(x))
  out[idx] <- as.integer(floor(log10(x[idx])) + 1L)
  out
}

interleave <- function(...){
  ordering <- .Internal(radixsort(
    na.last=TRUE, decreasing=FALSE, FALSE, TRUE,
    unlist(lapply(list(...), seq_along))
  ))
  c(...)[ordering]
}

is_url <- function(url){
  grepl("^https?://", stringi::stri_trim(url), ignore.case=TRUE, fixed=FALSE, perl=TRUE)
}


# Internal Single-Use Functions -------------------------------------------

r_avail_n <- function(x, n){
  if (length(x) == 0L){
    rep(FALSE, n)
  }else if (is.list(x)){
    r_avail_n(x[[1L]], n)
  }else{
    !is.na(x)
  }
}
