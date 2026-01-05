// SupeedoApp.swift
// Supeedo - Screenshot Intelligence for macOS
//
// Created by Claude Code
// Privacy-first screenshot analysis with local AI triage

import SwiftUI

/// Main entry point for the Supeedo macOS application.
/// Uses SwiftUI App lifecycle (macOS 11+).
@main
struct SupeedoApp: App {

    // MARK: - App State

    /// Shared app state manager
    @StateObject private var appState = AppState()

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            // Custom menu commands
            CommandGroup(replacing: .appInfo) {
                Button(L10n.App.about) {
                    appState.showAbout = true
                }
            }

            CommandGroup(after: .appSettings) {
                Button(L10n.Settings.title) {
                    appState.showSettings = true
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }

        // Settings window
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State

/// Observable app state shared across views
@MainActor
final class AppState: ObservableObject {

    // MARK: - Navigation State

    @Published var showSettings = false
    @Published var showAbout = false
    @Published var selectedScreenshot: UUID?

    // MARK: - Filter State

    @Published var selectedCategory: ScreenshotCategory?
    @Published var searchQuery = ""

    // MARK: - Settings

    @Published var watchedFolderURL: URL? {
        didSet {
            // Persist to UserDefaults when changed
            if let url = watchedFolderURL {
                UserDefaults.standard.set(url.path, forKey: "watchedFolderPath")
            }
        }
    }

    @Published var cloudAnalysisEnabled = false

    // MARK: - Initialization

    init() {
        // Load persisted settings
        if let path = UserDefaults.standard.string(forKey: "watchedFolderPath") {
            watchedFolderURL = URL(fileURLWithPath: path)
        }
        cloudAnalysisEnabled = UserDefaults.standard.bool(forKey: "cloudAnalysisEnabled")
    }
}
