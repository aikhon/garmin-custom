# Run Club Atyrau Garmin watch face

A sports watch face built in Monkey C. On `redesign/lime-and-black`, neon lime (#CCFF00) is the primary active background and black (#000000) is the secondary color for filled hours, hollow minutes, text, activity progress, icons, club logo, and the supplied Atyrau skyline. Squared Chakra Petch typography, subtle lime contours, and muted lime gauge tracks complete the face.

[Forerunner 265 preview](docs/previews/fr265-chakra-petch.png) · [Validation results](docs/VALIDATION.md). Other simulator previews show the previous design.

## Supported prototype targets

| Model | Product ID | Screen | Sleep display |
| --- | --- | --- | --- |
| Forerunner 255 | fr255 | 260 x 260, MIP | Large clock, date, small logo |
| Forerunner 265 | fr265 | 416 x 416, AMOLED | Small clock, date, logo in moving bands |
| Forerunner 965 | fr965 | 454 x 454, AMOLED | Small clock, date, logo in moving bands |

Debug and release builds compile without warnings. Three formatting tests pass on all three target simulators. Real-watch testing and Store publication are pending. These files require the exact listed model; 255S, 255 Music, and 265S need separate builds.

## Data and gauges

- Time follows the watch's 12/24-hour setting. AM/PM appears beside the battery in 12-hour mode. Date uses English abbreviated names and the watch's local calendar.
- Battery has a black outline icon with proportional black fill. An unavailable percentage is hidden.
- Steps come from today's ActivityMonitor data, abbreviated as 12.4K where needed. Missing steps display 0. The arc follows the watch's daily step goal, using 10,000 only if the goal is unavailable.
- Distance comes from ActivityMonitor's daily distance in centimeters, converted to kilometers. Below 10 km it uses one decimal; larger distances use whole kilometers. Missing distance displays 0.0. The distance arc reaches full scale at 5 km.
- Heart rate uses a positive recorded sample from the last five minutes. Missing or zero readings display --. Its arc uses a 0-200 BPM scale.
- Gauges have 270-degree arcs with a bottom gap. Progress is clamped to 0-100%.
- Data is cached for the current minute. No sensors are enabled, no health data is stored, and no network connection is needed.

Gauge scales and the normalized layout are centralized in source/DesignTokens.mc. Coordinates use the minimum screen dimension and a centered square, with fonts generated from a 454-pixel reference. The logo sits at the top. The skyline spans 90% of the screen width with its ground line anchored to the bottom; the round display deliberately crops the panorama.

## Assets and typography

Original media remains in media/:

- logos/logo-runclub-black.png: original transparent club logo, compiled in black for active mode and MIP sleep, and gray for AMOLED sleep. Its embedded EST text is masked in both active and sleep views; no year label is displayed.
- skyline/black_skyline.png: supplied skyline, including the original landmarks, compiled in black with lime details. The lime variant is retained as source media. No tourism wordmark is rendered.
- fonts/: Chakra Petch Bold, SemiBold, and Medium files with ChakraPetch-OFL.txt. Original Barlow Condensed files and OFL.txt are retained as source media.
- branding.txt: current colors and source references.

Garmin scales the logo and skyline at compile time. PNG transparency is retained. The monochrome icons and contour resources are drawn deterministically from vector primitives by scripts/Generate-DesignResources.ps1. The same script generates device-specific bitmap-font atlases: TimeFilled contains only digits and colon, and TimeOutline contains only hollow digit shapes. Outlines are genuine rasterized glyph outlines, not repeated drawText calls.

All fonts, icons, logo variants, skyline, and background resources are loaded once. Sleep mode removes contours, gauges, metrics, and skyline. AMOLED uses gray text on black in four non-overlapping bands to let pixels rest between appearances. MIP retains a lime background with a large black clock and a small black logo. Display type is compiled into each device binary and cannot be changed by stale app properties.

To regenerate the committed design resources after font or device-size changes:

```powershell
.\scripts\Generate-DesignResources.ps1
```

## Build and test

On this machine, SDK 9.2.0 is installed in .tools/connectiq-sdk, device profiles and fonts are installed, and a private signing key is in ignored .secrets/. VS Code has the official Garmin Monkey C extension. On a fresh machine, follow Garmin's SDK setup, download the three profiles, and set CONNECTIQ_SDK_HOME to the SDK directory containing bin. Generate a private key with scripts/New-DeveloperKey.ps1 or set CONNECTIQ_DEVELOPER_KEY to an existing key.

```powershell
.\scripts\Build.ps1
.\scripts\Build.ps1 -Release
.\scripts\Simulate.ps1 -Device fr265
.\scripts\Build.ps1 -Device fr265 -TestBuild
.\scripts\Simulate.ps1 -Device fr265 -Tests
.\scripts\Check-Resources.ps1
```

Use Monkey C: Verify Installation and configure the SDK/signing key in VS Code for debugging. Signing keys, downloaded tools, and generated binaries are excluded from Git. Back up the signing key privately for subsequent releases.

## Install

The local package bin/runclub-prototype.zip contains the three release PRG files, INSTALL.txt, and the bundled font's OFL license.

1. Connect the exact supported watch with a USB data cable.
2. Copy the matching runclub-frXXX-release.prg to its GARMIN/APPS folder.
3. Disconnect safely and choose Run Club Atyrau in watch-face settings.
4. Check outdoor legibility, sleep/wake behavior, real activity data, and battery use during normal wear.

## References

- Garmin setup: https://developer.garmin.com/connect-iq/sdk/
- Watch-face guidelines: https://developer.garmin.com/connect-iq/user-experience-guidelines/watch-faces/
- ActivityMonitor API: https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityMonitor/Info.html
- Chakra Petch source and license: https://github.com/google/fonts/tree/main/ofl/chakrapetch
- Original Barlow Condensed source and license: https://github.com/google/fonts/tree/main/ofl/barlowcondensed
