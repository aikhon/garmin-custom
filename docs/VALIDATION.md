# Redesign validation

Validated on 6 October 2026 against Garmin Connect IQ SDK 9.2.0. The redesign follows the supplied Run Club Atyrau brief and incorporates the user's club logo and lime skyline. Original media is preserved.

## Results

| Target | Debug/release builds | Formatting tests | Observed simulator memory |
| --- | --- | --- | --- |
| Forerunner 255 | Pass, no warnings | 3 passed, 0 failed | About 15.5 KB of 123.9 KB available |
| Forerunner 265 | Pass, no warnings | 3 passed, 0 failed | About 15.5 KB of 123.9 KB available |
| Forerunner 965 | Pass, no warnings | 3 passed, 0 failed | About 15.5 KB of 123.9 KB available |

Formatting tests cover midnight/noon and 12/24-hour display, compact steps, missing readings, battery limits, and centimeter-to-kilometer conversion including the 10 km formatting boundary. Final typography and display-profile refinements do not change these data functions. The 255 tests were also rerun after replacing mutable display properties with build-time profiles.

Simulator memory figures are observed readings, not exhaustive peak-memory or physical battery measurements. Custom time fonts contain only the characters required for time; UI fonts contain the required English labels and numeric symbols.

The 7 October layout update (90% skyline and a shared battery/date row) was compiled for all three targets and checked in their active simulator previews. Formatting logic and AMOLED sleep layout are unchanged by this update.

## Visual checks

- Metrics were moved down by 3% of the screen height to increase the gap below the time. The refreshed active previews show the gauges, values, and labels clear of both the clock and skyline; all three debug and release builds pass.
- All three updated active layouts were inspected. The logo sits at the top above a single row containing the battery and date. Time, gauges, and their labels remain readable. EST 2019 is removed from active and sleep views.
- Hours and colon are filled lime. Minutes use dedicated hollow white bitmap glyphs. Barlow Condensed is used throughout.
- The skyline now spans 90% of the screen width, preserving its 3:1 aspect ratio. Its ground line is aligned to the bottom edge, with intentional cropping at the circular boundary. It uses the provided landmarks and has no tourism wordmark.
- The 255 was checked with simulated 12,400 steps and a nonzero daily distance. Its compact step value remains readable inside the gauge; the formatter's 4.8 km case is covered by the centimeter-conversion test.
- AMOLED sleep shows a small logo above the clock and date. Earlier diagnostics reported no burn-in state and roughly 0.6% pixel use, below the 10% limit; an accelerated 265 exercise completed. The updated group retains four separate bands with three minute intervals of rest for each band. Sleep previews were refreshed after reordering the group; the full burn-in exercise was not repeated for this layout change.
- MIP sleep was inspected after the profile fix and retains large filled/outlined time, date, and a small logo. Its profile is now fixed in the binary instead of a persisted setting that could carry across simulator models.

Genuine simulator captures (values are simulated watch data):

- [255 active](previews/fr255-active.png), [nonzero metrics](previews/fr255-metrics.png), [sleep](previews/fr255-sleep.png)
- [265 active](previews/fr265-active.png), [sleep](previews/fr265-always-on.png), [diagnostic](previews/fr265-diagnostics.png)
- [965 active](previews/fr965-active.png), [sleep](previews/fr965-always-on.png), [diagnostic](previews/fr965-diagnostics.png), [wake](previews/fr965-wake.png)

## Reproduction and remaining work

Builds and the installation ZIP are in bin/. Font atlases, icons, and contour textures can be regenerated with scripts/Generate-DesignResources.ps1; original font files and their OFL license are in media/fonts. Resource XML and PowerShell syntax are checked by the supplied validation script and parser checks.

Before club-wide distribution, test on physical watches for outdoor legibility, recorded heart-rate availability, date rollover, and battery consumption. Distance currently uses KM, date labels use English, and additional device models require their own resources and builds. Store publication is pending. Font licensing is included with the test package.
