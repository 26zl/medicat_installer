"""Tests for tools/populate_offline.py: the network is faked, the checksum handling is real.

Run from the repository root: python -m unittest discover -s tests/python -v
"""

from __future__ import annotations

import contextlib
import hashlib
import io
import sys
import tempfile
import unittest
import urllib.error
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))

import populate_offline  # noqa: E402

VERSION = "1.1.05"
ZIP_NAME = f"ventoy-{VERSION}-windows.zip"
GOOD = b"not really a Ventoy zip, but the bytes the release lists"
GOOD_SHA = hashlib.sha256(GOOD).hexdigest()
SUMS = (
    f"{GOOD_SHA.upper()}  {ZIP_NAME}\n"
    f"{'0' * 64} *ventoy-{VERSION}-linux.tar.gz\n"
    f"{'1' * 64}  ventoy-{VERSION}-livecd.iso\n"
)


class FindSha256ForFile(unittest.TestCase):
    def test_reads_both_sha256sum_formats_and_lower_cases(self):
        self.assertEqual(populate_offline.find_sha256_for_file(SUMS, ZIP_NAME), GOOD_SHA)
        self.assertEqual(
            populate_offline.find_sha256_for_file(SUMS, f"ventoy-{VERSION}-linux.tar.gz"), "0" * 64
        )

    def test_name_match_ignores_case_paths_and_crlf(self):
        sums = f"{GOOD_SHA} *release/windows/{ZIP_NAME.upper()}\r\n"
        self.assertEqual(populate_offline.find_sha256_for_file(sums, ZIP_NAME), GOOD_SHA)
        sums = f"{GOOD_SHA}  release\\windows\\{ZIP_NAME}\r\n"
        self.assertEqual(populate_offline.find_sha256_for_file(sums, ZIP_NAME), GOOD_SHA)

    def test_missing_or_malformed_entries_give_none(self):
        self.assertIsNone(populate_offline.find_sha256_for_file(SUMS, "ventoy-9.9.9-windows.zip"))
        self.assertIsNone(populate_offline.find_sha256_for_file("", ZIP_NAME))
        self.assertIsNone(populate_offline.find_sha256_for_file(f"{'g' * 64}  {ZIP_NAME}\n", ZIP_NAME))
        self.assertIsNone(populate_offline.find_sha256_for_file(f"{GOOD_SHA[:63]}  {ZIP_NAME}\n", ZIP_NAME))
        self.assertIsNone(populate_offline.find_sha256_for_file(f"{GOOD_SHA}\n", ZIP_NAME))


class PopulateOffline(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.out = Path(self.tmp.name) / "offline"
        self.ventoy_dir = self.out / "ventoy"
        self.downloads: list[str] = []

    def run_tool(self, payload: bytes | None = GOOD, sums: str | Exception = SUMS, versions: str = VERSION):
        def fake_download(url: str, destination: Path) -> None:
            self.downloads.append(url)
            if payload is None:
                raise urllib.error.URLError("connection refused")
            destination.write_bytes(payload)

        def fake_fetch_text(url: str) -> str:
            if isinstance(sums, Exception):
                raise sums
            return sums

        stdout, stderr = io.StringIO(), io.StringIO()
        with mock.patch.object(populate_offline, "fetch_versions", return_value=[VERSION, "1.1.04"]), mock.patch.object(
            populate_offline, "fetch_text", side_effect=fake_fetch_text
        ), mock.patch.object(populate_offline, "download_file", side_effect=fake_download), contextlib.redirect_stdout(
            stdout
        ), contextlib.redirect_stderr(stderr):
            code = populate_offline.main(
                ["--output", str(self.out), "--versions", versions, "--skip-versions-file"]
            )
        return code, stdout.getvalue(), stderr.getvalue()

    def leftovers(self) -> list[str]:
        return sorted(p.name for p in self.ventoy_dir.iterdir())

    def test_matching_download_is_kept(self):
        code, out, err = self.run_tool()
        self.assertEqual(code, 0, err)
        self.assertEqual(self.downloads, [populate_offline.ventoy_zip_url(VERSION)])
        self.assertEqual((self.ventoy_dir / ZIP_NAME).read_bytes(), GOOD)
        self.assertEqual(self.leftovers(), [ZIP_NAME])
        self.assertIn("SHA-256 verified", out)

    def test_mismatching_download_is_discarded_and_fails(self):
        code, _, err = self.run_tool(payload=GOOD + b" tampered")
        self.assertEqual(code, 1)
        self.assertEqual(self.leftovers(), [], "neither the zip nor a .part file may stay behind")
        self.assertIn("SHA-256 mismatch", err)
        self.assertIn(GOOD_SHA, err)

    def test_version_without_a_listed_zip_fails_before_downloading(self):
        code, _, err = self.run_tool(versions="1.1.04")
        self.assertEqual(code, 1)
        self.assertEqual(self.downloads, [])
        self.assertEqual(self.leftovers(), [])
        self.assertIn("not listed", err)

    def test_unreachable_checksum_list_fails_before_downloading(self):
        code, _, err = self.run_tool(sums=urllib.error.HTTPError("u", 404, "Not Found", None, None))
        self.assertEqual(code, 1)
        self.assertEqual(self.downloads, [])
        self.assertIn("Cannot verify", err)

    def test_existing_good_zip_is_verified_not_downloaded(self):
        self.ventoy_dir.mkdir(parents=True)
        (self.ventoy_dir / ZIP_NAME).write_bytes(GOOD)
        code, out, _ = self.run_tool()
        self.assertEqual(code, 0)
        self.assertEqual(self.downloads, [])
        self.assertIn("Verified existing", out)

    def test_existing_bad_zip_is_moved_aside_and_fails(self):
        self.ventoy_dir.mkdir(parents=True)
        (self.ventoy_dir / ZIP_NAME).write_bytes(b"stale or tampered")
        code, _, err = self.run_tool()
        self.assertEqual(code, 1)
        self.assertEqual(self.downloads, [], "a bad cached zip is reported, not silently replaced")
        self.assertEqual(self.leftovers(), [ZIP_NAME + ".rejected"])
        self.assertIn("does not match", err)

    def test_failed_download_leaves_nothing_behind(self):
        code, _, err = self.run_tool(payload=None)
        self.assertEqual(code, 1)
        self.assertEqual(self.leftovers(), [])
        self.assertIn("Failed to download", err)

    def test_one_bad_version_fails_the_run_but_not_the_good_one(self):
        code, _, _ = self.run_tool(versions=f"{VERSION},1.1.04")
        self.assertEqual(code, 1)
        self.assertEqual(self.leftovers(), [ZIP_NAME])


if __name__ == "__main__":
    unittest.main()
