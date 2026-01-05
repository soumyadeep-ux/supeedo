# Supeedo Milestones

## Progress Overview

| Milestone | Status | Description |
|-----------|--------|-------------|
| 0 | ✅ Complete | Project Scaffolding + Localization |
| 1 | 🔲 Pending | Folder Watcher + Security Bookmarks |
| 2 | 🔲 Pending | Local Triage Pipeline (OCR + Classification) |
| 3 | 🔲 Pending | Persistence + Dashboard |
| 4 | 🔲 Pending | Action Suggestions + Integrations |
| 5 | 🔲 Pending | Search + Spotlight |
| 6 | 🔲 Pending | Weekly Digest |
| 7 | 🔲 Pending | Optional Cloud Analysis |

---

## Milestone 0: Project Scaffolding ✅

**Status:** Complete

**Delivered:**
- [x] SwiftUI app with sidebar navigation
- [x] Modular Swift Package architecture
- [x] Localization infrastructure (en/de)
- [x] Type-safe L10n wrapper
- [x] App sandbox entitlements
- [x] Git repository initialized
- [x] GitHub repo created

**Verification:**
```bash
cd ~/Documents/supeedo
swift build && .build/debug/Supeedo
```

---

## Milestone 1: Folder Watcher + Security Bookmarks

**Goal:** User can select a folder, app watches for new screenshots

**Tasks:**
- [ ] Implement FSEvents-based folder watcher (replace polling)
- [ ] Security-scoped bookmark persistence
- [ ] Detect new `.png` files in watched folder
- [ ] SHA-256 deduplication
- [ ] Thumbnail generation on ingest
- [ ] Display list of detected screenshots

**Key Concepts:**
- Security-scoped bookmarks for sandbox persistence
- FSEvents API for efficient file watching
- Background thread processing

**Files to Modify:**
- `Packages/Capture/Sources/Capture.swift`
- `Packages/Data/Sources/Data.swift`
- `Supeedo/Features/Settings/SettingsView.swift`

---

## Milestone 2: Local Triage Pipeline

**Goal:** Each screenshot is processed locally with OCR and categorized

**Tasks:**
- [ ] Implement Vision framework OCR
- [ ] Create heuristic classifier
- [ ] Implement sensitivity detection
- [ ] Extract entities (dates, amounts, phones)
- [ ] Store triage results
- [ ] Show categorized list with text preview

**Classification Logic:**
```swift
// Keywords → Category mapping
"total", "tax", "$", "€", "invoice" → receiptInvoice
"calendar", date patterns, "meeting" → eventAppointment
"todo", "task", "reminder", checkbox → todoNote
// etc.
```

**Performance Target:** < 500ms per screenshot

**Files to Modify:**
- `Packages/AIKitLocal/Sources/AIKitLocal.swift`
- `Packages/Domain/Sources/Domain.swift`

---

## Milestone 3: Persistence + Dashboard

**Goal:** Screenshots persist across launches, browsable dashboard

**Tasks:**
- [ ] Screenshot grid view with thumbnails
- [ ] Category filtering in sidebar
- [ ] Search within extracted text
- [ ] Sort by date/category
- [ ] Detail view with full OCR text

**Files to Create:**
- `Supeedo/Features/Dashboard/ScreenshotGridView.swift`
- `Supeedo/Features/Dashboard/ScreenshotDetailView.swift`

---

## Milestone 4: Action Suggestions + Integrations

**Goal:** App suggests actions and integrates with Reminders/Calendar

**Tasks:**
- [ ] Action suggestion engine
- [ ] EventKit Reminders integration
- [ ] EventKit Calendar integration
- [ ] Text export functionality
- [ ] Action buttons in detail view

**Entitlements:**
```xml
<key>com.apple.security.personal-information.calendars</key>
<key>com.apple.security.personal-information.reminders</key>
```

---

## Milestone 5: Search + Spotlight

**Goal:** Full-text search and Spotlight indexing

**Tasks:**
- [ ] In-app search bar
- [ ] Spotlight metadata (CSSearchableItem)
- [ ] Handle Spotlight result clicks
- [ ] Extended attributes (xattrs)

---

## Milestone 6: Weekly Digest

**Goal:** Localized weekly summary with suggested actions

**Tasks:**
- [ ] Digest data aggregator
- [ ] HTML email template (en/de)
- [ ] Mail.app draft creation
- [ ] Background scheduling

---

## Milestone 7: Optional Cloud Analysis

**Goal:** Opt-in Claude API with tiered model strategy

**Tasks:**
- [ ] API key configuration
- [ ] Claude API client
- [ ] Haiku-first, Sonnet fallback
- [ ] Privacy gate (block sensitive)
- [ ] Usage/cost tracking
- [ ] "Deep Analyze" button

**Model Strategy:**
1. Always start with local OCR (free)
2. User triggers cloud analysis
3. Try Haiku first ($0.003)
4. Fallback to Sonnet if confidence < 0.7 ($0.012)

---

## QA Checklist

### Localization
- [ ] All UI strings use L10n keys
- [ ] German translations complete
- [ ] No truncation/overflow in German
- [ ] Category keys are stable (not localized in storage)

### Performance
- [ ] OCR < 500ms per image
- [ ] App launch < 2s
- [ ] Memory < 200MB baseline
- [ ] Smooth scrolling in grid view

### Privacy
- [ ] Sensitive content detected correctly
- [ ] Cloud upload blocked for sensitive
- [ ] No data leaves device without consent
