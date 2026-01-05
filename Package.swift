// swift-tools-version: 5.9
// Package.swift
// Supeedo - Screenshot Intelligence for macOS

import PackageDescription

let package = Package(
    name: "Supeedo",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)  // macOS 14 Sonoma minimum
    ],
    products: [
        .executable(
            name: "Supeedo",
            targets: ["Supeedo"]
        )
    ],
    dependencies: [],
    targets: [
        // Main app target
        .executableTarget(
            name: "Supeedo",
            dependencies: [
                "Domain",
                "Capture",
                "AIKitLocal",
                "Data"
            ],
            path: "Supeedo",
            resources: [
                .process("Resources")
            ]
        ),

        // Domain layer - entities and protocols
        .target(
            name: "Domain",
            dependencies: [],
            path: "Packages/Domain/Sources"
        ),

        // Capture - folder watching and ingestion
        .target(
            name: "Capture",
            dependencies: ["Domain"],
            path: "Packages/Capture/Sources"
        ),

        // AIKitLocal - Vision OCR and local classification
        .target(
            name: "AIKitLocal",
            dependencies: ["Domain"],
            path: "Packages/AIKitLocal/Sources"
        ),

        // Data - persistence and repositories
        .target(
            name: "Data",
            dependencies: ["Domain"],
            path: "Packages/Data/Sources"
        ),

        // Tests
        .testTarget(
            name: "SupeedoTests",
            dependencies: ["Supeedo", "Domain", "AIKitLocal"],
            path: "SupeedoTests"
        )
    ]
)
