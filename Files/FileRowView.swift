//
//  FileRowView.swift
//  med
//
//  Created by Parshina Daria on 14.07.2025.
//

import SwiftUICore
import SwiftUI

struct FileRowView: View {
    let file: FileMetadataDTO
    let onDownload: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: fileIcon)
                .font(.system(size: 24))
                .foregroundColor(fileIconColor)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(file.filename)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack {
                    Text(formatFileSize(file.sizeBytes))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(file.contentType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Загружено: \(formatUploadDate(file.uploadedAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            

            HStack(spacing: 8) {
                Button(action: onDownload) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var fileIcon: String {
        let fileExtension = (file.filename as NSString).pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return "doc.text.fill"
        case "jpg", "jpeg", "png", "gif", "bmp":
            return "photo.fill"
        case "mp4", "mov", "avi":
            return "video.fill"
        case "mp3", "wav", "m4a":
            return "music.note"
        case "doc", "docx":
            return "doc.text.fill"
        case "xls", "xlsx":
            return "tablecells.fill"
        case "zip", "rar", "7z":
            return "archivebox.fill"
        default:
            return "doc.fill"
        }
    }
    
    private var fileIconColor: Color {
        let fileExtension = (file.filename as NSString).pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return .red
        case "jpg", "jpeg", "png", "gif", "bmp":
            return .blue
        case "mp4", "mov", "avi":
            return .purple
        case "mp3", "wav", "m4a":
            return .orange
        case "doc", "docx":
            return .blue
        case "xls", "xlsx":
            return .green
        case "zip", "rar", "7z":
            return .gray
        default:
            return .secondary
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatUploadDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        
        return dateString
    }
}
