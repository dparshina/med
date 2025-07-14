//
//  APIService.swift
//  med
//
//  Created by Parshina Daria on 13.07.2025.
//


import Foundation

class APIService {
    private let baseURL = "http://89.169.178.242:8080/api/v1"
    
    // MARK: - Patient methods
    
    /// Get all patients
    func getAllPatients(page: Int = 0, size: Int = 20) async throws -> PagePatientDTO {
        let endpoint = "/patients?page=\(page)&size=\(size)"
        return try await makeRequest(endpoint: endpoint, method: .GET, responseType: PagePatientDTO.self)
    }
    
    /// Create a new patient
    func createPatient(_ patient: PatientCreateDTO) async throws -> PatientDTO {
        let endpoint = "/patients"
        let body = try JSONEncoder().encode(patient)
        return try await makeRequest(endpoint: endpoint, method: .POST, body: body, responseType: PatientDTO.self)
    }
    
    /// Get a specific patient
    func getPatient(id: UUID) async throws -> PatientDTO {
        let endpoint = "/patients/\(id)"
        return try await makeRequest(endpoint: endpoint, method: .GET, responseType: PatientDTO.self)
    }
    
    /// Update a patient
    func updatePatient(id: UUID, updates: PatientUpdateDTO) async throws -> PatientDTO {
        let endpoint = "/patients/\(id)"
        let body = try JSONEncoder().encode(updates)
        return try await makeRequest(endpoint: endpoint, method: .PATCH, body: body, responseType: PatientDTO.self)
    }
    
    /// Delete a patient
    func deletePatient(id: UUID) async throws {
        let endpoint = "/patients/\(id)"
        let _: EmptyResponse = try await makeRequest(endpoint: endpoint, method: .DELETE, responseType: EmptyResponse.self)
    }
    
    // MARK: - Study methods
    
    /// Get all studies for a patient
    func getPatientStudies(patientId: UUID) async throws -> [StudyDTO] {
        let endpoint = "/patients/\(patientId)/studies"
        return try await makeRequest(endpoint: endpoint, method: .GET, responseType: [StudyDTO].self)
    }
    
    /// Create a new study for a patient
    func createStudy(patientId: UUID, study: StudyCreateDTO) async throws -> StudyDTO {
        let endpoint = "/patients/\(patientId)/studies"
        let body = try JSONEncoder().encode(study)
        return try await makeRequest(endpoint: endpoint, method: .POST, body: body, responseType: StudyDTO.self)
    }
    
    /// Update a study
    func updateStudy(studyId: UUID, updates: StudyUpdateDTO) async throws -> StudyDTO {
        let endpoint = "/patients/*/studies/\(studyId)"
        let body = try JSONEncoder().encode(updates)
        return try await makeRequest(endpoint: endpoint, method: .PATCH, body: body, responseType: StudyDTO.self)
    }
    
    /// Delete a study
    func deleteStudy(studyId: UUID) async throws {
        let endpoint = "/patients/*/studies/\(studyId)"
        let _: EmptyResponse = try await makeRequest(endpoint: endpoint, method: .DELETE, responseType: EmptyResponse.self)
    }
    
    // MARK: - File methods
    
    /// Get all files for a study
    func getStudyFiles(patientId: UUID, studyId: UUID) async throws -> [FileMetadataDTO] {
        let endpoint = "/patients/\(patientId)/studies/\(studyId)/files"
        return try await makeRequest(endpoint: endpoint, method: .GET, responseType: [FileMetadataDTO].self)
    }
    
    /// Upload files to a study
    func uploadFiles(patientId: UUID, studyId: UUID, files: [FileUploadData]) async throws -> [FileMetadataDTO] {
            guard let url = URL(string: "\(baseURL)/patients/\(patientId)/studies/\(studyId)/files") else {
                throw APIError.invalidURL
            }
            
            let boundary = "Boundary-\(UUID().uuidString)"
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            for fileData in files {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(fileData.filename)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: \(fileData.mimeType)\r\n\r\n".data(using: .utf8)!)
                body.append(fileData.data)
                body.append("\r\n".data(using: .utf8)!)
            }
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    // Print response for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Server response: \(responseString)")
                    }
                    throw APIError.serverError(httpResponse.statusCode)
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                return try decoder.decode([FileMetadataDTO].self, from: data)
                
            } catch let error as DecodingError {
                throw APIError.decodingError(error)
            } catch let error as APIError {
                throw error
            } catch {
                throw APIError.networkError(error)
            }
        }
    
    /// Download a file
    func downloadFile(patientId: UUID, studyId: UUID, fileId: UUID) async throws -> Data {
        let endpoint = "/patients/\(patientId)/studies/\(studyId)/files/\(fileId)/download"
        return try await makeRawRequest(endpoint: endpoint, method: .GET)
    }
    
    /// Delete a file
    func deleteFile(fileId: UUID) async throws {
        let endpoint = "/patients/*/studies/*/files/\(fileId)"
        let _: EmptyResponse = try await makeRequest(endpoint: endpoint, method: .DELETE, responseType: EmptyResponse.self)
    }
    
    // MARK: - Helper methods
    
    private func makeRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle 204 No Content responses
            if httpResponse.statusCode == 204 {
                return EmptyResponse() as! T
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(responseType, from: data)
            
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private func makeRawRequest(endpoint: String, method: HTTPMethod) async throws -> Data {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            return data
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Empty Response for DELETE operations
struct EmptyResponse: Codable {
    init() {}
}

