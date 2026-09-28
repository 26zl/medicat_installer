# Third-party license texts

The Windows installer embeds two third-party programs as resources and runs them as separate processes. The release binaries therefore redistribute them, so their license texts are reproduced here and the exact corresponding source is named. Neither program is modified.

| Component | Where it ships | License text | Corresponding source |
|-----------|----------------|--------------|----------------------|
| 7-Zip 26.01, `7za.exe` (x64 and x86 console versions) | `bin/7z/`, embedded in `MedicatInstaller.exe` and `MedicatInstaller-x86.exe` | [`7-Zip-License.txt`](7-Zip-License.txt): GNU LGPL 2.1 or later, the `Rar*` files with the unRAR restriction, some files BSD 2/3-clause; full LGPL text in [`LGPL-2.1.txt`](LGPL-2.1.txt) | <https://www.7-zip.org/a/7z2601-src.7z> (mirror: <https://sourceforge.net/projects/sevenzip/files/7-Zip/26.01/>) |
| aria2 1.37.0, `aria2c.exe` (official Windows builds) | fetched at build time by `tools/prepare_aria2_bundle.py`, embedded in both exes | [`GPL-2.0.txt`](GPL-2.0.txt): GNU GPL 2 or later; aria2 grants an additional exception permitting linking with OpenSSL | <https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0.tar.xz> |

The installer's own code is licensed under the GNU AGPL-3.0 ([`../LICENCE`](../LICENCE)); the Linux script under the GNU GPL-3.0 ([`../linux/LICENSE`](../linux/LICENSE)). Ventoy (GPL-3.0) and the MediCat archive are downloaded on the user's machine at run time and are not redistributed by this repository or its releases. Every release attaches `LICENSES.zip` with the contents of this directory, the two license files above and `THIRD_PARTY_NOTICES.md`.

When bumping 7-Zip or aria2, replace the license text with the one from the new source archive and update the version and source URL here and in [`../THIRD_PARTY_NOTICES.md`](../THIRD_PARTY_NOTICES.md).
