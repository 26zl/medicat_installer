# Changelog

All notable changes to `Medicat_Installer.sh` (now `linux/` on `main`).

## 0026

- Move the script into `linux/` on `main` next to the Windows installer. Archive name, hashes, mirrors, manifest URLs, size limits and Ventoy defaults now come from the shared `spec/medicat.json` (generated block at the top of the script, `tools/gen_spec.py`).
- Add command-line flags mirroring the Windows CLI: `--install`, `--verify`, `--extras`, `--drive`, `--path`, `--archive`, `--download`, `--fs ntfs|exfat`, `--label`, `--gpt`/`--mbr`, `--secure-boot`/`--no-secure-boot`, `--ventoy-version`, `--ventoy-tar`, `--offline`, `--manifest`, `--no-reextract`, `--skip-archive-hash`, `--allow-fixed`, `--work-dir`, `--log`, `--yes`. Same exit codes as Windows (0/1/2/4/5). No flags = interactive, as before.
- Verify after extract: MD5-check the stick against `MedicatFiles.md5` (`md5sum -c`), write `failed_files.txt`, and re-extract only the failed files with `7z @list`, then re-check them. `--verify` does the same on an existing stick or on a mounted folder (`--path`).
- Extras catalog (`spec/extras.json`): download checksummed boot images (SystemRescue, GParted Live, Clonezilla, Rescuezilla, Memtest86+, Hiren's BootCD PE, Ubuntu) into `Extras/<category>/` on the stick, interactively after install or with `--extras`. `--list-extras` shows the catalog.
- Ventoy: pin a release, use a local tarball, reuse an already extracted `./ventoy`, and fall back to a known-good version when the GitHub API is unreachable. `--no-secure-boot` passes `-S`. Downloaded packages are checked against the release's `sha256.txt` before extraction.
- Optional exFAT data partition (`--fs exfat`) keeps Ventoy's own filesystem instead of `mkntfs`; NTFS stays the default.
- Try every mirror from the spec in order before offering BitTorrent. Session log in the work dir (`--log`).
- Refuse to wipe a non-USB disk unattended unless `--allow-fixed`; refuse to continue on low free space in unattended mode.
- Install 7-Zip as `7zip` on Fedora 41+ and Debian/Ubuntu (p7zip is retired or transitional there); Arch and EPEL keep `p7zip`.
- Refresh package indexes with `dnf makecache` / `yum makecache` instead of `dnf upgrade` / `yum update`, which upgraded the whole system; skip the refresh on NixOS.
- `--extras` no longer requires `aria2c`: downloads fall back to `wget` or `curl` when it is missing, so the smoke test runs without installing packages.
- Drop the unused `mkfs.exfat` dependency; Ventoy formats with its own `mkexfatfs`.
- Resolve `--drive /dev/disk/by-id/...` symlinks to the kernel device name so the data partition path is correct.
- Add `tests/linux/loop_install_test.sh`: a root-only end-to-end install on a sparse loop device.
- Install 7-Zip as `7zip` on RHEL-family systems too (EPEL 9 and 10 ship it, EPEL 10 has no p7zip) and enable EPEL first when it is missing.
- Remove the FreeBSD branch; the script needs `lsblk`, `findmnt` and GNU `stat` and never ran there.
- Credit everyone who worked on the script on one banner line.
- Catalog 2026-10-04: Clonezilla 3.3.3-37, Parrot 7.4, Super Grub2 Disk and FreeDOS 1.4 added, ESET SysRescue Live as a manual entry; SANS SIFT (not bootable) and Ubuntu Desktop (covered by Linux Mint) removed. `--list-extras` prints the total size of `all`.

## 0025

- Fix Debian/Ubuntu as a normal user (#175): append `/usr/local/sbin`, `/usr/sbin`, and `/sbin` to `PATH`, and treat those directories as valid when checking for `mkntfs`, `mkfs.vfat`, `mkfs.exfat`, and `parted`.
- Only install `ntfsprogs` on Arch, CachyOS, Fedora, and CentOS. Debian/Ubuntu still get `mkntfs` from `ntfs-3g`; the script no longer tries to apt-install an obsolete `ntfsprogs` package.
- Detect CachyOS before `/etc/arch-release` so it is not misclassified as Arch.

## 0024

- Install `ntfsprogs` for `mkntfs` on Arch and Fedora. `ntfs-3g` no longer ships the NTFS userspace tools after the 2026 package split, so the script no longer treats a missing `mkntfs` as a missing `ntfs-3g`. Falls back to `ntfsprogs` if `mkntfs` is still absent after the first install.
- Drop the files.dog TLS bypass. The mirror now serves a valid Cloudflare / Google Trust Services certificate, so aria2c/wget verify SSL normally.

## 0023

- Skip package-index refresh (`apt update` / `pacman -Syy` / etc.) when every required command is already installed (#139).

## 0022

- Fix NTFS mount for distros without in-kernel ntfs3: try ntfs3, ntfs, ntfs-3g, then auto; verify `mountpoint` before extract so a failed mount cannot dump MediCat onto the local disk (#81).

## 0021

- Accept Google Drive / Mega multi-volume archives (`MediCat.USB.v21.12.zip.001`-.006): verify each part MD5, then extract with `7z` from `.001` (addresses #87).

## 0020

- Fix Ventoy download/rename when GitHub tag parsing failed (`mv ventoy-` / missing `Ventoy2Disk.sh`) by stripping the tag to digits+dots and validating the extracted folder (addresses #99 / #142-style `venver` bugs).
- Make wget `--show-progress` optional so older wget builds still download Ventoy.
- Reject truncated MediCat archives before hashing; clearer SHA256 mismatch hints for wrong format / incomplete downloads.
- Detect Google Drive `.zip.001-.006` in the working directory and point users at the solid `.7z`.
- Fix `Medicat7zFull` path quoting for the nested `MediCat USB v21.12/` layout.

## 0019

- Warn when free space is low: working directory (~1 GiB), MediCat download (~22 GiB), and USB extract (~26 GiB). Shows `df` and asks before continuing; download/extract gates use a stronger confirm.
- Note that 32GB sticks work but are just barely enough (prefer 64GB+).

## 0018

- Non-USB wipe gate requires typing exact `CONFIRM` (not Y/N) before the normal install prompt.

## 0017

- Warn and require an extra confirmation when the selected disk is not USB (`TRAN!=usb`), to reduce accidental wipes of internal HDD/SSD/NVMe.
- Include `TRAN` in the drive list so USB devices are easier to spot.

## 0016

- All interactive prompts (keypress wait, Yes/No, device name) always read from `/dev/tty` so they never skip under `curl | bash`, pipes, or empty stdin.
- USB device entry is re-prompted until a real block device is chosen; empty `/dev/` no longer reaches the wipe confirmation.
- Correct first-partition path for `nvme*` (`…p1`) vs `sd*` (`…1`).

## 0015

- Fix colour init: stop shadowing `/usr/bin/clear` with the sgr0 variable (could break the welcome banner); safer `colEcho` via `printf`.
- Fix Debian/Ubuntu package install: use `exfatprogs` (`exfat-utils` is gone on Bookworm+), which previously aborted the whole apt transaction so aria2/7z never installed.
- Print script version at start.

## 0014

- Install dependencies one package at a time so one missing/obsolete package cannot cancel the rest of the apt/dnf transaction.
- Pass `-y` / `--noconfirm` / `--no-interactive` on package installs (apt, yum, dnf, pkg, apk, xbps; pacman already used `--noconfirm`).
- Abort if required commands are still missing after install; re-check afterward.
- Direct download falls back to `wget` when `aria2c` is missing.
- Cap aria2c concurrency at `-x16 -s16` (aria2 max is 16; was `-x32 -s32`).

## 0013

- Allow running as root/sudo after an explicit warning confirmation (useful for root-only test VMs).
- Privileged commands use `$sudo` so they work when already root (empty sudo) or as a normal user.

## 0012

- Offer download method choice: direct HTTP (aria2c multi-connection), BitTorrent, or local path when the MediCat archive is missing.
- Primary direct mirror: `files.medicatusb.com` (`aria2c -x16 -s16 -k1M -c`).
- Fallback mirror: `files.dog` (known broken SSL; aria2c without cert check).

## 0011

- Fix YesNo infinite loop: empty/EOF input no longer spins forever on "Invalid input". Read failures exit cleanly; non-TTY stdin falls back to `/dev/tty` (`curl | bash`, pipelines).
- YesNo returns exit status (`0` = yes, `1` = no) instead of echoing `true`/`false`; call sites no longer use command substitution `$(YesNo ...)`.
- Trim CR/whitespace; accept `Y`/`Yes` and `N`/`No` (case-insensitive prefix).
