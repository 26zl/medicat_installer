#!/usr/bin/env bash

ScriptVersion="0026"

# See CHANGELOG.md for changes.
#
# Interactive by default. Headless use (mirrors the Windows CLI flags):
#   ./Medicat_Installer.sh --install --drive /dev/sdb --yes
#   ./Medicat_Installer.sh --verify --drive /dev/sdb
#   ./Medicat_Installer.sh --extras systemrescue,gparted-live --drive /dev/sdb
# Run with --help for the full list.

# Shared spec
# Everything between the markers comes from spec/medicat.json and spec/extras.json
# (the Windows installer reads the same data via src/spec_generated.h).
# BEGIN GENERATED SPEC - edit spec/*.json and run tools/gen_spec.py
# shellcheck disable=SC2034  # every spec value is defined here; the script uses only some of them
function loadSpec() {
	SpecVersion=1
	MedicatVersion='v21.12'
	Medicat7zFile='MediCat.USB.v21.12.7z'
	Medicat7zBytes=22994783619
	Medicat7zMinBytes=21845044438
	Medicat7zMd5='db50f96a5c7b5ec6dc9ed77ea29fffb0'
	Medicat256Hash='a306331453897d2b20644ca9334bb0015b126b8647cecec8d9b2d300a0027ea4'
	Medicat7zTorrentSubdir='MediCat USB v21.12'
	MedicatSplitBase='MediCat.USB.v21.12.zip'
	MedicatSplitFiles=('MediCat.USB.v21.12.zip.001' 'MediCat.USB.v21.12.zip.002' 'MediCat.USB.v21.12.zip.003' 'MediCat.USB.v21.12.zip.004' 'MediCat.USB.v21.12.zip.005' 'MediCat.USB.v21.12.zip.006')
	MedicatSplitSizes=('4290772992' '4290772992' '4290772992' '4290772992' '4290772992' '2917026620')
	MedicatSplitMd5s=('277793dcf0e31736f0790162a89d07c9' 'a4700261f32d4df5092c5dd5ea6aaa2d' '6b523273c5c7ed1ddc5920dec95b8509' '35fac6ff4902d62e6e5fd2dab1050a3f' '7f416a7d9ff0051ae75bbf44a411b8e4' '32d84a280af91ae408f55a7722ee6818')
	MedicatMirrorNames=('files.medicatusb.com' 'files.dog')
	MedicatMirrorUrls=('https://files.medicatusb.com/files/v21.12/MediCat.USB.v21.12.7z' 'https://files.dog/OD%20Rips/MediCat/v21.12/MediCat.USB.v21.12.7z')
	MedicatMirrorInsecure=('false' 'false')
	MedicatTorrentUrl='https://github.com/mon5termatt/medicat_installer/raw/main/download/MediCat_USB_v21.12.torrent'
	MedicatMagnetUrl='magnet:?xt=urn:btih:1D714BDF37890669E98933B724B55D47E7F2D01B'
	MedicatManifestFile='MedicatFiles.md5'
	MedicatManifestUrls=('https://raw.githubusercontent.com/26zl/medicat_installer/main/MedicatFiles.md5' 'https://raw.githubusercontent.com/mon5termatt/medicat_installer/main/MedicatFiles.md5')
	MedicatManifestFileCount=29652
	MedicatExtractedBytes=28311000111
	MedicatUsbMinBytes=30064771072
	MedicatUsbRecommendedBytes=64000000000
	MedicatDataLabel='Medicat'
	MedicatDataFs='ntfs'
	MedicatDownloadMinFreeBytes=23622320128
	MedicatWorkMinFreeBytes=1073741824
	MedicatUsbMinFreeBytes=27917287424
	VentoyKnownGoodVersion='1.1.17'
	VentoyPinnedVersion=''
	VentoyDefaultPartitionStyle='mbr'
	VentoyDefaultSecureBoot='true'
	VentoyReleaseApi='https://api.github.com/repos/ventoy/Ventoy/releases'
	VentoyLinuxTarUrlTemplate='https://github.com/ventoy/Ventoy/releases/download/v{version}/ventoy-{version}-linux.tar.gz'
	LinkManualInstallDoc='https://medicatusb.com/docs/medicat/installation/manual-install/'
	LinkIssues='https://github.com/26zl/medicat_installer/issues'
	LinkDiscord='https://url.medicatusb.com/discord'
	UpdateRepository='26zl/medicat_installer'
	UpdateChecksumsAsset='SHA256SUMS.txt'
	ExtrasCatalogVersion='2026-09-27'
	ExtrasDestRoot='Extras'
	ExtrasIds=('systemrescue' 'gparted-live' 'clonezilla-live' 'rescuezilla' 'memtest86plus' 'hirens-bootcd-pe' 'ubuntu-desktop-lts' 'windows-11-iso' 'linux-mint-cinnamon' 'debian-live-kde' 'shredos' 'windows-10-iso' 'caine' 'parrot-security' 'sift-workstation' 'paladin' 'tsurugi-acquire' 'tsurugi-linux')
	ExtrasNames=('SystemRescue' 'GParted Live' 'Clonezilla Live' 'Rescuezilla' 'Memtest86+' 'Hiren'\''s BootCD PE' 'Ubuntu Desktop LTS' 'Windows 11 installation media' 'Linux Mint Cinnamon' 'Debian Live KDE' 'ShredOS (nwipe)' 'Windows 10 installation media' 'CAINE' 'Parrot Security' 'SANS SIFT Workstation' 'SUMURI PALADIN' 'Tsurugi Acquire' 'Tsurugi Linux LAB')
	ExtrasVersions=('13.02' '1.8.1-6' '3.1.2-9' '2.6.2' '8.10' '1.0.8' '24.04.5.1' 'current' '22.3' '13.7.0' '2025.11 / nwipe 0.42' '22H2' '14.0' '7.3' 'current' 'current' '2021.1' '26.03')
	ExtrasCategories=('Rescue' 'Partition_and_Imaging' 'Partition_and_Imaging' 'Partition_and_Imaging' 'Diagnostics' 'Windows_Rescue' 'Live_Linux' 'Windows_Install' 'Live_Linux' 'Live_Linux' 'Disk_Wipe' 'Windows_Install' 'Forensics' 'Forensics' 'Forensics' 'Forensics' 'Forensics' 'Forensics')
	ExtrasTargets=('linux,windows' 'linux,windows' 'linux,windows' 'linux,windows' 'linux,windows' 'windows' 'linux' 'windows' 'linux' 'linux' 'linux,windows' 'windows' 'linux,windows' 'linux,windows' 'linux,windows' 'linux,windows' 'linux,windows' 'linux,windows')
	ExtrasTypes=('iso' 'iso' 'iso' 'iso' 'iso' 'iso' 'iso' 'manual' 'iso' 'iso' 'iso' 'manual' 'iso' 'iso' 'manual' 'manual' 'iso' 'iso')
	ExtrasUrls=('https://fastly-cdn.system-rescue.org/releases/13.02/systemrescue-13.02-amd64.iso' 'https://downloads.sourceforge.net/gparted/gparted-live-1.8.1-6-amd64.iso' 'https://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/3.1.2-9/clonezilla-live-3.1.2-9-amd64.iso' 'https://github.com/rescuezilla/rescuezilla/releases/download/2.6.2/rescuezilla-2.6.2-64bit.noble.iso' 'https://www.memtest.org/download/v8.10/mt86plus_8.10_x86_64.iso.zip' 'https://www.hirensbootcd.org/files/HBCD_PE_x64.iso' 'https://releases.ubuntu.com/24.04/ubuntu-24.04.5.1-desktop-amd64.iso' 'https://www.microsoft.com/software-download/windows11' 'https://mirrors.edge.kernel.org/linuxmint/stable/22.3/linuxmint-22.3-cinnamon-64bit.iso' 'https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.7.0-amd64-kde.iso' 'https://github.com/PartialVolume/shredos.x86_64/releases/download/v2025.11_31_x86-64_0.42/shredos-2025.11_31_x86-64_v0.42_20260716.iso' 'https://www.microsoft.com/software-download/windows10ISO' 'https://www.caine-live.net/Downloads/caine14.0.iso' 'https://deb.parrot.sh/parrot/iso/7.3/Parrot-security-7.3_amd64.iso' 'https://www.sans.org/tools/sift-workstation/' 'https://sumuri.com/paladin/' 'https://ftp.nluug.nl/os/Linux/distr/tsurugi/02.Tsurugi_Acquire/tsurugi_acquire_2021.1.iso' 'https://mirrors.gandi.net/tsurugi/01.Tsurugi_Linux_%5BLAB%5D/tsurugi_linux_26.03.iso')
	ExtrasFileNames=('systemrescue-13.02-amd64.iso' 'gparted-live-1.8.1-6-amd64.iso' 'clonezilla-live-3.1.2-9-amd64.iso' 'rescuezilla-2.6.2-64bit.noble.iso' 'mt86plus_8.10_x86_64.iso' 'HBCD_PE_x64.iso' 'ubuntu-24.04.5.1-desktop-amd64.iso' 'Win11.iso' 'linuxmint-22.3-cinnamon-64bit.iso' 'debian-live-13.7.0-amd64-kde.iso' 'shredos-2025.11_31_x86-64_v0.42_20260716.iso' 'Win10_22H2.iso' 'caine14.0.iso' 'Parrot-security-7.3_amd64.iso' 'SIFT-Workstation.ova' 'paladin.iso' 'tsurugi_acquire_2021.1.iso' 'tsurugi_linux_26.03.iso')
	ExtrasBytes=('1381629952' '720371712' '437256192' '1594339328' '233712' '3291686912' '6250332160' '0' '3091660800' '4186112000' '360710144' '0' '4169138176' '8555526144' '0' '0' '1215299584' '11786315776')
	ExtrasSha256=('ad4d670b72859d887c7960142a9a9d36a3e50446694a035e254442f65d6e7572' 'd789c38779f0d6f7026c12f44c2c52a04f66e28a1aea7d51f3045ad1bbf28411' '' '285db0af83213e2297490ca1cfd74ecd607c3b0a2f1d14e11a8412c0b71eea50' '93530005d6ac6a85aa2a49c68604a43c25794ecccf796c4f8849a73a8001be9a' '8c4c670c9c84d6c4b5a9c32e0aa5a55d8c23de851d259207d54679ea774c2498' '4da4a0c9035da8e68a59a838674f403f0a54472c78a83b4fb7f78d03588f85a7' '' 'a081ab202cfda17f6924128dbd2de8b63518ac0531bcfe3f1a1b88097c459bd4' '37dedc921f50325665c75829597126b3eeb70ff5cd8c511a7230ace09ae939be' '' '' '2702226cf9ee131ee54e9649d6d90008f3fe851ba35939f43ae8cb614a00d564' 'fe8ec64f92d8d629b1fcae85d9fab81c87e3ff30584201e82b7c453a740cefbc' '' '' '' '')
	ExtrasSha512=('' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' 'bd5488e9e75bbcbc6560d166031e84c70bf19c1b9db6f872df99212fef110296c3e7735e39bdee533aaaa92a64e1096fb674b1d45dd4c88cde280442737d77fe' '1284c3b4145ef2201e831350fde20a1445171be66ca34ab909cbd22eb77d5f19ec28a26275955538bddf7abb77ec5ac0c05f3383502c2ac83770150be1c31d8c')
	ExtrasSha1=('' '' '' '' '' '' '' '' '' '' 'ef4b41f95f96b2bc80ee3fbe2e9ca9ea51750569' '' '' '' '' '' '' '')
	ExtrasMd5=('' '' '99353cf50559fe8e5450643a764f0f57' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '')
	ExtrasUnpackFormat=('' '' '' '' 'zip' '' '' '' '' '' '' '' '' '' '' '' '' '')
	ExtrasUnpackMember=('' '' '' '' 'memtest.iso' '' '' '' '' '' '' '' '' '' '' '' '' '')
	ExtrasHomepages=('https://www.system-rescue.org/' 'https://gparted.org/' 'https://clonezilla.org/' 'https://rescuezilla.com/' 'https://www.memtest.org/' 'https://www.hirensbootcd.org/' 'https://ubuntu.com/download/desktop' 'https://www.microsoft.com/software-download/windows11' 'https://linuxmint.com/' 'https://www.debian.org/CD/live/' 'https://github.com/PartialVolume/shredos.x86_64' 'https://www.microsoft.com/software-download/windows10ISO' 'https://www.caine-live.net/' 'https://www.parrotsec.org/' 'https://www.sans.org/tools/sift-workstation/' 'https://sumuri.com/paladin/' 'https://tsurugi-linux.org/' 'https://tsurugi-linux.org/')
	ExtrasLicenses=('GPL-2.0-or-later (Arch-based live system, mixed licenses)' 'GPL-2.0-or-later' 'GPL-2.0' 'GPL-3.0' 'GPL-2.0' 'Freeware; bundled tools keep their own licenses' 'Mixed open source' 'Proprietary (Microsoft); download from Microsoft only' 'Mixed open source' 'Mixed open source (DFSG)' 'GPL-2.0' 'Proprietary (Microsoft); download from Microsoft only' 'GPL-3.0 (Ubuntu-based live system, mixed licenses)' 'GPL-3.0 (Debian-based, mixed licenses)' 'Free for use; download requires a SANS account' 'Free edition; download requires registration' 'Free to use (Ubuntu-based, mixed licenses)' 'Free to use (Ubuntu-based, mixed licenses)')
	ExtrasDescriptions=('Arch-based rescue system with disk, network and recovery tools for Linux and Windows machines.' 'Resize, move, copy and check partitions (NTFS, ext4, exFAT, FAT, btrfs and more).' 'Disk and partition imaging and cloning, sector-level or filesystem-aware.' 'Point-and-click backup and restore, compatible with Clonezilla images.' 'Stand-alone RAM tester for BIOS and UEFI machines.' 'Windows 11 PE based repair environment with password, driver, backup and diagnostics tools.' 'Live desktop and installer; handy for rescuing files from a Linux or Windows disk with a full GUI.' 'Microsoft issues time-limited download links, so fetch the ISO from the Microsoft page and copy it into Extras/Windows_Install/ on the stick.' 'Beginner-friendly live desktop and installer; the usual choice when a Windows PC is being moved to Linux.' 'Debian stable live desktop with the Calamares installer. The current-live URL moves at each point release, so bump the version when it 404s.' 'Boots straight into nwipe to securely erase disks (DoD, PRNG, verify) before a machine is sold or recycled. The project publishes SHA-1 only.' 'Still needed for machines that cannot run Windows 11. Microsoft issues time-limited links, so fetch the ISO from the Microsoft page and copy it into Extras/Windows_Install/ on the stick.' 'Computer Aided INvestigative Environment: boots with all disks read-only, with Autopsy, Guymager, PhotoRec and other acquisition and analysis tools. For authorized investigations and data recovery.' 'Security and forensics live system with a dedicated forensic boot mode (no automount, no swap) plus the usual pentest and analysis toolset. Large image.' 'DFIR toolkit (Plaso, Volatility, Sleuth Kit and more). SANS only offers it behind a login as a VM image or an Ubuntu install script, so fetch it from the SANS page; it is not a bootable ISO.' 'Forensic boot ISO with a write-blocked imager and disk tools. SUMURI issues the download after registration, so fetch it from their page and copy the ISO into Extras/Forensics/.' 'Small Tsurugi image built for evidence acquisition: boots read-only and images disks with Guymager, dc3dd and ewfacquire. The project publishes SHA-512 only.' 'Full DFIR lab live system (memory, disk, network and malware analysis, OSINT). Very large image; Tsurugi Acquire covers the acquisition part alone.')
}
# END GENERATED SPEC
loadSpec

# Variables

# Exit codes shared with the Windows CLI (see CLI.md).
ExitOk=0
ExitError=1
ExitBadArgs=2
ExitCancelled=4
ExitVerifyFailed=5

# Options (set by command-line flags; interactive prompts fill the gaps).
Mode="interactive"        # interactive | install | verify | extras
TargetDisk=""             # /dev/sdX (whole disk)
TargetPath=""             # already-mounted MediCat directory (--verify / --extras only)
ArchiveOverride=""
DownloadMethod=""         # direct | torrent | local
AssumeYes=false
AllowFixed=false
UseGpt=false
SecureBoot="$VentoyDefaultSecureBoot"
VentoyVersionArg="$VentoyPinnedVersion"
VentoyTarArg=""
Offline=false
LogFile=""
ReExtract=true
ExtrasArg=""              # all | none | id,id,...
FsType="$MedicatDataFs"   # ntfs | exfat
SkipArchiveHash=false
ManifestOverride=""
WorkDir="$PWD"

Medicat7zFull="${Medicat7zTorrentSubdir}/${Medicat7zFile}"
MedicatSplitFirst="${MedicatSplitBase}.001"
needMedicatDownload=false
location=""
# solid7z | splitzip
archiveKind=""
VerifyFailedCount=0
VerifyResult=""           # ok | failed | skipped
FailedListFile=""
MedicatMount=""
MountedByUs=false

# Dependencies: package names per distro for each required command.
declare -A depCommands=(
	[wget]="wget" [7z]="zip" [mkfs.vfat]="mkfs" [mkntfs]="ntfs" [mkfs.exfat]="exfat" [parted]="parted"
)
# mkntfs lives in ntfsprogs on RHEL-family and Arch (split from ntfs-3g in 2026); Debian, Ubuntu,
# Alpine and Void still ship it inside ntfs-3g. Bookworm+ and Ubuntu get mkfs.exfat from exfatprogs.
# shellcheck disable=SC2034  # looked up by name through declare -n in dependenciesHandler
declare -A wget=([nixos]="nixos.wget" [default]="wget") \
	zip=([arch]="p7zip" [cachyos]="p7zip" [nixos]="nixos.p7zip" [fedora]="p7zip p7zip-plugins" [nobara]="p7zip-full p7zip-plugins" [centos]="p7zip p7zip-plugins" [alpine]="7zip" [void]="7zip" [default]="p7zip-full") \
	mkfs=([nixos]="nixos.dosfstools" [default]="dosfstools") \
	ntfs=([centos]="ntfsprogs" [fedora]="ntfsprogs" [arch]="ntfsprogs" [cachyos]="ntfsprogs" [nixos]="nixos.ntfs3g" [default]="ntfs-3g") \
	aria=([nixos]="nixos.aria" [default]="aria2") \
	ventoy=([nixos]="nixos.ventoy-full" [default]="ventoy") \
	parted=([default]="parted") \
	exfat=([ubuntu]="exfatprogs" [debian]="exfatprogs" [fedora]="exfatprogs" [centos]="exfatprogs" [arch]="exfatprogs" [cachyos]="exfatprogs" [alpine]="exfatprogs" [void]="exfatprogs" [default]="exfatprogs")

# Other Variables
sudo="sudo" # By default use sudo with package manager
ventoyFS=true  # By default install ventoy from github(FromSource)
ventoyLauncher="sh ./Ventoy2Disk.sh" # By default use the ventoy script

# Colour / terminal (never name the reset var "clear" — masks /usr/bin/clear)
ansiReset=""
redB=""; greenB=""; yellowB=""; blueB=""; cyanB=""; whiteB=""

NumColours=$(tput colors 2>/dev/null || echo 0)
if [[ -n "$NumColours" && "$NumColours" -ge 8 ]]; then
	ansiReset="$(tput sgr0 2>/dev/null || true)"
	redB="$(tput bold 2>/dev/null; tput setaf 1 2>/dev/null || true)"
	greenB="$(tput bold 2>/dev/null; tput setaf 2 2>/dev/null || true)"
	yellowB="$(tput bold 2>/dev/null; tput setaf 3 2>/dev/null || true)"
	blueB="$(tput bold 2>/dev/null; tput setaf 4 2>/dev/null || true)"
	cyanB="$(tput bold 2>/dev/null; tput setaf 6 2>/dev/null || true)"
	whiteB="$(tput bold 2>/dev/null; tput setaf 7 2>/dev/null || true)"
fi

# Debian/Ubuntu omit /sbin from a normal user's PATH (#175).
# mkntfs, mkfs.vfat, mkfs.exfat, and parted live under /usr/sbin.
for _sbinDir in /usr/local/sbin /usr/sbin /sbin; do
	if [[ -d "$_sbinDir" ]]; then
		case ":$PATH:" in
			*":${_sbinDir}:"*) ;;
			*) PATH="${PATH}:${_sbinDir}" ;;
		esac
	fi
