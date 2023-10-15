# RetroChamber

Based on Emulation Station Desktop Edition with a focus on well pre-configured standalone emulators.

***Beware that this is an early preview version as of now.***

Before starting the first time, you can already place ROMs in the `roms/` directory, but it's not required.
At first run, `RetroChamber` will download & initialize `RetroArch` (stable), `Libretro` (nightly) cores, `EmulationStation Desktop Edition` (stable) & standalone emulators (stable/nightly) as an AppImage.

A list of available platforms can be found <a href="https://gitlab.com/es-de/emulationstation-de/-/blob/master/USERGUIDE.md?ref_type=heads#supported-game-systems">here</a>, but not all platforms are yet or will be supported in `RetroChamber`.

<img src="https://raw.githubusercontent.com/swmarc/RetroChamber/main/images/retro_chamber_logo-720.jpg" width="300px">

## Compatibility List

Libretro cores are based on nightly builds.

| Works                  | Partially works | Not working              | Unknown | Unsopprted                                     |
| ---------------------- | --------------- | ------------------------ | ------- | ---------------------------------------------- |
| 🟢                      | 🟡               | 🔴                        | ⚪       | 🔵                                              |
|                        |                 |                          |         |                                                |
| **Libretro Core(s)**   |                 | **Standalone**           |         | **Known issues**                               |
|                        |                 |                          |         |                                                |
| ***3DO***              |                 |                          |         |
| Opera                  | 🟢               |                          |         |
|                        |                 |                          |         |                                                |
| ***AGS***              |                 |                          |         |
| \-                     | \-              | \-                       | \-      | \-                                             |
|                        |                 |                          |         |                                                |
| ***AMIGA***            |                 |                          |         |
| PUAE                   | 🟡               |                          |         | Stores data in $HOME/.config/retroarch         |
| PUAE 2021              | 🟡               |                          |         | Stores data in $HOME/.config/retroarch         |
|                        |                 |                          |         |                                                |
| ***AMIGA1200***        |                 |                          |         |
| PUAE                   | ⚪               |                          |         | Stores data in $HOME/.config/retroarch         |
| PUAE 2021              | ⚪               |                          |         | Stores data in $HOME/.config/retroarch         |
|                        |                 |                          |         |                                                |
| ***AMIGA600***         |                 |                          |         |
| PUAE                   | ⚪               |                          |         | Stores data in $HOME/.config/retroarch         |
| PUAE 2021              | ⚪               |                          |         | Stores data in $HOME/.config/retroarch         |
|                        |                 |                          |         |                                                |
| ***AMIGACD32***        |                 |                          |         |
| PUAE                   | 🟢               |                          |         | Stores data in $HOME/.config/retroarch         |
| PUAE 2021              | 🟢               |                          |         | Stores data in $HOME/.config/retroarch         |
|                        |                 |                          |         |                                                |
| ***AMSTRADCPC***       |                 |                          |         |
| Caprice32              | 🟢               | CPCemu                   | 🔴       | Doesn't accept custom configuration file by /c |
| CrocoDS                | 🟢               | MAME                     | 🔵       |
|                        |                 |                          |         |                                                |
| ***ANDROID***          |                 |                          |         |
| ---                    | ---             | ---                      | ---     |
|                        |                 |                          |         |                                                |
| ***APPLE2***           |                 |                          |         |
|                        |                 | LinApple                 | 🟢       |
|                        |                 | Mednafen                 | 🟢       |
|                        |                 | MAME                     | 🔵       |
|                        |                 |                          |         |                                                |
| ***APPLE2GS***         |                 |                          |         |
|                        |                 | MAME                     | 🔵       |
|                        |                 |                          |         |                                                |
| ***ARCADE***           |                 |                          |         |
| MAME - Current         | ⚪               | MAME                     | ⚪       |
| MAME 2010              | ⚪               | FinalBurn Neo            | ⚪       |
| MAME 2003-Plus         | ⚪               | Flycast                  | ⚪       |
| MAME 2000              | ⚪               | Supermodel               | ⚪       |
| FinalBurn Neo          | ⚪               |                          |         |
| FB Alpha 2012          | ⚪               |                          |         |
| Flycast                | ⚪               |                          |         |
| Kronos                 | ⚪               |                          |         |
|                        |                 |                          |         |                                                |
| ***ARCADIA***          |                 |                          |         |
|                        |                 | MAME                     | ⚪       |
|                        |                 |                          |         |                                                |
| ***ARDUBOY***          |                 |                          |         |
| Arduous                | ⚪               |                          |         |
|                        |                 |                          |         |                                                |
| ***ASTROCDE***         |                 |                          |         |
| MAME - Current         | ⚪               | MAME                     | ⚪       |
|                        |                 |                          |         |                                                |
| ***ATARI2600***        |                 |                          |         |
| Stella                 | ⚪               | Stella                   | ⚪       |
| Stella 2014            | ⚪               | Gopher2600               | ⚪       |
|                        |                 | ares                     | ⚪       |
|                        |                 |                          |         |                                                |
| ***ATARI5200***        |                 |                          |         |
| a5200                  | ⚪               | Atari800                 | ⚪       |
| Atari800               | ⚪               |                          |         |
|                        |                 |                          |         |                                                |
| ***ATARI7800***        |                 |                          |         |
| ProSystem              | ⚪               |                          |         |
|                        |                 |                          |         |
| ***DREAMCAST***        |                 |                          |         |
| Flycast                | 🟢               | Flycast                  | ⚪       |                                                |
|                        |                 | redream                  | 🔵       |
|                        |                 |                          |         |
| ***FBNEO***            |                 |                          |         |
| FinalBurn Neo          | 🟢               | FinalBurn Neo            | 🔴       | Doesn't accept custom configuration            |
|                        |                 |                          |         |                                                |
| ***GC***               |                 |                          |         |
| Dolphin                | 🟢               | Dolphin - Setup Mode     | 🟢       |                                                |
|                        |                 | Dolphin - Play Mode      | 🟢       |                                                |
|                        |                 | PrimeHack                | 🔵       |
|                        |                 | Triforce                 | 🔵       |
| ***N3DS***             |                 |                          |         |
| Citra                  | 🟢               | Citra                    | 🔴       |                                                |
| Citra 2018             | 🟢               |                          |         |
|                        |                 |                          |         |                                                |
| ***NES***              |                 |                          |         |
| Mesen                  | 🟢               | puNES                    | ⚪       |
| Nestopia UA            | 🟢               | Mednafen                 | ⚪       |
| FCEUmm                 | 🟢               | ares                     | ⚪       |
| QuickNES               | 🟢               | ares FDS                 | ⚪       |
|                        |                 |                          |         |                                                |
| ***PS2***              |                 |                          |         |
| LRPS                   | 🔴               | PCSX2 - Setup Mode       | 🟢       |
|                        |                 | PCSX2 - Play Mode        | 🟢       |
|                        |                 | Play! - Setup Mode       | 🟢       |
|                        |                 | Play! - Play Mode        | 🟢       |
|                        |                 |                          |         |                                                |
| ***PSX***              |                 |                          |         |
| Swanstation            | 🟢               | Duckstation - Setup Mode | 🟢       |
| PCSX ReARMed           | 🟢               | Duckstation - Play Mode  | 🟢       |
| Beetle PSX             | 🟢               | Mednafen                 | ⚪       |
| Beetle PSX HW          | 🟢               |                          |         |
|                        |                 |                          |         |                                                |
| ***SATURN***           |                 |                          |         |
| Beetle Saturn          | 🟢               | Mednafen                 | 🟡       | No sound, no controller                        |
| Kronos                 | 🟢               |                          |         |
| YabaSanshiro           | 🟢               |                          |         |
| Yabause                | 🟡               |                          |         |
|                        |                 |                          |         |                                                |
| ***SCUMMVM***          |                 |                          |         |
| ScummVM                | 🟢               | ScummVM                  | 🟢       |
|                        |                 |                          |         |                                                |
| ***SNES***             |                 |                          |         |
| Snes9x - Current       | 🟢               | Snes9x                   | ⚪       |
| Snes9x 2010            | 🟢               | bsnes                    | ⚪       |
| bsnes                  | 🟢               | Mednafen                 | ⚪       |
| bsnes-hd               | 🟢               | ares                     | ⚪       |
| bsnes-mercury Accuracy | 🟢               |                          |         |
| Beetle Supafaust       | 🟢               |                          |         |
| Mesen-S                | 🟢               |                          |         |
|                        |                 |                          |         |                                                |
| ***WII***              |                 |                          |         |
| Dolphin                | 🟢               | Dolphin - Setup Mode     | 🟢       |                                                |
|                        |                 | Dolphin - Play Mode      | 🟢       |                                                |
|                        |                 | PrimeHack                | 🔵       |
|                        |                 |                          |         |                                                |
