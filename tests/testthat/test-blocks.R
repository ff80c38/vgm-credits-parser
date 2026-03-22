# [1] track
# […] role - artist
test_that("[1] track / […] role - artist", {
  # Normal
  block <- "M-01,02,03,05,06,09
  Composed & Arranged by Keiichi Okabe"
  expect_equal(check_block(block, "def")[["V2"]], c("track", "role_artist"))
  # Number in Artist
  block <- "M-06
  Artist: Vector U & Player2"
  expect_equal(check_block(block, "def")[["V2"]], c("track", "role_artist"))
  # TRACK #[0-9]
  block <- "Track #1
  Vocal: TestArtist 9"
  expect_equal(check_block(block, "def")[["V2"]], c("track", "role_artist"))
  # Long and Combined
  block <- "M-2.22
  Lyrics: Hideaki Hamada
  Arrangement: Mitsuo Singa
  Vocal & Chorus: Megumi Sasaka
  Guitar: PBM
  Violin: Kazuhiro Tanizaki
  Bass: NAOKIX
  Keyboard: gakia2"
  expect_equal(check_block(block, "def")[["V2"]], c("track", rep("role_artist", 7)))
})


# [1] track
# […] artist - role
# // NO EASY POSSIBILITY TO DIFFERENTIATE //


# [1] track - (comment)
# […] role - artist
test_that("[1] track - (comment) / […] role - artist", {
  # Normal
  block <- "7 (Anime ED)
  Composer: foobar2000"
  expect_equal(check_block(block, "def")[["V2"]], c("track_(comment)", rep("role_artist", 1)))
})


# [1] track - comment
# […] role - artist
test_that("[1] track - comment / […] role - artist", {
  # Normal
  block <- "M-01 - TV Anime \"JUJUTSU KAISEN\" Ending Theme
  Composer: ALI, AKLO
  Lyricist: LEO, LUTHFI, ALEX, AKLO"
  expect_equal(check_block(block, "def")[["V2"]], c("track_comment", rep("role_artist", 2)))
  # Longer
  block <- "01/08: Ever17-the out of infinity- opening theme song
  Composition & Lyrics: Chiyomaru Shikura
  Arrangement: Toshimichi Isoe
  Vocals: KAORI
  Chorus: Sayaka Shintani (新谷 さや香)
  Recorded & Mixed at STUDIO SOUND SHIP
  Recording & Mix Engineer: Yasutomo Nogawa (SCITRON DIGITAL CONTENT INC.)"
  expect_equal(check_block(block, "def")[["V2"]], c("track_comment", rep("role_artist", 6)))
})


# [1] comment - track
# […] role - artist
test_that("[1] comment - track / […] role - artist", {
  block <- "Sonic The Hedgehog - 01~06
  Composer: Masato Nakamura"
  expect_equal(check_block(block, "def")[["V2"]], c("comment_track", "role_artist"))
  # Numbers in comment --> Issue with comment/track detection
  block <- "Sonic The Hedgehog 2 - 07~10
  Composer: Masato Nakamura"
  result <- check_block(block, "def")
  expectation <- c("comment_track", "role_artist")
  expect_true(all(result[["V2"]] == expectation) || all(result[["V3"]] == expectation)) # If not first, it needs to be second
})


# [1] all - role - artist
test_that("[1] all - role - artist", {
  # Normal
  block <- "All Music and Sounds: Falcom Sound Team jdk"
  expect_equal(check_block(block, "def")[["V2"]], c("all_role_artist"))
})


# [1] all
# […] role - artist
test_that("[1] all / […] role - artist", {
  # Normal
  block <- "All
  Composition: Hiroyuki Sawano
  Mixing: Mitsunori Aizawa"
  expect_equal(check_block(block, "def")[["V2"]], c("all", rep("role_artist", 2)))
  # With number
  block <- "All
  Composed: Artist01"
  expect_equal(check_block(block, "def")[["V2"]], c("all", rep("role_artist", 1)))
})


