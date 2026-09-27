#pragma once

#include <cstdint>
#include <functional>
#include <string>

namespace medicat {

struct InstallerUpdateInfo {
    bool updateAvailable = false;
    int remoteBuild = 0;
    std::wstring version;
    std::wstring releaseTag;
    std::wstring releaseUrl;
    std::wstring downloadUrl;
    std::wstring checksumsUrl;  // SHA256SUMS.txt asset of the same release
};

struct UpdateCheckResult {
    bool success = false;
    std::wstring error;
    InstallerUpdateInfo info;
};

UpdateCheckResult CheckForInstallerUpdate();

// -1, 0 or 1 like strcmp; tags that are not M.m.p semver never count as newer.
int CompareInstallerVersionTags(const std::wstring& a, const std::wstring& b);
// Pick the expected lowercase SHA-256 for assetName out of a SHA256SUMS.txt body ("hex  name" lines).
std::string FindSha256ForAsset(const std::wstring& checksumsBody, const std::wstring& assetName);

std::wstring GetInstallerAssetFileName();
bool DownloadAndRelaunchInstallerUpdate(const InstallerUpdateInfo& info,
                                        const std::function<void(uint64_t downloaded, uint64_t total)>& onProgress,
                                        const std::function<void(const std::wstring&)>& onLog, std::wstring& error);

}  // namespace medicat
