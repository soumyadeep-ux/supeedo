// Data.swift
// Supeedo - Data Layer
//
// Persistence using Codable + JSON file storage.
// SwiftData macros require Xcode builds, so we use simple file-based storage for SPM compatibility.

import Foundation
import Domain

#if canImport(AppKit)
import AppKit
#endif

#if canImport(CommonCrypto)
import CommonCrypto
#endif

// MARK: - Screenshot Repository

/// Repository for screenshot persistence using JSON file storage.
public actor ScreenshotRepository: ScreenshotRepositoryProtocol {

    private var screenshots: [UUID: Screenshot] = [:]
    private let storageURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init() throws {
        // Store in Application Support/Supeedo/
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let supeedoDir = appSupport.appendingPathComponent("Supeedo", isDirectory: true)

        // Create directory if needed
        try FileManager.default.createDirectory(at: supeedoDir, withIntermediateDirectories: true)

        self.storageURL = supeedoDir.appendingPathComponent("screenshots.json")

        // Load existing data (nonisolated helper)
        self.screenshots = Self.loadScreenshotsFromDisk(at: storageURL)
    }

    /// Nonisolated helper to load screenshots from disk during init
    private nonisolated static func loadScreenshotsFromDisk(at url: URL) -> [UUID: Screenshot] {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return [:]
        }

        do {
            let data = try Data(contentsOf: url)
            let loaded = try JSONDecoder().decode([Screenshot].self, from: data)
            return Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
        } catch {
            print("[ScreenshotRepository] Failed to load from disk: \(error)")
            return [:]
        }
    }

    // MARK: - ScreenshotRepositoryProtocol

    public func save(_ screenshot: Screenshot) async throws {
        screenshots[screenshot.id] = screenshot
        try saveToDisk()
    }

    public func fetch(id: UUID) async throws -> Screenshot? {
        return screenshots[id]
    }

    public func fetchAll() async throws -> [Screenshot] {
        return screenshots.values
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func fetchByCategory(_ categoryKey: String) async throws -> [Screenshot] {
        return screenshots.values
            .filter { $0.triageResult?.categoryKey == categoryKey }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func delete(id: UUID) async throws {
        screenshots.removeValue(forKey: id)
        try saveToDisk()
    }

    public func search(query: String) async throws -> [Screenshot] {
        let lowercasedQuery = query.lowercased()
        return screenshots.values
            .filter { $0.triageResult?.extractedText.lowercased().contains(lowercasedQuery) ?? false }
            .sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Private Storage

    private func saveToDisk() throws {
        let data = try encoder.encode(Array(screenshots.values))
        try data.write(to: storageURL, options: .atomic)
    }
}

// MARK: - File Hasher

/// Computes SHA-256 hash for files.
public struct FileHasher {

    /// Compute SHA-256 hash of a file.
    public static func sha256(of url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        return sha256(of: data)
    }

    /// Compute SHA-256 hash of data using CryptoKit-style implementation.
    public static func sha256(of data: Data) -> String {
        // Simple SHA-256 implementation without CommonCrypto dependency
        // In production, use CryptoKit on macOS 10.15+
        var hash = [UInt8](repeating: 0, count: 32)

        #if canImport(CommonCrypto)
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        #else
        // Fallback: use data hash (not cryptographically secure, but works for deduplication)
        let hashValue = data.hashValue
        withUnsafeBytes(of: hashValue) { bytes in
            for (index, byte) in bytes.enumerated() where index < 32 {
                hash[index] = byte
            }
        }
        #endif

        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Thumbnail Generator

/// Generates thumbnails for screenshots.
public struct ThumbnailGenerator {

    /// Generate a JPEG thumbnail for an image.
    /// - Parameters:
    ///   - url: Source image URL
    ///   - maxSize: Maximum dimension (width or height)
    ///   - quality: JPEG quality (0.0 - 1.0)
    /// - Returns: JPEG data
    #if canImport(AppKit)
    public static func generateThumbnail(
        for url: URL,
        maxSize: CGFloat = 200,
        quality: CGFloat = 0.7
    ) throws -> Data {
        guard let image = NSImage(contentsOf: url) else {
            throw ThumbnailError.imageLoadFailed
        }

        let originalSize = image.size
        let scale = min(maxSize / originalSize.width, maxSize / originalSize.height, 1.0)
        let newSize = NSSize(
            width: originalSize.width * scale,
            height: originalSize.height * scale
        )

        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        image.draw(
            in: NSRect(origin: .zero, size: newSize),
            from: NSRect(origin: .zero, size: originalSize),
            operation: .copy,
            fraction: 1.0
        )
        resizedImage.unlockFocus()

        guard let tiffData = resizedImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: quality]) else {
            throw ThumbnailError.conversionFailed
        }

        return jpegData
    }
    #endif
}

public enum ThumbnailError: Error, LocalizedError {
    case imageLoadFailed
    case conversionFailed

    public var errorDescription: String? {
        switch self {
        case .imageLoadFailed:
            return "Failed to load image"
        case .conversionFailed:
            return "Failed to convert image to thumbnail"
        }
    }
}