done
unset _sbinDir
export PATH

# Functions

# Append one plain-text line to the session log (no-op until --log or the default log is set).
function logLine() {
	[[ -n "$LogFile" ]] || return 0
	printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LogFile" 2>/dev/null || true
}

# Print optional colour + message. Always treats args as data (never exec).
# Usage: colEcho "plain text"
#        colEcho "$cyanB" "coloured text with ${whiteB}embeds"
function colEcho() {
	local text
	if [[ $# -ge 2 ]]; then
		text="${1}${2}${ansiReset}"
	else
		text="${1-}${ansiReset}"
	fi
	printf '%b\n' "$text"
	if [[ -n "$LogFile" ]]; then
		local plain
		plain=$(printf '%b' "$text" | sed -E $'s/\e\\[[0-9;]*[A-Za-z]//g')
		logLine "$plain"
	fi
}

# Open interactive input: always prefer /dev/tty so pipes / curl|bash / leftover
# stdin never make keypress prompts return immediately empty.
# Sets global _promptFd (0 = stdin, or an open fd number). Call promptClose after.
_promptFd=0
function promptOpen() {
	_promptFd=0
	if [[ -r /dev/tty ]]; then
		exec 3</dev/tty
		_promptFd=3
	fi
}
function promptClose() {
	if [[ "${_promptFd:-0}" -ne 0 ]]; then
		exec 3<&-
		_promptFd=0
	fi
}

# Function to wait for a user keypress (real terminal, not redirected stdin).
function UserWait() {
	local promptText="${1:-Press any key to continue}"
	if $AssumeYes; then
		return 0
	fi
	promptOpen
	# Prompt on stderr so it still shows if stdout is piped; read one key from TTY.
	printf '%s' "$promptText" >&2
	if ! read -n 1 -s -r <&"$_promptFd"; then
		promptClose
		colEcho $redB "ERROR: Failed to read keypress (EOF). Exiting..." >&2
		exit $ExitError
	fi
	printf '\r                         \r' >&2
	promptClose
}

# Function to ask a Yes/No question.
# Returns 0 for Yes, 1 for No. Exit 1 on unrecoverable input failure.
# Prefer: if YesNo "prompt? (Y/N) "; then ...
function YesNo() {
	local setCheck=""
	promptOpen

	while true; do
		if ! read -r -p "$1" setCheck <&"$_promptFd"; then
			promptClose
			colEcho $redB "ERROR: Failed to read input (EOF). Exiting..." >&2
			exit $ExitError
		fi

		# Strip CR (Windows / paste) and surrounding whitespace.
		setCheck="${setCheck//$'\r'/}"
		setCheck="${setCheck#"${setCheck%%[![:space:]]*}"}"
		setCheck="${setCheck%"${setCheck##*[![:space:]]}"}"

		case "$setCheck" in
			[Yy]|[Yy][Ee][Ss])
				promptClose
				logLine "prompt: $1 -> yes"
				return 0
				;;
			[Nn]|[Nn][Oo])
				promptClose
				logLine "prompt: $1 -> no"
				return 1
				;;
			*)
				colEcho $redB "Invalid input. Please enter 'Y' or 'N'." >&2
				;;
		esac
	done
}

# Yes/No that --yes answers automatically (for confirmations, not for data entry).
function confirm() {
	if $AssumeYes; then
		logLine "prompt: $1 -> yes (--yes)"
		return 0
	fi
	YesNo "$1"
}

# Read a line from the real terminal (prefer /dev/tty; never skip on empty stdin).
function ReadPrompt() {
	local __prompt="$1"
	local __resultVar="$2"
	local __line=""

	promptOpen
	if ! read -r -p "$__prompt" __line <&"$_promptFd"; then
		promptClose
		colEcho $redB "ERROR: Failed to read input (EOF). Exiting..." >&2
		exit $ExitError
	fi
	promptClose

	__line="${__line//$'\r'/}"
	printf -v "$__resultVar" '%s' "$__line"
}

# Warn if running as root/sudo; allow continue with confirmation.
# As root, clear $sudo so package/privilege calls do not require the sudo binary.
function CheckNotElevated {
    if (( "$EUID" == "0" )); then
        colEcho $redB "WARNING: Running as root (or via sudo)."
        colEcho $yellowB "This script is meant to run as a normal user and elevate only when needed."
        colEcho $yellowB "Running fully as root can break package installs, file ownership, or Ventoy paths."
        if ! confirm "Continue anyway? Things may break. (Y/N) "; then
            colEcho $cyanB "Exiting. Re-run without sudo/root if possible."
            exit $ExitError
        fi
        sudo=""
        colEcho $yellowB "Continuing as root (elevation prefix disabled).\n"
    fi
}