# [1] role
# […] artist - (track)
test_that("[1] role / […] artist - (track)", {
  # Normal
  block <- "Composer:
  Yasunori Mitsuda (1-5, 7-10)
  Noriko Matsueda (6)"
  expect_equal(check_block(block, "def")[["V2"]], c("role", rep("artist_(track)", 2)))
  # With disc notation inside Track
  block <- "Arrangers:
  Masashi Hamauzu (Disc1 M-01~07,10,18, Disc2 M-10, Disc3 M-01,18,19, Disc4 M-01,06,08~10,17~19)
  Naoshi Mizuta (Disc1 M-08,09,11,12,15,20, Disc2 M-01~03,05,07,11~13,15~17, Disc3 M-02,04~09,11,12,14,15, Disc4 M-04,07,11,12)"
  expect_equal(check_block(block, "def")[["V2"]], c("role", rep("artist_(track)", 2)))
})


# [1] role
# […] artist - [track]
test_that("[1] role / […] artist - [track]", {
  # Normal
  block <- "Lyrics by:
  Hironobu Kageyama [Tr.01-02,13]
  Yukie Ozaki [Tr.03,10-11]
  rino [Tr.04,08]
  test_artist 04 [Tr.05]"
  expect_equal(check_block(block, "def")[["V2"]], c("role", rep("artist_[track]", 4)))
  # Short
  block <- "Lyrics by:
  Hironobu 1234 Kageyama [Tr.01-02,13]"
  expect_equal(check_block(block, "def")[["V2"]], c("role", rep("artist_[track]", 1)))
})


# [1] role
# […] artist - track
test_that("[1] role / […] artist - track", {
  # Normal
  block <- "Composition:
  Yoshio Tsuru: 01~14, 16~31
  June Chikuma: 15, 34, 42, 47
  Hudson (Hironao Yamamoto): 32, 33, 35~41, 43~46, 48~50"
  expect_equal(check_block(block, "def")[["V2"]], c("role", rep("artist_track", 3)))
})


# […] disc - track
# [1] role - artist
test_that("[…] disc - track / [1] role - artist", {
  # Normal
  block <- "Disc 1: 2, 3
  Disc 2: 20
  Composed & Arranged by Yoko Shimomura"
  expect_equal(check_block(block, "def")[["V2"]], c(rep("disc_track", 2), "role_artist"))
  # Short
  block <- "Disc 1: 4, 5, 6, 10, 11, 12, 14, 15, 16, 17, 19, 20
  Composed & Arranged by Manami Kiyota"
  expect_equal(check_block(block, "def")[["V2"]], c(rep("disc_track", 1), "role_artist"))
})


# [1] role - artist
# […] disc - track
test_that("[1] role - artist / […] disc - track", {
  # Normal
  block <- "Composed by Keita Haga
  Disc1 : TR2-7,9-17
  Disc2 : TR2-22
  Disc3 : TR1-15,17-20,22,24-27"
  expect_equal(check_block(block, "def")[["V2"]], c("role_artist", rep("disc_track", 3)))
  # Short
  block <- "Composition - Go Ichinose & Hitomi Sato
  Disc 3: 5, 7"
  expect_equal(check_block(block, "def")[["V2"]], c("role_artist", rep("disc_track", 1)))
})


# [1] track - comment
test_that("[1] track - comment", {
  # Normal
  block <- "M-01-04 - Mini Drama"
  expect_equal(check_block(block, "def")[["V2"]], c("track_comment"))
})


# [1] comment - (track)
test_that("[1] comment - (track)", {
  # Normal
  block <- "Bonus Tracks (4.15~18)"
  expect_equal(check_block(block, "def")[["V2"]], c("comment_(track)"))
  # Numbers!!
  block <- "Nintendo 64 Tracks (1~7)"
  expect_equal(check_block(block, "def")[["V2"]], c("comment_(track)"))
})


