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

server_dt_init <- function(id, r, output,
                           height="100%",
                           rownames=TRUE, ellipsis_cols=NULL, ellipsis_chars=200L,
                           readonly=TRUE, fixed_cols=0L, buttons=FALSE, column_defs=NULL, isolate=TRUE, selection="none"){
  tbl_id <- paste0("tbl_", id)
  dt_id <- paste0("dt_", id)
  opt_id <- paste0("dt_", id, ".rownames")

  options(structure(list(rownames), names=opt_id))

  extensions <- NULL
  plugins <- NULL
  columnDefs <- list()

  if (!is.null(column_defs)){
    columnDefs[[length(columnDefs)+1L]] <- column_defs
  }

  if (!is.null(ellipsis_cols)){
    plugins <- "ellipsis"
    columnDefs[[length(columnDefs)+1L]] <- list(
      targets = if (is.character(ellipsis_cols)) ellipsis_cols else ellipsis_cols - 1L + as.integer(rownames),
      render = DT::JS(paste0("$.fn.dataTable.render.ellipsis(", ellipsis_chars, ", true)"))
    )
  }

  # options$columnDefs must be `NULL` or a list of sub-lists, where each sub-list must contain a `targets` element
  if (length(columnDefs) == 0L){
    columnDefs <- NULL
  }

  if (buttons){
    extensions <- c(extensions, "Buttons")
  }

  if (fixed_cols > 0L){
    extensions <- c(extensions, "FixedColumns")
    fixedColumns <- list(leftColumns = fixed_cols + as.integer(rownames))
  }else{
    fixedColumns <- list()
  }

  if (is.logical(readonly)){
    editable <- !readonly
  }else{
    if (rownames){
      readonly_cols <- c(0L, readonly)
    }else{
      readonly_cols <- readonly - 1L
    }

    editable <- list(target = "cell", disable = list(columns = readonly_cols))
  }

  if (is.list(editable) || editable){
    caption <- "Double-click on a cell to edit its contents. All manual edits will be lost when table refreshes!"
  }else{
    caption <- NULL
  }

  if (length(extensions) == 0L){
    extensions <- list()
  }

  output[[dt_id]] <- DT::renderDT(
    DT::datatable(
      data = if (isolate) shiny::isolate(r[[tbl_id]]) else r[[tbl_id]],
      caption = caption,
      escape = TRUE,
      filter = "none",
      selection = selection,
      rownames = rownames,
      editable = editable,
      plugins = plugins,
      extensions = extensions,
      options = list(
        dom = "Bft",
        paging = FALSE,
        scrollCollapse = TRUE,
        scrollX = TRUE,
        scrollY = height,
        # scrollY = "100%",
        # scroller = TRUE,
        buttons = c("copy", "csv", "excel", "pdf", "print"),
        fixedColumns = fixedColumns,
        columnDefs = columnDefs
      ),
      class = "stripe"
    ),
    server = TRUE
  )
}

server_dt_link <- function(id, r){
  tbl_id <- paste0("tbl_", id)
  dt_id <- paste0("dt_", id)
  rownames <- getOption(paste0("dt_", id, ".rownames"))

  observeEvent(ignoreInit=TRUE, list(r[[tbl_id]]), {
    DT::replaceData(DT::dataTableProxy(dt_id), r[[tbl_id]], rownames=rownames)
  })
}

server_dt_edit <- function(id, r, input){
  tbl_id <- paste0("tbl_", id)
  dt_cell_id <- paste0("dt_", id, "_cell_edit")
  rownames <- getOption(paste0("dt_", id, ".rownames"))

  observeEvent(ignoreInit=TRUE, list(input[[dt_cell_id]]), {
    r[[tbl_id]] <- DT::editData(r[[tbl_id]], input[[dt_cell_id]], rownames=rownames)
  })
}

server_clipboard <- function(text, session){
  session$sendCustomMessage("txt", text)
}
