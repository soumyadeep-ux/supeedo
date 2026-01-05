// ContentView.swift
// Supeedo - Main Content View
//
// Primary app interface with sidebar navigation and dashboard.

import SwiftUI

/// Main content view with sidebar navigation.
struct ContentView: View {

    @EnvironmentObject private var appState: AppState

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            DashboardView()
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                // Search field
                TextField(L10n.Dashboard.searchPlaceholder, text: $appState.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)

                // Settings button
                Button {
                    appState.showSettings = true
                } label: {
                    Image(systemName: "gear")
                }
                .help(L10n.Settings.title)
            }
        }
        .sheet(isPresented: $appState.showAbout) {
            AboutView()
        }
    }
}

// MARK: - Sidebar View

struct SidebarView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        List(selection: $appState.selectedCategory) {
            Section {
                // All categories option
                Label(L10n.Category.all, systemImage: "square.grid.2x2")
                    .tag(nil as ScreenshotCategory?)
            }

            Section(header: Text("Categories")) {
                ForEach(ScreenshotCategory.allCases) { category in
                    Label {
                        Text(category.localizedName)
                    } icon: {
                        Image(systemName: category.iconName)
                            .foregroundStyle(category.color)
                    }
                    .tag(category as ScreenshotCategory?)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(L10n.App.title)
    }
}

// MARK: - Dashboard View

struct DashboardView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack {
            if appState.watchedFolderURL == nil {
                // Empty state - no folder selected
                EmptyStateView()
            } else {
                // Screenshot grid (placeholder for now)
                ScreenshotPlaceholderView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text(L10n.Dashboard.empty)
                .font(.title2)
                .fontWeight(.medium)

            Text(L10n.Dashboard.emptyHint)
                .font(.body)
                .foregroundStyle(.secondary)

            Button(L10n.Settings.selectFolder) {
                appState.showSettings = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

// MARK: - Screenshot Placeholder View

struct ScreenshotPlaceholderView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "eye")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Watching: \(appState.watchedFolderURL?.lastPathComponent ?? "Unknown")")
                .font(.title3)

            Text("Screenshots will appear here as they are captured")
                .font(.body)
                .foregroundStyle(.secondary)

            // Category filter if selected
            if let category = appState.selectedCategory {
                HStack {
                    Image(systemName: category.iconName)
                        .foregroundStyle(category.color)
                    Text("Filtering: \(category.localizedName)")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(category.color.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

// MARK: - About View

struct AboutView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            Text(L10n.App.title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(L10n.App.subtitle)
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("Version 1.0.0")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Divider()
                .padding(.horizontal, 40)

            Text("Privacy-first screenshot intelligence.\nLocal AI triage with optional cloud analysis.")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(.secondary)

            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.escape)
        }
        .padding(40)
        .frame(width: 400)
    }
}

// MARK: - Preview Provider (for Xcode)

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .frame(width: 1000, height: 700)
    }
}
#endif
