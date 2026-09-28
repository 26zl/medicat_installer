# Bundle the license material that must travel with the release binaries:
# the installer's AGPL-3.0 text, the Linux script's GPL-3.0 text, THIRD_PARTY_NOTICES.md and the
# license texts of the embedded 7-Zip and aria2 (THIRD_PARTY_LICENSES/). Called by tools/upload_release.bat;
# usable by hand: powershell -ExecutionPolicy Bypass -File tools\make_licenses_zip.ps1
param(
    [string]$Output = "build\Release\LICENSES.zip"
)

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

$stage = Join-Path ([IO.Path]::GetTempPath()) ("medicat_licenses_" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path (Join-Path $stage "linux") -Force | Out-Null
try {
    Copy-Item -LiteralPath "LICENCE" -Destination (Join-Path $stage "LICENCE")
    Copy-Item -LiteralPath "linux\LICENSE" -Destination (Join-Path $stage "linux\LICENSE")
    Copy-Item -LiteralPath "THIRD_PARTY_NOTICES.md" -Destination $stage
    Copy-Item -LiteralPath "THIRD_PARTY_LICENSES" -Destination (Join-Path $stage "THIRD_PARTY_LICENSES") -Recurse

    $outDir = Split-Path -Parent $Output
    if ($outDir -and -not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
    if (Test-Path $Output) { Remove-Item -LiteralPath $Output -Force }
    Compress-Archive -Path (Join-Path $stage "*") -DestinationPath $Output -CompressionLevel Optimal
    $entries = [IO.Compression.ZipFile]::OpenRead((Resolve-Path $Output).Path).Entries | Where-Object { $_.Name } | Select-Object -ExpandProperty FullName
    Write-Host ("{0}: {1} file(s)" -f $Output, $entries.Count)
    $entries | Sort-Object | ForEach-Object { Write-Host "  $_" }
}
finally {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
}
