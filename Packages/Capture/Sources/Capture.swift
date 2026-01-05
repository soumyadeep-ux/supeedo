// Capture.swift
// Supeedo - Capture Module
//
// Folder watching and screenshot ingestion using FSEvents.

import Foundation
import Domain

// MARK: - Folder Watcher

/// Watches a folder for new screenshot files using FSEvents.
public actor FolderWatcher: FolderWatcherProtocol {

    // MARK: - Properties

    private var watchedURL: URL?
    private var eventStream: FSEventStreamRef?
    private var isRunning = false
    private var fileHandler: (@Sendable (URL) async -> Void)?

    // MARK: - Initialization

    public init() {}

    // MARK: - FolderWatcherProtocol

    public func startWatching(folder: URL, onNewFile: @escaping @Sendable (URL) async -> Void) async throws {
        guard !isRunning else { return }

        // Verify folder exists
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: folder.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            throw FolderWatcherError.folderNotFound(folder)
        }

        watchedURL = folder
        isRunning = true
        fileHandler = onNewFile

        // Start FSEvents stream
        try await startEventStream(for: folder)

        print("[FolderWatcher] Started watching: \(folder.path)")
    }

    public func stopWatching() async {
        guard isRunning else { return }

        if let stream = eventStream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            eventStream = nil
        }

        isRunning = false
        watchedURL = nil
        fileHandler = nil

        print("[FolderWatcher] Stopped watching")
    }

    // MARK: - Private

    private func startEventStream(for folder: URL) async throws {
        // For now, use a simple polling approach
        // Full FSEvents implementation would require more complex setup
        // This is a placeholder that demonstrates the API

        Task { [weak self] in
            guard let self = self else { return }

            var knownFiles = Set<String>()

            // Initial scan
            if let contents = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
                for file in contents {
                    knownFiles.insert(file.lastPathComponent)
                }
            }

            // Polling loop (every 2 seconds)
            while await self.isRunning {
                try? await Task.sleep(for: .seconds(2))

                guard await self.isRunning else { break }
                let handler = await self.fileHandler

                if let contents = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
                    for file in contents where file.pathExtension.lowercased() == "png" {
                        let filename = file.lastPathComponent
                        if !knownFiles.contains(filename) {
                            knownFiles.insert(filename)
                            await handler?(file)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Errors

public enum FolderWatcherError: Error, LocalizedError {
    case folderNotFound(URL)
    case permissionDenied(URL)

    public var errorDescription: String? {
        switch self {
        case .folderNotFound(let url):
            return "Folder not found: \(url.path)"
        case .permissionDenied(let url):
            return "Permission denied: \(url.path)"
        }
    }
}

// MARK: - Security Bookmark Helper

/// Manages security-scoped bookmarks for folder access persistence.
public struct SecurityBookmarkManager {

    private static let bookmarkKey = "watchedFolderBookmark"

    /// Save a security-scoped bookmark for a URL.
    public static func saveBookmark(for url: URL) throws {
        let bookmarkData = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
    }

    /// Restore a URL from a saved security-scoped bookmark.
    public static func restoreBookmark() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return nil
        }

        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: bookmarkData,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            return nil
        }

        // Start accessing security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            return nil
        }

        // If bookmark is stale, try to refresh it
        if isStale {
            try? saveBookmark(for: url)
        }

        return url
    }

    /// Clear saved bookmark.
    public static func clearBookmark() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
    }
}
