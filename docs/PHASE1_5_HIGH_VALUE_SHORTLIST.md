# Phase 1.5 — High-Value Shortlist (RogueMaster External Apps)

Docs only. This is the automated candidate pool from `PHASE1_5_RM_APP_BULK_TRIAGE.md`:
**195 apps** that (a) declare a safe `fap_category` (Games, Tools, Tools/Educational,
Media, Settings, Main), (b) had zero hits in the 12-category safety-keyword scan
(run against both `fap_description` and README text), and (c) have a real README,
author, and description on file (i.e., are documented enough to evaluate at all).

**What "candidate" means here, precisely:** passed this automated filter and is
worth a human giving it a real look before import. It does **not** mean
security-reviewed, license-checked, or build-tested. None of these have been copied
anywhere; this is a reading list, not an import queue.

**Common fields for every row below** (stated once instead of 195 times): Source
path is `applications/external/<App>/` in the RogueMaster clone (commit
`472f6925e8aca9bd031cb37e3cb80b551772c957`). Dependencies: none declared beyond
standard Flipper GUI/dialogs/storage APIs (no unusual `requires=[...]` entries were
found in this pool — an app with an unusual dependency would need its own note, and
none did). Safety/legal risk: none identified by the automated pass (see the flagged
exceptions immediately below the tables — a few apps in categories that look
completely safe still deserved a specific callout). Hardware risk: none beyond
normal on-device execution, *except* the flagged exceptions below.

## Apps that passed the automated filter but still need an explicit flag

The automated filter is based on category + keyword scan; it does not read source
code or think about what a feature actually does. A few apps slipped through the
filter clean but deserve a specific note before anyone assumes "candidate" means
"no further thought needed":

