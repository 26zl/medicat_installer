@echo off
setlocal
cd /d "%~dp0\.."

REM Release into the repository this checkout belongs to (fork-safe): GitHub Actions sets
REM GITHUB_REPOSITORY; locally gh resolves it from the origin remote.
set "REPO=%GITHUB_REPOSITORY%"
if not "%REPO%"=="" goto have_repo
for /f "usebackq delims=" %%R in (`gh repo view --json nameWithOwner -q .nameWithOwner 2^>nul`) do set "REPO=%%R"
if not "%REPO%"=="" goto have_repo
echo Could not determine the GitHub repository. Set GITHUB_REPOSITORY=owner/name.
exit /b 1

:have_repo
set "TAG=%~1"
if not "%TAG%"=="" goto have_tag

if exist "build_number.txt" set /p TAG=<build_number.txt
if not "%TAG%"=="" goto have_tag

if exist "release_tag.txt" set /p TAG=<release_tag.txt
if not "%TAG%"=="" goto have_tag

REM Single-line for/f only — avoid nested parens / select(...) in do-blocks.
for /f "usebackq delims=" %%T in (`gh release list --repo %REPO% --limit 1 --json tagName -q ".[0].tagName" 2^>nul`) do set "TAG=%%T"

:have_tag
if not "%TAG%"=="" goto files_ready
echo Could not determine GitHub release tag.
echo Pass a tag matching the installer version, e.g. tools\upload_release.bat 1.0.41
echo Or ensure build_number.txt contains the version 1.0.N.
exit /b 1

:files_ready
set "X64_SRC=build\x64\Release\MedicatInstaller.exe"
set "X86_SRC=build\x86\Release\MedicatInstaller-x86.exe"
set "X64_EXE=build\Release\MedicatInstaller.exe"
set "X86_EXE=build\Release\MedicatInstaller-x86.exe"

if not exist "%X64_SRC%" if exist "%X64_EXE%" set "X64_SRC=%X64_EXE%"
if not exist "%X86_SRC%" if exist "%X86_EXE%" set "X86_SRC=%X86_EXE%"
if not exist "%X86_SRC%" if exist "build-x86\Release\MedicatInstaller-x86.exe" set "X86_SRC=build-x86\Release\MedicatInstaller-x86.exe"

if exist "%X64_SRC%" goto have_x64
echo Missing x64 build: %X64_SRC%
echo Run rebuild.bat first.
exit /b 1

:have_x64
if exist "%X86_SRC%" goto have_x86
echo Missing Win32 build: %X86_SRC%
echo Run rebuild.bat first.
exit /b 1

:have_x86
if not exist "build\Release" mkdir "build\Release"
copy /Y "%X64_SRC%" "%X64_EXE%" >nul
copy /Y "%X86_SRC%" "%X86_EXE%" >nul

if exist "%X64_EXE%" goto have_staged_x64
echo Missing x64 build: %X64_EXE%
echo Run rebuild.bat first.
exit /b 1

:have_staged_x64
if exist "%X86_EXE%" goto fetch_linux
echo Missing Win32 build: %X86_EXE%
echo Run rebuild.bat first.
exit /b 1

:fetch_linux
REM Ship the Linux installer from this checkout so the release matches the tagged tree.
set "LINUX_SH=build\Release\Medicat_Installer.sh"
set "LINUX_SRC=linux\Medicat_Installer.sh"
if not exist "%LINUX_SRC%" goto linux_fetch_failed
copy /Y "%LINUX_SRC%" "%LINUX_SH%" >nul
if errorlevel 1 goto linux_fetch_failed
for %%I in ("%LINUX_SH%") do if %%~zI==0 goto linux_fetch_failed
echo   %LINUX_SH% ready (from %LINUX_SRC%)

REM The installer refuses to self-update from a release without this file (see docs/UPDATER.md).
set "SUMS=build\Release\SHA256SUMS.txt"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$lines = foreach ($f in @('%X64_EXE%','%X86_EXE%','%LINUX_SH%')) { $h = Get-FileHash -Algorithm SHA256 -LiteralPath $f; '{0}  {1}' -f $h.Hash.ToLower(), (Split-Path -Leaf $f) }; Set-Content -LiteralPath '%SUMS%' -Value $lines -Encoding ascii"
if errorlevel 1 goto sums_failed
if not exist "%SUMS%" goto sums_failed
echo   %SUMS% ready
goto do_upload

:sums_failed
echo Failed to write %SUMS%.
exit /b 1

:linux_fetch_failed
echo Missing or empty %LINUX_SRC% in the checkout.
exit /b 1

:do_upload
gh release view "%TAG%" --repo "%REPO%" >nul 2>&1
if errorlevel 1 goto create_release
goto upload_assets

:create_release
echo Creating GitHub release %TAG%...
REM Prefer annotated tag message, else the tagged commit message (not empty
REM generate-notes changelog-only stubs). Resolve notes ourselves: gh rejects
REM --notes-from-tag with --repo, and --notes-from-tag needs the tag locally
REM (workflow_dispatch checkouts often lack refs/tags/1.0.N).
git rev-parse -q --verify "refs/tags/%TAG%" >nul 2>&1
if not errorlevel 1 goto have_local_tag
echo Fetching tag %TAG% for release notes...
git fetch --no-tags origin "refs/tags/%TAG%:refs/tags/%TAG%"
if errorlevel 1 goto create_failed

:have_local_tag
set "NOTES_FILE=%TEMP%\medicat_release_notes_%TAG%.txt"
git tag -l --format=%%(contents) "%TAG%" > "%NOTES_FILE%" 2>nul
for %%A in ("%NOTES_FILE%") do if %%~zA==0 git log -1 --format=%%B "%TAG%" > "%NOTES_FILE%"
gh release create "%TAG%" --title "%TAG%" --notes-file "%NOTES_FILE%" --latest --repo "%REPO%"
if errorlevel 1 goto create_failed
goto upload_assets

:create_failed
echo Failed to create release %TAG%.
exit /b 1

:upload_assets
echo Uploading assets to GitHub release %TAG%...
gh release upload "%TAG%" "%X64_EXE%" "%X86_EXE%" "%LINUX_SH%" "%SUMS%" --clobber --repo "%REPO%"
if errorlevel 1 goto upload_failed

echo.
echo Uploaded:
echo   %X64_EXE%
echo   %X86_EXE%
echo   %LINUX_SH%  ^(from linux\^)
echo   %SUMS%
echo Release: https://github.com/%REPO%/releases/tag/%TAG%
echo Installer self-update discovers Windows assets via the GitHub Releases API.
exit /b 0

:upload_failed
echo Release upload failed.
exit /b 1