# True if $1 is on PATH or executable in a common sbin directory (#175).
function commandExists() {
	local cmd="$1"
	local dir
	if command -v "$cmd" >/dev/null 2>&1; then
		return 0
	fi
	for dir in /usr/local/sbin /usr/sbin /sbin; do
		if [[ -x "${dir}/${cmd}" ]]; then
			return 0
		fi
	done
	return 1
}

# Human-readable size from byte count (approx GiB/MiB).
function humanBytes() {
	local bytes="${1:-0}"
	if (( bytes >= 1024 * 1024 * 1024 )); then
		awk -v b="$bytes" 'BEGIN { printf "%.1f GiB", b / (1024*1024*1024) }'
	elif (( bytes >= 1024 * 1024 )); then
		awk -v b="$bytes" 'BEGIN { printf "%.1f MiB", b / (1024*1024) }'
	else
		printf "%s B" "$bytes"
	fi
}

function usage() {
	local sbDefault="off"
	[[ "$VentoyDefaultSecureBoot" == "true" ]] && sbDefault="on"
	cat <<USAGE
MediCat USB installer for Linux (script ${ScriptVersion}, MediCat ${MedicatVersion})

Usage: Medicat_Installer.sh [options]
       Medicat_Installer.sh --install --drive /dev/sdX [--yes] [options]
       Medicat_Installer.sh --verify  (--drive /dev/sdX | --path DIR) [options]
       Medicat_Installer.sh --extras LIST (--drive /dev/sdX | --path DIR)

Without --install/--verify/--extras the installer runs interactively.

Actions:
  --install                 Install Ventoy, format, extract MediCat, verify, offer extras
  --verify                  MD5-verify an existing MediCat stick against the manifest
  --extras LIST             Download extra boot images: all, none, ask or ids (see --list-extras)
  --list-extras             Print the extras catalog and exit
  --dump-spec               Print the shared spec values (mirrors, hashes, sizes) and exit
  --help, --version

Target:
  --drive /dev/sdX          Whole USB disk (or sdX). Prompted when omitted
  --path DIR                Already-mounted MediCat folder (--verify / --extras only)
  --allow-fixed             Accept a non-USB disk without the typed CONFIRM prompt

Install options:
  --archive FILE            Path to ${Medicat7zFile} or ${MedicatSplitFirst}
  --download direct|torrent How to fetch the archive when it is not on disk
  --fs ntfs|exfat           Data partition filesystem (default ${MedicatDataFs})
  --label NAME              Data partition label (default ${MedicatDataLabel})
  --gpt | --mbr             Ventoy partition style (default ${VentoyDefaultPartitionStyle})
  --secure-boot | --no-secure-boot
                            Ventoy Secure Boot support (default ${sbDefault})
  --ventoy-version X.Y.Z    Pin a Ventoy release instead of the latest
  --ventoy-tar FILE         Use a local ventoy-X.Y.Z-linux.tar.gz (implies no download)
  --offline                 Never download Ventoy, the archive or the manifest
  --no-reextract            Do not re-extract files that fail verification
  --skip-archive-hash       Skip the archive SHA-256 check (custom or repacked archives)
  --manifest FILE           Use this ${MedicatManifestFile} instead of downloading it

General:
  --yes, -y                 Accept the wipe confirmation and other prompts
  --work-dir DIR            Where downloads, Ventoy and logs live (default: current directory)
  --log FILE                Session log (default: medicat_installer.log in the work dir)

Exit codes: 0 ok, 1 error, 2 bad arguments, 4 cancelled, 5 verify found failures
USAGE
}

function printVersion() {
	printf 'Medicat_Installer.sh %s (MediCat %s, spec %s, extras catalog %s)\n' \
		"$ScriptVersion" "$MedicatVersion" "$SpecVersion" "$ExtrasCatalogVersion"
}

function dumpSpec() {
	local name
	for name in SpecVersion MedicatVersion Medicat7zFile Medicat7zBytes Medicat7zMinBytes Medicat7zMd5 Medicat256Hash \
		MedicatSplitBase MedicatSplitFiles MedicatSplitSizes MedicatSplitMd5s MedicatMirrorNames MedicatMirrorUrls \
		MedicatMirrorInsecure MedicatTorrentUrl MedicatMagnetUrl MedicatManifestFile MedicatManifestUrls \
		MedicatManifestFileCount MedicatExtractedBytes MedicatUsbMinBytes MedicatUsbRecommendedBytes MedicatDataLabel \
		MedicatDataFs MedicatDownloadMinFreeBytes MedicatWorkMinFreeBytes MedicatUsbMinFreeBytes VentoyKnownGoodVersion \
		VentoyPinnedVersion VentoyDefaultPartitionStyle VentoyDefaultSecureBoot VentoyReleaseApi \
		VentoyLinuxTarUrlTemplate UpdateRepository UpdateChecksumsAsset ExtrasCatalogVersion ExtrasDestRoot ExtrasIds; do
		declare -p "$name" 2>/dev/null | sed 's/^declare -[-aA] //'
	done
}

function listExtras() {
	local i
	printf 'Extras catalog %s (files land in <stick>/%s/<category>/)\n\n' "$ExtrasCatalogVersion" "$ExtrasDestRoot"
	printf '%-20s %-30s %-10s %-10s %-14s %s\n' "ID" "NAME" "VERSION" "SIZE" "FOR" "CATEGORY"
	for i in "${!ExtrasIds[@]}"; do
		local size="manual"
		if [[ "${ExtrasTypes[$i]}" == "iso" ]]; then
			size=$(humanBytes "${ExtrasBytes[$i]}")
		fi
		printf '%-20s %-30s %-10s %-10s %-14s %s\n' "${ExtrasIds[$i]}" "${ExtrasNames[$i]}" "${ExtrasVersions[$i]}" \
			"$size" "${ExtrasTargets[$i]}" "${ExtrasCategories[$i]}"
	done
	printf '\n'
	for i in "${!ExtrasIds[@]}"; do
		printf '%s: %s\n    %s\n' "${ExtrasIds[$i]}" "${ExtrasDescriptions[$i]}" "${ExtrasHomepages[$i]}"
	done
}

function needArgValue() {
	if [[ -z "$2" || "$2" == --* ]]; then
		badArgs "$1 needs a value"
	fi
}

function badArgs() {
	printf 'ERROR: %s\n' "$1" >&2
	printf 'Run with --help for usage.\n' >&2
	exit $ExitBadArgs
}

# Resolve an extras id to its catalog index (prints index, returns 1 when unknown).
function extrasIndex() {
	local i
	for i in "${!ExtrasIds[@]}"; do
		if [[ "${ExtrasIds[$i]}" == "$1" ]]; then
			printf '%s\n' "$i"
			return 0
		fi
	done
	return 1
}

# Validate "all", "none", "ask" or a comma list of ids.
function validateExtrasSelection() {
	local selection="$1"
	local id
	local -a ids=()
	case "$selection" in
		all|none|ask) return 0 ;;
	esac
	IFS=',' read -r -a ids <<< "$selection"
	for id in "${ids[@]}"; do
		id="${id// /}"
		[[ -z "$id" ]] && continue
		if ! extrasIndex "$id" >/dev/null; then
			printf 'ERROR: Unknown extras id: %s (see --list-extras)\n' "$id" >&2
			return 1
		fi
	done
	return 0
}

