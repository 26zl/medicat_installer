# Security policy

## Supported versions

Only the latest release of this repository is supported. The batch-era installers and their packed executables were removed from this fork and are not supported.

## Reporting a vulnerability

Use GitHub's private vulnerability reporting for this repository (Security tab, "Report a vulnerability"). Include the installer version (`MedicatInstaller.exe /version` or `Medicat_Installer.sh --version`), the platform and steps to reproduce. Please do not open a public issue for security problems.

## What the installers do that is security-relevant

- Both installers download Ventoy and the MediCat archive over HTTPS and verify them (Ventoy against the release `sha256.txt`, the archive by SHA-256/MD5, every extracted file by MD5).
- Extras from `spec/extras.json` are verified with the checksum the upstream project publishes.
- Nothing is sent to a server without consent; see the telemetry section in the README.
