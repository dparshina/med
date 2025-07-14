//
//  AddPatientView.swift
//  med
//
//  Created by Parshina Daria on 14.07.2025.
//

// экран добавление нового пациента

import SwiftUICore
import SwiftUI


struct AddPatientView: View {
    @ObservedObject var viewModel: PatientViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date()
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о пациенте")) {
                    TextField("Имя", text: $firstName)
                    TextField("Фамилия", text: $lastName)
                    DatePicker("Дата рождения", selection: $dateOfBirth, displayedComponents: .date)
                }
            }
            .navigationTitle("Добавить пациента")
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
                            isLoading = true
                            Task {
                                let success = await viewModel.createPatient(
                                    firstName: firstName,
                                    lastName: lastName,
                                    dateOfBirth: dateFormatter.string(from: dateOfBirth)
                                )
                                isLoading = false
                                if success {
                                    dismiss()
                                }
                            }
                        }
                    }
                }
                
            }
        }
    }
}
