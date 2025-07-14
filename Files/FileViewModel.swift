//
//  FileViewModel.swift
//  med
//
//  Created by Parshina Daria on 13.07.2025.
//


import Foundation
import SwiftUI

@MainActor
class FileViewModel: ObservableObject {
    @Published var files: [FileMetadataDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var uploadProgress: Double = 0.0
    
    private let apiService = APIService()
    private let studyId: UUID
    private let patientId: UUID
    
    init(studyId: UUID, patientId: UUID) {
        self.studyId = studyId
        self.patientId = patientId
    }

    
    func loadFiles() async {
        isLoading = true
        errorMessage = nil
        
        do {
            files = try await apiService.getStudyFiles(patientId: patientId, studyId: studyId)
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading files: \(error)")
        }
        
        isLoading = false
    }
    
    func uploadFiles(_ filesToUpload: [FileUploadData]) async -> Bool {
        isLoading = true
        errorMessage = nil
        uploadProgress = 0.0
        
        do {
            let uploadedFiles = try await apiService.uploadFiles(
                patientId: patientId,
                studyId: studyId,
                files: filesToUpload
            )
            
            await loadFiles()
            
            uploadProgress = 1.0
            isLoading = false
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            print("Error uploading files: \(error)")
            isLoading = false
            return false
        }
    }
    
    func downloadFile(_ file: FileMetadataDTO) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiService.downloadFile(
                patientId: patientId,
                studyId: studyId,
                fileId: file.id
            )
            
            await saveFileToDevice(data: data, filename: file.filename)
            
        } catch {
            errorMessage = error.localizedDescription
            print("Error downloading file: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteFile(id: UUID) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.deleteFile(fileId: id)
            
            files.removeAll { $0.id == id }
            
            isLoading = false
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            print("Error deleting file: \(error)")
            isLoading = false
            return false
        }
    }
    
    
    private func saveFileToDevice(data: Data, filename: String) async {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            
            // Show success message or share sheet
            await showShareSheet(for: fileURL)
            
        } catch {
            await MainActor.run {
                errorMessage = "Failed to save file: \(error.localizedDescription)"
            }
        }
    }
    
    private func showShareSheet(for url: URL) async {
        await MainActor.run {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityVC, animated: true)
            }
        }
    }
}


extension FileViewModel {
    func uploadImages(_ images: [UIImage]) async -> Bool {
        var filesToUpload: [FileUploadData] = []
        
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let fileUpload = FileUploadData(
                    data: imageData,
                    filename: "image_\(index + 1).jpg",
                    mimeType: "image/jpeg"
                )
                filesToUpload.append(fileUpload)
            }
        }
        
        return await uploadFiles(filesToUpload)
    }
    
    func uploadDocuments(_ documents: [FileUploadData]) async -> Bool {
        var filesToUpload: [FileUploadData] = []
        
        for document in documents {
            let fileUpload = FileUploadData(
                data: document.data,
                filename: document.filename,
                mimeType: document.mimeType
            )
            filesToUpload.append(fileUpload)
        }
        
        return await uploadFiles(filesToUpload)
    }
}
