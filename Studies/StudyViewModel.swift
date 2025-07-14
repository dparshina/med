//
//  StudyViewModel.swift
//  med
//
//  Created by Parshina Daria on 14.07.2025.
//

import Foundation

@MainActor
class StudyViewModel: ObservableObject {
    @Published var studies: [StudyDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService()
    
    func loadStudies(for patientId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            studies = try await apiService.getPatientStudies(patientId: patientId)
        } catch {
            errorMessage = error.localizedDescription
            print("Ошибка выгрузки исследования: \(error)")
        }
        
        isLoading = false
    }
    
    func createStudy(patientId: UUID, studyType: String, description: String?, studyDate: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let newStudy = StudyCreateDTO(
            studyType: studyType,
            description: description,
            studyDate: studyDate
        )
        
        do {
            let createdStudy = try await apiService.createStudy(patientId: patientId, study: newStudy)
            studies.insert(createdStudy, at: 0)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Ошибка добавления исследования: \(error)")
            isLoading = false
            return false
       }
    }
    
    func deleteStudy(studyId: UUID) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.deleteStudy(studyId: studyId)
            
            studies.removeAll { $0.id == studyId }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Ошибка удаления исследования: \(error)")
            isLoading = false
            return false
        }
    }
    
    func updateStudy(studyId: UUID, studyType: String, description: String?, studyDate: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let updateData = StudyUpdateDTO(
            studyType: studyType,
            description: description,
            studyDate: studyDate
        )
        
        do {
            let updatedStudy = try await apiService.updateStudy(studyId: studyId, updates: updateData)
            if let index = studies.firstIndex(where: { $0.id == studyId }) {
                studies[index] = updatedStudy
            }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Ошибка обновления исследования: \(error)")
            isLoading = false
            return false
        }
    }
}
