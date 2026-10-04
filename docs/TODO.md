# Open work

What is still missing or worth doing next. Everything else in this file's history is done.

- **Extras catalog in the Windows GUI.** The catalog (`spec/extras.json`) is available on Windows through the CLI (`/extras:`, `/list-extras`) and in the Linux installer interactively; a picker in the GUI is the remaining piece.
- **Telemetry settings in the GUI.** Consent is asked on first start and stored in `preferences.json`; an Advanced checkbox to change it later would avoid editing the file by hand.
- **Refresh drives** button and a **Cancel** button during install (see `FEATURES.md`).
- **Kali Linux in the catalog.** `cdimage.kali.org` answers 404 to direct ISO downloads; adding it needs a torrent-based entry.
- **Headless install smoke test.** CI exercises the information commands, `/extras` and `/verify` on a throw-away VHD (`tests/windows/smoke_cli.ps1`); a full `/install /yes /quiet` run needs the 23 GB archive and is still manual.
