# CLAUDE.md

Instructions for Claude Code when working on Supeedo.

## Project Overview

Supeedo is a privacy-first macOS app that watches screenshots, performs local AI triage (classification + OCR + sensitivity detection), and helps users organize and act on their screenshots.

**Location:** `~/Documents/supeedo`
**Stack:** Swift 6, SwiftUI, macOS 14+ (Sonoma)
**Localization:** English (en) + German (de) from day 1

## Commands

```bash
# Build
swift build

# Run
.build/debug/Supeedo

# Test
swift test

# Clean build
swift package clean && swift build
```

## Architecture

See `docs/ARCHITECTURE.md` for full details.

### Package Structure
```
Packages/
├── Domain/      # Core entities & protocols (no dependencies)
├── Data/        # JSON persistence
├── Capture/     # Folder watching (FSEvents)
└── AIKitLocal/  # Vision OCR + classifier
```

### Agent Roles

When working on features, identify which role owns it:

| Role | Package/Files |
|------|---------------|
| Localization Lead | `Resources/`, `L10n.swift` |
| macOS Platform Lead | `Supeedo/App/`, `Supeedo/Features/` |
| Capture Engineer | `Packages/Capture/` |
| Local AI Engineer | `Packages/AIKitLocal/` |
| Domain & Data Engineer | `Packages/Domain/`, `Packages/Data/` |

## Output Format

All development tasks must follow this structure:

**(A) Plan** - What will be done and why

**(B) Code Changes** - Files modified

**(C) Tests** - Tests added/modified

**(D) Run Instructions** - How to verify

**(E) Next Steps** - What comes after

## Localization Rules

**CRITICAL:** Follow these rules for all UI work.

1. **Never hardcode strings** - Use `L10n.Category.receiptInvoice` etc.
2. **Store keys, not translations** - Categories stored as `"receiptInvoice"`, NOT `"Belege & Rechnungen"`
3. **Localize at render time** - Convert keys to localized strings only in views
4. **Both languages required** - Add en AND de translations for every new string

### Adding New Strings

1. Add to `Supeedo/Resources/en.lproj/Localizable.strings`:
   ```
   "feature.newString" = "English text";
   ```

2. Add to `Supeedo/Resources/de.lproj/Localizable.strings`:
   ```
   "feature.newString" = "German text";
   ```

3. Add to `Supeedo/Utilities/L10n.swift`:
   ```swift
   enum Feature {
       static let newString = NSLocalizedString("feature.newString", comment: "")
   }
   ```

4. Use in views:
   ```swift
   Text(L10n.Feature.newString)
   ```

## Data Model

### Key Types

```swift
// Screenshot - main entity
struct Screenshot: Identifiable, Codable, Sendable {
    let id: UUID
    let fileURL: URL
    let sha256: String
    var triageResult: TriageResult?
}

// Triage result - local analysis
struct TriageResult: Codable, Sendable {
    let categoryKey: String      // "receiptInvoice" NOT localized
    let confidence: Double
    let extractedText: String
    let sensitivityFlags: [String]
}

// Categories - stable enum keys
enum ScreenshotCategory: String {
    case receiptInvoice
    case eventAppointment
    case todoNote
    // etc.
}
```

## Current Status

**Milestone 0:** ✅ Complete (scaffolding + localization)
**Milestone 1:** 🔲 Next (folder watcher + security bookmarks)

See `docs/MILESTONES.md` for full roadmap.

## SPM Limitations

This project uses Swift Package Manager CLI builds. Some macOS features don't work:

| Feature | SPM Status | Workaround |
|---------|------------|------------|
| SwiftData (@Model) | ❌ No macros | Use Codable + JSON |
| #Preview macro | ❌ No macros | Use PreviewProvider |
| CommonCrypto | ⚠️ Conditional | `#if canImport` |

For full Xcode features, open `Package.swift` in Xcode instead of using `swift build`.

## Performance Targets

- OCR + classification: < 500ms per screenshot
- App launch: < 2 seconds
- Memory baseline: < 200MB
- Grid scrolling: 60fps

## Privacy Requirements

1. All processing local by default
2. Sensitive content auto-detected (credit cards, passwords)
3. Cloud upload blocked for sensitive screenshots
4. User must explicitly trigger cloud analysis
5. Clear indicator when data leaves device
