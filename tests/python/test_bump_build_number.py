"""Tests for tools/bump_build_number.py: pinned versions, including a release tag ending in .0."""

from __future__ import annotations

import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))

import bump_build_number  # noqa: E402


class ParseSetValue(unittest.TestCase):
    def test_release_versions_are_taken_as_is(self):
        self.assertEqual(bump_build_number.parse_set_value("1.0.0", 1, 0), (1, 0, 0))
        self.assertEqual(bump_build_number.parse_set_value("v1.2.3", 1, 0), (1, 2, 3))
        self.assertEqual(bump_build_number.parse_set_value("2.0.10", 1, 0), (2, 0, 10))

    def test_bare_counter_gets_the_default_major_minor_and_must_be_positive(self):
        self.assertEqual(bump_build_number.parse_set_value("57", 1, 0), (1, 0, 57))
        self.assertIsNone(bump_build_number.parse_set_value("0", 1, 0))

    def test_rejects_nonsense(self):
        for value in ("0.0.0", "1.0", "1.0.0.0", "abc", ""):
            self.assertIsNone(bump_build_number.parse_set_value(value, 1, 0), value)


class PinWritesBothFiles(unittest.TestCase):
    def test_set_release_version(self):
        with tempfile.TemporaryDirectory() as tmp:
            counter = Path(tmp) / "build_number.txt"
            output = Path(tmp) / "generated" / "build_version.cpp"
            argv = ["bump_build_number.py", str(counter), str(output), "--major", "1", "--minor", "0", "--set", "1.0.0"]
            env = {k: v for k, v in os.environ.items() if k != "MEDICAT_PIN_BUILD"}
            with mock.patch.object(sys, "argv", argv), mock.patch.dict(os.environ, env, clear=True):
                self.assertEqual(bump_build_number.main(), 0)
            self.assertEqual(counter.read_text(encoding="utf-8"), "1.0.0\n")
            text = output.read_text(encoding="utf-8")
            self.assertIn('kInstallerVersion[] = "1.0.0"', text)
            self.assertIn("kInstallerBuildNumber = 0;", text)

    def test_env_pin_with_zero_counter_is_still_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            counter = Path(tmp) / "build_number.txt"
            output = Path(tmp) / "build_version.cpp"
            argv = ["bump_build_number.py", str(counter), str(output)]
            with mock.patch.object(sys, "argv", argv), mock.patch.dict(os.environ, {"MEDICAT_PIN_BUILD": "0"}):
                self.assertEqual(bump_build_number.main(), 1)
            self.assertFalse(counter.exists())


if __name__ == "__main__":
    unittest.main()