# [1] comment - [track]
test_that("[1] comment - [track]", {
  # Normal
  block <- "Bonus Tracks [4.15~18]"
  expect_equal(check_block(block, "def")[["V2"]], c("comment_[track]"))
  # Numbers!!
  block <- "Nintendo 64 Tracks [1~7]"
  expect_equal(check_block(block, "def")[["V2"]], c("comment_[track]"))
})


# [1] comment - track
test_that("[1] comment - track", {
  # Normal
  block <- "Bonus Tracks: 4.15~18"
  expect_equal(check_block(block, "def")[["V2"]], c("comment_track"))
  # Numbers in comment --> Issue with comment/track detection
  block <- "Nintendo 64 Tracks: 1~7"
  result <- check_block(block, "def")
  expectation <- c("comment_track")
  expect_true(all(result[["V2"]] == expectation) || all(result[["V3"]] == expectation)) # If not first, it needs to be second
})


# [1] disc - track - comment
# […] role - artist
test_that("[1] disc - track - comment / […] role - artist", {
  # Normal
  block <- "Disc1 : TR1 - iOS/Android Game \"Fate/Grand Order\" Great Void Sea Battle: Imaginary Scramble -To the Surface, Nautilus!- TVCM Song
  Vocals: Hannah Grace
  Lyricist: Keiki Nishida
  Composer, Arranger: KOHTA YAMAMOTO
  Rec & Mix: Yasuomi Masuda"
  expect_equal(check_block(block, "def")[["V2"]], c("disc_track_comment", rep("role_artist", 4)))
})


# [1] disc - discsubtitle
test_that("[1] disc - discsubtitle", {
  # Normal
  block <- "Disc 3: ~Revolution~"
  expect_equal(check_block(block, "def")[["V2"]], c("disc_discsubtitle"))
  # Numbers
  block <- "Disc 2 - N64 Arrangements: The Dark Side"
  expect_equal(check_block(block, "def")[["V2"]], c("disc_discsubtitle"))
})


# [1] COMMENT
# […] track - comment
test_that("[1] COMMENT / […] track - comment", {
  # Normal
  block <- "COMMENT
  M-1.01~11 - from Steins;Gate
  M-1.12 - from Steins;Gate: Hiyoku Renri no Darling
  M-1.13,14 - from Steins;Gate: Senkei Kousoku no Phenogram
  M-1.15~19 - from STEINS;GATE 0
  M-2.25 - from CD:LIBRARIES II
  M-2.26 - 10th anniversary arrangement"
  expect_equal(check_block(block, "def")[["V2"]], c("COMMENT", rep("track_comment", 6)))
})


# [1] comment
# [1] role - artist
# […] disc - track
test_that("[1] comment / [1] role - artist / […] disc - track", {
  # Normal
  block <- "\"Overworld BGM\" from The Legend of Zelda
  Original Composition: Koji Kondo
  Disc 1 - 1, 14, 17, 24, 34
  Disc 2 - 37
  Disc 4 - 17, 26, 27, 31, 38, 39, 40
  Disc 5 - 36, 54, 59"
  expect_equal(check_block(block, "def")[["V2"]], c("comment", "role_artist", rep("disc_track", 4)))
  # Short
  block <- "\"Boss Clear Fanfare\" from The Wind Waker
  Original Composition: Hajime Wakai
  Disc 2 - 14"
  expect_equal(check_block(block, "def")[["V2"]], c("comment", "role_artist", rep("disc_track", 1)))
})


# [1] disc
test_that("[1] disc", {
  # Normal
  block <- "Disc 1"
  expect_equal(check_block(block, "def")[["V2"]], c("disc"))
  # Weird Format
  block <- "=Disc5="
  expect_equal(check_block(block, "def")[["V2"]], c("disc"))
})


# [1] role
# […] track - artist
# // OBSCURE AND HARD TO DIFFERENTIATE //
