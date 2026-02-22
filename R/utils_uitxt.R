# -----------------------------------------------------------------------------
# Copyright (c) 2026 ff80c38
# Licensed under the MIT License. See LICENSE file for details.
# -----------------------------------------------------------------------------

uitxt_info_various_text_fixes <- paste0(
  "Applies the following transformations:",
  "<ul>",
  "<li>Trim whitespace at the start and end</li>",
  "<li>Replace multiple whitespaces with one space</li>",
  "<li>Replace em/en dashes with a minus sign</li>",
  "<li>Ensure there is a space between text and trailing parentheses, e.g. \"Track(Inst.)\" → \"Track (Inst.)\"</li>",
  "<li>Replace some odd symbols with their ASCII equivalents</li>",
  "</ul>"
)

uitxt_tooltip_cover_resize_method <- paste0(
  "Choose whether the minimum or the maximum image side should be scaled to [size] px:",
  "<ul>",
  "<li>'Minimum' means the image will be at least [size] x [size] px.</li>",
  "<li>'Maximum' means the image will be at most [size] x [size] px.</li>",
  "</ul>"
)

uitxt_tooltip_cover_resize_size <- paste(
  "If the album cover is larger than the specified size, downscale the image used for tagging.",
  "The full-size album cover will always be saved inside the \"_tagged\" folder irrespective of this value."
)

uitxt_info_artist_role <- paste(
  "Automatic detection does not always work correctly when a line matches both \"Role-Artist\" and \"Artist-Role\".",
  "Set a tiebreak for the entire notes when parsing seems off."
)

uitxt_info_directory <- paste(
  "Directory is searched recursively for <code>.flac</code> files.",
  "For automatic matching, each disc needs to be in a separate (sub)folder inside the directory.",
  "<br>",
  "The alphanumeric order of the (sub)folder names is only used when disc/track matching failed or manual mode is selected.",
  "Tracks inside (sub)folders always need to be correctly sorted."
)

uitxt_info_fullwidth <- paste(
  "Convert latin fullwidth characters to their halfwidth equivalents.",
  "This also includes the tildes \"～\" and \"〜\"."
)

uitxt_info_multi_field_sep <- paste(
  "Separator between multiple values in a field, e.g. two different artists listed in <code>ARTIST</code>.",
  "<br>",
  "While Vorbis does support multi-value fields (by writing multiple Vorbis comments), most players and taggers do not or not correctly.",
  "Therefore we only write one Vorbis comment per field and separate multiple values by the specified string."
)

uitxt_info_remove_sort_tags <- paste(
  "Delete the following tags from your files during tagging:",
  "<ul>",
  "<li><code>ALBUMARTISTSORT</code></li>",
  "<li><code>ALBUMSORT</code></li>",
  "<li><code>ARTISTSORT</code></li>",
  "<li><code>COMPOSERSORT</code></li>",
  "<li><code>TITLESORT</code></li>",
  "</ul>"
)

uitxt_info_remove_musicbrainz_tags <- paste(
  "Delete the following tags from your files during tagging:",
  "<ul>",
  "<li><code>MUSICBRAINZ_ALBUMARTISTID</code></li>",
  "<li><code>MUSICBRAINZ_ALBUMID</code></li>",
  "<li><code>MUSICBRAINZ_ARTISTID</code></li>",
  "<li><code>MUSICBRAINZ_DISCID</code></li>",
  "<li><code>MUSICBRAINZ_ORIGINALALBUMID</code></li>",
  "<li><code>MUSICBRAINZ_ORIGINALARTISTID</code></li>",
  "<li><code>MUSICBRAINZ_RELEASEGROUPID</code></li>",
  "<li><code>MUSICBRAINZ_RELEASETRACKID</code></li>",
  "<li><code>MUSICBRAINZ_TRACKID</code></li>",
  "<li><code>MUSICBRAINZ_TRMID</code></li>",
  "<li><code>MUSICBRAINZ_WORKID</code></li>",
  "</ul>"
)

uitxt_info_default_tag_values <- paste(
  "Default tag values that are used for all tracks without found and parsed info.",
  "To specify multiple artists, use the defined multi-value field separator."
)

uitxt_info_artist_suffix <- paste(
  "Artist suffixes are parentheses at the end of the artist string.",
  "They usually contain unit or company specifications, or a note about an artist being uncredited.",
  "<br>",
  "This option does not affect the generated role suffixes of the <code>PERFORMER</code> tag or any default tag value."
)

uitxt_info_tags_overview <- paste(
  "This table serves as an overview of all parsed information.",
  "Anything not listed here will be missing from exports, and will not be used for tagging and file matching."
)

uitxt_info_fetch_album <- paste(
  "Specify the URL of the VGMdb album page you want to parse and use [Get Album].",
  "If URL does not start with \"http(s)://\", URL is treated as a filepath to an html document instead.",
  "<br>",
  "You can use the parser without an album page by creating a dummy tracklist.",
  "Simply list the number of tracks for each disc in the URL field and use [Create Dummy Tracklist]"
)

uitxt_info_min_width <- paste(
  "Set the minimum width of numeric fields used in the filename.",
  "Numbers shorter than the specified width are padded with leading zeroes.",
  "These settings also apply to the tags <code>DISCTOTAL</code> and <code>TRACKTOTAL</code>.",
  "<br>",
  "Widths explicitly specified inside the format string take precedence over these global options."
)

uitxt_info_min_width_auto <- paste(
  "Automatically determine the minimum width that is required for consistent padding.",
  "<br>",
  "This option will never reduce any specified minimum widths, and widths explicitly specified inside the format string take precedence."
)

uitxt_info_artist_buckets <- paste(
  "The <code>ARTIST</code> field is automatically populated using the detected role credits.",
  "The buckets here are used to define the calculation method applied to each track:",
  "<ul>",
  "<li>The first bucket that contains at least one credited artist is used, lower priority buckets act as fallbacks.</li>",
  "<li>Within a bucket, roles are processed top to bottom: All artists credited for the first role are listed first, followed by artists from the next role who have not already been listed.</li>",
  "<li>If no artists are found in any bucket, the <code>ARTIST</code> field remains empty for that track.</li>",
  "</ul>"
)
