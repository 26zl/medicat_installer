#pragma once

#include <shellapi.h>
#include <windows.h>

// Archive name/size/hashes, split parts, mirrors, manifest URLs and the extras catalog
// are generated from spec/medicat.json and spec/extras.json (tools/gen_spec.py).
#include "spec_generated.h"

namespace medicat {

inline bool OpenBrowserUrl(const wchar_t* url) {
    if (!url || !*url) {
        return false;
    }
    const HINSTANCE result =
        ShellExecuteW(nullptr, L"open", url, nullptr, nullptr, SW_SHOWNORMAL);
    return reinterpret_cast<INT_PTR>(result) > 32;
}

}  // namespace medicat
