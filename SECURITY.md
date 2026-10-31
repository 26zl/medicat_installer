# Security policy

## Supported versions

Only the newest build is supported: the most recent versioned release (`vX.Y.Z` on the [Releases page](https://github.com/26zl/medicat_installer/releases)) once there is one, until then the current `latest` build of the Windows installer, and the Linux script on `main`. The batch-era installers and their packed executables were removed from this fork and are not supported.

## Reporting a vulnerability

Use GitHub's private vulnerability reporting for this repository (Security tab, "Report a vulnerability"). Include the installer version (`MedicatInstaller.exe /version` or `Medicat_Installer.sh --version`), the platform and steps to reproduce. Please do not open a public issue for security problems.

## What the installers do that is security-relevant

- Both installers download Ventoy and the MediCat archive over HTTPS and verify them (Ventoy against the release `sha256.txt`, the archive by SHA-256/MD5, every extracted file by MD5). A Ventoy package supplied locally (`--ventoy-tar` on Linux, the `offline\` cache on Windows) is used as-is; `tools/populate_offline.py` only keeps a zip in that cache after it matched the release `sha256.txt`, and moves a cached zip aside when it does not.
- Windows installer, redirects: the files the checks rely on (the MD5 manifest, the Ventoy release list and `sha256.txt`) are fetched with WinHTTP over HTTPS only, and a redirect from HTTPS to plain HTTP fails the request. Payload downloads (the MediCat archive, the Ventoy zip, the extras) may follow such a redirect, because some mirrors use one, and are accepted only when their checksum matches.
- Windows installer, targets: `C:`, the drive Windows runs from and the drive the installer was started from are never offered or accepted, not even with `/allow-fixed /yes`.
- Extras from `spec/extras.json` are verified with the checksum the upstream project publishes.
- Nothing is sent to a server without consent; see the telemetry section in the README.
