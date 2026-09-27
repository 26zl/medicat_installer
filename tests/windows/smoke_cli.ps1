# Runtime smoke test for the built MedicatInstaller.exe: information commands, argument errors,
# and the extras download onto a throw-away VHD. Runs elevated on the CI runner; needs network
# for the Memtest86+ download. Console text from the exe is not captured (it attaches its own
# console), so the checks rely on exit codes and files.
param(
    [string]$Exe = "build\Release\MedicatInstaller.exe",
    [string]$DriveLetter = "X"
)

$ErrorActionPreference = "Stop"
$exePath = (Resolve-Path $Exe).Path
$failures = 0

function Run([string]$Arguments) {
    $p = Start-Process -FilePath $exePath -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
    return $p.ExitCode
}

function Check([bool]$Condition, [string]$What) {
    if ($Condition) {
        Write-Host "PASS: $What"
    } else {
        Write-Host "FAIL: $What"
        $script:failures++
    }
}

foreach ($a in @("/version", "/help", "/list-extras", "/dump-config")) {
    $code = Run $a
    Check ($code -eq 0) "$a exits 0 (got $code)"
}
Check ((Run "/bogus") -eq 2) "unknown flag exits 2"
Check ((Run "/extras:all") -eq 2) "/extras without /drive exits 2"
Check ((Run "/extras:nope /drive:$DriveLetter") -eq 2) "unknown catalog id exits 2"

$vhd = Join-Path $env:RUNNER_TEMP "medicat_smoke.vhdx"
if (Test-Path $vhd) { Remove-Item $vhd -Force }
$create = @"
create vdisk file="$vhd" maximum=40960 type=expandable
select vdisk file="$vhd"
attach vdisk
create partition primary
format fs=ntfs quick label=MEDICATTEST
assign letter=$DriveLetter
"@
$createScript = Join-Path $env:RUNNER_TEMP "dp_create.txt"
Set-Content -Path $createScript -Value $create
diskpart /s $createScript | Out-Null
Start-Sleep -Seconds 3
Check (Test-Path "${DriveLetter}:\") "throw-away VHD is mounted as ${DriveLetter}:"

try {
    Check ((Run "/list-drives /allow-fixed") -eq 0) "/list-drives exits 0"

    $code = Run "/extras:memtest86plus /drive:$DriveLetter /allow-fixed /quiet"
    Check ($code -eq 0) "/extras downloads Memtest86+ onto the VHD (exit $code)"
    $iso = "${DriveLetter}:\Extras\Diagnostics\mt86plus_8.10_x86_64.iso"
    Check ((Test-Path $iso) -and ((Get-Item $iso).Length -gt 1MB) -and -not (Test-Path "$iso.part")) "memtest iso is unpacked in Extras\Diagnostics"
    $manifest = "${DriveLetter}:\Extras\extras_manifest.txt"
    Check ((Test-Path $manifest) -and ((Get-Content $manifest) -match "^memtest86plus")) "extras_manifest.txt records the download"

    $code = Run "/extras:memtest86plus /drive:$DriveLetter /allow-fixed /quiet"
    Check ($code -eq 0) "/extras rerun keeps the existing image (exit $code)"
    Check (((Get-Content $manifest) | Measure-Object).Count -eq 1) "rerun does not duplicate the manifest entry"

    $code = Run "/verify /drive:$DriveLetter /allow-fixed /quiet /no-telemetry"
    Check ($code -ne 0) "/verify on an empty drive fails (exit $code)"
}
finally {
    $log = Join-Path (Split-Path $exePath) "logs\medicat_installer.log"
    if (Test-Path $log) {
        Write-Host "--- medicat_installer.log (tail)"
        Get-Content $log -Tail 40
    }
    $detachScript = Join-Path $env:RUNNER_TEMP "dp_detach.txt"
    Set-Content -Path $detachScript -Value "select vdisk file=`"$vhd`"`ndetach vdisk"
    diskpart /s $detachScript | Out-Null
}

Write-Host "$failures failure(s)"
exit $failures