# Turn --flag=value into --flag value, then walk the list.
function parseArgs() {
	local -a args=()
	local arg
	for arg in "$@"; do
		if [[ "$arg" == --*=* ]]; then
			args+=("${arg%%=*}" "${arg#*=}")
		else
			args+=("$arg")
		fi
	done

	set -- "${args[@]}"
	while [[ $# -gt 0 ]]; do
		case "$1" in
			-h|--help)
				usage
				exit $ExitOk
				;;
			-V|--version)
				printVersion
				exit $ExitOk
				;;
			--list-extras)
				listExtras
				exit $ExitOk
				;;
			--dump-spec)
				dumpSpec
				exit $ExitOk
				;;
			--install)
				Mode="install"
				;;
			--verify)
				Mode="verify"
				;;
			--extras)
				needArgValue "$1" "${2-}"
				ExtrasArg="$2"
				shift
				;;
			--drive|--disk)
				needArgValue "$1" "${2-}"
				TargetDisk="$2"
				shift
				;;
			--path)
				needArgValue "$1" "${2-}"
				TargetPath="$2"
				shift
				;;
			--archive)
				needArgValue "$1" "${2-}"
				ArchiveOverride="$2"
				shift
				;;
			--download)
				needArgValue "$1" "${2-}"
				case "$2" in
					direct|torrent) DownloadMethod="$2" ;;
					*) badArgs "--download expects direct or torrent" ;;
				esac
				shift
				;;
			--fs)
				needArgValue "$1" "${2-}"
				case "$2" in
					ntfs|exfat) FsType="$2" ;;
					*) badArgs "--fs expects ntfs or exfat" ;;
				esac
				shift
				;;
			--label)
				needArgValue "$1" "${2-}"
				MedicatDataLabel="$2"
				shift
				;;
			--gpt) UseGpt=true ;;
			--mbr) UseGpt=false ;;
			--secure-boot) SecureBoot=true ;;
			--no-secure-boot|--nosb) SecureBoot=false ;;
			--ventoy-version)
				needArgValue "$1" "${2-}"
				VentoyVersionArg="${2#v}"
				if [[ ! "$VentoyVersionArg" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
					badArgs "--ventoy-version expects X.Y.Z"
				fi
				shift
				;;
			--ventoy-tar)
				needArgValue "$1" "${2-}"
				VentoyTarArg="$2"
				shift
				;;
			--offline) Offline=true ;;
			--manifest)
				needArgValue "$1" "${2-}"
				ManifestOverride="$2"
				shift
				;;
			--no-reextract) ReExtract=false ;;
			--skip-archive-hash) SkipArchiveHash=true ;;
			--allow-fixed) AllowFixed=true ;;
			--work-dir)
				needArgValue "$1" "${2-}"
				WorkDir="$2"
				shift
				;;
			--log)
				needArgValue "$1" "${2-}"
				LogFile="$2"
				shift
				;;
			-y|--yes) AssumeYes=true ;;
			*)
				badArgs "Unknown option: $1"
				;;
		esac
		shift
	done

	if [[ -n "$ExtrasArg" && "$Mode" == "interactive" ]]; then
		Mode="extras"
	fi
	if [[ -n "$TargetPath" && "$Mode" != "verify" && "$Mode" != "extras" ]]; then
		badArgs "--path only applies to --verify and --extras"
	fi
	if [[ -n "$TargetPath" && -n "$TargetDisk" ]]; then
		badArgs "Use either --drive or --path, not both"
	fi
	if [[ -n "$TargetPath" && ! -d "$TargetPath" ]]; then
		badArgs "--path is not a directory: $TargetPath"
	fi
	if [[ -n "$ArchiveOverride" && ! -f "$ArchiveOverride" ]]; then
		badArgs "--archive file not found: $ArchiveOverride"
	fi
	if [[ -n "$VentoyTarArg" && ! -f "$VentoyTarArg" ]]; then
		badArgs "--ventoy-tar file not found: $VentoyTarArg"
	fi
	if [[ -n "$ManifestOverride" && ! -f "$ManifestOverride" ]]; then
		badArgs "--manifest file not found: $ManifestOverride"
	fi
	if $Offline && [[ -n "$DownloadMethod" ]]; then
		badArgs "--offline and --download contradict each other"
	fi
	if [[ -n "$ExtrasArg" ]]; then
		validateExtrasSelection "$ExtrasArg" || exit $ExitBadArgs
	fi
	if [[ "$Mode" == "extras" && "$ExtrasArg" == "none" ]]; then
		badArgs "--extras none does nothing without --install"
	fi
	if [[ -n "$TargetDisk" ]]; then
		TargetDisk="${TargetDisk#/dev/}"
		TargetDisk="/dev/${TargetDisk}"
	fi
	if [[ ! -d "$WorkDir" ]]; then
		badArgs "--work-dir is not a directory: $WorkDir"
	fi
	WorkDir=$(cd "$WorkDir" && pwd)
	for arg in ArchiveOverride VentoyTarArg ManifestOverride TargetPath; do
		if [[ -n "${!arg}" && "${!arg}" != /* ]]; then
			printf -v "$arg" '%s' "$(cd "$(dirname -- "${!arg}")" && pwd)/$(basename -- "${!arg}")"
		fi
	done
	if [[ -z "$LogFile" ]]; then
		LogFile="$WorkDir/medicat_installer.log"
	fi
}

# Function to handle dependecies list
function dependenciesHandler() {
	local toInstall=()
	local command pkg
	local failedPkgs=()

	# Check what is missing before refreshing package indexes (#139).
	# apt update / pacman -Syy / etc. are slow and unnecessary when everything is present.
	for command in "${!depCommands[@]}"; do
		if ! commandExists "$command"; then
			declare -n ref="${depCommands[$command]}"
			local pkgList
			if [ -z "${ref[$os]}" ]; then
				pkgList="${ref['default']}"
			else
				pkgList="${ref[$os]}"
			fi
			# Expand multi-package entries (e.g. "p7zip p7zip-plugins") into one-by-one installs
			# shellcheck disable=SC2206
			local pkgs=( $pkgList )
			for pkg in "${pkgs[@]}"; do
				toInstall+=("$pkg")
			done
		fi
	done

	if (( ${#toInstall[@]} == 0 )); then
		colEcho $cyanB "All dependencies are already installed.\n"
		return 0
	fi

	if [ "$os" == "unknown" ]; then
		colEcho $redB "ERROR: Distro is unknown and some dependencies were not found."
		colEcho $redB "Please install the following packages manually:$whiteB ${toInstall[*]}"
		exit $ExitError
	fi

	colEcho $cyanB "Refreshing package indexes ($pkgmgr $update_arg)..."
	# shellcheck disable=SC2086
	$sudo $pkgmgr $update_arg

	colEcho $cyanB "The following dependencies will be installed (one at a time):$whiteB ${toInstall[*]}"
	UserWait
	for pkg in "${toInstall[@]}"; do
		colEcho $cyanB "Installing$whiteB $pkg$cyanB..."
		# shellcheck disable=SC2086
		if ! $sudo $pkgmgr $install_arg $pkg; then
			colEcho $yellowB "WARNING: Failed to install $pkg - continuing with remaining packages."
			failedPkgs+=("$pkg")
		fi
	done
	if (( ${#failedPkgs[@]} > 0 )); then
		colEcho $yellowB "Some packages failed:$whiteB ${failedPkgs[*]}"
	fi

	# Arch/CachyOS/Fedora/CentOS split mkntfs into ntfsprogs. Debian/Ubuntu still
	# ship it in ntfs-3g; do not try to apt-install a package that no longer exists (#175).
	if [[ -n "${depCommands[mkntfs]-}" ]] && ! commandExists mkntfs; then
		case "$os" in
			arch|cachyos|fedora|centos)
				if [[ " ${toInstall[*]} " != *" ntfsprogs "* ]]; then
					colEcho $cyanB "Installing$whiteB ntfsprogs$cyanB (provides mkntfs)..."
					# shellcheck disable=SC2086
					if ! $sudo $pkgmgr $install_arg ntfsprogs; then
						colEcho $yellowB "WARNING: Failed to install ntfsprogs - continuing."
						failedPkgs+=("ntfsprogs")
					fi
				fi
				;;
		esac
	fi

	# Only hard-fail for commands that are still missing after best-effort install.
	local stillMissing=""
	for command in "${!depCommands[@]}"; do
		if ! commandExists "$command"; then
			stillMissing+=" $command"
		fi
	done
	if [ -n "$stillMissing" ]; then
		colEcho $redB "ERROR: Required commands still missing after install:$whiteB$stillMissing"
		if [[ "$stillMissing" == *" mkntfs"* ]]; then
			case "$os" in
				arch|cachyos|fedora|centos)
					colEcho $yellowB "mkntfs comes from ntfsprogs on Arch/Fedora (not from ntfs-3g)."
					;;
				debian|ubuntu)
					colEcho $yellowB "mkntfs comes from ntfs-3g on Debian/Ubuntu. If it is already installed, /usr/sbin may be missing from PATH."
					;;
			esac
		fi
		colEcho $redB "Install them manually (or install an equivalent package), then re-run this script."
		exit $ExitError
	fi
}

# Fetch a URL to stdout with wget or curl (small files only: API JSON, manifest).
function fetchText() {
	if command -v wget >/dev/null 2>&1; then
		wget -q -O - -- "$1"
	elif command -v curl >/dev/null 2>&1; then
		curl -fsSL -- "$1"
	else
		return 1
	fi
}

# Download $1 into directory $2 as file $3 (resumable; aria2c > wget > curl).
function fetchFile() {
	local url="$1"
	local dir="$2"
	local name="$3"
	if command -v aria2c >/dev/null 2>&1; then
		aria2c -x8 -s8 -k1M -c --file-allocation=none --summary-interval=15 --console-log-level=warn \
			-d "$dir" -o "$name" -- "$url"
	elif command -v wget >/dev/null 2>&1; then
		wget -c -O "$dir/$name" -- "$url"
	elif command -v curl >/dev/null 2>&1; then
		curl -L -C - -o "$dir/$name" -- "$url"
	else
		colEcho $redB "ERROR: aria2c, wget or curl is required to download $name"
		return 1
	fi
}

# Compare a file against sha256 ($2), sha512 ($3), sha1 ($4) or md5 ($5), whichever is given first.
function checksumOk() {
	local file="$1"
	local sha="$2"
	local sha512="${3-}"
	local sha1="${4-}"
	local md5="${5-}"
	local got
	if [[ -n "$sha" ]]; then
		got=$(sha256sum "$file" | awk '{print tolower($1)}')
		[[ "$got" == "$sha" ]]
	elif [[ -n "$sha512" ]]; then
		got=$(sha512sum "$file" | awk '{print tolower($1)}')
		[[ "$got" == "$sha512" ]]
	elif [[ -n "$sha1" ]]; then
		got=$(sha1sum "$file" | awk '{print tolower($1)}')
		[[ "$got" == "$sha1" ]]
	elif [[ -n "$md5" ]]; then
		got=$(md5sum "$file" | awk '{print tolower($1)}')
		[[ "$got" == "$md5" ]]
	else
		return 1
	fi
}

# Check a downloaded Ventoy tarball against the sha256.txt published with the same release.
function verifyVentoyTarball() {
	local tarUrl="$1"
	local tarFile="$2"
	local venver="$3"
	local sumsUrl="${tarUrl%/*}/sha256.txt"
	local expected
	expected=$(fetchText "$sumsUrl" 2>/dev/null | awk -v f="$(basename -- "$tarFile")" \
		'{ name = $2; sub(/^\*/, "", name); if (name == f) { print tolower($1); exit } }')
	if [[ ! "$expected" =~ ^[0-9a-f]{64}$ ]]; then
		colEcho $redB "ERROR: Could not read the SHA-256 for $tarFile from$whiteB $sumsUrl"
		colEcho $yellowB "Refusing to install an unverified Ventoy. Retry, or pass --ventoy-tar with a package you checked yourself."
		rm -f "$tarFile"
		exit $ExitError
	fi
	if ! checksumOk "$tarFile" "$expected" ""; then
		colEcho $redB "ERROR: SHA-256 mismatch for $tarFile (expected $expected)."
		rm -f "$tarFile"
		exit $ExitError
	fi
	colEcho $greenB "Ventoy $venver package verified against the release checksum list."
}

# Make sure ./ventoy holds an extracted Ventoy release (pinned, local tarball, cached or latest).
function prepareVentoy() {
	local wanted="$VentoyVersionArg"
	local localVer=""
	local venver=""
	local tarUrl=""
	local tarFile=""
	local extractedDir=""

	if [[ -d ./ventoy && -f ./ventoy/Ventoy2Disk.sh ]]; then
		localVer=$(tr -d '[:space:]' < ./ventoy/ventoy/version 2>/dev/null)
	fi

	if [[ -n "$VentoyTarArg" ]]; then
		tarFile="$VentoyTarArg"
		colEcho $cyanB "Using local Ventoy package:$whiteB $tarFile"
	elif [[ -n "$localVer" && ( "$localVer" == "$wanted" || ( -z "$wanted" && "$Offline" == "true" ) ) ]]; then
		colEcho $cyanB "Reusing extracted Ventoy$whiteB $localVer$cyanB in ./ventoy"
		return 0
	elif $Offline; then
		colEcho $redB "ERROR: --offline but no usable Ventoy in ./ventoy. Pass --ventoy-tar FILE."
		exit $ExitError
	else
		if [[ -z "$wanted" ]]; then
			colEcho $cyanB "\nLooking up latest Ventoy release..."
			local apiJson
			apiJson=$(fetchText "${VentoyReleaseApi}/latest" 2>/dev/null) || apiJson=""
			venver=$(printf '%s' "$apiJson" | grep -oE '"tag_name"[[:space:]]*:[[:space:]]*"[^"]+"' | head -n1 | cut -d'"' -f4)
			# Keep digits and dots only (strip leading v / junk). Avoid brittle ${venver: -6}.
			venver="${venver//[^0-9.]/}"
			if [[ -z "$venver" ]]; then
				colEcho $yellowB "WARNING: Could not read the latest Ventoy version from GitHub; using known-good $VentoyKnownGoodVersion."
				venver="$VentoyKnownGoodVersion"
			fi
		else
			venver="$wanted"
		fi

		if [[ -n "$localVer" && "$localVer" == "$venver" ]]; then
			colEcho $cyanB "Ventoy $venver is already extracted in ./ventoy"
			return 0
		fi

		tarUrl="${VentoyLinuxTarUrlTemplate//\{version\}/$venver}"
		tarFile="ventoy-${venver}-linux.tar.gz"
		colEcho $cyanB "\nDownloading Ventoy Version:$whiteB $venver"
		colEcho $cyanB "URL:$whiteB $tarUrl"
		rm -f "$tarFile"
		if ! fetchFile "$tarUrl" "." "$tarFile" || [[ ! -s "$tarFile" ]]; then
			colEcho $redB "ERROR: Failed to download Ventoy $venver."
			exit $ExitError
		fi
		verifyVentoyTarball "$tarUrl" "$tarFile" "$venver"
	fi

	colEcho $cyanB "\nExtracting Ventoy..."
	rm -rf ./ventoy
	# Entries are stored as ./ventoy-X.Y.Z/...; take the first real top-level directory.
	extractedDir=$(tar -tzf "$tarFile" 2>/dev/null | sed 's|^\./||' | awk -F/ 'NF && $1 != "." { print $1; exit }')
	if ! tar -xzf "$tarFile"; then
		colEcho $redB "ERROR: Failed to extract $tarFile"
		exit $ExitError
	fi
	if [[ -z "$extractedDir" || ! -f "$extractedDir/Ventoy2Disk.sh" ]]; then
		extractedDir=$(find . -maxdepth 1 -type d -name 'ventoy-*' | head -n1)
		extractedDir="${extractedDir#./}"
	fi
	if [[ -z "$extractedDir" || ! -f "$extractedDir/Ventoy2Disk.sh" ]]; then
		colEcho $redB "ERROR: Ventoy2Disk.sh is missing inside the extracted package $tarFile"
		exit $ExitError
	fi
	mv "$extractedDir" ventoy
	if [[ -z "$VentoyTarArg" ]]; then
		rm -f "$tarFile"
	fi
	colEcho $greenB "Ventoy$whiteB $(cat ./ventoy/ventoy/version 2>/dev/null)$greenB ready."
}

# Normalize a path that may be any of .zip.001-.006 (or a directory containing them) to the .001 volume.
# Prints the .001 path on success; returns 1 if not a usable split set.
function resolveSplitFirstVolume() {
	local input="$1"
	local dir=""
	local first=""
	local part

	if [[ -d "$input" ]]; then
		dir="${input%/}"
	elif [[ -f "$input" ]]; then
		dir=$(dirname -- "$input")
	else
		return 1
	fi

	first="${dir}/${MedicatSplitFirst}"
	if [[ ! -f "$first" ]]; then
		return 1
	fi

	for part in "${MedicatSplitFiles[@]}"; do
		if [[ ! -f "${dir}/${part}" ]]; then
			return 1
		fi
	done
	printf '%s\n' "$first"
	return 0
}

