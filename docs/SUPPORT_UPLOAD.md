# Support telemetry and log upload

Two kinds of data can leave the Windows installer, both only after an explicit yes and only in builds that carry an ingest token. CI builds of this repository have no token, so they never prompt and never send anything. The Linux script sends nothing.

| Tier | When | Consent | Payload |
|------|------|---------|---------|
| **A: session report** | At start (`launch` / `opened`) and at the end of every install or verify | Asked once on first GUI start and saved; headless runs follow the saved answer or `/telemetry` | About 1 KB of JSON, no log files |
| **B: failure log bundle** | Only after a failed install or verify | Yes/No dialog for each failure; headless runs need `/upload-logs` | Zip of allowlisted log files plus a manifest |

Code: `src/support.cpp` (payloads, preferences, HTTP), `src/app.cpp` (`EnsureTelemetryConsent`, `SubmitSessionReport`, `QueueFailureLogUpload`), `src/debug.cpp` (system snapshot). What the server stores: [`SUPPORT_SERVER.md`](SUPPORT_SERVER.md); its API: [`api.md`](api.md).

## Consent and preferences

On the first GUI start of a build with an ingest token, `EnsureTelemetryConsent` shows `messages.telemetry_consent` as a Yes/No box and writes `%AppData%\MedicatInstaller\preferences.json`:

```json
{
  "session_reports_enabled": false,
  "failure_log_auto_upload_enabled": true
}
```

- `session_reports_enabled` turns Tier A on or off. A missing or unreadable file counts as **off**; consent is never assumed.
- `failure_log_auto_upload_enabled` only controls whether the Tier B offer appears after a failure. `false` hides the dialog. Despite the name, nothing is uploaded automatically.
- `/telemetry` and `/no-telemetry` override the saved answer for one run. A headless run without either flag and without a saved yes sends nothing.
- There is no settings UI yet ([`TODO.md`](TODO.md)); edit the file, or delete it to be asked again.

## Tier A: session report

`SubmitLaunchSessionReport` runs right after start, `SubmitSessionReport` when an install or verify ends. The GUI posts from a background thread; headless runs post before exiting. Target: `MEDICAT_SESSIONS_URL`, default `https://telemetry.medicatusb.com/v1/sessions`, with `Authorization: Bearer <ingest token>`. Failures (401, 503, network) go to `medicat_installer.log` only; nothing is retried or shown.

`BuildSessionReportJson` sends:

| Field | Content |
|-------|---------|
| `schema_version`, `session_id`, `client` | `1`, a random UUID per run, `MedicatInstaller` |
| `operation`, `outcome`, `exit_code`, `duration_ms` | `launch`, `install` or `verify`; outcome below; the exit code and wall time |
| `installer_version`, `installer_build`, `installer_arch`, `release_tag`, `medicat_usb_version` | Build identity, e.g. `1.0.49`, `49`, `x64`, `1.0.49`, `21.12` |
| `ui_language`, `locale`, `elevated` | UI language code, Windows user locale, whether the process is elevated |
| `options` | `format`, `ventoy`, `ventoy_gpt`, `ventoy_secure_boot`, `headless` as booleans |
| `system` | `windows_build`, `windows_ubr`, `windows_major_minor`, `edition_id`, `installation_type`, `processor_arch`, `logical_processors`, `ram_gb_bucket` (`4`, `8`, `16`, `32`, `64+`), `machine_id_hash` (SHA-256 of the machine GUID) |
| `error` | Only on failure: `title` (max 128 chars) and `detail` (max 512), translated to English, with drive letters replaced by `<drive>:`, profile paths by `\Users\<user>\` and `\\?\` prefixes by `<path>\` |

Outcomes (`DeriveSessionOutcome`): `opened`, `success`, `cancelled`, `install_failed`, `reextract_failed`, `verify_failed`, `verify_failed_after_reextract`, `verify_error`, `verify_wrong_drive`.

Not sent: user or computer name, drive letters or paths other than the redacted error text, file names from the stick, log contents. The client sends no IP address; the server sees the connection and keeps a salted hash for rate limiting.

## Tier B: failure log bundle

Offered only when an install or verify failed with a message (not on cancel), the build has a token and `failure_log_auto_upload_enabled` is not `false`. The GUI asks with `messages.upload_logs_prompt` before the failure dialog opens; headless runs upload only with `/upload-logs`.

`CollectSupportLogFiles` takes these files from `logs\` beside the exe (falling back to the exe directory), skipping missing or empty ones:

| File | Source |
|------|--------|
| `medicat_installer.log` | Every session, including the diagnostics sections |
| `ventoy.log`, `cli_log.txt` | Ventoy2Disk output (`cli_log.txt` also from `Ventoy2Disk\` on older layouts) |
| `extract.log`, `reextract.log` | Full and selective 7-Zip extraction |
| `check.log`, `failed_files.txt` | MD5 verification |
| `aria.log` | aria2c HTTP or torrent download |
| `support_manifest.json` | Generated at upload time: `session_id`, `client`, `operation`, `installer_version`, `installer_build`, `ui_language`, `error_title`, `error_detail`, `files_included` |

The files are zipped with the bundled `7za.exe` under `%TEMP%\MedicatInstaller\<pid>\` and posted as multipart form data (`bundle`, `session_id`, `manifest`) to `MEDICAT_UPLOADS_URL`, default `https://telemetry.medicatusb.com/v1/support/uploads`, with the same bearer token. The server answers with a keyword such as `MEDICAT-A7X9K2`; the failure dialog shows it as the **Diag code** with a copy button for Discord. The zip and the staging folder are deleted afterwards.

The log files contain file paths, drive letters and tool output. The debug log no longer records the computer or user name. Executables, archives, the Ventoy package and the contents of the stick are never included. Retention and rate limits are the server's: 30 days, 5 uploads per hour per IP ([`SUPPORT_SERVER.md`](SUPPORT_SERVER.md)).

## Build configuration

- `MEDICAT_SESSIONS_URL` and `MEDICAT_UPLOADS_URL` are compile definitions set in `CMakeLists.txt`; `cmake/local.cmake` (gitignored, see `cmake/local.cmake.example`) overrides them for a local server.
- The ingest token comes from the `MEDICAT_INGEST_TOKEN` CMake variable or environment variable, or from `cmake/ingest.token` (gitignored). `tools/generate_ingest_token.py` writes it obfuscated into `generated/ingest_token.cpp`; without a token `HasIngestToken()` is false and every path above is skipped. `ci.yml` builds without one; a build that reports needs the token set locally.

## Command line

| Flag | Effect |
|------|--------|
| `/telemetry`, `/no-telemetry` | Send or skip the session reports for this run, overriding the saved preference |
| `/upload-logs` | Allow the failure bundle after a failed headless run |

Details in [`CLI.md`](CLI.md). The user-facing summary lives in the README's telemetry section.
