#include "extras.h"

#include "download.h"
#include "extract.h"
#include "util.h"
#include "verify.h"

#include <shlobj.h>
#include <windows.h>

#include <fstream>
#include <iomanip>
#include <sstream>

namespace medicat {

namespace {

std::wstring Trim(const std::wstring& text) {
    const size_t start = text.find_first_not_of(L" \t");
    if (start == std::wstring::npos) {
        return {};
    }
    const size_t end = text.find_last_not_of(L" \t");
    return text.substr(start, end - start + 1);
}

const MediCatExtra* FindExtra(const std::wstring& id) {
    for (const MediCatExtra& entry : kMediCatExtras) {
        if (_wcsicmp(entry.id, id.c_str()) == 0) {
            return &entry;
        }
    }
    return nullptr;
}

bool EnsureDirectory(const std::wstring& path) {
    const int status = SHCreateDirectoryExW(nullptr, path.c_str(), nullptr);
    return status == ERROR_SUCCESS || status == ERROR_ALREADY_EXISTS || status == ERROR_FILE_EXISTS;
}

std::wstring UrlFileName(const std::wstring& url) {
    const size_t slash = url.find_last_of(L'/');
    std::wstring name = slash == std::wstring::npos ? url : url.substr(slash + 1);
    const size_t query = name.find_first_of(L"?#");
    if (query != std::wstring::npos) {
        name = name.substr(0, query);
    }
    return name;
}

bool HasChecksum(const MediCatExtra& entry) {
    return entry.sha256[0] || entry.sha512[0] || entry.sha1[0] || entry.md5[0];
}

// Strongest published digest first, mirroring the Linux installer.
bool ChecksumMatches(const std::wstring& path, const MediCatExtra& entry, std::wstring& error) {
    std::string actual;
    std::string expected;
    bool ok = false;
    if (entry.sha256[0]) {
        expected = entry.sha256;
        ok = ComputeFileSha256(path, actual, error);
    } else if (entry.sha512[0]) {
        expected = entry.sha512;
        ok = ComputeFileSha512(path, actual, error);
    } else if (entry.sha1[0]) {
        expected = entry.sha1;
        ok = ComputeFileSha1(path, actual, error);
    } else if (entry.md5[0]) {
        expected = entry.md5;
        ok = ComputeFileMd5(path, actual, error);
    } else {
        error = L"no checksum in the catalog";
        return false;
    }
    if (!ok) {
        return false;
    }
    if (actual != expected) {
        error = L"checksum mismatch";
        return false;
    }
    return true;
}

std::wstring DigestLabel(const MediCatExtra& entry) {
    if (entry.sha256[0]) {
        return L"sha256:" + Utf8ToWide(entry.sha256);
    }
    if (entry.sha512[0]) {
        return L"sha512:" + Utf8ToWide(entry.sha512);
    }
    if (entry.sha1[0]) {
        return L"sha1:" + Utf8ToWide(entry.sha1);
    }
    return L"md5:" + Utf8ToWide(entry.md5);
}

void AppendManifest(const std::wstring& extrasRoot, const MediCatExtra& entry) {
    SYSTEMTIME now{};
    GetLocalTime(&now);
    std::wostringstream line;
    line << entry.id << L'\t' << entry.version << L'\t' << entry.category << L'/' << entry.fileName << L'\t'
         << DigestLabel(entry) << L'\t' << now.wYear << L'-' << std::setw(2) << std::setfill(L'0') << now.wMonth
         << L'-' << std::setw(2) << std::setfill(L'0') << now.wDay << L'\n';
    const std::wstring path = JoinPath(extrasRoot, L"extras_manifest.txt");
    std::ofstream out(path.c_str(), std::ios::binary | std::ios::app);
    if (out) {
        out << WideToUtf8(line.str());
    }
}

void RemoveDirectoryTree(const std::wstring& dir) {
    WIN32_FIND_DATAW data{};
    const HANDLE find = FindFirstFileW(JoinPath(dir, L"*").c_str(), &data);
    if (find != INVALID_HANDLE_VALUE) {
        do {
            const std::wstring name = data.cFileName;
            if (name == L"." || name == L"..") {
                continue;
            }
            const std::wstring child = JoinPath(dir, name);
            if (data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                RemoveDirectoryTree(child);
            } else {
                DeleteFileW(child.c_str());
            }
        } while (FindNextFileW(find, &data));
        FindClose(find);
    }
    RemoveDirectoryW(dir.c_str());
}

}  // namespace

bool ResolveExtrasSelection(const std::wstring& selection, std::vector<const MediCatExtra*>& out,
                            std::wstring& error) {
    out.clear();
    error.clear();
    const std::wstring trimmed = Trim(selection);
    if (trimmed.empty() || _wcsicmp(trimmed.c_str(), L"none") == 0) {
        return true;
    }
    if (_wcsicmp(trimmed.c_str(), L"all") == 0) {
        for (const MediCatExtra& entry : kMediCatExtras) {
            out.push_back(&entry);
        }
        return true;
    }
    size_t start = 0;
    while (start <= trimmed.size()) {
        size_t comma = trimmed.find(L',', start);
        if (comma == std::wstring::npos) {
            comma = trimmed.size();
        }
        const std::wstring id = Trim(trimmed.substr(start, comma - start));
        start = comma + 1;
        if (id.empty()) {
            continue;
        }
        const MediCatExtra* entry = FindExtra(id);
        if (!entry) {
            error = L"Unknown extras id: " + id + L" (see /list-extras)";
            out.clear();
            return false;
        }
        bool duplicate = false;
        for (const MediCatExtra* existing : out) {
            duplicate = duplicate || existing == entry;
        }
        if (!duplicate) {
            out.push_back(entry);
        }
    }
    return true;
}

std::wstring FormatExtrasCatalog() {
    std::wostringstream out;
    out << L"Extras catalog " << kExtrasCatalogVersion << L" (files land in <drive>:\\" << kExtrasDestRoot
        << L"\\<category>\\)\n\n";
    out << std::left << std::setw(20) << L"ID" << std::setw(30) << L"NAME" << std::setw(22) << L"VERSION"
        << std::setw(11) << L"SIZE" << std::setw(15) << L"FOR" << L"CATEGORY\n";
    for (const MediCatExtra& entry : kMediCatExtras) {
        const std::wstring size = wcscmp(entry.type, L"iso") == 0 ? FormatBytes(entry.bytes) : L"manual";
        out << std::left << std::setw(20) << entry.id << std::setw(30) << entry.name << std::setw(22)
            << entry.version << std::setw(11) << size << std::setw(15) << entry.targets << entry.category << L'\n';
    }
    out << L'\n';
    for (const MediCatExtra& entry : kMediCatExtras) {
        out << entry.id << L": " << entry.description << L"\n    " << entry.homepage << L'\n';
    }
    return out.str();
}

ExtrasInstallResult InstallExtras(const std::wstring& driveRoot, const std::vector<const MediCatExtra*>& entries,
                                  const std::wstring& sevenZaExe, const ExtrasLog& log,
                                  const ExtrasProgress& onProgress) {
    ExtrasInstallResult result;
    result.requested = entries.size();
    const auto say = [&](const std::wstring& message) {
        if (log) {
            log(message);
        }
    };
    const auto fail = [&](const MediCatExtra& entry, const std::wstring& why) {
        ++result.failed;
        result.failures.push_back(std::wstring(entry.id) + L": " + why);
        say(L"[Extras] " + std::wstring(entry.name) + L" failed: " + why);
    };

    std::wstring root = driveRoot;
    if (!root.empty() && root.back() != L'\\') {
        root += L'\\';
    }
    const std::wstring extrasRoot = JoinPath(root, kExtrasDestRoot);
    if (!EnsureDirectory(extrasRoot)) {
        say(L"[Extras] Could not create " + extrasRoot);
        result.failed = entries.size();
        return result;
    }

    uint64_t needed = 0;
    for (const MediCatExtra* entry : entries) {
        if (wcscmp(entry->type, L"iso") == 0 &&
            !FileExists(JoinPath(JoinPath(extrasRoot, entry->category), entry->fileName))) {
            needed += entry->bytes;
        }
    }
    ULARGE_INTEGER freeBytes{};
    if (GetDiskFreeSpaceExW(root.c_str(), &freeBytes, nullptr, nullptr) && freeBytes.QuadPart < needed) {
        say(L"[Extras] Not enough free space on " + root + L": need " + FormatBytes(needed) + L", have " +
            FormatBytes(freeBytes.QuadPart));
        result.failed = entries.size();
        return result;
    }

    for (const MediCatExtra* entryPtr : entries) {
        const MediCatExtra& entry = *entryPtr;
        const std::wstring dest = JoinPath(extrasRoot, entry.category);
        const std::wstring target = JoinPath(dest, entry.fileName);
        if (!EnsureDirectory(dest)) {
            fail(entry, L"could not create " + dest);
            continue;
        }

        if (wcscmp(entry.type, L"manual") == 0) {
            ++result.manual;
            say(L"[Extras] " + std::wstring(entry.name) + L": download it yourself from " + entry.url +
                L" and copy the ISO into " + dest);
            continue;
        }

        if (FileExists(target)) {
            std::wstring checkError;
            if (entry.unpackFormat[0] || ChecksumMatches(target, entry, checkError)) {
                ++result.present;
                say(L"[Extras] " + std::wstring(entry.name) + L" already present: " + target);
                continue;
            }
            say(L"[Extras] " + std::wstring(entry.name) + L" exists but fails its checksum; downloading again");
            DeleteFileW(target.c_str());
        }

        if (!HasChecksum(entry)) {
            fail(entry, L"catalog entry has no checksum");
            continue;
        }

        const bool unpack = entry.unpackFormat[0] != L'\0';
        const std::wstring downloadName = unpack ? UrlFileName(entry.url) : std::wstring(entry.fileName);
        const std::wstring downloadPath = JoinPath(dest, downloadName + L".part");
        DeleteFileW(downloadPath.c_str());
        say(L"[Extras] Downloading " + std::wstring(entry.name) + L" (" + FormatBytes(entry.bytes) + L") from " +
            entry.url);
        std::wstring error;
        const bool downloaded = HttpDownloadFileWithProgress(
            entry.url, downloadPath,
            [&](const uint64_t downloadedBytes, const uint64_t total) {
                if (onProgress) {
                    onProgress(entry, downloadedBytes, total);
                }
            },
            error);
        if (!downloaded) {
            DeleteFileW(downloadPath.c_str());
            fail(entry, L"download failed: " + error);
            continue;
        }
        if (!ChecksumMatches(downloadPath, entry, error)) {
            DeleteFileW(downloadPath.c_str());
            fail(entry, error);
            continue;
        }

        if (unpack) {
            if (sevenZaExe.empty() || !FileExists(sevenZaExe)) {
                DeleteFileW(downloadPath.c_str());
                fail(entry, L"7za.exe is not available to unpack " + downloadName);
                continue;
            }
            const std::wstring tempDir = JoinPath(dest, L".extract_tmp");
            RemoveDirectoryTree(tempDir);
            EnsureDirectory(tempDir);
            const ExtractResult extracted = Extract7zArchive(
                sevenZaExe, downloadPath, tempDir, 0, 0, [](const ExtractProgress&) {}, L"", false);
            const std::wstring member = JoinPath(tempDir, entry.unpackMember);
            if (!extracted.success || !FileExists(member) ||
                !MoveFileExW(member.c_str(), target.c_str(), MOVEFILE_REPLACE_EXISTING)) {
                RemoveDirectoryTree(tempDir);
                DeleteFileW(downloadPath.c_str());
                fail(entry, L"could not unpack " + std::wstring(entry.unpackMember) + L" from " + downloadName);
                continue;
            }
            RemoveDirectoryTree(tempDir);
            DeleteFileW(downloadPath.c_str());
        } else if (!MoveFileExW(downloadPath.c_str(), target.c_str(), MOVEFILE_REPLACE_EXISTING)) {
            DeleteFileW(downloadPath.c_str());
            fail(entry, L"could not move the download into place: " + FormatWindowsError(GetLastError()));
            continue;
        }

        AppendManifest(extrasRoot, entry);
        ++result.installed;
        say(L"[Extras] Added " + std::wstring(entry.name) + L" -> " + target);
    }
    return result;
}

}  // namespace medicat
