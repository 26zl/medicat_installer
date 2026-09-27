// Console test runner for installer logic that needs no GUI, USB stick or network.
// Built as MedicatTests when CMake is configured with -DMEDICAT_BUILD_TESTS=ON.
#include "cli.h"
#include "spec_generated.h"
#include "update.h"
#include "verify.h"

#include <windows.h>

#include <cstdio>
#include <fstream>
#include <string>
#include <vector>

namespace {

int g_checks = 0;
int g_failures = 0;

void Check(const bool condition, const char* what) {
    ++g_checks;
    if (!condition) {
        ++g_failures;
        std::printf("FAIL: %s\n", what);
    }
}

medicat::CliParseResult Parse(std::vector<std::wstring> args) {
    std::vector<wchar_t*> argv;
    static wchar_t program[] = L"MedicatInstaller.exe";
    argv.push_back(program);
    for (std::wstring& arg : args) {
        argv.push_back(arg.data());
    }
    return medicat::ParseCommandLine(static_cast<int>(argv.size()), argv.data());
}

std::wstring WriteTempFile(const std::string& content) {
    wchar_t dir[MAX_PATH]{};
    wchar_t path[MAX_PATH]{};
    if (!GetTempPathW(MAX_PATH, dir) || !GetTempFileNameW(dir, L"mct", 0, path)) {
        return {};
    }
    std::ofstream out(path, std::ios::binary | std::ios::trunc);
    out << content;
    return path;
}

void TestCliParsing() {
    using medicat::CliAction;

    Check(Parse({L"/help"}).options.action == CliAction::Help, "/help selects the help action");
    Check(Parse({L"--version"}).options.action == CliAction::Version, "--version alias is accepted");

    const auto install = Parse({L"/install", L"/drive:E", L"/yes"});
    Check(install.ok && install.options.action == CliAction::Install, "/install /drive:E /yes parses");
    Check(!install.options.drive.empty(), "/drive value is kept");
    Check(install.options.yes, "/yes sets yes");

    Check(Parse({L"/install"}).errorCode == 2, "/install without /drive fails with exit code 2");
    Check(Parse({L"/install", L"/drive:E", L"/quiet"}).errorCode == 2, "/quiet without /yes is rejected");
    Check(Parse({L"/verify", L"/drive:E", L"/gpt", L"/nogpt"}).errorCode == 2, "conflicting /gpt and /nogpt");
    Check(Parse({L"/verify", L"/drive:E", L"/bogus"}).errorCode == 2, "unknown flag fails with exit code 2");

    const auto noTelemetry = Parse({L"/verify", L"/drive:E", L"/no-telemetry"});
    Check(noTelemetry.ok && noTelemetry.options.telemetry.has_value() && !*noTelemetry.options.telemetry,
          "/no-telemetry turns session reports off");
    const auto telemetry = Parse({L"/verify", L"/drive:E", L"/telemetry"});
    Check(telemetry.ok && telemetry.options.telemetry.value_or(false), "/telemetry turns session reports on");
    Check(Parse({L"/verify", L"/drive:E", L"/telemetry", L"/no-telemetry"}).errorCode == 2,
          "conflicting telemetry flags are rejected");
    Check(Parse({L"/verify", L"/drive:E", L"/upload-logs"}).options.uploadLogs, "/upload-logs is parsed");
    Check(!Parse({L"/verify", L"/drive:E"}).options.uploadLogs, "log upload is off by default");

    Check(medicat::NormalizeDriveLetter(L"e") == medicat::NormalizeDriveLetter(L"E:\\"),
          "drive letters normalize to one form");
    Check(medicat::IsSupportedLanguage(L"en") && !medicat::IsSupportedLanguage(L"xx"), "language codes are validated");
}

void TestVersionCompare() {
    using medicat::CompareInstallerVersionTags;
    Check(CompareInstallerVersionTags(L"1.0.43", L"1.0.42") == 1, "1.0.43 is newer than 1.0.42");
    Check(CompareInstallerVersionTags(L"1.0.9", L"1.0.10") == -1, "1.0.9 is older than 1.0.10 (numeric, not lexical)");
    Check(CompareInstallerVersionTags(L"1.0.5", L"1.0.5") == 0, "equal versions compare equal");
    Check(CompareInstallerVersionTags(L"3520", L"1.0.1") == -1, "legacy tag 3520 never counts as newer");
    Check(CompareInstallerVersionTags(L"1.0.1", L"3521-BETA") == 1, "semver beats a legacy tag");
}

void TestChecksumParsing() {
    const std::wstring body =
        L"9c1cccb8d81b41188d4e6da620703b4cde5cce92d9098eb162c21228bf4aa0ad  MedicatInstaller-x86.exe\r\n"
        L"BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD *MedicatInstaller.exe\n"
        L"deadbeef  Medicat_Installer.sh\n";
    Check(medicat::FindSha256ForAsset(body, L"MedicatInstaller.exe") ==
              "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
          "SHA256SUMS lookup handles the *name form and lowercases the digest");
    Check(medicat::FindSha256ForAsset(body, L"MedicatInstaller-x86.exe") ==
              "9c1cccb8d81b41188d4e6da620703b4cde5cce92d9098eb162c21228bf4aa0ad",
          "SHA256SUMS lookup handles CRLF lines");
    Check(medicat::FindSha256ForAsset(body, L"Medicat_Installer.sh").empty(), "short digests are rejected");
    Check(medicat::FindSha256ForAsset(body, L"missing.exe").empty(), "missing assets yield no digest");
}

void TestFileHashing() {
    const std::wstring path = WriteTempFile("abc");
    Check(!path.empty(), "temp file for hashing is created");
    if (path.empty()) {
        return;
    }
    std::string md5;
    std::string sha256;
    std::wstring error;
    Check(medicat::ComputeFileMd5(path, md5, error) && md5 == "900150983cd24fb0d6963f7d28e17f72",
          "MD5 of \"abc\" matches the reference vector");
    Check(medicat::ComputeFileSha256(path, sha256, error) &&
              sha256 == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
          "SHA-256 of \"abc\" matches the reference vector");
    DeleteFileW(path.c_str());
}

void TestPresenceCheck() {
    wchar_t dir[MAX_PATH]{};
    GetTempPathW(MAX_PATH, dir);
    const medicat::MedicatPresenceResult result = medicat::CheckMedicatPresenceOnDrive(dir);
    Check(result.markersTotal > 0, "presence markers are defined");
    Check(!result.likelyInstalled, "an empty folder is not a MediCat stick");
}

}  // namespace

static_assert(medicat::kMediCatSplitPartCount == 6, "spec: six Google Drive split parts");
static_assert(medicat::kMediCatMirrorCount >= 2, "spec: two mirrors feed the GUI buttons");
static_assert(medicat::kMediCatExtraCount >= 1, "spec: extras catalog is not empty");
static_assert(sizeof(medicat::kUpdateRepository) > sizeof(wchar_t), "spec: update repository is set");

int main() {
    TestCliParsing();
    TestVersionCompare();
    TestChecksumParsing();
    TestFileHashing();
    TestPresenceCheck();
    std::printf("%d checks, %d failures\n", g_checks, g_failures);
    return g_failures == 0 ? 0 : 1;
}
