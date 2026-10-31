#pragma once

#include <cstdint>
#include <functional>
#include <string>

namespace medicat {

void SetAria2cPath(const std::wstring& path);

// Small HTTPS fetch for metadata the checks depend on (GitHub API, sha256.txt): a plain-HTTP URL or
// a redirect from HTTPS to HTTP fails the request.
bool HttpGet(const std::wstring& url, std::wstring& body, std::wstring& error);
int HttpPostJson(const std::wstring& url, const std::string& jsonBody, const std::wstring& bearerToken,
                 std::wstring& error);

struct HttpMultipartResult {
    int statusCode = 0;
    std::wstring keyword;
    std::wstring uploadId;
    std::wstring error;
};

HttpMultipartResult HttpPostMultipartUpload(const std::wstring& url, const std::wstring& bearerToken,
                                            const std::wstring& sessionId, const std::string& manifestJson,
                                            const std::wstring& zipPath);
// Payload download (aria2c when bundled, WinHTTP otherwise). Every redirect is followed, HTTPS to
// HTTP included, so the caller must verify the file against a checksum afterwards.
bool HttpDownloadFile(const std::wstring& url, const std::wstring& outputPath, std::wstring& error);
// For a file that is itself the checksum source (the MD5 manifest): WinHTTP only, HTTPS only, and a
// redirect to plain HTTP fails the download.
bool HttpDownloadMetadataFile(const std::wstring& url, const std::wstring& outputPath, std::wstring& error);
bool HttpDownloadFileWithProgress(const std::wstring& url, const std::wstring& outputPath,
                                  const std::function<void(uint64_t downloaded, uint64_t total)>& onProgress,
                                  std::wstring& error);
bool TorrentDownloadFileWithProgress(const std::wstring& url, const std::wstring& outputPath,
                                     const std::function<void(uint64_t downloaded, uint64_t total)>& onProgress,
                                     std::wstring& error);
bool TestInternetConnection(std::wstring& error);

}  // namespace medicat
