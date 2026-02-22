# -----------------------------------------------------------------------------
# Copyright (c) 2026 ff80c38
# Licensed under the MIT License. See LICENSE file for details.
# -----------------------------------------------------------------------------

ui_radiobutton_case <- function(id, selected=""){
  shiny::radioButtons(
    inputId = id,
    label = NULL,
    choices = list(
      "No Changes" = "",
      "Lower Case" = "lower",
      "Upper Case" = "upper",
      "Title Case" = "title",
      "Force Title Case" = "force_title",
      "Proper Case" = "proper",
      "Sentence Case" = "sentence"
    ),
    selected = selected
  )
}

ui_textinput_default <- function(tag, id = NULL){
  if (is.null(id)){
    id <- paste0("default_", tag)
  }

  list(
    shiny::span(shiny::code(tag), class="input-label"),
    shiny::textInput(id, NULL, "")
  )
}

ui_input_grid <- function(...){
  shiny::div(class="input-grid", ...)
}

ui_info <- function(...){
  bslib::tooltip(
    trigger = bsicons::bs_icon("info-circle"),
    shiny::HTML(paste0(..., collapse=""))
  )
}

ui_page_container <- function(...) {
  shiny::div(class="page-container", ...)
}

ui_sidebar_scroll <- function (..., width){
  shiny::div(
    class = paste0("col-sm-", width),
    shiny::tags$form(class="well scroll-container", role="complementary", ...)
  )
}

ui_sidebar_fill <- function(..., width){
  shiny::div(
    class = paste0("col-sm-", width),
    shiny::tags$form(class="well fill-container", role="complementary", ...)
  )
}

ui_mainpanel <- function(..., width=8){
  shiny::div(
    class = paste0("col-sm-", width, " limited-container"),
    role = "main",
    ...
  )
}

ui_datatable <- function(id) {
  shiny::div(
    class = "datatable-scroll",
    DT::DTOutput(id, height="100%"),
    style = paste0("font-size: ", getOption("vgm_table_fontsize"), ";")
  )
}

ui_vertical_space <- function() {
  shiny::div(class="vertical-space")
}

ui_vertical_space_small <- function() {
  shiny::div(class="vertical-space-small")
}

ui_vertical_space_large <- function() {
  shiny::div(class="vertical-space-large")
}

ui_row <- function(...){
  shiny::div(class="row unset-height", ...)
}
