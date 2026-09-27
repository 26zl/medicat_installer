#pragma once

#include "spec_generated.h"

#include <cstdint>
#include <functional>
#include <string>
#include <vector>

namespace medicat {

struct ExtrasInstallResult {
    size_t requested = 0;
    size_t installed = 0;  // downloaded and verified in this run
    size_t present = 0;    // already on the drive
    size_t manual = 0;     // vendor only offers a browser download
    size_t failed = 0;
    std::vector<std::wstring> failures;
};

// "all", "none" or comma-separated catalog ids (spaces allowed). Unknown ids fill `error`.
bool ResolveExtrasSelection(const std::wstring& selection, std::vector<const MediCatExtra*>& out,
                            std::wstring& error);

// One line per catalog entry for /list-extras.
std::wstring FormatExtrasCatalog();

using ExtrasLog = std::function<void(const std::wstring&)>;
using ExtrasProgress = std::function<void(const MediCatExtra& entry, uint64_t downloaded, uint64_t total)>;

// Download the entries into <driveRoot>\Extras\<category>\, verify them with the catalog
// checksum, unpack zipped images with 7za and record them in Extras\extras_manifest.txt.
ExtrasInstallResult InstallExtras(const std::wstring& driveRoot, const std::vector<const MediCatExtra*>& entries,
                                  const std::wstring& sevenZaExe, const ExtrasLog& log,
                                  const ExtrasProgress& onProgress);

}  // namespace medicat