# Verify size + MD5 of all split volumes. Expects location = ...zip.001
function verifySplitArchive() {
	local dir
	local i part expectMd5 expectMin gotSize gotMd5
	dir=$(dirname -- "$location")

	colEcho $cyanB "Checking Google Drive / Mega split volumes (MD5)..."
	for i in "${!MedicatSplitFiles[@]}"; do
		part="${dir}/${MedicatSplitFiles[$i]}"
		expectMd5="${MedicatSplitMd5s[$i]}"
		# Allow 5% below expected size (same idea as the C++ installer).
		expectMin=$(( MedicatSplitSizes[i] * 95 / 100 ))
		if [[ ! -f "$part" ]]; then
			colEcho $redB "ERROR: Missing split volume:$whiteB $part"
			exit $ExitError
		fi
		gotSize=$(stat -c%s "$part" 2>/dev/null || stat -f%z "$part" 2>/dev/null || echo 0)
		if [[ "$gotSize" -lt "$expectMin" ]]; then
			colEcho $redB "ERROR: $part looks incomplete or truncated."
			colEcho $cyanB "Size is$whiteB $gotSize$cyanB bytes; expected about$whiteB ${MedicatSplitSizes[$i]}$cyanB."
			exit $ExitError
		fi
		if $SkipArchiveHash; then
			continue
		fi
		colEcho $cyanB "Hashing$whiteB $(basename -- "$part")$cyanB..."
		gotMd5=$(md5sum "$part" | awk '{print tolower($1)}')
		if [[ "$gotMd5" != "$expectMd5" ]]; then
			colEcho $redB "ERROR: MD5 mismatch for$whiteB $part"
			colEcho $cyanB "Got:$whiteB      $gotMd5"
			colEcho $cyanB "Expected:$whiteB $expectMd5"
			exit $ExitError
		fi
		colEcho $greenB "OK:$whiteB $(basename -- "$part")"
	done
	colEcho $greenB "All split volumes match. Safe to proceed..."
	colEcho $cyanB "7z will extract from$whiteB $location$cyanB (follows the other volumes automatically)."
}

# Mount the MediCat data partition (NTFS: ntfs3, ntfs, ntfs-3g; exFAT: exfat) as the current user.
# Fail hard if the mountpoint is not a real mount of $device so 7z never extracts
# into a plain local ./MedicatUSB directory (#81).
function mountMedicatVolume() {
	local device="$1"
	local mnt="$2"
	local fs="$3"
	local opts
	opts="rw,uid=$(id -u),gid=$(id -g),fmask=0111,dmask=0000"
	local attempt=""
	local mountedSource=""
	local -a attempts=()

	if [[ ! -b "$device" ]]; then
		colEcho $redB "ERROR: Not a block device:$whiteB $device"
		exit $ExitError
	fi
	mkdir -p "$mnt"

	# Clear a stale mount from a previous run.
	if mountpoint -q "$mnt" 2>/dev/null; then
		colEcho $yellowB "Unmounting existing mount at$whiteB $mnt$yellowB..."
		$sudo umount "$mnt" 2>/dev/null || true
	fi

	if [[ "$fs" == "exfat" ]]; then
		attempts=("exfat" "auto")
	else
		attempts=("ntfs3" "ntfs" "ntfs-3g" "auto")
	fi

	for attempt in "${attempts[@]}"; do
		colEcho $cyanB "Trying mount type:$whiteB $attempt"
		case "$attempt" in
			ntfs3)
				$sudo mount -t ntfs3 -o "$opts" "$device" "$mnt" 2>/dev/null || continue
				;;
			ntfs)
				$sudo mount -t ntfs -o "$opts" "$device" "$mnt" 2>/dev/null || continue
				;;
			ntfs-3g)
				if ! command -v ntfs-3g >/dev/null 2>&1; then
					continue
				fi
				$sudo ntfs-3g -o "$opts" "$device" "$mnt" 2>/dev/null || continue
				;;
			exfat)
				$sudo mount -t exfat -o "$opts" "$device" "$mnt" 2>/dev/null || continue
				;;
			auto)
				$sudo mount -o "$opts" "$device" "$mnt" 2>/dev/null || continue
				;;
		esac

		if ! mountpoint -q "$mnt" 2>/dev/null; then
			# mount may have "succeeded" without binding; try next type
			$sudo umount "$mnt" 2>/dev/null || true
			continue
		fi

		mountedSource=$(findmnt -n -o SOURCE --target "$mnt" 2>/dev/null || true)
		# Accept exact device or a resolved path (e.g. /dev/sdb1).
		if [[ "$mountedSource" != "$device" ]] && [[ "$mountedSource" != "$(readlink -f "$device" 2>/dev/null || true)" ]]; then
			colEcho $yellowB "Mount at$whiteB $mnt$yellowB is$whiteB $mountedSource$yellowB, expected$whiteB $device$yellowB; trying next type..."
			$sudo umount "$mnt" 2>/dev/null || true
			continue
		fi

		colEcho $greenB "Mounted$whiteB $device$greenB at$whiteB $mnt$greenB (type$whiteB $attempt$greenB)."
		return 0
	done

	colEcho $redB "ERROR: Failed to mount$whiteB $device$redB at$whiteB $mnt"
	if [[ "$fs" == "exfat" ]]; then
		colEcho $yellowB "Install exfatprogs (or a kernel with exfat support), then re-run."
	else
		colEcho $yellowB "Tried ntfs3, ntfs, ntfs-3g, and auto. Install ntfs-3g if needed, then re-run."
	fi
	colEcho $redB "Refusing to extract into an unmounted local folder (that would fill your system disk)."
	exit $ExitError
}

# Download the MediCat archive over HTTP (aria2c multi-connection preferred; wget fallback).
# $1=url  $2=mirror name  $3=insecure (true|false) - skip TLS verify when true
function downloadMedicatHttp() {
	local url="$1"
	local mirrorName="$2"
	local insecure="$3"
	local ok=1

	colEcho $cyanB "\nDirect download from$whiteB $mirrorName"
	colEcho $cyanB "URL:$whiteB $url"

	if command -v aria2c >/dev/null 2>&1; then
		# aria2 caps --max-connection-per-server (-x) at 16
		local ariaArgs=(-x16 -s16 -k1M -c --file-allocation=none --summary-interval=5 -o "$Medicat7zFile")
		if [[ "$insecure" == "true" ]]; then
			colEcho $yellowB "Note: this mirror has known TLS certificate issues; certificate checking is disabled for this download only."
			ariaArgs+=(--check-certificate=false)
		fi
		if aria2c "${ariaArgs[@]}" -- "$url"; then
			ok=0
		fi
	elif command -v wget >/dev/null 2>&1; then
		colEcho $yellowB "aria2c not found; falling back to single-stream wget."
		local wgetArgs=(-c --show-progress -O "$Medicat7zFile")
		if [[ "$insecure" == "true" ]]; then
			colEcho $yellowB "Note: this mirror has known TLS certificate issues; certificate checking is disabled for this download only."
			wgetArgs+=(--no-check-certificate)
		fi
		if wget "${wgetArgs[@]}" -- "$url"; then
			ok=0
		fi
	else
		colEcho $redB "ERROR: Neither aria2c nor wget is available for HTTP download."
		return 1
	fi

	if [[ "$ok" -eq 0 ]] && [[ -f "$Medicat7zFile" ]]; then
		location="$Medicat7zFile"
		archiveKind="solid7z"
		colEcho $greenB "Download finished:$whiteB $location"
		return 0
	fi

	colEcho $redB "Download from $mirrorName failed."
	return 1
}

# Download MediCat via BitTorrent (aria2c).
function downloadMedicatTorrent() {
	colEcho $cyanB "\nStarting MediCat download via BitTorrent..."
	if ! fetchFile "$MedicatTorrentUrl" "." "medicat.torrent"; then
		colEcho $redB "ERROR: Failed to download torrent file from:$whiteB $MedicatTorrentUrl"
		return 1
	fi

	if ! aria2c --file-allocation=none --seed-time=0 --summary-interval=15 medicat.torrent; then
		colEcho $redB "ERROR: BitTorrent download failed."
		rm -f medicat.torrent
		return 1
	fi
	rm -f medicat.torrent

	if [[ -f "$Medicat7zFull" ]]; then
		location="$Medicat7zFull"
		archiveKind="solid7z"
	elif [[ -f "$Medicat7zFile" ]]; then
		location="$Medicat7zFile"
		archiveKind="solid7z"
	else
		colEcho $redB "ERROR: Torrent finished but $Medicat7zFile was not found."
		return 1
	fi

	colEcho $greenB "Medicat successfully downloaded:$whiteB $location"
	return 0
}

# Try direct mirrors in order, then offer torrent on total failure.
function downloadMedicatDirect() {
	local i
	for i in "${!MedicatMirrorUrls[@]}"; do
		if (( i > 0 )); then
			colEcho $yellowB "\nMirror failed. Trying fallback (${MedicatMirrorNames[$i]})..."
		fi
		if downloadMedicatHttp "${MedicatMirrorUrls[$i]}" "${MedicatMirrorNames[$i]}" "${MedicatMirrorInsecure[$i]}"; then
			return 0
		fi
	done

	colEcho $redB "\nAll direct download mirrors failed."
	if confirm "Try BitTorrent instead? (Y/N) "; then
		downloadMedicatTorrent
		return $?
	fi
	return 1
}

# Available bytes on the filesystem that holds $1 (GNU df). Prints nothing / fails on error.
function getAvailBytes() {
	local path="$1"
	df -B1 --output=avail "$path" 2>/dev/null | awk 'NR==2 {print $1; exit}'
}

# Warn (or optionally abort) when path has less than minBytes free.
# $1=path  $2=minBytes  $3=purpose label  $4=fatal|warn
# fatal: exit 1 unless user continues after extra confirm (still discouraged)
# warn:  YesNo to continue; decline exits 0
function requireFreeSpace() {
	local path="$1"
	local minBytes="$2"
	local purpose="$3"
	local mode="${4:-warn}"
	local avail

	if [[ ! -e "$path" ]]; then
		colEcho $yellowB "WARNING: Cannot check free space; path does not exist yet:$whiteB $path"
		return 0
	fi

	avail=$(getAvailBytes "$path")
	if [[ -z "$avail" || ! "$avail" =~ ^[0-9]+$ ]]; then
		colEcho $yellowB "WARNING: Unable to read free space for$whiteB $path$yellowB (df failed). Continuing..."
		return 0
	fi

	colEcho $cyanB "Free space on$whiteB $path$cyanB:$whiteB $(humanBytes "$avail")$cyanB (need ~$whiteB$(humanBytes "$minBytes")$cyanB for $purpose)"

	if (( avail >= minBytes )); then
		return 0
	fi

	colEcho $redB "\nWARNING: Not enough free space for $purpose."
	colEcho $redB "  Path:$whiteB $path"
	colEcho $redB "  Available:$whiteB $(humanBytes "$avail")"
	colEcho $redB "  Recommended:$whiteB $(humanBytes "$minBytes")"
	colEcho $yellowB "Low space often causes truncated MediCat downloads, apt failures, or extract errors."
	colEcho $yellowB "Free space, move the archive to a larger disk, or download to another path.\n"
	df -h "$path" 2>/dev/null || true

	if $AssumeYes; then
		colEcho $redB "Refusing to continue with low free space in unattended mode."
		exit $ExitError
	fi

	if [[ "$mode" == "fatal" ]]; then
		if ! YesNo "Continue anyway? A failed/truncated download is likely. (Y/N) "; then
			colEcho $cyanB "Exiting so you can free space first."
			exit $ExitError
		fi
		colEcho $yellowB "Continuing despite low free space...\n"
		return 0
	fi

	if ! YesNo "Continue anyway? (Y/N) "; then
		colEcho $cyanB "Exiting so you can free space first."
		exit $ExitCancelled
	fi
	colEcho $yellowB "Continuing despite low free space...\n"
	return 0
}

# Point $location at a solid .7z or a split .001 set. Returns 1 when the path is unusable.
function useArchivePath() {
	local pathInput="$1"
	local splitFirst
	if splitFirst=$(resolveSplitFirstVolume "$pathInput"); then
		location="$splitFirst"
		archiveKind="splitzip"
		DownloadMethod="local"
		needMedicatDownload=false
		colEcho $cyanB "Using local split archive:$whiteB $location"
		return 0
	fi
	if [[ ! -f "$pathInput" ]]; then
		colEcho $redB "File not found:$whiteB $pathInput"
		return 1
	fi
	location="$pathInput"
	archiveKind="solid7z"
	DownloadMethod="local"
	needMedicatDownload=false
	colEcho $cyanB "Using local file:$whiteB $location"
	return 0
}

