//
//  PatientViewModel.swift
//  med
//
//  Created by Parshina Daria on 13.07.2025.
//

// загрузка пациентов, создание пациента, обновление пациента, удаление пациента

import Foundation
import SwiftUI

@MainActor
class PatientViewModel: ObservableObject {
    @Published var patients: [PatientDTO] = []
    @Published var selectedPatient: PatientDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 0
    @Published var totalPages = 0
    @Published var hasMorePages = true
    
    private let apiService = APIService()
    
    
    func loadPatients(page: Int = 0, size: Int = 20) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let pageData = try await apiService.getAllPatients(page: page, size: size)
            
            if page == 0 {
                patients = pageData.content
            } else {
                patients.append(contentsOf: pageData.content)
            }
            
            patients = sortPatients(patients)
            
            currentPage = pageData.number
            totalPages = pageData.totalPages
            hasMorePages = !pageData.last
            
        } catch {
            errorMessage = error.localizedDescription
            print("Ошибка выгрузки пациентов: \(error)")
        }
        
        isLoading = false
    }
    
    private func sortPatients(_ patients: [PatientDTO]) -> [PatientDTO] {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return patients.sorted { first, second in
            guard let date1 = formatter.date(from: first.createdAt),
                  let date2 = formatter.date(from: second.createdAt) else {
                return false
            }
            return date1 > date2
        }
    }
    
        
    func createPatient(firstName: String, lastName: String, dateOfBirth: String) async -> Bool {
            isLoading = true
            errorMessage = nil
            
            let newPatient = PatientCreateDTO(
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth
            )
            
            do {
                let createdPatient = try await apiService.createPatient(newPatient)
                self.patients.insert(createdPatient, at: 0)
                isLoading = false
                return true
            } catch {
                errorMessage = error.localizedDescription
                print("Ошибка добавления пациента: \(error)")
                isLoading = false
                return false
            }
        }
        
        func updatePatient(id: UUID, firstName: String?, lastName: String?, dateOfBirth: String?) async -> Bool {
            isLoading = true
            errorMessage = nil
            
            let updates = PatientUpdateDTO(
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth
            )
            
            do {
                let updatedPatient = try await apiService.updatePatient(id: id, updates: updates)
                
                if let index = patients.firstIndex(where: { $0.id == id }) {
                    self.patients[index] = updatedPatient
                }
                
                isLoading = false
                return true
            } catch {
                errorMessage = error.localizedDescription
                print("Ошибка обновления пациента: \(error)")
                isLoading = false
                return false
            }
        }
        
        func deletePatient(id: UUID) async -> Bool {
            isLoading = true
            errorMessage = nil
            
            do {
                try await apiService.deletePatient(id: id)
                self.patients.removeAll { $0.id == id }
                isLoading = false
                return true
            } catch {
                errorMessage = error.localizedDescription
                print("Ошибка удаления пациента: \(error)")
                isLoading = false
                return false
            }
        }
        
        func loadNextPage() async {
            guard hasMorePages && !isLoading else { return }
            await loadPatients(page: currentPage + 1)
        }
        
        func refreshPatients() async {
            currentPage = 0
            hasMorePages = true
            await loadPatients(page: 0)
        }
}
    
