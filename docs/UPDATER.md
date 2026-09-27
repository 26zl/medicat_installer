# Installer auto-update

The C++ installer discovers updates via the **GitHub Releases API**.

## Version and tag

| Field | Value |
|-------|--------|
| Display / build file | `1.0.41` in `build_number.txt` |
| GitHub release tag | **same string** (`1.0.41`) |
| Embedded `kInstallerVersion` | `1.0.41` |
| Embedded `kInstallerBuildNumber` | `41` (patch) |

`rebuild.bat` (local) sets `build_number.txt` to **one patch above** the latest GitHub release that ships `MedicatInstaller.exe` (e.g. latest `1.0.43` → next build `1.0.44`). That keeps local test builds aligned with published tags. Use `rebuild.bat as 1.0.N` to pin a version. CI pins the git tag and does not bump.

### Publish from a tag (CI)

Push a tag that matches the installer version (no `v` prefix). [`.github/workflows/release-build.yml`](../.github/workflows/release-build.yml) pins that tag, configures unified CMake, builds x64 + Win32 on `windows-2022`, and does **not** bump from GitHub. Then it runs `tools/upload_release.bat`.

```bat
git tag 1.0.50
git push origin 1.0.50
```

Optional repo secret **`MEDICAT_INGEST_TOKEN`** is passed into the build so support ingest works in the published exe. You can also run the workflow by hand (`workflow_dispatch`) and choose whether to publish.

Local upload is still available:

```bat
rebuild.bat as 1.0.50 release
```

(omit TAG after `release` to use the version from `build_number.txt`)

`tools/upload_release.bat` creates the GitHub release if the tag is missing (as **Latest**), using the annotated tag message or the tagged commit message as release notes (`gh --notes-from-tag`). It uploads both Windows exes and attaches **`Medicat_Installer.sh`** from `linux/` in the tagged tree. The release goes to the repository of the checkout (`GITHUB_REPOSITORY` in Actions, `gh repo view` locally), so forks release to themselves.

## Source

```
GET https://api.github.com/repos/<updates.github_repository>/releases?per_page=20
```

The repository is `updates.github_repository` in `spec/medicat.json` (`26zl/medicat_installer` for this fork).

Selection (newest first, must include platform asset):

1. Stable release with **semver** tag `M.m.p` (e.g. `1.0.41`)
2. Else any release with semver tag
3. Else any stable with the asset
4. Else prerelease with the asset

| Local build | Asset name |
|-------------|------------|
| x64 | `MedicatInstaller.exe` |
| x86 | `MedicatInstaller-x86.exe` |
| Linux | `Medicat_Installer.sh` (from `linux/` in the tagged tree, attached every `upload_release.bat` run) |

## Version compare

Remote is newer when **patch/build** is greater (`remoteBuild` 43 > local `kInstallerBuildNumber` 42), or when the remote **semantic version** is greater (`1.0.43` > `1.0.42`). Local version comes from `kInstallerVersion` / `kInstallerBuildNumber` (same as the UI), not the CMake `INSTALLER_RELEASE_TAG` define.  
Legacy tags like `3520` / `3521-BETA` are never treated as updates over a `1.0.N` build.

## Apply flow

1. Download asset to `<exe>.new`
2. Download the release's `SHA256SUMS.txt` (written by `tools/upload_release.bat`) and compare the SHA-256 of `<exe>.new` with the entry for the asset. A release without the file, without an entry, or with a mismatch is refused and the download deleted.
3. Launch hidden `apply_update.cmd` helper
4. Helper waits, replaces the exe, relaunches

The repository the installer polls comes from `spec/medicat.json` (`updates.github_repository`, generated into `kUpdateRepository`), so a fork updates from its own releases.
