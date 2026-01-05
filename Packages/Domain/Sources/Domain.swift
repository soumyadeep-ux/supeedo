// Domain.swift
// Supeedo - Domain Layer
//
// Core entities, protocols, and business logic interfaces.
// This package has no external dependencies.

import Foundation

// MARK: - Screenshot Entity

/// Represents a screenshot file with its metadata and analysis results.
public struct Screenshot: Identifiable, Codable, Sendable {
    public let id: UUID
    public let fileURL: URL
    public let createdAt: Date
    public let sha256: String

    /// Thumbnail data (JPEG compressed)
    public var thumbnailData: Data?

    /// Triage result from local analysis
    public var triageResult: TriageResult?

    /// Deep analysis result from cloud
    public var deepAnalysisResult: DeepAnalysisResult?

    public init(
        id: UUID = UUID(),
        fileURL: URL,
        createdAt: Date = Date(),
        sha256: String,
        thumbnailData: Data? = nil,
        triageResult: TriageResult? = nil,
        deepAnalysisResult: DeepAnalysisResult? = nil
    ) {
        self.id = id
        self.fileURL = fileURL
        self.createdAt = createdAt
        self.sha256 = sha256
        self.thumbnailData = thumbnailData
        self.triageResult = triageResult
        self.deepAnalysisResult = deepAnalysisResult
    }
}

// MARK: - Triage Result

/// Result of local AI triage (OCR + classification + sensitivity).
public struct TriageResult: Codable, Sendable {
    /// Category key (language-agnostic)
    public let categoryKey: String

    /// Classification confidence (0.0 - 1.0)
    public let confidence: Double

    /// Extracted text from OCR
    public let extractedText: String

    /// Detected entities (dates, amounts, phones, etc.)
    public let entities: [String: String]

    /// Sensitivity flags (e.g., "credit_card", "password")
    public let sensitivityFlags: [String]

    /// Processing time in milliseconds
    public let processingTimeMs: Int

    public init(
        categoryKey: String,
        confidence: Double,
        extractedText: String,
        entities: [String: String] = [:],
        sensitivityFlags: [String] = [],
        processingTimeMs: Int = 0
    ) {
        self.categoryKey = categoryKey
        self.confidence = confidence
        self.extractedText = extractedText
        self.entities = entities
        self.sensitivityFlags = sensitivityFlags
        self.processingTimeMs = processingTimeMs
    }

    /// Whether this screenshot contains sensitive content
    public var isSensitive: Bool {
        !sensitivityFlags.isEmpty
    }
}

// MARK: - Deep Analysis Result

/// Result of cloud-based deep analysis.
public struct DeepAnalysisResult: Codable, Sendable {
    /// The model used for analysis
    public let model: String

    /// Detailed description of the screenshot
    public let description: String

    /// Suggested actions based on content
    public let suggestedActions: [SuggestedAction]

    /// Additional insights
    public let insights: [String]

    /// Cost of this analysis in USD
    public let costUSD: Double

    /// Processing time in milliseconds
    public let processingTimeMs: Int

    public init(
        model: String,
        description: String,
        suggestedActions: [SuggestedAction] = [],
        insights: [String] = [],
        costUSD: Double,
        processingTimeMs: Int
    ) {
        self.model = model
        self.description = description
        self.suggestedActions = suggestedActions
        self.insights = insights
        self.costUSD = costUSD
        self.processingTimeMs = processingTimeMs
    }
}

// MARK: - Suggested Action

/// An action suggested based on screenshot content.
public enum SuggestedAction: Codable, Sendable {
    case createReminder(title: String, notes: String?, dueDate: Date?)
    case createCalendarEvent(title: String, startDate: Date, endDate: Date?, location: String?)
    case exportText(text: String)
    case archive
    case ignore

    /// Localized action title key
    public var titleKey: String {
        switch self {
        case .createReminder:
            return "action.createReminder"
        case .createCalendarEvent:
            return "action.createEvent"
        case .exportText:
            return "action.exportText"
        case .archive:
            return "action.archive"
        case .ignore:
            return "action.ignore"
        }
    }
}

// MARK: - Protocols

/// Protocol for screenshot repository (persistence layer).
public protocol ScreenshotRepositoryProtocol: Sendable {
    func save(_ screenshot: Screenshot) async throws
    func fetch(id: UUID) async throws -> Screenshot?
    func fetchAll() async throws -> [Screenshot]
    func fetchByCategory(_ categoryKey: String) async throws -> [Screenshot]
    func delete(id: UUID) async throws
    func search(query: String) async throws -> [Screenshot]
}

/// Protocol for folder watching service.
public protocol FolderWatcherProtocol: Sendable {
    func startWatching(folder: URL, onNewFile: @escaping @Sendable (URL) async -> Void) async throws
    func stopWatching() async
}

/// Protocol for OCR service.
public protocol OCRServiceProtocol: Sendable {
    func extractText(from imageURL: URL) async throws -> String
}

/// Protocol for triage classifier.
public protocol TriageClassifierProtocol: Sendable {
    func classify(text: String, imageURL: URL) async throws -> TriageResult
}
