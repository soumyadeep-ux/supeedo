# Supeedo

**Privacy-first screenshot intelligence for macOS**

Supeedo watches your screenshot folder, performs local AI triage (classification + OCR + sensitivity detection), and helps you organize and act on your screenshots—all while keeping your data private by default.

## Features

- 📁 **Folder Watching** - Monitors your Screenshots folder via FSEvents
- 🔍 **Local OCR** - Extracts text using Apple Vision (FREE, no cloud)
- 🏷️ **Smart Classification** - Categorizes screenshots into 8 types
- 🔒 **Privacy-First** - Sensitive content detection, cloud upload blocking
- 🌐 **Bilingual** - English + German from day 1
- ☁️ **Optional Cloud** - Deep analysis with Claude Haiku/Sonnet (user-triggered)

## Requirements

- macOS 14+ (Sonoma)
- Apple Silicon recommended
- Xcode 15+ (for development)

## Quick Start

```bash
# Clone
git clone https://github.com/soumyadeep-ux/supeedo.git
cd supeedo

# Build
swift build

# Run
.build/debug/Supeedo
```

## Architecture

```
Supeedo/
├── Package.swift              # SPM configuration
├── Supeedo/                   # Main app target
│   ├── App/                   # Entry point, main views
│   ├── Features/              # Feature modules (Settings, Dashboard)
│   ├── Utilities/             # L10n, helpers
│   └── Resources/             # Localizations, assets
├── Packages/                  # Modular Swift packages
│   ├── Domain/                # Core entities & protocols
│   ├── Data/                  # Persistence layer
│   ├── Capture/               # Folder watching
│   └── AIKitLocal/            # Vision OCR, classifier
└── SupeedoTests/              # Unit tests
```

## Screenshot Categories

| Key | English | German |
|-----|---------|--------|
| `receiptInvoice` | Receipts & Invoices | Belege & Rechnungen |
| `eventAppointment` | Events & Appointments | Termine & Veranstaltungen |
| `todoNote` | Tasks & Notes | Aufgaben & Notizen |
| `designInspo` | Design Inspiration | Design-Inspiration |
| `documentResearch` | Documents & Research | Dokumente & Recherche |
| `chatCommunication` | Chats & Messages | Chats & Nachrichten |
| `sensitivePrivate` | Sensitive & Private | Sensibel & Privat |
| `other` | Other | Sonstiges |

## AI Cost Strategy

| Mode | Cost | Use Case |
|------|------|----------|
| Local OCR | **$0.00** | Default for all screenshots |
| Cloud Quick (Haiku) | ~$0.003/image | User-triggered deep analysis |
| Cloud Deep (Sonnet 4.5) | ~$0.012/image | Complex screenshots |

## Development

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed architecture and role assignments.

See [docs/MILESTONES.md](docs/MILESTONES.md) for implementation roadmap.

## License

MIT
