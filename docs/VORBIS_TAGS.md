# Vorbis Tags

VGM Credits Parser supports and handles the following vorbis tags. The tags are grouped by scope, meaning the tag in question applies either album, disc, or track wide. The location of its source on the VGMdb album page is written in parentheses.

Note: There currently is no way to change this mapping except editing the source code. Please submit a feature request if this option is needed or there is a better/more commonly used tag mapping.

## Album

* **`ALBUM`**  
  Album title (Page)
* **`ALBUMARTIST`**  
  Album artist (Calculated, Notes)
* **`BARCODE`**  
  Barcode (Album Info)
* **`CONTENTGROUP`**  
  Products represented (Album Stats)
* **`COPYRIGHT`**  
  Phonographic copyright (Album Info)
* **`DATE`**  
  Release date (Album Info)
* **`DISCTOTAL`**  
  Total number of discs (Tracklist)
* **`GENRE`**  
  Category (Album Stats)
* **`LABEL`**  
  Label (Album Info)
* **`PICTURE`**  
  Album cover (Page)
* **`PUBLISHER`**  
  Publisher (Album Info)
* **`RELEASESTATUS`**  
  Publish format (Album Info)
* **`SOURCEMEDIA`**  
  Media format, where first number is removed (Album Info)
* **`VGMDB_CREDITS`**  
  Flattened credits table (Credits)
* **`VGMDB_DISTRIBUTOR`**  
  Distributor (Album Info)
* **`VGMDB_EVENT`**  
  Event from inside the release date field (Album Info)
* **`VGMDB_MANUFACTURER`**  
  Manufacturer (Album Info)
* **`VGMDB_NOTES`**  
  Notes (Notes)
* **`VGMDB_PLATFORM`**  
  Platforms represented (Album Stats)
* **`VGMDB_PRICE`**  
  Release price (Album Info)
* **`WEBSITE`**  
  Album URL (Page)

## Disc/Album

* **`CATALOGNUMBER`**  
  The media catalog number is used first and if not available, the album catalog number is used for all discs (Tracklist, Album Info)
* **`VGMDB_CLASSIFICATION`**  
 The media classification is used first and if not available, the album classification is used for all discs (Tracklist, Album Info)

## Disc

* **`DISCNUMBER`**  
  Disc number (Tracklist)
* **`DISCSUBTITLE`**  
  Disc title (Notes)
* **`TRACKTOTAL`**  
  Total number of tracks on disc (Tracklist)

## Track

* **`ARRANGER`**  
  Arranger credit (Notes)
* **`ARTIST`**  
  Artist credit (Calculated, Notes)
* **`COMMENT`**  
  Track specific commentary (Notes)
* **`COMPOSER`**  
  Composer credit (Notes)
* **`CONDUCTOR`**  
  Conductor credit (Notes)
* **`LYRICIST`**  
  Lyricist credit (Notes)
* **`PERFORMER`**  
  Performer credit, default value for any kind of credit (Notes)
* **`REMIXER`**  
  Remixer credit (Notes)
* **`TITLE`**  
  Track title (Tracklist)
* **`TRACKNUMBER`**  
  Track number (Tracklist)
* **`VOCALIST`**  
  Vocalist credit, duplicated in `PERFORMER` (Notes)