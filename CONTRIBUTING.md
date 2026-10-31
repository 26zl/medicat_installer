# Contributing

`main` is the only branch; open pull requests against it. CI ([`ci.yml`](.github/workflows/ci.yml)) runs on every push and pull request: the spec check, shellcheck and the smoke test for the Linux script, then a Windows build with the unit tests and the VHD smoke test. Commits of the upstream project arrive through the weekly `upstream-sync` workflow (or `tools/sync_upstream.sh`), so there is no need to port them by hand.

Discuss larger changes in an [issue](https://github.com/26zl/medicat_installer/issues) or in the [MediCat Discord](https://url.medicatusb.com/discord) first. Security problems go through [`SECURITY.md`](SECURITY.md), not a public issue.

## Shared spec

Mirrors, hashes, sizes and the extras catalog live in `spec/*.json`. Never edit `src/spec_generated.h` or the generated block in `linux/Medicat_Installer.sh` by hand:

```bash
python3 tools/gen_spec.py          # regenerate both outputs
python3 tools/gen_spec.py --check  # what CI runs: fails when either output is stale
```

Adding an extras entry is described in [`spec/README.md`](spec/README.md).

## Linux installer (`linux/Medicat_Installer.sh`)

Needs bash 4+, `shellcheck`, `7z` (`p7zip-full` or `7zip`) and GNU coreutils. The checks CI runs, from the repository root:

```bash
bash -n linux/Medicat_Installer.sh
shellcheck -S warning linux/Medicat_Installer.sh tests/linux/smoke_test.sh tools/sync_upstream.sh
bash tests/linux/smoke_test.sh        # no root, no USB stick; MEDICAT_TEST_NETWORK=0 skips the one download
```

`sudo bash tests/linux/loop_install_test.sh` runs a full `--install` on a 32 GiB sparse loop device (needs root; downloads Ventoy unless `MEDICAT_TEST_VENTOY_TAR` names a local tarball). Keep the script self-contained (users fetch it alone with curl), indent with tabs, and add a line to [`linux/CHANGELOG.md`](linux/CHANGELOG.md) under the current script version.

## Windows installer (`src/`, C++17)

Visual Studio 2022 or newer with the C++ build tools, CMake and Python 3 on `PATH`; Pillow only to regenerate `res/discord.ico`. Build both exes with `rebuild.bat` (outputs in `build\Release\`). Unit tests and the runtime smoke test, as CI runs them after the build (the smoke test needs an elevated PowerShell and creates a throw-away VHD):

```bat
cmake -S . -B build-tests -G "Visual Studio 17 2022" -A x64 -DMEDICAT_BUILD_TESTS=ON
cmake --build build-tests --config Release --target MedicatTests
build-tests\Release\MedicatTests.exe
powershell -NoProfile -ExecutionPolicy Bypass -File tests\windows\smoke_cli.ps1
```

Conventions: `/W4 /permissive-`, wide strings for paths and UI, no Win32 GUI calls from worker threads (see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)). New user-visible strings go into `i18n/translations.json` for every language, then `python tools/i18n_codegen.py` (the CMake build runs it too). Flags and exit codes are documented in [`docs/CLI.md`](docs/CLI.md); change it together with the code.

## Workflows

`actionlint .github/workflows/*.yml` must pass. Workflows keep `permissions: contents: read` at the top level and grant write scopes to the job that needs them.

## Commits and pull requests

- One topic per pull request; say in the description which of the checks above you ran.
- Commit messages are plain imperative sentences that say why (no Conventional Commits prefixes).
- Add a line under `Unreleased` in [`CHANGELOG.md`](CHANGELOG.md) for anything a user would notice.

## Releases

There are no versioned releases yet. Every push to `main` rebuilds both exes and refreshes the rolling [`latest`](https://github.com/26zl/medicat_installer/releases/tag/latest) release (the tag is moved to the new commit and the assets replaced); the installer version is `1.0.<CI run number>`. The Linux script is used straight from `main`.
