# Command-line interface

`MedicatInstaller.exe` is GUI-first: without flags it opens the window. The flags below make the same jobs scriptable for support scripts, diagnostics and unattended installs. The Linux script offers the same flags in `--flag` form ([`linux/README.md`](../linux/README.md)).

## Conventions

- **Windows style:** `/flag`, `/flag:value`, `/flag value`. **Unix style:** `--flag`, `--flag=value`, `--flag value`. Flag names are case-insensitive; drive letters are normalized (`e`, `E:` and `E:\` all mean `E:`).
- Unknown flags, missing values and conflicting flags exit **2** with a one-line message and a pointer to `/help`.
- **Elevation:** the exe carries a `requireAdministrator` manifest, so every launch, `/help` included, goes through UAC. Run scripts from an elevated prompt.
- **Console:** the installer is a GUI-subsystem program and opens its own console window for output (`AllocConsole`). The calling shell does not capture that text, so automation should rely on exit codes and the log files in `logs\`. `Ctrl+C` in that console cancels a headless run (exit **4**), stops the worker threads and terminates the tracked `7za.exe` children.
- **Language:** help and version output are English; dialogs and log lines follow `/lang:` or the Windows UI language.

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | Success: install finished and verify passed, verify-only passed, or every requested extra is on the drive |
| `1` | Operation failed: Ventoy, extract, download, bundled tools missing, an extra failed to download |
| `2` | Invalid or conflicting arguments, or the drive is not eligible |
| `3` | `/install` started without Administrator rights (only reachable when the UAC manifest is bypassed) |
| `4` | Cancelled: `Ctrl+C`, or a confirmation declined |
| `5` | Verify found failures and no re-extract ran |
| `6` | Re-extract ran but files still fail (the log carries the antivirus/firewall hint) |
| `7` | Verify aborted: the drive does not look like a MediCat stick |

Details always go to `logs\medicat_installer.log` beside the exe (or the `/log:` path).

## Flags

### Help and version

| Flag | Alias | Action |
|------|-------|--------|
| `/help` | `/h`, `/?`, `--help` | Print usage; exit `0` |
| `/version` | `/v`, `--version` | Print version, architecture, embedded release tag and MediCat version; exit `0` |

```text
MedicatInstaller 1.0.49 x64
MediCat USB: v21.12
```

The version comes from `build_number.txt` at build time (`rebuild.bat` bumps it, CI pins `1.0.1`).

### Language

| Flag | Alias | Values | Default |
|------|-------|--------|---------|
| `/lang:` | `--lang=` | `en`, `es`, `fr`, `pl`, `tr` (and `cat`, a generated test language) | Windows UI language, `en` when unsupported |

`/lang:` alone opens the GUI in that language. An unknown code exits **2**.

### Target drive

| Flag | Alias | Values | Required for |
|------|-------|--------|--------------|
| `/drive:` | `--drive=` | `E`, `E:`, `E:\` | `/install`, `/verify`, `/extras` |

Rules, same as the GUI: not `C:`, at least 30 GiB, and listed as a removable or VHD drive unless `/allow-fixed` is given. Anything else exits **2** with `Drive not eligible`.

### Actions

| Flag | Alias | Description |
|------|-------|-------------|
| `/install` | `--install` | Full pipeline: optional Ventoy, optional format, extract, verify |
| `/verify` | `--verify` | MD5 verify only (**Check USB Files**); no Ventoy, format or extract |
| `/extras:LIST` | `--extras=` | Download catalog boot images ([`spec/extras.json`](../spec/README.md)) into `E:\Extras\<category>\`. `LIST` is `all`, `none` or comma-separated ids. Alone it needs `/drive:`; with `/install` or `/verify` it runs afterwards when that step exits `0` or `5` |
| `/list-extras` | `--list-extras` | Print the extras catalog and exit |

`/install` and `/verify` together exit **2**. Without an action the GUI opens. Images already on the drive are kept, and every download is recorded in `E:\Extras\extras_manifest.txt`.

### Re-extract on verify failure

| Flag | Behaviour |
|------|-----------|
| `/reextract` | After a failed verify, re-extract the failed files with `7za @list`, then re-verify |
| `/noreextract` | Stop after the first verify; exit **5** |
| `/reextract-only` | Accepted; currently behaves like `/reextract` |
| *(none)* | Re-extract runs when `/yes` is given, otherwise the run ends with exit **5** |

### Install options

Defaults depend on whether Ventoy is already on the drive (`TestVentoyInstalled`, the same check as the GUI).

| Flag | GUI equivalent | No Ventoy on drive | Ventoy present |
|------|----------------|--------------------|----------------|
| `/format` / `/noformat` | Format checkbox | forced on; `/noformat` exits **2** | off unless `/format` |
| `/ventoy` / `/noventoy` | Install / Update Ventoy | forced on (`VTOYCLI /I`); `/noventoy` exits **2** | off unless `/ventoy` (`VTOYCLI /U`, or `/I` together with `/format`) |
| `/gpt` / `/nogpt` | Advanced: GPT | MBR | MBR |
| `/secureboot` / `/nosb` | Advanced: Secure Boot | on | on |
| `/ventoy-version:1.1.12` | Pin Ventoy version | latest | latest |

A pinned version that cannot be downloaded fails the run with exit **1**.

### Paths and offline use

| Flag | Alias | Description |
|------|-------|-------------|
| `/archive:` | `--archive=` | Path to `MediCat.USB.v21.12.7z` instead of the lookup beside the exe and in `offline\` |
| `/offline` | `--offline` | Use only the `offline\` cache for Ventoy and the archive ([OFFLINE.md](OFFLINE.md)); exit **1** when it is missing |
| `/log:` | `--log=` | Session log path (default `logs\medicat_installer.log`) |

### Unattended runs

| Flag | Alias | Description |
|------|-------|-------------|
| `/yes` | `/y`, `--yes` | Accept the wipe confirmation and the Ventoy warning (**destructive**) and run the re-extract without asking |
| `/quiet` | `/q`, `--quiet` | No message boxes; only errors are mirrored to the console. `/install` with `/quiet` needs `/yes` (exit **2** otherwise) |
| `/telemetry` / `/no-telemetry` | `--telemetry`, `--no-telemetry` | Send or skip the anonymous session report for this run. Without either flag a headless run follows the answer saved by the GUI, and sends nothing when none is saved |
| `/upload-logs` | `--upload-logs` | Allow the failure-log upload after a failed headless run (logs contain paths and drive details) |

Builds without an ingest token, such as every CI build of this repository, never send anything ([SUPPORT_UPLOAD.md](SUPPORT_UPLOAD.md)).

### Diagnostics

| Flag | Description |
|------|-------------|
| `/list-drives` | Eligible drives, one per line: letter, label, type, free and total size. Add `/allow-fixed` to include fixed disks |
| `/dump-config` | Resolved paths: installer directory, `7za`, `aria2c`, MD5 manifest, archive, temp dir |

## Mode matrix

```text
(no args)                     → GUI
/lang:fr                      → GUI in French
/help, /version               → console, exit 0
/list-drives, /dump-config,
/list-extras                  → console, exit 0
/verify /drive:E              → headless verify (+ /quiet, /yes, /extras:)
/install /drive:E /yes …      → headless install
/extras:LIST /drive:E         → headless extras only
```

## Headless flow

1. `ParseCommandLine` builds `CliOptions`; errors exit **2** before anything runs.
2. `App::RunParsed` mirrors the session log to the console (errors only with `/quiet`), logs the command line and the system diagnostics, and installs the `Ctrl+C` handler.
3. `RunHeadless` validates the drive, then runs the same worker code as the GUI (`RunPreInstallThread`, `RunVerifyThread`) with confirmations answered by `/yes`; `MapHeadlessExitCode` turns the outcome into the exit code.
4. `/extras` runs last through `RunExtrasForDrive`, shared with the stand-alone `/extras` action.

Extraction and download progress appear as console lines (`42% — <file>`) unless `/quiet` is set.

## Examples

```bat
MedicatInstaller.exe /install /drive:E /yes /quiet /lang:en
MedicatInstaller.exe /verify /drive:E /yes /reextract
MedicatInstaller.exe /extras:systemrescue,gparted-live /drive:E /quiet
MedicatInstaller.exe /install /drive:E /yes /extras:all /nosb /gpt
```

## Not implemented

Tracked in [TODO.md](TODO.md): a full headless install in CI.

## Related files

| Path | Role |
|------|------|
| `src/cli.cpp` | Parsing, console output, help and version text |
| `src/app.cpp` | `RunHeadless*`, exit code mapping, confirmations |
| `src/extras.cpp` | Extras download, checksum and unpack |
| `src/gui.cpp` | Checkbox defaults and the forced Ventoy rule shared with the CLI |
| `generated/build_version.cpp` | `kInstallerVersion`, `kInstallerBuildNumber` |
| `tests/windows/test_main.cpp` | Parser tests (`MedicatTests.exe`) |
| `tests/windows/smoke_cli.ps1` | Runtime smoke test on a VHD (CI) |
