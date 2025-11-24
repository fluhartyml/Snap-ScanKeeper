//
//  ContentView.swift
//  Snap&ScanKeeper
//
//  Created by Michael Fluharty on 11/24/25.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    @State private var showScanner = false
    @State private var scannedPDFURL: URL?
    @State private var showShareSheet = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
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

            Text("Scans are saved to Photos")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
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
        .alert("Scanner", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func processScan(_ scan: VNDocumentCameraScan) async {
        do {
            let pdfURL = try await PhotosManager.shared.saveScan(scan)
            scannedPDFURL = pdfURL
            alertMessage = "Scan saved successfully! \(scan.pageCount) page(s)"
            showAlert = true
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
