//
//  ContentView.swift
//  Snap&ScanKeeper
//
//  Created by Michael Fluharty on 11/24/25.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    @StateObject private var settings = SettingsManager()
    @State private var showScanner = false
    @State private var scannedPDFURL: URL?
    @State private var showShareSheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
            // App Icon/Logo
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text("Snap & Scan Keeper")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Document Scanner")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            // Scan Button
            Button(action: {
                if VNDocumentCameraViewController.isSupported {
                    showScanner = true
                } else {
                    alertMessage = "Document scanning is not supported on this device."
                    showAlert = true
                }
            }) {
                Label("Scan Document", systemImage: "camera.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)

            if scannedPDFURL != nil {
                // Share Button (shown after scan)
                Button(action: {
                    showShareSheet = true
                }) {
                    Label("Share Last Scan", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }

            Spacer()

            Text(settings.saveFormat == .shareOnly ? "Scans ready to share" : "Scans saved to Photos")
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            DocumentScannerView { scan in
                Task {
                    await processScan(scan)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = scannedPDFURL {
                ShareSheet(items: [url])
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
            .alert("Scanner", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .navigationViewStyle(.stack)
    }

    private func processScan(_ scan: VNDocumentCameraScan) async {
        do {
            let pdfURL = try await PhotosManager.shared.saveScan(scan, format: settings.saveFormat)
            scannedPDFURL = pdfURL

            // Custom message based on save format
            let formatMessage: String
            let shouldShowAlert: Bool

            switch settings.saveFormat {
            case .shareOnly:
                formatMessage = "PDF created - ready to share"
                shouldShowAlert = false
                // Auto-show share sheet
                showShareSheet = true
            case .pdfOnly:
                formatMessage = "PDF saved to Photos"
                shouldShowAlert = true
            case .both:
                formatMessage = "PDF and \(scan.pageCount) image(s) saved to Photos"
                shouldShowAlert = true
            case .pagesOnly:
                formatMessage = "\(scan.pageCount) image(s) saved to Photos"
                shouldShowAlert = true
            }

            if shouldShowAlert {
                alertMessage = "Success! \(formatMessage)"
                showAlert = true
            }
        } catch {
            alertMessage = "Failed to save scan: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

// Share Sheet for iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    ContentView()
}
