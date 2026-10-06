# Runclub Garmin watch face

A Connect IQ / Monkey C prototype with original placeholder club artwork. The watch face shows digital time, date, battery, steps, and recent heart rate above a running track and two runners. Replace the branding when the club media is ready.

Club colors are black (`#000000`) and lime (`#CCFC00`), recorded in `media/branding.txt`. The track, date, club name, and launcher icons use lime; data uses readable white/gray. MIP devices map the accent to their supported palette.

**Status:** debug, release, and test builds compile without warnings for the Forerunner 255, 265, and 965 using Connect IQ SDK 9.2.0. Both formatting tests pass on all three Garmin simulators. Release binaries are in `bin/`; simulator evidence and the remaining hardware checks are recorded in [docs/VALIDATION.md](docs/VALIDATION.md).

## Initial targets

| Garmin model | Product ID | Screen | Low-power behavior |
| --- | --- | --- | --- |
| Forerunner 255 | `fr255` | 260 × 260, MIP | Full face, minute updates |
| Forerunner 265 | `fr265` | 416 × 416, AMOLED | Small gray clock on black |
| Forerunner 965 | `fr965` | 454 × 454, AMOLED | Small gray clock on black |

These targets have device-specific builds. Physical-watch testing is still required. Other models can be added after obtaining their Garmin device definitions and testing their layout and memory limits. Square and monochrome displays need their own design adaptation.

## Setup on this machine

1. The **Forerunner 255, 265, and 965** profiles and fonts are installed on this machine. On a fresh machine, open SDK Manager, sign in, and download those profiles. Keep its normal device-data location; if you choose a custom location, ensure the compiler and simulator use that same location.
2. The downloaded SDK is `.tools/connectiq-sdk`. The installed Java 8 runtime successfully runs its 9.2.0 compiler. For another machine, install the SDK using [Garmin's setup page](https://developer.garmin.com/connect-iq/sdk/) and set `CONNECTIQ_SDK_HOME` to the SDK directory containing `bin`.
3. The VS Code extension recommendation is included. For debugging, use **Monkey C: Verify Installation**, select the installed SDK, and configure your developer key through the extension. Command-line scripts work independently of VS Code settings.
4. A local signing key was generated in `.secrets/developer_key.der`. Back up this key privately and reuse it for later releases. `.secrets`, downloaded tools, and build outputs are ignored by Git. On a fresh checkout, run `scripts/New-DeveloperKey.ps1` once or set `CONNECTIQ_DEVELOPER_KEY` to an existing key. Never replace a published app's signing key casually.

## Build and run

Run from this directory in PowerShell after device profiles have been installed:

```powershell
# All initial targets; a failure stops the script.
.\scripts\Build.ps1

# One target, then open the interactive Garmin simulator.
.\scripts\Build.ps1 -Device fr265
.\scripts\Simulate.ps1 -Device fr265

# Unit-test build and run (uses Garmin's actual runtime).
.\scripts\Build.ps1 -Device fr265 -TestBuild
.\scripts\Simulate.ps1 -Device fr265 -Tests

# Device binaries without debug information.
.\scripts\Build.ps1 -Release
```

For a different SDK location:

```powershell
$env:CONNECTIQ_SDK_HOME = 'C:\path\to\connectiq-sdk'
$env:CONNECTIQ_DEVELOPER_KEY = 'C:\private\developer_key.der'
.\scripts\Build.ps1
```

If the compiler reports **Invalid device id**, the required Garmin device profile has not been installed or is not available in the compiler's configured device-data location. A manifest entry alone does not install a profile.

## Behavior and customization

- Time follows the watch's 12/24-hour setting. AM/PM appears next to the battery in 12-hour mode. The date uses Garmin's localized abbreviated day and month names; app labels are currently English.
- Steps use daily activity data and show `--` when tracking is disabled or data is unavailable. Counts of 100,000 or more are abbreviated to keep the layout readable.
- Heart rate uses a positive recorded sample from the last five minutes. Missing or zero readings show `--`. This is recent history, not a live sensor stream. The app does not enable sensors, request location, store health data, or make network requests.
- Data reads are cached for the current minute. Garmin controls watch-face update callbacks; there are no timers, animations, seconds display, or partial updates.
- AMOLED devices use a build-time display profile, including models whose `requiresBurnInProtection` flag is false. The sleep clock moves among four separate bands; see the validation record for measured pixel coverage. Always-on behavior also depends on the watch's system settings.
- The small MIP layout omits the tagline. System fonts have size fallbacks, and coordinates scale from a 260-pixel round canvas.
- Change club name and tagline in `resources/strings/strings.xml`. Original placeholder geometry and colors live in `source/ClubArtwork.mc`; it contains no time or health-data logic. Replace its drawing with club bitmap resources later and use device/family resource overrides for resolution-specific assets. Do not bake changing numbers into artwork.
- `resources-amoled/properties.xml` selects the AMOLED sleep behavior for the two AMOLED product entries in `monkey.jungle`. Add this override for any future AMOLED target.

## Validation

See [the validation record and previews](docs/VALIDATION.md). The pure formatting tests cover midnight/noon, 12/24-hour time, missing readings, large step counts, and battery boundaries. Both tests passed on all three target simulators and can be rerun using the commands above.

All six resource XML files pass the installed SDK's schema. Repeat that check after changing resources:

```powershell
.\scripts\Check-Resources.ps1
```

## Install on a watch after validation

1. Build the release for the **exact** model. For example, `Build.ps1 -Device fr265 -Release` creates `bin/runclub-fr265-release.prg`.
2. Connect the watch by USB using a data-capable cable and copy that `.prg` to its `GARMIN/APPS` directory. Disconnect safely.
3. Select **Runclub Prototype** in the watch's watch-face settings. Check readability outdoors, heart-rate availability, and wake/sleep transitions.

Do not use a 265 build on a 265S or another model; each needs its own manifest target and build. Club-wide distribution through the Connect IQ Store comes after real-device testing and final artwork. Store publication has not been performed.

## References

- [Garmin: first Connect IQ app and device installation](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/)
- [Garmin: watch-face display guidelines](https://developer.garmin.com/connect-iq/user-experience-guidelines/watch-faces/)
- [Garmin: SensorHistory API](https://developer.garmin.com/connect-iq/api-docs/Toybox/SensorHistory.html)
