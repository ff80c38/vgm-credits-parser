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

options(vgm_live_theme = FALSE)

options(vgm_sidebar_width_content = 5) # Possible values: 0, 1, ..., 11, 12
options(vgm_sidebar_width_options = 2) # Possible values: 0, 1, ..., 11, 12

options(vgm_app_theme = bslib::bs_theme(
  version = 5,
  preset = "flatly",

  # The following options will overwrite the theme ("preset") defined above
  # Available themes: https://bootswatch.com/

  # General
  # =======
  "font-size-base" = "1rem",
  "small-font-size" = "0.9em",
  "enable-rounded" = FALSE,
  # "enable-shadows" = FALSE,
  # "enable-gradients" = FALSE,
  # "enable-transitions" = TRUE,
  # "enable-reduced-motion" = TRUE,
  # "enable-smooth-scroll" = TRUE,
  # "enable-button-pointers" = TRUE,

  # Fonts
  # =====
  # "base_font" = "Roboto", # sass::font_google("Roboto"),
  # "code_font" = "Roboto Mono", # sass::font_google("Roboto Mono"),

  # To download and cache web fonts not installed locally, simply use sass::font_google()
  # Available web fonts: https://fonts.google.com/

  # Main Colors
  # ===========
  # "primary" = "#2c3e50",
  # "secondary" = "#95a5a6",
  # "success" = "#18bc9c",
  # "info" = "#3498db",
  # "warning" = "#f39c12",
  # "danger" = "#e74c3c",
  # "light" = "#ecf0f1",
  # "dark" = "#7b8a8b"
))


# Options: https://rdrr.io/cran/shinyAce/man/aceEditor.html
options(vgm_editor = list(
  # Appearance
  theme = "solarized_light",
  fontSize = 16, # px
  showPrintMargin = FALSE,
  placeholder = "Add notes with track credits and format them for parsing", # Shown text when editor is empty
  # height = "calc(100vh - 225px)",
  height = "100%",
  mode = "text",

  # Behavior
  debounce = 1000, # When user stops typing, wait 'debounce' ms before sending text to app
  autoComplete = "live" # Possible values: "disabled", "enabled", "live"
))

options(vgm_table_fontsize = "10pt")

options(ace_themes = list(
  Light = list(
    "Chrome" = "chrome",
    "Clouds" = "clouds",
    "Crimson Editor" = "crimson_editor",
    "Dawn" = "dawn",
    "Dreamweaver" = "dreamweaver",
    "Eclipse" = "eclipse",
    "GitHub" = "github",
    "IPlastic" = "iplastic",
    "KatzenMilch" = "katzenmilch",
    "Kuroir" = "kuroir",
    "Solarized Light" = "solarized_light",
    "SQL Server" = "sqlserver",
    "TextMate" = "textmate",
    "Tomorrow" = "tomorrow",
    "XCode" = "xcode"
  ),
  Dark = list(
    "Ambiance" = "ambiance",
    "Chaos" = "chaos",
    "Clouds Midnight" = "clouds_midnight",
    "Cobalt" = "cobalt",
    "Dracula" = "dracula",
    "Green on Black" = "gob",
    "Gruvbox" = "gruvbox",
    "idle Fingers" = "idle_fingers",
    "krTheme" = "kr_theme",
    "Merbivore" = "merbivore",
    "Merbivore Soft" = "merbivore_soft",
    "Mono Industrial" = "mono_industrial",
    "Monokai" = "monokai",
    "Pastel on dark" = "pastel_on_dark",
    "Solarized Dark" = "solarized_dark",
    "Terminal" = "terminal",
    "Tomorrow Night" = "tomorrow_night",
    "Tomorrow Night Blue" = "tomorrow_night_blue",
    "Tomorrow Night Bright" = "tomorrow_night_bright",
    "Tomorrow Night 80s" = "tomorrow_night_eighties",
    "Twilight" = "twilight",
    "Vibrant Ink" = "vibrant_ink"
  )
))

