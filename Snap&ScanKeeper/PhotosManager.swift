//
//  PhotosManager.swift
//  Snap&ScanKeeper
//
//  Created by Michael Fluharty on 11/24/25.
//

import UIKit
import Photos
import PDFKit
import VisionKit

@MainActor
class PhotosManager {
    static let shared = PhotosManager()

    private init() {}

    // Save scanned document to Photos and return PDF URL
    func saveScan(_ scan: VNDocumentCameraScan, format: SaveFormat) async throws -> URL {
        // Request Photos permission
        let status = await requestPhotoLibraryPermission()
        guard status == .authorized || status == .limited else {
            throw PhotosError.permissionDenied
        }

        var pdfURL: URL?

        // Handle save format
        switch format {
        case .shareOnly:
            // Create PDF for share sheet only (don't save to Photos)
            pdfURL = try createPDF(from: scan)

        case .pdfOnly:
            // Create and save PDF only
            pdfURL = try createPDF(from: scan)
            try await saveToCustomAlbum(pdfURL: pdfURL!)

        case .both:
            // Save individual pages
            try await saveIndividualPages(from: scan)
            // Create and save PDF
            pdfURL = try createPDF(from: scan)
            try await saveToCustomAlbum(pdfURL: pdfURL!)

        case .pagesOnly:
            // Save individual pages only
            try await saveIndividualPages(from: scan)
            // Create temporary PDF for share sheet (not saved to Photos)
            pdfURL = try createPDF(from: scan)
        }

        return pdfURL ?? FileManager.default.temporaryDirectory.appendingPathComponent("temp.pdf")
    }

    private func saveIndividualPages(from scan: VNDocumentCameraScan) async throws {
        let albumName = "Snap&ScanKeeper Images"

        // Find or create custom album
        let album = try await findOrCreateAlbum(named: albumName)

        // Save each page as individual image
        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)

            try await PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let placeholder = request.placeholderForCreatedAsset

                if let placeholder = placeholder,
                   let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                    albumChangeRequest.addAssets([placeholder] as NSArray)
                }
            }
        }
    }

    private func requestPhotoLibraryPermission() async -> PHAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    private func createPDF(from scan: VNDocumentCameraScan) throws -> URL {
        let pdfDocument = PDFDocument()

        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)
            if let pdfPage = PDFPage(image: image) {
                pdfDocument.insert(pdfPage, at: pageIndex)
            }
        }

        // Create filename with timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "SnapScanKeeper-\(timestamp).pdf"

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        pdfDocument.write(to: tempURL)

        return tempURL
    }

    private func saveToCustomAlbum(pdfURL: URL) async throws {
        let albumName = "Snap&ScanKeeper PDFs"

        // Find or create custom album
        let album = try await findOrCreateAlbum(named: albumName)

        // Save PDF to Photos
        var assetPlaceholder: PHObjectPlaceholder?

        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: pdfURL)
            assetPlaceholder = request?.placeholderForCreatedAsset

            if let placeholder = assetPlaceholder,
               let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                albumChangeRequest.addAssets([placeholder] as NSArray)
            }
        }
    }

    // Helper to find or create album
    private func findOrCreateAlbum(named albumName: String) async throws -> PHAssetCollection {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let existingAlbum = collections.firstObject {
            return existingAlbum
        }

        // Create new album
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }

        // Fetch the newly created album
        let newCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        guard let newAlbum = newCollections.firstObject else {
            throw PhotosError.albumCreationFailed
        }

        return newAlbum
    }
}

enum PhotosError: LocalizedError {
    case permissionDenied
    case albumCreationFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Photos permission denied. Please enable in Settings."
        case .albumCreationFailed:
            return "Failed to create Snap&ScanKeeper album."
        case .saveFailed:
            return "Failed to save scan to Photos."
        }
    }
}
