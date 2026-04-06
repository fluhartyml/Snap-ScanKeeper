//
//  SnapScanKeeper_DeveloperNotes.swift
//  Snap & Scan Keeper
//
//  Developer Notes — Persistent Memory for AI Assistants
//  Created: 2025 NOV 24 (Claude Code)
//

// ============================================================================
// MARK: - PROJECT IDENTITY
// ============================================================================
//
//  Name:           Snap & Scan Keeper
//  Bundle ID:      com.NightGard.Snap-ScanKeeper
//  Platform:       iOS (Universal - iPhone & iPad)
//  Version:        1.0
//  Deployment:     iOS 16.0+
//  Language:       Swift 5.0, SwiftUI
//  App Store ID:   6755695364
//  Status:         LIVE on App Store
//  Location:       /Users/michaelfluharty/Developer/NightGard/Snap&ScanKeeper/

// ============================================================================
// MARK: - DESCRIPTION
// ============================================================================
//
//  iOS document scanning app using VisionKit. Scan documents with automatic
//  edge detection, generate PDFs, save to custom photo albums, and share.
//  Privacy-first — all processing on-device.
//
//  Had multiple failed submissions (SnazzyScan, Swift-Scan, SnapKeeper)
//  before this version was rebuilt and finally published.

// ============================================================================
// MARK: - ARCHITECTURE
// ============================================================================
//
//  Snap_ScanKeeperApp.swift      — App entry point (@main)
//  ContentView.swift              — Main UI: scan button, share button, settings gear
//  DocumentScannerView.swift      — UIViewControllerRepresentable wrapping VNDocumentCameraViewController
//  PhotosManager.swift            — @MainActor singleton: PDF generation, custom album management
//  SettingsView.swift             — Form with radio-button save format selection
//  ShareSheet.swift               — UIActivityViewController wrapper
//  GlyphPreview.swift             — SF Symbol browser (not compiled)

// ============================================================================
// MARK: - KEY FEATURES
// ============================================================================
//
//  Document Scanning:
//    - VisionKit edge detection and perspective correction
//    - Multi-page scanning support
//
//  PDF Generation:
//    - Timestamp filenames: SnapScanKeeper-yyyy-MM-dd-HHmmss.pdf
//
//  Photo Albums:
//    - "Snap&ScanKeeper PDFs" and "Snap&ScanKeeper Images" custom albums
//
//  Save Modes (4):
//    - Share Only (default): auto-opens share sheet
//    - PDF Only: saves to custom album
//    - Both: individual pages + PDF
//    - Pages Only: individual page images
//
//  Settings via UserDefaults (key: "saveFormat")
//  Light/dark app icon variants

// ============================================================================
// MARK: - EASTER EGG
// ============================================================================
//
//  "Engineered with Claude by Anthropic" — present in developer notes

// ============================================================================
// MARK: - ABOUT THIS APP
// ============================================================================
//
//  Snap & Scan Keeper v1.0
//  "Scan it. Save it. Share it."
//
//  Engineered with Claude by Anthropic
//  Copyright (c) 2025 Michael Fluharty
//  Licensed under CC BY-SA 4.0
//  Website: https://fluharty.me
//  Contact: michael@fluharty.me

// ============================================================================
// MARK: - SHAKEDOWN CHECKLIST
// ============================================================================
//
//  [ ] App launches without crash
//  [ ] Camera permission prompt appears on first launch
//  [ ] Photos permission prompt appears when saving
//  [ ] Document scanner opens and captures pages
//  [ ] Multi-page scanning works
//  [ ] PDF generation creates valid PDF
//  [ ] Share Only mode: share sheet auto-opens after scan
//  [ ] PDF Only mode: PDF saved to custom album
//  [ ] Both mode: pages + PDF saved
//  [ ] Pages Only mode: individual pages saved
//  [ ] Settings gear opens settings view
//  [ ] Save format persists between launches
//  [ ] Light mode icon displays correctly
//  [ ] Dark mode icon displays correctly
//  [ ] App runs on iPhone
//  [ ] App runs on iPad

// ============================================================================
// MARK: - KNOWN ISSUES
// ============================================================================
//
//  (none currently — app is live and stable)

// ============================================================================
// MARK: - DEVELOPER NOTES LOG
// ============================================================================
//
//  2026 MAR 20 — Developer notes documented with shakedown checklist. (Claude Code)
//  2025 NOV 25 — App Store approval. Live (ID: 6755695364). 5th attempt succeeded.
//  2025 NOV 24 — Full reconstruction as Snap & Scan Keeper. (Claude Code)
//
