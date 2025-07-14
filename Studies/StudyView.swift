//
//  StudyView.swift
//  med
//
//  Created by Parshina Daria on 13.07.2025.
//

import SwiftUI
import PhotosUI

struct StudyDetailView: View {
    let study: StudyDTO
    @StateObject private var fileViewModel: FileViewModel
    @State private var showingAddFile = false
    @State private var showingDeleteAlert = false
    @State private var fileToDelete: FileMetadataDTO?
    @State private var showingEditStudy = false
    @StateObject private var studyViewModel = StudyViewModel()
    
    init(study: StudyDTO) {
        self.study = study
        self._fileViewModel = StateObject(wrappedValue: FileViewModel(studyId: study.id, patientId: study.patientId))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                studyInfoCard
                
                filesSection
            }
            .padding()
        }
        .navigationTitle("Исследование")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        showingEditStudy = true
                    }) {
                        Image(systemName: "pencil")
                    }

                    Button(action: {
                        showingAddFile = true
                    }) {
                        Image(systemName: "paperclip")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddFile) {
            AddFileView(
                fileViewModel: fileViewModel,
                patientId: study.patientId,
                studyId: study.id
            )
        }
        .sheet(isPresented: $showingEditStudy) {
            EditStudyView(study: study, studyViewModel: studyViewModel)
        }
        .alert("Удалить файл", isPresented: $showingDeleteAlert) {
            Button("Удалить", role: .destructive) {
                if let file = fileToDelete {
                    Task {
                        await fileViewModel.deleteFile(id: file.id)
                    }
                }
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Вы уверены, что хотите удалить файл '\(fileToDelete?.filename ?? "")'?")
        }
        .task {
            await fileViewModel.loadFiles()
        }
        .refreshable {
            await fileViewModel.loadFiles()
        }
    }
    
    private var studyInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Информация об исследовании")
                .font(.headline)
            
            infoRow("Тип исследования:", study.studyType)
            
            if let description = study.description {
                infoRow("Описание:", description)
            }
            
            infoRow("Дата исследования:", study.studyDate)
            infoRow("Количество файлов:", "\(study.fileCount)")
            infoRow("Создано:", formatDate(study.createdAt))
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

    
    private var filesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Файлы")
                    .font(.headline)
                
                Spacer()
                
                if fileViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if fileViewModel.files.isEmpty && !fileViewModel.isLoading {
                VStack(spacing: 16) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("Нет файлов")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Добавьте файлы к этому исследованию")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Добавить файл") {
                        showingAddFile = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else if !fileViewModel.files.isEmpty {
                LazyVStack(spacing: 8) {
                    ForEach(fileViewModel.files) { file in
                        FileRowView(
                            file: file,
                            onDownload: {
                                Task {
                                    await fileViewModel.downloadFile(file)
                                }
                            },
                            onDelete: {
                                fileToDelete = file
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
            }
            
            if let errorMessage = fileViewModel.errorMessage {
                Text("Ошибка: \(errorMessage)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text(title)
                .foregroundColor(.black)
            Text(value)
                .multilineTextAlignment(.leading)
                .foregroundColor(.gray)
                .fontWeight(.medium)
        }
    }

    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        return dateString
    }
}


#Preview {
    NavigationView {
        StudyDetailView(study: StudyDTO(
            id: UUID(),
            patientId: UUID(),
            studyType: "МРТ",
            description: "Исследование головного мозга",
            studyDate: "2025-07-14",
            fileCount: 3,
            createdAt: "2025-07-14T10:00:00.000000"
        ))
    }
}
