# -----------------------------------------------------------------------------
# Copyright (c) 2026 ff80c38
# Licensed under the MIT License. See LICENSE file for details.
# -----------------------------------------------------------------------------

server <- function(input, output, session){
  if (getOption("vgm_live_theme")){
    bslib::bs_themer()
  }

  # Stop the shiny server when a browser tab is closed
  session$onSessionEnded(shiny::stopApp)

  # Reactive Objects --------------------------------------------------------
  # Stuff we create and change inside the app

  r <- shiny::reactiveValues(
    url = "",
    tracklists = list(),
    album_tags = list(),
    cover = character(2L),
    disctotal = 1L,

    # data.tables linked to DTs
    # Section 1
    tbl_album_info = init_tbl_album_info,
    tbl_tracklist = init_tbl_tracklist,
    # Section 2
    tbl_found_info = init_tbl_found_info,
    tbl_credits = init_tbl_credits,
    tbl_comments = init_tbl_comments,
    tbl_discs = init_tbl_discs,
    tbl_nomatch_credit = init_tbl_credits,
    # Section 3
    tbl_album_tags = init_tbl_album_tags,
    tbl_disc_tags = init_tbl_disc_tags,
    tbl_track_tags = init_tbl_track_tags,
    tbl_artist_scores = init_artist_scores[[1L]],
    # Section 4
    tbl_filenames = init_tbl_filenames,
    tbl_files = init_tbl_files
  )


  # Section 1 ---------------------------------------------------------------

  shiny::observeEvent(input$get_dummy, {
    r$tracklists <- get_dummy_tracklists(input$url)
    r$tbl_album_info <- init_tbl_album_info
    r$album_tags <- list(VGMDB_NOTES = "")
    r$cover <- c(small = "", large = "")
  })


  # get Album
  shiny::observeEvent(input$get_album, {
    r$url <- input$url
    scraped_album <- scrape_album(input$url)

    # album_page only contains 4 elements, store them in r
    r$tracklists <- scraped_album$tracklists
    r$tbl_album_info <- scraped_album$album_info
    r$album_tags <- scraped_album$album_tags
    r$cover <- scraped_album$cover
  })


  # Disable Album-get-Button
  shiny::observeEvent(ignoreInit=TRUE, list(input$url, r$url), {
    if (is_url(input$url) && input$url == r$url){
      updateActionButton(session, "get_album", disabled=TRUE)
    }else{
      updateActionButton(session, "get_album", disabled=FALSE)
    }
  })

  # Update selectable tracklist languages after album has been geted
  shiny::observeEvent(ignoreInit=TRUE, list(r$tracklists), {
    updateSelectInput(session, "tracklist_language", choices=names(r$tracklists), selected=names(r$tracklists)[1L])
  })

  shiny::observeEvent(ignoreInit=TRUE, list(r$tracklists, input$tracklist_language), {
    r$disctotal <- r$tracklists[[input$tracklist_language]]$album_tags[["DISCTOTAL"]]
  })

  # Update small preview cover after album has been geted
  shiny::observeEvent(ignoreInit=TRUE, list(r$cover), {
    output$cover <- renderText({
      paste0('<div class="container"><img src="', r$cover["small"], '"></div>')
    })
  })

  # Change tracklist table based on selected language
  shiny::observeEvent(
    ignoreInit=TRUE,
    list(
      r$tracklists,
      input$tracklist_language
    ), {
      r$tbl_tracklist <- r$tracklists[[input$tracklist_language]]$table
    }
  )


  # Section 2 ---------------------------------------------------------------

  output$editor <- shiny::renderUI({
    args <- getOption("vgm_editor")
    args$outputId <- "ace"
    args$value <- r$album_tags$VGMDB_NOTES
    if (is.null(args$value)){
      args$value <- ""
    }
    do.call(shinyAce::aceEditor, args)
  })

  shiny::observeEvent(input$ace_theme, {
    shinyAce::updateAceEditor(session, "ace", theme=input$ace_theme)
  })

  # Send notes to editor after album has been fetched
  shiny::observeEvent(r$album_tags, {
    shinyAce::updateAceEditor(session, "ace", value=r$album_tags$VGMDB_NOTES)
  })

  # Reset notes to VGMdb default
  shiny::observeEvent(ignoreInit=TRUE, list(input$reset_notes), {
    shinyAce::updateAceEditor(session, "ace", value=r$album_tags$VGMDB_NOTES)
  })

  # Parse notes edited by User
  shiny::observeEvent(ignoreInit=TRUE, list(input$ace, input$ra_ar), {
    r$tbl_found_info <- analyse_notes(notes=input$ace, ra_ar=input$ra_ar)
  })

  # Update Detected Info Tabs (Counters)
  shiny::observeEvent(ignoreInit=FALSE, list(r$tbl_found_info, r$tbl_tracklist), {
    if (nrow(r$tbl_found_info) > 0L){
      parsed_info <- parse_found_info(r$tbl_found_info, r$tbl_tracklist)

      r$tbl_credits <- parsed_info$table_credit
      r$tbl_comments <- parsed_info$table_comment
      r$tbl_discs <- parsed_info$table_disc

      r$tbl_nomatch_credits <- parsed_info$table_nomatch_credit
      r$tbl_nomatch_comments <- parsed_info$table_nomatch_comment
      r$tbl_nomatch_discs <- parsed_info$table_nomatch_disc

    }

    # Update Counters for Parsed Table Tabs
    output$tab_parsed_credits <- renderText(p("Track Credits (", nrow(r$tbl_credits), ")"))
    output$tab_parsed_comments <- renderText(p("Comments (", nrow(r$tbl_comments), ")"))
    output$tab_parsed_discs <- renderText(p("Disc Titles (", nrow(r$tbl_discs), ")"))
    output$tab_parsed_nomatch <- renderText(p("No Matches (", nrow(r$tbl_nomatch_credits) + nrow(r$tbl_nomatch_comments) + nrow(r$tbl_nomatch_discs), ")"))
    output$tab_nomatch_credits <- renderText(p("Track Credits (", nrow(r$tbl_nomatch_credits), ")"))
    output$tab_nomatch_comments <- renderText(p("Comment (", nrow(r$tbl_nomatch_comments), ")"))
    output$tab_nomatch_discs <- renderText(p("Disc Titles (", nrow(r$tbl_nomatch_discs), ")"))
  })

  shiny::observeEvent(nrow(r$tbl_disc_tags), {
    choices <- as.character(r$tbl_disc_tags[["DISCNUMBER"]])
    updateCheckboxGroupInput(
      session,
      "all_tags_disc_selection",
      label = NULL,
      choices = choices,
      selected = choices
    )
  })


  # Section 3 ---------------------------------------------------------------


  # Create Album Tags Table
  shiny::observeEvent(
    ignoreInit=TRUE,
    list(
      r$album_tags,
      r$tracklists,
      input$tracklist_language,
      input$sep_multi_value,
      input$halfwidth,
      input$date_format,
      input$case_album,
      input$case_contentgroup
    ), {
      r$tbl_album_tags <- create_album_tags(r=r, input=input)
    }
  )

  shiny::observeEvent(input$discsubtitle_format_code_preset, {
    if (input$discsubtitle_format_code_preset != ""){
      shiny::updateTextInput(
        session = session,
        inputId = "discsubtitle_format_code",
        value = input$discsubtitle_format_code_preset
      )
    }
  })

  # Create Disc Tags Table
  shiny::observeEvent(
    ignoreInit=TRUE,
    list(
      r$tbl_discs,
      r$tracklists,
      input$tracklist_language,
      input$sep_multi_value,
      input$halfwidth,
      input$case_discsubtitle,
      input$discsubtitle_format_code
    ), {
      r$tbl_disc_tags <- create_disc_tags(r=r, input=input)
    }
  )

  # Create Track Tags Table
  shiny::observeEvent(
    ignoreInit=TRUE,
    list(
      r$tbl_tracklist,
      r$tbl_credits,
      r$tbl_comments,
      input$sep_multi_value,
      input$remove_artist_suffix,
      input$case_title,
      input$case_artist,
      input$halfwidth,
      input$buckets_ARTIST,
      input$default_ARTIST,
      input$default_COMPOSER,
      input$default_ARRANGER,
      input$default_REMIXER,
      input$default_LYRICIST,
      input$default_VOCALIST,
      input$default_CONDUCTOR,
      input$default_PERFORMER
    ), {
      r$tbl_track_tags <- create_track_tags(r=r, input=input)
    }
  )

  shiny::observeEvent(
    ignoreInit=TRUE,
    list(
      r$tbl_tracklist,
      r$artist_scores,
      input$sep_multi_value,
      input$albumartist_method,
      input$albumartist_threshold
    ), {
      result <- calculate_albumartist(r=r, input=input)
      updateTextInput(session, "albumartist", value=result$ALBUMARTIST)
      output$albumartist_blurb <- result$blurb
    }
  )


  # Artist Overview
  shiny::observeEvent(
    ignoreInit=TRUE,
    list(
      r$tbl_track_tags,
      input$sep_multi_value
    ), {
      r$artist_scores <- create_artist_scores(r=r, input=input)
    }
  )

  # Show correct artist credits overview
  shiny::observeEvent(
    ignoreInit=TRUE,
    list(
      r$artist_scores,
      input$albumartist_method
    ), {
      if (input$albumartist_method == "length"){
        r$tbl_artist_scores <- r$artist_scores[["tbl_length"]]
      }else{
        r$tbl_artist_scores <- r$artist_scores[["tbl_tracks"]]
      }
    }
  )

  output$download_track_tags <- downloadHandler(
    filename = function(){
      paste0("track_tags.tsv")
    },
    content = function(file){
      data.table::fwrite(x=r$tbl_track_tags, file=file, sep="\t", quote="auto", encoding="UTF-8")
    }
  )

  shiny::observeEvent(input$copy_track_tags, {
    server_clipboard(r$tbl_track_tags, session)
  })


  # Section 4 ---------------------------------------------------------------

  shiny::observeEvent(
    ignoreInit=TRUE,
    list(
      r$tbl_album_tags,
      r$tbl_disc_tags,
      r$tbl_track_tags,
      input$all_tags_keep_disc,
      input$all_tags_keep_credits,
      input$all_tags_keep_notes,
      input$all_tags_disc_selection,
      input$albumartist
    ), {
      r$tbl_all_tags <- create_all_tags(r=r, input=input)
    }
  )

  shiny::observeEvent(r$tbl_all_tags, {
    r$char_3pp <- get_char_3pp(tbl=r$tbl_all_tags)
  })

  output$download_all_tags <- downloadHandler(
    filename = function() {
      paste0("tags.tsv")
    },
    content = function(file) {
      data.table::fwrite(x=r$tbl_all_tags, file=file, sep="\t", quote="auto", encoding="UTF-8")
    }
  )

  output$download_all_tags_3pp <- downloadHandler(
    filename = function() {
      paste0("tags.txt")
    },
    content = function(file) {
      data.table::fwrite(x=r$tbl_all_tags, file=file, sep=r$char_3pp, quote="auto", encoding="UTF-8", col.names=FALSE)
    }
  )

  shiny::observeEvent(input$copy_format_string_3pp, {
    txt <- paste0("%", colnames(r$tbl_all_tags), "%", collapse=r$char_3pp)
    server_clipboard(txt, session)
  })

  # Section 5 ---------------------------------------------------------------

  shiny::observeEvent(input$filename_format_code_preset, {
    if (input$filename_format_code_preset != ""){
      shiny::updateTextInput(
        session = session,
        inputId = "filename_format_code",
        value = input$filename_format_code_preset
      )
    }
  })

  shiny::observeEvent(
    ignoreInit = TRUE,
    list(
      r$tbl_all_tags,
      input$filename_format_code,
      input$filename_min_width_disc,
      input$filename_min_width_track,
      input$filename_min_width_auto
    ), {
      r$tbl_filenames <- create_tbl_filenames(r=r, input=input)
    }
  )

  shiny::observeEvent(input$get_folder, {
    if (!dir.exists(input$folder)){
      shiny::showNotification("Directory does not exist.", type="warning")
    }else{
      r$tbl_files <- create_tbl_files(r=r, input=input)

      if (!simple_df(r$tbl_files)){
        shiny::showNotification("Could not match files to tags.", type="warning")
      }
    }
  })

  shiny::observeEvent(input$tag_files, {
    if (!simple_df(r$tbl_files)){
      shiny::showNotification("No matched files found.", type="warning")
    }else{
      # Create a Progress object
      progress <- shiny::Progress$new()
      progress$set(message="Tagging music files", value=0)
      on.exit(progress$close())

      updateProgress <- function(detail=NULL){
        progress$inc(amount=1/nrow(r$tbl_files), detail=detail)
      }

      tag_flac_files(r=r, input=input, updateProgress=updateProgress)
    }
  })


  # DataTable Definitions ---------------------------------------------------

  # 1 Album Info ------------------------------------------------------------

  server_dt_init("album_info", r, output)
  server_dt_link("album_info", r)

  # 1 Tracklist -------------------------------------------------------------

  server_dt_init("tracklist", r, output)
  server_dt_link("tracklist", r)

  # DT 2-1 Detected Info ----------------------------------------------------

  server_dt_init("found_info", r, output, isolate=FALSE)

  # DT 2-2 Parsed Credits ---------------------------------------------------

  server_dt_init("credits", r, output)
  server_dt_link("credits", r)

  # DT 2-3 Parsed Comments --------------------------------------------------

  server_dt_init("comments", r, output)
  server_dt_link("comments", r)

  # DT 2-4 Parsed Disc Titles -----------------------------------------------

  server_dt_init("discs", r, output)
  server_dt_link("discs", r)

  # DT 2-5 Parsed No Match --------------------------------------------------

  server_dt_init("nomatch_credits", r, output)
  server_dt_link("nomatch_credits", r)

  server_dt_init("nomatch_comments", r, output)
  server_dt_link("nomatch_comments", r)

  server_dt_init("nomatch_discs", r, output)
  server_dt_link("nomatch_discs", r)

  # DT 3-2 Album Tags -------------------------------------------------------

  server_dt_init("album_tags", r, output,
                 rownames=FALSE, ellipsis_cols=2, readonly=1)
  server_dt_link("album_tags", r)
  server_dt_edit("album_tags", r, input)

  # DT 3-3 Disc Tags --------------------------------------------------------

  server_dt_init("disc_tags", r, output,
                 rownames=FALSE, readonly=1)
  server_dt_link("disc_tags", r)
  server_dt_edit("disc_tags", r, input)

  # DT 3-4 Track Tags -------------------------------------------------------

  server_dt_init("track_tags", r, output,
                 readonly=1:2, fixed_cols=2)
  server_dt_link("track_tags", r)
  server_dt_edit("track_tags", r, input)

  # DT 3-5 Album Artist -----------------------------------------------------

  server_dt_init("artist_scores", r, output, isolate=FALSE)
  # server_dt_link("artist_scores", r)

  # 4 ------------------

  server_dt_init("all_tags", r, output,
                 isolate=FALSE, ellipsis_cols="_all", ellipsis_chars=25, selection="multiple")

  # 5 --------------

  server_dt_init("filenames", r, output)
  server_dt_link("filenames", r)

  server_dt_init("files", r, output, isolate=FALSE)
}
