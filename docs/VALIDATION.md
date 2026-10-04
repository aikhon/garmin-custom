# Prototype validation

## Completed in this workspace

- Connect IQ SDK 9.2.0 downloaded from Garmin; compiler version/help commands run successfully under Java 1.8.0_401.
- Official Garmin Monkey C VS Code extension 1.1.3 installed.
- Local RSA signing key generated in ignored `.secrets`; original launcher icon generated.
- Source reviewed against the installed SDK's API declarations and watch-face guidance.
- All four resource XML files pass the SDK's `resources.xsd`; the manifest is well-formed XML.
- All five PowerShell scripts pass PowerShell parser checks; VS Code JSON configuration parses successfully.

## Pending

The user chose to continue without simulator testing. Garmin device profiles are not installed. A build attempt for `fr265` stops with `Invalid device id specified: 'fr265'` before source compilation. A generic build also cannot resolve the device qualifiers. **Source compilation, unit-test execution, memory use, rendered screenshots, and always-on pixel coverage have not been verified.**

After signing in to SDK Manager and downloading all three profiles and fonts:

| Check | Acceptance |
| --- | --- |
| Compile debug and release for all three targets | Successful compiler exit, no unresolved symbols or type errors |
| Execute test builds | Both formatting tests pass in the simulator |
| Default face, all screen sizes | Time, date, stats, track, and club name fit the round screen without overlap |
| 00:00, 12:00, 23:59; 12- and 24-hour modes | Correct time, minute zero padding, AM/PM; no clipping |
| 0, 1,000, 99,999, 100,000 steps; HR absent/zero | Readable formatting, real zero steps, `--` for missing HR |
| Battery 0%, 100%; unavailable tracking | No crash; battery remains visible; unavailable steps show `--` |
| Date rollover and available system languages | Day/date advances correctly; abbreviations fit |
| AMOLED enter/exit sleep, both targets | Artwork disappears in sleep, time remains, full face returns on wake |
| AMOLED four-minute cycle and heat-map test | Fewer than 10% of display pixels lit; disjoint clock bands; no burn-in violation |
| MIP low-power mode | Full layout remains readable; no partial-update budget errors |
| Runtime profiling | Memory stays within each device's watch-face limits |
| Screenshots | Save genuine simulator captures for each target's active face and AMOLED sleep face |

On a physical watch, check outdoor legibility, wrist-off HR behavior, system always-on settings, and battery usage over normal use. Simulator results cannot establish physical battery life.