| App | Why it needs a note |
|---|---|
| `bomberfox` (Games) | Uses the Flipper's Sub-GHz radio to transmit between two Flippers for local two-player gameplay. Not a risk in the excluded sense (no third-party targeting), but it does transmit RF — flag as "transmits RF, device-to-device gameplay only," not "no radio risk." |
| `rock_paper_scissors` (Games) | Same as above — Sub-GHz radio used for local two-player play only. |
| `flipper_wedge` (Tools) | Reads RFID/NFC tag UIDs and **types them out via USB/Bluetooth HID**. Legitimate "keyboard wedge" reader pattern (common in physical security/IT), but it does perform HID keystroke output — same general caution class as BadUSB tools, just with a fixed, non-arbitrary payload (the tag's own UID). Worth an explicit note rather than filing under "no hardware/HID interaction." |
| `keycopier` (Tools) | "Measure and save Kwikset/Schlage physical keys" — a physical-locksmithing utility (key bitting capture). Same category of caution as `combocracker` in the Phase 1 Risk Register: legitimate for your own keys, no ownership check possible in software. |
| `lishi_hu66` (Tools) | Logs values obtained from a Lishi lock-pick tool. Doesn't perform picking itself, but is adjacent to lock-picking hobby tooling — noting for completeness, not proposing exclusion. |
| `disn3y_toolbox` (Tools) | Includes a "MagicBand+ beacon emulator" and "Kyber crystal writer" for Disney theme-park wearables — writes/emulates third-party-manufactured hardware. Very likely intended for personalizing your own device (a well-documented hobbyist activity in that community, since Disney provides no official tool), but it's writing to hardware you may not have designed, so it gets a note rather than a blank pass. |
| `id_card_v2` (Tools), `keyller` (Games) | Descriptions are too thin ("manages an ID card" / "Echo Keyller/Executor Keychain") to classify confidently either way — flag as "purpose unclear from metadata, read source before considering." |

None of the above are proposed for the Top 25 (see that document) precisely because
of these notes — Top 25 sticks to unambiguous, zero-footnote candidates.

## Full candidate table (195 apps, grouped by declared category)

### Games (105 candidates)

| App | Purpose | Author | Complexity |
|---|---|---|---|
| `1dpacman` | 1D Pacman using the Flipper Game Engine | easiwork | Low-Med |
| `2048` | Port of 2048 | eugene-kirzhanov | Low-Med |
| `4inrow` | 4 in a row | leo-need-more-coffee | Low-Med |
| `applegrabber` | Falling-apples catch game (vertical mode) | d7d8 / Julio Rodriguez | Low-Med |
| `ardudrivin` | Ported race game | apfxtech | Low-Med |
| `arduventure` | Retro RPG adventure | apfxtech | Med-High |
| `asteroids` | Classic Asteroids | antirez & SimplyMinimal | Low-Med |
| `avocado_zero` | Avocado-growing sim | Endika | Low-Med |
| `blackjack` | Blackjack | teeebor | Medium |
| `bomberduck` | Bomberman-style | leo-need-more-coffee & x | Low-Med |
| `bomberfox`* | Two-player Bomberman over Sub-GHz | Electric Fox | Low-Med |
| `brainy` | Simon Says memory game | Deya Elkhawaldeh | Low-Med |
| `bzzbzz` | Haptic rhythm-matching game | Koray Er | Low |
| `catacombs` | Ported Arduboy3D game | apfxtech | Med-High |
| `cell_lab` | Pixel-world life simulator | PilotOfAsuka | Low-Med |
| `chess` | Chess | Struan Clark (xtruan) | Medium |
| `cigarette` | Novelty "smoke break" animation | fuckmaz | Low-Med |
| `citybloxx` | Tower-stacking game | Milk-Cool | Low |
| `cognizant_flipper` | Random word generator | Luke Gamertsfelder | Low-Med |
| `color_guess` | Color guessing game | Leedave | Low-Med |
| `connect_wires` | Wire-rotation puzzle | AlexTaran | Low-Med |
| `countdown` | UK "Countdown" numbers game | Oscar Rodriguez | Low-Med |
| `crossy_road` | Frogger clone (WIP) | Mikael098 | Low |
| `deadzone` | Side-scrolling survival game | retrooper | Medium |
| `decision_maker` | Random-choice roulette | jacki | Low-Med |
| `dice2` | Multi-sided dice roller | Ka3u6y6a | Medium |
| `digital_kaleidoscope` | Kaleidoscope visualizer | J. Randall | Low-Med |
| `doom` | Doom port | xMasterX & Svarich & hedger | Med-High |
| `drifter` | Boat game | Jed Lejosne | Low-Med |
| `eightball` | Magic 8-ball | Steven Quinn | Low |
| `etch_a_sketch` | Etch A Sketch | SimplyMinimal | Low-Med |
| `fighter_jet` | Fighter jet simulator | Erbonator3000 | Low |
| `fish` | Simple survival game | Invizabel | Low |
| `flight_assault` | Spacecraft combat game | evillero | Low-Med |
| `flipper_questions` | Icebreaker question game | nikilark | Low-Med |
| `flippy_road` | Road game | rkilpadi | Low |
| `fliprogue` | Roguelike dungeon | Abzac | Medium |
| `fmatrix` | "Matrix rain" screensaver | misterwaztaken | Low-Med |
| `fortune_cookie` | Random motivational quotes | evillero | Low-Med |
| `furious_birds` | Angry-Birds-style game | Dmitry Ermashev | Low-Med |
| `game15` | 15-puzzle logic game | x27 | Low-Med |
| `game_of_life` | Conway's Game of Life | tgxn | Low-Med |
| `geometryflip` | Geometry Dash demake | goosedev72-projects | Low-Med |
| `golf` | Ported Wolfenduino game | apfxtech | Med-High |
| `groks_adventure` | Micro text adventure | DigiMancer3D | Low-Med |
| `guessing_game` | Akinator/20-questions style | Miksang | Low |
| `hangman` | Hangman | Evgeny Stepanischev | Low-Med |
| `hanoi_towers` | Towers of Hanoi | AlexTaran | Low-Med |
| `holdem` | Single-player Texas Hold'em vs. bots | code-phreak | Medium |
| `hunter_flipper` | Pico-8 submarine-warfare port | josephburnett | Low-Med |
| `impostor` | Undercover-style word game | Endika | Low-Med |
| `infinite_tic_tac_toe` | Infinite tic-tac-toe | Kyle Diller | Low |
| `jetpack_joyride` | Jetpack side-scroller | timstrasser | Low-Med |
| `jumping_pawns` | Racing board game | Tyl3rA | Low-Med |
| `kcline` | Dot-munching game | Andrew Diamond | Low-Med |
| `keyller`* | Unclear — see flagged note above | Esteban Fuentealba | Low-Med |
| `matagotchi` | Tamagotchi-like pet sim | MrModd | Low-Med |
| `minesweeper` | Minesweeper | Alexander Rodriguez | Med-High |
| `minesweeper_og` | Minesweeper (alt. implementation) | panki27 & xMasterX | Low-Med |
| `mode7_demo` | Pseudo-3D Mode 7 rendering demo | CookiePLMonster | Med-High |
| `monster_slayer` | RPG-style game | ratmanZorry | Low-Med |
| `morse_code_learning_toolkit` | Morse code learning tool | P1X / w84death | Low-Med |
| `multi_counter` | 4-way tabletop-game counter | JadePossible & Roro | Med-High |
| `mysticballoon` | Ported Mystic Balloon game | apfxtech | Medium |
| `nupogodi_game` | Soviet retro "Nu, Pogodi!" clone | sionyx | Low-Med |
| `p1x_flipper_and_watch` | Game & Watch-style "Network Defender" | Krzysztof Krystian Jankowski | Low-Med |
| `panis` | Jump'n'run game | F Greil | Low-Med |
| `paperplane` | Obstacle-dodging game | Larry-the-Pig | Low-Med |
| `pinball0` | Pinball with JSON-defined tables | Roberto De Feo | Low-Med |
| `platformer_game` | Simple platformer | adevil5 | Low |
| `pocket_battle` | Pokémon-battle-style game | HermeticCode | Low-Med |
| `pong` | Pong | nmrr & SimplyMinimal | Low-Med |
| `quadrastic` | Arduboy-inspired puzzle game | ivanbarsukov | Medium |
| `race_game` | 3-lane racer | mrc19056 | Low-Med |
| `racegame` | BrickGame-inspired racer | zyuhel | Low-Med |
| `reaction_game` | Reaction test | Milk-Cool | Low |
| `reaction_time` | Reaction time test | ihatecsv | Low |
| `reversi` | Reversi/Othello | dimat | Low-Med |
| `rmdice` | Multi-sided dice roller for tabletop RPGs | RogueMaster | Low-Med |
| `rock_paper_scissors`* | RPS over Sub-GHz between two Flippers | jamisonderek | Medium |
| `rock_paper_scissors2` | RPS (local, alt. implementation) | benwoo1110 | Low |
| `rocketgod_blackjack` | Blackjack (alt. implementation) | RocketGod-git | Low-Med |
| `rubiks_cube_scrambler` | Rubik's Cube scramble generator | RaZeSloth | Low |
| `schip` | SUPER-CHIP/Chip8 emulator | Milk-Cool | Low |
| `scorched_tanks` | Scorched-Earth-style artillery game | jasniec | Low-Med |
| `secret_toggle` | Square-toggling puzzle | nostrumuva | Low-Med |
| `simonsays` | Simon Says | SimplyMinimal & ShehabAtef | Low-Med |
| `slots` | Slot machine simulator | Daniel-dev-s | Medium |
| `snake_2` | Enhanced Snake remake | Willzvul | Low-Med |
| `space_impact` | Nokia "Space Impact" port | Ka3u6y6a | Low |
| `space_invaders` | Space Invaders | PavelZurek | Low |
| `stratagem_hero` | Helldivers 2 minigame clone | Maxim Kulkin | Low-Med |
| `stratagemzero` | Stratagem Hero clone (alt.) | Nymda | Low |
| `sudoku` | Sudoku | profelis | Low-Med |
| `t_rex_runner` | Chrome T-Rex runner port | Rrycbarm | Med-High |
| `tanks` | Battle-City-style tank game | alexgr13 & b1rd & lagous | Low-Med |
| `tarot` | Tarot card reader (novelty) | pionaiki & tihyltew | Low-Med |
| `trivia_zero` | Bilingual flashcard trivia | Endika | Medium |
| `ultimate_tic_tac_toe` | Ultimate tic-tac-toe | Racso | Low-Med |
| `vexed` | Palm OS "Vexed" puzzle clone | Dominik Dzienia | Medium |
| `volorsavanna` | Text-adventure game | Invizabel | Low-Med |
| `wave_game` | Obstacle-dodging wave game | sergo | Medium |
| `wolfenduino` | Ported Wolfenduino game | apfxtech | Med-High |
| `yatzee` | Yahtzee | emfleak | Low-Med |
| `zero` | Card game "ZERO!" | Racso | Low-Med |

*Starred entries have a note in the flagged-exceptions table above.*

### Main (1 candidate)

| App | Purpose | Author | Complexity |
|---|---|---|---|
| `dab_timer` | Clock with stopwatch and configurable alarm | RogueMaster | Low-Med |

### Media (19 candidates)

| App | Purpose | Author | Complexity |
|---|---|---|---|
| `bpmtapper` | Tap-tempo BPM counter | panki27 | Low-Med |
| `dvd_screensaver` | DVD-logo screensaver | shantih19 | Low |
| `fmf2usbmidi` | Converts FZ Music Player files to MIDI over USB | crackerjacques | Low-Med |
| `guido_score_reader` | Guido music-notation file reader | F Greil | Low-Med |
| `image_scroller` | Large tiled-image scroller | F Greil | Low-Med |
| `image_viewer` | Image viewer | polioan | Low |
| `karl_eido` | Optical-instrument pattern generator | F Greil | Low |
| `metronome` | Metronome | panki27 & xMasterX | Low-Med |
| `midi_ocarina` | Plays MIDI notes over USB on button press | crackerjacques | Low-Med |
| `midi_player` | Standard MIDI file player | Aspenini | Low-Med |
| `midi_rx` | Receives and plays MIDI | crackerjacques | Low |
| `morse_code` | Morse code parser | wh00hw & xMasterX | Low |
| `ocarina` | Ocarina of Time-style instrument | invalidna-me | Low |
| `snowflake` | Aesthetic image viewer | F Greil | Low-Med |
| `space_playground` | Space simulation playground | Alan Silva | Low-Med |
| `text2sam` | Text-to-speech (SAM engine) | Round-Pi | Low-Med |
| `video_player` | Video+audio player | LTVA | Low-Med |
| `wav_player` | WAV audio player | DrZlo13 | Low-Med |
| `windbreak` | Novelty sound-effect app | F. Greil | Low-Med |

### Settings (2 candidates)

| App | Purpose | Author | Complexity |
|---|---|---|---|
| `animation_switcher` | Switch background dolphin animations | lsalik2 | Low-Med |
| `theme_manager` | Manage dolphin animation themes from SD card | Hoasker | Low-Med |

### Tools (61 candidates)

| App | Purpose | Author | Complexity |
|---|---|---|---|
| `analogclock` | Analog clock display | scrolltex | Low |
| `animation_previewer` | Preview dolphin animations from SD card | H4W9 | Low-Med |
| `barcode_gen` | Display barcodes | Kingal1337 | Low-Med |
| `big_clock` | Bedside clock, adjustable brightness | Eris-Margeta | Low-Med |
| `blackjack_counter` | Blackjack card-counting aid | grugnoymeme | Low |
| `blinker` | Slowing-blink LED effect | Cupprum | Low-Med |
| `brainfuck` | Brainfuck language interpreter | nymda | Low-Med |
| `caesarcipher` | Caesar cipher encode/decode | panki27 | Low-Med |
| `cal_weeks` | Weekly organizer | F. Greil | Low-Med |
| `calendar` | Calendar | Adiras | Low-Med |
| `can_tools` | CAN bus DBC creation/decoding | Matthew KuKanich | Low-Med |
| `cntdown_timer` | Countdown timer | 0w0mewo | Low |
| `counter` | General-purpose counter | TEXploder | Med-High |
| `disn3y_toolbox`* | Disney park-tech toolbox (see flagged note) | Nathaniel Belles | Medium |
| `docviewlite` | Simple document viewer | C0d3-5t3w | Low |
| `enigma` | Enigma-machine simulator | Struan Clark (xtruan) | Low-Med |
| `eye_saver` | 20-20-20 eye-strain reminder | paul-sopin | Low-Med |
| `fcc_id_lookup` | Offline FCC ID/frequency lookup | lrehmann | Low-Med |
| `flipaid` | Emergency-response pulse/CPR timer | spaghety | Low |
| `flipfetch` | Device-info display ("neofetch"-style) | Ismael A. Rodríguez | Low |
| `flipnote` | On-device text editor | morty517 | Low-Med |
| `flipper95` | Prime-number stress test | Silent / CookiePLMonster | Low |
| `flipper_wedge`* | RFID/NFC UID-to-HID keyboard wedge (see flagged note) | Dangerous Things | Medium |
| `flippertasks` | To-do list | Stanislav Vasilev | Low-Med |
| `flipperzero_clock` | Customizable clock | mdaskalov | Low-Med |
| `gnomishtool` | Novelty multitool | Andreeved88 | Low-Med |
| `hex_editor` | Line-based text file editor | dunaevai135 | Low-Med |
| `hex_viewer` | Hex file viewer | QtRoS | Low-Med |
| `hyper_focus_calc` | Hyperfocal-distance photography calculator | Endika | Low-Med |
| `iconedit` | Icon editor | Roberto De Feo | Medium |
| `id_card_v2`* | ID card manager — unclear scope, see flagged note | evillero | Low-Med |
| `keycopier`* | Physical key-bitting logger (see flagged note) | zinongli | Low-Med |
| `lightning_distance` | Lightning-distance calculator | HyperMuffin12 | Low |
| `lishi_hu66`* | Lishi lock-pick value logger (see flagged note) | evillero | Low-Med |
| `math_wiz` | Trig/calculus calculator | Papa_Ghost | Low-Med |
| `mayan_decoder` | Decimal-to-Mayan numeral converter | Roger F5 | Low-Med |
| `mitzi_tree_ident` | Tree-identification quiz | fgreil | Low-Med |
| `multitimer` | Multi-timer with external display support | C0d3-5t3w | Low-Med |
| `name_gen` | Random name generator | disaxq | Low |
| `network_subnet` | IPv4 subnet calculator | aaumkar | Low-Med |
| `nightstand_clock` | Clock with brightness control | nymda & WillyJL | Low |
| `orgasmotron` | Vibration-pattern novelty app | Leedave | Low-Med |
| `p1x_moon_phases` | Moon-phase display | Krzysztof Krystian Jankowski | Low |
| `pomodoro_og` | Pomodoro timer | sbrin | Low-Med |
| `programmer_calc` | Programmer's calculator | armixz | Medium |
| `qrcode` | QR code display | Bob Matcuk | Low-Med |
| `quadratic_solver` | Quadratic-equation solver | paul-sopin | Low-Med |
| `resistors` | Resistor color-code calculator | Lewis Westbury | Med-High |
| `roman_decoder` | Roman-numeral converter | evillero | Low-Med |
| `rot13` | ROT13 cipher | nothingbutlucas | Low-Med |
| `sd_info` | SD card info display | sergo | Low-Med |
| `segment_clock` | Segment-display clock | Sladkisnovraper | Low |
| `space_calculator` | Interplanetary-transfer planner (KSP-style) | ejfox | Low-Med |
| `space_dilate` | Relativistic time-dilation calculator | ejfox | Low |
| `spindle_calc` | Stair-spindle spacing calculator | Jordan M | Medium |
| `techart_calendar` | Calendar | TechArtDev | Low |
| `tone_gen` | Audio tone generator | Gerald McAlister | Low-Med |
| `type_aid` | On-device typing aid | F Greil | Low-Med |
| `upython` | MicroPython script runner | Oliver Fabel | Med-High |
| `vin_decoder` | VIN (Vehicle Identification Number) decoder | evillero | Low-Med |
| `voltcalc_app` | Voltage/VRI calculator | HappyAmos | Low-Med |

### Tools/Educational (7 candidates)

| App | Purpose | Author | Complexity |
|---|---|---|---|
| `ascii` | ASCII table reference | x10102 | Low |
| `boilerplate` | FAP template/starter project | leedave | Low-Med |
| `book_of_answers` | "Magic 8-ball"-style answer book | redbson | Low-Med |
| `c_book` | "The C Programming Language" reference (K&R) | armixz | Low-Med |
| `cocktail_book` | Cocktail recipe reference | resu95 | Low-Med |
| `crypto_dictionary` | Cryptography glossary | armixz | Low-Med |
| `survival_manual` | Offline survival reference (public-domain US Army manual) | Louis | Medium |

## Next step

`PHASE1_5_TOP_25_CANDIDATES.md` narrows this pool to 25 for a first real integration
attempt, once approved. `PHASE1_5_EXCLUSION_LIST.md` covers the apps deliberately
kept out of this pool.
