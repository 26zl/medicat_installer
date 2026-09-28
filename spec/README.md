# Shared spec

One source of truth for everything both installers must agree on, plus the catalog of
optional boot images. The Windows C++ installer and the Linux bash installer never read
these JSON files at runtime; `tools/gen_spec.py` bakes them in.

| File | Contents |
|------|----------|
| `medicat.json` | MediCat version, archive name/size/MD5/SHA-256, Google Drive split parts, download mirrors, torrent/magnet, MD5 manifest URLs, USB size limits, free-space gates, Ventoy defaults, the GitHub repository the Windows installer updates from (`updates.github_repository`) and the checksum asset it requires (`SHA256SUMS.txt`), support links |
| `extras.json` | Catalog of optional boot images with the upstream projects' checksums: rescue and imaging, diagnostics and disk wiping, Windows rescue, live Linux, forensics, plus `manual` entries for downloads that need a login (Windows ISOs, SANS SIFT, PALADIN). `--list-extras` / `/list-extras` print the current entries |
| `MediCat_USB_v21.12.torrent` | The official torrent for the archive, kept here so the fork stays self-sufficient; the installers fetch it from `medicat.torrent.url` |

## Generated outputs

| Output | Consumer |
|--------|----------|
| `src/spec_generated.h` | `src/downloads.h` includes it; constants keep their old names (`kMediCatArchiveFileName`, `kDownloadMirror1Url`, ...) plus `kMediCatExtras[]` |
| `linux/Medicat_Installer.sh` | the block between `# BEGIN GENERATED SPEC` and `# END GENERATED SPEC` (bash variables and arrays) |

Both outputs are committed. Regenerate after editing a JSON file:

```bash
python3 tools/gen_spec.py          # rewrite both outputs
python3 tools/gen_spec.py --check  # exit 1 when an output is stale (CI runs this)
```

The CMake build also runs the generator, so a Windows build never ships stale constants.

## Adding an extra boot image

1. Add an entry to `extras.json`:
   - `id`: lowercase letters, digits, dashes. Used on the command line (`--extras id1,id2`).
   - `category`: folder name under `Extras/` on the stick. Ventoy lists it as a submenu.
   - `targets`: `linux`, `windows` or both, meaning which kind of machine the tool repairs.
   - `type`: `iso` for a direct download, `manual` when the vendor only offers time-limited links (the installer prints instructions instead).
   - `url`, `file_name`, `bytes`, and `sha256` (preferred), `sha512`, `sha1` or `md5`, whatever the project publishes. Take the checksum from the upstream project and record where in `checksum_source`.
   - `unpack`: only when the download is a zip that contains the ISO, e.g. `{"format": "zip", "member": "memtest.iso"}`.
2. Run `python3 tools/gen_spec.py`.
3. Run `bash tests/linux/smoke_test.sh` (needs `7z`; set `MEDICAT_TEST_NETWORK=0` to skip the download check).

Bumping a version means updating `version`, `url`, `file_name`, `bytes` and the checksum together; the generator refuses malformed hashes and non-https URLs.

## Where the values came from

The initial `medicat.json` mirrors the constants that lived in `src/downloads.h`, `src/verify.cpp`, `src/drives.h` and the top of the Linux script, so the first generated outputs changed no behaviour.
