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
    func saveScan(_ scan: VNDocumentCameraScan) async throws -> URL {
        // Request Photos permission
        let status = await requestPhotoLibraryPermission()
        guard status == .authorized || status == .limited else {
            throw PhotosError.permissionDenied
        }

        // Create PDF from scanned images
        let pdfURL = try createPDF(from: scan)

        // Save to custom album
        try await saveToCustomAlbum(pdfURL: pdfURL)

        return pdfURL
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
        let albumName = "Snap&ScanKeeper"

        // Find or create custom album
        var album: PHAssetCollection?
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let existingAlbum = collections.firstObject {
            album = existingAlbum
        } else {
            // Create new album
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            }

            // Fetch the newly created album
            let newCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            album = newCollections.firstObject
        }

        guard let targetAlbum = album else {
            throw PhotosError.albumCreationFailed
        }

        // Save PDF to Photos
        var assetPlaceholder: PHObjectPlaceholder?

        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: pdfURL)
            assetPlaceholder = request?.placeholderForCreatedAsset

            if let placeholder = assetPlaceholder,
               let albumChangeRequest = PHAssetCollectionChangeRequest(for: targetAlbum) {
                albumChangeRequest.addAssets([placeholder] as NSArray)
            }
        }
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
