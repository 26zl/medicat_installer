# Medicat Installer

![Logo](res/icon.png)

[![CI](https://github.com/26zl/medicat_installer/actions/workflows/ci.yml/badge.svg)](https://github.com/26zl/medicat_installer/actions/workflows/ci.yml)

Installer for [MediCat USB](https://medicatusb.com/): puts Ventoy on a USB stick, extracts the MediCat archive onto it, verifies every file against the MD5 manifest and optionally adds extra boot images from a checksummed catalog. Windows gets a native C++ app with a GUI and a CLI, Linux a self-contained bash script with the same flags; both are generated from one [shared spec](spec/README.md) of mirrors, hashes and the extras catalog.

Fork of [mon5termatt/medicat_installer](https://github.com/mon5termatt/medicat_installer), modified since September 2026 with every change in the git history. `main` is the only branch; upstream's commits arrive through pull requests that a weekly workflow opens here. Questions and help: the [MediCat Discord](https://url.medicatusb.com/discord) or an [issue](https://github.com/26zl/medicat_installer/issues).

Copyright (C) 2021-2026 the MediCat Installer contributors. Free software without any warranty: the installer under the GNU AGPL-3.0 ([`LICENCE`](LICENCE)), the Linux script under the GNU GPL-3.0 ([`linux/LICENSE`](linux/LICENSE)). Third-party components and their license texts: [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

## Grab it

Linux, one line: downloads the self-contained script from this repository into the current directory and starts it interactively. Drop `MediCat.USB.v21.12.7z` in the same directory first if you already have it.

```bash
curl -fsSLO https://raw.githubusercontent.com/26zl/medicat_installer/main/linux/Medicat_Installer.sh && chmod +x Medicat_Installer.sh && ./Medicat_Installer.sh
```

Add flags for headless use (`--help` lists them; examples under [Quick start](#quick-start)).

Windows: download [`MedicatInstaller.exe`](https://github.com/26zl/medicat_installer/releases/download/latest/MedicatInstaller.exe) ([32-bit](https://github.com/26zl/medicat_installer/releases/download/latest/MedicatInstaller-x86.exe)) and run it, or in PowerShell:

```powershell
iwr -OutFile MedicatInstaller.exe https://github.com/26zl/medicat_installer/releases/download/latest/MedicatInstaller.exe; .\MedicatInstaller.exe
```

CI rebuilds both exes from every push to `main` and keeps them on the [`latest` release](https://github.com/26zl/medicat_installer/releases/tag/latest), next to the source archives of the embedded 7-Zip and aria2; `/version` prints `1.0.<build>`. The exe is not code-signed, so SmartScreen may ask once. Or build it yourself (see [Build from source](#build-from-source)).

## Requirements

- **Windows:** Windows 10 or 11 (1703 or newer; Insider builds may break the installer), administrator rights (the exe asks through UAC), a USB stick or VHD of at least 32 GB (64 GB recommended), and `MediCat.USB.v21.12.7z` beside the exe or fetched by the installer from the built-in mirrors or BitTorrent.
- **Linux:** bash 4+, GNU coreutils and util-linux (`lsblk`, `findmnt`, `mountpoint`), `sudo` for the disk steps, and network access for packages, Ventoy and the archive. The script installs what it needs on Ubuntu, Debian, Fedora, the RHEL family, Arch, CachyOS, Void, Alpine and NixOS. It does not run on FreeBSD, macOS or WSL, which has no USB block devices. Details: [`linux/README.md`](linux/README.md).

## What it does

* Installs or updates **Ventoy**
* Optional **NTFS** format when you need a clean stick
* Extracts **MediCat** with progress
* **MD5 verify** + selective re-extract if something failed
* GUI (dark theme) and a proper **CLI** (`/help`, `/install`, `/verify`, ...)
* **Extras**: optional boot images from a curated, checksummed catalog: rescue and boot repair (SystemRescue, Super Grub2 Disk), partitioning and imaging (GParted Live, Clonezilla, Rescuezilla), diagnostics, firmware and wiping (Memtest86+, FreeDOS, ShredOS), Windows rescue (Hiren's BootCD PE), live Linux (Linux Mint, Debian), forensics (CAINE, Tsurugi Acquire, Tsurugi Linux, Parrot Security) and pointers for downloads that are rolling or need a login (ESET SysRescue Live, Windows 10/11 ISOs, SUMURI PALADIN); the Linux installer downloads them into `Extras/` on the stick. `all` is about 40 GB on top of MediCat's 28 GB, so it needs a 128 GB stick; pick ids on a 64 GB one

## Quick start

Windows:

1. Download `MedicatInstaller.exe` (see [Grab it](#grab-it)).
2. Drop `MediCat.USB.v21.12.7z` next to it, or use the in-app download.
3. Run it and accept the UAC prompt.
4. Pick your USB stick. Install. Drink water.

```bat
MedicatInstaller.exe /help
MedicatInstaller.exe /install /drive:E /yes
MedicatInstaller.exe /verify /drive:E /yes
MedicatInstaller.exe /extras:systemrescue,gparted-live /drive:E
MedicatInstaller.exe /list-extras
```

Logs land in `logs\` beside the exe: `medicat_installer.log` plus the 7-Zip, Ventoy and download logs, with earlier sessions kept under `logs\archive\`. If something blows up and you upload logs, the dialog gives you a **Diag code** for Discord.

Linux, the same jobs as flags of the script (no flags = interactive; it is `linux/Medicat_Installer.sh` in the repository):

```bash
./Medicat_Installer.sh --install --drive /dev/sdb --yes
./Medicat_Installer.sh --verify --drive /dev/sdb
./Medicat_Installer.sh --extras systemrescue,gparted-live --drive /dev/sdb
./Medicat_Installer.sh --list-extras
```

Exit codes on Linux: `0` ok, `1` error, `2` bad arguments, `4` cancelled, `5` verification found failures. The Windows codes are in [`docs/CLI.md`](docs/CLI.md).

## Telemetry (Windows installer)

Nothing leaves the machine without a yes. On first start `MedicatInstaller.exe` asks whether it may send an anonymous session report when it starts and at the end of each install or verify (outcome, installer version, Windows build and edition, CPU/RAM class, UI language, a hash of the machine GUID). After a failure it asks whether to upload the `.log`/`.txt` files from `logs\` beside the exe, which contain file paths and drive details; the logs no longer include the computer or user name. Headless runs follow the saved answer, `/telemetry` and `/no-telemetry` override it for one run, and the log upload needs `/upload-logs`. The saved answer lives in `%AppData%\MedicatInstaller\preferences.json`:

```json
{ "session_reports_enabled": false, "failure_log_auto_upload_enabled": false }
```

Builds without an ingest token (every CI build of this fork, including the published `latest` exe) send nothing at all. The Linux script sends nothing. Details: [`docs/SUPPORT_UPLOAD.md`](docs/SUPPORT_UPLOAD.md).

## Build from source

Visual Studio 2022 or newer with the C++ build tools (the Build Tools edition is enough), CMake, and Python 3 on `PATH`, plus the committed `bin/7z/.../7za.exe` and `MedicatFiles.md5`. `rebuild.bat` finds the CMake bundled with Visual Studio when `cmake` is not on `PATH`. Pillow (`pip install pillow`) is only needed to regenerate `res/discord.ico` after changing `res/discord.png`; without it the committed icon is kept. The build fetches official `aria2c` (GPL-2.0) and embeds it for multi-connection downloads, and fetches the Ventoy release list from GitHub (falling back to `res/ventoy_versions.txt` offline).

```bat
rebuild.bat
```

Outputs land in `build/Release/`. The version goes to `build_number.txt` (gitignored) and into the exe's version resource and `/version`; `rebuild.bat` bumps the local counter, `rebuild.bat as 1.0.N` pins it and CI uses `1.0.<run number>`. Every push runs [`ci.yml`](.github/workflows/ci.yml): spec check, shellcheck and smoke tests for the Linux script, and a Windows build; a push to `main` also refreshes the `latest` release. Ask in Discord if you get stuck.

Mirrors, hashes and the extras catalog live in [`spec/`](spec/README.md); `python3 tools/gen_spec.py` regenerates `src/spec_generated.h` and the spec block in the Linux script (the CMake build does this automatically).

Contributing: pull requests against `main` are welcome. Run `bash tests/linux/smoke_test.sh` for the Linux script (`sudo bash tests/linux/loop_install_test.sh` for a full install on a loop device) and `rebuild.bat` plus `tests\windows\smoke_cli.ps1` for Windows; CI runs the same checks on every push.

## Documentation

| Document | Contents |
|----------|----------|
| [`docs/FEATURES.md`](docs/FEATURES.md) | Feature checklist of the Windows installer |
| [`docs/CLI.md`](docs/CLI.md) | Every flag and exit code of the Windows CLI |
| [`linux/README.md`](linux/README.md) | The Linux script: flags, exit codes, distributions, tests |
| [`spec/README.md`](spec/README.md) | The shared spec and how to add an extras entry |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Code layout, threading model, build pipeline |
| [`docs/SUPPORT_UPLOAD.md`](docs/SUPPORT_UPLOAD.md) | What the telemetry and the log upload send, and when |
| [`SECURITY.md`](SECURITY.md) | Supported builds and how to report a vulnerability |

## Credits

The installer is the work of the upstream project's contributors, listed in the [upstream README](https://github.com/mon5termatt/medicat_installer#credits), and of everyone helping in the MediCat Discord. The Linux script was originally written by [SkeletonMan03](https://github.com/SkeletonMan03) and later changed by Manganar, id3v1669 and 26zl. The MediCat name and logo belong to the [MediCat USB](https://medicatusb.com/) project; this repository is an independent fork of the community installer.
