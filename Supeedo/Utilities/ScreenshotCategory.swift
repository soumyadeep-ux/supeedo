// ScreenshotCategory.swift
// Supeedo - Screenshot Categories
//
// Language-agnostic category keys with localized display names.

import SwiftUI

/// Screenshot category classification.
/// Raw values are stable keys stored in database.
/// Display names are localized at render time.
enum ScreenshotCategory: String, CaseIterable, Identifiable, Codable {
    case receiptInvoice
    case eventAppointment
    case todoNote
    case designInspo
    case documentResearch
    case chatCommunication
    case sensitivePrivate
    case other

    var id: String { rawValue }

    // MARK: - Localized Display Name

    /// Returns the localized display name for this category.
    var localizedName: String {
        switch self {
        case .receiptInvoice:
            return L10n.Category.receiptInvoice
        case .eventAppointment:
            return L10n.Category.eventAppointment
        case .todoNote:
            return L10n.Category.todoNote
        case .designInspo:
            return L10n.Category.designInspo
        case .documentResearch:
            return L10n.Category.documentResearch
        case .chatCommunication:
            return L10n.Category.chatCommunication
        case .sensitivePrivate:
            return L10n.Category.sensitivePrivate
        case .other:
            return L10n.Category.other
        }
    }

    // MARK: - Icon

    /// SF Symbol name for category icon.
    var iconName: String {
        switch self {
        case .receiptInvoice:
            return "doc.text"
        case .eventAppointment:
            return "calendar"
        case .todoNote:
            return "checklist"
        case .designInspo:
            return "paintpalette"
        case .documentResearch:
            return "doc.richtext"
        case .chatCommunication:
            return "bubble.left.and.bubble.right"
        case .sensitivePrivate:
            return "lock.shield"
        case .other:
            return "square.grid.2x2"
        }
    }

    // MARK: - Color

    /// Color associated with this category.
    var color: Color {
        switch self {
        case .receiptInvoice:
            return .green
        case .eventAppointment:
            return .blue
        case .todoNote:
            return .orange
        case .designInspo:
            return .purple
        case .documentResearch:
            return .gray
        case .chatCommunication:
            return .cyan
        case .sensitivePrivate:
            return .red
        case .other:
            return .secondary
        }
    }

    // MARK: - Classification Keywords

    /// Keywords used for heuristic classification.
    /// These are language-agnostic patterns used for detection.
    var classificationKeywords: [String] {
        switch self {
        case .receiptInvoice:
            return ["total", "tax", "subtotal", "invoice", "receipt", "payment",
                    "$", "€", "£", "amount", "qty", "quantity", "price"]
        case .eventAppointment:
            return ["calendar", "meeting", "appointment", "event", "schedule",
                    "am", "pm", "monday", "tuesday", "wednesday", "thursday",
                    "friday", "saturday", "sunday", "jan", "feb", "mar", "apr",
                    "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
        case .todoNote:
            return ["todo", "task", "reminder", "note", "checklist", "✓", "☐",
                    "☑", "•", "action item", "deadline", "priority"]
        case .designInspo:
            return ["design", "ui", "ux", "figma", "sketch", "dribbble",
                    "behance", "prototype", "mockup", "wireframe"]
        case .documentResearch:
            return ["abstract", "introduction", "conclusion", "references",
                    "figure", "table", "section", "chapter", "page"]
        case .chatCommunication:
            return ["sent", "delivered", "read", "typing", "online", "message",
                    "reply", "forward", "imessage", "whatsapp", "slack", "teams"]
        case .sensitivePrivate:
            return ["password", "ssn", "social security", "credit card",
                    "cvv", "expiry", "pin", "secret", "private", "confidential",
                    "bank account", "routing number"]
        case .other:
            return []
        }
    }

    // MARK: - Sensitivity

    /// Whether this category should block cloud analysis by default.
    var isSensitiveByDefault: Bool {
        self == .sensitivePrivate
    }
}