# Prompt how to obtain the archive when it is not already on disk.
function chooseMedicatSource() {
	local choice=""
	local pathInput=""

	while true; do
		colEcho $cyanB "\nHow would you like to get$whiteB $Medicat7zFile$cyanB?"
		colEcho $whiteB "  1)$cyanB Direct download (multi-connection HTTPS via aria2c) [recommended]"
		colEcho $whiteB "  2)$cyanB BitTorrent"
		colEcho $whiteB "  3)$cyanB Enter path to an existing file"
		ReadPrompt "Choice [1/2/3]: " choice
		choice="${choice#"${choice%%[![:space:]]*}"}"
		choice="${choice%"${choice##*[![:space:]]}"}"

		case "$choice" in
			1)
				DownloadMethod="direct"
				needMedicatDownload=true
				return 0
				;;
			2)
				DownloadMethod="torrent"
				needMedicatDownload=true
				return 0
				;;
			3)
				ReadPrompt "Path to $Medicat7zFile or ${MedicatSplitFirst}: " pathInput
				pathInput="${pathInput//$'\r'/}"
				pathInput="${pathInput#"${pathInput%%[![:space:]]*}"}"
				pathInput="${pathInput%"${pathInput##*[![:space:]]}"}"
				# Expand ~ if present
				pathInput="${pathInput/#\~/$HOME}"
				if [[ -z "$pathInput" ]]; then
					colEcho $redB "No path entered."
					continue
				fi
				if useArchivePath "$pathInput"; then
					return 0
				fi
				;;
			*)
				colEcho $redB "Invalid choice. Enter 1, 2, or 3."
				;;
		esac
	done
}

# Find the archive beside the script, via --archive, or ask. Sets location/archiveKind.
function locateArchive() {
	local splitFirst
	colEcho $cyanB "\nLocating the Medicat archive..."
	if [[ -n "$ArchiveOverride" ]]; then
		useArchivePath "$ArchiveOverride" || exit $ExitBadArgs
	elif [[ -f "$Medicat7zFile" ]]; then
		location="$Medicat7zFile"
		archiveKind="solid7z"
		colEcho $cyanB "Medicat file found:$whiteB $Medicat7zFile\n"
	elif [[ -f "$Medicat7zFull" ]]; then
		location="$Medicat7zFull"
		archiveKind="solid7z"
		colEcho $cyanB "Medicat file found:$whiteB $Medicat7zFull\n"
	elif splitFirst=$(resolveSplitFirstVolume "."); then
		location="$splitFirst"
		archiveKind="splitzip"
		colEcho $cyanB "Medicat split volumes found:$whiteB $MedicatSplitFirst ..\n"
	elif $Offline; then
		colEcho $redB "ERROR: --offline but no MediCat archive found here. Pass --archive FILE."
		exit $ExitError
	elif [[ -n "$DownloadMethod" ]]; then
		needMedicatDownload=true
	elif $AssumeYes; then
		colEcho $yellowB "Medicat archive not found; unattended mode defaults to direct download."
		DownloadMethod="direct"
		needMedicatDownload=true
	else
		colEcho $yellowB "Medicat archive not found in the current directory (.7z or split .zip.001-.006)."
		chooseMedicatSource
	fi
}

# Download (if requested) and check the archive size + hash.
function acquireArchive() {
	if $needMedicatDownload ; then
		# Archive lands in the current directory — low space here truncates the .7z.
		requireFreeSpace "." "$MedicatDownloadMinFreeBytes" "MediCat archive download" "fatal"
		case "$DownloadMethod" in
			direct)
				if ! downloadMedicatDirect; then
					colEcho $redB "ERROR: Unable to obtain MediCat archive. Exiting..."
					exit $ExitError
				fi
				;;
			torrent)
				if ! downloadMedicatTorrent; then
					colEcho $redB "ERROR: Unable to obtain MediCat archive. Exiting..."
					exit $ExitError
				fi
				;;
			*)
				colEcho $redB "ERROR: Unknown download method. Exiting..."
				exit $ExitError
				;;
		esac
	fi

	if [[ -z "$location" ]] || [[ ! -f "$location" ]]; then
		colEcho $redB "ERROR: MediCat archive path is missing or invalid:$whiteB ${location:-"(empty)"}"
		exit $ExitError
	fi

	# Infer kind if local path was set without going through locate.
	if [[ -z "$archiveKind" ]]; then
		if [[ "$location" == *.zip.001 ]]; then
			archiveKind="splitzip"
		else
			archiveKind="solid7z"
		fi
	fi

	if [[ "$archiveKind" == "splitzip" ]]; then
		local splitFirst
		if ! splitFirst=$(resolveSplitFirstVolume "$location"); then
			colEcho $redB "ERROR: Incomplete Google Drive / Mega split set (need all of ${MedicatSplitFiles[*]})."
			exit $ExitError
		fi
		location="$splitFirst"
		verifySplitArchive
		return 0
	fi

	# Check size then SHA256 of the solid Medicat .7z
	colEcho $cyanB "Checking size and SHA256 hash of$whiteB $location$cyanB..."

	local fileSize
	fileSize=$(stat -c%s "$location" 2>/dev/null || stat -f%z "$location" 2>/dev/null || echo 0)
	if [[ "$fileSize" -lt "$Medicat7zMinBytes" ]]; then
		colEcho $redB "ERROR: $location looks incomplete or truncated."
		colEcho $cyanB "Size is$whiteB $fileSize$cyanB bytes; expected$whiteB $Medicat7zBytes$cyanB (at least $Medicat7zMinBytes)."
		colEcho $yellowB "Delete the partial file and download again (prefer aria2c / a stable mirror)."
		exit $ExitError
	fi

	if $SkipArchiveHash; then
		colEcho $yellowB "Skipping the archive SHA256 check (--skip-archive-hash)."
		return 0
	fi

	local checksha256
	checksha256=$(sha256sum "$location" | awk '{print $1}')
	if [[ "$checksha256" != "$Medicat256Hash" ]]; then
		colEcho $redB "$location SHA256 hash does not match."
		colEcho $redB "File may be corrupted, incomplete, or the wrong format (need the .7z, or all split .zip parts)."
		colEcho $cyanB "Got:$whiteB      $checksha256"
		colEcho $cyanB "Expected:$whiteB $Medicat256Hash"
		colEcho $cyanB "Exiting..."
		exit $ExitError
	fi
	colEcho $greenB "$location SHA256 hash matches."
	colEcho $cyanB "Hash is$whiteB $checksha256"
	colEcho $cyanB "Safe to proceed..."
}

