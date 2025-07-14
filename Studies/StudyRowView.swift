//
//  StudyRowView.swift
//  med
//
//  Created by Parshina Daria on 14.07.2025.
//

import SwiftUICore

struct StudyRowView: View {
    let study: StudyDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(study.studyType)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            if let description = study.description {
                Text("Описание: \(description)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Дата: \(study.studyDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                let count = study.fileCount
                let word = pluralForm(for: count, wordForms: ["файл", "файла", "файлов"])
                
                Text("\(count) \(word)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
    
    private func pluralForm(for count: Int, wordForms: [String]) -> String {
        let remainder100 = count % 100
        let remainder10 = count % 10

        if remainder100 >= 11 && remainder100 <= 14 {
            return wordForms[2]
        }

        switch remainder10 {
        case 1:
            return wordForms[0]
        case 2...4:
            return wordForms[1]
        default:
            return wordForms[2]
        }
    }
}
