//
//  Models.swift
//  med
//
//  Created by Parshina Daria on 13.07.2025.
//

// все модели, описанные backend, и дополнительные для работы с ошибками и файлами

import Foundation

// MARK: - Patient Models
struct PatientDTO: Codable, Identifiable {
    let id: UUID
    let firstName: String
    let lastName: String
    let age: Int
    let dateOfBirth: String
    let createdAt: String
}

struct PatientCreateDTO: Codable {
    let firstName: String
    let lastName: String
    let dateOfBirth: String
}

struct PatientUpdateDTO: Codable {
    let firstName: String?
    let lastName: String?
    let dateOfBirth: String?
}

// MARK: - Study Models
struct StudyDTO: Codable, Identifiable {
    let id: UUID
    let patientId: UUID
    let studyType: String
    let description: String?
    let studyDate: String
    let fileCount: Int
    let createdAt: String
}

struct StudyCreateDTO: Codable {
    let studyType: String
    let description: String?
    let studyDate: String
}

struct StudyUpdateDTO: Codable {
    let studyType: String?
    let description: String?
    let studyDate: String?
}

// MARK: - File Models
struct FileMetadataDTO: Codable, Identifiable {
    let id: UUID
    let filename: String
    let contentType: String
    let sizeBytes: Int64
    let uploadedAt: String
}

struct FileUploadData {
    let data: Data
    let filename: String
    let mimeType: String
}

struct DocumentFile {
    let name: String
    let data: Data
    let mimeType: String
}
// MARK: - Pagination Models
struct PagePatientDTO: Codable {
    let totalElements: Int64
    let totalPages: Int
    let first: Bool
    let size: Int
    let content: [PatientDTO]
    let number: Int
    let numberOfElements: Int
    let last: Bool
    let empty: Bool
}

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError(Error)
    case networkError(Error)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