# Pick the target disk interactively unless --drive was given. Sets drive/drive2/letter.
function selectDisk() {
	letter=""
	if [[ -n "$TargetDisk" ]]; then
		letter="${TargetDisk#/dev/}"
		if [[ ! -b "/dev/$letter" ]]; then
			colEcho $redB "ERROR: Block device not found:$whiteB /dev/$letter"
			exit $ExitBadArgs
		fi
	else
		# Advise user to connect and select the required USB device.
		colEcho $yellowB "\nPlease plug your USB in now if it is not already connected..."
		colEcho $yellowB "NOTE: A 32GB stick works, but only just barely — prefer 64GB+ if you have one."
		colEcho $yellowB "Press any key once it has been detected by your system..."
		UserWait "Press any key when ready..."

		while true; do
			colEcho $yellowB "\nPlease find the ID of your USB drive below (look for TRAN=usb):"
			lsblk --nodeps --output "NAME,SIZE,TRAN,VENDOR,MODEL,SERIAL" | grep -v loop || true

			colEcho $yellowB "Enter the device name NOT including /dev/ or the partition number."
			colEcho $yellowB "For example: sda  or  sdb  or  nvme0n1"
			ReadPrompt "Device: " letter
			letter="${letter//$'\r'/}"
			letter="${letter#/dev/}"
			letter="${letter#"${letter%%[![:space:]]*}"}"
			letter="${letter%"${letter##*[![:space:]]}"}"
			if [[ -z "$letter" ]]; then
				colEcho $redB "No device entered. Try again."
				continue
			fi
			if [[ ! -b "/dev/$letter" ]]; then
				colEcho $redB "Block device not found:$whiteB /dev/$letter"
				colEcho $yellowB "Check the name from the list and try again."
				continue
			fi
			break
		done
	fi

	drive=/dev/$letter
	# First partition: nvme0n1 -> nvme0n1p1, sda -> sda1
	if [[ "$letter" =~ [0-9]$ ]]; then
		drive2="${drive}p1"
	else
		drive2="${drive}1"
	fi

	local driveType
	driveType=$(lsblk -ndo TYPE "$drive" 2>/dev/null | head -n1)
	if [[ -n "$driveType" && "$driveType" != "disk" && "$driveType" != "loop" ]]; then
		colEcho $redB "ERROR: $drive is a $driveType, not a whole disk. Pass the disk (e.g. /dev/sdb), not a partition."
		exit $ExitBadArgs
	fi

	local driveBytes
	driveBytes=$(lsblk -ndbo SIZE "$drive" 2>/dev/null | head -n1)
	if [[ "$driveBytes" =~ ^[0-9]+$ ]] && (( driveBytes < MedicatUsbMinBytes )); then
		colEcho $redB "ERROR: $drive is $(humanBytes "$driveBytes"); MediCat needs at least $(humanBytes "$MedicatUsbMinBytes")."
		exit $ExitError
	fi
}

# Warn when the chosen disk is not USB (internal HDD/SSD/NVMe wipe risk).
function confirmDiskChoice() {
	local driveTran driveSize driveModel confirmWipe
	driveTran=$(lsblk -ndo TRAN "$drive" 2>/dev/null | head -n1 | tr '[:upper:]' '[:lower:]')
	driveSize=$(lsblk -ndo SIZE "$drive" 2>/dev/null | head -n1)
	driveModel=$(lsblk -ndo MODEL "$drive" 2>/dev/null | head -n1)
	driveModel="${driveModel#"${driveModel%%[![:space:]]*}"}"
	driveModel="${driveModel%"${driveModel##*[![:space:]]}"}"
	logLine "target disk: $drive tran=${driveTran:-unknown} size=${driveSize:-unknown} model=${driveModel:-unknown}"
	if [[ "$driveTran" != "usb" ]]; then
		colEcho $redB "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		colEcho $redB " WARNING: $drive does not look like a USB drive."
		colEcho $redB " Transport:$whiteB ${driveTran:-unknown}$redB  Size:$whiteB ${driveSize:-unknown}$redB  Model:$whiteB ${driveModel:-unknown}"
		colEcho $redB " Installing here will ERASE this disk (internal HDD/SSD/NVMe)."
		colEcho $redB " MediCat is meant for a removable USB stick — double-check the device name."
		colEcho $redB "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		if $AllowFixed; then
			colEcho $yellowB "--allow-fixed given; continuing with a non-USB disk."
		elif $AssumeYes; then
			colEcho $redB "Refusing to wipe a non-USB disk unattended. Add --allow-fixed if you really mean it."
			exit $ExitCancelled
		else
			colEcho $redB "To continue, type CONFIRM in all caps (anything else cancels).\n"
			confirmWipe=""
			ReadPrompt "Type CONFIRM to wipe $drive: " confirmWipe
			if [[ "$confirmWipe" != "CONFIRM" ]]; then
				colEcho $yellowB "Confirmation text did not match. Installation Cancelled."
				exit $ExitCancelled
			fi
		fi
	fi

	colEcho $yellowB "\nThis will ERASE everything on $drive (${driveModel:-unknown model}, ${driveSize:-unknown size})."
	if confirm "You want to install Ventoy and Medicat to $drive / $drive2? (Y/N) "; then
		colEcho $cyanB "Installation confirmed and will commence in 5 seconds..."
		sleep 5
	else
		colEcho $yellowB "Installation Cancelled."
		exit $ExitCancelled
	fi
}

# Run Ventoy2Disk on $drive. Ventoy asks its own two y/n questions; we answer them
# because the wipe was already confirmed above.
function installVentoy() {
	local -a ventoyArgs=(-I)
	if $UseGpt; then
		colEcho $yellowB "Using GPT"
		ventoyArgs+=(-g)
	else
		colEcho $yellowB "Using MBR"
	fi
	if [[ "$SecureBoot" == "true" ]]; then
		ventoyArgs+=(-s)
	else
		colEcho $yellowB "Ventoy Secure Boot support disabled (--no-secure-boot)"
		ventoyArgs+=(-S)
	fi
	if [[ "$FsType" == "exfat" ]]; then
		ventoyArgs+=(-L "$MedicatDataLabel")
	fi

	colEcho $cyanB "Installing Ventoy on$whiteB $drive"
	colEcho $blueB "MBR at max can do up to approximately 2.2 TB and will work with older BIOS systems and UEFI systems that support legacy operating systems. GPT can do up to 18 exabytes and will work with UEFI systems."

	if $ventoyFS; then
		cd ventoy || exit $ExitError  # Ventoy2Disk.sh must run from its own directory
	fi
	logLine "ventoy: $ventoyLauncher ${ventoyArgs[*]} $drive"
	local answers=$'y\ny\n'
	# shellcheck disable=SC2086
	if ! $sudo $ventoyLauncher "${ventoyArgs[@]}" "$drive" <<< "$answers"; then
		colEcho $redB "ERROR: Unable to install Ventoy. Exiting..."
		exit $ExitError
	fi
	if $ventoyFS; then
		cd .. || exit $ExitError
	fi

	# Give the kernel a moment to publish the new partition table.
	$sudo partprobe "$drive" >/dev/null 2>&1 || true
	if command -v udevadm >/dev/null 2>&1; then
		$sudo udevadm settle >/dev/null 2>&1 || true
	fi
	local i
	for i in 1 2 3 4 5 6 7 8 9 10; do
		[[ -b "$drive2" ]] && break
		sleep 1
	done
	if [[ ! -b "$drive2" ]]; then
		colEcho $redB "ERROR: Partition $drive2 did not appear after the Ventoy install."
		exit $ExitError
	fi
}

# Put the requested filesystem on the data partition (Ventoy always creates exFAT first).
function formatDataPartition() {
	colEcho $cyanB "Unmounting drive$whiteB $drive"
	$sudo umount "$drive2" 2>/dev/null || true
	$sudo umount "$drive" 2>/dev/null || true

	if [[ "$FsType" == "exfat" ]]; then
		colEcho $cyanB "Keeping Ventoy's exFAT data partition on$whiteB $drive2$cyanB (label $MedicatDataLabel)"
		return 0
	fi

	colEcho $cyanB "Creating Medicat NTFS file system on drive$whiteB $drive2"
	if ! $sudo mkntfs --fast --label "$MedicatDataLabel" "$drive2"; then
		colEcho $redB "ERROR: mkntfs failed on$whiteB $drive2"
		exit $ExitError
	fi
}

# Resolve the MD5 manifest: --manifest, cached copy in the work dir, or download.
function resolveManifest() {
	local cached="$WorkDir/$MedicatManifestFile"
	local url
	if [[ -n "$ManifestOverride" ]]; then
		printf '%s\n' "$ManifestOverride"
		return 0
	fi
	if [[ -s "$cached" ]] && grep -q -E '^[0-9a-fA-F]{32} \*' "$cached"; then
		printf '%s\n' "$cached"
		return 0
	fi
	if $Offline; then
		colEcho $redB "ERROR: --offline and no $MedicatManifestFile in $WorkDir (pass --manifest FILE)." >&2
		return 1
	fi
	for url in "${MedicatManifestUrls[@]}"; do
		colEcho $cyanB "Downloading manifest:$whiteB $url" >&2
		if fetchText "$url" > "$cached.part" && grep -q -E '^[0-9a-fA-F]{32} \*' "$cached.part"; then
			mv "$cached.part" "$cached"
			printf '%s\n' "$cached"
			return 0
		fi
		rm -f "$cached.part"
	done
	colEcho $redB "ERROR: Could not download $MedicatManifestFile from any source." >&2
	return 1
}

# MD5-verify the MediCat tree in $1 against the manifest. Sets VerifyResult/VerifyFailedCount and
# writes failed_files.txt (forward-slash paths) at the root of the tree when anything fails.
function verifyTree() {
	local dir="$1"
	local manifest listFile rawFile
	if ! manifest=$(resolveManifest); then
		VerifyResult="skipped"
		return 1
	fi
	listFile="$WorkDir/medicat_verify_list.txt"
	rawFile="$WorkDir/medicat_verify_output.txt"
	FailedListFile="$dir/failed_files.txt"

	# QuickSFV format "md5 *path\with\backslashes" -> "md5  path/with/slashes" for md5sum -c.
	sed -e 's/\r$//' -e '/^;/d' -e '/^[[:space:]]*$/d' -e 's/^\([0-9a-fA-F]\{32\}\) \*/\1  /' -e 's/\\/\//g' \
		"$manifest" > "$listFile"
	local total
	total=$(wc -l < "$listFile" | tr -d ' ')
	colEcho $cyanB "\nVerifying $total files on$whiteB $dir$cyanB (this reads about $(humanBytes "$MedicatExtractedBytes"))..."

	(cd "$dir" && md5sum -c --quiet "$listFile") > "$rawFile" 2>&1
	grep -E ': FAILED( open or read)?$' "$rawFile" | sed -E 's/: FAILED( open or read)?$//' > "$FailedListFile"
	VerifyFailedCount=$(wc -l < "$FailedListFile" | tr -d ' ')
	local missing
	missing=$(grep -c ': FAILED open or read$' "$rawFile" || true)

	if (( VerifyFailedCount == 0 )); then
		rm -f "$FailedListFile"
		VerifyResult="ok"
		colEcho $greenB "All $total files verified OK."
		return 0
	fi
	VerifyResult="failed"
	colEcho $redB "$VerifyFailedCount of $total files failed verification ($missing missing)."
	colEcho $yellowB "List written to$whiteB $FailedListFile"
	head -n 20 "$FailedListFile" | sed 's/^/  /'
	if (( VerifyFailedCount > 20 )); then
		colEcho $yellowB "  ... ($((VerifyFailedCount - 20)) more)"
	fi
	return 1
}

# Re-extract only the files listed in failed_files.txt from the archive, then re-check them.
function reextractFailed() {
	local dir="$1"
	local archive="$2"
	local listFile="$WorkDir/medicat_reextract_list.txt"
	local checkFile="$WorkDir/medicat_recheck_list.txt"
	cp "$FailedListFile" "$listFile"

	colEcho $cyanB "\nRe-extracting $VerifyFailedCount files from$whiteB $archive"
	if ! 7z x -o"$dir" -aoa -y "$archive" "@$listFile"; then
		colEcho $redB "ERROR: 7z re-extract failed."
		return 1
	fi
	sync

	# Re-check only the re-extracted paths.
	awk 'NR==FNR { want[$0] = 1; next } { path = $0; sub(/^[0-9a-fA-F]+  /, "", path); if (path in want) print }' \
		"$listFile" "$WorkDir/medicat_verify_list.txt" > "$checkFile"
	(cd "$dir" && md5sum -c --quiet "$checkFile") > "$WorkDir/medicat_verify_output.txt" 2>&1
	grep -E ': FAILED( open or read)?$' "$WorkDir/medicat_verify_output.txt" | sed -E 's/: FAILED( open or read)?$//' > "$FailedListFile"
	VerifyFailedCount=$(wc -l < "$FailedListFile" | tr -d ' ')
	if (( VerifyFailedCount == 0 )); then
		rm -f "$FailedListFile"
		VerifyResult="ok"
		colEcho $greenB "Re-extracted files verified OK."
		return 0
	fi
	VerifyResult="failed"
	colEcho $redB "$VerifyFailedCount files still fail after re-extract (see $FailedListFile)."
	colEcho $yellowB "A bad USB stick, an antivirus quarantine or a damaged archive are the usual causes."
	return 1
}

# Verify and optionally re-extract. $1=tree  $2=archive path or empty
function verifyAndRepair() {
	local dir="$1"
	local archive="$2"
	verifyTree "$dir" && return 0
	[[ "$VerifyResult" == "failed" ]] || return 1
	if ! $ReExtract || [[ -z "$archive" || ! -f "$archive" ]]; then
		if [[ -z "$archive" ]]; then
			colEcho $yellowB "No archive available for re-extract (pass --archive FILE to repair)."
		fi
		return 1
	fi
	if confirm "Re-extract the failed files from the archive? (Y/N) "; then
		reextractFailed "$dir" "$archive"
		return $?
	fi
	return 1
}

# Interactive extras picker. Prints the chosen ids comma-separated (or "none").
function pickExtras() {
	local i choice n
	local -a picked=()
	local -a nums=()
	colEcho $cyanB "\nExtra boot images available (Ventoy boots anything under ${ExtrasDestRoot}/):" >&2
	for i in "${!ExtrasIds[@]}"; do
		local size="manual download"
		if [[ "${ExtrasTypes[$i]}" == "iso" ]]; then
			size=$(humanBytes "${ExtrasBytes[$i]}")
		fi
		colEcho $whiteB "  $((i + 1)))$cyanB ${ExtrasNames[$i]} ${ExtrasVersions[$i]}$whiteB ($size, for ${ExtrasTargets[$i]})" >&2
		colEcho "      ${ExtrasDescriptions[$i]}" >&2
	done
	while true; do
		ReadPrompt "Numbers to add (e.g. 1,3), 'all' or 'none': " choice
		choice="${choice//[[:space:]]/}"
		case "$choice" in
			all|none)
				printf '%s\n' "$choice"
				return 0
				;;
			"")
				continue
				;;
		esac
		picked=()
		local ok=true
		IFS=',' read -r -a nums <<< "$choice"
		for n in "${nums[@]}"; do
			if [[ ! "$n" =~ ^[0-9]+$ ]] || (( n < 1 || n > ${#ExtrasIds[@]} )); then
				colEcho $redB "Invalid entry: $n" >&2
				ok=false
				break
			fi
			picked+=("${ExtrasIds[$((n - 1))]}")
		done
		if $ok; then
			local IFS=','
			printf '%s\n' "${picked[*]}"
			return 0
		fi
	done
}

# The digest recorded in extras_manifest.txt for catalog index $1, strongest first.
function extrasDigestLabel() {
	local i="$1"
	if [[ -n "${ExtrasSha256[$i]}" ]]; then printf 'sha256:%s\n' "${ExtrasSha256[$i]}"
	elif [[ -n "${ExtrasSha512[$i]}" ]]; then printf 'sha512:%s\n' "${ExtrasSha512[$i]}"
	elif [[ -n "${ExtrasSha1[$i]}" ]]; then printf 'sha1:%s\n' "${ExtrasSha1[$i]}"
	else printf 'md5:%s\n' "${ExtrasMd5[$i]}"
	fi
}

# Download the selected extras into $1/<dest_root>/<category>/. $2 = all | none | id,id
function installExtras() {
	local dir="$1"
	local selection="$2"
	local -a ids=()
	local id i
	local totalBytes=0
	local failures=0
	local manifestFile="$dir/$ExtrasDestRoot/extras_manifest.txt"

	case "$selection" in
		none|"") return 0 ;;
		all) ids=("${ExtrasIds[@]}") ;;
		*)
			IFS=',' read -r -a ids <<< "$selection"
			;;
	esac

	for id in "${ids[@]}"; do
		id="${id// /}"
		[[ -z "$id" ]] && continue
		i=$(extrasIndex "$id") || { colEcho $redB "Unknown extras id: $id"; return 1; }
		if [[ "${ExtrasTypes[$i]}" == "iso" ]]; then
			totalBytes=$(( totalBytes + ExtrasBytes[i] ))
		fi
	done
	if (( totalBytes > 0 )); then
		requireFreeSpace "$dir" "$totalBytes" "extra boot images" "fatal"
	fi

	mkdir -p "$dir/$ExtrasDestRoot"
	for id in "${ids[@]}"; do
		id="${id// /}"
		[[ -z "$id" ]] && continue
		i=$(extrasIndex "$id")
		local name="${ExtrasNames[$i]} ${ExtrasVersions[$i]}"
		local dest="$dir/$ExtrasDestRoot/${ExtrasCategories[$i]}"
		local target="$dest/${ExtrasFileNames[$i]}"

		if [[ "${ExtrasTypes[$i]}" == "manual" ]]; then
			colEcho $yellowB "\n$name: download it yourself from$whiteB ${ExtrasUrls[$i]}"
			colEcho $yellowB "then copy the ISO into$whiteB $dest/"
			mkdir -p "$dest"
			continue
		fi

		mkdir -p "$dest"
		if [[ -f "$target" ]]; then
			if [[ -n "${ExtrasUnpackFormat[$i]}" ]]; then
				colEcho $cyanB "\n$name already present:$whiteB $target"
				continue
			fi
			if checksumOk "$target" "${ExtrasSha256[$i]}" "${ExtrasSha512[$i]}" "${ExtrasSha1[$i]}" "${ExtrasMd5[$i]}"; then
				colEcho $cyanB "\n$name already present and verified:$whiteB $target"
				continue
			fi
			colEcho $yellowB "\n$name exists but fails its checksum; downloading again."
			rm -f "$target"
		fi

		local downloadName="${ExtrasFileNames[$i]}"
		if [[ -n "${ExtrasUnpackFormat[$i]}" ]]; then
			downloadName="${ExtrasUrls[$i]##*/}"
		fi
		colEcho $cyanB "\nDownloading $name ($(humanBytes "${ExtrasBytes[$i]}"))..."
		colEcho $cyanB "URL:$whiteB ${ExtrasUrls[$i]}"
		if ! fetchFile "${ExtrasUrls[$i]}" "$dest" "$downloadName"; then
			colEcho $redB "Download failed for $name."
			failures=$((failures + 1))
			continue
		fi
		colEcho $cyanB "Checking checksum of $downloadName..."
		if ! checksumOk "$dest/$downloadName" "${ExtrasSha256[$i]}" "${ExtrasSha512[$i]}" "${ExtrasSha1[$i]}" "${ExtrasMd5[$i]}"; then
			colEcho $redB "Checksum mismatch for $name; removing the download."
			rm -f "$dest/$downloadName"
			failures=$((failures + 1))
			continue
		fi
		if [[ "${ExtrasUnpackFormat[$i]}" == "zip" ]]; then
			colEcho $cyanB "Unpacking ${ExtrasUnpackMember[$i]} from $downloadName..."
			if ! 7z e -y -o"$dest" "$dest/$downloadName" "${ExtrasUnpackMember[$i]}" >/dev/null; then
				colEcho $redB "Failed to unpack $downloadName."
				failures=$((failures + 1))
				continue
			fi
			mv -f "$dest/${ExtrasUnpackMember[$i]}" "$target"
			rm -f "$dest/$downloadName"
		fi
		printf '%s\t%s\t%s/%s\t%s\t%s\n' "$id" "${ExtrasVersions[$i]}" "${ExtrasCategories[$i]}" "${ExtrasFileNames[$i]}" \
			"$(extrasDigestLabel "$i")" "$(date '+%Y-%m-%d')" >> "$manifestFile"
		colEcho $greenB "Added $name ->$whiteB $target"
	done
	sync
	if (( failures > 0 )); then
		colEcho $redB "\n$failures extra image(s) could not be added."
		return 1
	fi
	return 0
}

