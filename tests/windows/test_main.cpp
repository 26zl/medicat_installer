// Console test runner for installer logic that needs no GUI, USB stick or network.
// Built as MedicatTests when CMake is configured with -DMEDICAT_BUILD_TESTS=ON.
#include "cli.h"
#include "extras.h"
#include "spec_generated.h"
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

    Check(Parse({L"/list-extras"}).options.action == CliAction::ListExtras, "/list-extras selects the catalog action");
    const auto extrasOnly = Parse({L"/extras:memtest86plus,caine", L"/drive:E"});
    Check(extrasOnly.ok && extrasOnly.options.action == CliAction::Extras, "/extras with a drive is its own action");
    Check(Parse({L"/extras:all"}).errorCode == 2, "/extras without /drive fails with exit code 2");
    Check(Parse({L"/extras:nope", L"/drive:E"}).errorCode == 2, "unknown catalog id fails with exit code 2");
    const auto installExtras = Parse({L"/install", L"/drive:E", L"/yes", L"/extras:all"});
    Check(installExtras.ok && installExtras.options.action == CliAction::Install &&
              installExtras.options.extras == L"all",
          "/extras rides along with /install");
}

void TestExtrasCatalog() {
    std::vector<const medicat::MediCatExtra*> entries;
    std::wstring error;
    Check(medicat::ResolveExtrasSelection(L"all", entries, error) && entries.size() == medicat::kMediCatExtraCount,
          "\"all\" selects the whole catalog");
    Check(medicat::ResolveExtrasSelection(L"none", entries, error) && entries.empty(), "\"none\" selects nothing");
    Check(medicat::ResolveExtrasSelection(L" memtest86plus , caine ,memtest86plus", entries, error) &&
              entries.size() == 2,
          "ids are trimmed and de-duplicated");
    Check(!medicat::ResolveExtrasSelection(L"nope", entries, error) && !error.empty() && entries.empty(),
          "unknown ids are rejected with a message");
    const std::wstring catalog = medicat::FormatExtrasCatalog();
    Check(catalog.find(L"systemrescue") != std::wstring::npos && catalog.find(L"manual") != std::wstring::npos,
          "the catalog listing names entries and manual downloads");
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

int main() {
    TestCliParsing();
    TestExtrasCatalog();
    TestFileHashing();
    TestPresenceCheck();
    std::printf("%d checks, %d failures\n", g_checks, g_failures);
    return g_failures == 0 ? 0 : 1;
}
