# Third-party notices

Copyright (C) 2021-2026 the MediCat Installer contributors (see the credits in `README.md`). The installer source is licensed under the GNU AGPL-3.0 (`LICENCE`); the Linux script under `linux/` is GPL-3.0 (`linux/LICENSE`). Both are free software and come without any warranty.

The builds and the installers also ship or fetch these third-party components:

| Component | Version | License | How it is used |
|-----------|---------|---------|----------------|
| [7-Zip](https://www.7-zip.org/) `7za.exe` (x64, x86) | 26.03 | LGPL-2.1 or later, `Rar*` files with the unRAR restriction, some files BSD ([`THIRD_PARTY_LICENSES/7-Zip-License.txt`](THIRD_PARTY_LICENSES/7-Zip-License.txt), [`LGPL-2.1.txt`](THIRD_PARTY_LICENSES/LGPL-2.1.txt)) | Committed in `bin/7z/`, embedded in `MedicatInstaller.exe` and run as a separate process to extract MediCat and Ventoy. Unmodified official build; source: <https://www.7-zip.org/a/7z2603-src.7z> |
| [aria2](https://aria2.github.io/) `aria2c.exe` | 1.37.0 | GPL-2.0 or later, with aria2's exception for linking OpenSSL ([`THIRD_PARTY_LICENSES/GPL-2.0.txt`](THIRD_PARTY_LICENSES/GPL-2.0.txt)) | Downloaded at build time by `tools/prepare_aria2_bundle.py` (pinned URL and SHA-256), embedded and run as a separate process for downloads and BitTorrent. Unmodified official build; source: <https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz> |
| [Ventoy](https://www.ventoy.net/) | latest release at install time | GPL-3.0 | Downloaded by both installers at run time on the user's machine and written to the USB stick; not redistributed. The Linux script verifies it against the release `sha256.txt` |
| [MediCat USB](https://medicatusb.com/) archive | v21.12 | Assembled by the MediCat project; the bundled tools keep their own licenses | Downloaded from the mirrors in `spec/medicat.json` on the user's machine, verified by MD5/SHA-256 and extracted to the stick; not redistributed. `spec/MediCat_USB_v21.12.torrent` is the project's official torrent metadata, kept as upstream did |
| Extras catalog (`spec/extras.json`) | per entry | Listed per entry (`license`) | Optional boot images the user chooses; downloaded from the upstream projects and verified with their published checksums; not redistributed |
| [Pillow](https://python-pillow.org/) | pinned in the workflows | MIT-CMU | Build-time icon preparation only; nothing of it ships |

A built exe redistributes 7-Zip and aria2, so `LICENCE`, `linux/LICENSE`, this file and `THIRD_PARTY_LICENSES/` travel with it: they sit in the repository next to the CI artifacts, and the installer's **Credits & licenses** window states the license and links to the project page, and `tools/prepare_aria2_bundle.py` and the CMake build are the only places that fetch binaries into the build; nothing else is vendored.

The MediCat name and logo belong to the MediCat USB project; this repository is an independent fork of the community installer and is not affiliated with Microsoft or the vendors of the tools inside MediCat.
