# Changelog

Notable changes to this repository (both installers, the spec, build and workflows), in the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format. The Linux script also keeps a per-version log in [`linux/CHANGELOG.md`](linux/CHANGELOG.md).

There are no versioned releases yet: CI rebuilds the Windows installers from every push to `main` and refreshes the rolling [`latest`](https://github.com/26zl/medicat_installer/releases/tag/latest) release (installer version `1.0.<CI run number>`), and the Linux script is fetched from `main`. Earlier history is in the git log.

## [Unreleased]

### Fixed

- Linux installer: verification no longer reports "All files verified OK" when `md5sum` never checked the files (a manifest without checksum lines, an unreadable list, a read-only mount). `--verify` exits 1 in that case, and `--install` exits 1 instead of 0 when the manifest could not be resolved or checked.
- Linux installer: the full 7z extract runs with `-y`, so an unattended `--install` cannot block on an overwrite prompt.
- Docs: the minimum drive size is 28 GiB (30 GB), and Ventoy detection on Windows uses the disk layout only.

### Security

- Windows installer: the downloaded Ventoy zip is checked against the `sha256.txt` of the same release before it is extracted or cached, as the Linux installer already did for the tarball. A zip from the `offline\` cache is still used as-is.
- Windows installer: `format.com` and `cmd.exe` are started by their full `System32` path instead of being looked up next to the elevated installer first.
- `upstream-sync` workflow: the token is read-only by default; the write scopes are granted to the sync job only.

### Added

- `CONTRIBUTING.md`, `CHANGELOG.md` and `.editorconfig`.
- Linux smoke test: a manifest without checksum lines must fail verification.

[Unreleased]: https://github.com/26zl/medicat_installer/commits/main
