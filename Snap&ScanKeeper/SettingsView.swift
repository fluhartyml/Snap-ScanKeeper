//
//  SettingsView.swift
//  Snap&ScanKeeper
//
//  Created by Michael Fluharty on 11/24/25.
//

import SwiftUI
import Combine

enum SaveFormat: String, CaseIterable, Identifiable {
    case shareOnly = "Share Only (Don't Save)"
    case pdfOnly = "PDF Only"
    case both = "Individual Pages + PDF"
    case pagesOnly = "Individual Pages Only"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .shareOnly:
            return "Create PDF for sharing without saving to Photos"
        case .pdfOnly:
            return "Save scans as a single combined PDF document"
        case .both:
            return "Save both individual page images and a combined PDF"
        case .pagesOnly:
            return "Save only individual page images (no PDF)"
        }
    }
}

class SettingsManager: ObservableObject {
    @Published var saveFormat: SaveFormat {
        didSet {
            UserDefaults.standard.set(saveFormat.rawValue, forKey: "saveFormat")
        }
    }

    init() {
        let savedFormat = UserDefaults.standard.string(forKey: "saveFormat") ?? SaveFormat.shareOnly.rawValue
        self.saveFormat = SaveFormat(rawValue: savedFormat) ?? .shareOnly
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settings = SettingsManager()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Choose how scanned documents are saved to your Photos library.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Save Format")
                }

                Section {
                    ForEach(SaveFormat.allCases) { format in
                        Button(action: {
                            settings.saveFormat = format
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(format.rawValue)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Text(format.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if settings.saveFormat == format {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section {
                    Text("PDFs are saved to 'Snap&ScanKeeper PDFs' and images to 'Snap&ScanKeeper Images' albums.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
