//
//  PatientInfoCard.swift
//  med
//
//  Created by Parshina Daria on 14.07.2025.
//

// карточка пациента подробная по нажатию на конкретного пациента

import SwiftUICore
import SwiftUI

struct PatientDetailView: View {
    let patient: PatientDTO
    @StateObject private var studyViewModel = StudyViewModel()
    @StateObject private var patientViewModel = PatientViewModel() 
    @State private var showEdit = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Информация о пациенте")
                            .font(.headline)
                        
                        Spacer()

                    }
                    
                    HStack {
                        Text("Имя и фамилия:")
                        Spacer()
                        Text("\(patient.firstName) \(patient.lastName)")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Возраст:")
                        Spacer()
                        Text("\(patient.age)")
                    }
                    
                    HStack {
                        Text("Дата рождения:")
                        Spacer()
                        Text(patient.dateOfBirth)
                    }
                    
                    HStack {
                        Text("ID:")
                        Spacer()
                        Text(patient.id.uuidString)
                    }

                    
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Медицинские исследования")
                            .font(.headline)
                        
                        Spacer()
                        
                        NavigationLink(destination: StudyListView(patient: patient, onPatientChange: {})) {
                            Text("Посмотреть все")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if studyViewModel.isLoading {
                        ProgressView("Загрузка исследований...")
                            .frame(maxWidth: .infinity)
                    } else if studyViewModel.studies.isEmpty {
                        Text("Нет исследований")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    } else {
                        ForEach(studyViewModel.studies.prefix(3)) { study in
                            NavigationLink(destination: StudyDetailView(study: study)) {
                                StudyRowView(study: study)
                            }
                        }
                        
                        if studyViewModel.studies.count > 3 {
                            Text("И еще \(studyViewModel.studies.count - 3) исследований...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle(patient.firstName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showEdit = true
                }) {
                    Image(systemName: "pencil")
                }
            }
        }

        .sheet(isPresented: $showEdit) {
            EditPatientView(viewModel: patientViewModel, patient: patient)
        }
        .task {
            await studyViewModel.loadStudies(for: patient.id)
        }
    }
}
