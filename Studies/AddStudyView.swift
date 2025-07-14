//
//  AddStudyView.swift
//  med
//
//  Created by Parshina Daria on 14.07.2025.
//

import Foundation
import SwiftUICore
import SwiftUI

struct AddStudyView: View {
    let patientId: UUID
    @ObservedObject var studyViewModel: StudyViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var studyType = ""
    @State private var description = ""
    @State private var studyDate = Date()
    @State private var isLoading = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
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
            .navigationTitle("Новое исследование")
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
        }
    }
    
    private func saveStudy() async {
        isLoading = true
        
        let success = await studyViewModel.createStudy(
            patientId: patientId,
            studyType: studyType,
            description: description.isEmpty ? nil : description,
            studyDate: dateFormatter.string(from: studyDate)
        )
        
        isLoading = false
        
        if success {
            dismiss()
        }
    }
}
