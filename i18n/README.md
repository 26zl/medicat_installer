# Translations (C++ installer)

## Method

**Source of truth:** `i18n/translations.json`

**Build time:** `tools/i18n_codegen.py` generates `src/i18n_generated.h`; the CMake build runs it automatically.

**Runtime:** `src/i18n.cpp` loads the language pack for the Windows UI language and exposes:

```cpp
i18n::Tr(L"ui.install_button");
i18n::Tr(L"messages.file_not_found", archiveName);
i18n::Tr(L"ui.drive_format", letter, type, freeGb, totalGb);
```

The strings are compiled into the exe as a generated lookup table: no JSON parser in the installer and nothing to load at runtime. Keys and `{0}` placeholders are the same as in the JSON.

## Workflow

1. Edit `i18n/translations.json`
2. Rebuild (CMake runs the generator) or run:
   ```bat
   python tools/i18n_codegen.py
   ```
3. Use keys as `category.key` (flattened from the JSON nesting)

## Languages

`en`, `es`, `fr`, `pl`, `tr`. The installer takes the ISO 639-1 code of `GetUserDefaultUILanguage()` and uses that block when it exists, otherwise `en`; `/lang:xx` overrides it ([`docs/CLI.md`](../docs/CLI.md)). The generator also emits `cat`, a placeholder language of meows derived from the English strings, which makes untranslated text easy to spot: `MedicatInstaller.exe /lang:cat`.

## Adding a language

1. Copy the `en` block in `translations.json` under the new ISO 639-1 code
2. Translate the values, keep the keys identical
3. Rebuild

Detection is automatic: the Windows language code is matched against the generated language list. Missing keys fall back to English at runtime, so a partial translation still builds; add new keys to every language block when changing the UI.

## Key conventions

- `ui.*` labels, buttons, checkboxes
- `status.*` progress bar and status line
- `messages.*` / `titles.*` message boxes and their titles
- `errors.*` error texts shared by GUI and CLI
- `log.*` lines written to `medicat_installer.log`
- `ventoy_warning.*`, `ventoy_not_detected.*`, `wipe_confirm.*`, `drive_letter_changed.*` the confirmation dialogs

Placeholders: `{0}`, `{1}`, …
