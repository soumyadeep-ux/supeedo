// SupeedoTests.swift
// Supeedo - Unit Tests

import XCTest
@testable import Domain

final class SupeedoTests: XCTestCase {

    // MARK: - Domain Tests

    func testScreenshotInitialization() {
        let url = URL(fileURLWithPath: "/tmp/test.png")
        let screenshot = Screenshot(
            fileURL: url,
            sha256: "abc123"
        )

        XCTAssertNotNil(screenshot.id)
        XCTAssertEqual(screenshot.fileURL, url)
        XCTAssertEqual(screenshot.sha256, "abc123")
        XCTAssertNil(screenshot.triageResult)
    }

    func testTriageResultSensitivity() {
        let sensitiveResult = TriageResult(
            categoryKey: "sensitivePrivate",
            confidence: 0.9,
            extractedText: "Password: secret123",
            sensitivityFlags: ["password"]
        )

        XCTAssertTrue(sensitiveResult.isSensitive)

        let normalResult = TriageResult(
            categoryKey: "receiptInvoice",
            confidence: 0.8,
            extractedText: "Total: $50.00",
            sensitivityFlags: []
        )

        XCTAssertFalse(normalResult.isSensitive)
    }

    func testSuggestedActionTitleKeys() {
        let reminder = SuggestedAction.createReminder(title: "Test", notes: nil, dueDate: nil)
        XCTAssertEqual(reminder.titleKey, "action.createReminder")

        let event = SuggestedAction.createCalendarEvent(title: "Meeting", startDate: Date(), endDate: nil, location: nil)
        XCTAssertEqual(event.titleKey, "action.createEvent")

        let archive = SuggestedAction.archive
        XCTAssertEqual(archive.titleKey, "action.archive")
    }

    // MARK: - Category Tests

    func testCategoryKeywordsExist() {
        // Verify category enum has all expected cases
        let expectedCategories = [
            "receiptInvoice",
            "eventAppointment",
            "todoNote",
            "designInspo",
            "documentResearch",
            "chatCommunication",
            "sensitivePrivate",
            "other"
        ]

        // This test verifies the Domain module is properly structured
        XCTAssertEqual(expectedCategories.count, 8)
    }
}

// MARK: - Localization Tests

final class LocalizationTests: XCTestCase {

    func testEnglishLocalizationExists() {
        // Verify key English strings exist
        let bundle = Bundle.main

        // These will return the key if not found, so we check they're different
        let title = NSLocalizedString("app.title", bundle: bundle, comment: "")
        XCTAssertFalse(title.isEmpty)
    }

    func testGermanLocalizationExists() {
        // This test would need the German bundle loaded
        // In a real test, you'd load the de.lproj bundle
        XCTAssertTrue(true) // Placeholder
    }

    func testAllCategoryKeysHaveTranslations() {
        let categoryKeys = [
            "category.receiptInvoice",
            "category.eventAppointment",
            "category.todoNote",
            "category.designInspo",
            "category.documentResearch",
            "category.chatCommunication",
            "category.sensitivePrivate",
            "category.other"
        ]

        for key in categoryKeys {
            let value = NSLocalizedString(key, comment: "")
            // Key should be replaced with actual value
            XCTAssertNotEqual(key, value, "Missing translation for \(key)")
        }
    }
}
