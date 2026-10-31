#!/usr/bin/env python3
"""Download Ventoy zips and helper files into offline/ for air-gapped installs.

Every zip is checked against the sha256.txt of its release before it is kept, the same check the
installers run on a fresh download, because the installer uses a zip from offline/ventoy/ as-is.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import sys
import urllib.error
import urllib.request
from pathlib import Path

USER_AGENT = "medicat-installer-offline"
_SHA256_RE = re.compile(r"^[0-9a-f]{64}$")


def normalize_version(value: str) -> str:
    value = value.strip()
    if value.lower().startswith("v"):
        value = value[1:]
    return value


def fetch_json(url: str) -> object:
    request = urllib.request.Request(
        url,
        headers={"Accept": "application/vnd.github+json", "User-Agent": USER_AGENT},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        return json.load(response)


def fetch_text(url: str) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read().decode("utf-8", errors="replace")


def fetch_versions() -> list[str]:
    versions: list[str] = []
    for page in range(1, 21):
        payload = fetch_json(
            f"https://api.github.com/repos/ventoy/Ventoy/releases?per_page=100&page={page}"
        )
        if not isinstance(payload, list) or not payload:
            break
        for release in payload:
            tag = normalize_version(str(release.get("tag_name", "")))
            if tag:
                versions.append(tag)
        if len(payload) < 100:
            break
    return versions


def download_file(url: str, destination: Path) -> None:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=300) as response, destination.open("wb") as out:
        shutil.copyfileobj(response, out, 1024 * 1024)


def sha256_of(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def find_sha256_for_file(sums: str, file_name: str) -> str | None:
    """Lowercase digest of file_name from a sha256sum-style list ("<hex>  <name>" or "<hex> *<name>",
    any path prefix ignored), as FindSha256ForFile in src/ventoy.cpp reads it. None when missing."""
    for line in sums.splitlines():
        parts = line.strip().split(None, 1)
        if len(parts) != 2:
            continue
        digest = parts[0].lower()
        name = parts[1].lstrip("*").replace("\\", "/").rsplit("/", 1)[-1]
        if name.lower() == file_name.lower() and _SHA256_RE.fullmatch(digest):
            return digest
    return None


def ventoy_zip_name(version: str) -> str:
    return f"ventoy-{version}-windows.zip"


def ventoy_zip_url(version: str) -> str:
    return f"https://github.com/ventoy/Ventoy/releases/download/v{version}/{ventoy_zip_name(version)}"


def ventoy_sha256_url(version: str) -> str:
    return f"https://github.com/ventoy/Ventoy/releases/download/v{version}/sha256.txt"


def expected_zip_sha256(version: str) -> str:
    """The digest the release publishes for its Windows zip. Raises ValueError when it cannot be had."""
    url = ventoy_sha256_url(version)
    try:
        sums = fetch_text(url)
    except (urllib.error.URLError, TimeoutError, OSError) as exc:
        raise ValueError(f"could not fetch {url}: {exc}") from exc
    digest = find_sha256_for_file(sums, ventoy_zip_name(version))
    if digest is None:
        raise ValueError(f"{ventoy_zip_name(version)} is not listed in {url}")
    return digest


def ensure_verified_zip(version: str, ventoy_dir: Path) -> bool:
    """Leave a zip for `version` in ventoy_dir only if it matches the release sha256.txt.

    An existing zip is re-checked; one that does not match is moved aside, because the installer
    would use it without any further check. Returns False on any failure, after printing why.
    """
    destination = ventoy_dir / ventoy_zip_name(version)
    try:
        expected = expected_zip_sha256(version)
    except ValueError as exc:
        print(f"Cannot verify v{version}: {exc}", file=sys.stderr)
        return False

    if destination.is_file():
        actual = sha256_of(destination)
        if actual == expected:
            print(f"Verified existing {destination.name}")
            return True
        rejected = destination.with_name(destination.name + ".rejected")
        destination.replace(rejected)
        print(
            f"ERROR: existing {destination.name} does not match the release sha256.txt; moved to "
            f"{rejected.name}. Run again to download a fresh copy.\n"
            f"  expected {expected}\n  got      {actual}",
            file=sys.stderr,
        )
        return False

    url = ventoy_zip_url(version)
    partial = destination.with_name(destination.name + ".part")
    print(f"Downloading {url}")
    try:
        download_file(url, partial)
    except (urllib.error.URLError, TimeoutError, OSError) as exc:
        partial.unlink(missing_ok=True)
        print(f"Failed to download v{version}: {exc}", file=sys.stderr)
        return False

    actual = sha256_of(partial)
    if actual != expected:
        partial.unlink()
        print(
            f"ERROR: SHA-256 mismatch for {destination.name}; the download was discarded.\n"
            f"  expected {expected}\n  got      {actual}",
            file=sys.stderr,
        )
        return False

    partial.replace(destination)
    size_mb = destination.stat().st_size / (1024 * 1024)
    print(f"Saved {destination} ({size_mb:.1f} MB), SHA-256 verified")
    return True


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Populate offline/ cache for MediCat Installer; every Ventoy zip is verified "
        "against the release sha256.txt before it is kept"
    )
    parser.add_argument(
        "--output",
        type=Path,
        help="Offline folder path (default: <repo>/offline)",
    )
    parser.add_argument(
        "--versions",
        default="latest",
        help="Comma-separated Ventoy versions, or 'latest' (default: latest)",
    )
    parser.add_argument(
        "--count",
        type=int,
        default=1,
        help="When --versions=latest, download this many newest releases (default: 1)",
    )
    parser.add_argument(
        "--md5",
        action="store_true",
        help="Copy MedicatFiles.md5 from repo root into offline/",
    )
    parser.add_argument(
        "--skip-versions-file",
        action="store_true",
        help="Do not write offline/ventoy_versions.txt",
    )
    args = parser.parse_args(argv)

    repo_root = Path(__file__).resolve().parent.parent
    offline_dir = args.output or (repo_root / "offline")
    ventoy_dir = offline_dir / "ventoy"
    ventoy_dir.mkdir(parents=True, exist_ok=True)

    try:
        all_versions = fetch_versions()
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as exc:
        print(f"Failed to fetch Ventoy versions: {exc}", file=sys.stderr)
        return 1

    if not all_versions:
        print("No Ventoy versions found", file=sys.stderr)
        return 1

    if args.versions.strip().lower() == "latest":
        selected = all_versions[: max(args.count, 1)]
    else:
        selected = [normalize_version(part) for part in args.versions.split(",") if normalize_version(part)]

    if not selected:
        print("No versions selected", file=sys.stderr)
        return 1

    if not args.skip_versions_file:
        versions_path = offline_dir / "ventoy_versions.txt"
        versions_path.write_text("\n".join(all_versions) + "\n", encoding="utf-8")
        print(f"Wrote {len(all_versions)} versions to {versions_path}")

    failures = 0
    for version in selected:
        if not ensure_verified_zip(version, ventoy_dir):
            failures += 1

    if args.md5:
        source = repo_root / "MedicatFiles.md5"
        if not source.is_file():
            print(f"MedicatFiles.md5 not found at {source}", file=sys.stderr)
            failures += 1
        else:
            target = offline_dir / "MedicatFiles.md5"
            shutil.copyfile(source, target)
            print(f"Copied {target}")

    if failures:
        return 1

    print(f"Offline cache ready in {offline_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
