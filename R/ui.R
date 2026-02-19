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

ui <- shiny::navbarPage(
  theme = getOption("vgm_app_theme"),
  title = "VGM Credits Parser",
  header = shiny::tags$head(
    shiny::tags$link(rel="shortcut icon", href="www/favicon.ico"),
    shiny::tags$link(rel="icon", type="image/x-icon", href="www/favicon.ico"),
    shiny::tags$link(rel="stylesheet", type="text/css", href=paste0("www/style.css?v=", as.integer(Sys.time()))),
    shiny::tags$script(src="www/script.js")
  ),

  shiny::tabPanel(
    "1. Get Album",
    ui_page_container(
      shiny::sidebarLayout(
        ui_sidebar_scroll(
          width = getOption("vgm_sidebar_width_content"),
          ui_row(
            shiny::column(
              width = 4,
              htmlOutput("cover") # if needed
            ),
            shiny::column(
              width = 8,
              shiny::h6("Album URL", ui_info(uitxt_info_fetch_album)),
              shiny::textInput("url", NULL, getOption("vgm_album_url")),
              shiny::span(
                shiny::actionButton("get_album", "Get Album"),
                shiny::actionButton("get_dummy", "Create Dummy Tracklist")
              )
            )
          ),
          ui_vertical_space(),
          shiny::h6("Album Info"),
          ui_datatable("dt_album_info")
        ),

        shiny::mainPanel(
          width = 12 - getOption("vgm_sidebar_width_content"),
          bslib::card(
            class = "no-gap",
            shiny::h6("Tracklist Language"),
            shiny::selectInput("tracklist_language", NULL, choices="-", multiple=FALSE),
            ui_vertical_space(),
            shiny::h6("Tracklist"),
            ui_datatable("dt_tracklist")
          )
        )
      )
    )
  ),

  shiny::tabPanel(
    "2. Parse Credits",
    ui_page_container(
      shiny::sidebarLayout(
        ui_sidebar_fill(
          width = getOption("vgm_sidebar_width_content"),
          shiny::div(
            class = "flex-row",
            shiny::actionButton("reset_notes", "Reset Notes"),
            shiny::span(ui_info(uitxt_info_artist_role), "Tiebreak:", class="push"),
            shiny::radioButtons("ra_ar", label=NULL, choices=list("Auto"="", "Role-Artist"="role_artist", "Artist-Role"="artist_role"), inline=TRUE, width="auto")
          ),
          if (getOption("vgm_live_theme")){
            shiny::selectInput("ace_theme", label=NULL, choices=getOption("ace_themes"), selected=getOption("vgm_editor")$theme, width="50%")
          },
          shiny::div(class="vertical-space"),
          shiny::uiOutput("editor")
        ),

        shiny::mainPanel(
          width = 12 - getOption("vgm_sidebar_width_content"),
          bslib::navset_card_pill(
            shiny::tabPanel(
              "Detected Info",
              ui_datatable("dt_found_info")
            ),
            shiny::tabPanel(
              shiny::textOutput("tab_parsed_credits"),
              ui_datatable("dt_credits")
            ),
            shiny::tabPanel(
              shiny::textOutput("tab_parsed_comments"),
              ui_datatable("dt_comments")
            ),
            shiny::tabPanel(
              shiny::textOutput("tab_parsed_discs"),
              ui_datatable("dt_discs")
            ),
            shiny::tabPanel(
              shiny::textOutput("tab_parsed_nomatch"),
              bslib::navset_pill(
                shiny::tabPanel(
                  shiny::textOutput("tab_nomatch_credits"),
                  ui_datatable("dt_nomatch_credits")
                ),
                shiny::tabPanel(
                  shiny::textOutput("tab_nomatch_comments"),
                  ui_datatable("dt_nomatch_comments")
                ),
                shiny::tabPanel(
                  shiny::textOutput("tab_nomatch_discs"),
                  ui_datatable("dt_nomatch_discs")
                )
              )
            )
          )
        )
      )
    )
  ),

  shiny::tabPanel(
    "3. Adjust Info",
    ui_page_container(
      bslib::navset_card_pill(
        shiny::tabPanel(
          "Options",
          shiny::sidebarLayout(
            ui_sidebar_scroll(
              width = getOption("vgm_sidebar_width_options"),
              shiny::h6(shiny::tags$b("Tag Separator")),
              shiny::h6("Separator for multi-value fields", ui_info(uitxt_info_multi_field_sep)),
              shiny::textInput("sep_multi_value", NULL, value=getOption("vgm_sep_multi_value", "; ")),
              shiny::hr(),
              shiny::h6(shiny::tags$b("Text Formatting")),
              shiny::h6(shiny::HTML("Transformations applied to <code>ALBUM</code>, <code>TITLE</code>, <code>DISCSUBTITLE</code>, and <code>CONTENTGROUP</code>")),
              shiny::checkboxInput(
                "halfwidth",
                shiny::span("Fullwidth to Halfwidth", ui_info(uitxt_info_fullwidth)),
                getOption("vgm_fullwidth_to_halfwidth", FALSE)
              ),
              shiny::checkboxInput(
                "various_text_fixes",
                shiny::span("Various Fixes", ui_info(uitxt_info_various_text_fixes)),
                getOption("vgm_various_text_fixes", FALSE)
              )
            ),
            ui_mainpanel(
              width = 12 - getOption("vgm_sidebar_width_options"),
              shiny::h6(shiny::tags$b(shiny::code("ARTIST"), " Field")),
              shiny::p("Method for automatic ", shiny::code("ARTIST"), " field population", ui_info(uitxt_info_artist_buckets)),
              sortable::bucket_list(
                header = NULL,
                group_name = "buckets_ARTIST",
                orientation = "horizontal",
                sortable::add_rank_list(
                  text = "Priority 1",
                  labels = getOption("vgm_artist_calc_priority1"),
                  input_id = "ba_prio1"
                ),
                sortable::add_rank_list(
                  text = "Priority 2",
                  labels = getOption("vgm_artist_calc_priority2"),
                  input_id = "ba_prio2"
                ),
                sortable::add_rank_list(
                  text = "Priority 3",
                  labels = getOption("vgm_artist_calc_priority3"),
                  input_id = "ba_prio3"
                ),
                sortable::add_rank_list(
                  text = "Unused",
                  labels = getOption("vgm_artist_calc_unused"),
                  input_id = "ba_unused"
                )
              )
            )
          )
        ),

        shiny::tabPanel(
          "Album",
          shiny::sidebarLayout(
            ui_sidebar_scroll(
              width = getOption("vgm_sidebar_width_options"),
              shiny::h6(shiny::tags$b(shiny::code("DATE"), " Format")),
              shiny::radioButtons("date_format", NULL, list("YYYY-MM-DD"="ymd", "YYYY-MM"="ym", "YYYY"="y"), selected=getOption("vgm_date_format")),
              shiny::hr(),
              shiny::h6(shiny::tags$b(shiny::code("ALBUM"), " Case")),
              ui_radiobutton_case("case_album", getOption("vgm_case_album")),
              shiny::hr(),
              shiny::h6(shiny::tags$b(shiny::code("CONTENTGROUP"), " Case")),
              ui_radiobutton_case("case_contentgroup", getOption("vgm_case_contengroup"))
            ),
            ui_mainpanel(
              width = 12 - getOption("vgm_sidebar_width_options"),
              ui_datatable("dt_album_tags")
            )
          )
        ),

        shiny::tabPanel(
          "Discs",
          shiny::sidebarLayout(
            ui_sidebar_scroll(
              width = getOption("vgm_sidebar_width_options"),
              shiny::h6(shiny::tags$b(shiny::code("DISCSUBTITLE"), " Case")),
              ui_radiobutton_case("case_discsubtitle", getOption("vgm_case_discsubtitle")),
            ),
            ui_mainpanel(
              width = 12 - getOption("vgm_sidebar_width_options"),
              ui_row(
                shiny::column(
                  width = 8,
                  shiny::h6(shiny::code("DISCSUBTITLE"), " Format"),
                  shiny::textInput("discsubtitle_format_code", NULL, width="100%",
                                   placeholder="Enter format code...")
                ),
                shiny::column(
                  shiny::h6("Preset"),
                  width = 4,
                  shiny::selectInput("discsubtitle_format_code_preset", NULL, width="100%",
                                     choices=getOption("vgm_discsubtitle_format_codes")
                  )
                )
              ),
              ui_vertical_space(),
              ui_datatable("dt_disc_tags")
            )
          )
        ),

        shiny::tabPanel(
          "Tracks",
          shiny::sidebarLayout(
            ui_sidebar_scroll(
              width = getOption("vgm_sidebar_width_options"),
              shiny::h6(shiny::tags$b("Artist Suffix")),
              shiny::checkboxInput(
                "remove_artist_suffix",
                shiny::span("Remove artist suffixes", ui_info(uitxt_info_artist_suffix)),
                value=getOption("vgm_remove_artist_suffix")
              ),
              shiny::hr(),
              shiny::h6(shiny::tags$b("Default Tag Values"), ui_info(uitxt_info_default_tag_values)),
              ui_input_grid(
              ui_textinput_default("ARTIST"),
              ui_textinput_default("COMPOSER"),
              ui_textinput_default("ARRANGER"),
              ui_textinput_default("REMIXER"),
              ui_textinput_default("LYRICIST"),
              ui_textinput_default("CONDUCTOR"),
              ui_textinput_default("VOCALIST"),
              ui_textinput_default("PERFORMER")
              ),
              shiny::hr(),
              shiny::h6(shiny::tags$b(shiny::code("TITLE"), " Case")),
              ui_radiobutton_case("case_title", getOption("vgm_case_title")),
              shiny::hr(),
              shiny::h6(shiny::tags$b("Artist Case")),
              ui_radiobutton_case("case_artist", getOption("vgm_case_artist"))
            ),
            ui_mainpanel(
              width = 12 - getOption("vgm_sidebar_width_options"),
              ui_datatable("dt_track_tags")
            )
          )
        ),

        shiny::tabPanel(
          "Album Artist",
          shiny::sidebarLayout(
            ui_sidebar_scroll(
              width = getOption("vgm_sidebar_width_options"),
              shiny::h6(shiny::tags$b(shiny::code("ALBUMARTIST"), " Calculation")),
              shiny::h6("Needed share of ", shiny::code("ARTIST"), " credits"),
              shiny::div(
                class = "flex-row",
                shiny::numericInput("albumartist_threshold", NULL, value=getOption("vgm_albumartist_percentage"), min=0L, max=100L, step=5L),
                shiny::span("%", class="numeric-unit")
              ),
              shiny::radioButtons("albumartist_method", "Method for counting", choices=list("Tracks"="tracks", "Track Length"="length"), selected=getOption("vgm_albumartist_method")),
              shiny::uiOutput("albumartist_blurb")
            ),
            ui_mainpanel(
              width = 12 - getOption("vgm_sidebar_width_options"),
              shiny::h6(shiny::code("ALBUMARTIST")),
              shiny::textInput("albumartist", NULL, "", width="100%"),
              ui_vertical_space(),
              shiny::h6("Artist Overview"),
              ui_datatable("dt_artist_scores")
            )
          )
        ),

        shiny::tabPanel(
          "Tags Overview",
          shiny::sidebarLayout(
            ui_sidebar_scroll(
              width = getOption("vgm_sidebar_width_options"),
              shiny::h6(shiny::tags$b("Text Export")),
              shiny::h6("General"),
              shiny::downloadButton("download_all_tags", "TSV"),
              # shiny::hr(),
              ui_vertical_space(),
              shiny::h6("Mp3tag / foobar2000"),
              shiny::downloadButton("download_all_tags_3pp", "TXT"),
              shiny::actionButton("copy_format_string_3pp", label = shiny::tagList(
                shiny::icon("copy", class="fa-solid", lib="font-awesome"),
                "Format String"
              ),
              icon = NULL),
              shiny::hr(),
              shiny::h6(shiny::tags$b("Tag Selection")),
              shiny::checkboxInput("all_tags_keep_disc", shiny::HTML(paste("Keep single", shiny::code("DISCNUMBER"))), value=getOption("vgm_all_tags_keep_disc")),
              shiny::checkboxInput("all_tags_keep_credits", shiny::HTML(paste("Include", shiny::code("VGMDB_CREDITS"))), value=getOption("vgm_all_tags_keep_credits")),
              shiny::checkboxInput("all_tags_keep_notes", shiny::HTML(paste("Include", shiny::code("VGMDB_NOTES"))), value=getOption("vgm_all_tags_keep_notes")),
              shiny::hr(style="margin-bottom: calc(1em - 3px);"),
              shiny::checkboxGroupInput("all_tags_disc_selection", shiny::tags$b("Disc Selection"))
            ),
            ui_mainpanel(
              width = 12 - getOption("vgm_sidebar_width_options"),
              shiny::h6("All Tags", ui_info(uitxt_info_tags_overview)),
              ui_datatable("dt_all_tags")
            )
          )
        )
      )
    )
  ),

  shiny::tabPanel(
    "4. Tag Files",
    ui_page_container(
      bslib::navset_card_pill(
        shiny::tabPanel(
          "Filenames",
          shiny::sidebarLayout(
            ui_sidebar_scroll(
              width = getOption("vgm_sidebar_width_options"),
              shiny::h6(shiny::tags$b("Minimum Width"), ui_info(uitxt_info_min_width)),
              ui_input_grid(
                list(
                  shiny::span(shiny::code("DISCNUMBER"), class="input-label"),
                  shiny::numericInput("filename_min_width_disc", NULL, value=getOption("vgm_filename_min_width_disc"), min=0L, step=1L)
                ),
                list(
                  shiny::span(shiny::code("TRACKNUMBER"), class="input-label"),
                  shiny::numericInput("filename_min_width_track", NULL, value=getOption("vgm_filename_min_width_track"), min=0L, step=1L)
                )
              ),
              ui_vertical_space_small(),
              shiny::checkboxInput("filename_min_width_auto",
                                   shiny::span("Use Auto-Width", ui_info(uitxt_info_min_width_auto)),
                                   getOption("vgm_filename_min_width_auto"))
            ),
            ui_mainpanel(
              width = 12 - getOption("vgm_sidebar_width_options"),

              ui_row(
                shiny::column(
                  width = 8,
                  shiny::h6("Filename Format"),
                  shiny::textInput("filename_format_code", NULL, width="100%",
                                   placeholder="Enter format code...")
                ),
                shiny::column(
                  shiny::h6("Preset"),
                  width = 4,
                  shiny::selectInput("filename_format_code_preset", NULL, width="100%",
                                     choices=getOption("vgm_filename_format_codes")
                  )
                )
              ),
              ui_vertical_space(),
              shiny::h6("Filename Overview"),
              ui_datatable("dt_filenames")
            )
          )
        ),

        shiny::tabPanel(
          "Match Files",
          shiny::sidebarLayout(
            ui_sidebar_scroll(
              width = getOption("vgm_sidebar_width_options"),
              shiny::h6(shiny::tags$b("File Matching")),
              shiny::h6("Match files to tracklist"),
              shiny::radioButtons("file_matching_method", NULL, choices=list("Automatic"="auto", "Manual"="manual"), selected=getOption("vgm_file_matching_method")),
              ui_vertical_space_small(),
              shiny::h6("Maximum length difference", ui_info("The max difference in seconds that is allowed.")),
              shiny::div(
                class = "flex-row",
                shiny::numericInput("file_matching_time_diff", NULL, value=getOption("vgm_file_matching_time_diff"), min=0L, step=1L),
                shiny::span(class="numeric-unit", "seconds")
              ),

              shiny::hr(),
              shiny::h6(shiny::tags$b("Album Cover")),
              shiny::h6("Size of embedded cover", ui_info(uitxt_tooltip_cover_resize_size)),
              shiny::div(
                class = "flex-row",
                shiny::numericInput("cover_resize_size", NULL, getOption("vgm_cover_size"), min=50L, step=50L),
                shiny::span(class="numeric-unit", "pixel")
              ),
              ui_vertical_space_small(),
              shiny::h6("Applied side", ui_info(uitxt_tooltip_cover_resize_method)),
              shiny::radioButtons("cover_resize_method", NULL, choices=list("Minimum"="min", "Maximum"="max"), selected=getOption("vgm_cover_dim", "min")),

              shiny::hr(),
              shiny::h6(shiny::tags$b("Other Tags")),
              shiny::checkboxInput(
                "remove_sort_tags",
                shiny::span("Remove ", shiny::code("SORT"), " tags", ui_info(uitxt_info_remove_sort_tags)),
                getOption("vgm_remove_sort_tags")
              ),
              shiny::checkboxInput(
                "remove_musicbrainz_tags",
                shiny::span("Remove", shiny::code("MUSICBRAINZ"), "tags", ui_info(uitxt_info_remove_musicbrainz_tags)),
                getOption("vgm_remove_musicbrainz_tags")
              )
            ),
            ui_mainpanel(
              width = 12 - getOption("vgm_sidebar_width_options"),
              shiny::h6("Directory path containing music files", ui_info(uitxt_info_directory)),
              shiny::textInput("folder", NULL, "", width="100%"),
              shiny::span(
                shiny::actionButton("get_folder", "Get Music Files"),
                shiny::actionButton("tag_files", "Tag Music Files")
              ),
              ui_vertical_space(),
              shiny::h6("Table with Files and File Names"),
              ui_datatable("dt_files")
            )
          )
        )
      )
    )
  )
)
