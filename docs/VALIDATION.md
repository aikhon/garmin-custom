# Prototype validation

Validated on 6 October 2026 using Garmin Connect IQ SDK 9.2.0 and the official device profiles. The supplied black Run Club Atyrau logo is displayed on a lime background.

After the logo update, debug and release builds passed without warnings for all three targets and the active previews were inspected and refreshed. The original transparent PNG is scaled by Garmin's resource compiler. The 965 sleep/wake check confirmed that the lime active face switches to the dark always-on clock and returns on wake. Formatting logic is unchanged from the tested version.

## Build and runtime results

| Target | Debug / release builds | Formatting tests (before branding update) | Observed simulator memory |
| --- | --- | --- | --- |
| Forerunner 255 | Pass, no compiler warnings | 2 passed, 0 failed | About 8.6 KB of 123.9 KB available |
| Forerunner 265 | Pass, no compiler warnings | 2 passed, 0 failed | About 8.7 KB of 123.9 KB available |
| Forerunner 965 | Pass, no compiler warnings | 2 passed, 0 failed | About 8.7 KB of 123.9 KB available |

Memory values are observed simulator readings, not measured physical battery consumption or exhaustive peak-memory profiles. Signing keys are local and excluded from version control.

- `timeBoundaries` checks midnight, noon, 23:59, 12/24-hour formatting, and minute zero padding.
- `missingAndLargeData` checks missing/zero heart rate, zero steps, comma-separated steps through 99,999, abbreviated 100,000 steps, and battery boundaries.
- All six resource XML files pass the installed SDK's `resources.xsd`. PowerShell scripts pass syntax checks.
- Launcher icons use each device's specified dimensions: 40 x 40, 60 x 60, and 65 x 65 respectively.

## Visual and display checks

Active layouts were inspected on all three target simulators. Time, date, battery, stats, and the actual club logo fit the round screens. Dark text and black logo artwork remain readable on the lime background. Tiny lettering inside the logo is naturally less detailed on the 260-pixel MIP screen.

The Forerunner 265 completed Garmin's accelerated 24-hour burn-in simulation with screen protection enabled and **Burn-in State: NO**. Observed always-on luminance usage was approximately 0.15-0.2%, below Garmin's 10% limit. The Forerunner 965 received a brief always-on and wake check; its diagnostic reported **Burn-in State: NO** and **0.31%** usage. A second full 24-hour simulation was intentionally omitted for this prototype.

Additional smoke checks on downloaded MIP and AMOLED profiles confirmed readable rendering of 99,999 steps with missing heart rate, 12/24-hour mode changes, and the moving sleep clock. These do not add those models to the supported manifest.

These are genuine simulator window captures with simulated watch data:

- [255 active](previews/fr255-active.png)
- [265 active](previews/fr265-active.png), [always-on](previews/fr265-always-on.png), [completed burn-in diagnostic](previews/fr265-diagnostics.png)
- [965 active](previews/fr965-active.png), [always-on](previews/fr965-always-on.png), [diagnostic](previews/fr965-diagnostics.png), [wake](previews/fr965-wake.png)

## Delivery and remaining checks

`bin/runclub-prototype.zip` contains the three model-specific release `.prg` files and USB installation instructions. Individual release binaries are also in `bin/`. No private keys or SDK files are included in the package.

Before club-wide distribution, install the matching build on a physical watch and check outdoor legibility, recorded heart-rate availability, date rollover, system always-on settings, and battery use over normal wear. Non-English date rendering has not been exhaustively checked. Club branding, further device support, and Connect IQ Store publication are later steps.
