// AIKitLocal.swift
// Supeedo - Local AI Module
//
// Vision framework OCR and heuristic classification.
// All processing is local - no network calls.

import Foundation
import Vision
import AppKit
import Domain

// MARK: - OCR Service

/// Extracts text from images using Apple's Vision framework.
public struct OCRService: OCRServiceProtocol, Sendable {

    public init() {}

    /// Extract text from an image file.
    /// - Parameter imageURL: URL to the image file
    /// - Returns: Extracted text content
    public func extractText(from imageURL: URL) async throws -> String {
        // Load image
        guard let image = NSImage(contentsOf: imageURL),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw OCRError.imageLoadFailed(imageURL)
        }

        return try await withCheckedThrowingContinuation { continuation in
            // Create text recognition request
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: OCRError.recognitionFailed(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                // Extract top candidate from each observation
                let text = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                continuation.resume(returning: text)
            }

            // Configure for accuracy
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            // Support English and German
            request.recognitionLanguages = ["en-US", "de-DE"]

            // Perform request
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: OCRError.recognitionFailed(error))
            }
        }
    }
}

// MARK: - Triage Classifier

/// Classifies screenshots based on OCR text and visual features.
public struct TriageClassifier: TriageClassifierProtocol, Sendable {

    private let ocrService: OCRService

    public init(ocrService: OCRService = OCRService()) {
        self.ocrService = ocrService
    }

    /// Classify a screenshot based on its content.
    public func classify(text: String, imageURL: URL) async throws -> TriageResult {
        let startTime = Date()

        // Get text if not provided
        let ocrText = text.isEmpty ? try await ocrService.extractText(from: imageURL) : text

        // Detect category
        let (categoryKey, confidence) = detectCategory(from: ocrText)

        // Extract entities
        let entities = extractEntities(from: ocrText)

        // Detect sensitivity
        let sensitivityFlags = detectSensitivity(from: ocrText)

        let processingTime = Int(Date().timeIntervalSince(startTime) * 1000)

        return TriageResult(
            categoryKey: categoryKey,
            confidence: confidence,
            extractedText: ocrText,
            entities: entities,
            sensitivityFlags: sensitivityFlags,
            processingTimeMs: processingTime
        )
    }

    // MARK: - Category Detection

    private func detectCategory(from text: String) -> (String, Double) {
        let lowercasedText = text.lowercased()

        // Score each category based on keyword matches
        var scores: [(String, Double)] = []

        let categories = CategoryKeywords.all
        for (key, keywords) in categories {
            let matchCount = keywords.filter { lowercasedText.contains($0.lowercased()) }.count
            if matchCount > 0 {
                let score = Double(matchCount) / Double(keywords.count)
                scores.append((key, score))
            }
        }

        // Return highest scoring category
        if let best = scores.max(by: { $0.1 < $1.1 }) {
            return (best.0, min(best.1 * 2, 1.0))  // Scale up confidence
        }

        return ("other", 0.3)
    }

    // MARK: - Entity Extraction

    private func extractEntities(from text: String) -> [String: String] {
        var entities: [String: String] = [:]

        // Extract dates
        let dateDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        if let matches = dateDetector?.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            for match in matches.prefix(3) {  // Limit to 3 dates
                if let date = match.date {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    entities["date_\(entities.count)"] = formatter.string(from: date)
                }
            }
        }

        // Extract amounts (simple regex for currency)
        let amountPattern = #"[$€£]\s*\d+[.,]?\d*|\d+[.,]\d+\s*(?:USD|EUR|GBP)"#
        if let regex = try? NSRegularExpression(pattern: amountPattern, options: .caseInsensitive) {
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            for match in matches.prefix(3) {
                if let range = Range(match.range, in: text) {
                    entities["amount_\(entities.count)"] = String(text[range])
                }
            }
        }

        // Extract phone numbers
        let phoneDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        if let matches = phoneDetector?.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            for match in matches.prefix(2) {
                if let phone = match.phoneNumber {
                    entities["phone_\(entities.count)"] = phone
                }
            }
        }

        return entities
    }

    // MARK: - Sensitivity Detection

    private func detectSensitivity(from text: String) -> [String] {
        let lowercasedText = text.lowercased()
        var flags: [String] = []

        // Credit card pattern (16 digits, possibly with spaces/dashes)
        let creditCardPattern = #"\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b"#
        if let regex = try? NSRegularExpression(pattern: creditCardPattern),
           regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil {
            flags.append("credit_card")
        }

        // Password indicators
        let passwordKeywords = ["password", "passwort", "kennwort", "pin code", "secret key"]
        if passwordKeywords.contains(where: { lowercasedText.contains($0) }) {
            flags.append("password")
        }

        // SSN pattern (US)
        let ssnPattern = #"\b\d{3}-\d{2}-\d{4}\b"#
        if let regex = try? NSRegularExpression(pattern: ssnPattern),
           regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil {
            flags.append("ssn")
        }

        // Banking keywords
        let bankingKeywords = ["account number", "routing number", "kontonummer", "bankleitzahl", "iban"]
        if bankingKeywords.contains(where: { lowercasedText.contains($0) }) {
            flags.append("banking")
        }

        return flags
    }
}

// MARK: - Category Keywords

private enum CategoryKeywords {
    static let all: [String: [String]] = [
        "receiptInvoice": ["total", "tax", "subtotal", "invoice", "receipt", "payment",
                           "$", "€", "£", "amount", "qty", "price", "rechnung", "betrag"],
        "eventAppointment": ["calendar", "meeting", "appointment", "event", "schedule",
                             "termin", "besprechung", "am", "pm"],
        "todoNote": ["todo", "task", "reminder", "note", "checklist", "aufgabe",
                     "erinnerung", "notiz"],
        "designInspo": ["design", "ui", "ux", "figma", "sketch", "prototype", "mockup"],
        "documentResearch": ["abstract", "introduction", "conclusion", "references",
                             "section", "chapter", "einleitung", "zusammenfassung"],
        "chatCommunication": ["sent", "delivered", "read", "typing", "message",
                              "gesendet", "zugestellt", "gelesen"],
        "sensitivePrivate": ["password", "ssn", "credit card", "cvv", "passwort",
                             "geheim", "vertraulich"]
    ]
}

// MARK: - Errors

public enum OCRError: Error, LocalizedError {
    case imageLoadFailed(URL)
    case recognitionFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .imageLoadFailed(let url):
            return "Failed to load image: \(url.lastPathComponent)"
        case .recognitionFailed(let error):
            return "Text recognition failed: \(error.localizedDescription)"
        }
    }
}
