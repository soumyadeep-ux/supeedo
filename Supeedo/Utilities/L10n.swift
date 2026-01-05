// L10n.swift
// Supeedo - Localization Helper
//
// Provides type-safe access to localized strings.
// All user-facing strings must use this helper - no hardcoded strings!

import Foundation

/// Type-safe localization helper.
/// Usage: `L10n.App.title` returns the localized "Supeedo" string.
enum L10n {

    // MARK: - App

    enum App {
        /// "Supeedo"
        static var title: String {
            NSLocalizedString("app.title", value: "Supeedo", comment: "App name")
        }

        /// "Screenshot Intelligence"
        static var subtitle: String {
            NSLocalizedString("app.subtitle", value: "Screenshot Intelligence", comment: "App tagline")
        }

        /// "About Supeedo"
        static var about: String {
            NSLocalizedString("app.about", value: "About Supeedo", comment: "About menu item")
        }
    }

    // MARK: - Categories

    enum Category {
        /// "Receipts & Invoices"
        static var receiptInvoice: String {
            NSLocalizedString("category.receiptInvoice", value: "Receipts & Invoices", comment: "Receipt/invoice category")
        }

        /// "Events & Appointments"
        static var eventAppointment: String {
            NSLocalizedString("category.eventAppointment", value: "Events & Appointments", comment: "Event/appointment category")
        }

        /// "Tasks & Notes"
        static var todoNote: String {
            NSLocalizedString("category.todoNote", value: "Tasks & Notes", comment: "Todo/note category")
        }

        /// "Design Inspiration"
        static var designInspo: String {
            NSLocalizedString("category.designInspo", value: "Design Inspiration", comment: "Design inspiration category")
        }

        /// "Documents & Research"
        static var documentResearch: String {
            NSLocalizedString("category.documentResearch", value: "Documents & Research", comment: "Document/research category")
        }

        /// "Chats & Messages"
        static var chatCommunication: String {
            NSLocalizedString("category.chatCommunication", value: "Chats & Messages", comment: "Chat/communication category")
        }

        /// "Sensitive & Private"
        static var sensitivePrivate: String {
            NSLocalizedString("category.sensitivePrivate", value: "Sensitive & Private", comment: "Sensitive/private category")
        }

        /// "Other"
        static var other: String {
            NSLocalizedString("category.other", value: "Other", comment: "Other/uncategorized")
        }

        /// "All Categories"
        static var all: String {
            NSLocalizedString("category.all", value: "All Categories", comment: "All categories filter")
        }
    }

    // MARK: - Actions

    enum Action {
        /// "Create Reminder"
        static var createReminder: String {
            NSLocalizedString("action.createReminder", value: "Create Reminder", comment: "Create reminder action")
        }

        /// "Create Event"
        static var createEvent: String {
            NSLocalizedString("action.createEvent", value: "Create Event", comment: "Create calendar event action")
        }

        /// "Export Text"
        static var exportText: String {
            NSLocalizedString("action.exportText", value: "Export Text", comment: "Export text action")
        }

        /// "Archive"
        static var archive: String {
            NSLocalizedString("action.archive", value: "Archive", comment: "Archive action")
        }

        /// "Deep Analyze (Cloud)"
        static var deepAnalyze: String {
            NSLocalizedString("action.deepAnalyze", value: "Deep Analyze (Cloud)", comment: "Cloud deep analysis action")
        }

        /// "Quick Analyze"
        static var quickAnalyze: String {
            NSLocalizedString("action.quickAnalyze", value: "Quick Analyze", comment: "Quick cloud analysis with Haiku")
        }
    }

    // MARK: - Settings

    enum Settings {
        /// "Settings"
        static var title: String {
            NSLocalizedString("settings.title", value: "Settings", comment: "Settings window title")
        }

        /// "Watched Folder"
        static var watchedFolder: String {
            NSLocalizedString("settings.watchedFolder", value: "Watched Folder", comment: "Watched folder setting label")
        }

        /// "Select Folder"
        static var selectFolder: String {
            NSLocalizedString("settings.selectFolder", value: "Select Folder", comment: "Select folder button")
        }

        /// "No folder selected"
        static var noFolderSelected: String {
            NSLocalizedString("settings.noFolderSelected", value: "No folder selected", comment: "No folder selected placeholder")
        }

        /// "Enable Cloud Analysis"
        static var cloudEnabled: String {
            NSLocalizedString("settings.cloudEnabled", value: "Enable Cloud Analysis", comment: "Cloud analysis toggle")
        }

        /// "Cloud analysis uses Claude AI for enhanced understanding. Your screenshots are sent to Anthropic's servers."
        static var cloudDescription: String {
            NSLocalizedString("settings.cloudDescription", value: "Cloud analysis uses Claude AI for enhanced understanding. Your screenshots are sent to Anthropic's servers.", comment: "Cloud analysis description")
        }

        /// "API Key"
        static var apiKey: String {
            NSLocalizedString("settings.apiKey", value: "API Key", comment: "API key label")
        }

        /// "General"
        static var general: String {
            NSLocalizedString("settings.general", value: "General", comment: "General settings tab")
        }

        /// "Cloud"
        static var cloud: String {
            NSLocalizedString("settings.cloud", value: "Cloud", comment: "Cloud settings tab")
        }
    }

    // MARK: - Dashboard

    enum Dashboard {
        /// "Dashboard"
        static var title: String {
            NSLocalizedString("dashboard.title", value: "Dashboard", comment: "Dashboard title")
        }

        /// "No screenshots yet"
        static var empty: String {
            NSLocalizedString("dashboard.empty", value: "No screenshots yet", comment: "Empty state message")
        }

        /// "Select a folder to watch in Settings"
        static var emptyHint: String {
            NSLocalizedString("dashboard.emptyHint", value: "Select a folder to watch in Settings", comment: "Empty state hint")
        }

        /// "Search screenshots..."
        static var searchPlaceholder: String {
            NSLocalizedString("dashboard.searchPlaceholder", value: "Search screenshots...", comment: "Search placeholder")
        }

        /// "%d screenshots"
        static func screenshotCount(_ count: Int) -> String {
            String(format: NSLocalizedString("dashboard.screenshotCount", value: "%d screenshots", comment: "Screenshot count"), count)
        }
    }

    // MARK: - Digest

    enum Digest {
        /// "Your Weekly Screenshot Summary"
        static var subject: String {
            NSLocalizedString("digest.subject", value: "Your Weekly Screenshot Summary", comment: "Digest email subject")
        }

        /// "You captured %d screenshots this week."
        static func summaryLine(_ count: Int) -> String {
            String(format: NSLocalizedString("digest.summaryLine", value: "You captured %d screenshots this week.", comment: "Digest summary line"), count)
        }

        /// "Open Supeedo"
        static var openApp: String {
            NSLocalizedString("digest.openApp", value: "Open Supeedo", comment: "Open app CTA")
        }
    }

    // MARK: - Errors

    enum Error {
        /// "Permission Denied"
        static var permissionDenied: String {
            NSLocalizedString("error.permissionDenied", value: "Permission Denied", comment: "Permission denied error")
        }

        /// "Cannot access folder"
        static var folderNotAccessible: String {
            NSLocalizedString("error.folderNotAccessible", value: "Cannot access folder", comment: "Folder not accessible error")
        }

        /// "Analysis failed"
        static var analysisFailed: String {
            NSLocalizedString("error.analysisFailed", value: "Analysis failed", comment: "Analysis failed error")
        }
    }
}