# Mount the data partition of $drive (partition 1) at ./MedicatUSB, unless --path was given.
function attachTarget() {
	if [[ -n "$TargetPath" ]]; then
		MedicatMount="$TargetPath"
		if [[ ! -d "$MedicatMount/ventoy" ]]; then
			colEcho $yellowB "WARNING: $MedicatMount has no ventoy/ folder; is this really a MediCat stick?"
		fi
		return 0
	fi
	selectDisk
	if [[ ! -b "$drive2" ]]; then
		colEcho $redB "ERROR: No partition $drive2 on $drive. Is MediCat installed there?"
		exit $ExitError
	fi
	requireFreeSpace "." "$MedicatWorkMinFreeBytes" "MedicatUSB mountpoint" "warn"
	mkdir -p MedicatUSB
	local fs
	fs=$(lsblk -ndo FSTYPE "$drive2" 2>/dev/null | head -n1)
	[[ "$fs" == "exfat" ]] || fs="ntfs"
	mountMedicatVolume "$drive2" "./MedicatUSB" "$fs"
	MedicatMount="./MedicatUSB"
	MountedByUs=true
}

function detachTarget() {
	if [[ "$MountedByUs" == "true" ]]; then
		if confirm "Would you like to unmount $MedicatMount? (Y/N) "; then
			colEcho $cyanB "Unmounting $MedicatMount..."
			sync
			$sudo umount "$MedicatMount" && colEcho $cyanB "Unmounted."
		else
			colEcho $cyanB "$MedicatMount will not be unmounted."
		fi
	fi
}

function setDistroVars() {
	# Package manager and package names per distro family.
	if grep -qs "ubuntu" /etc/os-release; then
		os="ubuntu"
		pkgmgr="apt"
		install_arg="install -y"
		update_arg="update"
	elif grep -qs "freebsd" /etc/os-release; then
		os="freebsd"
		pkgmgr="pkg"
		install_arg="install -y"
		update_arg="update"
	elif grep -qs "nixos" /etc/os-release; then
		os="nixos"
		sudo=""
		pkgmgr="nix-env"
		install_arg="-iA"
		update_arg="--upgrade"
		ventoyFS=false
	elif grep -qs "alpine" /etc/os-release; then
		os="alpine"
		pkgmgr="apk"
		install_arg="add --no-interactive"
		update_arg="update"
	elif [[ -e /etc/debian_version ]]; then
		os="debian"
		pkgmgr="apt"
		install_arg="install -y"
		update_arg="update"
	elif [[ -e /etc/almalinux-release || -e /etc/rocky-release || -e /etc/centos-release ]]; then
		os="centos"
		pkgmgr="yum"
		install_arg="install -y"
		update_arg="update"
	elif [[ -e /etc/fedora-release ]]; then
		os="fedora"
		pkgmgr="dnf"
		install_arg="install -y"
		update_arg="upgrade"
	elif [[ -e /etc/nobara ]]; then
		os="fedora"
		pkgmgr="yum"
		install_arg="install -y"
		update_arg="update"
	elif grep -qs "cachyos" /etc/os-release; then
		# Must run before /etc/arch-release: CachyOS is Arch-based and often has that file.
		os="cachyos"
		colEcho $blueB "CachyOS, Arch but faster"
		pkgmgr="pacman"
		install_arg="-S --needed --noconfirm"
		update_arg="-Syy"
	elif [[ -e /etc/arch-release ]]; then
		os="arch"
		colEcho $blueB "I use Arch btw"
		pkgmgr="pacman"
		install_arg="-S --needed --noconfirm"
		update_arg="-Syy"
	elif grep -qs "void" /etc/os-release; then
		os="void"
		colEcho $greenB "Enter the void"
		pkgmgr="xbps-install"
		install_arg="-Sy" # -y = assume yes
		update_arg="-S"
	else
		os="unknown"
		colEcho "WARNING: Distro not recognised - trying to continue...\n"
	fi

	colEcho $cyanB "Operating System Identified as:$whiteB $os"
}

# Full install: deps, Ventoy, archive, disk, format, extract, verify, extras.
function runInstall() {
	locateArchive

	colEcho $cyanB "Acquiring any dependencies..."
	# Working directory needs headroom for packages / Ventoy tarball / mountpoint.
	requireFreeSpace "." "$MedicatWorkMinFreeBytes" "installer working files" "warn"

	if $needMedicatDownload ; then
		depCommands["aria2c"]="aria"
	fi
	if [[ "$FsType" == "exfat" ]]; then
		unset 'depCommands[mkntfs]'
	fi

	if $ventoyFS ; then
		dependenciesHandler
		prepareVentoy
	else
		colEcho $cyanB "INFO: Handling ventoy as a package."
		depCommands["ventoy"]="ventoy"
		dependenciesHandler
		ventoyLauncher="ventoy"
	fi

	acquireArchive
	selectDisk
	confirmDiskChoice
	installVentoy
	formatDataPartition

	# Create a mountpoint folder for the Medicat volume
	requireFreeSpace "." "$MedicatWorkMinFreeBytes" "MedicatUSB mountpoint" "fatal"
	if ! [[ -d MedicatUSB/ ]] ; then
		colEcho $cyanB "Creating a mountpoint for the Medicat volume..."
		mkdir MedicatUSB
	fi

	colEcho $cyanB "Mounting Medicat volume..."
	mountMedicatVolume "$drive2" "./MedicatUSB" "$FsType"
	MedicatMount="./MedicatUSB"
	MountedByUs=true

	# Target USB must have room for the extracted MediCat tree.
	colEcho $yellowB "NOTE: 32GB USBs are fine but JUST BARELY - little room left after extract."
	requireFreeSpace "./MedicatUSB" "$MedicatUsbMinFreeBytes" "MediCat extract onto USB" "fatal"

	# Belt-and-suspenders: never extract unless ./MedicatUSB is still a mount of $drive2.
	if ! mountpoint -q ./MedicatUSB 2>/dev/null; then
		colEcho $redB "ERROR: ./MedicatUSB is not a mounted filesystem. Aborting extract."
		exit $ExitError
	fi

	colEcho $cyanB "Extracting Medicat to the $FsType volume..."
	logLine "extract: 7z x -o./MedicatUSB $location"
	# For split Drive/Mega volumes, $location is the .001 file; 7z opens the rest automatically.
	if ! 7z x -o./MedicatUSB "$location"; then
		colEcho $redB "ERROR: 7z extract failed for$whiteB $location"
		exit $ExitError
	fi
	sync
	colEcho $cyanB "MedicatUSB has been created."

	local exitCode=$ExitOk
	if ! verifyAndRepair "./MedicatUSB" "$location"; then
		if [[ "$VerifyResult" == "failed" ]]; then
			exitCode=$ExitVerifyFailed
		fi
	fi

	local selection="$ExtrasArg"
	if [[ -z "$selection" || "$selection" == "ask" ]]; then
		if $AssumeYes && [[ "$selection" != "ask" ]]; then
			selection="none"
		elif YesNo "Would you like to add extra boot images (SystemRescue, GParted, Clonezilla, ...)? (Y/N) "; then
			selection=$(pickExtras)
		else
			selection="none"
		fi
	fi
	if ! installExtras "./MedicatUSB" "$selection" && (( exitCode == ExitOk )); then
		exitCode=$ExitError
	fi

	detachTarget
	printSummary "$exitCode"
	exit "$exitCode"
}

# --verify: check an existing stick, repair from the archive when possible.
function runVerify() {
	local archive=""
	if [[ -n "$ArchiveOverride" ]]; then
		archive="$ArchiveOverride"
	elif [[ -f "$Medicat7zFile" ]]; then
		archive="$Medicat7zFile"
	elif [[ -f "$Medicat7zFull" ]]; then
		archive="$Medicat7zFull"
	fi
	if [[ -n "$archive" ]] && $ReExtract; then
		depCommands=(["7z"]="zip")
		dependenciesHandler
	fi
	attachTarget
	local exitCode=$ExitOk
	if ! verifyAndRepair "$MedicatMount" "$archive"; then
		if [[ "$VerifyResult" == "failed" ]]; then
			exitCode=$ExitVerifyFailed
		else
			exitCode=$ExitError
		fi
	fi
	detachTarget
	printSummary "$exitCode"
	exit "$exitCode"
}

# --extras: add catalog images to an existing stick.
function runExtras() {
	depCommands=(["7z"]="zip" ["aria2c"]="aria")
	dependenciesHandler
	attachTarget
	local exitCode=$ExitOk
	local selection="$ExtrasArg"
	if [[ "$selection" == "ask" ]]; then
		selection=$(pickExtras)
	fi
	installExtras "$MedicatMount" "$selection" || exitCode=$ExitError
	detachTarget
	printSummary "$exitCode"
	exit "$exitCode"
}

function printSummary() {
	local code="$1"
	colEcho $cyanB "\nSummary"
	case "$code" in
		"$ExitOk") colEcho $greenB "  Result: success" ;;
		"$ExitVerifyFailed") colEcho $redB "  Result: finished, but $VerifyFailedCount files fail verification (exit 5)" ;;
		*) colEcho $redB "  Result: finished with errors (exit $code)" ;;
	esac
	[[ -n "${drive:-}" ]] && colEcho "  Disk: $drive"
	[[ -n "$MedicatMount" ]] && colEcho "  MediCat tree: $MedicatMount"
	colEcho "  Log: $LogFile"
	if [[ "$code" != "$ExitOk" ]]; then
		colEcho "  Help: $LinkDiscord (attach the log)"
	fi
}

# Main

parseArgs "$@"
cd "$WorkDir" || exit $ExitError
logLine "=== Medicat_Installer.sh $ScriptVersion start: mode=$Mode args: $*"

if [[ "$Mode" == "interactive" && -t 1 ]]; then
	command clear 2>/dev/null || true
fi
colEcho "$yellowB" "WELCOME TO THE MEDICAT INSTALLER.\n"
colEcho "$cyanB" "Script version:$whiteB $ScriptVersion$cyanB  MediCat:$whiteB $MedicatVersion$cyanB  Extras catalog:$whiteB $ExtrasCatalogVersion"

CheckNotElevated

if [[ "$Mode" == "interactive" || "$Mode" == "install" ]]; then
	colEcho $cyanB "This Installer will install Ventoy and Medicat.\n"
	colEcho $yellowB "THIS IS IN BETA. PLEASE CONTACT MATT IN THE DISCORD FOR ALL ISSUES.\n"
	colEcho $cyanB "Updated for efficiency and cross-distro use by SkeletonMan.\n"
	colEcho $cyanB "Enhancements by Manganar.\n"
	colEcho $cyanB "Thanks to @m3p89goljrf7fu9eched in the Medicat Discord for pointing out a bug.\n"
	colEcho $cyanB "Refactored by id3v1669.\n"
fi

setDistroVars

case "$Mode" in
	interactive|install) runInstall ;;
	verify) runVerify ;;
	extras) runExtras ;;
esac
