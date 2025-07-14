//
//  AddFileView.swift
//  med
//
//  Created by Parshina Daria on 14.07.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct AddFileView: View {
    @ObservedObject var fileViewModel: FileViewModel
    @Environment(\.dismiss) private var dismiss
    

    let patientId: UUID
    let studyId: UUID
    
    @State private var selectedDocuments: [DocumentFile] = []
    @State private var isLoading = false
    @State private var showingDocumentPicker = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Добавить файлы к исследованию")
                    .font(.headline)
                    .padding()
                
                VStack(spacing: 16) {

                    Button(action: {
                        showingDocumentPicker = true
                    }) {
                        Label("Выбрать документы", systemImage: "doc.badge.plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                    }
                    
                    Text("Поддерживаемые форматы: PDF, DOC, DOCX, TXT, RTF, XLS, XLSX")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                if !selectedDocuments.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Выбранные документы:")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(0..<selectedDocuments.count, id: \.self) { index in
                                    HStack {
                                        Image(systemName: documentIcon(for: selectedDocuments[index].name))
                                            .foregroundColor(documentIconColor(for: selectedDocuments[index].name))
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(selectedDocuments[index].name)
                                                .font(.body)
                                                .lineLimit(1)
                                            
                                            Text(formatFileSize(selectedDocuments[index].data.count))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            selectedDocuments.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                if !selectedDocuments.isEmpty {
                    Button(action: {
                        Task {
                            await uploadFiles()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            }
                            Text("Загрузить файлы (\(selectedDocuments.count))")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                    .padding()
                }
            }
            .navigationTitle("Добавить файлы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showingDocumentPicker,
                allowedContentTypes: [
                    .pdf,
                    .plainText,
                    .rtf,
                    .commaSeparatedText,
                    UTType(filenameExtension: "doc") ?? .data,
                    UTType(filenameExtension: "docx") ?? .data,
                    UTType(filenameExtension: "xls") ?? .data,
                    UTType(filenameExtension: "xlsx") ?? .data
                ],
                allowsMultipleSelection: true
            ) { result in
                handleDocumentSelection(result)
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Произошла ошибка при загрузке файлов")
            }
        }
    }
    
    private func handleDocumentSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            selectedDocuments = []
            
            for url in urls {
                let didStartAccessing = url.startAccessingSecurityScopedResource()
                defer {
                    if didStartAccessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    let document = DocumentFile(
                        name: url.lastPathComponent,
                        data: data,
                        mimeType: mimeType(for: url)
                    )
                    selectedDocuments.append(document)
                } catch {
                    print("Error reading document: \(error)")
                    DispatchQueue.main.async {
                        self.errorMessage = "Не удалось прочитать файл \(url.lastPathComponent): \(error.localizedDescription)"
                        self.showingError = true
                    }
                }
            }
            
        case .failure(let error):
            errorMessage = "Ошибка при выборе документов: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func mimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "pdf":
            return "application/pdf"
        case "txt":
            return "text/plain"
        case "rtf":
            return "application/rtf"
        case "csv":
            return "text/csv"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls":
            return "application/vnd.ms-excel"
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        default:
            return "application/octet-stream"
        }
    }
    
    private func documentIcon(for filename: String) -> String {
        let pathExtension = filename.lowercased().split(separator: ".").last ?? ""
        
        switch pathExtension {
        case "pdf":
            return "doc.text.fill"
        case "doc", "docx":
            return "doc.text.fill"
        case "xls", "xlsx":
            return "tablecells.fill"
        case "txt":
            return "text.alignleft"
        case "rtf":
            return "doc.richtext.fill"
        case "csv":
            return "tablecells.fill"
        default:
            return "doc.fill"
        }
    }
    
    private func documentIconColor(for filename: String) -> Color {
        let pathExtension = filename.lowercased().split(separator: ".").last ?? ""
        
        switch pathExtension {
        case "pdf":
            return .red
        case "doc", "docx":
            return .blue
        case "xls", "xlsx":
            return .green
        case "txt":
            return .gray
        case "rtf":
            return .purple
        case "csv":
            return .orange
        default:
            return .secondary
        }
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    private func uploadFiles() async {
        isLoading = true
        errorMessage = nil
        
        var filesToUpload: [FileUploadData] = []
        
        for document in selectedDocuments {
            let fileUpload = FileUploadData(
                data: document.data,
                filename: document.name,
                mimeType: document.mimeType
            )
            filesToUpload.append(fileUpload)
        }
        
        let success = await fileViewModel.uploadFiles(filesToUpload)
        
        await MainActor.run {
            isLoading = false
            
            if success {
                dismiss()
            } else {
                errorMessage = fileViewModel.errorMessage ?? "Неизвестная ошибка при загрузке"
                showingError = true
            }
        }
    }
}

struct AddFileView_Previews: PreviewProvider {
    static var previews: some View {
        AddFileView(
            fileViewModel: FileViewModel(studyId: UUID(), patientId: UUID()),
            patientId: UUID(),
            studyId: UUID()
        )
    }
}


