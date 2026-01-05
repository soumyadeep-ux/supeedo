# Supeedo Architecture

## Agent / Subsystem Assignments

Development is structured as specialized roles. Each role has clear responsibilities and owns specific packages/files.

---

### 0) Localization Lead

**Owner:** `Supeedo/Resources/`, `Supeedo/Utilities/L10n.swift`

**Responsibilities:**
- Set up `.strings` catalogs and typed wrapper for keys
- Ensure every UI string uses localization keys (NO hardcoded strings)
- Create en/de translations from day 1
- Ensure digest templates are localized
- Ensure category labels and action labels are localized consistently
- Add screenshot tests or QA checklist for truncation/overflow in German

**Key Files:**
- `Supeedo/Resources/en.lproj/Localizable.strings`
- `Supeedo/Resources/de.lproj/Localizable.strings`
- `Supeedo/Utilities/L10n.swift` - Type-safe localization wrapper

**Rules:**
- Categories stored as stable keys (enum/raw string), NOT localized strings
- Localization occurs at render time via `L10n.Category.receiptInvoice`, etc.
- All user-facing strings must have both en/de translations

---

### 1) macOS Platform Lead

**Owner:** `Supeedo/App/`, `Supeedo/Features/`

**Responsibilities:**
- SwiftUI app lifecycle and navigation
- Settings UI (folder picker, cloud config, preferences)
- Menu bar integration
- Keyboard shortcuts
- Window management
- App sandbox entitlements

**Key Files:**
- `Supeedo/App/SupeedoApp.swift`
- `Supeedo/App/ContentView.swift`
- `Supeedo/Features/Settings/SettingsView.swift`
- `Supeedo/Supeedo.entitlements`
- `Supeedo/Info.plist`

---

### 2) Capture & Indexing Engineer

**Owner:** `Packages/Capture/`

**Responsibilities:**
- FSEvents folder watching
- Security-scoped bookmarks for sandbox persistence
- Screenshot ingestion pipeline
- Duplicate detection (SHA-256)
- Thumbnail generation
- File system operations

**Key Files:**
- `Packages/Capture/Sources/Capture.swift` - FolderWatcher actor
- Security bookmark helpers

**Entitlements Required:**
```xml
<key>com.apple.security.files.user-selected.read-write</key>
<key>com.apple.security.files.bookmarks.app-scope</key>
```

---

### 3) Local AI Engineer

**Owner:** `Packages/AIKitLocal/`

**Responsibilities:**
- Apple Vision framework OCR (`VNRecognizeTextRequest`)
- Heuristic text classification
- Entity extraction (dates, amounts, phone numbers)
- Sensitivity detection (credit cards, passwords, SSN patterns)
- Performance optimization (<500ms per screenshot)

**Key Files:**
- `Packages/AIKitLocal/Sources/AIKitLocal.swift`
  - `OCRService` - Vision framework wrapper
  - `TriageClassifier` - Heuristic categorization
  - `SensitivityDetector` - Privacy pattern matching

**Performance Target:** OCR + classification < 500ms per screenshot

---

### 4) Domain & Data Engineer

**Owner:** `Packages/Domain/`, `Packages/Data/`

**Responsibilities:**
- Core entity definitions (Screenshot, TriageResult, etc.)
- Protocol definitions for all services
- JSON file persistence (SPM-compatible)
- Repository pattern implementation
- Data migration strategies

**Key Files:**
- `Packages/Domain/Sources/Domain.swift` - Entities & protocols
- `Packages/Data/Sources/Data.swift` - Repository & persistence

---

### 5) Productivity Integrations Engineer

**Owner:** `Packages/Integrations/` (future)

**Responsibilities:**
- EventKit integration (Reminders)
- EventKit integration (Calendar)
- Text export functionality
- Clipboard operations
- Share sheet integration

**Entitlements Required:**
```xml
<key>com.apple.security.personal-information.calendars</key>
<key>com.apple.security.personal-information.reminders</key>
```

---

### 6) Cloud AI Engineer

**Owner:** `Packages/AIKitCloud/` (future)

**Responsibilities:**
- Claude API client (Haiku + Sonnet 4.5)
- Tiered model selection strategy
- Privacy gate (block sensitive uploads)
- API key management
- Usage/cost tracking
- Rate limiting

**Model Strategy:**
```swift
// 1. Try Haiku first (fast, $0.003)
// 2. Fallback to Sonnet 4.5 if confidence < 0.7
// 3. User can force Sonnet for important screenshots
```

---

### 7) Digest & Notifications Engineer

**Owner:** `Packages/Digest/` (future)

**Responsibilities:**
- Weekly digest generation
- HTML email templates (localized)
- Mail.app draft creation
- Local notifications
- Background scheduling

---

### 8) QA & Performance Engineer

**Owner:** `SupeedoTests/`, performance monitoring

**Responsibilities:**
- Unit tests for all packages
- Integration tests
- Performance benchmarks
- Memory profiling
- Localization QA (German overflow checks)
- Accessibility testing

---

## Data Model

### ScreenshotItem
```swift
struct Screenshot: Identifiable, Codable, Sendable {
    let id: UUID
    let fileURL: URL
    let createdAt: Date
    let sha256: String
    var thumbnailData: Data?
    var triageResult: TriageResult?
    var deepAnalysisResult: DeepAnalysisResult?
}
```

### TriageResult
```swift
struct TriageResult: Codable, Sendable {
    let categoryKey: String      // Stable key, NOT localized
    let confidence: Double       // 0.0 - 1.0
    let extractedText: String    // OCR output
    let entities: [String: String]  // dates, amounts, phones
    let sensitivityFlags: [String]  // "credit_card", "password"
    let processingTimeMs: Int

    var isSensitive: Bool { !sensitivityFlags.isEmpty }
}
```

### SuggestedAction
```swift
enum SuggestedAction: Codable, Sendable {
    case createReminder(title: String, notes: String?, dueDate: Date?)
    case createCalendarEvent(title: String, startDate: Date, endDate: Date?, location: String?)
    case exportText(text: String)
    case archive
    case ignore
}
```

### DeepAnalysisResult
```swift
struct DeepAnalysisResult: Codable, Sendable {
    let model: String           // "haiku" or "sonnet"
    let description: String
    let suggestedActions: [SuggestedAction]
    let insights: [String]
    let costUSD: Double
    let processingTimeMs: Int
}
```

### Category Keys (Enum)

**IMPORTANT:** Store categories as stable keys, NOT localized strings.

```swift
enum ScreenshotCategory: String, CaseIterable {
    case receiptInvoice
    case eventAppointment
    case todoNote
    case designInspo
    case documentResearch
    case chatCommunication
    case sensitivePrivate
    case other

    var localizedName: String {
        // Localization at render time
        L10n.Category.name(for: self)
    }
}
```

---

## Output Structure

All development tasks follow this format:

**(A) Plan** - What will be done and why

**(B) Code Changes** - Files modified with diffs

**(C) Tests** - Unit/integration tests added

**(D) Run Instructions** - How to verify the change

**(E) Next Steps** - What comes next

---

## Package Dependencies

```
Domain (no dependencies)
   ↑
Capture, AIKitLocal, Data (depend on Domain)
   ↑
Supeedo (main app, depends on all)
```

All packages are Swift 6 compatible with strict concurrency.
