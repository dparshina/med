//
//  EditPatientView.swift
//  med
//
//  Created by Parshina Daria on 14.07.2025.
//

// экран редактирования уже добавленного пациента

import SwiftUI

struct EditPatientView: View {
    @ObservedObject var viewModel: PatientViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var showAlert = false
    
    let patient: PatientDTO
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация о пациенте") {
                    TextField("Имя", text: $firstName)
                    TextField("Фамилия", text: $lastName)
                    DatePicker("Дата рождения", selection: $dateOfBirth, displayedComponents: .date)
                }
                
            }
            .navigationTitle("Редактировать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отменить") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Сохранить") {
                            savePatient()
                        }
                        .disabled(firstName.isEmpty || lastName.isEmpty)
                    }
                }
            }
            .alert("Удалить пациента", isPresented: $showAlert) {
                Button("Отменить", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    deletePatient()
                }
            } message: {
                Text("Вы уверены? Это действие нельзя отменить.")
            }
        }
        .onAppear {
            firstName = patient.firstName
            lastName = patient.lastName
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: patient.dateOfBirth) {
                dateOfBirth = date
            }
        }
    }
    
    func savePatient() {
        isLoading = true
        
        Task {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: dateOfBirth)
            
            let success = await viewModel.updatePatient(
                id: patient.id,
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateString
            )
            
            isLoading = false
            if success {
                dismiss()
            }
        }
    }
    
    func deletePatient() {
        isLoading = true
        
        Task {
            let success = await viewModel.deletePatient(id: patient.id)
            isLoading = false
            if success {
                dismiss()
            }
        }
    }
    
}
