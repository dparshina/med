//
//  EditStudyView.swift
//  med
//
//  Created by Parshina Daria on 14.07.2025.
//


import SwiftUI

struct EditStudyView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var studyViewModel: StudyViewModel
    
    let study: StudyDTO
    
    @State private var studyType: String
    @State private var description: String
    @State private var studyDate: Date
    @State private var isLoading = false
    @State private var showingErrorAlert = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    init(study: StudyDTO, studyViewModel: StudyViewModel) {
        self.study = study
        self.studyViewModel = studyViewModel
        self._studyType = State(initialValue: study.studyType)
        self._description = State(initialValue: study.description ?? "")
        // Convert string date to Date using your existing format
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self._studyDate = State(initialValue: formatter.date(from: study.studyDate) ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация об исследовании")) {
                    TextField("Тип исследования", text: $studyType)
                    
                    TextField("Описание (опционально)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    DatePicker("Дата исследования", selection: $studyDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Редактировать исследование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Сохранить") {
                            Task {
                                await saveStudy()
                            }
                        }
                        .disabled(studyType.isEmpty)
                    }
                }
            }
            .alert("Ошибка", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(studyViewModel.errorMessage ?? "Произошла неизвестная ошибка")
            }
            .disabled(isLoading)
        }
    }
    
    private func saveStudy() async {
        isLoading = true
        
        let success = await studyViewModel.updateStudy(
            studyId: study.id,
            studyType: studyType,
            description: description.isEmpty ? nil : description,
            studyDate: dateFormatter.string(from: studyDate)
        )
        
        isLoading = false
        
        if success {
            dismiss()
        } else {
            showingErrorAlert = true
        }
    }
}
