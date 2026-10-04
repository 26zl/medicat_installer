# MediCat telemetry API (ingest)

The part of the support server that the installer talks to. The server itself, its admin UI and the read API (`GET /v1/sessions`, `/v1/uploads`, `/v1/stats`, `/v1/insights`) live in the private repository [medicat-support-server](https://github.com/mon5termatt/medicat-support-server); what the installer sends and when is in [`SUPPORT_UPLOAD.md`](SUPPORT_UPLOAD.md), what the server keeps in [`SUPPORT_SERVER.md`](SUPPORT_SERVER.md).

Base URL: `https://telemetry.medicatusb.com` (production) or `http://127.0.0.1:8000` (local Docker). JSON routes live under `/v1`; the health check is `GET /health` (no auth, answers `{"status": "ok"}`).

## Authentication

Every ingest request carries the build's ingest token:

```http
Authorization: Bearer <INGEST_TOKEN>
```

| Status | Body | Meaning |
|--------|------|---------|
| 401 | `{"error": "unauthorized"}` | Missing or wrong token |
| 503 | `{"error": "ingest_not_configured"}` | The server has no `INGEST_TOKEN` set |

## Session reports

```http
POST /v1/sessions
Content-Type: application/json
```

Rate limit: 60 requests per hour per client IP. Required fields: `session_id` (UUID, max 36 chars), `client` (`MedicatInstaller`), `operation` (`launch`, `install`, `verify`) and `outcome` (`opened`, `success`, `cancelled`, `install_failed`, `reextract_failed`, `verify_failed`, `verify_failed_after_reextract`, `verify_error`, `verify_wrong_drive`). Everything else the installer sends (`exit_code`, `installer_version`, `installer_build`, `installer_arch`, `system`, `error` with `title`/`detail` capped at 512 chars, and the rest listed in `SUPPORT_UPLOAD.md`) is optional and stored as-is.

| Status | Body |
|--------|------|
| 204 | empty, accepted |
| 400 | `{"error": "expected_json"}` or `{"error": "invalid_payload", "message": "..."}` |

## Failure log upload

```http
POST /v1/support/uploads
Content-Type: multipart/form-data
```

Rate limit: 5 uploads per hour per client IP.

| Field | Required | Notes |
|-------|----------|-------|
| `bundle` | yes | Zip file: 10 MB compressed, 25 MB uncompressed, 20 files at most; only `.log`, `.txt` and `.json` entries, no path traversal |
| `session_id` | no | Links the upload to a session report |
| `manifest` | no | JSON string, merged with `support_manifest.json` inside the zip |

```json
{
  "upload_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "keyword": "MEDICAT-A7X9K2",
  "expires_at": "2026-07-30T12:00:00+00:00",
  "retention_days": 30,
  "merged": false
}
```

| Status | Body |
|--------|------|
| 201 | the object above |
| 400 | `{"error": "missing_bundle"}`, `{"error": "invalid_manifest"}` or a validation code with `message` |
| 413 | `{"error": "payload_too_large", "message": "..."}` |
| 500 | `{"error": "storage_error"}` |

The keyword is `MEDICAT-` plus 6 to 8 characters from `ABCDEFGHJKLMNPQRSTUVWXYZ23456789`; the installer shows it as the Diag code, and anyone holding it can open `https://telemetry.medicatusb.com/support/<keyword>`.

## Example

```bash
curl -sS -X POST \
  -H "Authorization: Bearer $INGEST_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"session_id":"…","client":"MedicatInstaller","operation":"launch","outcome":"opened"}' \
  "https://telemetry.medicatusb.com/v1/sessions"
```

Client IP on ingest comes from `CF-Connecting-IP`, then `X-Forwarded-For`, then the socket address when the server runs with `TRUST_PROXY_HEADERS=true`.
