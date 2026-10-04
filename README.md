# Medicat Installer
![Logo](res/icon.png)

Fork of [mon5termatt/medicat_installer](https://github.com/mon5termatt/medicat_installer) with a shared spec for both installers, a Linux installer with the same command-line interface as Windows, an extras catalog of boot images and telemetry consent.

Copyright (C) 2021-2026 the MediCat Installer [contributors](#credits). The installer is free software under the GNU AGPL-3.0 ([`LICENCE`](LICENCE)) and the Linux script under the GNU GPL-3.0 ([`linux/LICENSE`](linux/LICENSE)), both without any warranty. This fork has been modified from the upstream project since August 2026; every change is in the git history. Third-party components and their license texts: [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) and [`THIRD_PARTY_LICENSES/`](THIRD_PARTY_LICENSES/README.md).

# [Visit the Medicat website](https://medicatusb.com/)

The Windows installer is now a native C++ app (`MedicatInstaller.exe`). Same job as before: Ventoy, optional format, extract MediCat, verify files. Linux has the shell script in [`linux/`](linux/). Both read the same [shared spec](spec/README.md) (archive, mirrors, hashes) and the same catalog of optional extra boot images.

### We appreciate some code improvements to the installer!
If you want to help improve Medicat installer, you can:
* Join the Discord: (https://url.medicatusb.com/discord),

OR:

* Fork this project, and create a pull request with modified files. PRs welcome on **`main`**.

# Compatibility
* Windows 10/11 (Insider builds might break the installer)
* Linux via `Medicat_Installer.sh` (Ubuntu / Arch / Debian / Fedora / Void / friends)

#### Requirements for Windows
* Windows 10/11 (1703+ is fine)
* Administrator (UAC)
* Half a brain
* A USB (or VHD) with about **30 GiB+** free, ideally 64GB+
* `MediCat.USB.v21.12.7z` beside the exe, or grab it from the built-in mirrors / Drive parts

#### Requirements for Linux
* Terminal
* Like 75% of a brain
* General Linux knowledge
* Script lives in [`linux/`](linux/); the one-liner above fetches it from `main`

# Grab it

Linux, one line: downloads the self-contained script from this repository into the current directory and starts it interactively. Drop `MediCat.USB.v21.12.7z` in the same directory first if you already have it.

```bash
curl -fsSLO https://raw.githubusercontent.com/26zl/medicat_installer/main/linux/Medicat_Installer.sh && chmod +x Medicat_Installer.sh && ./Medicat_Installer.sh
```

Add flags for headless use (`--help` lists them, see below). Windows: `MedicatInstaller.exe` is the artifact of the latest [CI run](https://github.com/26zl/medicat_installer/actions/workflows/ci.yml) on `main` (needs a GitHub login), or build it yourself (see [Build from source](#build-from-source)).

# What it does (short version)

* Installs or updates **Ventoy**
* Optional **NTFS** format when you need a clean stick
* Extracts **MediCat** with progress
* **MD5 verify** + selective re-extract if something failed
* GUI (dark theme) and a proper **CLI** (`/help`, `/install`, `/verify`, ...)
* **Extras**: optional boot images from a curated, checksummed catalog: rescue and boot repair (SystemRescue, Super Grub2 Disk), partitioning and imaging (GParted Live, Clonezilla, Rescuezilla), diagnostics, firmware and wiping (Memtest86+, FreeDOS, ShredOS), Windows rescue (Hiren's BootCD PE), live Linux (Linux Mint, Debian), forensics (CAINE, Tsurugi Acquire, Tsurugi Linux, Parrot Security) and pointers for downloads that are rolling or need a login (ESET SysRescue Live, Windows 10/11 ISOs, SUMURI PALADIN); the Linux installer downloads them into `Extras/` on the stick. `all` is about 40 GB on top of MediCat's 28 GB, so it needs a 128 GB stick; pick ids on a 64 GB one

More detail: [`docs/FEATURES.md`](docs/FEATURES.md) · [`docs/CLI.md`](docs/CLI.md) · [`spec/README.md`](spec/README.md) · [`linux/README.md`](linux/README.md)

# Quick start

1. Download the exe from Releases.
2. Drop `MediCat.USB.v21.12.7z` next to it (or use the in-app download).
3. Run as Administrator.
4. Pick your USB. Install. Drink water.

```bat
MedicatInstaller.exe /help
MedicatInstaller.exe /install /drive:E /yes
MedicatInstaller.exe /verify /drive:E /yes
MedicatInstaller.exe /extras:systemrescue,gparted-live /drive:E
MedicatInstaller.exe /list-extras
```

Logs land in `logs\` beside the exe: `medicat_installer.log` plus the 7-Zip, Ventoy and download logs, with earlier sessions kept under `logs\archive\`. If something blows up and you upload logs, the dialog gives you a **Diag code** for Discord.

On Linux the same jobs are flags of the shell script (no flags = interactive):

```bash
./linux/Medicat_Installer.sh --install --drive /dev/sdb --yes
./linux/Medicat_Installer.sh --verify --drive /dev/sdb
./linux/Medicat_Installer.sh --extras systemrescue,gparted-live --drive /dev/sdb
./linux/Medicat_Installer.sh --list-extras
```

# Telemetry (Windows installer)

Nothing leaves the machine without a yes. On first start `MedicatInstaller.exe` asks whether it may send an anonymous session report at the end of each install or verify (outcome, installer version, Windows build and edition, CPU/RAM class, UI language, a hash of the machine GUID). After a failure it asks whether to upload the `.log`/`.txt` files from `logs\` beside the exe, which contain file paths and drive details; the logs no longer include the computer or user name. Headless runs follow the saved answer, `/telemetry` and `/no-telemetry` override it for one run, and the log upload needs `/upload-logs`. The saved answer lives in `%AppData%\MedicatInstaller\preferences.json`:

```json
{ "session_reports_enabled": false, "failure_log_auto_upload_enabled": false }
```

Builds without an ingest token (every CI build of this fork) send nothing at all. The Linux script sends nothing. Details: [`docs/SUPPORT_UPLOAD.md`](docs/SUPPORT_UPLOAD.md).

# Branches

`main` is the only branch: C++ Windows installer, Linux script in `linux/`, shared `spec/`. Work happens on short-lived topic branches that are merged into `main` and deleted. The batch-era scripts and their helper binaries were removed from this fork; they live on in the upstream repository's `legacy` branch.

# Syncing with upstream

Upstream is a fetch-only source; nothing here can push to it or open pull requests there.

- `tools/sync_upstream.sh --dry-run` shows what upstream `main` has that we do not; without `--dry-run` it merges, regenerates `spec`/`i18n` outputs, runs the quick checks and tells you to push. `--linux` also merges upstream's `linux` branch into `linux/`, `--push` pushes `main` when everything passed.
- [`upstream-sync.yml`](.github/workflows/upstream-sync.yml) does the same every Monday (or on demand): a clean merge becomes a pull request against **this** repository on a `sync/upstream-<date>` branch; conflicts become an issue, which needs Issues enabled in the repository settings. GitHub can delay or skip a scheduled run, and a fork sometimes needs the workflow enabled once in the Actions tab; when a Monday run is missing, start it by hand with `gh workflow run upstream-sync.yml`.
- Guardrails: `tools/sync_upstream.sh` sets the `upstream` push URL to `no_push` on first use. A fresh clone should set the rest up once:

  ```bash
  git remote set-url --push upstream no_push
  git config remote.upstream.tagOpt --no-tags   # never fetch upstream's tags into this clone
  gh repo set-default 26zl/medicat_installer
  ```

  Leaving the fork network on GitHub (Settings, General, Danger Zone, "Leave fork network") also removes GitHub's own "Compare & pull request" suggestions toward upstream; syncing keeps working through the scripts above.

# Build from source

Visual Studio 2022 or newer with the C++ build tools (the Build Tools edition is enough), CMake, and Python 3 on `PATH`, plus the committed `bin/7z/.../7za.exe` and `MedicatFiles.md5`. `rebuild.bat` finds the CMake bundled with Visual Studio when `cmake` is not on `PATH`. Pillow (`pip install pillow`) is only needed to regenerate `res/discord.ico` after changing `res/discord.png`; without it the committed icon is kept. The build fetches official `aria2c` (GPL-2.0) and embeds it for multi-connection downloads, and fetches the Ventoy release list from GitHub (falling back to `res/ventoy_versions.txt` offline).

```bat
rebuild.bat
```

Outputs land in `build/Release/`. The version goes to `build_number.txt` (gitignored) and into the exe's version resource and `/version`; `rebuild.bat` bumps the local counter, `rebuild.bat as 1.0.N` pins it and CI pins `1.0.1`. Every push runs [`ci.yml`](.github/workflows/ci.yml): spec check, shellcheck and smoke tests for the Linux script, and a Windows build. Ask in Discord if you get stuck.

Mirrors, hashes and the extras catalog live in [`spec/`](spec/README.md); `python3 tools/gen_spec.py` regenerates `src/spec_generated.h` and the spec block in the Linux script (the CMake build does this automatically).

# Credits

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/SkeletonMan03"><img src="https://avatars.githubusercontent.com/u/96273359?v=4?s=100" width="100px;" alt="Lord SkeletonMan"/><br /><sub><b>Lord SkeletonMan</b></sub></a><br /><a href="#code-SkeletonMan03" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://edm115.dev"><img src="https://avatars.githubusercontent.com/u/82015596?v=4?s=100" width="100px;" alt="EDM115"/><br /><sub><b>EDM115</b></sub></a><br /><a href="#code-EDM115" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Ludo-code"><img src="https://avatars.githubusercontent.com/u/56892223?v=4?s=100" width="100px;" alt="Ludovic"/><br /><sub><b>Ludovic</b></sub></a><br /><a href="#code-Ludo-code" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Manganar"><img src="https://avatars.githubusercontent.com/u/22703860?v=4?s=100" width="100px;" alt="David Thomson"/><br /><sub><b>David Thomson</b></sub></a><br /><a href="#code-Manganar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://dablog.pages.dev"><img src="https://avatars.githubusercontent.com/u/42101257?v=4?s=100" width="100px;" alt="Ronald Cantillo"/><br /><sub><b>Ronald Cantillo</b></sub></a><br /><a href="#code-Rooyca" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Samega7Cattac"><img src="https://avatars.githubusercontent.com/u/25128554?v=4?s=100" width="100px;" alt="Samega7Cattac"/><br /><sub><b>Samega7Cattac</b></sub></a><br /><a href="#code-Samega7Cattac" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Sipper1236"><img src="https://avatars.githubusercontent.com/u/82241081?v=4?s=100" width="100px;" alt="Sipping "/><br /><sub><b>Sipping </b></sub></a><br /><a href="#code-Sipper1236" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/SuperRedPanda1"><img src="https://avatars.githubusercontent.com/u/120546867?v=4?s=100" width="100px;" alt="SuperRedPanda1"/><br /><sub><b>SuperRedPanda1</b></sub></a><br /><a href="#code-SuperRedPanda1" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Teknoist"><img src="https://avatars.githubusercontent.com/u/37031361?v=4?s=100" width="100px;" alt="Mahmut Sözen"/><br /><sub><b>Mahmut Sözen</b></sub></a><br /><a href="#code-Teknoist" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Wyzzro"><img src="https://avatars.githubusercontent.com/u/57268445?v=4?s=100" width="100px;" alt="Le Touzic Ethan"/><br /><sub><b>Le Touzic Ethan</b></sub></a><br /><a href="#code-Wyzzro" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://benhampson.co.uk"><img src="https://avatars.githubusercontent.com/u/77866043?v=4?s=100" width="100px;" alt="Ben Hampson"/><br /><sub><b>Ben Hampson</b></sub></a><br /><a href="#code-ben-hampson" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://fedoraproject.org/wiki/User:Eclipseo"><img src="https://avatars.githubusercontent.com/u/30413512?v=4?s=100" width="100px;" alt="Robert-André Mauchin"/><br /><sub><b>Robert-André Mauchin</b></sub></a><br /><a href="#code-eclipseo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/id3v1669"><img src="https://avatars.githubusercontent.com/u/57532211?v=4?s=100" width="100px;" alt="id3v1669"/><br /><sub><b>id3v1669</b></sub></a><br /><a href="#code-id3v1669" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://link.itrio.pet"><img src="https://avatars.githubusercontent.com/u/15737258?v=4?s=100" width="100px;" alt="Itrio"/><br /><sub><b>Itrio</b></sub></a><br /><a href="#code-itsitrio" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/keelnar"><img src="https://avatars.githubusercontent.com/u/198622?v=4?s=100" width="100px;" alt="Neelnavo Kar"/><br /><sub><b>Neelnavo Kar</b></sub></a><br /><a href="#code-keelnar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/randompersononinternet69"><img src="https://avatars.githubusercontent.com/u/107446530?v=4?s=100" width="100px;" alt="a random person on the internet"/><br /><sub><b>a random person on the internet</b></sub></a><br /><a href="#code-randompersononinternet69" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/shenqingyi9"><img src="https://avatars.githubusercontent.com/u/37582641?v=4?s=100" width="100px;" alt="La vaguelette"/><br /><sub><b>La vaguelette</b></sub></a><br /><a href="#code-shenqingyi9" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tolgabalper"><img src="https://avatars.githubusercontent.com/u/60055681?v=4?s=100" width="100px;" alt="Tolga Boran Alper"/><br /><sub><b>Tolga Boran Alper</b></sub></a><br /><a href="#code-tolgabalper" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/FabienRCT"><img src="https://avatars.githubusercontent.com/u/56532663?v=4?s=100" width="100px;" alt="FabienRCT"/><br /><sub><b>FabienRCT</b></sub></a><br /><a href="#code-FabienRCT" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

* Along with all the others helping in the Discord server!

  ## Star History

<a href="https://star-history.com/#mon5termatt/medicat_installer&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=mon5termatt/medicat_installer&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=mon5termatt/medicat_installer&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=mon5termatt/medicat_installer&type=Date" />
 </picture>
</a>
