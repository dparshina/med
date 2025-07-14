//
//  StudyListView.swift
//  med
//
//  Created by Parshina Daria on 14.07.2025.
//

import SwiftUICore
import SwiftUI

struct StudyListView: View {
    let patient: PatientDTO
    let onPatientChange: () -> Void
    @StateObject private var studyViewModel = StudyViewModel()
    @State private var showingAddStudy = false
    @State private var showingDeleteAlert = false
    @State private var studyToDelete: StudyDTO?
    @State private var showingErrorAlert = false
    
    var body: some View {
        VStack {
            if studyViewModel.isLoading {
                ProgressView("Загрузка исследований...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if studyViewModel.studies.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("Нет исследований")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Добавьте первое исследование для этого пациента")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Добавить исследование") {
                        showingAddStudy = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(studyViewModel.studies) { study in
                        NavigationLink(destination: StudyDetailView(study: study)) {
                            StudyRowView(study: study)
                        }
                    }
                    .onDelete(perform: deleteStudy)
                }
                .refreshable {
                    await studyViewModel.loadStudies(for: patient.id)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Добавить") {
                    showingAddStudy = true
                }
            }
        }
        .sheet(isPresented: $showingAddStudy) {
            AddStudyView(patientId: patient.id, studyViewModel: studyViewModel)
        }
        .alert("Удалить исследование", isPresented: $showingDeleteAlert) {
            Button("Удалить", role: .destructive) {
                if let study = studyToDelete {
                    Task {
                        await confirmDeleteStudy(study)
                    }
                }
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Вы уверены, что хотите удалить это исследование? Это действие нельзя отменить.")
        }
        .alert("Ошибка", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(studyViewModel.errorMessage ?? "Произошла неизвестная ошибка")
        }
        .task {
            await studyViewModel.loadStudies(for: patient.id)
        }
    }
    
    private func deleteStudy(at offsets: IndexSet) {
        for index in offsets {
            let study = studyViewModel.studies[index]
            studyToDelete = study
            showingDeleteAlert = true
        }
    }
    
    private func confirmDeleteStudy(_ study: StudyDTO) async {
        let success = await studyViewModel.deleteStudy(studyId: study.id)
        if !success {
            showingErrorAlert = true
        }
        studyToDelete = nil
    }
}
