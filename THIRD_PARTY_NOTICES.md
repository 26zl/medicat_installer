# Third-party notices

The installer source is AGPL-3.0 (`LICENCE`); the Linux script under `linux/` is GPL-3.0 (`linux/LICENSE`). The builds and the installers also ship or fetch these third-party components:

| Component | Version | License | How it is used |
|-----------|---------|---------|----------------|
| [7-Zip](https://www.7-zip.org/) `7za.exe` (x64, x86) | 26.01 | LGPL-2.1 with the unRAR restriction | Committed in `bin/7z/`, embedded in `MedicatInstaller.exe` and run as a separate process to extract MediCat and Ventoy |
| [aria2](https://aria2.github.io/) `aria2c.exe` | 1.37.0 | GPL-2.0-or-later | Downloaded at build time by `tools/prepare_aria2_bundle.py` (pinned URL and SHA-256), embedded and run as a separate process for downloads and BitTorrent |
| [Ventoy](https://www.ventoy.net/) | latest release at install time | GPL-3.0 | Downloaded by both installers at run time and written to the USB stick; the Linux script verifies it against the release `sha256.txt` |
| [MediCat USB](https://medicatusb.com/) archive | v21.12 | Assembled by the MediCat project; the bundled tools keep their own licenses | Downloaded from the mirrors in `spec/medicat.json`, verified by MD5/SHA-256 and extracted to the stick |
| Extras catalog (`spec/extras.json`) | per entry | Listed per entry (`license`) | Optional boot images the user chooses; downloaded from the upstream projects and verified with their published checksums |
| [Pillow](https://python-pillow.org/) | pinned in the workflows | MIT-CMU | Build-time icon preparation only |

`tools/prepare_aria2_bundle.py` and the CMake build are the only places that fetch binaries into the build; nothing else is vendored.
