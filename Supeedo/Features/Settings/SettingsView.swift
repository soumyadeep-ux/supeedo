// SettingsView.swift
// Supeedo - Settings Interface
//
// User preferences and configuration.

import SwiftUI
import UniformTypeIdentifiers

/// Main settings view with tabs for different sections.
struct SettingsView: View {

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label(L10n.Settings.general, systemImage: "gear")
                }

            CloudSettingsView()
                .tabItem {
                    Label(L10n.Settings.cloud, systemImage: "cloud")
                }
        }
        .frame(width: 500, height: 350)
        .padding()
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {

    @EnvironmentObject private var appState: AppState
    @State private var isSelectingFolder = false

    var body: some View {
        Form {
            Section {
                LabeledContent(L10n.Settings.watchedFolder) {
                    HStack {
                        if let url = appState.watchedFolderURL {
                            Text(url.path)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(L10n.Settings.noFolderSelected)
                                .foregroundStyle(.tertiary)
                        }

                        Button(L10n.Settings.selectFolder) {
                            selectFolder()
                        }
                    }
                }
            } header: {
                Text("Screenshot Monitoring")
            } footer: {
                Text("Supeedo will watch this folder for new screenshots and analyze them automatically.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Toggle("Launch at Login", isOn: .constant(false))
                Toggle("Show in Menu Bar", isOn: .constant(true))
                Toggle("Notification on New Screenshot", isOn: .constant(true))
            } header: {
                Text("Behavior")
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Folder Selection

    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.title = L10n.Settings.selectFolder
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false

        // Start at the default Screenshots folder
        let screenshotsPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
        panel.directoryURL = screenshotsPath

        if panel.runModal() == .OK, let url = panel.url {
            // Store as security-scoped bookmark
            do {
                let bookmarkData = try url.bookmarkData(
                    options: .withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                UserDefaults.standard.set(bookmarkData, forKey: "watchedFolderBookmark")
                appState.watchedFolderURL = url
            } catch {
                print("Failed to create bookmark: \(error)")
                // Fallback: just store the path (won't work after restart in sandbox)
                appState.watchedFolderURL = url
            }
        }
    }
}

// MARK: - Cloud Settings

struct CloudSettingsView: View {

    @EnvironmentObject private var appState: AppState
    @State private var apiKey = ""

    var body: some View {
        Form {
            Section {
                Toggle(L10n.Settings.cloudEnabled, isOn: $appState.cloudAnalysisEnabled)

                if appState.cloudAnalysisEnabled {
                    SecureField(L10n.Settings.apiKey, text: $apiKey)
                        .textFieldStyle(.roundedBorder)

                    Picker("Default Model", selection: .constant("haiku")) {
                        Text("Quick (Haiku) - $0.003/image").tag("haiku")
                        Text("Deep (Sonnet 4.5) - $0.012/image").tag("sonnet")
                    }
                }
            } header: {
                Text("Cloud Analysis")
            } footer: {
                Text(L10n.Settings.cloudDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if appState.cloudAnalysisEnabled {
                Section {
                    Toggle("Block sensitive screenshots", isOn: .constant(true))
                    Toggle("Ask before each upload", isOn: .constant(false))
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("Sensitive screenshots (passwords, financial data) are never uploaded by default.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section {
                    LabeledContent("This Month") {
                        Text("$0.00")
                    }
                    LabeledContent("Images Analyzed") {
                        Text("0")
                    }
                } header: {
                    Text("Usage")
                }
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Preview Provider (for Xcode)

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState())
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
            .environmentObject(AppState())
            .frame(width: 500)
    }
}

struct CloudSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CloudSettingsView()
            .environmentObject(AppState())
            .frame(width: 500)
    }
}
#endif
